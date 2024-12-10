local Players = game:GetService("Players")
local localPlayer = Players.LocalPlayer

local function isAlly(player)
    return player.Team == localPlayer.Team
end

local boxHandles = {}

local function addOrUpdateBox(player)
    local character = player.Character or player.CharacterAdded:Wait()
    if character and character:FindFirstChild("HumanoidRootPart") then
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        local box = boxHandles[player]
        if not box then
            box = Instance.new("BoxHandleAdornment")
            box.Adornee = humanoidRootPart
            box.Size = Vector3.new(4, 6, 4)
            box.AlwaysOnTop = true
            box.ZIndex = 5
            box.Parent = humanoidRootPart
            boxHandles[player] = box
        end
        box.Color3 = isAlly(player) and Color3.new(0, 0, 1) or Color3.new(1, 0, 0)
        box.Transparency = 0.3
    end
end

local function addOrUpdateLabel(player)
    local character = player.Character or player.CharacterAdded:Wait()
    if character and character:FindFirstChild("HumanoidRootPart") and character:FindFirstChild("Humanoid") then
        local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        local humanoid = character:FindFirstChild("Humanoid")

        local billboard = Instance.new("BillboardGui")
        billboard.Adornee = humanoidRootPart
        billboard.Size = UDim2.new(4, 0, 1, 0)
        billboard.AlwaysOnTop = true
        billboard.MaxDistance = 100

        local textLabel = Instance.new("TextLabel", billboard)
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.BackgroundTransparency = 1
        textLabel.TextColor3 = isAlly(player) and Color3.new(0, 0, 1) or Color3.new(1, 0, 0)
        textLabel.TextStrokeTransparency = 0
        textLabel.TextScaled = true
        textLabel.Font = Enum.Font.SourceSansBold

        local function updateHealth()
            if humanoid then
                textLabel.Text = string.format("%s - %d HP", player.Name, math.floor(humanoid.Health))
            end
        end

        updateHealth()
        humanoid:GetPropertyChangedSignal("Health"):Connect(updateHealth)
        billboard.Parent = humanoidRootPart
    end
end

local function applyESP(player)
    addOrUpdateBox(player)
    addOrUpdateLabel(player)
end

local function monitorPlayersForESP()
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

local function monitorTeamChangesForESP()
    localPlayer:GetPropertyChangedSignal("Team"):Connect(function()
        for _, player in ipairs(Players:GetPlayers()) do
            if player.Character then
                addOrUpdateBox(player)
                addOrUpdateLabel(player)
            end
        end
    end)

    for _, player in ipairs(Players:GetPlayers()) do
        player:GetPropertyChangedSignal("Team"):Connect(function()
            if player.Character then
                addOrUpdateBox(player)
                addOrUpdateLabel(player)
            end
        end)
    end
end

task.delay(5, function()
    monitorPlayersForESP()
    monitorTeamChangesForESP()
end)
