-- Player Variables
local workspace = game:GetService("Workspace")
local player = game:GetService("Players").LocalPlayer
local character = player.Character
local humanoid = character:FindFirstChild("Humanoid")
local humanoidRoot = character:WaitForChild("HumanoidRootPart")
local virtualUser = game:GetService("VirtualUser")

-- Path Variables
local PathfindingService = game:GetService("PathfindingService")
local MAX_RETRIES = 5
local RETRY_COOLDOWN = 5
local YIELDING = false

-- Tween Variables
local tweenService = game:GetService("TweenService")
local tweenInfo = TweenInfo.new(3)

-- Variables used for functions handling hives
local hiveFolder = workspace.Honeycombs
local hives = hiveFolder:GetChildren()

-- Variables used for functions handling fields
local fieldsFolder = workspace.FlowerZones
local fields = fieldsFolder:GetChildren()

-- Variables used for functions handling FlowerZones
local flowersFolder = workspace.Flowers
local flowers = flowersFolder:GetChildren()

-- Variables used for functions handling NPCs
local npcFolder = workspace.NPCs
local npcs = npcFolder:GetChildren()

-- Gadget Variables
local gadgetsFolder = workspace.Gadgets
local gadgets = gadgetsFolder:GetChildren()

local pos = {
    position = Vector3.new(player.SpawnPos.Value.Position.X, player.SpawnPos.Value.Position.Y, player.SpawnPos.Value.Position.Z)
}

local hr = {
    position = Vector3.new(humanoidRoot.Position.X, humanoidRoot.Position.Y, humanoidRoot.Position.Z)
}

for index, hive in pairs(hives) do
    print("Checking hive")
    if tostring(hive.Owner.Value) == player.Name then
        print("found hive")
        local tween = tweenService:Create(hr, tweenInfo, pos)
        print("playing tween")
        tween:Play()
    end
end