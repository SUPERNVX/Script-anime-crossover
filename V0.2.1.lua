--[[
    SCRIPT DE FARM BÁSICO (V0.2.1 REVISITADO - PARA LOADSTRING)
    ASSUMINDO QUE A UNIDADE "U0Model" JÁ EXISTE EM Workspace.Units.UFolder
]]

-- Adicionando um print para confirmar que o script foi carregado do HttpGet
print("FARM SCRIPT (via HttpGet): Script carregado e iniciando execução...")
wait(1) -- Pequena pausa para ver o print

-- COLE AQUI O CONTEÚDO COMPLETO DO SCRIPT V0.2.1 REVISITADO
-- (ou qualquer versão que estivermos testando)
-- Exemplo:
-- print("FARM V0.2.1 REVISITADO: Script iniciado.")
--
-- --====================================================================================
-- -- CONFIGURAÇÕES
-- --====================================================================================
-- local TARGET_CFRAME = CFrame.new(7.1433563232421875, 3.066650629043579, -65.1104507446289)
-- -- ... (resto do script V0.2.1 Revisado) ...
--
-- main()
-- print("FARM SCRIPT (via HttpGet): Execução principal concluída.")

-- ###########################################################################
-- ## COLE O SCRIPT COMPLETO (EX: V0.2.1 REVISITADO) ABAIXO DESTA LINHA:   ##
-- ###########################################################################

--[[
    SCRIPT DE FARM BÁSICO (V0.2.1 REVISITADO - DEBUG DO REMOTE DE UPGRADE)
    ASSUMINDO QUE A UNIDADE "U0Model" JÁ EXISTE EM Workspace.Units.UFolder
]]

print("FARM V0.2.1 REVISITADO: Script iniciado.")

--====================================================================================
-- CONFIGURAÇÕES
--====================================================================================
local TARGET_CFRAME = CFrame.new(7.1433563232421875, 3.066650629043579, -65.1104507446289) -- Coordenadas de teleporte que funcionam
local UNIT_TO_FIND_NAME = "U0Model" 
local UNITS_FOLDER_PATH_IN_WORKSPACE = "Units.UFolder" -- Ex: Workspace.Units.UFolder
local UPGRADE_PATH_TOP = 1
local UPGRADE_PATH_BOTTOM = 2
local INITIAL_TOP_UPGRADES_COUNT = 2
local INITIAL_BOTTOM_UPGRADES_COUNT = 2
local CONTINUOUS_TOP_UPGRADES_MAX_ATTEMPTS = 15
local DELAY_BETWEEN_UPGRADES = 0.65 -- Aumentei um pouco o delay para observação
local REMOTE_UPGRADE_UNIT_PATH = "RemoteFunctions.UpgradeUnitFunctions.UpgradeUnit"
print("FARM V0.2.1 REVISITADO DEBUG: REMOTE_UPGRADE_UNIT_PATH: '" .. REMOTE_UPGRADE_UNIT_PATH .. "' (Tipo: " .. type(REMOTE_UPGRADE_UNIT_PATH) .. ")")

--====================================================================================
-- SERVIÇOS E VARIÁVEIS GLOBAIS
--====================================================================================
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local player = Players.LocalPlayer
local character = nil
local humanoidRootPart = nil
local unitsFolderInstance = nil
local targetUnitInstance = nil
print("FARM V0.2.1 REVISITADO: Serviços e globais definidos.")

--====================================================================================
-- FUNÇÃO SPLIT MANUAL (CUSTOMSPLIT)
--====================================================================================
local function customSplit(inputString, separator)
    if type(inputString) ~= "string" or type(separator) ~= "string" then return {} end; if separator == "" then return {inputString} end
    local result = {}; local currentIndex = 1
    while true do
        local startIndex, endIndex = string.find(inputString, separator, currentIndex, true)
        if not startIndex then table.insert(result, string.sub(inputString, currentIndex)); break end
        table.insert(result, string.sub(inputString, currentIndex, startIndex - 1))
        currentIndex = endIndex + 1
        if currentIndex > #inputString and startIndex then table.insert(result, ""); break end
    end
    return result
end

--====================================================================================
-- FUNÇÃO GETREMOTE
--====================================================================================
local function getRemote(fullPathString)
    print("FARM V0.2.1 REVISITADO getRemote: Tentando obter '" .. tostring(fullPathString) .. "'")
    if type(fullPathString) ~= "string" then warn("getRemote: Caminho não é string."); return nil end
    local pathParts = customSplit(fullPathString, ".")
    if not pathParts or #pathParts == 0 then warn("getRemote: customSplit falhou para o caminho."); return nil end
    local currentObject = ReplicatedStorage
    for _, partName in ipairs(pathParts) do
        if currentObject and type(currentObject.FindFirstChild) == "function" then
            local foundPart = currentObject:FindFirstChild(partName, 10)
            if not foundPart then warn("getRemote: Parte do caminho NÃO encontrada: '" .. partName .. "' em '" .. currentObject:GetFullName() .. "'."); return nil end
            currentObject = foundPart
        else warn("getRemote: currentObject inválido ou sem FindFirstChild. Parte: " .. partName); return nil end
    end
    if currentObject then print("FARM V0.2.1 REVISITADO getRemote: Encontrado: " .. currentObject:GetFullName() .. " (Tipo: " .. currentObject.ClassName .. ")") else warn("FARM V0.2.1 REVISITADO getRemote: Não encontrado: " .. fullPathString) end
    return currentObject
end

--====================================================================================
-- FUNÇÕES PRINCIPAIS DE INICIALIZAÇÃO E AÇÃO
--====================================================================================
local function initializePlayerAndCharacter() print("FARM V0.2.1R Init P&C..."); if not player then print("ERR: No P"); return false end; character=player.Character or player.CharacterAdded:Wait(); if not character then print("ERR: No C"); return false end; humanoidRootPart=character:WaitForChild("HumanoidRootPart",20); if not humanoidRootPart then print("ERR: No HRP"); return false end; print("OK: P&C&HRP init."); return true end
local function executeTeleport() print("FARM V0.2.1R TP..."); if not humanoidRootPart then print("ERR: HRP nil for TP"); return false end; local s,e=pcall(function() humanoidRootPart.CFrame=TARGET_CFRAME end); if s then print("OK: TP sent. Pos:"..tostring(humanoidRootPart.Position)); return true else print("ERR: TP fail: "..tostring(e)); return false end end
local function findUnitsFolder() print("FARM V0.2.1R Find UF..."); local p=customSplit(UNITS_FOLDER_PATH_IN_WORKSPACE,"."); local c=Workspace; for _,n in ipairs(p) do if c and type(c.WaitForChild)=="function" then c=c:WaitForChild(n,15); if not c then print("ERR: UF part '"..n.."' not found."); return false end else print("ERR: Invalid obj for UF."); return false end end; unitsFolderInstance=c; if unitsFolderInstance then print("OK: UF: "..unitsFolderInstance:GetFullName()); return true else print("ERR: UF not found."); return false end end
local function findSpecificUnit() print("FARM V0.2.1R Find SU '"..UNIT_TO_FIND_NAME.."'..."); if not unitsFolderInstance then print("ERR: UF nil for SU."); return false end; targetUnitInstance=unitsFolderInstance:WaitForChild(UNIT_TO_FIND_NAME,10); if targetUnitInstance and targetUnitInstance:IsA("Model") then print("OK: SU '"..UNIT_TO_FIND_NAME.."' found."); return true else if targetUnitInstance then print("WARN: Obj '"..UNIT_TO_FIND_NAME.."' found but not Model: "..targetUnitInstance.ClassName) else print("ERR: SU '"..UNIT_TO_FIND_NAME.."' not found.") end; targetUnitInstance=nil; return false end end

-- FUNÇÃO DE UPGRADE (COM DEBUG DETALHADO)
local function performSingleUpgrade(unitModel, upgradePath)
    print("----------------------------------------------------")
    print("FARM V0.2.1R performSingleUpgrade: PARA " .. unitModel.Name .. ", CAMINHO " .. upgradePath)
    
    local upgradeUnitRemote = getRemote(REMOTE_UPGRADE_UNIT_PATH)

    print("FARM V0.2.1R DEBUG performSingleUpgrade: Tipo de upgradeUnitRemote: " .. type(upgradeUnitRemote))
    if upgradeUnitRemote then
        print("FARM V0.2.1R DEBUG performSingleUpgrade: upgradeUnitRemote.Name: " .. tostring(upgradeUnitRemote.Name))
        print("FARM V0.2.1R DEBUG performSingleUpgrade: upgradeUnitRemote.ClassName: " .. tostring(upgradeUnitRemote.ClassName))
        if type(upgradeUnitRemote.InvokeServer) == "function" then
            print("FARM V0.2.1R DEBUG performSingleUpgrade: upgradeUnitRemote.InvokeServer É UMA FUNÇÃO.")
        else
            print("FARM V0.2.1R DEBUG performSingleUpgrade: upgradeUnitRemote.InvokeServer NÃO É UMA FUNÇÃO! É um " .. type(upgradeUnitRemote.InvokeServer))
        end
    else
        print("FARM V0.2.1R DEBUG performSingleUpgrade: upgradeUnitRemote é nil.")
    end
    print("----------------------------------------------------")
    
    if not upgradeUnitRemote or type(upgradeUnitRemote.InvokeServer) ~= "function" then
        warn("performSingleUpgrade: Remote de upgrade inválido/não encontrado/InvokeServer não é func. Abortando este upgrade.")
        return false
    end

    print("performSingleUpgrade: Tentando InvokeServer...")
    local success, result = pcall(function()
        return upgradeUnitRemote:InvokeServer(unitModel, upgradePath)
    end)

    if success then
        print("performSingleUpgrade: InvokeServer SUCESSO. Resultado do servidor: " .. tostring(result))
        if result == false then print("performSingleUpgrade: Upgrade falhou (servidor retornou false)."); return false end
        return true
    else
        warn("performSingleUpgrade: InvokeServer ERRO CRÍTICO: " .. tostring(result))
        return false
    end
end

-- executeUpgradeSequence
local function executeUpgradeSequence() if not targetUnitInstance then print("ERR: No target for UPGs."); return end; print("FARM V0.2.1R Upg Seq for " .. targetUnitInstance.Name); print("UPGs CIMA..."); for i=1,INITIAL_TOP_UPGRADES_COUNT do if not performSingleUpgrade(targetUnitInstance,UPGRADE_PATH_TOP) then print("UPG CIMA "..i.." FAILED"); break end; print("UPG CIMA "..i.." OK"); wait(DELAY_BETWEEN_UPGRADES) end; print("UPGs BAIXO..."); for i=1,INITIAL_BOTTOM_UPGRADES_COUNT do if not performSingleUpgrade(targetUnitInstance,UPGRADE_PATH_BOTTOM) then print("UPG BAIXO "..i.." FAILED"); break end; print("UPG BAIXO "..i.." OK"); wait(DELAY_BETWEEN_UPGRADES) end; print("UPGs contínuos CIMA..."); for i=1,CONTINUOUS_TOP_UPGRADES_MAX_ATTEMPTS do if not performSingleUpgrade(targetUnitInstance,UPGRADE_PATH_TOP) then print("UPG CIMA cont "..i.." FAILED"); break end; print("UPG CIMA cont "..i.." OK"); wait(DELAY_BETWEEN_UPGRADES) end; print("FARM V0.2.1R Upg Seq concluída.") end

--====================================================================================
-- EXECUÇÃO PRINCIPAL
--====================================================================================
local function main()
    print("FARM V0.2.1R main()..."); wait(1);
    if not initializePlayerAndCharacter() then print("CRIT: Player init fail."); return end
    if not executeTeleport() then print("CRIT: TP fail."); return end
    wait(1); 
    if not findUnitsFolder() then print("CRIT: Units folder fail."); return end
    if not findSpecificUnit() then 
        print("INFO: Unit not found, no upgrades.")
    else
        print("INFO: Unidade encontrada, iniciando sequência de upgrades...");
        executeUpgradeSequence()
    end
    print("FARM V0.2.1R main() done.")
end

main()

print("FARM SCRIPT (via HttpGet): Execução do script principal terminada.")
