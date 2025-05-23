--[[
    SCRIPT DE FARM (V0..

**Script V0.9 (Baseado no seu V0.5 funcional + Nova Lógica de Rein9 - BASEADO NO SEU V0.5 FUNCIONAL + REINÍCIO VIA UI)
]]

print("Fício via UI):**

```lua
--[[
    SCRIPT DE FARM (V0.9 - REINÍCIO VIAARM V0.9 (via HttpGet): Script carregado e iniciando...")
wait(1)

--================ UI ESPECÍFICA)
    Baseado no seu V0.5 funcional.
    Assume que o tele====================================================================
-- CONFIGURAÇÕES (Valores do seu V0.5 + Novas para Reinício)
porte, colocação de unidade e upgrades estavam OK no V0.5.
    Foca em uma detecção de--====================================================================================
-- Teleporte
local TARGET_CFRAME = CFrame.new( fim de fase mais robusta via UI.
]]

print("FARM V0.9 (via HttpGet):7.1433563232421875, 3.06 Script carregado e iniciando...")
wait(1)

--====================================================================================
-- CONFIGURAÇÕES6650629043579, -65.110450 (DO SEU V0.5, com adições para reinício)
--====================================================================================
--7446289)

-- Colocação da Unidade
local UNIT_PLACEMENT_POSITION = Vector3. Teleporte
local TARGET_CFRAME = CFrame.new(7.1433563new(5.92716646194458, 3.06232421875, 3.0666506290466775703430176, -65.96981048583984)
local UNIT_PLACEMENT_SLOT_NUMBER = 4          3579, -65.1104507446289)

-- Colocação da Unidade
local UNIT_PLACEMENT_POSITION = Vector3.new(5.92
local UNIT_INSTANCE_ID_IN_SLOT = "u017003s1"  
local UNIT_BASE_ID = "u017003"                

-- Encontrar Unidade716646194458, 3.0666775703430176, -65.96981048583 Após Colocação
local UNIT_TO_FIND_NAME = "U0Model" 

-- Caminhos e Parâmetros de Upgrade/Outros
local UNITS_FOLDER_PATH_IN_WORKSPACE = "Units.984)
local UNIT_PLACEMENT_SLOT_NUMBER = 4          
local UNIT_INSTANCE_ID_IN_SLOT = "u017003s1"  
local UNIT_BASE_ID = "u017003"                

-- Encontrar Unidade Após Colocação
local UNIT_UFolder"
local UPGRADE_PATH_TOP = 1; local UPGRADE_PATH_BOTTOM = 2
local INITIAL_TOP_UPGRADES_COUNT = 2; local INITIAL_BOTTOM_UPGRADES_COUNT = 2   
local DELAY_BETWEEN_UPGRADE_ATTEMPTS = 1.TO_FIND_NAME = "U0Model" 

-- Caminhos e Parâmetros de Upgrade/Outros
local UNITS_FOLDER_PATH_IN_WORKSPACE = "Units.UFolder"
local UPGRADE_PATH_TOP = 1; local UPGRADE_PATH_BOTTOM = 2
local INITIAL_TOP_UP0 -- Pode ajustar conforme necessário
local DELAY_AFTER_PLACEMENT = 3           
local CHECK_UNIT_INTERVAL = 2             
local MAX_UNIT_FIND_ATTEMPTS = 5          
local REMOTE_PLACE_UNIT_PATH = "RemoteFunctions.PlaceUnitFunctions.PlaceUnit"
local REMOTE_UPGRADE_UNIT_PATH = "RemoteFunctions.UpgradeUnitFunctions.UpgradeUnit"
local REMOTE_SPEED_CHANGE_PATH =GRADES_COUNT = 2; local INITIAL_BOTTOM_UPGRADES_COUNT = 2   
local DELAY_BETWEEN_UPGRADE_ATTEMPTS = 1.0 -- Ajustado para ser um pouco mais rápido
local DELAY_AFTER_PLACEMENT = 3           
local CHECK_UNIT_INTERVAL = 2             
local MAX_ "RemoteFunctions.SpeedChange.ChangeSpeedRemoteFunction"

-- CONFIGURAÇÕES PARA REINÍCIO AUTOMÁTICO (Valores descobertos)
local VICTORY_SCREEN_NAME = "EndOfGameGUI"                -- Nome da ScreenGui de fim de jogo
local REPRODUCE_BUTTON_VISUAL_NAME = "ReproduceButtonUNIT_FIND_ATTEMPTS = 5          
local REMOTE_PLACE_UNIT_PATH = "RemoteFunctions.PlaceUnitFunctions.PlaceUnit"
local REMOTE_UPGRADE_UNIT_PATH = "RemoteFunctions.UpgradeUnitFunctions.UpgradeUnit"
local REMOTE_SPEED_CHANGE_PATH = "RemoteFunctions.SpeedChange.Change"    -- (!!) NOME VISUAL DO BOTÃO "REPRODUZIR" DENTRO DA EndOfGameGUI (!!) - VOCÊ PRECISA CONFIRMAR ESTE NOME
local REMOTE_PLAY_AGAIN_SpeedRemoteFunction"

-- CONFIGURAÇÕES PARA REINÍCIO AUTOMÁTICO (ATUALIZADAS)
local VICTORY_SCREEN_GUI_NAME = "EndOfGameGUI"            -- Nome da ScreenGui que você descobriu!PATH = "RemoteEvents.UIRemoteEvents.PostEndGameClient" 
local PLAY_AGAIN_ARG
local REPRODUCE_BUTTON_VISUAL_NAME = "ReproduceButton"    -- (!!) NOME VISUMENT = "replay"                      
local CHECK_FOR_VICTORY_SCREEN_INTERVAL = 2 -- AUAL DO BOTÃO 'REPRODUZIR' DENTRO DA EndOfGameGUI (!!)
                                                          -- Você precisa cada quantos segundos verificar a tela de vitória APÓS o loop de upgrade parar
local MAX_WAIT_FOR_ encontrar o nome exato deste botão no Explorer.
local REMOTE_PLAY_AGAIN_PATH = "RemoteEvents.UIRemoteEvents.PostEndGameClient" -- Do seu spy
local PLAY_AGAIN_ARGUMENT = "replayVICTORY_SCREEN = 45      -- Segundos máximos para esperar pela tela de vitória
local MAX_FAILS"                      -- Do seu spy

local CHECK_FOR_VICTORY_UI_INTERVAL = 1  -- Verifica_CONTINUOUS_LOG_THRESHOLD = 10 -- Quantas falhas no upg contínuo antes de assumir que está maxed e sair do CUL
print("FARM V0.9: Configs carregadas.") a UI de vitória a cada X segundos APÓS CUL
local MAX_WAIT_FOR_VICTORY

--====================================================================================
-- SERVIÇOS E VARIÁVEIS GLOBAIS
--====================================================================================
local Players=game:GetService("Players"); local Workspace=game:GetService("Workspace"); local_UI = 45       -- Segundos máximos para esperar pela UI de vitória
local MAX_CUL_FAILS_ ReplicatedStorage=game:GetService("ReplicatedStorage"); local RunService=game:GetService("RunService")
TO_ASSUME_MAXED = 15 -- Se o upg contínuo do topo falhar X vezes, assumelocal LocalPlayer=Players.LocalPlayer; if not LocalPlayer then error("FATAL: No LocalPlayer") end; local Player que está maxed e CUL pode parar.
print("FARM V0.9: Configs carregadas.")Gui=LocalPlayer:WaitForChild("PlayerGui"); if not PlayerGui then error("FATAL: No PlayerGui

--====================================================================================
-- SERVIÇOS E VARIÁVEIS GLOBAIS
") end
local character,humanoidRootPart,unitsFolderInstance,targetUnitInstance=nil,nil,nil,nil;--====================================================================================
local Players=game:GetService("Players"); local Workspace=game:GetService("Workspace"); local 
local stopAllLoops = false -- Flag global para parar tudo se necessário (não usado ativamente para parar pelo ReplicatedStorage=game:GetService("ReplicatedStorage")
local LocalPlayer=Players.LocalPlayer; if not LocalPlayer then usuário neste script)
print("FARM V0.9: Serviços e globais ok.")

--================================================================ error("FATAL: No LocalPlayer") end
local PlayerGui=LocalPlayer:WaitForChild("PlayerGui");====================
-- FUNÇÕES AUXILIARES (customSplit, getRemote com cache)
--====================================================================================
 if not PlayerGui then error("FATAL: No PlayerGui") end
local character,humanoidRootPart,local function customSplit(s, sep) if type(s)~="string" or type(sep)~="stringunitsFolderInstance,targetUnitInstance=nil,nil,nil,nil; 
local stopAllLoops = false" then return {} end; if sep=="" then return {s} end; local r={}; local ci= -- Flag global para parar todos os loops se necessário
print("FARM V0.9: Serviços e globais ok1; while true do local si,ei=string.find(s,sep,ci,true); if not.")

--====================================================================================
-- FUNÇÕES AUXILIARES (customSplit, getRemote com cache)
-- si then table.insert(r,string.sub(s,ci)); break end; table.insert(r,string.====================================================================================
local function customSplit(s, sep) if type(s)~="string"sub(s,ci,si-1)); ci=ei+1; if ci>#s and si then or type(sep)~="string" then return {} end; if sep=="" then return {s} end; table.insert(r,""); break end end; return r end
local remoteCache={}; local function getRemote( local r={}; local ci=1; while true do local si,ei=string.find(s,sepfp) if remoteCache[fp]==false then return nil elseif remoteCache[fp] then return remoteCache[fp,ci,true); if not si then table.insert(r,string.sub(s,ci)); break end;] end; print("V0.9 getRemote: "..tostring(fp)); if type(fp)~=" table.insert(r,string.sub(s,ci,si-1)); ci=ei+1;string" then warn("getRemote: Path non-string"); remoteCache[fp]=false; return nil end; local pp=customSplit(fp,"."); if not pp or #pp==0 then warn("getRemote: customSplit fail if ci>#s and si then table.insert(r,""); break end end; return r end
local remoteCache={}; local function getRemote(fp) if remoteCache[fp]==false then return nil elseif remoteCache[fp] then return remoteCache[fp] end; print("V0.9 getRemote: "..tostring"); remoteCache[fp]=false; return nil end; local co=ReplicatedStorage; for _,pn in ipairs(pp) do if co and type(co.FindFirstChild)=="function" then local f=co:FindFirstChild(fp)); if type(fp)~="string" then warn("getRemote: Path non-string"); remoteCache[fp]=false; return nil end; local pp=customSplit(fp,"."); if not pp or #pp==0 then warn("getRemote: customSplit fail"); remoteCache[fp]=false; return nil end; local co=Replicated(pn,3); if not f then warn("getRemote: Part NF: "..pn.." in "..co:GetFullName()); remoteCache[fp]=false; return nil end; co=f else warn("getRemote: Invalid CO for "..pn); remoteCache[fp]=false; return nil end end; if co then print("V0.9 getRemote: Found: "..co:GetFullName().." ("..co.ClassName..")"); remoteCache[fp]=co else warnStorage; for _,pn in ipairs(pp) do if co and type(co.FindFirstChild)=="function" then local f=co:FindFirstChild(pn,3); if not f then warn("getRemote: Part NF: "..pn.." in "..co:GetFullName()); remoteCache[fp]=false; return nil end; co=f else warn("getRemote: Invalid CO for "..pn); remoteCache[fp]=false; return nil end end; if co then print("V0.("V0.9 getRemote: Not Found: "..fp); remoteCache[fp]=false end; return co end

--====================================================================================
-- FUNÇÕES DE JOGO (Baseadas no seu V0.5, com logs atualizados para V0.9)
--====================================================================================
local function initializePlayerAndCharacter() print("V0.9 Init P&C"); character=LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait();if not character then print("ERR:NoC");return false end;humanoidRootPart=character:WaitForChild("HumanoidRoot9 getRemote: Found: "..co:GetFullName().." ("..co.ClassName..")"); remoteCache[fp]=co else warn("V0.9 getRemote: Not Found: "..fp); remoteCache[fp]=false end; return co end

--====================================================================================
-- FUNÇÕES DE JOGO (Baseadas no seu V0.5 funcional)
--====================================================================================
local function initializePlayerAndCharacter() print("V0.9 Init P&C");character=LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait();if not character thenPart",20);if not humanoidRootPart then print("ERR:NoHRP");return false end;print("OK:P&C&HRP init");return true end
local function executeTeleport() print("V0.9 TP");if not humanoidRootPart then print("ERR:HRPnilTP");return false end;local s,e=pcall(function()humanoidRootPart.CFrame=TARGET_CFRAME end);if s then print("OK:TPsent.Pos:"..tostring(humanoidRootPart.Position));return true else print print("ERR:NoC");return false end;humanoidRootPart=character:WaitForChild("HumanoidRootPart",20);if not humanoidRootPart then print("ERR:NoHRP");return false end;print("OK:P&C&HRP init");return true end
local function executeTeleport() print("V0.9 TP");if not humanoidRootPart then print("ERR:HRPnilTP");return false end;local s,e=pcall(function()humanoidRootPart.CFrame=TARGET_CFRAME end);if s then print("OK:TPsent.Pos:"..tostring(humanoidRootPart.Position));return true else print("("ERR:TPfail:"..tostring(e));return false end end
local function findUnitsFolder() print("V0.9 FindUF");local p=customSplit(UNITS_FOLDER_PATH_IN_WORKSPACE,".");local c=Workspace;for _,n in ipairs(p)do if c and type(c.WaitForChild)=="function"then c=c:WaitForChild(n,10);if not c then print("ERR:UFpart'"..n.."'NF");return false end else print("ERR:InvalidObjUF");return false end end;unitsFolderInstance=c;if unitsFolderInstance then print("OK:UF:"..unitsFolderInstance:GetFullName());return true else print("ERR:UF NF");return false end end
local function setGameSpeedTo2ERR:TPfail:"..tostring(e));return false end end
local function findUnitsFolder() print("V0.9 FindUF");local p=customSplit(UNITS_FOLDER_PATH_IN_WORKSPACE,".");local c=Workspace;for _,n in ipairs(p)do if c and type(c.WaitForChild)=="function"then c=c:WaitForChild(n,10);if not c then print("ERR:UFpart'"..n.."'NF");return false end else print("ERR:InvalidObjUF");return false end end;unitsFolderInstance=c;if unitsFolderInstance then print("OK:UF:"..unitsFolderInstance:GetFullName());return true else print("ERR:UF NF");return false end end
local function setGameSpeedTo2XX() print("V0.9 setGameSpeed");local r=getRemote(REMOTE_SPEED_CHANGE_PATH);if not r or type(r.InvokeServer)~="function"then warn("Speed:RemoteInvalid");return end;local s,e=pcall(function()r:InvokeServer()end);if s then print("Speed:CmdSent")else warn("Speed:Fail:"..tostring(e))end;wait(0.5)end
local function placeUnitOnMap() print("V0.9 placeUnit");local r=getRemote(REMOTE_PLACE_UNIT_PATH);if not r or type(r.InvokeServer)~="function"then warn("PlaceU:RemoteInvalid");return false end;print("PlaceU:Slot"..UNIT_PLACEMENT_SLOT_() print("V0.9 setGameSpeed");local r=getRemote(REMOTE_SPEED_CHANGE_PATH);if not r or type(r.InvokeServer)~="function"then warn("Speed:RemoteInvalid");return end;local s,e=pcall(function()r:InvokeServer()end);if s then print("Speed:CmdSent")else warn("Speed:Fail:"..tostring(e))end;wait(0.5)end
local function placeUnitOnMap() print("V0.9 placeUnit");local r=getRemote(REMOTE_PLACE_UNIT_PATH);if not r or type(r.InvokeServer)~="function"then warn("PlaceU:RemoteInvalid");return false end;print("PlaceU:Slot"..UNIT_PLACEMENT_SLOT_NUMBERNUMBER);local a={[1]=UNIT_PLACEMENT_SLOT_NUMBER,[2]=UNIT_INSTANCE_ID_IN_SLOT,[3]=UNIT_BASE_ID,[4]=UNIT_PLACEMENT_POSITION};local s,e=pcall(function()r:InvokeServer(unpack(a))end);if s then print("PlaceU:CmdSent.Wait"..DELAY_AFTER_PLACEMENT.."s");wait(DELAY_AFTER_PLACEMENT);return true else warn("PlaceU:Fail:"..tostring(e));return false end end
local function findOrWaitForUnit() print("V0.9 findUnit:'"..UNIT_TO_FIND_NAME.."'");if not unitsFolderInstance then print("ERR:UFnil");return false end;for att=1,MAX_UNIT_FIND_ATTEMPTS do);local a={[1]=UNIT_PLACEMENT_SLOT_NUMBER,[2]=UNIT_INSTANCE_ID_IN_SLOT,[3]=UNIT_BASE_ID,[4]=UNIT_PLACEMENT_POSITION};local s,e=pcall(function()r:InvokeServer(unpack(a))end);if s then print("PlaceU:CmdSent.Wait"..DELAY_AFTER_PLACEMENT.."s");wait(DELAY_AFTER_PLACEMENT);return true else warn("PlaceU:Fail:"..tostring(e));return false end end
local function findOrWaitForUnit() print("V0.9 findUnit:'"..UNIT_TO_FIND_NAME.."'");if not unitsFolderInstance then print("ERR:UFnil");return false end;for att=1,MAX_UNIT_FIND_ATTEMPTS do targetUnitInstance=unitsFolderInstance:FindFirstChild(UNIT_TO_FIND_NAME);if target targetUnitInstance=unitsFolderInstance:FindFirstChild(UNIT_TO_FIND_NAME);if targetUnitInstance and targetUnitInstance:IsA("Model")then print("OK:Unit'"..UNIT_TO_FIND_NAME.."'found:"..targetUnitInstance:GetFullName());return true else if targetUnitInstance then print("WARN:Obj'"..UNIT_TO_FIND_NAME.."'foundNotModel:"..targetUnitInstance.ClassName)else print("INFO:Unit'"..UNIT_TO_FIND_NAME.."'NF.Att"..att)end end;if att<MAX_UNIT_FIND_ATTEMPTS then wait(CHECK_UNIT_INTERVAL)end end;print("ERR:Unit'"..UNIT_TO_FIND_NAME.."'NOTfound");targetUnitInstance=nil;return false end
local upgradeUnitRemoteFunc=nil;local function performSingleUpgrade(uM,uP)if not upgradeUnitInstance and targetUnitInstance:IsA("Model")then print("OK:Unit'"..UNIT_TO_FIND_NAME.."'found:"..targetUnitInstance:GetFullName());return true else if targetUnitInstance then print("WARN:Obj'"..UNIT_TO_FIND_NAME.."'foundNotModel:"..targetUnitInstance.ClassName)else print("INFO:Unit'"..UNIT_TO_FIND_NAME.."'NF.Att"..att)end end;if att<MAX_UNIT_FIND_ATTEMPTS then wait(CHECK_UNIT_INTERVAL)end end;print("ERR:Unit'"..UNIT_TO_FIND_NAME.."'NOTfound");targetUnitInstance=nil;return false end
local upgradeUnitRemoteFunc=nil;local function performSingleUpgrade(uM,uP)if not upgradeUnitRemoteFunc then print("V0.9PSU:GetRemote");upgradeUnitRemoteFunc=getRemote(REMOTE_UPGRADE_UNIT_PATH);if not upgradeUnitRemoteFunc or type(upgradeUnitRemoteFunc.InvokeServer)~="function"then warn("PSU:InvalidRemote");upgradeUnitRemoteFunc=nil;return falseUnitRemoteFunc then print("V0.9PSU:GetRemote");upgradeUnitRemoteFunc=getRemote(REMOTE_UPGRADE_UNIT_PATH);if not upgradeUnitRemoteFunc or type(upgradeUnitRemoteFunc.InvokeServer)~="function"then warn("PSU:InvalidRemote");upgradeUnitRemoteFunc=nil;return false end;print("V0.9PSU:RemoteCached")end;if not upgradeUnitRemoteFunc then return false end;print("V0.9PSU:Upg "..uM.Name..",P"..uP);local s,r=pcall(function()return upgradeUnitRemoteFunc:InvokeServer(uM,uP)end);if s then if r==false then print("V0.9PSU:UPG_NEGADO_SV "..uM.Name..",P"..uP);return false end;print("V0.9PSU:UPG_SUCESSO "..uM.Name..",P"..uP..".Res:"..tostring(r));return true else warn("V0.9PSU:ERR_InvokeServer:"..tostring(r));return false end end

--====================================================================================
-- LOOP DE UPGRADE CONTÍNU end;print("V0.9PSU:RemoteCached")end;if not upgradeUnitRemoteFunc then return false end;print("V0.9PSU:Upg"..uM.Name..",P"..uP);local s,r=pcall(function()return upgradeUnitRemoteFunc:InvokeServer(uM,uP)end);if s then if r==false then print("V0.9PSU:UPG_NEGADO_SV "..uM.Name..",P"..uP);return false end;print("V0.9PSU:UPG_SUCESSO "..uM.Name..",P"..uP..".Res:"..tostring(r));return true else warn("V0.9PSU:ERR_InvokeServer:"..tostring(r));return false end end

--====================================================================================
-- LOOP DE UPGRADE CONTÍNUO (MODIFICADO PARA SAIR APÓS FALHAS CONSECUTIVAS NO TOPO)
--====================================================================================
local function continuousUpgradeLoop() 
    if not targetUnitInstance then print("ERR:NoUnitCUL");return end
    print("V0.9 CUL:StartingFor "..targetUnitInstance.Name)
    local tUO (MODIFICADO PARA SAIR APÓS FALHAS CONSECUTIVAS)
--====================================================================================
local function continuousUpgradeLoop() 
    if not targetUnitInstance then print("V0.9 CUL ERR:NoUnitCUL");return end
    print("V0.9 CUL:Start "..targetUnitInstance.Name)
    local tU,bU,iPC,cUT,iter,cTF=0,0,false,false,0,0
    if type(tU)~="number"then tU=0 end; if type(bU)~="number"then bU=0 end

    while not stopAllLoops and targetUnitInstance and targetUnitInstance.Parent do 
        iter=iter+1; print("---V0.9 CUL:Loop#"..iter.." ---")
        local upgradedThisCycle=false
        if not iPC then 
            if type(INITIAL_TOP_UPGRADES_COUNT)~="number" or type(INITIAL_BOTTOM_UPGRADES_COUNT)~="number" then print("ERR:CULConstsInvalid");break end
            if tU<INITIAL_,bU,iPC,cUT,iter,consecutiveTopFails = 0,0,false,false,0,0
    
    while not stopAllLoops and targetUnitInstance and targetUnitInstance.Parent do 
        iter=iter+1; print("---V0.9 CUL:Loop#"..iter.." ---")
        local upgradedThisCycle = false
        if not iPC then 
            if tU < INITIAL_TOP_UPGRADES_COUNT then 
                if performSingleUpgrade(targetUnitInstance,UPGRADE_PATH_TOP)then tU=tU+1;upgradedThisCycle=true;consecutiveTopFails=0 
                else print("V0.9 CUL: FailUpgTopInit (tU="..tU..")") end 
            elseif bU < INITIAL_BOTTOM_UPGRADES_COUNT then 
                if performSingleUpgrade(targetUnitInstance,UPGRADE_PATH_BOTTOM)then bU=bU+1;upgradedThisCycle=true 
                else print("V0.9 CUL: FailUpgBottomInit (TOP_UPGRADES_COUNT then 
                if performSingleUpgrade(targetUnitInstance,UPGRADE_PATH_TOP)then tU=tU+1;upgradedThisCycle=true;cTF=0 else print("V0.9 CUL:FailUpgTopInit (tU="..tU..")") end 
            elseif bU<INITIAL_BOTTOM_UPGRADES_COUNT then 
                if performSingleUpgrade(targetUnitInstance,UPGRADE_PATH_BOTTOM)then bU=bU+1;upgradedThisCycle=true else print("V0.9 CUL:FailUpgBottomInit (bU="..bU..")") end 
            else iPC=true;cUT=true;print("V0.9 CUL:InitialPhaseDone.ContinuousTOP");cTF=0 end 
        end
        if cUT then 
            if performSingleUpgrade(targetUnitInstance,UPGRADE_PATH_TOP)then upgradedThisCycle=true;cTF=0 
            else 
                cTF=cTF+1;print("V0.9 CUL:FailContTOP.Fails:"..cTF)
                if cTF >= MAX_FAILS_CONTINUOUS_LOG_bU="..bU..")") end 
            else iPC=true;cUT=true;print("V0.9 CUL:InitialPhaseDONE.ContinuousTOP");consecutiveTopFails=0 end 
        end
        if cUT then 
            if performSingleUpgrade(targetUnitInstance,UPGRADE_PATH_TOP)then 
                upgradedThisCycle=true;consecutiveTopFails=0 
            else 
                consecutiveTopFails=consecutiveTopFails+1;print("V0.9 CUL:FailContTOP.Fails:"..consecutiveTopFails)
                if consecutiveTopFails >= MAX_CUL_FAILS_TO_ASSUME_MAXED then
                    print("V0.9 CUL: Atingido max de falhas ("..MAX_CUL_FAILS_TO_ASSUME_MAXED..") no upg contínuo do TOPO. Assumindo caminho maxed/fim de fase. Saindo do CUL.")
                    break -- Sai do while loop do CUL
                end
            end 
        end
        wait(THRESHOLD then
                    print("V0.9 CUL: Atingido máx de falhas ("..MAX_FAILS_CONTINUOUS_LOG_THRESHOLD..") no upg contínuo do TOPO. Assumindo caminho maxed/fim da fase de combate. Saindo do CUL.")
                    break -- Sai do while loop do CUL
                end
            end 
        end
        wait(DELAY_BETWEEN_UPGRADE_ATTEMPTS)
    end
    print("V0.9 CUL:ENDED for "..(targetUnitInstance and targetUnitInstance.Name or "UnitN/A").." (Reason: stop="..tostring(stopAllLoops).." or unit/parent nil or max fails)") 
end

--====================================================================================
-- FUNÇÃO DE REINÍCIO DE FASE (Detecta UI e dispara Remote)
--====================================================================================
local function checkForAndPressPlayAgain() 
    print("V0.9 CPA: VerificandoDELAY_BETWEEN_UPGRADE_ATTEMPTS)
    end
    print("V0.9 CUL:ENDED for "..(targetUnitInstance and targetUnitInstance.Name or "UnitN/A").." (Reason: stopAllLoops="..tostring(stopAllLoops).." or unit/parent nil or max fails)")
end

--====================================================================================
-- FUNÇÃO DE REINÍCIO DE FASE (VERIFICA UI ESPECÍFICA)
--====================================================================================
local function checkForAndPressPlayAgain() 
    print("V0.9 CPA: Verificando UI de Vitória: '"..VICTORY_SCREEN_GUI_NAME.."' com botão '"..REPRODUCE_BUTTON_VISUAL_NAME.."'")
    local victoryScreen = PlayerGui:FindFirstChild(VICTORY_SCREEN_GUI_NAME, true) 

    if not victory TelaDeVitoria: '"..VICTORY_SCREEN_NAME.."'")
    local victoryScreen = PlayerGui:FindFirstChild(VICTORY_SCREEN_NAME, true) 

    if not victoryScreen then print("V0.9 CPA: "..VICTORY_SCREEN_NAME.." NÃO ENCONTRADA EM PLAYERGUI."); return false end
    if not victoryScreen.Enabled then print("V0.9 CPA: "..VICTORY_SCREEN_NAME.." encontrada, MAS NÃO ESTÁ HABILITADA (.Enabled=false)."); return false end
    
    print("V0.9 CPA: TelaDeVitoria '"..VICTORY_SCREEN_NAME.."' ENCONTRADA e HABILITADA!")
    
    local reproduceButtonVisual = victoryScreen:FindFirstChild(REPRODUCE_BUTTON_VISUAL_NAME, true)
    if not reproduceButtonVisual or not reproduceButtonVisual.Visible thenScreen then print("V0.9 CPA: ScreenGui '"..VICTORY_SCREEN_GUI_NAME.."' NÃO encontrada."); return false end
    if not victoryScreen.Enabled then print("V0.9 CPA: ScreenGui '"..VICTORY_SCREEN_GUI_NAME.."' encontrada, MAS .Enabled = false."); return false end
    
    print("V0.9 CPA: ScreenGui '"..VICTORY_SCREEN_GUI_NAME.."' ENCONTRADA e HABILITADA!")
    
    local reproduceButton = victoryScreen:FindFirstChild(REPRODUCE_BUTTON_VISUAL_NAME, true) -- Busca recursiva pelo botão
    if not reproduceButton then print("V0.9 CPA: Botão visual '"..REPRODUCE_BUTTON_VISUAL_NAME.."' NÃO encontrado dentro de "..VICTORY_SCREEN_GUI_NAME); return false end
    if
        print("V0.9 CPA: Botão visual '"..REPRODUCE_BUTTON_VISUAL_NAME.."' não encontrado ou não visível dentro de '"..VICTORY_SCREEN_NAME.."'.")
        return false 
    end
    print("V0.9 CPA: Botão visual '"..REPRODUCE_BUTTON_VISUAL_NAME.."' ENCONTRADO e VISÍVEL.")

    local playAgainRemote = getRemote(REMOTE_PLAY_AGAIN_PATH)
    if not playAgainRemote then warn("V0.9 CPA: Remote '"..REMOTE_PLAY_AGAIN_PATH.."' NÃO encontrado."); return false end
    
    if not playAgainRemote:IsA("RemoteEvent") then warn("V0.9 CPA: Obj em '"..REMOTE_PLAY_AGAIN_PATH.."' NÃO É RemoteEvent. É: "..play not reproduceButton.Visible then print("V0.9 CPA: Botão visual '"..REPRODUCE_BUTTON_VISUAL_NAME.."' encontrado, MAS .Visible = false"); return false end
    
    print("V0.9 CPA: Botão visual '"..REPRODUCE_BUTTON_VISUAL_NAME.."' ENCONTRADO e VISÍVEL!")

    local playAgainRemote = getRemote(REMOTE_PLAY_AGAIN_PATH)
    if not playAgainRemote then warn("V0.9 CPA: Remote '"..REMOTE_PLAY_AGAIN_PATH.."' NÃO encontrado."); return false end
    
    if not playAgainRemote:IsA("RemoteEvent") then warn("V0.9 CPA: Obj em '"..REMOTE_PLAY_AGAIN_PATH..AgainRemote.ClassName); return false end
            
    print("V0.9 CPA: RemoteEvent '"..REMOTE_PLAY_AGAIN_PATH.."' encontrado. Disparando com argumento: '" .. PLAY_AGAIN_ARGUMENT .. "'")
    local success, err = pcall(function() playAgainRemote:FireServer(PLAY_AGAIN_ARGUMENT) end)
    
    if success then print("V0.9 CPA: RemoteEvent disparado COM SUCESSO!"); return true 
    else warn("V0.9 CPA: ERRO ao disparar RemoteEvent: "..tostring(err)); return false end 
end


--====================================================================================
-- LOOP DE JOGO PRINCIPAL (MASTER LOOP)
--====================================================================================
local function master"' NÃO É RemoteEvent. É: "..playAgainRemote.ClassName); return false end
            
    print("V0.9 CPA: RemoteEvent '"..REMOTE_PLAY_AGAIN_PATH.."' encontrado. Disparando com argumento: '" .. PLAY_AGAIN_ARGUMENT .. "'")
    local success, err = pcall(function() playAgainRemote:FireServer(PLAY_AGAIN_ARGUMENT) end)
    
    if success then print("V0.9 CPA: RemoteEvent disparado COM SUCESSO!"); return true 
    else warn("V0.9 CPA: ERRO ao disparar RemoteEvent: "..tostring(err)); return false end 
end


--================================================GameLoop()
    print("FARM V0.9: MGL Init...")
    stopAllLoops = false 
    while not stopAllLoops do 
        print("=====FARM V0.9 MGL: NEW ROUND=====")
        targetUnitInstance=nil; remoteCache={}; 
        
        if not initializePlayerAndCharacter()then print("CRIT MGL:PInitFail.Stop.");stopAllLoops=true;break end
        if not executeTeleport()then print("CRIT MGL:TPFail.Stop.");stopAllLoops=true;break end
        set====================================
-- LOOP DE JOGO PRINCIPAL (MASTER LOOP)
--====================================================================================
local function masterGameLoop()
    print("FARM V0.9: MGL Init...")
    stopAllLoops = false 
    while not stopAllLoops do 
        print("=====FARM V0.9 MGL: NEW ROUND=====")
        targetUnitInstance=nil; remoteCache={}; 
        
        if not initializePlayerAndCharacter()then print("CRIT MGL:PInitFail.Stop.");stopAllLoops=trueGameSpeedTo2X()
        if not placeUnitOnMap()then print("CRIT MGL:PlaceFail.NewRnd10s");wait(10);continue end
        wait(1);if not findUnitsFolder()then print("CRIT MGL:UFFail.NewRnd10s");wait(10);continue end
        
        if findOrWaitForUnit()then 
            print("INFO MGL:UnitFound,startingCUL...");
            local ugCo = coroutine.create(continuousUpgradeLoop)
            coroutine.resume(ugCo)
            ;break end
        if not executeTeleport()then print("CRIT MGL:TPFail.Stop.");stopAllLoops=true;break end
        setGameSpeedTo2X()
        if not placeUnitOnMap()then print("CRIT MGL:PlaceFail.NewRnd10s");wait(10);continue end
        wait(1);if not findUnitsFolder()then print("CRIT MGL:UFFail.NewRnd10print("INFO MGL:CULstarted.")

            -- Espera o CUL terminar (seja por max fails, unidade sumir, ou stopAllLoops)
            local coStatus = coroutine.status(ugCo)
            print("INFO MGL:Aguardando CUL terminar. Status inicial: " .. coStatus)
            while cos");wait(10);continue end
        
        if findOrWaitForUnit()then 
            print("INFO MGL:UnitFound,starting CUL...");
            local upgradeCoroutine = coroutine.create(continuousStatus ~= "dead" and not stopAllLoops do
                wait(1)
                coStatus = coroutine.statusUpgradeLoop)
            coroutine.resume(upgradeCoroutine)
            print("INFO MGL:CULstarted.")

            --(ugCo)
            end
            if stopAllLoops then print("INFO MGL:stopAllLoops at Espera a corrotina de upgrade terminar
            local coStatus = coroutine.status(upgradeCoroutine)
ivado durante espera do CUL."); break end
            print("INFO MGL:CUL terminou (status final: " .. co            print("INFO MGL:Aguardando CUL terminar. Status inicial: "..coStatus)
            whileStatus .. "). Verificando tela de vitória...")

            local victoryScreenPressed = false; local waitStartTime = tick() coStatus ~= "dead" and not stopAllLoops do 
                wait(1) 
                coStatus = cor
            while not victoryScreenPressed and not stopAllLoops and (tick() - waitStartTime < MAX_WAIT_FOR_VIoutine.status(upgradeCoroutine)
            end
            if stopAllLoops then print("INFO MGL:stopCTORY_SCREEN) do
                if checkForAndPressPlayAgain() then print("INFO MGL:'Reproduzir'PRESSEDAllLoops ativado, parando espera CUL."); break end
            print("INFO MGL:CUL terminou (status:".");victoryScreenPressed=true 
                else print("INFO MGL:Tela vitória NF/botão NP.Wait..coStatus.."). Verificando tela de vitória...")

            local victoryScreenPressed = false; local waitStartTime = tick()...") end
                wait(CHECK_FOR_VICTORY_SCREEN_INTERVAL)
            end
            if
            while not victoryScreenPressed and not stopAllLoops and (tick() - waitStartTime < MAX_WAIT_FOR_VI not victoryScreenPressed and not stopAllLoops then print("WARN MGL:TimeoutVS ou botão não acionado.")CTORY_UI) do
                if checkForAndPressPlayAgain()then 
                    print("INFO MGL:'Reproduzir' ACIONADO.")
                    victoryScreenPressed=true 
                else 
                    print("INFO M 
            elseif stopAllLoops then print("INFO MGL:stopAllLoops durante espera VS."); break end
        else GL:Tela de vitória não detectada/botão não acionado. Esperando...")
                end
                wait
            print("CRIT MGL:UnitNOTfound.NewRnd10s");wait(10)(CHECK_FOR_VICTORY_UI_INTERVAL)
            end
            if not victoryScreenPressed and not stop
        end
        
        if stopAllLoops then print("INFO MGL:stopAllLoops,breakingMAllLoops then print("WARN MGL:Timeout esperando tela de vitória.") 
            elseif stopAllLoops then printGL.");break end
        print("FARM V0.9 MGL:EndOfRnd.Wait~7s para trans("INFO MGL:stopAllLoops durante espera VS."); break end
        else 
            print("CRITição...")
        wait(7)
    end
    print("FARM V0.9 FINAL:MGL MGL:UnitNOTfound.NewRnd10s");wait(10)
        end
        
        ifended.")
end

local s_main,e_main=pcall(masterGameLoop);if not s_main stopAllLoops then print("INFO MGL:stopAllLoops ativado, quebrando MGL.");break end
        print then warn("FATAL ERR MGL():",e_main)end
print("FARM V0.9(via("FARM V0.9 MGL:EndOfRnd.Wait~7s");wait(7)
 HttpGet):ExecTerminated.")
