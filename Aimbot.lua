local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer

local function isAlly(player)
    return player.Team == localPlayer.Team
end

local function getClosestEnemy()
    local closestEnemy = nil
    local closestDistance = math.huge
    for _, player in ipairs(Players:GetPlayers()) do
        if not isAlly(player) and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
            local rootPart = player.Character.HumanoidRootPart
            local distance = (rootPart.Position - localPlayer.Character.HumanoidRootPart.Position).Magnitude

            local ray = Ray.new(localPlayer.Character.HumanoidRootPart.Position, (rootPart.Position - localPlayer.Character.HumanoidRootPart.Position).Unit * distance)
            local hitPart = workspace:FindPartOnRayWithIgnoreList(ray, {localPlayer.Character})

            if hitPart and hitPart:IsDescendantOf(player.Character) and distance < closestDistance then
                closestEnemy = rootPart
                closestDistance = distance
            end
        end
    end
    return closestEnemy
end

local function aimAtTarget(target)
    local camera = workspace.CurrentCamera
    if target then
        camera.CFrame = CFrame.new(camera.CFrame.Position, target.Position)
    end
end

local function monitorAimBot()
    RunService.RenderStepped:Connect(function()
        local closestEnemy = getClosestEnemy()
        if closestEnemy then
            aimAtTarget(closestEnemy)
        end
    end)
end

task.delay(5, function()
    monitorAimBot()
end)
