--[[
    SCRIPT DE FARM (V0.8.5 - CORREÇÃO NIL CUL + DEBUG LOGSERVICE)
    VERSÃO COMPLETA E CORRIGIDA PARA GITHUB
]]

print("FARM V0.8.5 (via HttpGet): Script carregado e iniciando...")
wait(1)

-- CONFIGURAÇÕES
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
local CHECK_FOR_VICTORY_SCREEN_INTERVAL = 1; local MAX_WAIT_FOR_VICTORY_SCREEN = 30; 
local CONSOLE_MESSAGE_FOR_RESTART = "rewards collected:"
local CONSOLE_MESSAGE_FOR_RESTART_LOWER = string.lower(CONSOLE_MESSAGE_FOR_RESTART)
local MAX_FAILS_CONTINUOUS_LOG_THRESHOLD = 5
print("FARM V0.8.5: Configs. Trigger: '"..CONSOLE_MESSAGE_FOR_RESTART.."'")

-- SERVIÇOS E VARIÁVEIS GLOBAIS
local Players=game:GetService("Players"); local Workspace=game:GetService("Workspace"); local ReplicatedStorage=game:GetService("ReplicatedStorage"); local LogService=game:GetService("LogService")
local LocalPlayer=Players.LocalPlayer; if not LocalPlayer then error("FATAL: No LocalPlayer") end; local PlayerGui=LocalPlayer:WaitForChild("PlayerGui"); if not PlayerGui then error("FATAL: No PlayerGui") end
local character,humanoidRootPart,unitsFolderInstance,targetUnitInstance=nil,nil,nil,nil; 
local stopAllLoops = false; local roundOverEvent = Instance.new("BindableEvent")
print("FARM V0.8.5: Serviços e globais ok.")

-- FUNÇÕES AUXILIARES
local function customSplit(s, sep) if type(s)~="string" or type(sep)~="string" then return {} end; if sep=="" then return {s} end; local r={}; local ci=1; while true do local si,ei=string.find(s,sep,ci,true); if not si then table.insert(r,string.sub(s,ci)); break end; table.insert(r,string.sub(s,ci,si-1)); ci=ei+1; if ci>#s and si then table.insert(r,""); break end end; return r end
local remoteCache={}; local function getRemote(fp) if remoteCache[fp]==false then return nil elseif remoteCache[fp] then return remoteCache[fp] end; if type(fp)~="string"then remoteCache[fp]=false;return nil end;local pp=customSplit(fp,".");if not pp or #pp==0 then remoteCache[fp]=false;return nil end;local co=ReplicatedStorage;for _,pn in ipairs(pp)do if co and type(co.FindFirstChild)=="function"then local f=co:FindFirstChild(pn,3);if not f then remoteCache[fp]=false;return nil end;co=f else remoteCache[fp]=false;return nil end end;if co then remoteCache[fp]=co else remoteCache[fp]=false end;return co end

-- FUNÇÕES DE JOGO (VERSÕES COMPLETAS)
local function initializePlayerAndCharacter() 
    print("V0.8.5 InitP&C")
    character=LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    if not character then print("ERR:NoC"); return false end
    humanoidRootPart=character:WaitForChild("HumanoidRootPart",20)
    if not humanoidRootPart then print("ERR:NoHRP"); return false end
    print("OK:P&C&HRP init")
    return true 
end

local function executeTeleport() 
    print("V0.8.5 TP")
    if not humanoidRootPart then print("ERR:HRPnilTP"); return false end
    local s,e=pcall(function() humanoidRootPart.CFrame=TARGET_CFRAME end)
    if s then print("OK:TPsent") else print("ERR:TPfail:"..tostring(e)) end
    return s 
end

local function findUnitsFolder() 
    print("V0.8.5 FindUF")
    local p=customSplit(UNITS_FOLDER_PATH_IN_WORKSPACE,".")
    local c=Workspace
    for _,n in ipairs(p)do 
        if c and type(c.WaitForChild)=="function"then 
            c=c:WaitForChild(n,10)
            if not c then print("ERR:UFpart'"..n.."'NF"); return false end 
        else print("ERR:InvalidObjUF"); return false end 
    end
    unitsFolderInstance=c
    if unitsFolderInstance then print("OK:UF found") else print("ERR:UF NF") end
    return unitsFolderInstance ~= nil
end

local function setGameSpeedTo2X() 
    print("V0.8.5 setGameSpeed")
    local r=getRemote(REMOTE_SPEED_CHANGE_PATH)
    if not r or type(r.InvokeServer)~="function"then print("WARN:SpeedRemoteInvalid"); return end
    pcall(function()r:InvokeServer()end)
    wait(0.5)
    print("OK:SpeedCmdSent")
end

local function placeUnitOnMap() 
    print("V0.8.5 placeUnit")
    local r=getRemote(REMOTE_PLACE_UNIT_PATH)
    if not r or type(r.InvokeServer)~="function"then print("WARN:PlaceURemoteInvalid"); return false end
    local a={[1]=UNIT_PLACEMENT_SLOT_NUMBER,[2]=UNIT_INSTANCE_ID_IN_SLOT,[3]=UNIT_BASE_ID,[4]=UNIT_PLACEMENT_POSITION}
    local s,e=pcall(function()r:InvokeServer(unpack(a))end)
    if s then print("OK:PlaceU cmd sent"); wait(DELAY_AFTER_PLACEMENT); return true 
    else print("ERR:PlaceU fail:"..tostring(e)); return false end 
end

local function findOrWaitForUnit() 
    print("V0.8.5 findUnit")
    if not unitsFolderInstance then print("ERR:UFnil for findUnit"); return false end
    for att=1,MAX_UNIT_FIND_ATTEMPTS do 
        targetUnitInstance=unitsFolderInstance:FindFirstChild(UNIT_TO_FIND_NAME)
        if targetUnitInstance and targetUnitInstance:IsA("Model")then print("OK:UnitFound"); return true end
        if att<MAX_UNIT_FIND_ATTEMPTS then print("INFO:UnitNF, wait Att"..att); wait(CHECK_UNIT_INTERVAL)end 
    end
    print("ERR:UnitNOTfound after tries");targetUnitInstance=nil;return false 
end

local upgradeUnitRemoteFunc=nil
local function performSingleUpgrade(uM,uP)
    if not upgradeUnitRemoteFunc then 
        upgradeUnitRemoteFunc=getRemote(REMOTE_UPGRADE_UNIT_PATH)
        if not upgradeUnitRemoteFunc or type(upgradeUnitRemoteFunc.InvokeServer)~="function"then 
            print("WARN:UpgradeRemoteInvalid"); upgradeUnitRemoteFunc=nil; return false 
        end 
    end
    if not upgradeUnitRemoteFunc then return false end
    local s,r=pcall(function()return upgradeUnitRemoteFunc:InvokeServer(uM,uP)end)
    if s then 
        if r==false then print("PSU:UpgDenied "..uM.Name); return false end
        print("PSU:UpgOK "..uM.Name); return true 
    else print("ERR:PSU Invoke "..tostring(r)); return false end 
end

local function continuousUpgradeLoop() 
    if not targetUnitInstance then print("V0.8.5 CUL ERR:NoUnitCUL");return end
    print("V0.8.5 CUL:Start "..targetUnitInstance.Name)
    local tU,bU,iPC,cUT,iter,cTF=0,0,false,false,0,0
    if type(tU)~="number"then tU=0 end; if type(bU)~="number"then bU=0 end
    while not stopAllLoops and targetUnitInstance and targetUnitInstance.Parent do 
        iter=iter+1; 
        local upgradedThisCycle=false
        if not iPC then 
            if type(INITIAL_TOP_UPGRADES_COUNT)~="number" or type(INITIAL_BOTTOM_UPGRADES_COUNT)~="number" then print("ERR:CULConstsInvalid");break end
            if tU<INITIAL_TOP_UPGRADES_COUNT then 
                if performSingleUpgrade(targetUnitInstance,UPGRADE_PATH_TOP)then tU=tU+1;upgradedThisCycle=true;cTF=0 else print("CUL:FailUpgTopInit") end 
            elseif bU<INITIAL_BOTTOM_UPGRADES_COUNT then 
                if performSingleUpgrade(targetUnitInstance,UPGRADE_PATH_BOTTOM)then bU=bU+1;upgradedThisCycle=true else print("CUL:FailUpgBottomInit") end 
            else iPC=true;cUT=true;print("CUL:InitialPhaseDone");cTF=0 end 
        end
        if cUT then 
            if performSingleUpgrade(targetUnitInstance,UPGRADE_PATH_TOP)then upgradedThisCycle=true;cTF=0 
            else cTF=cTF+1;print("CUL:FailContTOP.Fails:"..cTF);if cTF>=MAX_FAILS_CONTINUOUS_LOG_THRESHOLD and cTF%MAX_FAILS_CONTINUOUS_LOG_THRESHOLD==0 then print("CUL:WARN-"..cTF.."failsContTOP")end end 
        end
        wait(DELAY_BETWEEN_UPGRADE_ATTEMPTS)
    end
    print("V0.8.5 CUL:ENDED") 
end

local function checkForAndPressPlayAgain() 
    print("V0.8.5 CPA:'"..VICTORY_SCREEN_NAME.."'")
    local vS=PlayerGui:FindFirstChild(VICTORY_SCREEN_NAME,true)
    if vS and vS.Enabled then 
        local rPAV=vS:FindFirstChild("ReproduceButton",true)
        if not rPAV or not rPAV.Visible then print("CPA:ReproduceBtnVisualNF"); return false end
        local pAR=getRemote(REMOTE_PLAY_AGAIN_PATH)
        if pAR and pAR:IsA("RemoteEvent")then 
            local s,e=pcall(function()pAR:FireServer(PLAY_AGAIN_ARGUMENT)end)
            if s then print("CPA:RE FiredOK"); return true else print("ERR:CPA FireFail "..tostring(e)) end
            return s 
        else print("ERR:CPA RemoteInvalid"); return false end 
    else print("INFO:CPA VS NF or disabled"); return false end 
end

-- MONITORAMENTO DO LOGSERVICE
local messageOutConnection = nil; local logMonitorShouldBeActive = false; local hasFiredRoundOverSignalThisRound = false 
local function listenForRewardsMessage()
    logMonitorShouldBeActive=true; hasFiredRoundOverSignalThisRound=false 
    if messageOutConnection and messageOutConnection.Connected then messageOutConnection:Disconnect() end
    print("V0.8.5 LogListen:CONNECTING...")
    messageOutConnection=LogService.MessageOut:Connect(function(m,mT)
        print(string.format("LogSvcMSG T[%s]:'%s'",tostring(mT),m))
        if not logMonitorShouldBeActive then return end
        local lM=string.lower(m)
        print(string.format("LogSvcCMP: lM='%s',target='%s'",lM,CONSOLE_MESSAGE_FOR_RESTART_LOWER))
        if string.find(lM,CONSOLE_MESSAGE_FOR_RESTART_LOWER,1,true)then
            print("V0.8.5 LogListen:!!!KEY MSG FOUND!!! -> '"..m.."'")
            if not hasFiredRoundOverSignalThisRound then
                print("V0.8.5 LogListen:Firing roundOverEvent & DISABLING listener.")
                hasFiredRoundOverSignalThisRound=true;logMonitorShouldBeActive=false 
                if messageOutConnection and messageOutConnection.Connected then messageOutConnection:Disconnect();messageOutConnection=nil end
                roundOverEvent:Fire() 
            else print("V0.8.5 LogListen:KeyMSG,but signal already fired.")end
        end
    end)
    if messageOutConnection and messageOutConnection.Connected then print("V0.8.5 LogListen:ConnectOK.")else print("V0.8.5 LogListen:ConnectFAIL.")end
end

-- LOOP DE JOGO PRINCIPAL
local function masterGameLoop()
    print("FARM V0.8.5:MGL Init...");stopAllLoops=false
    while not stopAllLoops do 
        print("=====FARM V0.8.5 MGL:NEW ROUND=====");targetUnitInstance=nil;remoteCache={};logMonitorShouldBeActive=true;listenForRewardsMessage()
        if not initializePlayerAndCharacter()then print("CRIT:PInitFail.Stop.");stopAllLoops=true;break end
        if not executeTeleport()then print("CRIT:TPFail.Stop.");stopAllLoops=true;break end
        setGameSpeedTo2X()
        if not placeUnitOnMap()then print("CRIT:PlaceFail.NewRnd10s");if messageOutConnection then messageOutConnection:Disconnect()end;logMonitorShouldBeActive=false;wait(10);continue end
        wait(1);if not findUnitsFolder()then print("CRIT:UFFail.NewRnd10s");if messageOutConnection then messageOutConnection:Disconnect()end;logMonitorShouldBeActive=false;wait(10);continue end
        if findOrWaitForUnit()then 
            print("INFO:UnitFound,startingCUL...");local ugCo=coroutine.create(continuousUpgradeLoop);coroutine.resume(ugCo);print("INFO:CULstarted.")
            print("INFO:MGLWait 'rewards collected' signal...");local sigFired=false;local pWOK,pWVal=pcall(function()roundOverEvent.Event:Wait();sigFired=true end)
            if not pWOK then print("WARN:ErrEventWait:"..tostring(pWVal))end
            if sigFired then print("INFO:roundOverEventRX!")else print("WARN:ExitEventWaitNoSig.")end
            logMonitorShouldBeActive=false;if messageOutConnection then messageOutConnection:Disconnect();messageOutConnection=nil end
            print("INFO:SignalCULtoStop...");stopAllLoops=true;local c=0;while coroutine.status(ugCo)~="dead"and c<5 do wait(0.2);c=c+1 end;stopAllLoops=false
            print("INFO:CheckVS...");local vsP=false;local wsT=tick();while not vsP and not stopAllLoops and(tick()-wsT<MAX_WAIT_FOR_VICTORY_SCREEN)do if checkForAndPressPlayAgain()then print("INFO:'Reproduzir'PRESSED.");vsP=true else print("INFO:VS NF/btnNP.Wait...")end;wait(CHECK_FOR_VICTORY_SCREEN_INTERVAL)end
            if not vsP and not stopAllLoops then print("WARN:TimeoutVS.")elseif stopAllLoops then print("INFO:stopAllLoopsDuringVSwait.");break end
        else print("CRIT:UnitNOTfound.NewRnd10s");if messageOutConnection then messageOutConnection:Disconnect()end;logMonitorShouldBeActive=false;wait(10)end
        if stopAllLoops then print("INFO:stopAllLoops,breakingMGL.");break end;print("FARM V0.8.5 MGL:EndOfRnd.Wait~7s");wait(7)
    end
    if messageOutConnection and messageOutConnection.Connected then messageOutConnection:Disconnect()end;logMonitorShouldBeActive=false;print("FARM V0.8.5 FINAL:MGLended.")
end
local s_main,e_main=pcall(masterGameLoop);if not s_main then warn("FATAL ERR MGL():",e_main)end
print("FARM V0.8.5(via HttpGet):ExecTerminated.")
