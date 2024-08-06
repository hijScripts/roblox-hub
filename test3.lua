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
local RETRY_COOLDOWN = 1
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

-- Function to move character to given position
function goTo(targetPos)
    print("Starting goTo function with target position:", targetPos, "and humanroot pos:", humanoidRoot.Position)
    local path = PathfindingService:CreatePath()
    local reachedConnection
    local pathBlockedConnection

    local RETRY_NUM = 0
    local success, errorMessage

    repeat
        RETRY_NUM = RETRY_NUM + 1 
        success, errorMessage = pcall(function()
            path:ComputeAsync(humanoidRoot.Position, targetPos)
        end)
        if not success then -- if fails, warn console
            print("Pathfind compute path error: " .. errorMessage)
            task.wait(RETRY_COOLDOWN)
        end
    until success == true or RETRY_NUM > MAX_RETRIES

    if success then
        if path.Status == Enum.PathStatus.Success then
            print("Path computed successfully. Moving to target position.")
            local waypoints = path:GetWaypoints()
            local currentWaypointIndex = 2 -- not 1, because 1 is the waypoint of the starting position

            if not reachedConnection then
                reachedConnection = humanoid.MoveToFinished:Connect(function(reached)
                    if reached and currentWaypointIndex < #waypoints then
                        currentWaypointIndex = currentWaypointIndex + 1

                        humanoid:MoveTo(waypoints[currentWaypointIndex].Position)
                        if waypoints[currentWaypointIndex].Action == Enum.PathWaypointAction.Jump then
                            humanoid.Jump = true
                        end
                    else
                        reachedConnection:Disconnect()
                        pathBlockedConnection:Disconnect()
                        reachedConnection = nil -- you need to manually set this to nil because calling disconnect function does not make the variable to be nil.
                        pathBlockedConnection = nil
                        print("Reached target position or path blocked.")
                    end
                end)
            end

            pathBlockedConnection = path.Blocked:Connect(function(waypointNumber)
                if waypointNumber > currentWaypointIndex then -- blocked path is ahead of the BoostBallBarrier
                    print("Path blocked at waypoint:", waypointNumber)
                    reachedConnection:Disconnect()
                    pathBlockedConnection:Disconnect()
                    reachedConnection = nil
                    pathBlockedConnection = nil
                end
            end)
            
            humanoid:MoveTo(waypoints[currentWaypointIndex].Position) -- move to the nth waypoint
            if waypoints[currentWaypointIndex].Action == Enum.PathWaypointAction.Jump then
                humanoid.Jump = true
            end

        else -- if the path can't be computed between two points, do nothing!
            print("Pathfinding failed: Path Status is not Complete")
            return
        end
    else -- this only runs IF the function has problems computing the path in its backend, NOT if a path can't be created between two points.
        print("Pathfind compute retry maxed out, error: " .. errorMessage)
        return
    end

    repeat
        task.wait()
    until (humanoidRoot.Position - targetPos).Magnitude < 10
    print("Reached target position:", targetPos)
end

local selectedField = "Rose Field"
print("Selected field:", selectedField)

for index, field in ipairs(fields) do
    print("Checking field:", field.Name)
    if field.Name == selectedField then
        print("Field matched:", field.Name)
        goTo(field.Position)
        break
    end
end
local selectedField = "Rose Field"

for index, field in ipairs(fields) do
    if field.Name == selectedField then
        goTo(field.Position)
    end
end

print(humanoid.JumpPower)