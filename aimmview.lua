-- Configuration
local config = {
    enable = false, -- Keep false
    color = Color3.fromRGB(255, 0, 0), -- Color of aimviewer beam
    toggle_keybind = Enum.KeyCode.V,
    notifier_keybind = Enum.KeyCode.B,
    method = "MousePos", -- "MousePos", "UpdateMousePos"
}

if game.PlaceId == 2788229376 then
    config.method = "MousePos"
end

-- Services
local rs = game:GetService("RunService")
local localPlayer = game.Players.LocalPlayer
local mouse = localPlayer:GetMouse()

-- Variables
local target

-- Functions
function getgun()
    for _, v in pairs(target.Character:GetChildren()) do
        if v and (v:FindFirstChild('Default') or v:FindFirstChild('Handle')) then
            return v
        end
    end
end

function sendNotification(message)
    game.StarterGui:SetCore("SendNotification", {
        Title = '',
        Text = message,
        Duration = 1,
    })
end

function getCloset()
    local closestPlayer, closestDistance = nil, math.huge

    for _, player in pairs(game.Players:GetPlayers()) do
        if player ~= localPlayer and player.Character and player.Character:FindFirstChild("Head") and player.Character:FindFirstChild("HumanoidRootPart") then
            local characterPosition = player.Character.PrimaryPart.Position
            local viewportPosition = game.Workspace.CurrentCamera:WorldToViewportPoint(characterPosition)
            local distance = (Vector2.new(mouse.X, mouse.Y) - Vector2.new(viewportPosition.X, viewportPosition.Y)).Magnitude

            if distance < closestDistance then
                closestPlayer = player
                closestDistance = distance
            end
        end
    end

    return closestPlayer
end

-- Keybinds
mouse.KeyDown:Connect(function(key)
    if key == config.toggle_keybind then
        config.enable = not config.enable
        sendNotification(config.enable and "Enabled" or "Disabled")
    elseif key == config.notifier_keybind then
        target = getCloset()
        if target then
            sendNotification("Targeting: " .. target.Name)
        end
    end
end)

-- AimViewer
local aimViewer = Instance.new("Beam")
aimViewer.Segments = 1
aimViewer.Width0 = 0.2
aimViewer.Width1 = 0.2
aimViewer.Color = ColorSequence.new(config.color)
aimViewer.FaceCamera = true

local attachment0 = Instance.new("Attachment")
local attachment1 = Instance.new("Attachment")
aimViewer.Attachment0 = attachment0
aimViewer.Attachment1 = attachment1

aimViewer.Parent = workspace.Terrain
attachment0.Parent = workspace.Terrain
attachment1.Parent = workspace.Terrain

-- Rendering
task.spawn(function()
    rs.RenderStepped:Connect(function()
        local character = localPlayer.Character
        if not character then
            aimViewer.Enabled = false
            return
        end

        if config.enable and getgun() and target and target.Character:FindFirstChild("BodyEffects") and target.Character:FindFirstChild("Head") then
            aimViewer.Enabled = true
            attachment0.Position = target.Character:FindFirstChild("Head").Position
            attachment1.Position = target.Character.BodyEffects[config.method].Value
        else
            aimViewer.Enabled = false
        end
    end)
end)
