--[[
    SCRIPT DE FARM (V0.6 - FINAL - FARM AFK COMPLETO COM REINÍCIO AUTOMÁTICO)
]]

print("FARM V0.6 FINAL (via HttpGet): Script carregado e iniciando...")
wait(1)

--====================================================================================
-- CONFIGURAÇÕES (Valores descobertos e padrão)
--====================================================================================
-- Teleporte
local TARGET_CFRAME = CFrame.new(7.1433563232421875, 3.066650629043579, -65.1104507446289)

-- Colocação da Unidade
local UNIT_PLACEMENT_POSITION = Vector3.new(5.92716646194458, 3.0666775703430176, -65.96981048583984)
local UNIT_PLACEMENT_SLOT_NUMBER = 4          
local UNIT_INSTANCE_ID_IN_SLOT = "u017003s1"  -- (!!) CONFIRME SE ESTES IDs AINDA SÃO OS CORRETOS PARA A UNIDADE NO SLOT 4 (!!)
local UNIT_BASE_ID = "u017003"                -- (!!) CONFIRME SE ESTES IDs AINDA SÃO OS CORRETOS PARA A UNIDADE NO SLOT 4 (!!)

-- Encontrar Unidade Após Colocação
local UNIT_TO_FIND_NAME = "U0Model" -- (!!) CONFIRME SE ESTE É O NOME DA UNIDADE APÓS SER COLOCADA (!!)

-- Caminhos e Parâmetros de Upgrade/Outros
local UNITS_FOLDER_PATH_IN_WORKSPACE = "Units.UFolder"
local UPGRADE_PATH_TOP = 1; local UPGRADE_PATH_BOTTOM = 2
local INITIAL_TOP_UPGRADES_COUNT = 2; local INITIAL_BOTTOM_UPGRADES_COUNT = 2   
local DELAY_BETWEEN_UPGRADE_ATTEMPTS = 1.5 
local DELAY_AFTER_PLACEMENT = 3           
local CHECK_UNIT_INTERVAL = 2             
local MAX_UNIT_FIND_ATTEMPTS = 5          
local REMOTE_PLACE_UNIT_PATH = "RemoteFunctions.PlaceUnitFunctions.PlaceUnit"
local REMOTE_UPGRADE_UNIT_PATH = "RemoteFunctions.UpgradeUnitFunctions.UpgradeUnit"
local REMOTE_SPEED_CHANGE_PATH = "RemoteFunctions.SpeedChange.ChangeSpeedRemoteFunction"

-- CONFIGURAÇÕES PARA REINÍCIO AUTOMÁTICO (COM VALORES DESCOBERTOS)
local VICTORY_SCREEN_NAME = "EndOfGameGUI"                -- NOME DESCOBERTO!
local REMOTE_PLAY_AGAIN_PATH = "RemoteEvents.UIRemoteEvents.PostEndGameClient" -- CAMINHO COMPLETO DESCOBERTO!
local PLAY_AGAIN_ARGUMENT = "replay"                      -- ARGUMENTO DESCOBERTO!
local CHECK_FOR_VICTORY_SCREEN_INTERVAL = 3 
print("FARM V0.6 FINAL: Configs carregadas.")

--====================================================================================
-- SERVIÇOS E VARIÁVEIS GLOBAIS
--====================================================================================
local Players = game:GetService("Players"); local Workspace = game:GetService("Workspace"); local ReplicatedStorage = game:GetService("ReplicatedStorage"); local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
if not LocalPlayer then error("FARM V0.6 FATAL: LocalPlayer não encontrado no início.") end
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui") 
if not PlayerGui then error("FARM V0.6 FATAL: PlayerGui não encontrada no início.") end

local character = nil; local humanoidRootPart = nil
local unitsFolderInstance = nil; local targetUnitInstance = nil; 
local stopAllLoops = false 
print("FARM V0.6 FINAL: Serviços e globais ok.")

--====================================================================================
-- FUNÇÕES AUXILIARES (customSplit, getRemote com cache)
--====================================================================================
local function customSplit(s, sep) if type(s)~="string" or type(sep)~="string" then return {} end; if sep=="" then return {s} end; local r={}; local ci=1; while true do local si,ei=string.find(s,sep,ci,true); if not si then table.insert(r,string.sub(s,ci)); break end; table.insert(r,string.sub(s,ci,si-1)); ci=ei+1; if ci>#s and si then table.insert(r,""); break end end; return r end
local remoteCache = {}; local function getRemote(fp) if remoteCache[fp] == false then return nil elseif remoteCache[fp] then return remoteCache[fp] end; print("V0.6 getRemote: "..tostring(fp)); if type(fp)~="string" then warn("getRemote: Path non-string"); remoteCache[fp]=false; return nil end; local pp=customSplit(fp,"."); if not pp or #pp==0 then warn("getRemote: customSplit fail"); remoteCache[fp]=false; return nil end; local co=ReplicatedStorage; for _,pn in ipairs(pp) do if co and type(co.FindFirstChild)=="function" then local f=co:FindFirstChild(pn,3); if not f then warn("getRemote: Part NF: "..pn.." in "..co:GetFullName()); remoteCache[fp]=false; return nil end; co=f else warn("getRemote: Invalid CO for "..pn); remoteCache[fp]=false; return nil end end; if co then print("V0.6 getRemote: Found: "..co:GetFullName().." ("..co.ClassName..")"); remoteCache[fp]=co else warn("V0.6 getRemote: Not Found: "..fp); remoteCache[fp]=false end; return co end

--====================================================================================
-- FUNÇÕES DE JOGO
--====================================================================================
local function initializePlayerAndCharacter() print("V0.6 Init P&C..."); character=LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait(); if not character then print("ERR: No C"); return false end; humanoidRootPart=character:WaitForChild("HumanoidRootPart",20); if not humanoidRootPart then print("ERR: No HRP"); return false end; print("OK: P&C&HRP init."); return true end
local function executeTeleport() print("V0.6 TP..."); if not humanoidRootPart then print("ERR: HRP nil for TP"); return false end; local s,e=pcall(function() humanoidRootPart.CFrame=TARGET_CFRAME end); if s then print("OK: TP sent. Pos:"..tostring(humanoidRootPart.Position)); return true else print("ERR: TP fail: "..tostring(e)); return false end end
local function findUnitsFolder() print("V0.6 Find UF..."); local p=customSplit(UNITS_FOLDER_PATH_IN_WORKSPACE,"."); local c=Workspace; for _,n in ipairs(p) do if c and type(c.WaitForChild)=="function" then c=c:WaitForChild(n,10); if not c then print("ERR: UF part '"..n.."' not found."); return false end else print("ERR: Invalid obj for UF."); return false end end; unitsFolderInstance=c; if unitsFolderInstance then print("OK: UF: "..unitsFolderInstance:GetFullName()); return true else print("ERR: UF not found."); return false end end
local function setGameSpeedTo2X() print("V0.6 setGameSpeed..."); local r=getRemote(REMOTE_SPEED_CHANGE_PATH); if not r or type(r.InvokeServer)~="function" then warn("Speed: Remote invalid."); return end; local s,e=pcall(function() r:InvokeServer() end); if s then print("Speed: Cmd sent.") else warn("Speed: Fail: "..tostring(e)) end; wait(0.5) end
local function placeUnitOnMap() print("V0.6 placeUnit..."); local r=getRemote(REMOTE_PLACE_UNIT_PATH); if not r or type(r.InvokeServer)~="function" then warn("PlaceU: Remote invalid."); return false end; print("PlaceU: Slot"..UNIT_PLACEMENT_SLOT_NUMBER.." etc."); local a={[1]=UNIT_PLACEMENT_SLOT_NUMBER,[2]=UNIT_INSTANCE_ID_IN_SLOT,[3]=UNIT_BASE_ID,[4]=UNIT_PLACEMENT_POSITION}; local s,e=pcall(function() r:InvokeServer(unpack(a)) end); if s then print("PlaceU: Cmd sent. Waiting "..DELAY_AFTER_PLACEMENT.."s"); wait(DELAY_AFTER_PLACEMENT); return true else warn("PlaceU: Fail: "..tostring(e)); return false end end
local function findOrWaitForUnit() print("V0.6 findUnit: Looking for '"..UNIT_TO_FIND_NAME.."'..."); if not unitsFolderInstance then print("ERR: UF nil."); return false end; for att=1,MAX_UNIT_FIND_ATTEMPTS do targetUnitInstance=unitsFolderInstance:FindFirstChild(UNIT_TO_FIND_NAME); if targetUnitInstance and targetUnitInstance:IsA("Model") then print("OK: Unit '"..UNIT_TO_FIND_NAME.."' found: "..targetUnitInstance:GetFullName()); return true else if targetUnitInstance then print("WARN: Obj '"..UNIT_TO_FIND_NAME.."' found but not Model: "..targetUnitInstance.ClassName) else print("INFO: Unit '"..UNIT_TO_FIND_NAME.."' not found. Att "..att) end end; if att<MAX_UNIT_FIND_ATTEMPTS then wait(CHECK_UNIT_INTERVAL) end end; print("ERR: Unit '"..UNIT_TO_FIND_NAME.."' NOT found."); targetUnitInstance=nil; return false end
local upgradeUnitRemoteFunc = nil; local function performSingleUpgrade(uM,uP) if not upgradeUnitRemoteFunc then print("V0.6 PSU: Get remote..."); upgradeUnitRemoteFunc=getRemote(REMOTE_UPGRADE_UNIT_PATH); if not upgradeUnitRemoteFunc or type(upgradeUnitRemoteFunc.InvokeServer)~="function" then warn("PSU: Invalid remote."); upgradeUnitRemoteFunc=nil; return false end; print("V0.6 PSU: Remote cached.") end; if not upgradeUnitRemoteFunc then return false end; print("V0.6 PSU: Upg "..uM.Name..",P"..uP); local s,r=pcall(function() return upgradeUnitRemoteFunc:InvokeServer(uM,uP) end); if s then if r==false then print("V0.6 PSU: UPG NEGADO sv "..uM.Name..",P"..uP); return false end; print("V0.6 PSU: UPG SUCESSO "..uM.Name..",P"..uP..".Res:"..tostring(r)); return true else warn("V0.6 PSU: ERR InvokeServer: "..tostring(r)); return false end end
local function continuousUpgradeLoop() if not targetUnitInstance then print("ERR:No unit CUL.");return end; print("V0.6 CUL: Starting for "..targetUnitInstance.Name); local tU,bU,iPC,cUT,iter=0,0,false,false,0; while not stopAllLoops and targetUnitInstance and targetUnitInstance.Parent do iter=iter+1; print("--- V0.6 CUL: Loop #"..iter.." ---"); local uTC=false; if not iPC then if tU<INITIAL_TOP_UPGRADES_COUNT then if performSingleUpgrade(targetUnitInstance,UPGRADE_PATH_TOP) then tU=tU+1;uTC=true end elseif bU<INITIAL_BOTTOM_UPGRADES_COUNT then if performSingleUpgrade(targetUnitInstance,UPGRADE_PATH_BOTTOM) then bU=bU+1;uTC=true end else iPC=true;cUT=true;print("V0.6 CUL: Initial phase DONE. Continuous TOP.") end end; if cUT then if performSingleUpgrade(targetUnitInstance,UPGRADE_PATH_TOP) then uTC=true end end; wait(DELAY_BETWEEN_UPGRADE_ATTEMPTS) end; if stopAllLoops then print("V0.6 CUL: Loop stopped (cmd).") elseif not(targetUnitInstance and targetUnitInstance.Parent) then print("V0.6 CUL: Loop stopped (unit gone).") else print("V0.6 CUL: Loop naturally ended.") end end

--====================================================================================
-- FUNÇÃO DE REINÍCIO DE FASE
--====================================================================================
local function checkForAndPressPlayAgain()
    print("V0.6 checkPlayAgain: Verificando tela '"..VICTORY_SCREEN_NAME.."'...")
    local victoryScreen = PlayerGui:FindFirstChild(VICTORY_SCREEN_NAME, true) 

    if victoryScreen and victoryScreen.Enabled then
        print("V0.6 checkPlayAgain: Tela de vitória ('"..VICTORY_SCREEN_NAME.."') detectada e habilitada!")
        local playAgainRemote = getRemote(REMOTE_PLAY_AGAIN_PATH) 

        if playAgainRemote then
            if playAgainRemote:IsA("RemoteEvent") then
                print("V0.6 checkPlayAgain: RemoteEvent '"..REMOTE_PLAY_AGAIN_PATH.."' encontrado. Disparando com argumento: '" .. PLAY_AGAIN_ARGUMENT .. "'")
                local success, err = pcall(function()
                    playAgainRemote:FireServer(PLAY_AGAIN_ARGUMENT) 
                end)
                if success then print("V0.6 checkPlayAgain: RemoteEvent disparado com sucesso!"); return true 
                else warn("V0.6 checkPlayAgain: Erro ao disparar RemoteEvent: "..tostring(err)); return false end
            else warn("V0.6 checkPlayAgain: Objeto em '"..REMOTE_PLAY_AGAIN_PATH.."' NÃO é RemoteEvent. É: "..playAgainRemote.ClassName); return false end
        else warn("V0.6 checkPlayAgain: Remote para jogar novamente ('"..REMOTE_PLAY_AGAIN_PATH.."') não encontrado."); return false end
    else return false end
end

--====================================================================================
-- LOOP DE JOGO PRINCIPAL (MASTER LOOP)
--====================================================================================
local function masterGameLoop()
    print("FARM V0.6 FINAL: Iniciando MASTER GAME LOOP...")
    stopAllLoops = false 

    while not stopAllLoops do
        print("===== FARM V0.6 MASTER LOOP: INICIANDO NOVA RODADA =====")
        targetUnitInstance = nil 
        remoteCache = {} -- Limpa o cache de remotes para a nova rodada (caso algum mude, improvável mas seguro)
        
        if not initializePlayerAndCharacter() then print("CRIT masterLoop: P init fail. Tentando novamente em 10s..."); wait(10); stopAllLoops=true; continue end -- Parar se init falhar criticamente
        if not executeTeleport() then print("CRIT masterLoop: TP fail. Tentando novamente em 10s..."); wait(10); stopAllLoops=true; continue end -- Parar se teleporte falhar
        
        setGameSpeedTo2X() 
        
        if not placeUnitOnMap() then print("CRIT masterLoop: Place unit fail. Tentando novamente em 10s..."); wait(10); continue end
        
        wait(1); 
        if not findUnitsFolder() then print("CRIT masterLoop: UF fail. Tentando novamente em 10s..."); wait(10); continue end
        
        if findOrWaitForUnit() then 
            print("INFO masterLoop: Unidade colocada e encontrada, iniciando CUL..."); 
            
            local upgradeCoroutine = coroutine.create(continuousUpgradeLoop)
            local co_success, co_error = coroutine.resume(upgradeCoroutine)
            if not co_success then warn("ERRO AO INICIAR CORROTINA DE UPGRADE:", co_error) end
            print("INFO masterLoop: Loop de upgrade (CUL) iniciado/resumido.")

            local roundOver = false
            local checkVictoryStartTime = tick()
            while not stopAllLoops and coroutine.status(upgradeCoroutine) ~= "dead" and not roundOver do
                if checkForAndPressPlayAgain() then
                    print("INFO masterLoop: Botão 'Reproduzir' ACIONADO. Encerrando CUL desta rodada.")
                    -- O CUL deve parar sozinho quando a unidade sumir com a transição de fase.
                    roundOver = true 
                end
                wait(CHECK_FOR_VICTORY_SCREEN_INTERVAL)
                if tick() - checkVictoryStartTime > 300 then -- Timeout de 5 minutos para esta fase
                    print("WARN masterLoop: Timeout da fase (5 min). Considerando rodada encerrada.")
                    roundOver = true -- Evita ficar preso indefinidamente se a tela de vitória não aparecer
                end
            end
            
            if coroutine.status(upgradeCoroutine) == "dead" and not roundOver then
                 print("INFO masterLoop: CUL terminou (unidade sumiu?). Verificando tela de vitória final.")
                 if checkForAndPressPlayAgain() then
                     print("INFO masterLoop: Botão 'Reproduzir' ACIONADO após CUL.")
                 else
                     print("INFO masterLoop: Tela de vitória não encontrada após CUL. Esperando...")
                     wait(10) 
                 end
            end
        else 
            print("CRIT masterLoop: Unidade NÃO encontrada após colocação. Tentando novamente em 10s...") 
            wait(10)
            -- continue -- Não precisa mais de continue aqui, o loop while fará a próxima iteração
        end; 
        
        if stopAllLoops then break end -- Sai do master loop se stopAllLoops for true

        print("FARM V0.6 MASTER LOOP: Fim da rodada processada. Aguardando ~7s para transição de jogo...")
        wait(7) -- Espera para o jogo transicionar/carregar após clicar em "Reproduzir"
    end
    print("FARM V0.6 FINAL: MASTER GAME LOOP encerrado.")
end

--====================================================================================
-- EXECUÇÃO INICIAL
--====================================================================================
local s_main,e_main = pcall(masterGameLoop); 
if not s_main then 
    warn("FATAL ERR masterGameLoop(): ", e_main) 
end
print("FARM V0.6 FINAL (via HttpGet): Execução do script (chamada a masterGameLoop) terminada.")
