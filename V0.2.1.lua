--[[
    SCRIPT DE FARM (V0.8.1 - REFINAMENTOS E DEBUG ADICIONAL)
]]

print("FARM V0.8.1 (via HttpGet): Script carregado e iniciando...")
wait(1)

-- CONFIGURAÇÕES (Mantidas, mas atenção à CONSOLE_MESSAGE_FOR_RESTART)
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
local CHECK_FOR_VICTORY_SCREEN_INTERVAL = 2 
local MAX_WAIT_FOR_VICTORY_SCREEN = 30 
local CONSOLE_MESSAGE_FOR_RESTART = "rewards collected:" -- Confirmado pela sua print
local MAX_FAILS_CONTINUOUS_LOG_THRESHOLD = 5 -- Loga um aviso após X falhas, mas não para o loop
print("FARM V0.8.1: Configs. Trigger: '"..CONSOLE_MESSAGE_FOR_RESTART.."'")

-- SERVIÇOS E VARIÁVEIS GLOBAIS (Mesmas)
local Players=game:GetService("Players"); local Workspace=game:GetService("Workspace"); local ReplicatedStorage=game:GetService("ReplicatedStorage"); local RunService=game:GetService("RunService"); local LogService=game:GetService("LogService")
local LocalPlayer=Players.LocalPlayer; if not LocalPlayer then error("FATAL: No LocalPlayer") end; local PlayerGui=LocalPlayer:WaitForChild("PlayerGui"); if not PlayerGui then error("FATAL: No PlayerGui") end
local character,humanoidRootPart,unitsFolderInstance,targetUnitInstance=nil,nil,nil,nil; 
local stopAllLoops = false; local roundOverSignal = Instance.new("BindableEvent")
print("FARM V0.8.1: Serviços e globais ok.")

-- FUNÇÕES AUXILIARES (Mesmas)
local function customSplit(s, sep) if type(s)~="string" or type(sep)~="string" then return {} end; if sep=="" then return {s} end; local r={}; local ci=1; while true do local si,ei=string.find(s,sep,ci,true); if not si then table.insert(r,string.sub(s,ci)); break end; table.insert(r,string.sub(s,ci,si-1)); ci=ei+1; if ci>#s and si then table.insert(r,""); break end end; return r end
local remoteCache={}; local function getRemote(fp) if remoteCache[fp]==false then return nil elseif remoteCache[fp] then return remoteCache[fp] end; if type(fp)~="string" then warn("getRemote:Path non-string"); remoteCache[fp]=false; return nil end; local pp=customSplit(fp,"."); if not pp or #pp==0 then warn("getRemote:customSplit fail"); remoteCache[fp]=false; return nil end; local co=ReplicatedStorage; for _,pn in ipairs(pp) do if co and type(co.FindFirstChild)=="function" then local f=co:FindFirstChild(pn,3); if not f then warn("getRemote:Part NF: "..pn.." in "..co:GetFullName()); remoteCache[fp]=false; return nil end; co=f else warn("getRemote:Invalid CO for "..pn); remoteCache[fp]=false; return nil end end; if co then remoteCache[fp]=co else warn("V0.8.1 getRemote:NotFound:"..fp); remoteCache[fp]=false end; return co end

-- FUNÇÕES DE JOGO (Mesmas, resumidas para brevidade no exemplo, mas use as completas no seu script)
local function initializePlayerAndCharacter() print("V0.8.1 InitP&C"); character=LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait();if not character then print("ERR:NoC");return false end;humanoidRootPart=character:WaitForChild("HumanoidRootPart",20);if not humanoidRootPart then print("ERR:NoHRP");return false end;print("OK:P&C&HRP init");return true end
local function executeTeleport() print("V0.8.1 TP");if not humanoidRootPart then print("ERR:HRPnilTP");return false end;local s,e=pcall(function()humanoidRootPart.CFrame=TARGET_CFRAME end);if s then print("OK:TPsent.Pos:"..tostring(humanoidRootPart.Position));return true else print("ERR:TPfail:"..tostring(e));return false end end
local function findUnitsFolder() print("V0.8.1 FindUF");local p=customSplit(UNITS_FOLDER_PATH_IN_WORKSPACE,".");local c=Workspace;for _,n in ipairs(p)do if c and type(c.WaitForChild)=="function"then c=c:WaitForChild(n,10);if not c then print("ERR:UFpart'"..n.."'NF");return false end else print("ERR:InvalidObjUF");return false end end;unitsFolderInstance=c;if unitsFolderInstance then print("OK:UF:"..unitsFolderInstance:GetFullName());return true else print("ERR:UF NF");return false end end
local function setGameSpeedTo2X() print("V0.8.1 setGameSpeed");local r=getRemote(REMOTE_SPEED_CHANGE_PATH);if not r or type(r.InvokeServer)~="function"then warn("Speed:RemoteInvalid");return end;local s,e=pcall(function()r:InvokeServer()end);if s then print("Speed:CmdSent")else warn("Speed:Fail:"..tostring(e))end;wait(0.5)end
local function placeUnitOnMap() print("V0.8.1 placeUnit");local r=getRemote(REMOTE_PLACE_UNIT_PATH);if not r or type(r.InvokeServer)~="function"then warn("PlaceU:RemoteInvalid");return false end;print("PlaceU:Slot"..UNIT_PLACEMENT_SLOT_NUMBER);local a={[1]=UNIT_PLACEMENT_SLOT_NUMBER,[2]=UNIT_INSTANCE_ID_IN_SLOT,[3]=UNIT_BASE_ID,[4]=UNIT_PLACEMENT_POSITION};local s,e=pcall(function()r:InvokeServer(unpack(a))end);if s then print("PlaceU:CmdSent.Wait"..DELAY_AFTER_PLACEMENT.."s");wait(DELAY_AFTER_PLACEMENT);return true else warn("PlaceU:Fail:"..tostring(e));return false end end
local function findOrWaitForUnit() print("V0.8.1 findUnit:'"..UNIT_TO_FIND_NAME.."'");if not unitsFolderInstance then print("ERR:UFnil");return false end;for att=1,MAX_UNIT_FIND_ATTEMPTS do targetUnitInstance=unitsFolderInstance:FindFirstChild(UNIT_TO_FIND_NAME);if targetUnitInstance and targetUnitInstance:IsA("Model")then print("OK:Unit'"..UNIT_TO_FIND_NAME.."'found:"..targetUnitInstance:GetFullName());return true else if targetUnitInstance then print("WARN:Obj'"..UNIT_TO_FIND_NAME.."'foundNotModel:"..targetUnitInstance.ClassName)else print("INFO:Unit'"..UNIT_TO_FIND_NAME.."'NF.Att"..att)end end;if att<MAX_UNIT_FIND_ATTEMPTS then wait(CHECK_UNIT_INTERVAL)end end;print("ERR:Unit'"..UNIT_TO_FIND_NAME.."'NOTfound");targetUnitInstance=nil;return false end
local upgradeUnitRemoteFunc=nil;local function performSingleUpgrade(uM,uP)if not upgradeUnitRemoteFunc then print("V0.8.1PSU:GetRemote");upgradeUnitRemoteFunc=getRemote(REMOTE_UPGRADE_UNIT_PATH);if not upgradeUnitRemoteFunc or type(upgradeUnitRemoteFunc.InvokeServer)~="function"then warn("PSU:InvalidRemote");upgradeUnitRemoteFunc=nil;return false end;print("V0.8.1PSU:RemoteCached")end;if not upgradeUnitRemoteFunc then return false end;print("V0.8.1PSU:Upg "..uM.Name..",P"..uP);local s,r=pcall(function()return upgradeUnitRemoteFunc:InvokeServer(uM,uP)end);if s then if r==false then print("V0.8.1PSU:UPG_NEGADO_SV "..uM.Name..",P"..uP);return false end;print("V0.8.1PSU:UPG_SUCESSO "..uM.Name..",P"..uP..".Res:"..tostring(r));return true else warn("V0.8.1PSU:ERR_InvokeServer:"..tostring(r));return false end end
local function checkForAndPressPlayAgain() print("V0.8.1 checkPlayAgain:'"..VICTORY_SCREEN_NAME.."'");local vS=PlayerGui:FindFirstChild(VICTORY_SCREEN_NAME,true);if vS and vS.Enabled then local rPAV=vS:FindFirstChild("ReproduceButton",true);if not rPAV or not rPAV.Visible then print("V0.8.1 CPA:ReproduceButton visual NF/invisible in "..VICTORY_SCREEN_NAME);return false end;print("V0.8.1 CPA:VS&BtnVisual('"..VICTORY_SCREEN_NAME.."')OK");local pAR=getRemote(REMOTE_PLAY_AGAIN_PATH);if pAR then if pAR:IsA("RemoteEvent")then print("V0.8.1 CPA:RE'"..REMOTE_PLAY_AGAIN_PATH.."'found.Firing:'"..PLAY_AGAIN_ARGUMENT.."'");local s,e=pcall(function()pAR:FireServer(PLAY_AGAIN_ARGUMENT)end);if s then print("V0.8.1 CPA:REfired!");return true else warn("V0.8.1 CPA:ERRfireRE:"..tostring(e));return false end else warn("V0.8.1 CPA:ObjAt'"..REMOTE_PLAY_AGAIN_PATH.."'not RE.Is:"..pAR.ClassName);return false end else warn("V0.8.1 CPA:RemotePlayAgain('"..REMOTE_PLAY_AGAIN_PATH.."')NF.");return false end else return false end end

--====================================================================================
-- LOOP DE UPGRADE CONTÍNUO (MODIFICADO)
--====================================================================================
local function continuousUpgradeLoop() 
    if not targetUnitInstance then print("ERR:NoUnitCUL");return end
    print("V0.8.1CUL:StartingFor "..targetUnitInstance.Name)
    local tU,bU,iPC,cUT,iter=0,0,false,false,0
    local consecutiveTopFails = 0

    while not stopAllLoops and targetUnitInstance and targetUnitInstance.Parent do 
        iter=iter+1; print("---V0.8.1CUL:Loop#"..iter.." ---")
        local upgradedThisCycle = false
        if not iPC then 
            if tU<INITIAL_TOP_UPGRADES_COUNT then 
                if performSingleUpgrade(targetUnitInstance,UPGRADE_PATH_TOP)then tU=tU+1;upgradedThisCycle=true;consecutiveTopFails=0 
                -- Não incrementa consecutiveTopFails aqui, pois ainda estamos na fase inicial obrigatória.
                end 
            elseif bU<INITIAL_BOTTOM_UPGRADES_COUNT then 
                if performSingleUpgrade(targetUnitInstance,UPGRADE_PATH_BOTTOM)then bU=bU+1;upgradedThisCycle=true end 
            else 
                iPC=true;cUT=true;print("V0.8.1CUL:InitialPhaseDONE.ContinuousTOP");consecutiveTopFails=0 
            end 
        end
        if cUT then 
            if performSingleUpgrade(targetUnitInstance,UPGRADE_PATH_TOP)then 
                upgradedThisCycle=true;consecutiveTopFails=0 
            else 
                consecutiveTopFails=consecutiveTopFails+1
                print("V0.8.1CUL:FailContTOP.Fails:"..consecutiveTopFails)
                if consecutiveTopFails >= MAX_FAILS_CONTINUOUS_LOG_THRESHOLD and consecutiveTopFails % MAX_FAILS_CONTINUOUS_LOG_THRESHOLD == 0 then
                    -- Loga um aviso a cada X falhas, mas NÃO PARA O LOOP.
                    print("V0.8.1CUL:WARN - "..consecutiveTopFails.." falhas consecutivas no upg contínuo do TOPO. (Caminho pode estar maxed ou sem dinheiro)")
                end
                -- NÃO TEM MAIS O 'break' AQUI. O loop continua.
            end 
        end
        wait(DELAY_BETWEEN_UPGRADE_ATTEMPTS)
    end
    print("V0.8.1CUL:ENDED for "..(targetUnitInstance and targetUnitInstance.Name or "UnitN/A").." (Reason: stopAllLoops="..tostring(stopAllLoops).." or unit/parent nil)")
end

--====================================================================================
-- MONITORAMENTO DO LOGSERVICE (COM MAIS DEBUG)
--====================================================================================
local messageOutConnection = nil
local logMonitorActive = false

local function startLogMonitoring()
    if logMonitorActive then print("V0.8.1 LogMonitor: Já ativo."); return end
    print("V0.8.1 LogMonitor: ATIVANDO monitoramento...")
    logMonitorActive = true
    if messageOutConnection and messageOutConnection.Connected then messageOutConnection:Disconnect() end -- Garante que não haja conexões duplicadas

    messageOutConnection = LogService.MessageOut:Connect(function(message, messageType)
        if not logMonitorActive then return end -- Checagem extra

        -- print("RAW LOG: "..message) -- Para debug extremo, pode ser muito spam
        if string.find(string.lower(message), string.lower(CONSOLE_MESSAGE_FOR_RESTART), 1, true) then -- plain find
            print("V0.8.1 LogMonitor: MENSAGEM CHAVE '"..CONSOLE_MESSAGE_FOR_RESTART.."' DETECTADA NA MENSAGEM: '" .. message .. "'")
            if logMonitorActive then -- Verifica novamente antes de disparar e desconectar
                print("V0.8.1 LogMonitor: Sinalizando fim da rodada e DESCONECTANDO monitoramento.")
                roundOverSignal:Fire() 
                logMonitorActive = false -- Desativa para esta rodada
                if messageOutConnection then messageOutConnection:Disconnect(); messageOutConnection = nil end
            end
        end
    end)
end

local function stopLogMonitoring()
    print("V0.8.1 LogMonitor: PARANDO monitoramento.")
    logMonitorActive = false
    if messageOutConnection and messageOutConnection.Connected then
        messageOutConnection:Disconnect()
        messageOutConnection = nil
    end
end

--====================================================================================
-- LOOP DE JOGO PRINCIPAL (MASTER LOOP - COM MAIS DEBUG)
--====================================================================================
local function masterGameLoop()
    print("FARM V0.8.1: MGL Init...")
    stopAllLoops = false 
    while not stopAllLoops do
        print("=====FARM V0.8.1 MGL: NEW ROUND=====")
        targetUnitInstance=nil; remoteCache={}; 
        local roundActuallyOver = false 
        
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
            local waitingForSignalOrCULDead = true
            print("INFO MGL: Aguardando sinal de 'rewards collected' ou fim do CUL...")
            while waitingForSignalOrCULDead and not stopAllLoops do
                local signalReceived = false
                local eventFiredWithinTimeout = false
                local waitSuccess, waitErr = pcall(function()
                    eventFiredWithinTimeout = roundOverSignal.Event:Wait(0.5) -- Timeout menor para checar coStatus mais frequentemente
                end)

                if not waitSuccess then print("WARN MGL: Erro Event:Wait(): "..tostring(waitErr)) end
                
                if eventFiredWithinTimeout then
                    print("INFO MGL: Sinal de roundOverSignal RECEBIDO (via Event:Wait)!")
                    roundActuallyOver = true
                    waitingForSignalOrCULDead = false -- Sai deste loop de espera
                end
                
                coStatus = coroutine.status(upgradeCoroutine)
                if coStatus == "dead" then
                    print("INFO MGL: CUL terminou (status dead).")
                    waitingForSignalOrCULDead = false -- Sai deste loop de espera
                end
            end
            
            -- Independentemente de como saímos do loop acima, paramos o monitoramento do log para esta rodada.
            stopLogMonitoring() 

            if stopAllLoops then print("INFO MGL: stopAllLoops ativado, saindo da espera CUL/sinal."); break end 
            
            if roundActuallyOver then
                print("INFO MGL: Fim da rodada por MSG CONSOLE. Parando CUL (se ativo)...")
                stopAllLoops = true; local c=0; while coroutine.status(upgradeCoroutine)~="dead" and c<3 do wait(1);c=c+1 end; stopAllLoops = false;
            elseif coStatus == "dead" then
                 print("INFO MGL: CUL terminou (unidade sumiu/max upg).")
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
        print("FARM V0.8.1 MGL:EndOfRound.Wait~7s")
        wait(7) 
    end
    stopLogMonitoring() 
    print("FARM V0.8.1 FINAL:MGLended.")
end

local s_main,e_main=pcall(masterGameLoop);if not s_main then warn("FATAL ERR MGL():",e_main)end
print("FARM V0.8.1(via HttpGet):ExecTerminated.")
