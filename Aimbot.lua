local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local localPlayer = Players.LocalPlayer

local aimInterval = 0.05
local maxDistance = 2000
local lastUpdate = 0

local function isEnemy(player)
    return player ~= localPlayer and (not player.Team or player.Team ~= localPlayer.Team)
end

local function isVisible(part)
    local origin = localPlayer.Character.HumanoidRootPart.Position
    local direction = (part.Position - origin).Unit * (part.Position - origin).Magnitude
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {localPlayer.Character}
    rayParams.FilterType = Enum.RaycastFilterType.Blacklist

    local result = Workspace:Raycast(origin, direction, rayParams)
    return result and result.Instance:IsDescendantOf(part.Parent)
end

local function getClosestEnemy()
    local closestEnemy = nil
    local closestPart = nil
    local closestDistance = math.huge

    for _, player in ipairs(Players:GetPlayers()) do
        if isEnemy(player) and player.Character then
            local head = player.Character:FindFirstChild("Head")
            local rootPart = player.Character:FindFirstChild("HumanoidRootPart")
            local targetPart = nil

            if head and isVisible(head) then
                targetPart = head
            elseif rootPart and isVisible(rootPart) then
                targetPart = rootPart
            end

            if targetPart then
                local distance = (targetPart.Position - localPlayer.Character.HumanoidRootPart.Position).Magnitude
                if distance < closestDistance and distance <= maxDistance then
                    closestEnemy = player
                    closestPart = targetPart
                    closestDistance = distance
                end
            end
        end
    end

    return closestPart
end

local function aimAtTarget(target)
    local camera = Workspace.CurrentCamera
    if target then
        camera.CFrame = CFrame.new(camera.CFrame.Position, target.Position)
    end
end

local function monitorAimBot()
    RunService.RenderStepped:Connect(function()
        if tick() - lastUpdate >= aimInterval then
            lastUpdate = tick()

            local closestEnemyPart = getClosestEnemy()
            if closestEnemyPart then
                aimAtTarget(closestEnemyPart)
            end
        end
    end)
end

task.delay(5, function()
    monitorAimBot()
end)
