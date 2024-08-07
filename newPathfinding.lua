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

-- Tween Variables
local tweenService = game:GetService("TweenService")
local tweenInfo = TweenInfo.New(3)

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

-- Variable for menus
local menu = player.PlayerGui.ScreenGui:FindFirstChild("Menus")
local menuOptions = menu.Children:GetChildren()

local function calcPath(pos)
    local path = PathfindingService:CreatePath({
        Costs = {

        }
    })

    local success, errorMessage
    local RETRY_NUM = 0

    -- Retrying this as network issues can cause it to fail initially.
    repeat
        RETRY_NUM = RETRY_NUM + 1

        success, errorMessage = pcall(path.ComputeAsync, path, humanoidRoot.Position, pos)

        if not success then -- if it fails, print to console and then retry
            print("Pathfind compute error: " .. errorMessage)
        end

        print("Success: " .. success)
    until success == true or RETRY_NUM > MAX_RETRIES

    if success then
        if path.Status == Enum.PathStatus.Success then
            return path
        else
            local RETRY_NUM = 0

            -- Retrying again as it is no longer network issue, it's humanoidRoot.Position issue
            repeat
                RETRY_NUM = RETRY_NUM + 1

                humanoid:MoveTo(Vector3.new(0, 0, -3)) -- relocationg before recomputing
                humanoid:MoveToFinished():Wait()

                path:ComputeAsync(humanoidRoot.Position, pos)

            until path.Status == Enum.PathStatus.Success or RETRY_NUM > MAX_RETRIES

            if path.Status == Enum.PathStatus.Success then
                return path
            else
                print("Pathfind compute error: " .. errorMessage)
            end
        end
    else
        print("Pathfind compute error: " .. errorMessage)
    end
end

local function onPathBlocked(path, blockedWaypoint)

end

local function goToLocation(locationPos)
    local path = calcPath(locationPos)

    local reachedConnection
    local pathBlockedConnection

    local waypoints = path:GetWaypoints()

    for index, waypoint in ipairs(waypoints) do
        -- spawn dots to destination
    end

    for index, waypoint in ipairs(waypoints) do
        -- walk to waypoint
        -- delete the dot

        -- need to catch blocked waypoints then call function onPathBlocked()
    end

    -- repeat task.wait() until we can meet a condition
end

local function goToItem(itemPos)
    local path = calcPath(itemPos)

    local reachedConnection
    local pathBlockedConnection

    local waypoints = path:GetWaypoints()

    for index, waypoint in ipairs(waypoints) do
        -- walk to item

        -- need to catch blocked waypoints then call function onPathBlocked()
    end

    -- repeat task.wait() until we can meet a condition
end