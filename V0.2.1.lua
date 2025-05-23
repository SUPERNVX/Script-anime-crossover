--[[
    SCRIPT DE FARM (V0.8.4 - DEBUG INTENSIVO DO LOGSERVICE LISTENER)
]]

print("FARM V0.8.4 (via HttpGet): Script carregado e iniciando...")
wait(1)

-- CONFIGURAÇÕES (Mesmas)
local TARGET_CFRAME = CFrame.new(7.1433563232421875, 3.066650629043579, -65.1104507446289); local UNIT_PLACEMENT_POSITION = Vector3.new(5.92716646194458, 3.0666775703430176, -65.96981048583984); local UNIT_PLACEMENT_SLOT_NUMBER = 4; local UNIT_INSTANCE_ID_IN_SLOT = "u017003s1"; local UNIT_BASE_ID = "u017003"; local UNIT_TO_FIND_NAME = "U0Model"; local UNITS_FOLDER_PATH_IN_WORKSPACE = "Units.UFolder"; local UPGRADE_PATH_TOP = 1; local UPGRADE_PATH_BOTTOM = 2; local INITIAL_TOP_UPGRADES_COUNT = 2; local INITIAL_BOTTOM_UPGRADES_COUNT = 2; local DELAY_BETWEEN_UPGRADE_ATTEMPTS = 1.0; local DELAY_AFTER_PLACEMENT = 3; local CHECK_UNIT_INTERVAL = 2; local MAX_UNIT_FIND_ATTEMPTS = 5; local REMOTE_PLACE_UNIT_PATH = "RemoteFunctions.PlaceUnitFunctions.PlaceUnit"; local REMOTE_UPGRADE_UNIT_PATH = "RemoteFunctions.UpgradeUnitFunctions.UpgradeUnit"; local REMOTE_SPEED_CHANGE_PATH = "RemoteFunctions.SpeedChange.ChangeSpeedRemoteFunction"; local VICTORY_SCREEN_NAME = "EndOfGameGUI"; local REMOTE_PLAY_AGAIN_PATH = "RemoteEvents.UIRemoteEvents.PostEndGameClient"; local PLAY_AGAIN_ARGUMENT = "replay"; local CHECK_FOR_VICTORY_SCREEN_INTERVAL = 1; local MAX_WAIT_FOR_VICTORY_SCREEN = 30; 
local CONSOLE_MESSAGE_FOR_RESTART = "rewards collected:"
local CONSOLE_MESSAGE_FOR_RESTART_LOWER = string.lower(CONSOLE_MESSAGE_FOR_RESTART) -- Pré-calcula a versão minúscula
print("FARM V0.8.4: Configs. Trigger: '"..CONSOLE_MESSAGE_FOR_RESTART.."'")

-- SERVIÇOS E VARIÁVEIS GLOBAIS (Mesmas)
local Players=game:GetService("Players"); local Workspace=game:GetService("Workspace"); local ReplicatedStorage=game:GetService("ReplicatedStorage"); local LogService=game:GetService("LogService")
local LocalPlayer=Players.LocalPlayer; if not LocalPlayer then error("FATAL: No LocalPlayer") end; local PlayerGui=LocalPlayer:WaitForChild("PlayerGui"); if not PlayerGui then error("FATAL: No PlayerGui") end
local character,humanoidRootPart,unitsFolderInstance,targetUnitInstance=nil,nil,nil,nil; 
local stopAllLoops = false; local roundOverEvent = Instance.new("BindableEvent")
print("FARM V0.8.4: Serviços e globais ok.")

-- FUNÇÕES AUXILIARES E DE JOGO (Mesmas da V0.8.3 - super resumidas aqui, use as completas no seu script)
local function customSplit(s, sep) if type(s)~="string" or type(sep)~="string" then return {} end; if sep=="" then return {s} end; local r={}; local ci=1; while true do local si,ei=string.find(s,sep,ci,true); if not si then table.insert(r,string.sub(s,ci)); break end; table.insert(r,string.sub(s,ci,si-1)); ci=ei+1; if ci>#s and si then table.insert(r,""); break end end; return r end
local remoteCache={}; local function getRemote(fp) if remoteCache[fp]==false then return nil elseif remoteCache[fp] then return remoteCache[fp] end; if type(fp)~="string"then remoteCache[fp]=false;return nil end;local pp=customSplit(fp,".");if not pp or #pp==0 then remoteCache[fp]=false;return nil end;local co=ReplicatedStorage;for _,pn in ipairs(pp)do if co and type(co.FindFirstChild)=="function"then local f=co:FindFirstChild(pn,3);if not f then remoteCache[fp]=false;return nil end;co=f else remoteCache[fp]=false;return nil end end;if co then remoteCache[fp]=co else remoteCache[fp]=false end;return co end
local function initializePlayerAndCharacter() character=LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait();if not character then return false end;humanoidRootPart=character:WaitForChild("HumanoidRootPart",20);if not humanoidRootPart then return false end;return true end
local function executeTeleport() if not humanoidRootPart then return false end;local s,e=pcall(function()humanoidRootPart.CFrame=TARGET_CFRAME end);return s end
local function findUnitsFolder() local p=customSplit(UNITS_FOLDER_PATH_IN_WORKSPACE,".");local c=Workspace;for _,n in ipairs(p)do if c and type(c.WaitForChild)=="function"then c=c:WaitForChild(n,10);if not c then return false end else return false end end;unitsFolderInstance=c;return true end
local function setGameSpeedTo2X() local r=getRemote(REMOTE_SPEED_CHANGE_PATH);if not r or type(r.InvokeServer)~="function"then return end;pcall(function()r:InvokeServer()end);wait(0.5)end
local function placeUnitOnMap() local r=getRemote(REMOTE_PLACE_UNIT_PATH);if not r or type(r.InvokeServer)~="function"then return false end;local a={[1]=UNIT_PLACEMENT_SLOT_NUMBER,[2]=UNIT_INSTANCE_ID_IN_SLOT,[3]=UNIT_BASE_ID,[4]=UNIT_PLACEMENT_POSITION};local s,e=pcall(function()r:InvokeServer(unpack(a))end);if s then wait(DELAY_AFTER_PLACEMENT);return true else return false end end
local function findOrWaitForUnit() if not unitsFolderInstance then return false end;for att=1,MAX_UNIT_FIND_ATTEMPTS do targetUnitInstance=unitsFolderInstance:FindFirstChild(UNIT_TO_FIND_NAME);if targetUnitInstance and targetUnitInstance:IsA("Model")then return true end;if att<MAX_UNIT_FIND_ATTEMPTS then wait(CHECK_UNIT_INTERVAL)end end;targetUnitInstance=nil;return false end
local upgradeUnitRemoteFunc=nil;local function performSingleUpgrade(uM,uP)if not upgradeUnitRemoteFunc then upgradeUnitRemoteFunc=getRemote(REMOTE_UPGRADE_UNIT_PATH);if not upgradeUnitRemoteFunc or type(upgradeUnitRemoteFunc.InvokeServer)~="function"then upgradeUnitRemoteFunc=nil;return false end end;if not upgradeUnitRemoteFunc then return false end;local s,r=pcall(function()return upgradeUnitRemoteFunc:InvokeServer(uM,uP)end);if s then if r==false then return false end;return true else return false end end
local function continuousUpgradeLoop() if not targetUnitInstance then return end;print("V0.8.4CUL:Start "..targetUnitInstance.Name);local tU,bU,iPC,cUT,iter,cTF=0,0,false,false,0,0;while not stopAllLoops and targetUnitInstance and targetUnitInstance.Parent do iter=iter+1;if not iPC then if tU<INITIAL_TOP_UPGRADES_COUNT then if performSingleUpgrade(targetUnitInstance,UPGRADE_PATH_TOP)then tU=tU+1;cTF=0 end elseif bU<INITIAL_BOTTOM_UPGRADES_COUNT then if performSingleUpgrade(targetUnitInstance,UPGRADE_PATH_BOTTOM)then bU=bU+1 end else iPC=true;cUT=true;cTF=0 end end;if cUT then if performSingleUpgrade(targetUnitInstance,UPGRADE_PATH_TOP)then cTF=0 else cTF=cTF+1;if cTF>=MAX_FAILS_CONTINUOUS_LOG_THRESHOLD and cTF%MAX_FAILS_CONTINUOUS_LOG_THRESHOLD==0 then print("V0.8.4CUL:WARN-"..cTF.."failsContTOP")end end end;wait(DELAY_BETWEEN_UPGRADE_ATTEMPTS)end;print("V0.8.4CUL:ENDED ".. (targetUnitInstance and targetUnitInstance.Name or "N/A")) end
local function checkForAndPressPlayAgain() print("V0.8.4 CPA:'"..VICTORY_SCREEN_NAME.."'");local vS=PlayerGui:FindFirstChild(VICTORY_SCREEN_NAME,true);if vS and vS.Enabled then local rPAV=vS:FindFirstChild("ReproduceButton",true);if not rPAV or not rPAV.Visible then return false end;local pAR=getRemote(REMOTE_PLAY_AGAIN_PATH);if pAR and pAR:IsA("RemoteEvent")then local s,e=pcall(function()pAR:FireServer(PLAY_AGAIN_ARGUMENT)end);return s else return false end else return false end end

--====================================================================================
-- MONITORAMENTO DO LOGSERVICE (DEBUG INTENSIVO)
--====================================================================================
local messageOutConnection = nil
local logMonitorShouldBeActive = false 
local hasFiredRoundOverSignalThisRound = false 

local function listenForRewardsMessage()
    if logMonitorShouldBeActive then 
        print("V0.8.4 LogListen: Monitoramento já deveria estar ativo ou será reativado.")
    end
    logMonitorShouldBeActive = true -- Garante que está ativo para a nova rodada
    hasFiredRoundOverSignalThisRound = false 
    
    if messageOutConnection and messageOutConnection.Connected then
        print("V0.8.4 LogListen: Desconectando listener antigo.")
        messageOutConnection:Disconnect()
    end

    print("V0.8.4 LogListen: CONECTANDO a LogService.MessageOut...")
    messageOutConnection = LogService.MessageOut:Connect(function(message, messageType)
        -- Log para TODAS as mensagens recebidas pelo LogService (cuidado com spam)
        print(string.format("LogService MSG [%s]: %s", tostring(messageType), message))

        if not logMonitorShouldBeActive then 
            -- print("V0.8.4 LogListen: Recebeu msg, mas monitor não está ativo. Ignorando.")
            return 
        end
        
        local lowerMessage = string.lower(message)
        if string.find(lowerMessage, CONSOLE_MESSAGE_FOR_RESTART_LOWER, 1, true) then
            print("V0.8.4 LogListen: !!! MENSAGEM CHAVE ENCONTRADA ('"..CONSOLE_MESSAGE_FOR_RESTART.."') !!!")
            print("V0.8.4 LogListen: Mensagem original: '"..message.."'")
            print("V0.8.4 LogListen: Mensagem em minúsculas: '"..lowerMessage.."'")
            
            if not hasFiredRoundOverSignalThisRound then
                print("V0.8.4 LogListen: Disparando roundOverEvent e DESATIVANDO listener para esta rodada.")
                hasFiredRoundOverSignalThisRound = true 
                logMonitorShouldBeActive = false -- Impede disparos múltiplos
                
                if messageOutConnection and messageOutConnection.Connected then
                    print("V0.8.4 LogListen: Desconectando listener LogService.MessageOut.")
                    messageOutConnection:Disconnect()
                    messageOutConnection = nil 
                end
                roundOverEvent:Fire() 
            else
                print("V0.8.4 LogListen: Mensagem chave detectada, MAS SINAL JÁ FOI DISPARADO para esta rodada.")
            end
        end
    end)
    if messageOutConnection and messageOutConnection.Connected then
         print("V0.8.4 LogListen: Conexão LogService.MessageOut SUCESSO.")
    else
         print("V0.8.4 LogListen: FALHA ao conectar LogService.MessageOut.")
    end
end

--====================================================================================
-- LOOP DE JOGO PRINCIPAL (MASTER LOOP - SEM MUDANÇAS SIGNIFICATIVAS, FOCO NO LISTENER)
--====================================================================================
local function masterGameLoop()
    print("FARM V0.8.4: MGL Init...")
    stopAllLoops = false 
    while not stopAllLoops do
        print("=====FARM V0.8.4 MGL: NEW ROUND=====")
        targetUnitInstance=nil; remoteCache={}; 
        local roundDeclaredOverByLog = false 
        
        listenForRewardsMessage() -- Ativa o listener para a nova rodada

        if not initializePlayerAndCharacter() then print("CRIT MGL:PInitFail.Stop."); stopAllLoops=true; break end
        if not executeTeleport() then print("CRIT MGL:TPFail.Stop."); stopAllLoops=true; break end
        setGameSpeedTo2X() 
        if not placeUnitOnMap() then print("CRIT MGL:PlaceFail.NewRound10s"); if messageOutConnection then messageOutConnection:Disconnect() end; logMonitorShouldBeActive=false; wait(10); continue end
        wait(1); 
        if not findUnitsFolder() then print("CRIT MGL:UFFail.NewRound10s"); if messageOutConnection then messageOutConnection:Disconnect() end; logMonitorShouldBeActive=false; wait(10); continue end
        
        if findOrWaitForUnit() then 
            print("INFO MGL:UnitFound,starting CUL...");
            local upgradeCoroutine = coroutine.create(continuousUpgradeLoop)
            coroutine.resume(upgradeCoroutine)
            print("INFO MGL:CULstarted.")

            print("INFO MGL: Aguardando sinal de 'rewards collected' (roundOverEvent)...")
            local signalFired = false
            local pcall_wait_ok, pcall_wait_val = pcall(function()
                roundOverEvent.Event:Wait() 
                signalFired = true
            end)

            if not pcall_wait_ok then print("WARN MGL: Erro Event:Wait(): " .. tostring(pcall_wait_val)) end
            
            if signalFired then print("INFO MGL: roundOverEvent RECEBIDO!") else print("WARN MGL: Saída Event:Wait() sem sinal.") end
            
            logMonitorShouldBeActive = false; if messageOutConnection then messageOutConnection:Disconnect(); messageOutConnection = nil; end

            print("INFO MGL: Sinalizando CUL para parar (se ativo)...")
            stopAllLoops = true; local c=0; while coroutine.status(upgradeCoroutine)~="dead" and c<5 do wait(0.2); c=c+1 end; stopAllLoops = false;
            
            print("INFO MGL: Verificando tela de vitória...")
            local victoryScreenPressed = false; local waitStartTime = tick()
            while not victoryScreenPressed and not stopAllLoops and (tick() - waitStartTime < MAX_WAIT_FOR_VICTORY_SCREEN) do
                if checkForAndPressPlayAgain() then print("INFO MGL:'Reproduzir'PRESSED."); victoryScreenPressed=true 
                else print("INFO MGL:Tela vitória NF/botão NP.Wait...") end
                wait(CHECK_FOR_VICTORY_SCREEN_INTERVAL)
            end
            if not victoryScreenPressed and not stopAllLoops then print("WARN MGL:TimeoutVS.") elseif stopAllLoops then print("INFO MGL:stopAllLoops duringVSwait.");break end
        else 
            print("CRIT MGL:UnitNOTfound.NewRound10s"); if messageOutConnection then messageOutConnection:Disconnect() end; logMonitorShouldBeActive=false; wait(10); 
        end; 
        
        if stopAllLoops then print("INFO MGL: stopAllLoops, quebrando MGL."); break end
        print("FARM V0.8.4 MGL:EndOfRound.Wait~7s")
        wait(7) 
    end
    if messageOutConnection and messageOutConnection.Connected then messageOutConnection:Disconnect() end; logMonitorShouldBeActive=false;
    print("FARM V0.8.4 FINAL:MGLended.")
end

local s_main,e_main=pcall(masterGameLoop);if not s_main then warn("FATAL ERR MGL():",e_main)end
print("FARM V0.8.4(via HttpGet):ExecTerminated.")
