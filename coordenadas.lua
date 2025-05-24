--[[
    SCRIPT PARA MOSTRAR E COPIAR COORDENADAS DO JOGADOR

    Como usar:
    1. Execute este script em um executor client-side.
    2. Uma pequena GUI aparecerá no canto da tela.
    3. As coordenadas (X, Y, Z) do seu personagem serão atualizadas continuamente.
    4. Clique no botão "Copiar CFrame" para copiar a linha `CFrame.new(X, Y, Z)` para sua área de transferência.
    5. Clique no botão "Copiar Vector3" para copiar a linha `Vector3.new(X, Y, Z)` para sua área de transferência.
    6. Cole no seu script de farm nas variáveis TARGET_CFRAME ou UNIT_PLACEMENT_POSITION.
]]

print("Coordenadas GUI: Script iniciado.")

-- Serviços
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui") -- Usar CoreGui para sobrepor outras UIs do jogo

-- Jogador Local
local player = Players.LocalPlayer
if not player then
    warn("Coordenadas GUI: Jogador local não encontrado.")
    return
end

-- Variável para armazenar a GUI e evitar duplicação
local COORDS_GUI_NAME = "PlayerCoordinatesDisplayGUI"
if CoreGui:FindFirstChild(COORDS_GUI_NAME) then
    CoreGui:FindFirstChild(COORDS_GUI_NAME):Destroy()
    print("Coordenadas GUI: GUI anterior removida.")
end

-- Criar a ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = COORDS_GUI_NAME
screenGui.ResetOnSpawn = false -- Para não resetar se o personagem morrer e respawnar
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling -- Ou Global se precisar estar sempre no topo
screenGui.DisplayOrder = 9999 -- Tenta colocar no topo
screenGui.Parent = CoreGui
print("Coordenadas GUI: ScreenGui criada.")

-- Criar o Frame principal
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 250, 0, 100) -- Largura, Altura
mainFrame.Position = UDim2.new(0.01, 0, 0.01, 0) -- Posição no canto superior esquerdo
mainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
mainFrame.BorderColor3 = Color3.fromRGB(80, 80, 80)
mainFrame.BorderSizePixel = 2
mainFrame.Active = true -- Para permitir arrastar
mainFrame.Draggable = true -- Permite arrastar o frame
mainFrame.Parent = screenGui

-- Criar o TextLabel para mostrar as coordenadas
local coordsLabel = Instance.new("TextLabel")
coordsLabel.Name = "CoordsLabel"
coordsLabel.Size = UDim2.new(1, -10, 0, 30) -- Largura total (-10 de padding), Altura
coordsLabel.Position = UDim2.new(0, 5, 0, 5) -- Posição com padding
coordsLabel.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
coordsLabel.TextColor3 = Color3.fromRGB(230, 230, 230)
coordsLabel.TextStrokeColor3 = Color3.fromRGB(0,0,0)
coordsLabel.TextStrokeTransparency = 0.5
coordsLabel.Font = Enum.Font.SourceSansSemibold
coordsLabel.TextSize = 14
coordsLabel.TextXAlignment = Enum.TextXAlignment.Left
coordsLabel.Text = "Coordenadas: Aguardando personagem..."
coordsLabel.Parent = mainFrame

-- Criar o botão para copiar CFrame
local copyCFrameButton = Instance.new("TextButton")
copyCFrameButton.Name = "CopyCFrameButton"
copyCFrameButton.Size = UDim2.new(0.48, -5, 0, 25)
copyCFrameButton.Position = UDim2.new(0, 5, 0, 40)
copyCFrameButton.BackgroundColor3 = Color3.fromRGB(70, 130, 180) -- SteelBlue
copyCFrameButton.TextColor3 = Color3.fromRGB(255, 255, 255)
copyCFrameButton.Font = Enum.Font.SourceSansBold
copyCFrameButton.TextSize = 13
copyCFrameButton.Text = "Copiar CFrame"
copyCFrameButton.Parent = mainFrame

-- Criar o botão para copiar Vector3
local copyVector3Button = Instance.new("TextButton")
copyVector3Button.Name = "CopyVector3Button"
copyVector3Button.Size = UDim2.new(0.48, -5, 0, 25)
copyVector3Button.Position = UDim2.new(0.52, 0, 0, 40) -- Ao lado do outro botão
copyVector3Button.BackgroundColor3 = Color3.fromRGB(60, 179, 113) -- MediumSeaGreen
copyVector3Button.TextColor3 = Color3.fromRGB(255, 255, 255)
copyVector3Button.Font = Enum.Font.SourceSansBold
copyVector3Button.TextSize = 13
copyVector3Button.Text = "Copiar Vector3"
copyVector3Button.Parent = mainFrame

-- TextLabel para feedback de cópia
local feedbackLabel = Instance.new("TextLabel")
feedbackLabel.Name = "FeedbackLabel"
feedbackLabel.Size = UDim2.new(1, -10, 0, 20)
feedbackLabel.Position = UDim2.new(0, 5, 0, 70)
feedbackLabel.BackgroundTransparency = 1
feedbackLabel.TextColor3 = Color3.fromRGB(0, 200, 0)
feedbackLabel.Font = Enum.Font.SourceSansItalic
feedbackLabel.TextSize = 12
feedbackLabel.Text = ""
feedbackLabel.TextXAlignment = Enum.TextXAlignment.Center
feedbackLabel.Parent = mainFrame

-- Variáveis para armazenar as coordenadas atuais
local currentPosition = Vector3.new(0,0,0)

-- Função para mostrar feedback
local function showFeedback(message)
    feedbackLabel.Text = message
    wait(2)
    if feedbackLabel and feedbackLabel.Parent then -- Verifica se ainda existe
        feedbackLabel.Text = ""
    end
end

-- Função de clique para o botão CFrame
copyCFrameButton.MouseButton1Click:Connect(function()
    if setclipboard then -- Verifica se a função setclipboard está disponível (geralmente em exploits)
        local cframeString = string.format("CFrame.new(%.6f, %.6f, %.6f)", currentPosition.X, currentPosition.Y, currentPosition.Z)
        setclipboard(cframeString)
        print("Coordenadas GUI: CFrame copiado para a área de transferência:", cframeString)
        showFeedback("CFrame copiado!")
    else
        warn("Coordenadas GUI: Função 'setclipboard' não disponível neste executor.")
        showFeedback("Erro: setclipboard indisponível.")
    end
end)

-- Função de clique para o botão Vector3
copyVector3Button.MouseButton1Click:Connect(function()
    if setclipboard then
        local vector3String = string.format("Vector3.new(%.6f, %.6f, %.6f)", currentPosition.X, currentPosition.Y, currentPosition.Z)
        setclipboard(vector3String)
        print("Coordenadas GUI: Vector3 copiado para a área de transferência:", vector3String)
        showFeedback("Vector3 copiado!")
    else
        warn("Coordenadas GUI: Função 'setclipboard' não disponível neste executor.")
        showFeedback("Erro: setclipboard indisponível.")
    end
end)

-- Loop para atualizar as coordenadas na GUI
local function updateCoordsLoop()
    while screenGui and screenGui.Parent and wait() do -- O wait() aqui é importante para não travar
        local character = player.Character
        if character then
            local hrp = character:FindFirstChild("HumanoidRootPart")
            if hrp then
                currentPosition = hrp.Position
                coordsLabel.Text = string.format("X: %.2f, Y: %.2f, Z: %.2f", currentPosition.X, currentPosition.Y, currentPosition.Z)
            else
                coordsLabel.Text = "Coordenadas: HRP não encontrado."
            end
        else
            coordsLabel.Text = "Coordenadas: Personagem não encontrado."
        end
    end
    print("Coordenadas GUI: Loop de atualização encerrado (GUI removida).")
end

-- Iniciar o loop de atualização
coroutine.wrap(updateCoordsLoop)() -- Roda em uma nova thread para não bloquear

print("Coordenadas GUI: GUI de coordenadas carregada e rodando.")
print("Coordenadas GUI: Posicione seu personagem e clique nos botões para copiar.")

-- Para limpar a GUI se o script for executado novamente ou se você quiser um comando para limpar:
-- (Opcional: você pode criar um comando no seu executor para chamar esta função)
-- function ClearCoordsGUI()
--     if CoreGui:FindFirstChild(COORDS_GUI_NAME) then
--         CoreGui:FindFirstChild(COORDS_GUI_NAME):Destroy()
--         print("Coordenadas GUI: GUI removida manualmente.")
--     end
-- end
