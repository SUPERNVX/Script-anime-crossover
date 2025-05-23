--[[
    SCRIPT DE FARM (V0.8.2 - DEBUG ULTRA FOCADO NO REINÍCIO)
]]

print("FARM V0.8.2 (via HttpGet): Script carregado e iniciando...")
wait(1)

-- CONFIGURAÇÕES (Mesmas da V0.8.1)
local TARGET_CFRAME = CFrame.new(7.1433563232421875, 3.066650629043579, -65.1104507446289)
local UNIT_PLACEMENT_POSITION = Vector3.new(5.92716646194458, 3.0666775703430176, -65.96981048583984)
local UNIT_PLACEMENT_SLOT_NUMBER = 4; local UNIT_INSTANCE_ID_IN_SLOT = "u017003s1"; local UNIT_BASE_ID = "u017003"
local UNIT_TO_FIND_NAME = "U0Model"
local UNITS_FOLDER_PATH_IN_WORKSPACE = "Units.UFolder"
local UPGRADE_PATH_TOP = 1; local UPGRADE_PATH_BOTTOM = 2
local INITIAL_TOP_UPGRADES_COUNT = 2; local INITIAL_BOTTOM_UPGRADES_COUNT = 2   
local DELAY_BETWEEN_UPGRADE_ATTEMPTS = 1.0 
local DELAY_AFTER_PLACEMENT = 3; local CHECK_UNIT_INTERVAL = 2; local MAX_UNIT_FIND_ATTEMPTS = 5          
local REMOTE_PLACE_UNIT_PATH = "RemoteFunctions.PlaceUnitFunctions.PlaceUnit"
local REMOTE_UPGRADE_UNIT_PATH = "RemoteFunctions.UpgradeUnitFunctions.UpgradeUnit"
local REMOTE_SPEED_CHANGE_PATH = "RemoteFunctions.SpeedChange.ChangeSpeedRemoteFunction"
local VICTORY_SCREEN_NAME = "EndOfGameGUI"; local REMOTE_PLAY_AGAIN_PATH = "RemoteEvents.UIRemoteEvents.PostEndGameClient"; local PLAY_AGAIN_ARGUMENT = "replay"
local CHECK_FOR_VICTORY_SCREEN_INTERVAL = 1 -- Verificação mais rápida da tela de vitória
local MAX_WAIT_FOR_VICTORY_SCREEN = 30 
local CONSOLE_MESSAGE_FOR_RESTART = "rewards collected:" 
local MAX_FAILS_CONTINUOUS_LOG_THRESHOLD = 5
print("FARM V0.8.2: Configs. Trigger: '"..CONSOLE_MESSAGE_FOR_RESTART.."'")

-- SERVIÇOS E VARIÁVEIS GLOBAIS (Mesmas)
local Players=game:GetService("Players"); local Workspace=game:GetService("Workspace"); local ReplicatedStorage=game:GetService("ReplicatedStorage"); local RunService=game:GetService("RunService"); local LogService=game:GetService("LogService")
local LocalPlayer=Players.LocalPlayer; if not LocalPlayer then error("FATAL: No LocalPlayer") end; local PlayerGui=LocalPlayer:WaitForChild("PlayerGui"); if not PlayerGui then error("FATAL: No PlayerGui") end
local character,humanoidRootPart,unitsFolderInstance,targetUnitInstance=nil,nil,nil,nil; 
local stopAllLoops = false; local roundOverSignal = Instance.new("BindableEvent")
print("FARM V0.8.2: Serviços e globais ok.")

-- FUNÇÕES AUXILIARES (Mesmas)
local function customSplit(s, sep) if type(s)~="string" or type(sep)~="string" then return {} end; if sep=="" then return {s} end; local r={}; local ci=1; while true do local si,ei=string.find(s,sep,ci,true); if not si then table.insert(r,string.sub(s,ci)); break end; table.insert(r,string.sub(s,ci,si-1)); ci=ei+1; if ci>#s and si then table.insert(r,""); break end end; return r end
local remoteCache={}; local function getRemote(fp) if remoteCache[fp]==false then return nil elseif remoteCache[fp] then return remoteCache[fp] end; if type(fp)~="string" then warn("getRemote:Path non-string"); remoteCache[fp]=false; return nil end; local pp=customSplit(fp,"."); if not pp or #pp==0 then warn("getRemote:customSplit fail"); remoteCache[fp]=false; return nil end; local co=ReplicatedStorage; for _,pn in ipairs(pp) do if co and type(co.FindFirstChild)=="function" then local f=co:FindFirstChild(pn,3); if not f then warn("getRemote:Part NF: "..pn.." in "..co:GetFullName()); remoteCache[fp]=false; return nil end; co=f else warn("getRemote:Invalid CO for "..pn); remoteCache[fp]=false; return nil end end; if co then remoteCache[fp]=co else warn("V0.8.2 getRemote:NotFound:"..fp); remoteCache[fp]=false end; return co end

-- FUNÇÕES DE JOGO (Mesmas, resumidas)
local function initializePlayerAndCharacter() print("V0.8.2 InitP&C"); character=LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait();if not character then print("ERR:NoC");return false end;humanoidRootPart=character:WaitForChild("HumanoidRootPart",20);if not humanoidRootPart then print("ERR:NoHRP");return false end;print("OK:P&C&HRP init");return true end
local function executeTeleport() print("V0.8.2 TP");if not humanoidRootPart then print("ERR:HRPnilTP");return false end;local s,e=pcall(function()humanoidRootPart.CFrame=TARGET_CFRAME end);if s then print("OK:TPsent.Pos:"..tostring(humanoidRootPart.Position));return true else print("ERR:TPfail:"..tostring(e));return false end end
local function findUnitsFolder() print("V0.8.2 FindUF");local p=customSplit(UNITS_FOLDER_PATH_IN_WORKSPACE,".");local c=Workspace;for _,n in ipairs(p)do if c and type(c.WaitForChild)=="function"then c=c:WaitForChild(n,10);if not c then print("ERR:UFpart'"..n.."'NF");return false end else print("ERR:InvalidObjUF");return false end end;unitsFolderInstance=c;if unitsFolderInstance then print("OK:UF:"..unitsFolderInstance:GetFullName());return true else print("ERR:UF NF");return false end end
local function setGameSpeedTo2X() print("V0.8.2 setGameSpeed");local r=getRemote(REMOTE_SPEED_CHANGE_PATH);if not r or type(r.InvokeServer)~="function"then warn("Speed:RemoteInvalid");return end;local s,e=pcall(function()r:InvokeServer()end);if s then print("Speed:CmdSent")else warn("Speed:Fail:"..tostring(e))end;wait(0.5)end
local function placeUnitOnMap() print("V0.8.2 placeUnit");local r=getRemote(REMOTE_PLACE_UNIT_PATH);if not r or type(r.InvokeServer)~="function"then warn("PlaceU:RemoteInvalid");return false end;print("PlaceU:Slot"..UNIT_PLACEMENT_SLOT_NUMBER);local a={[1]=UNIT_PLACEMENT_SLOT_NUMBER,[2]=UNIT_INSTANCE_ID_IN_SLOT,[3]=UNIT_BASE_ID,[4]=UNIT_PLACEMENT_POSITION};local s,e=pcall(function()r:InvokeServer(unpack(a))end);if s then print("PlaceU:CmdSent.Wait"..DELAY_AFTER_PLACEMENT.."s");wait(DELAY_AFTER_PLACEMENT);return true else warn("PlaceU:Fail:"..tostring(e));return false end end
local function findOrWaitForUnit() print("V0.8.2 findUnit:'"..UNIT_TO_FIND_NAME.."'");if not unitsFolderInstance then print("ERR:UFnil");return false end;for att=1,MAX_UNIT_FIND_ATTEMPTS do targetUnitInstance=unitsFolderInstance:FindFirstChild(UNIT_TO_FIND_NAME);if targetUnitInstance and targetUnitInstance:IsA("Model")then print("OK:Unit'"..UNIT_TO_FIND_NAME.."'found:"..targetUnitInstance:GetFullName());return true else if targetUnitInstance then print("WARN:Obj'"..UNIT_TO_FIND_NAME.."'foundNotModel:"..targetUnitInstance.ClassName)else print("INFO:Unit'"..UNIT_TO_FIND_NAME.."'NF.Att"..att)end end;if att<MAX_UNIT_FIND_ATTEMPTS then wait(CHECK_UNIT_INTERVAL)end end;print("ERR:Unit'"..UNIT_TO_FIND_NAME.."'NOTfound");targetUnitInstance=nil;return false end
local upgradeUnitRemoteFunc=nil;local function performSingleUpgrade(uM,uP)if not upgradeUnitRemoteFunc then print("V0.8.2PSU:GetRemote");upgradeUnitRemoteFunc=getRemote(REMOTE_UPGRADE_UNIT_PATH);if not upgradeUnitRemoteFunc or type(upgradeUnitRemoteFunc.InvokeServer)~="function"then warn("PSU:InvalidRemote");upgradeUnitRemoteFunc=nil;return false end;print("V0.8.2PSU:RemoteCached")end;if not upgradeUnitRemoteFunc then return false end;print("V0.8.2PSU:Upg "..uM.Name..",P"..uP);local s,r=pcall(function()return upgradeUnitRemoteFunc:InvokeServer(uM,uP)end);if s then if r==false then print("V0.8.2PSU:UPG_NEGADO_SV "..uM.Name..",P"..uP);return false end;print("V0.8.2PSU:UPG_SUCESSO "..uM.Name..",P"..uP..".Res:"..tostring(r));return true else warn("V0.8.2PSU:ERR_InvokeServer:"..tostring(r));return false end end
local function continuousUpgradeLoop() if not targetUnitInstance then print("ERR:NoUnitCUL");return end;print("V0.8.2CUL:StartingFor "..targetUnitInstance.Name);local tU,bU,iPC,cUT,iter=0,0,false,false,0;local cTF=0;while not stopAllLoops and targetUnitInstance and targetUnitInstance.Parent do iter=iter+1;print("---V0.8.2CUL:Loop#"..iter.." ---");local uTC=false;if not iPC then if tU<INITIAL_TOP_UPGRADES_COUNT then if performSingleUpgrade(targetUnitInstance,UPGRADE_PATH_TOP)then tU=tU+1;uTC=true;cTF=0 end elseif bU<INITIAL_BOTTOM_UPGRADES_COUNT then if performSingleUpgrade(targetUnitInstance,UPGRADE_PATH_BOTTOM)then bU=bU+1;uTC=true end else iPC=true;cUT=true;print("V0.8.2CUL:InitialPhaseDONE.ContinuousTOP");cTF=0 end end;if cUT then if performSingleUpgrade(targetUnitInstance,UPGRADE_PATH_TOP)then uTC=true;cTF=0 else cTF=cTF+1;print("V0.8.2CUL:FailContTOP.Fails:"..cTF);if cTF>=MAX_FAILS_CONTINUOUS_LOG_THRESHOLD and cTF%MAX_FAILS_CONTINUOUS_LOG_THRESHOLD==0 then print("V0.8.2CUL:WARN-"..cTF.."failsContTOP")end end end;wait(DELAY_BETWEEN_UPGRADE_ATTEMPTS)end;print("V0.8.2CUL:ENDED for "..(targetUnitInstance and targetUnitInstance.Name or "UnitN/A").." (Reason: stop="..tostring(stopAllLoops).." or unit/parent nil)")end

--====================================================================================
-- MONITORAMENTO DO LOGSERVICE (COM MAIS DEBUG)
--====================================================================================
local messageOutConnection = nil
local logMonitorActive = false
local hasFiredRoundOverSignalThisRound = false -- NOVA FLAG

local function startLogMonitoring()
    if logMonitorActive then print("V0.8.2 LogMonitor: Já ativo."); return end
    print("V0.8.2 LogMonitor: ATIVANDO monitoramento...")
    logMonitorActive = true
    hasFiredRoundOverSignalThisRound = false -- Reseta a flag para a nova rodada
    if messageOutConnection and messageOutConnection.Connected then messageOutConnection:Disconnect() end

    messageOutConnection = LogService.MessageOut:Connect(function(message, messageType)
        if not logMonitorActive then return end 
        
        -- Log bruto para ver todas as mensagens se necessário (pode ser muito!)
        -- print("RAW_CONSOLE_MSG ("..tostring(messageType).."): " .. message)

        if string.find(string.lower(message), string.lower(CONSOLE_MESSAGE_FOR_RESTART), 1, true) then
            print("V0.8.2 LogMonitor: MENSAGEM CHAVE '"..CONSOLE_MESSAGE_FOR_RESTART.."' DETECTADA EM: '" .. message .. "'")
            if not hasFiredRoundOverSignalThisRound then -- Só dispara uma vez por rodada
                print("V0.8.2 LogMonitor: Disparando roundOverSignal e DESCONECTANDO monitoramento para esta rodada.")
                roundOverSignal:Fire() 
                hasFiredRoundOverSignalThisRound = true -- Marca que já disparou
                logMonitorActive = false -- Para de processar novas mensagens nesta conexão
                if messageOutConnection then messageOutConnection:Disconnect(); messageOutConnection = nil end
            else
                print("V0.8.2 LogMonitor: Mensagem chave detectada novamente, mas roundOverSignal já foi disparado para esta rodada.")
            end
        end
    end)
end

local function stopLogMonitoring()
    print("V0.8.2 LogMonitor: PARANDO monitoramento explicitamente.")
    logMonitorActive = false
    if messageOutConnection and messageOutConnection.Connected then
        messageOutConnection:Disconnect()
        messageOutConnection = nil
    end
end

--====================================================================================
-- FUNÇÃO DE REINÍCIO DE FASE (COM MAIS DEBUG)
--====================================================================================
local function checkForAndPressPlayAgain() 
    print("V0.8.2 checkPlayAgain: Procurando por TelaDeVitoria: '"..VICTORY_SCREEN_NAME.."'")
    local victoryScreen = PlayerGui:FindFirstChild(VICTORY_SCREEN_NAME, true) 

    if not victoryScreen then print("V0.8.2 CPA: "..VICTORY_SCREEN_NAME.." NÃO ENCONTRADA EM PLAYERGUI."); return false end
    if not victoryScreen.Enabled then print("V0.8.2 CPA: "..VICTORY_SCREEN_NAME.." encontrada, MAS NÃO ESTÁ HABILITADA (.Enabled=false)."); return false end
    
    print("V0.8.2 CPA: TelaDeVitoria '"..VICTORY_SCREEN_NAME.."' ENCONTRADA e HABILITADA!")
    
    -- Adicionada verificação visual do botão "Reproduzir" como na V0.6.1 para robustez extra
    local reproduceButtonVisual = victoryScreen:FindFirstChild("ReproduceButton", true) -- (!!) ASSUMINDO NOME "ReproduceButton" (!!)
    if not reproduceButtonVisual or not reproduceButtonVisual.Visible then
        print("V0.8.2 CPA: Botão visual 'ReproduceButton' não encontrado ou não visível dentro de '"..VICTORY_SCREEN_NAME.."'.")
        return false -- Não tenta disparar o remote se o botão visual não estiver lá
    end
    print("V0.8.2 CPA: Botão visual 'ReproduceButton' ENCONTRADO e VISÍVEL.")

    local playAgainRemote = getRemote(REMOTE_PLAY_AGAIN_PATH)
    if not playAgainRemote then warn("V0.8.2 CPA: Remote '"..REMOTE_PLAY_AGAIN_PATH.."' NÃO encontrado."); return false end
    
    if not playAgainRemote:IsA("RemoteEvent") then warn("V0.8.2 CPA: Obj em '"..REMOTE_PLAY_AGAIN_PATH.."' NÃO É RemoteEvent. É: "..playAgainRemote.ClassName); return false end
            
    print("V0.8.2 CPA: RemoteEvent '"..REMOTE_PLAY_AGAIN_PATH.."' encontrado. Disparando com argumento: '" .. PLAY_AGAIN_ARGUMENT .. "'")
    local success, err = pcall(function() playAgainRemote:FireServer(PLAY_AGAIN_ARGUMENT) end)
    
    if success then print("V0.8.2 CPA: RemoteEvent disparado COM SUCESSO!"); return true 
    else warn("V0.8.2 CPA: ERRO ao disparar RemoteEvent: "..tostring(err)); return false end 
end

--====================================================================================
-- LOOP DE JOGO PRINCIPAL (MASTER LOOP - COM MAIS DEBUG)
--====================================================================================
local function masterGameLoop()
    print("FARM V0.8.2: MGL Init...")
    stopAllLoops = false 
    while not stopAllLoops do
        print("=====FARM V0.8.2 MGL: NEW ROUND=====")
        targetUnitInstance=nil; remoteCache={}; 
        local roundDeclaredOverByLog = false -- Renomeado para clareza
        
        startLogMonitoring() 

        if not initializePlayerAndCharacter() then print("CRIT MGL:PInitFail.Stop."); stopAllLoops=true; break end
        if not executeTeleport() then print("CRIT MGL:TPFail.Stop."); stopAllLoops=true; break end
        setGameSpeedTo2X() 
        if not placeUnitOnMap() then print("CRIT MGL:PlaceFail.NewRound10s"); stopLogMonitoring(); wait(10); continue end
        wait(1); 
        if not findUnitsFolder() then print("CRIT MGL:UFFail.NewRound10s"); stopLogMonitoring(); wait(10); continue end
        
        if findOrWaitForUnit() then 
            print("INFO MGL:UnitFound,starting CUL...");
            local upgradeCoroutine = coroutine.create(continuousUpgradeLoop)
            local co_success, co_error = coroutine.resume(upgradeCoroutine)
            if not co_success then warn("ERR StartingCUL:",co_error); print("CRIT MGL:CULFail.NewRound10s"); stopLogMonitoring(); wait(10); continue end
            print("INFO MGL:CULstarted.")

            local coStatus = coroutine.status(upgradeCoroutine)
            local waitingForEndOfRoundSignal = true
            print("INFO MGL: Aguardando CUL terminar OU sinal de 'rewards collected'...")
            
            while waitingForEndOfRoundSignal and not stopAllLoops do
                local signalReceivedThisWait = false
                local pcallWaitOk, pcallWaitVal = pcall(function() 
                    signalReceivedThisWait = roundOverSignal.Event:Wait(0.5) -- Checa a cada 0.5s
                end)
                if not pcallWaitOk then print("WARN MGL: Erro em Event:Wait(): "..tostring(pcallWaitVal)) end

                if signalReceivedThisWait then
                    print("INFO MGL: Sinal de 'rewards collected' RECEBIDO (via Event:Wait)!")
                    roundDeclaredOverByLog = true
                    waitingForEndOfRoundSignal = false 
                end
                
                coStatus = coroutine.status(upgradeCoroutine)
                if coStatus == "dead" then
                    print("INFO MGL: CUL terminou (status dead).")
                    waitingForEndOfRoundSignal = false 
                end
                -- print("MGL Wait Loop: signalReceived="..tostring(signalReceivedThisWait)..", coStatus="..coStatus) -- Log muito verboso
            end
            
            stopLogMonitoring() 

            if stopAllLoops then print("INFO MGL: stopAllLoops ativado, saindo espera CUL/sinal."); break end 
            
            if roundDeclaredOverByLog then
                print("INFO MGL: Fim da rodada por MSG CONSOLE. Parando CUL...")
                stopAllLoops = true; local c=0; while coroutine.status(upgradeCoroutine)~="dead" and c<3 do wait(0.5);c=c+1;print("INFO MGL: Esperando CUL sair ("..c..")...") end; stopAllLoops = false;
            elseif coStatus == "dead" then
                 print("INFO MGL: CUL terminou (unidade sumiu/max upg antes da msg de rewards).")
            end
            
            print("INFO MGL: Verificando tela de vitória...")
            local victoryScreenPressed = false; local waitStartTime = tick()
            while not victoryScreenPressed and not stopAllLoops and (tick() - waitStartTime < MAX_WAIT_FOR_VICTORY_SCREEN) do
                if checkForAndPressPlayAgain() then print("INFO MGL:'Reproduzir'PRESSED."); victoryScreenPressed=true 
                else print("INFO MGL:Tela vitória NF/botão NP.Wait...") end
                wait(CHECK_FOR_VICTORY_SCREEN_INTERVAL)
            end
            if not victoryScreenPressed and not stopAllLoops then print("WARN MGL:TimeoutVS.") elseif stopAllLoops then print("INFO MGL:stopAllLoops duringVSwait.");break end
        else 
            print("CRIT MGL:UnitNOTfound.NewRound10s"); stopLogMonitoring(); wait(10); 
        end; 
        
        if stopAllLoops then break end
        print("FARM V0.8.2 MGL:EndOfRound.Wait~7s")
        wait(7) 
    end
    stopLogMonitoring() 
    print("FARM V0.8.2 FINAL:MGLended.")
end

local s_main,e_main=pcall(masterGameLoop);if not s_main then warn("FATAL ERR MGL():",e_main)end
print("FARM V0.8.2(via HttpGet):ExecTerminated.")
