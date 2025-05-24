--[[
    SCRIPT DE FARM (V0.6.2 - COMPLETO - Logs Detalhados no Fim do CUL)
]]

print("FARM V0.6.2 (via HttpGet): Script carregado e iniciando...")
wait(1)

--====================================================================================
-- CONFIGURAÇÕES 
--====================================================================================
local TARGET_CFRAME = CFrame.new(23.4280948638916, 3.0800403491973877, -5.562551498413086)
local UNIT_PLACEMENT_POSITION = Vector3.new(23.4280948638916, 3.0800403491973877, -5.562551498413086)
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
local CHECK_FOR_VICTORY_SCREEN_INTERVAL = 2 
local MAX_WAIT_FOR_VICTORY_SCREEN = 30 
print("FARM V0.6.2: Configs carregadas.")

--====================================================================================
-- SERVIÇOS E VARIÁVEIS GLOBAIS
--====================================================================================
local Players=game:GetService("Players"); local Workspace=game:GetService("Workspace"); local ReplicatedStorage=game:GetService("ReplicatedStorage"); local RunService=game:GetService("RunService")
local LocalPlayer=Players.LocalPlayer; if not LocalPlayer then error("FATAL: No LocalPlayer") end; local PlayerGui=LocalPlayer:WaitForChild("PlayerGui"); if not PlayerGui then error("FATAL: No PlayerGui") end
local character,humanoidRootPart,unitsFolderInstance,targetUnitInstance=nil,nil,nil,nil; local stopAllLoops=false
print("FARM V0.6.2: Serviços e globais ok.")

--====================================================================================
-- FUNÇÕES AUXILIARES
--====================================================================================
local function customSplit(s, sep) if type(s)~="string" or type(sep)~="string" then return {} end; if sep=="" then return {s} end; local r={}; local ci=1; while true do local si,ei=string.find(s,sep,ci,true); if not si then table.insert(r,string.sub(s,ci)); break end; table.insert(r,string.sub(s,ci,si-1)); ci=ei+1; if ci>#s and si then table.insert(r,""); break end end; return r end
local remoteCache={}; local function getRemote(fp) if remoteCache[fp]==false then return nil elseif remoteCache[fp] then return remoteCache[fp] end; print("V0.6.2 getRemote: "..tostring(fp)); if type(fp)~="string" then warn("getRemote: Path non-string"); remoteCache[fp]=false; return nil end; local pp=customSplit(fp,"."); if not pp or #pp==0 then warn("getRemote: customSplit fail"); remoteCache[fp]=false; return nil end; local co=ReplicatedStorage; for _,pn in ipairs(pp) do if co and type(co.FindFirstChild)=="function" then local f=co:FindFirstChild(pn,3); if not f then warn("getRemote: Part NF: "..pn.." in "..co:GetFullName()); remoteCache[fp]=false; return nil end; co=f else warn("getRemote: Invalid CO for "..pn); remoteCache[fp]=false; return nil end end; if co then print("V0.6.2 getRemote: Found: "..co:GetFullName().." ("..co.ClassName..")"); remoteCache[fp]=co else warn("V0.6.2 getRemote: Not Found: "..fp); remoteCache[fp]=false end; return co end

--====================================================================================
-- FUNÇÕES DE JOGO
--====================================================================================
local function initializePlayerAndCharacter() print("V0.6.2 InitP&C"); character=LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait();if not character then print("ERR:NoC");return false end;humanoidRootPart=character:WaitForChild("HumanoidRootPart",20);if not humanoidRootPart then print("ERR:NoHRP");return false end;print("OK:P&C&HRP init");return true end
local function executeTeleport() print("V0.6.2 TP");if not humanoidRootPart then print("ERR:HRPnilTP");return false end;local s,e=pcall(function()humanoidRootPart.CFrame=TARGET_CFRAME end);if s then print("OK:TPsent.Pos:"..tostring(humanoidRootPart.Position));return true else print("ERR:TPfail:"..tostring(e));return false end end
local function findUnitsFolder() print("V0.6.2 FindUF");local p=customSplit(UNITS_FOLDER_PATH_IN_WORKSPACE,".");local c=Workspace;for _,n in ipairs(p)do if c and type(c.WaitForChild)=="function"then c=c:WaitForChild(n,10);if not c then print("ERR:UFpart'"..n.."'NF");return false end else print("ERR:InvalidObjUF");return false end end;unitsFolderInstance=c;if unitsFolderInstance then print("OK:UF:"..unitsFolderInstance:GetFullName());return true else print("ERR:UF NF");return false end end
local function setGameSpeedTo2X() print("V0.6.2 setGameSpeed");local r=getRemote(REMOTE_SPEED_CHANGE_PATH);if not r or type(r.InvokeServer)~="function"then warn("Speed:RemoteInvalid");return end;local s,e=pcall(function()r:InvokeServer()end);if s then print("Speed:CmdSent")else warn("Speed:Fail:"..tostring(e))end;wait(0.5)end
local function placeUnitOnMap() print("V0.6.2 placeUnit");local r=getRemote(REMOTE_PLACE_UNIT_PATH);if not r or type(r.InvokeServer)~="function"then warn("PlaceU:RemoteInvalid");return false end;print("PlaceU:Slot"..UNIT_PLACEMENT_SLOT_NUMBER);local a={[1]=UNIT_PLACEMENT_SLOT_NUMBER,[2]=UNIT_INSTANCE_ID_IN_SLOT,[3]=UNIT_BASE_ID,[4]=UNIT_PLACEMENT_POSITION};local s,e=pcall(function()r:InvokeServer(unpack(a))end);if s then print("PlaceU:CmdSent.Wait"..DELAY_AFTER_PLACEMENT.."s");wait(DELAY_AFTER_PLACEMENT);return true else warn("PlaceU:Fail:"..tostring(e));return false end end
local function findOrWaitForUnit() print("V0.6.2 findUnit:'"..UNIT_TO_FIND_NAME.."'");if not unitsFolderInstance then print("ERR:UFnil");return false end;for att=1,MAX_UNIT_FIND_ATTEMPTS do targetUnitInstance=unitsFolderInstance:FindFirstChild(UNIT_TO_FIND_NAME);if targetUnitInstance and targetUnitInstance:IsA("Model")then print("OK:Unit'"..UNIT_TO_FIND_NAME.."'found:"..targetUnitInstance:GetFullName());return true else if targetUnitInstance then print("WARN:Obj'"..UNIT_TO_FIND_NAME.."'foundNotModel:"..targetUnitInstance.ClassName)else print("INFO:Unit'"..UNIT_TO_FIND_NAME.."'NF.Att"..att)end end;if att<MAX_UNIT_FIND_ATTEMPTS then wait(CHECK_UNIT_INTERVAL)end end;print("ERR:Unit'"..UNIT_TO_FIND_NAME.."'NOTfound");targetUnitInstance=nil;return false end
local upgradeUnitRemoteFunc=nil;local function performSingleUpgrade(uM,uP)if not upgradeUnitRemoteFunc then print("V0.6.2PSU:GetRemote");upgradeUnitRemoteFunc=getRemote(REMOTE_UPGRADE_UNIT_PATH);if not upgradeUnitRemoteFunc or type(upgradeUnitRemoteFunc.InvokeServer)~="function"then warn("PSU:InvalidRemote");upgradeUnitRemoteFunc=nil;return false end;print("V0.6.2PSU:RemoteCached")end;if not upgradeUnitRemoteFunc then return false end;print("V0.6.2PSU:Upg"..uM.Name..",P"..uP);local s,r=pcall(function()return upgradeUnitRemoteFunc:InvokeServer(uM,uP)end);if s then if r==false then print("V0.6.2PSU:UPG_NEGADO_SV "..uM.Name..",P"..uP);return false end;print("V0.6.2PSU:UPG_SUCESSO "..uM.Name..",P"..uP..".Res:"..tostring(r));return true else warn("V0.6.2PSU:ERR_InvokeServer:"..tostring(r));return false end end

--====================================================================================
-- LOOP DE UPGRADE CONTÍNUO (COM LOGS DE FIM DETALHADOS)
--====================================================================================
local function continuousUpgradeLoop()
    if not targetUnitInstance then print("ERR: No unit for CUL."); return end
    print("FARM V0.6.2: Iniciando CONTINUOUS UPGRADE LOOP para " .. targetUnitInstance.Name)

    local topUpgradesDone, bottomUpgradesDone, initialPhaseComplete, continuouslyUpgradingTop, loopIteration = 0,0,false,false,0

    while not stopAllLoops and targetUnitInstance and targetUnitInstance.Parent do
        loopIteration = loopIteration + 1 
        print("--- FARM V0.6.2 CUL: Iteração do Loop #"..loopIteration.." ---") 

        local upgradedThisCycle = false
        if not initialPhaseComplete then
            if topUpgradesDone < INITIAL_TOP_UPGRADES_COUNT then
                if performSingleUpgrade(targetUnitInstance, UPGRADE_PATH_TOP) then topUpgradesDone = topUpgradesDone + 1; upgradedThisCycle = true end
            elseif bottomUpgradesDone < INITIAL_BOTTOM_UPGRADES_COUNT then
                 if performSingleUpgrade(targetUnitInstance, UPGRADE_PATH_BOTTOM) then bottomUpgradesDone = bottomUpgradesDone + 1; upgradedThisCycle = true end
            else
                initialPhaseComplete = true; continuouslyUpgradingTop = true
                print("FARM V0.6.2 CUL: Fase inicial CONCLUÍDA. Iniciando upgrade contínuo do TOPO.")
            end
        end
        if continuouslyUpgradingTop then
            if performSingleUpgrade(targetUnitInstance, UPGRADE_PATH_TOP) then upgradedThisCycle = true end
        end
        wait(DELAY_BETWEEN_UPGRADE_ATTEMPTS) 
    end 

    -- LOGS DETALHADOS DE POR QUE O LOOP TERMINOU:
    print("-------------------------------------------------------------")
    print("FARM V0.6.2 CUL: FIM DO LOOP DE UPGRADE DETECTADO!")
    if stopAllLoops then 
        print("CUL END REASON: stopAllLoops era true.")
    end
    if not targetUnitInstance then
        print("CUL END REASON: targetUnitInstance tornou-se nil durante o loop.")
    elseif not targetUnitInstance.Parent then
        print("CUL END REASON: targetUnitInstance.Parent tornou-se nil (unidade removida do jogo).")
        if targetUnitInstance.Name then -- Verifica se Name ainda é acessível
             print("CUL END INFO: Nome da unidade: " .. targetUnitInstance.Name)
        else
             print("CUL END INFO: targetUnitInstance.Name não é acessível.")
        end
    else
        print("CUL END REASON: Condição do loop (targetUnitInstance and targetUnitInstance.Parent) avaliada como false, MAS .Parent NÃO é nil. Isso é INESPERADO se stopAllLoops for false.")
        print("CUL END INFO: targetUnitInstance.Name: " .. (targetUnitInstance.Name or "Nome Indisponível") .. ", Parent: " .. (targetUnitInstance.Parent and targetUnitInstance.Parent.Name or "nil"))
        print("CUL END INFO: stopAllLoops é: " .. tostring(stopAllLoops))
    end
    local runningCoroutine = coroutine.running()
    if runningCoroutine then
        print("CUL INFO: Status da corrotina atual (de dentro do CUL): " .. coroutine.status(runningCoroutine))
    else
        print("CUL INFO: Não foi possível obter a corrotina atual (provavelmente porque já terminou).")
    end
    print("-------------------------------------------------------------")
    
    print("V0.6.2 CUL:ENDED for "..(targetUnitInstance and targetUnitInstance.Name or "Unidade Desconhecida"))
end

-- FUNÇÃO DE REINÍCIO DE FASE
local function checkForAndPressPlayAgain() 
    print("V0.6.2 checkPlayAgain:'"..VICTORY_SCREEN_NAME.."'...");
    local vS=PlayerGui:FindFirstChild(VICTORY_SCREEN_NAME,true);
    if vS and vS.Enabled then 
        print("V0.6.2 checkPlayAgain:VS('"..VICTORY_SCREEN_NAME.."')detected!");
        local pAR=getRemote(REMOTE_PLAY_AGAIN_PATH); -- pAR é playAgainRemote
        if pAR then 
            if pAR:IsA("RemoteEvent")then 
                print("V0.6.2 checkPlayAgain:RE'"..REMOTE_PLAY_AGAIN_PATH.."'found.Firing arg:'"..PLAY_AGAIN_ARGUMENT.."'");
                local s,e=pcall(function()pAR:FireServer(PLAY_AGAIN_ARGUMENT)end); -- Usando pAR aqui
                if s then print("V0.6.2 checkPlayAgain:REfired!");return true 
                else warn("V0.6.2 checkPlayAgain:ERRfireRE:"..tostring(e));return false end 
            else warn("V0.6.2 checkPlayAgain:ObjAt'"..REMOTE_PLAY_AGAIN_PATH.."'not RE.Is:"..pAR.ClassName);return false end 
        else warn("V0.6.2 checkPlayAgain:RemotePlayAgain('"..REMOTE_PLAY_AGAIN_PATH.."')NF.");return false end 
    else 
        -- print("V0.6.2 checkPlayAgain: VS not found or not enabled.") -- Pode ser verboso, comentado
        return false 
    end 
end

--====================================================================================
-- LOOP DE JOGO PRINCIPAL (MASTER LOOP)
--====================================================================================
local function masterGameLoop()
    print("FARM V0.6.2: Iniciando MASTER GAME LOOP...")
    stopAllLoops = false 
    while not stopAllLoops do
        print("===== FARM V0.6.2 MASTER LOOP: INICIANDO NOVA RODADA =====")
        targetUnitInstance = nil; remoteCache = {} 
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
            if not co_success then warn("ERRO AO INICIAR CUL:", co_error); print("CRIT MLoop: Falha CUL. Tentando nova rodada 10s"); wait(10); continue end
            print("INFO MLoop: CUL iniciado/resumido.")
            
            local coStatus = coroutine.status(upgradeCoroutine)
            print("INFO MLoop: Status inicial da corrotina de upgrade: " .. coStatus)

            while coStatus ~= "dead" and not stopAllLoops do 
                wait(1) 
                coStatus = coroutine.status(upgradeCoroutine)
                -- print("INFO MLoop: Aguardando CUL terminar. Status atual: " .. coStatus) -- Log verboso
            end

            if stopAllLoops then print("INFO MLoop: stopAllLoops ativado, saindo espera CUL."); break end 
            
            print("INFO MLoop: CUL terminou (status final: " .. coStatus .. "). Iniciando verificação da tela de vitória.")
            
            local victoryScreenPressed = false; local waitStartTime = tick()
            while not victoryScreenPressed and not stopAllLoops and (tick() - waitStartTime < MAX_WAIT_FOR_VICTORY_SCREEN) do
                if checkForAndPressPlayAgain() then print("INFO MLoop: 'Reproduzir' ACIONADO."); victoryScreenPressed = true 
                else print("INFO MLoop: Tela de vitória não detectada ou botão não pressionado. Esperando...") end
                wait(CHECK_FOR_VICTORY_SCREEN_INTERVAL)
            end

            if not victoryScreenPressed and not stopAllLoops then print("WARN MLoop: Timeout tela de vitória ou botão não pressionado.") 
            elseif stopAllLoops then print("INFO MLoop: stopAllLoops ativado durante espera tela vitória."); break end
        else 
            print("CRIT MLoop: Unidade NÃO encontrada após colocação. Tentando nova rodada 10s..."); wait(10); 
        end; 
        
        if stopAllLoops then break end
        print("FARM V0.6.2 MASTER LOOP: Fim da rodada processada. Aguardando ~7s para transição...")
        wait(7) 
    end
    print("FARM V0.6.2 FINAL: MASTER GAME LOOP encerrado.")
end

-- EXECUÇÃO INICIAL
local s_main,e_main = pcall(masterGameLoop); if not s_main then warn("FATAL ERR masterGameLoop(): ",e_main) end
print("FARM V0.6.2 (via HttpGet): Execução terminada.")
