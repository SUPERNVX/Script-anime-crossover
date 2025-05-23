--[[
    SCRIPT DE FARM (V0.8 - REINÍCIO BASEADO EM MENSAGEM DO CONSOLE "rewards collected:")
]]

print("FARM V0.8 (via HttpGet): Script carregado e iniciando...")
wait(1)

--====================================================================================
-- CONFIGURAÇÕES (Muitas configs do boss não são mais necessárias)
--====================================================================================
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

local CONSOLE_MESSAGE_FOR_RESTART = "rewards collected:" -- (!!) VERIFIQUE SE É EXATAMENTE ESTA STRING (!!)
print("FARM V0.8: Configs carregadas. Trigger de reinício: '"..CONSOLE_MESSAGE_FOR_RESTART.."'")

--====================================================================================
-- SERVIÇOS E VARIÁVEIS GLOBAIS
--====================================================================================
local Players=game:GetService("Players"); local Workspace=game:GetService("Workspace"); local ReplicatedStorage=game:GetService("ReplicatedStorage"); local RunService=game:GetService("RunService"); local LogService = game:GetService("LogService")
local LocalPlayer=Players.LocalPlayer; if not LocalPlayer then error("FATAL: No LocalPlayer") end; local PlayerGui=LocalPlayer:WaitForChild("PlayerGui"); if not PlayerGui then error("FATAL: No PlayerGui") end
local character,humanoidRootPart,unitsFolderInstance,targetUnitInstance=nil,nil,nil,nil; 
local stopAllLoops = false 
local roundOverSignal = Instance.new("BindableEvent") -- Para sinalizar que a rodada acabou
print("FARM V0.8: Serviços e globais ok.")

--====================================================================================
-- FUNÇÕES AUXILIARES (Mesmas)
--====================================================================================
local function customSplit(s, sep) if type(s)~="string" or type(sep)~="string" then return {} end; if sep=="" then return {s} end; local r={}; local ci=1; while true do local si,ei=string.find(s,sep,ci,true); if not si then table.insert(r,string.sub(s,ci)); break end; table.insert(r,string.sub(s,ci,si-1)); ci=ei+1; if ci>#s and si then table.insert(r,""); break end end; return r end
local remoteCache={}; local function getRemote(fp) if remoteCache[fp]==false then return nil elseif remoteCache[fp] then return remoteCache[fp] end; print("V0.8 getRemote: "..tostring(fp)); if type(fp)~="string" then warn("getRemote:Path non-string"); remoteCache[fp]=false; return nil end; local pp=customSplit(fp,"."); if not pp or #pp==0 then warn("getRemote:customSplit fail"); remoteCache[fp]=false; return nil end; local co=ReplicatedStorage; for _,pn in ipairs(pp) do if co and type(co.FindFirstChild)=="function" then local f=co:FindFirstChild(pn,3); if not f then warn("getRemote:Part NF: "..pn.." in "..co:GetFullName()); remoteCache[fp]=false; return nil end; co=f else warn("getRemote:Invalid CO for "..pn); remoteCache[fp]=false; return nil end end; if co then print("V0.8 getRemote:Found:"..co:GetFullName().." ("..co.ClassName..")"); remoteCache[fp]=co else warn("V0.8 getRemote:NotFound:"..fp); remoteCache[fp]=false end; return co end

-- FUNÇÕES DE JOGO (Mesmas, resumidas)
local function initializePlayerAndCharacter() print("V0.8 InitP&C");character=LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait();if not character then print("ERR:NoC");return false end;humanoidRootPart=character:WaitForChild("HumanoidRootPart",20);if not humanoidRootPart then print("ERR:NoHRP");return false end;print("OK:P&C&HRP init");return true end
local function executeTeleport() print("V0.8 TP");if not humanoidRootPart then print("ERR:HRPnilTP");return false end;local s,e=pcall(function()humanoidRootPart.CFrame=TARGET_CFRAME end);if s then print("OK:TPsent.Pos:"..tostring(humanoidRootPart.Position));return true else print("ERR:TPfail:"..tostring(e));return false end end
local function findUnitsFolder() print("V0.8 FindUF");local p=customSplit(UNITS_FOLDER_PATH_IN_WORKSPACE,".");local c=Workspace;for _,n in ipairs(p)do if c and type(c.WaitForChild)=="function"then c=c:WaitForChild(n,10);if not c then print("ERR:UFpart'"..n.."'NF");return false end else print("ERR:InvalidObjUF");return false end end;unitsFolderInstance=c;if unitsFolderInstance then print("OK:UF:"..unitsFolderInstance:GetFullName());return true else print("ERR:UF NF");return false end end
local function setGameSpeedTo2X() print("V0.8 setGameSpeed");local r=getRemote(REMOTE_SPEED_CHANGE_PATH);if not r or type(r.InvokeServer)~="function"then warn("Speed:RemoteInvalid");return end;local s,e=pcall(function()r:InvokeServer()end);if s then print("Speed:CmdSent")else warn("Speed:Fail:"..tostring(e))end;wait(0.5)end
local function placeUnitOnMap() print("V0.8 placeUnit");local r=getRemote(REMOTE_PLACE_UNIT_PATH);if not r or type(r.InvokeServer)~="function"then warn("PlaceU:RemoteInvalid");return false end;print("PlaceU:Slot"..UNIT_PLACEMENT_SLOT_NUMBER);local a={[1]=UNIT_PLACEMENT_SLOT_NUMBER,[2]=UNIT_INSTANCE_ID_IN_SLOT,[3]=UNIT_BASE_ID,[4]=UNIT_PLACEMENT_POSITION};local s,e=pcall(function()r:InvokeServer(unpack(a))end);if s then print("PlaceU:CmdSent.Wait"..DELAY_AFTER_PLACEMENT.."s");wait(DELAY_AFTER_PLACEMENT);return true else warn("PlaceU:Fail:"..tostring(e));return false end end
local function findOrWaitForUnit() print("V0.8 findUnit:'"..UNIT_TO_FIND_NAME.."'");if not unitsFolderInstance then print("ERR:UFnil");return false end;for att=1,MAX_UNIT_FIND_ATTEMPTS do targetUnitInstance=unitsFolderInstance:FindFirstChild(UNIT_TO_FIND_NAME);if targetUnitInstance and targetUnitInstance:IsA("Model")then print("OK:Unit'"..UNIT_TO_FIND_NAME.."'found:"..targetUnitInstance:GetFullName());return true else if targetUnitInstance then print("WARN:Obj'"..UNIT_TO_FIND_NAME.."'foundNotModel:"..targetUnitInstance.ClassName)else print("INFO:Unit'"..UNIT_TO_FIND_NAME.."'NF.Att"..att)end end;if att<MAX_UNIT_FIND_ATTEMPTS then wait(CHECK_UNIT_INTERVAL)end end;print("ERR:Unit'"..UNIT_TO_FIND_NAME.."'NOTfound");targetUnitInstance=nil;return false end
local upgradeUnitRemoteFunc=nil;local function performSingleUpgrade(uM,uP)if not upgradeUnitRemoteFunc then print("V0.8PSU:GetRemote");upgradeUnitRemoteFunc=getRemote(REMOTE_UPGRADE_UNIT_PATH);if not upgradeUnitRemoteFunc or type(upgradeUnitRemoteFunc.InvokeServer)~="function"then warn("PSU:InvalidRemote");upgradeUnitRemoteFunc=nil;return false end;print("V0.8PSU:RemoteCached")end;if not upgradeUnitRemoteFunc then return false end;print("V0.8PSU:Upg"..uM.Name..",P"..uP);local s,r=pcall(function()return upgradeUnitRemoteFunc:InvokeServer(uM,uP)end);if s then if r==false then print("V0.8PSU:UPG_NEGADO_SV "..uM.Name..",P"..uP);return false end;print("V0.8PSU:UPG_SUCESSO "..uM.Name..",P"..uP..".Res:"..tostring(r));return true else warn("V0.8PSU:ERR_InvokeServer:"..tostring(r));return false end end
local function continuousUpgradeLoop() if not targetUnitInstance then print("ERR:NoUnitCUL");return end;print("V0.8CUL:StartingFor"..targetUnitInstance.Name);local tU,bU,iPC,cUT,iter=0,0,false,false,0;local consecutiveTopFails=0;local MAX_FAILS_CONTINUOUS=10;while not stopAllLoops and targetUnitInstance and targetUnitInstance.Parent do iter=iter+1;print("---V0.8CUL:Loop#"..iter.."---");local uTC=false;if not iPC then if tU<INITIAL_TOP_UPGRADES_COUNT then if performSingleUpgrade(targetUnitInstance,UPGRADE_PATH_TOP)then tU=tU+1;uTC=true;consecutiveTopFails=0 else consecutiveTopFails=consecutiveTopFails+1 end elseif bU<INITIAL_BOTTOM_UPGRADES_COUNT then if performSingleUpgrade(targetUnitInstance,UPGRADE_PATH_BOTTOM)then bU=bU+1;uTC=true end else iPC=true;cUT=true;print("V0.8CUL:InitialPhaseDONE.ContinuousTOP");consecutiveTopFails=0 end end;if cUT then if performSingleUpgrade(targetUnitInstance,UPGRADE_PATH_TOP)then uTC=true;consecutiveTopFails=0 else consecutiveTopFails=consecutiveTopFails+1;if consecutiveTopFails>=MAX_FAILS_CONTINUOUS then print("V0.8CUL:MaxFailsContTOP("..MAX_FAILS_CONTINUOUS.."). Presuming path maxed for now."); break end end end;wait(DELAY_BETWEEN_UPGRADE_ATTEMPTS)end;print("V0.8CUL:ENDED for "..(targetUnitInstance and targetUnitInstance.Name or "UnitN/A"))end
local function checkForAndPressPlayAgain() print("V0.8 checkPlayAgain:'"..VICTORY_SCREEN_NAME.."'...");local vS=PlayerGui:FindFirstChild(VICTORY_SCREEN_NAME,true);if vS and vS.Enabled then local rPAVisual=vS:FindFirstChild("ReproduceButton",true); if not rPAVisual or not rPAVisual.Visible then print("V0.8 CPA: ReproduceButton visual not found/visible in "..VICTORY_SCREEN_NAME); return false end; print("V0.8 CPA:VS&ButtonVisual('"..VICTORY_SCREEN_NAME.."')detected!");local pAR=getRemote(REMOTE_PLAY_AGAIN_PATH);if pAR then if pAR:IsA("RemoteEvent")then print("V0.8 CPA:RE'"..REMOTE_PLAY_AGAIN_PATH.."'found.Firing:'"..PLAY_AGAIN_ARGUMENT.."'");local s,e=pcall(function()pAR:FireServer(PLAY_AGAIN_ARGUMENT)end);if s then print("V0.8 CPA:REfired!");return true else warn("V0.8 CPA:ERRfireRE:"..tostring(e));return false end else warn("V0.8 CPA:ObjAt'"..REMOTE_PLAY_AGAIN_PATH.."'not RE.Is:"..pAR.ClassName);return false end else warn("V0.8 CPA:RemotePlayAgain('"..REMOTE_PLAY_AGAIN_PATH.."')NF.");return false end else return false end end

--====================================================================================
-- MONITORAMENTO DO LOGSERVICE (NOVO)
--====================================================================================
local messageOutConnection = nil
local function startLogMonitoring()
    if messageOutConnection and messageOutConnection.Connected then
        print("V0.8 LogMonitor: Já está monitorando.")
        return
    end
    print("V0.8 LogMonitor: Iniciando monitoramento de LogService.MessageOut...")
    messageOutConnection = LogService.MessageOut:Connect(function(message, messageType)
        if messageType == Enum.MessageType.MessageOutput or messageType == Enum.MessageType.MessageInfo then -- Onde "rewards collected" aparece
            -- print("LOG: "..message) -- Descomente para ver todas as mensagens do console
            if string.find(string.lower(message), string.lower(CONSOLE_MESSAGE_FOR_RESTART)) then
                print("V0.8 LogMonitor: MENSAGEM CHAVE DETECTADA! '" .. message .. "'")
                print("V0.8 LogMonitor: Sinalizando fim da rodada...")
                roundOverSignal:Fire() -- Dispara o evento para o masterGameLoop
                
                -- Desconecta para evitar múltiplos disparos por rodada até ser reativado
                if messageOutConnection then
                    print("V0.8 LogMonitor: Desconectando monitoramento temporariamente.")
                    messageOutConnection:Disconnect()
                    messageOutConnection = nil
                end
            end
        end
    end)
    print("V0.8 LogMonitor: Monitoramento ATIVADO.")
end

local function stopLogMonitoring()
    if messageOutConnection and messageOutConnection.Connected then
        print("V0.8 LogMonitor: Parando monitoramento de LogService.MessageOut.")
        messageOutConnection:Disconnect()
        messageOutConnection = nil
    else
        print("V0.8 LogMonitor: Monitoramento já estava parado.")
    end
end

--====================================================================================
-- LOOP DE JOGO PRINCIPAL (MASTER LOOP - MODIFICADO PARA USAR roundOverSignal)
--====================================================================================
local function masterGameLoop()
    print("FARM V0.8: Iniciando MASTER GAME LOOP...")
    stopAllLoops = false 

    while not stopAllLoops do
        print("===== FARM V0.8 MASTER LOOP: INICIANDO NOVA RODADA =====")
        targetUnitInstance = nil; remoteCache = {}; 
        local roundActuallyOver = false -- Flag para este loop
        
        startLogMonitoring() -- Inicia o monitoramento do console para esta rodada

        if not initializePlayerAndCharacter() then print("CRIT MLoop: P init fail. Stop."); stopAllLoops=true; break end
        if not executeTeleport() then print("CRIT MLoop: TP fail. Stop."); stopAllLoops=true; break end
        setGameSpeedTo2X() 
        if not placeUnitOnMap() then print("CRIT MLoop: Place unit fail. NewRound10s"); stopLogMonitoring(); wait(10); continue end
        wait(1); 
        if not findUnitsFolder() then print("CRIT MLoop: UF fail. NewRound10s"); stopLogMonitoring(); wait(10); continue end
        
        if findOrWaitForUnit() then 
            print("INFO MLoop: Unidade encontrada, iniciando CUL..."); 
            
            local upgradeCoroutine = coroutine.create(continuousUpgradeLoop)
            local co_success, co_error = coroutine.resume(upgradeCoroutine)
            if not co_success then warn("ERRO INICIAR CUL:", co_error); print("CRIT MLoop:Falha CUL.NewRound10s"); stopLogMonitoring(); wait(10); continue end
            print("INFO MLoop: CUL iniciado.")

            -- Espera pelo sinal de roundOverSignal OU pelo fim da corrotina de upgrade
            local coStatus = coroutine.status(upgradeCoroutine)
            while coStatus ~= "dead" and not roundActuallyOver and not stopAllLoops do
                local signalReceived = false
                local successSignal, errSignal = pcall(function()
                    roundOverSignal.Event:Wait(1) -- Espera pelo evento com timeout de 1 segundo
                    signalReceived = true -- Se Wait não deu timeout, o evento foi disparado
                end)
                if not successSignal then print("WARN MLoop: Erro em Event:Wait(): " .. tostring(errSignal)) end

                if signalReceived then
                    print("INFO MLoop: Sinal de roundOverSignal RECEBIDO!")
                    roundActuallyOver = true
                end
                coStatus = coroutine.status(upgradeCoroutine)
            end
            stopLogMonitoring() -- Para o monitoramento após o sinal ou fim do CUL

            if stopAllLoops then print("INFO MLoop: stopAllLoops ativado, saindo espera CUL/sinal."); break end 
            
            if roundActuallyOver then
                print("INFO MLoop: Fim da rodada sinalizado por mensagem do console. Parando CUL (se ainda ativo)...")
                stopAllLoops = true -- Sinaliza para o CUL parar (ele verifica esta flag)
                local c = 0
                while coroutine.status(upgradeCoroutine) ~= "dead" and c < 3 do wait(1); c = c + 1 end -- Dá um tempinho para o CUL sair
                stopAllLoops = false -- Reseta para a próxima rodada principal
            elseif coStatus == "dead" then
                 print("INFO MLoop: CUL terminou (unidade sumiu ou max upgrades).")
            end
            
            print("INFO MLoop: Iniciando verificação da tela de vitória.")
            local victoryScreenPressed = false; local waitStartTime = tick()
            while not victoryScreenPressed and not stopAllLoops and (tick() - waitStartTime < MAX_WAIT_FOR_VICTORY_SCREEN) do
                if checkForAndPressPlayAgain() then print("INFO MLoop: 'Reproduzir' ACIONADO."); victoryScreenPressed = true 
                else print("INFO MLoop: Tela de vitória NF/botão NP. Esperando...") end
                wait(CHECK_FOR_VICTORY_SCREEN_INTERVAL)
            end
            if not victoryScreenPressed and not stopAllLoops then print("WARN MLoop: Timeout tela de vitória.") elseif stopAllLoops then print("INFO MLoop: stopAllLoops durante espera VS."); break end
        else 
            print("CRIT MLoop: Unidade NÃO encontrada. NewRound10s"); stopLogMonitoring(); wait(10); 
        end; 
        
        if stopAllLoops then break end
        print("FARM V0.8 MGL: Fim da rodada. Aguardando ~7s para transição...")
        wait(7) 
    end
    stopLogMonitoring() -- Garante que parou se sair do loop principal
    print("FARM V0.8 FINAL: MGL encerrado.")
end

-- EXECUÇÃO INICIAL
local s_main,e_main = pcall(masterGameLoop); if not s_main then warn("FATAL ERR MGL():",e_main) end
print("FARM V0.8 (via HttpGet): Execução terminada.")
