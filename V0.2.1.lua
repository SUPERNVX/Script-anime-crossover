--[[
    SCRIPT DE FARM (V0.4.2 - COMPLETO - CONFIRMAÇÃO DO LOOP PRINCIPAL)
]]

print("FARM V0.4.2 (via HttpGet): Script carregado e iniciando...")
wait(1)

--====================================================================================
-- CONFIGURAÇÕES 
--====================================================================================
local TARGET_CFRAME = CFrame.new(7.1433563232421875, 3.066650629043579, -65.1104507446289)
local UNIT_TO_FIND_NAME = "U0Model" 
local UNITS_FOLDER_PATH_IN_WORKSPACE = "Units.UFolder"
local UPGRADE_PATH_TOP = 1
local UPGRADE_PATH_BOTTOM = 2
local INITIAL_TOP_UPGRADES_COUNT = 2      
local INITIAL_BOTTOM_UPGRADES_COUNT = 2   
local DELAY_BETWEEN_UPGRADE_ATTEMPTS = 1.5 
local CHECK_UNIT_INTERVAL = 5
local MAX_UNIT_FIND_ATTEMPTS = 6
local REMOTE_UPGRADE_UNIT_PATH = "RemoteFunctions.UpgradeUnitFunctions.UpgradeUnit"
print("FARM V0.4.2: Configs carregadas.")

--====================================================================================
-- SERVIÇOS E VARIÁVEIS GLOBAIS
--====================================================================================
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer
local character = nil
local humanoidRootPart = nil
local unitsFolderInstance = nil
local targetUnitInstance = nil
local stopUpgradeLoop = false
print("FARM V0.4.2: Serviços e globais ok.")

--====================================================================================
-- FUNÇÕES AUXILIARES
--====================================================================================
local function customSplit(s, sep) if type(s)~="string" or type(sep)~="string" then return {} end; if sep=="" then return {s} end; local r={}; local ci=1; while true do local si,ei=string.find(s,sep,ci,true); if not si then table.insert(r,string.sub(s,ci)); break end; table.insert(r,string.sub(s,ci,si-1)); ci=ei+1; if ci>#s and si then table.insert(r,""); break end end; return r end
local function getRemote(fp) print("V0.4.2 getRemote: Tentando '"..tostring(fp).."'"); if type(fp)~="string" then warn("getRemote: Path non-string"); return nil end; local pp=customSplit(fp,"."); if not pp or #pp==0 then warn("getRemote: customSplit fail"); return nil end; local co=ReplicatedStorage; for _,pn in ipairs(pp) do if co and type(co.FindFirstChild)=="function" then local f=co:FindFirstChild(pn,5); if not f then warn("getRemote: Part NF: "..pn.." in "..co:GetFullName()); return nil end; co=f else warn("getRemote: Invalid CO for "..pn); return nil end end; if co then print("V0.4.2 getRemote: Found: "..co:GetFullName().." ("..co.ClassName..")") else warn("V0.4.2 getRemote: Not Found: "..fp) end; return co end

--====================================================================================
-- FUNÇÕES DE INICIALIZAÇÃO E AÇÃO
--====================================================================================
local function initializePlayerAndCharacter() 
    print("V0.4.2 Init P&C..."); 
    if not player then print("ERR: No P"); return false end; 
    character=player.Character or player.CharacterAdded:Wait(); 
    if not character then print("ERR: No C"); return false end; 
    humanoidRootPart=character:WaitForChild("HumanoidRootPart",20); 
    if not humanoidRootPart then print("ERR: No HRP"); return false end; 
    print("OK: P&C&HRP init."); return true 
end

local function executeTeleport() 
    print("V0.4.2 TP..."); 
    if not humanoidRootPart then print("ERR: HRP nil for TP"); return false end; 
    local s,e=pcall(function() humanoidRootPart.CFrame=TARGET_CFRAME end); 
    if s then print("OK: TP sent. Pos:"..tostring(humanoidRootPart.Position)); return true 
    else print("ERR: TP fail: "..tostring(e)); return false end 
end

local function findUnitsFolder() 
    print("V0.4.2 Find UF..."); 
    local p=customSplit(UNITS_FOLDER_PATH_IN_WORKSPACE,"."); local c=Workspace; 
    for _,n in ipairs(p) do 
        if c and type(c.WaitForChild)=="function" then 
            c=c:WaitForChild(n,10); 
            if not c then print("ERR: UF part '"..n.."' not found."); return false end 
        else print("ERR: Invalid obj for UF."); return false end 
    end; 
    unitsFolderInstance=c; 
    if unitsFolderInstance then print("OK: UF: "..unitsFolderInstance:GetFullName()); return true 
    else print("ERR: UF not found."); return false end 
end

local function findOrWaitForUnit() 
    print("V0.4.2 findOrWaitForUnit: Procurando '"..UNIT_TO_FIND_NAME.."'..."); 
    if not unitsFolderInstance then print("ERR: UF nil."); return false end; 
    for att=1,MAX_UNIT_FIND_ATTEMPTS do 
        targetUnitInstance=unitsFolderInstance:FindFirstChild(UNIT_TO_FIND_NAME); 
        if targetUnitInstance and targetUnitInstance:IsA("Model") then 
            print("OK: Unit '"..UNIT_TO_FIND_NAME.."' found."); return true 
        else 
            if targetUnitInstance then print("WARN: Obj '"..UNIT_TO_FIND_NAME.."' found but not Model: "..targetUnitInstance.ClassName) 
            else print("INFO: Unit '"..UNIT_TO_FIND_NAME.."' not found. Att "..att.."/"..MAX_UNIT_FIND_ATTEMPTS) end 
        end; 
        if att<MAX_UNIT_FIND_ATTEMPTS then wait(CHECK_UNIT_INTERVAL) end 
    end; 
    print("ERR: Unit '"..UNIT_TO_FIND_NAME.."' NOT found after tries."); targetUnitInstance=nil; return false 
end

local upgradeUnitRemoteFunc = nil
local function performSingleUpgrade(unitModel, upgradePath)
    if not upgradeUnitRemoteFunc then 
        print("V0.4.2 PSU: Getting remote..."); 
        upgradeUnitRemoteFunc=getRemote(REMOTE_UPGRADE_UNIT_PATH); 
        if not upgradeUnitRemoteFunc or type(upgradeUnitRemoteFunc.InvokeServer)~="function" then 
            warn("PSU: Invalid remote."); upgradeUnitRemoteFunc=nil; return false 
        end; 
        print("V0.4.2 PSU: Remote cached.") 
    end
    if not upgradeUnitRemoteFunc then return false end
    
    print("V0.4.2 PSU: Tentando para "..unitModel.Name..", path "..upgradePath)
    local success, result = pcall(function() return upgradeUnitRemoteFunc:InvokeServer(unitModel, upgradePath) end)
    
    if success then
        if result == false then 
            print("V0.4.2 PSU: Upgrade NEGADO sv para "..unitModel.Name..", path "..upgradePath); return false 
        end
        print("V0.4.2 PSU: Upgrade SUCESSO para "..unitModel.Name..", path "..upgradePath..". Result: "..tostring(result))
        return true
    else 
        warn("V0.4.2 PSU: ERRO CRÍTICO InvokeServer: " .. tostring(result)); return false 
    end
end

--====================================================================================
-- LOOP DE UPGRADE CONTÍNUO
--====================================================================================
local function continuousUpgradeLoop()
    if not targetUnitInstance then print("ERR: No unit for CUL."); return end
    print("FARM V0.4.2: Iniciando CONTINUOUS UPGRADE LOOP para " .. targetUnitInstance.Name)

    local topUpgradesDone = 0
    local bottomUpgradesDone = 0
    local initialPhaseComplete = false
    local continuouslyUpgradingTop = false
    local loopIteration = 0 

    while not stopUpgradeLoop and targetUnitInstance and targetUnitInstance.Parent do
        loopIteration = loopIteration + 1 
        print("--- FARM V0.4.2 CUL: Iteração do Loop #"..loopIteration.." ---") 

        local upgradedThisCycle = false
        if not initialPhaseComplete then
            if topUpgradesDone < INITIAL_TOP_UPGRADES_COUNT then
                if performSingleUpgrade(targetUnitInstance, UPGRADE_PATH_TOP) then
                    topUpgradesDone = topUpgradesDone + 1; upgradedThisCycle = true
                end
            elseif bottomUpgradesDone < INITIAL_BOTTOM_UPGRADES_COUNT then
                 if performSingleUpgrade(targetUnitInstance, UPGRADE_PATH_BOTTOM) then
                    bottomUpgradesDone = bottomUpgradesDone + 1; upgradedThisCycle = true
                end
            else
                initialPhaseComplete = true; continuouslyUpgradingTop = true
                print("FARM V0.4.2 CUL: Fase inicial CONCLUÍDA. Iniciando upgrade contínuo do TOPO.")
            end
        end

        if continuouslyUpgradingTop then
            if performSingleUpgrade(targetUnitInstance, UPGRADE_PATH_TOP) then
                upgradedThisCycle = true
            end
        end
        
        wait(DELAY_BETWEEN_UPGRADE_ATTEMPTS) 
    end
    if stopUpgradeLoop then print("FARM V0.4.2 CUL: Loop parado por comando.") end
    if not (targetUnitInstance and targetUnitInstance.Parent) then print("FARM V0.4.2 CUL: Loop parado, unidade não existe mais.") end
end

--====================================================================================
-- EXECUÇÃO PRINCIPAL
--====================================================================================
local function main() 
    print("FARM V0.4.2 main()..."); 
    wait(1); 
    if not initializePlayerAndCharacter() then print("CRIT: P init fail."); return end; 
    
    -- GARANTINDO QUE O TELEPORTE É CHAMADO:
    if not executeTeleport() then print("CRIT: TP fail."); return end; 
    
    wait(1); 
    if not findUnitsFolder() then print("CRIT: UF fail."); return end; 
    if findOrWaitForUnit() then 
        print("INFO: Unit found, starting CUL..."); 
        continuousUpgradeLoop() 
    else 
        print("INFO: Unit not found, no UPGs.") 
    end; 
    print("FARM V0.4.2 main() done.") 
end

local s_main,e_main=pcall(main); 
if not s_main then 
    warn("FATAL ERR main(): ",e_main) 
end
print("FARM V0.4.2 (via HttpGet): Exec principal (call main) terminada.")
