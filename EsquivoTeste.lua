local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local localPlayer = Players.LocalPlayer

local dodgeDistance = 5
local dodgeSpeed = 25
local detectionRadius = 15

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

    local directionToCharacter = (humanoidRootPart.Position - projectile.Position).Unit
    local projectileVelocity = projectile.Velocity.Unit

    return directionToCharacter:Dot(projectileVelocity) > 0.9
end

local function dodgeProjectiles()
    local character = localPlayer.Character or localPlayer.CharacterAdded:Wait()
    local humanoid = character:FindFirstChild("Humanoid")
    local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")

    if not humanoid or not humanoidRootPart then return end

    for _, object in ipairs(workspace:GetDescendants()) do
        if object:IsA("BasePart") and object.Velocity.Magnitude > 50 then
            if (object.Position - humanoidRootPart.Position).Magnitude <= detectionRadius then
                if isProjectileDangerous(object, character) then
                    local dodgePosition = calculateDodgePosition(character, object)
                    humanoid:MoveTo(dodgePosition)
                    break
                end
            end
        end
    end
end

task.delay(5, function()
    RunService.Stepped:Connect(function()
        local success, err = pcall(function()
            dodgeProjectiles()
        end)
    end)
end)
