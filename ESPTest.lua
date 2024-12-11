local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer

-- Tabela para armazenar referências dos adornos
local espData = {}

-- Função para verificar se o jogador é aliado ou inimigo
local function isAlly(player)
    return player.Team == localPlayer.Team
end

-- Função para remover ESP de um jogador
local function removeESP(player)
    if espData[player] then
        if espData[player].Box then
            espData[player].Box:Destroy()
        end
        if espData[player].Label then
            espData[player].Label:Destroy()
        end
        espData[player] = nil
    end
end

-- Função para criar ou atualizar ESP Box
local function addOrUpdateBox(player)
    local character = player.Character or player.CharacterAdded:Wait()
    if character and character:FindFirstChild("HumanoidRootPart") then
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

        -- Verificar se já existe um ESP para o jogador
        local espBox = espData[player] and espData[player].Box
        if not espBox then
            -- Criar novo BoxHandleAdornment
            espBox = Instance.new("BoxHandleAdornment")
            espBox.Adornee = humanoidRootPart
            espBox.Size = Vector3.new(4, 6, 4)
            espBox.AlwaysOnTop = true
            espBox.ZIndex = 5
            espBox.Parent = humanoidRootPart
            espData[player] = espData[player] or {}
            espData[player].Box = espBox
        end

        -- Atualizar cor dependendo de ser aliado ou inimigo
        espBox.Color3 = isAlly(player) and Color3.new(0, 0, 1) or Color3.new(1, 0, 0)
        espBox.Transparency = 0.3
    end
end

-- Função para criar ou atualizar Label
local function addOrUpdateLabel(player)
    local character = player.Character or player.CharacterAdded:Wait()
    if character and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("Humanoid") then
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChild("Humanoid")

        local espLabel = espData[player] and espData[player].Label
        if not espLabel then
            -- Criar BillboardGui
            espLabel = Instance.new("BillboardGui")
            espLabel.Adornee = humanoidRootPart
            espLabel.Size = UDim2.new(4, 0, 1, 0)
            espLabel.AlwaysOnTop = true
            espLabel.MaxDistance = 100

            local textLabel = Instance.new("TextLabel", espLabel)
            textLabel.Size = UDim2.new(1, 0, 1, 0)
            textLabel.BackgroundTransparency = 1
            textLabel.TextStrokeTransparency = 0
            textLabel.TextScaled = true
            textLabel.Font = Enum.Font.SourceSansBold
            textLabel.Name = "ESPText"
            textLabel.Parent = espLabel

            espData[player] = espData[player] or {}
            espData[player].Label = espLabel
        end

        -- Atualizar texto e cor
        local textLabel = espLabel:FindFirstChild("ESPText")
        if textLabel then
            local function updateLabel()
                textLabel.Text = string.format("%s - %d HP", player.Name, math.floor(humanoid.Health))
                textLabel.TextColor3 = isAlly(player) and Color3.new(0, 0, 1) or Color3.new(1, 0, 0)
            end

            -- Conectar atualização do texto ao evento de mudança de vida
            humanoid:GetPropertyChangedSignal("Health"):Connect(updateLabel)
            updateLabel()
        end
        espLabel.Parent = humanoidRootPart
    end
end

-- Função para aplicar ESP a um jogador
local function applyESP(player)
    addOrUpdateBox(player)
    addOrUpdateLabel(player)
end

-- Função para limpar e recriar ESP de todos os jogadores
local function resetAndReapplyESP()
    for _, player in ipairs(Players:GetPlayers()) do
        removeESP(player)
        if player.Character then
            applyESP(player)
        end
    end
end

-- Monitorar mudanças de time de todos os jogadores
local function monitorTeamChanges()
    for _, player in ipairs(Players:GetPlayers()) do
        player:GetPropertyChangedSignal("Team"):Connect(function()
            print("Mudança de time detectada para:", player.Name)
            resetAndReapplyESP()
        end)
    end

    Players.PlayerAdded:Connect(function(player)
        player:GetPropertyChangedSignal("Team"):Connect(function()
            print("Novo jogador mudou de time:", player.Name)
            resetAndReapplyESP()
        end)
    end)
end

-- Função para monitorar jogadores e aplicar ESP
local function monitorPlayers()
    for _, player in ipairs(Players:GetPlayers()) do
        player.CharacterAdded:Connect(function()
            task.wait(1) -- Aguarde antes de executar para evitar falhas
            applyESP(player)
        end)
        if player.Character then
            applyESP(player)
        end
    end

    Players.PlayerAdded:Connect(function(player)
        player.CharacterAdded:Connect(function()
            task.wait(1)
            applyESP(player)
        end)
    end)
end

-- Inicialização
print("ESP ativado! Aguardando 5 segundos...")
task.delay(5, function()
    print("ESP iniciado com sistema de atualização de times!")
    monitorPlayers()
    monitorTeamChanges()

    -- Atualizar ESP se o próprio jogador mudar de time
    localPlayer:GetPropertyChangedSignal("Team"):Connect(function()
        print("Time do player local mudou! Atualizando ESP...")
        resetAndReapplyESP()
    end)
end)
