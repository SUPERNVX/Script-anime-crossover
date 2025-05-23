--[[
    SCRIPT DE FARM (V0.6.1 - LÓGICA DE REINÍCIO CORRIGIDA)
]]

print("FARM V0.6.1 (via HttpGet): Script carregado e iniciando...")
wait(1)

-- CONFIGURAÇÕES (Mesmas da V0.6 FINAL)
local TARGET_CFRAME = CFrame.new(7.1433563232421875, 3.066650629043579, -65.1104507446289)
local UNIT_PLACEMENT_POSITION = Vector3.new(5.92716646194458, 3.0666775703430176, -65.96981048583984)
local UNIT_PLACEMENT_SLOT_NUMBER = 4; local UNIT_INSTANCE_ID_IN_SLOT = "u017003s1"; local UNIT_BASE_ID = "u017003"
local UNIT_TO_FIND_NAME = "U0Model"
local UNITS_FOLDER_PATH_IN_WORKSPACE = "Units.UFolder"
local UPGRADE_PATH_TOP = 1; local UPGRADE_PATH_BOTTOM = 2
local INITIAL_TOP_UPGRADES_COUNT = 2; local INITIAL_BOTTOM_UPGRADES_COUNT = 2   
local DELAY_BETWEEN_UPGRADE_ATTEMPTS = 1.5 
local DELAY_AFTER_PLACEMENT = 3; local CHECK_UNIT_INTERVAL = 2; local MAX_UNIT_FIND_ATTEMPTS = 5          
local REMOTE_PLACE_UNIT_PATH = "RemoteFunctions.PlaceUnitFunctions.PlaceUnit"
local REMOTE_UPGRADE_UNIT_PATH = "RemoteFunctions.UpgradeUnitFunctions.UpgradeUnit"
local REMOTE_SPEED_CHANGE_PATH = "RemoteFunctions.SpeedChange.ChangeSpeedRemoteFunction"
local VICTORY_SCREEN_NAME = "EndOfGameGUI"; local REMOTE_PLAY_AGAIN_PATH = "RemoteEvents.UIRemoteEvents.PostEndGameClient"; local PLAY_AGAIN_ARGUMENT = "replay"
local CHECK_FOR_VICTORY_SCREEN_INTERVAL = 2 -- Verificação mais rápida APÓS o CUL terminar
local MAX_WAIT_FOR_VICTORY_SCREEN = 30 -- Segundos máximos para esperar pela tela de vitória após CUL
print("FARM V0.6.1: Configs carregadas.")

-- SERVIÇOS E VARIÁVEIS GLOBAIS (Mesmas)
local Players=game:GetService("Players"); local Workspace=game:GetService("Workspace"); local ReplicatedStorage=game:GetService("ReplicatedStorage"); local RunService=game:GetService("RunService")
local LocalPlayer=Players.LocalPlayer; if not LocalPlayer then error("FATAL: No LocalPlayer") end; local PlayerGui=LocalPlayer:WaitForChild("PlayerGui"); if not PlayerGui then error("FATAL: No PlayerGui") end
local character,humanoidRootPart,unitsFolderInstance,targetUnitInstance=nil,nil,nil,nil; local stopAllLoops=false
print("FARM V0.6.1: Serviços e globais ok.")

-- FUNÇÕES AUXILIARES (customSplit, getRemote - Mesmas)
local function customSplit(s, sep) if type(s)~="string" or type(sep)~="string" then return {} end; if sep=="" then return {s} end; local r={}; local ci=1; while true do local si,ei=string.find(s,sep,ci,true); if not si then table.insert(r,string.sub(s,ci)); break end; table.insert(r,string.sub(s,ci,si-1)); ci=ei+1; if ci>#s and si then table.insert(r,""); break end end; return r end
local remoteCache={}; local function getRemote(fp) if remoteCache[fp]==false then return nil elseif remoteCache[fp] then return remoteCache[fp] end; print("V0.6.1 getRemote: "..tostring(fp)); if type(fp)~="string" then warn("getRemote: Path non-string"); remoteCache[fp]=false; return nil end; local pp=customSplit(fp,"."); if not pp or #pp==0 then warn("getRemote: customSplit fail"); remoteCache[fp]=false; return nil end; local co=ReplicatedStorage; for _,pn in ipairs(pp) do if co and type(co.FindFirstChild)=="function" then local f=co:FindFirstChild(pn,3); if not f then warn("getRemote: Part NF: "..pn.." in "..co:GetFullName()); remoteCache[fp]=false; return nil end; co=f else warn("getRemote: Invalid CO for "..pn); remoteCache[fp]=false; return nil end end; if co then print("V0.6.1 getRemote: Found: "..co:GetFullName().." ("..co.ClassName..")"); remoteCache[fp]=co else warn("V0.6.1 getRemote: Not Found: "..fp); remoteCache[fp]=false end; return co end

-- FUNÇÕES DE JOGO (Mesmas, resumidas para brevidade)
local function initializePlayerAndCharacter() print("V0.6.1 InitP&C"); character=LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait();if not character then print("ERR:NoC");return false end;humanoidRootPart=character:WaitForChild("HumanoidRootPart",20);if not humanoidRootPart then print("ERR:NoHRP");return false end;print("OK:P&C&HRP init");return true end
local function executeTeleport() print("V0.6.1 TP");if not humanoidRootPart then print("ERR:HRPnilTP");return false end;local s,e=pcall(function()humanoidRootPart.CFrame=TARGET_CFRAME end);if s then print("OK:TPsent.Pos:"..tostring(humanoidRootPart.Position));return true else print("ERR:TPfail:"..tostring(e));return false end end
local function findUnitsFolder() print("V0.6.1 FindUF");local p=customSplit(UNITS_FOLDER_PATH_IN_WORKSPACE,".");local c=Workspace;for _,n in ipairs(p)do if c and type(c.WaitForChild)=="function"then c=c:WaitForChild(n,10);if not c then print("ERR:UFpart'"..n.."'NF");return false end else print("ERR:InvalidObjUF");return false end end;unitsFolderInstance=c;if unitsFolderInstance then print("OK:UF:"..unitsFolderInstance:GetFullName());return true else print("ERR:UF NF");return false end end
local function setGameSpeedTo2X() print("V0.6.1 setGameSpeed");local r=getRemote(REMOTE_SPEED_CHANGE_PATH);if not r or type(r.InvokeServer)~="function"then warn("Speed:RemoteInvalid");return end;local s,e=pcall(function()r:InvokeServer()end);if s then print("Speed:CmdSent")else warn("Speed:Fail:"..tostring(e))end;wait(0.5)end
local function placeUnitOnMap() print("V0.6.1 placeUnit");local r=getRemote(REMOTE_PLACE_UNIT_PATH);if not r or type(r.InvokeServer)~="function"then warn("PlaceU:RemoteInvalid");return false end;print("PlaceU:Slot"..UNIT_PLACEMENT_SLOT_NUMBER);local a={[1]=UNIT_PLACEMENT_SLOT_NUMBER,[2]=UNIT_INSTANCE_ID_IN_SLOT,[3]=UNIT_BASE_ID,[4]=UNIT_PLACEMENT_POSITION};local s,e=pcall(function()r:InvokeServer(unpack(a))end);if s then print("PlaceU:CmdSent.Wait"..DELAY_AFTER_PLACEMENT.."s");wait(DELAY_AFTER_PLACEMENT);return true else warn("PlaceU:Fail:"..tostring(e));return false end end
local function findOrWaitForUnit() print("V0.6.1 findUnit:'"..UNIT_TO_FIND_NAME.."'");if not unitsFolderInstance then print("ERR:UFnil");return false end;for att=1,MAX_UNIT_FIND_ATTEMPTS do targetUnitInstance=unitsFolderInstance:FindFirstChild(UNIT_TO_FIND_NAME);if targetUnitInstance and targetUnitInstance:IsA("Model")then print("OK:Unit'"..UNIT_TO_FIND_NAME.."'found:"..targetUnitInstance:GetFullName());return true else if targetUnitInstance then print("WARN:Obj'"..UNIT_TO_FIND_NAME.."'foundNotModel:"..targetUnitInstance.ClassName)else print("INFO:Unit'"..UNIT_TO_FIND_NAME.."'NF.Att"..att)end end;if att<MAX_UNIT_FIND_ATTEMPTS then wait(CHECK_UNIT_INTERVAL)end end;print("ERR:Unit'"..UNIT_TO_FIND_NAME.."'NOTfound");targetUnitInstance=nil;return false end
local upgradeUnitRemoteFunc=nil;local function performSingleUpgrade(uM,uP)if not upgradeUnitRemoteFunc then print("V0.6.1PSU:GetRemote");upgradeUnitRemoteFunc=getRemote(REMOTE_UPGRADE_UNIT_PATH);if not upgradeUnitRemoteFunc or type(upgradeUnitRemoteFunc.InvokeServer)~="function"then warn("PSU:InvalidRemote");upgradeUnitRemoteFunc=nil;return false end;print("V0.6.1PSU:RemoteCached")end;if not upgradeUnitRemoteFunc then return false end;print("V0.6.1PSU:Upg"..uM.Name..",P"..uP);local s,r=pcall(function()return upgradeUnitRemoteFunc:InvokeServer(uM,uP)end);if s then if r==false then print("V0.6.1PSU:UPG_NEGADO_SV "..uM.Name..",P"..uP);return false end;print("V0.6.1PSU:UPG_SUCESSO "..uM.Name..",P"..uP..".Res:"..tostring(r));return true else warn("V0.6.1PSU:ERR_InvokeServer:"..tostring(r));return false end end
local function continuousUpgradeLoop() if not targetUnitInstance then print("ERR:NoUnitCUL");return end;print("V0.6.1CUL:StartingFor"..targetUnitInstance.Name);local tU,bU,iPC,cUT,iter=0,0,false,false,0;while not stopAllLoops and targetUnitInstance and targetUnitInstance.Parent do iter=iter+1;print("---V0.6.1CUL:Loop#"..iter.."---");local uTC=false;if not iPC then if tU<INITIAL_TOP_UPGRADES_COUNT then if performSingleUpgrade(targetUnitInstance,UPGRADE_PATH_TOP)then tU=tU+1;uTC=true end elseif bU<INITIAL_BOTTOM_UPGRADES_COUNT then if performSingleUpgrade(targetUnitInstance,UPGRADE_PATH_BOTTOM)then bU=bU+1;uTC=true end else iPC=true;cUT=true;print("V0.6.1CUL:InitialPhaseDONE.ContinuousTOP")end end;if cUT then if performSingleUpgrade(targetUnitInstance,UPGRADE_PATH_TOP)then uTC=true end end;wait(DELAY_BETWEEN_UPGRADE_ATTEMPTS)end;if stopAllLoops then print("V0.6.1CUL:LoopStopped(cmd)")elseif not(targetUnitInstance and targetUnitInstance.Parent)then print("V0.6.1CUL:LoopStopped(unitGone)")else print("V0.6.1CUL:LoopNaturallyEnded")end;print("V0.6.1CUL:ENDED for "..targetUnitInstance.Name)end

-- FUNÇÃO DE REINÍCIO DE FASE (Mesma da V0.6)
local function checkForAndPressPlayAgain() print("V0.6.1 checkPlayAgain:'"..VICTORY_SCREEN_NAME.."'...");local vS=PlayerGui:FindFirstChild(VICTORY_SCREEN_NAME,true);if vS and vS.Enabled then print("V0.6.1 checkPlayAgain:VS('"..VICTORY_SCREEN_NAME.."')detected!");local pAR=getRemote(REMOTE_PLAY_AGAIN_PATH);if pAR then if pAR:IsA("RemoteEvent")then print("V0.6.1 checkPlayAgain:RE'"..REMOTE_PLAY_AGAIN_PATH.."'found.Firing arg:'"..PLAY_AGAIN_ARGUMENT.."'");local s,e=pcall(function()pAR:FireServer(PLAY_AGAIN_ARGUMENT)end);if s then print("V0.6.1 checkPlayAgain:REfired!");return true else warn("V0.6.1 checkPlayAgain:ERRfireRE:"..tostring(e));return false end else warn("V0.6.1 checkPlayAgain:ObjAt'"..REMOTE_PLAY_AGAIN_PATH.."'not RE.Is:"..pAR.ClassName);return false end else warn("V0.6.1 checkPlayAgain:RemotePlayAgain('"..REMOTE_PLAY_AGAIN_PATH.."')NF.");return false end else return false end end

--====================================================================================
-- LOOP DE JOGO PRINCIPAL (MASTER LOOP - LÓGICA CORRIGIDA)
--====================================================================================
local function masterGameLoop()
    print("FARM V0.6.1: Iniciando MASTER GAME LOOP...")
    stopAllLoops = false 

    while not stopAllLoops do
        print("===== FARM V0.6.1 MASTER LOOP: INICIANDO NOVA RODADA =====")
        targetUnitInstance = nil 
        remoteCache = {} 
        
        if not initializePlayerAndCharacter() then print("CRIT MLoop: P init fail. Stop."); stopAllLoops=true; break end
        if not executeTeleport() then print("CRIT MLoop: TP fail. Stop."); stopAllLoops=true; break end
        
        setGameSpeedTo2X() 
        
        if not placeUnitOnMap() then print("CRIT MLoop: Place unit fail. Tentando nova rodada em 10s..."); wait(10); continue end
        
        wait(1); 
        if not findUnitsFolder() then print("CRIT MLoop: UF fail. Tentando nova rodada em 10s..."); wait(10); continue end
        
        if findOrWaitForUnit() then 
            print("INFO MLoop: Unidade colocada e encontrada, iniciando CUL..."); 
            
            local upgradeCoroutine = coroutine.create(continuousUpgradeLoop)
            local co_success, co_error = coroutine.resume(upgradeCoroutine)
            if not co_success then 
                warn("ERRO AO INICIAR CORROTINA DE UPGRADE:", co_error)
                print("CRIT MLoop: Falha ao iniciar CUL. Tentando nova rodada em 10s...")
                wait(10)
                continue -- Pula para a próxima rodada
            end
            print("INFO MLoop: CUL (corrotina de upgrade) iniciado/resumido.")

            -- AGUARDA A CORROTINA DE UPGRADE TERMINAR
            while coroutine.status(upgradeCoroutine) ~= "dead" and not stopAllLoops do
                wait(1) -- Verifica a cada segundo se a corrotina terminou
            end

            if stopAllLoops then print("INFO MLoop: stopAllLoops ativado, saindo da espera do CUL."); break end 
            
            print("INFO MLoop: CUL terminou (status: " .. coroutine.status(upgradeCoroutine) .. "). Iniciando verificação da tela de vitória.")
            
            -- AGORA, APÓS O CUL TERMINAR, VERIFICA A TELA DE VITÓRIA
            local victoryScreenPressed = false
            local waitStartTime = tick()
            while not victoryScreenPressed and not stopAllLoops and (tick() - waitStartTime < MAX_WAIT_FOR_VICTORY_SCREEN) do
                if checkForAndPressPlayAgain() then
                    print("INFO MLoop: Botão 'Reproduzir' ACIONADO.")
                    victoryScreenPressed = true 
                else
                    print("INFO MLoop: Tela de vitória ainda não detectada ou botão não pressionado. Esperando...")
                end
                wait(CHECK_FOR_VICTORY_SCREEN_INTERVAL)
            end

            if not victoryScreenPressed and not stopAllLoops then
                print("WARN MLoop: Timeout esperando tela de vitória ou botão não foi pressionado. Tentando nova rodada de qualquer maneira...")
            elseif stopAllLoops then
                 print("INFO MLoop: stopAllLoops ativado durante espera da tela de vitória.")
                 break
            end
        else 
            print("CRIT MLoop: Unidade NÃO encontrada após colocação. Tentando nova rodada em 10s...") 
            wait(10)
            -- continue -- O loop while fará a próxima iteração
        end; 
        
        if stopAllLoops then break end

        print("FARM V0.6.1 MASTER LOOP: Fim da rodada processada. Aguardando ~7s para transição...")
        wait(7) 
    end
    print("FARM V0.6.1 FINAL: MASTER GAME LOOP encerrado.")
end

-- EXECUÇÃO INICIAL
local s_main,e_main = pcall(masterGameLoop); if not s_main then warn("FATAL ERR masterGameLoop(): ",e_main) end
print("FARM V0.6.1 (via HttpGet): Execução (chamada a masterGameLoop) terminada.")
