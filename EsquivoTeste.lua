local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer

local dodgeDistance = 7
local detectionRadius = 20
local dodgeSpeed = 20

local function calculateDodgePosition(character, projectile)
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return end

    local characterPosition = humanoidRootPart.Position
    local projectilePosition = projectile.Position
    local directionToDodge = (characterPosition - projectilePosition).Unit

    local dodgeOffset = Vector3.new(directionToDodge.Z, 0, -directionToDodge.X) * dodgeDistance
    return characterPosition + dodgeOffset
end

local function isProjectileDangerous(projectile, character)
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
    if not humanoidRootPart then return false end

    local distance = (projectile.Position - humanoidRootPart.Position).Magnitude
    if distance > detectionRadius then return false end

    local directionToCharacter = (humanoidRootPart.Position - projectile.Position).Unit
    local projectileVelocity = projectile.Velocity.Unit

    local movingTowardPlayer = directionToCharacter:Dot(projectileVelocity) > 0.9
    return movingTowardPlayer
end

local function dodgeProjectiles()
    local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
    local humanoid = character:FindFirstChild("Humanoid")
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

    if not humanoid or not humanoidRootPart then return end

    for _, object in ipairs(workspace:GetDescendants()) do
        if object:IsA("BasePart") and object.Velocity.Magnitude > 50 then
            if isProjectileDangerous(object, character) then
                local dodgePosition = calculateDodgePosition(character, object)
                humanoid:MoveTo(dodgePosition)
                task.wait(0.1)
                break
            end
        end
    end
end

local function monitorHealthChanges()
    local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
    local humanoid = character:WaitForChild("Humanoid")

    humanoid:GetPropertyChangedSignal("Health"):Connect(function()
        if humanoid.Health < humanoid.MaxHealth then
            dodgeProjectiles()
        end
    end)
end

task.delay(5, function()
    monitorHealthChanges()
    RunService.Stepped:Connect(function()
        dodgeProjectiles()
    end)
end)
