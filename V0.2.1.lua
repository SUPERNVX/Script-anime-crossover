--[[
    SCRIPT DE FARM (V0.5 - TELEPORTE + COLOCAR UNIDADE + LOOP DE UPGRADE)
]]

print("FARM V0.5 (via HttpGet): Script carregado e iniciando...")
wait(1)

--====================================================================================
-- CONFIGURAÇÕES 
--====================================================================================
-- Teleporte
local TARGET_CFRAME = CFrame.new(7.1433563232421875, 3.066650629043579, -65.1104507446289)

-- Colocação da Unidade (!!) AJUSTE ESSES VALORES CONFORME SUA UNIDADE E POSIÇÃO DESEJADA (!!)
local UNIT_PLACEMENT_POSITION = Vector3.new(5.92716646194458, 3.0666775703430176, -65.96981048583984) -- Posição onde a unidade será colocada
local UNIT_PLACEMENT_SLOT_NUMBER = 4          -- Slot da unidade na sua barra
local UNIT_INSTANCE_ID_IN_SLOT = "u017003s1"  -- ID da instância/skin da unidade no slot
local UNIT_BASE_ID = "u017003"                -- ID base da unidade

-- Encontrar Unidade Após Colocação
local UNIT_TO_FIND_NAME = "U0Model" -- Nome esperado da unidade no Workspace APÓS ser colocada

-- Caminhos e Parâmetros de Upgrade/Outros
local UNITS_FOLDER_PATH_IN_WORKSPACE = "Units.UFolder"
local UPGRADE_PATH_TOP = 1
local UPGRADE_PATH_BOTTOM = 2
local INITIAL_TOP_UPGRADES_COUNT = 2      
local INITIAL_BOTTOM_UPGRADES_COUNT = 2   
local DELAY_BETWEEN_UPGRADE_ATTEMPTS = 1.5 
local DELAY_AFTER_PLACEMENT = 3           -- Quanto tempo esperar para a unidade aparecer após o comando de colocar
local CHECK_UNIT_INTERVAL = 2             -- Intervalo reduzido para encontrar a unidade mais rápido após colocar
local MAX_UNIT_FIND_ATTEMPTS = 5          -- (5 tentativas * 2s = 10s para encontrar)
local REMOTE_PLACE_UNIT_PATH = "RemoteFunctions.PlaceUnitFunctions.PlaceUnit"
local REMOTE_UPGRADE_UNIT_PATH = "RemoteFunctions.UpgradeUnitFunctions.UpgradeUnit"
local REMOTE_SPEED_CHANGE_PATH = "RemoteFunctions.SpeedChange.ChangeSpeedRemoteFunction" -- Para velocidade 2x
print("FARM V0.5: Configs carregadas.")

--====================================================================================
-- SERVIÇOS E VARIÁVEIS GLOBAIS
--====================================================================================
local Players = game:GetService("Players"); local Workspace = game:GetService("Workspace"); local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer; local character = nil; local humanoidRootPart = nil
local unitsFolderInstance = nil; local targetUnitInstance = nil; local stopUpgradeLoop = false
print("FARM V0.5: Serviços e globais ok.")

--====================================================================================
-- FUNÇÕES AUXILIARES (customSplit, getRemote)
--====================================================================================
local function customSplit(s, sep) if type(s)~="string" or type(sep)~="string" then return {} end; if sep=="" then return {s} end; local r={}; local ci=1; while true do local si,ei=string.find(s,sep,ci,true); if not si then table.insert(r,string.sub(s,ci)); break end; table.insert(r,string.sub(s,ci,si-1)); ci=ei+1; if ci>#s and si then table.insert(r,""); break end end; return r end
local remoteCache = {} -- Cache para os remotes
local function getRemote(fp)
    if remoteCache[fp] then return remoteCache[fp] end -- Retorna do cache se já obtido
    print("V0.5 getRemote: Tentando '"..tostring(fp).."'"); if type(fp)~="string" then warn("getRemote: Path non-string"); return nil end; local pp=customSplit(fp,"."); if not pp or #pp==0 then warn("getRemote: customSplit fail"); return nil end; local co=ReplicatedStorage; for _,pn in ipairs(pp) do if co and type(co.FindFirstChild)=="function" then local f=co:FindFirstChild(pn,5); if not f then warn("getRemote: Part NF: "..pn.." in "..co:GetFullName()); remoteCache[fp] = false; return nil end; co=f else warn("getRemote: Invalid CO for "..pn); remoteCache[fp] = false; return nil end end; 
    if co then print("V0.5 getRemote: Found: "..co:GetFullName().." ("..co.ClassName..")"); remoteCache[fp] = co else warn("V0.5 getRemote: Not Found: "..fp); remoteCache[fp] = false end
    return co
end

--====================================================================================
-- FUNÇÕES PRINCIPAIS
--====================================================================================
local function initializePlayerAndCharacter() print("V0.5 Init P&C..."); if not player then print("ERR: No P"); return false end; character=player.Character or player.CharacterAdded:Wait(); if not character then print("ERR: No C"); return false end; humanoidRootPart=character:WaitForChild("HumanoidRootPart",20); if not humanoidRootPart then print("ERR: No HRP"); return false end; print("OK: P&C&HRP init."); return true end
local function executeTeleport() print("V0.5 TP..."); if not humanoidRootPart then print("ERR: HRP nil for TP"); return false end; local s,e=pcall(function() humanoidRootPart.CFrame=TARGET_CFRAME end); if s then print("OK: TP sent. Pos:"..tostring(humanoidRootPart.Position)); return true else print("ERR: TP fail: "..tostring(e)); return false end end
local function findUnitsFolder() print("V0.5 Find UF..."); local p=customSplit(UNITS_FOLDER_PATH_IN_WORKSPACE,"."); local c=Workspace; for _,n in ipairs(p) do if c and type(c.WaitForChild)=="function" then c=c:WaitForChild(n,10); if not c then print("ERR: UF part '"..n.."' not found."); return false end else print("ERR: Invalid obj for UF."); return false end end; unitsFolderInstance=c; if unitsFolderInstance then print("OK: UF: "..unitsFolderInstance:GetFullName()); return true else print("ERR: UF not found."); return false end end

local function setGameSpeedTo2X() -- NOVA FUNÇÃO (REINTRODUZIDA)
    print("V0.5 setGameSpeedTo2X: Tentando mudar velocidade...")
    local speedChangeRemote = getRemote(REMOTE_SPEED_CHANGE_PATH)
    if not speedChangeRemote or type(speedChangeRemote.InvokeServer) ~= "function" then
        warn("setGameSpeedTo2X: Remote de mudança de velocidade inválido ou não encontrado.")
        return
    end
    local success, err = pcall(function() speedChangeRemote:InvokeServer() end)
    if success then print("setGameSpeedTo2X: Comando para velocidade 2x enviado.")
    else warn("setGameSpeedTo2X: Falha ao enviar comando para velocidade 2x: " .. tostring(err)) end
    wait(0.5) -- Pequeno delay para processar
end

local function placeUnitOnMap() -- NOVA FUNÇÃO (REINTRODUZIDA E ADAPTADA)
    print("V0.5 placeUnitOnMap: Tentando colocar unidade...")
    local placeUnitRemote = getRemote(REMOTE_PLACE_UNIT_PATH)
    if not placeUnitRemote or type(placeUnitRemote.InvokeServer) ~= "function" then
        warn("placeUnitOnMap: Remote de colocar unidade inválido ou não encontrado.")
        return false
    end
    print("placeUnitOnMap: Colocando Slot "..UNIT_PLACEMENT_SLOT_NUMBER.." (Inst:"..UNIT_INSTANCE_ID_IN_SLOT..",Base:"..UNIT_BASE_ID..") em "..tostring(UNIT_PLACEMENT_POSITION))
    local argsToPlace = {
        [1] = UNIT_PLACEMENT_SLOT_NUMBER,
        [2] = UNIT_INSTANCE_ID_IN_SLOT,
        [3] = UNIT_BASE_ID,
        [4] = UNIT_PLACEMENT_POSITION
    }
    local success, err = pcall(function() placeUnitRemote:InvokeServer(unpack(argsToPlace)) end)
    if success then
        print("placeUnitOnMap: Comando para colocar unidade enviado. Esperando "..DELAY_AFTER_PLACEMENT.."s para unidade aparecer...")
        wait(DELAY_AFTER_PLACEMENT)
        return true
    else
        warn("placeUnitOnMap: Falha ao enviar comando para colocar unidade: " .. tostring(err))
        return false
    end
end

local function findOrWaitForUnit() 
    print("V0.5 findOrWaitForUnit: Procurando '"..UNIT_TO_FIND_NAME.."'..."); 
    if not unitsFolderInstance then print("ERR: UF nil."); return false end; 
    for att=1,MAX_UNIT_FIND_ATTEMPTS do 
        targetUnitInstance=unitsFolderInstance:FindFirstChild(UNIT_TO_FIND_NAME); 
        if targetUnitInstance and targetUnitInstance:IsA("Model") then 
            print("OK: Unit '"..UNIT_TO_FIND_NAME.."' found: "..targetUnitInstance:GetFullName()); return true 
        else 
            if targetUnitInstance then print("WARN: Obj '"..UNIT_TO_FIND_NAME.."' found but not Model: "..targetUnitInstance.ClassName) 
            else print("INFO: Unit '"..UNIT_TO_FIND_NAME.."' not found. Att "..att.."/"..MAX_UNIT_FIND_ATTEMPTS..". Waiting "..CHECK_UNIT_INTERVAL.."s...") end 
        end; 
        if att<MAX_UNIT_FIND_ATTEMPTS then wait(CHECK_UNIT_INTERVAL) end 
    end; 
    print("ERR: Unit '"..UNIT_TO_FIND_NAME.."' NOT found after tries."); targetUnitInstance=nil; return false 
end

local upgradeUnitRemoteFunc = nil -- Cache já existia, mantido
local function performSingleUpgrade(unitModel,upgradePath) if not upgradeUnitRemoteFunc then print("V0.5 PSU: Getting remote..."); upgradeUnitRemoteFunc=getRemote(REMOTE_UPGRADE_UNIT_PATH); if not upgradeUnitRemoteFunc or type(upgradeUnitRemoteFunc.InvokeServer)~="function" then warn("PSU: Invalid remote."); upgradeUnitRemoteFunc=nil; return false end; print("V0.5 PSU: Remote cached.") end; if not upgradeUnitRemoteFunc then return false end; print("V0.5 PSU: Tentando para "..unitModel.Name..", path "..upgradePath); local s,r=pcall(function() return upgradeUnitRemoteFunc:InvokeServer(unitModel,upgradePath) end); if s then if r==false then print("V0.5 PSU: UPG NEGADO sv "..unitModel.Name..",P"..upgradePath); return false end; print("V0.5 PSU: UPG SUCESSO "..unitModel.Name..",P"..upgradePath..".Res:"..tostring(r)); return true else warn("V0.5 PSU: ERR InvokeServer: "..tostring(r)); return false end end
local function continuousUpgradeLoop() if not targetUnitInstance then print("ERR:No unit CUL.");return end; print("V0.5 CUL: Starting for "..targetUnitInstance.Name); local tU=0;local bU=0;local iPC=false;local cUT=false;local iter=0; while not stopUpgradeLoop and targetUnitInstance and targetUnitInstance.Parent do iter=iter+1; print("--- V0.5 CUL: Loop #"..iter.." ---"); local uTC=false; if not iPC then if tU<INITIAL_TOP_UPGRADES_COUNT then if performSingleUpgrade(targetUnitInstance,UPGRADE_PATH_TOP) then tU=tU+1;uTC=true end elseif bU<INITIAL_BOTTOM_UPGRADES_COUNT then if performSingleUpgrade(targetUnitInstance,UPGRADE_PATH_BOTTOM) then bU=bU+1;uTC=true end else iPC=true;cUT=true;print("V0.5 CUL: Initial phase DONE. Continuous TOP.") end end; if cUT then if performSingleUpgrade(targetUnitInstance,UPGRADE_PATH_TOP) then uTC=true end end; wait(DELAY_BETWEEN_UPGRADE_ATTEMPTS) end; if stopUpgradeLoop then print("V0.5 CUL: Loop stopped cmd.") end; if not(targetUnitInstance and targetUnitInstance.Parent) then print("V0.5 CUL: Loop stopped, unit gone.") end end

--====================================================================================
-- EXECUÇÃO PRINCIPAL
--====================================================================================
local function main() 
    print("FARM V0.5 main()..."); wait(1); 
    if not initializePlayerAndCharacter() then print("CRIT: P init fail."); return end; 
    if not executeTeleport() then print("CRIT: TP fail."); return end; 
    
    setGameSpeedTo2X() -- Chamando a função de velocidade
    
    if not placeUnitOnMap() then -- Chamando a função de colocar unidade
        print("CRIT: Falha ao colocar unidade. Abortando script."); return
    end
    
    wait(1); -- Pequena pausa adicional após a colocação
    if not findUnitsFolder() then print("CRIT: UF fail."); return end; 

    if findOrWaitForUnit() then 
        print("INFO: Unidade colocada e encontrada, iniciando CUL..."); 
        continuousUpgradeLoop() 
    else 
        print("CRIT: Unidade NÃO encontrada após colocação. Verifique UNIT_TO_FIND_NAME e se a unidade foi realmente colocada com esse nome.") 
    end; 
    print("FARM V0.5 main() done.") 
end

local s_main,e_main=pcall(main); if not s_main then warn("FATAL ERR main(): ",e_main) end
print("FARM V0.5 (via HttpGet): Exec principal (call main) terminada.")
