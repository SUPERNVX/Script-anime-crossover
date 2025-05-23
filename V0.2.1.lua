--[[
    SCRIPT DE FARM (V0.4 - LOOP DE UPGRADE CONTÍNUO)
    - Teleporta
    - Encontra a unidade "U0Model" (deve existir no mapa)
    - Entra em um loop para tentar upgrades continuamente na sequência definida.
]]

print("FARM V0.4 (via HttpGet): Script carregado e iniciando...")
wait(1)

--====================================================================================
-- CONFIGURAÇÕES
--====================================================================================
local TARGET_CFRAME = CFrame.new(7.1433563232421875, 3.066650629043579, -65.1104507446289)
local UNIT_TO_FIND_NAME = "U0Model" 
local UNITS_FOLDER_PATH_IN_WORKSPACE = "Units.UFolder"
local UPGRADE_PATH_TOP = 1
local UPGRADE_PATH_BOTTOM = 2
local INITIAL_TOP_UPGRADES_COUNT = 2      -- Quantos upgrades fazer inicialmente no caminho de cima
local INITIAL_BOTTOM_UPGRADES_COUNT = 2   -- Quantos upgrades fazer inicialmente no caminho de baixo
-- DEPOIS DESTES, o script focará em upar continuamente o caminho de CIMA.
local DELAY_BETWEEN_UPGRADE_ATTEMPTS = 1  -- Delay entre cada TENTATIVA de upgrade no loop
local CHECK_UNIT_INTERVAL = 5             -- Intervalo em segundos para verificar a unidade se não encontrada inicialmente
local MAX_UNIT_FIND_ATTEMPTS = 6          -- Tentar encontrar a unidade por (6 * 5 = 30 segundos)
local REMOTE_UPGRADE_UNIT_PATH = "RemoteFunctions.UpgradeUnitFunctions.UpgradeUnit"
print("FARM V0.4: Configs carregadas. REMOTE_UPGRADE_UNIT_PATH: '" .. REMOTE_UPGRADE_UNIT_PATH .. "'")

--====================================================================================
-- SERVIÇOS E VARIÁVEIS GLOBAIS
--====================================================================================
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService") -- Para um loop mais preciso se necessário

local player = Players.LocalPlayer
local character = nil
local humanoidRootPart = nil
local unitsFolderInstance = nil
local targetUnitInstance = nil      -- A unidade que vamos upar
local stopUpgradeLoop = false       -- Variável para parar o loop externamente se necessário
print("FARM V0.4: Serviços e globais ok.")

--====================================================================================
-- FUNÇÕES AUXILIARES (customSplit, getRemote - mesmas de antes)
--====================================================================================
local function customSplit(s, sep) if type(s)~="string" or type(sep)~="string" then return {} end; if sep=="" then return {s} end; local r={}; local ci=1; while true do local si,ei=string.find(s,sep,ci,true); if not si then table.insert(r,string.sub(s,ci)); break end; table.insert(r,string.sub(s,ci,si-1)); ci=ei+1; if ci>#s and si then table.insert(r,""); break end end; return r end
local function getRemote(fp) print("V0.4 getRemote: "..tostring(fp)); if type(fp)~="string" then warn("getRemote: Path non-string"); return nil end; local pp=customSplit(fp,"."); if not pp or #pp==0 then warn("getRemote: customSplit fail"); return nil end; local co=ReplicatedStorage; for _,pn in ipairs(pp) do if co and type(co.FindFirstChild)=="function" then local f=co:FindFirstChild(pn,5); if not f then warn("getRemote: Part NF: "..pn); return nil end; co=f else warn("getRemote: Invalid CO or no FindFirstChild for "..pn); return nil end end; if co then print("V0.4 getRemote: Found: "..co:GetFullName().." ("..co.ClassName..")") else warn("V0.4 getRemote: Not Found: "..fp) end; return co end

--====================================================================================
-- FUNÇÕES DE INICIALIZAÇÃO E AÇÃO
--====================================================================================
local function initializePlayerAndCharacter() print("V0.4 Init P&C..."); if not player then print("ERR: No P"); return false end; character=player.Character or player.CharacterAdded:Wait(); if not character then print("ERR: No C"); return false end; humanoidRootPart=character:WaitForChild("HumanoidRootPart",20); if not humanoidRootPart then print("ERR: No HRP"); return false end; print("OK: P&C&HRP init."); return true end
local function executeTeleport() print("V0.4 TP..."); if not humanoidRootPart then print("ERR: HRP nil for TP"); return false end; local s,e=pcall(function() humanoidRootPart.CFrame=TARGET_CFRAME end); if s then print("OK: TP sent. Pos:"..tostring(humanoidRootPart.Position)); return true else print("ERR: TP fail: "..tostring(e)); return false end end
local function findUnitsFolder() print("V0.4 Find UF..."); local p=customSplit(UNITS_FOLDER_PATH_IN_WORKSPACE,"."); local c=Workspace; for _,n in ipairs(p) do if c and type(c.WaitForChild)=="function" then c=c:WaitForChild(n,10); if not c then print("ERR: UF part '"..n.."' not found."); return false end else print("ERR: Invalid obj for UF."); return false end end; unitsFolderInstance=c; if unitsFolderInstance then print("OK: UF: "..unitsFolderInstance:GetFullName()); return true else print("ERR: UF not found."); return false end end

local function findOrWaitForUnit()
    print("V0.4 findOrWaitForUnit: Procurando unidade '" .. UNIT_TO_FIND_NAME .. "'...")
    if not unitsFolderInstance then print("ERR: Pasta de unidades é nil."); return false end

    for attempt = 1, MAX_UNIT_FIND_ATTEMPTS do
        targetUnitInstance = unitsFolderInstance:FindFirstChild(UNIT_TO_FIND_NAME)
        if targetUnitInstance and targetUnitInstance:IsA("Model") then
            print("OK: Unidade '" .. UNIT_TO_FIND_NAME .. "' encontrada: " .. targetUnitInstance:GetFullName())
            return true
        else
            if targetUnitInstance then
                print("WARN: Objeto '"..UNIT_TO_FIND_NAME.."' encontrado mas não é Model: "..targetUnitInstance.ClassName .. ". Tentativa " .. attempt .. "/" .. MAX_UNIT_FIND_ATTEMPTS)
            else
                print("INFO: Unidade '" .. UNIT_TO_FIND_NAME .. "' não encontrada. Tentativa " .. attempt .. "/" .. MAX_UNIT_FIND_ATTEMPTS .. ". Esperando " .. CHECK_UNIT_INTERVAL .. "s...")
            end
        end
        if attempt < MAX_UNIT_FIND_ATTEMPTS then wait(CHECK_UNIT_INTERVAL) end
    end
    print("ERR: Unidade '" .. UNIT_TO_FIND_NAME .. "' NÃO encontrada após " .. MAX_UNIT_FIND_ATTEMPTS .. " tentativas.")
    targetUnitInstance = nil
    return false
end

local upgradeUnitRemoteFunc = nil -- Cache do remote de upgrade
local function performSingleUpgrade(unitModel, upgradePath)
    if not upgradeUnitRemoteFunc then -- Obter e cachear o remote na primeira chamada
        print("V0.4 performSingleUpgrade: Obtendo remote de upgrade pela primeira vez...")
        upgradeUnitRemoteFunc = getRemote(REMOTE_UPGRADE_UNIT_PATH)
        if not upgradeUnitRemoteFunc or type(upgradeUnitRemoteFunc.InvokeServer) ~= "function" then
            warn("performSingleUpgrade: Remote de upgrade inválido ou não encontrado. Upgrades não funcionarão.")
            upgradeUnitRemoteFunc = nil -- Anula para não tentar usar um remote inválido
            return false
        end
        print("V0.4 performSingleUpgrade: Remote de upgrade cacheado com sucesso.")
    end
    
    if not upgradeUnitRemoteFunc then return false end -- Se o cache falhou, não prossiga

    -- print("V0.4 performSingleUpgrade: Tentando para "..unitModel.Name..", path "..upgradePath) -- Log menos verboso
    local success, result = pcall(function()
        return upgradeUnitRemoteFunc:InvokeServer(unitModel, upgradePath)
    end)

    if success then
        if result == false then
            -- print("V0.4 performSingleUpgrade: Upgrade falhou (servidor retornou false - sem dinheiro/max level?).")
            return false -- Não é um erro crítico, apenas o upgrade não pôde ser feito
        end
        print("V0.4 performSingleUpgrade: Upgrade SUCESSO para "..unitModel.Name..", path "..upgradePath..". Result: "..tostring(result))
        return true
    else
        warn("V0.4 performSingleUpgrade: ERRO CRÍTICO ao tentar InvokeServer: " .. tostring(result))
        return false -- Erro na chamada do remote
    end
end

--====================================================================================
-- LOOP DE UPGRADE CONTÍNUO
--====================================================================================
local function continuousUpgradeLoop()
    if not targetUnitInstance then print("ERR: Nenhuma unidade para o loop de upgrade."); return end
    print("FARM V0.4: Iniciando LOOP DE UPGRADE CONTÍNUO para " .. targetUnitInstance.Name)

    local topUpgradesDone = 0
    local bottomUpgradesDone = 0
    local initialPhaseComplete = false
    local continuouslyUpgradingTop = false

    while not stopUpgradeLoop and targetUnitInstance and targetUnitInstance.Parent do
        if not initialPhaseComplete then
            -- Fase 1: INITIAL_TOP_UPGRADES_COUNT no caminho de cima
            if topUpgradesDone < INITIAL_TOP_UPGRADES_COUNT then
                if performSingleUpgrade(targetUnitInstance, UPGRADE_PATH_TOP) then
                    topUpgradesDone = topUpgradesDone + 1
                else
                    -- Se falhou (sem dinheiro/max), pode precisar esperar ou o path está maxed para esta fase
                    -- print("Falha no upgrade inicial de cima, esperando...")
                end
            -- Fase 2: INITIAL_BOTTOM_UPGRADES_COUNT no caminho de baixo
            elseif bottomUpgradesDone < INITIAL_BOTTOM_UPGRADES_COUNT then
                 if performSingleUpgrade(targetUnitInstance, UPGRADE_PATH_BOTTOM) then
                    bottomUpgradesDone = bottomUpgradesDone + 1
                else
                    -- print("Falha no upgrade inicial de baixo, esperando...")
                end
            else
                initialPhaseComplete = true
                continuouslyUpgradingTop = true -- Mover para upgrade contínuo do topo
                print("FARM V0.4: Fase inicial de upgrades concluída. Movendo para upgrade contínuo do topo.")
            end
        end

        if continuouslyUpgradingTop then
            if not performSingleUpgrade(targetUnitInstance, UPGRADE_PATH_TOP) then
                -- Se falhou (sem dinheiro/max no path), apenas espera e tenta de novo
                -- print("Falha no upgrade contínuo do topo, esperando...")
            end
        end
        
        wait(DELAY_BETWEEN_UPGRADE_ATTEMPTS) -- Espera antes da próxima tentativa
    end
    if stopUpgradeLoop then print("FARM V0.4: Loop de upgrade parado por comando.") end
    if not (targetUnitInstance and targetUnitInstance.Parent) then print("FARM V0.4: Loop de upgrade parado pois a unidade não existe mais.") end
end

--====================================================================================
-- EXECUÇÃO PRINCIPAL
--====================================================================================
local function main()
    print("FARM V0.4 main()..."); wait(1);
    if not initializePlayerAndCharacter() then print("CRIT: Player init fail."); return end
    if not executeTeleport() then print("CRIT: TP fail."); return end
    wait(1); 
    if not findUnitsFolder() then print("CRIT: Units folder fail."); return end
    
    if findOrWaitForUnit() then 
        print("INFO: Unidade encontrada, iniciando loop de upgrades contínuos...");
        continuousUpgradeLoop() -- Chama o loop de upgrade
    else
        print("INFO: Unidade não foi encontrada após tentativas. O script não fará upgrades.")
    end
    print("FARM V0.4 main() concluída (ou loop de upgrade interrompido).")
end

-- Protegendo a chamada principal
local success_main, error_main = pcall(main)
if not success_main then
    warn("ERRO FATAL NA EXECUÇÃO DE main(): ", error_main)
end

print("FARM V0.4 (via HttpGet): Execução do script principal (chamada a main) terminada.")
