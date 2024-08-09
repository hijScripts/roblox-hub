-- Player Variables
local workspace = game:GetService("Workspace")
local player = game:GetService("Players").LocalPlayer
local character = player.Character
local humanoid = character:FindFirstChild("Humanoid")
local humanoidRoot = character:WaitForChild("HumanoidRootPart")
local virtualUser = game:GetService("VirtualUser")

local tweenService = game:GetService("TweenService")
local tweenInfo = TweenInfo.new(5)



local targetCFrame = CFrame.new(player.SpawnPos.Value.Position + Vector3.new(0, 5, 0))
local tween = tweenService:Create(humanoidRoot, tweenInfo, {CFrame = targetCFrame})

if not tween.PlaybackState == Enum.PlaybackState.Playing then
    tween:Play()
end