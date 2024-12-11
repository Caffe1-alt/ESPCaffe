local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer

local espData = {}

local function isAlly(player)
    return player.Team == localPlayer.Team
end

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

local function addOrUpdateBox(player)
    local character = player.Character or player.CharacterAdded:Wait()
    if character and character:FindFirstChild("HumanoidRootPart") then
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

        local espBox = espData[player] and espData[player].Box
        if not espBox then
            espBox = Instance.new("BoxHandleAdornment")
            espBox.Adornee = humanoidRootPart
            espBox.Size = Vector3.new(4, 6, 4)
            espBox.AlwaysOnTop = true
            espBox.ZIndex = 5
            espBox.Parent = humanoidRootPart
            espData[player] = espData[player] or {}
            espData[player].Box = espBox
        end

        espBox.Color3 = isAlly(player) and Color3.new(0, 0, 1) or Color3.new(1, 0, 0)
        espBox.Transparency = 0.3
    end
end

local function addOrUpdateLabel(player)
    local character = player.Character or player.CharacterAdded:Wait()
    if character and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("Humanoid") then
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChild("Humanoid")

        local espLabel = espData[player] and espData[player].Label
        if not espLabel then
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

        local textLabel = espLabel:FindFirstChild("ESPText")
        if textLabel then
            local function updateLabel()
                textLabel.Text = string.format("%s - %d HP", player.Name, math.floor(humanoid.Health))
                textLabel.TextColor3 = isAlly(player) and Color3.new(0, 0, 1) or Color3.new(1, 0, 0)
            end

            humanoid:GetPropertyChangedSignal("Health"):Connect(updateLabel)
            updateLabel()
        end
        espLabel.Parent = humanoidRootPart
    end
end

local function applyESP(player)
    addOrUpdateBox(player)
    addOrUpdateLabel(player)
end

local function resetAndReapplyESP()
    for _, player in ipairs(Players:GetPlayers()) do
        removeESP(player)
        if player.Character then
            applyESP(player)
        end
    end
end

local function monitorTeamChanges()
    for _, player in ipairs(Players:GetPlayers()) do
        player:GetPropertyChangedSignal("Team"):Connect(function()
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

local function monitorPlayers()
    for _, player in ipairs(Players:GetPlayers()) do
        player.CharacterAdded:Connect(function()
            task.wait(1)
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

task.delay(5, function()
    monitorPlayers()
    monitorTeamChanges()

    localPlayer:GetPropertyChangedSignal("Team"):Connect(function()
        resetAndReapplyESP()
    end)
end)
