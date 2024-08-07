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
    until success == true or RETRY_NUM > MAX_RETRIES

    if success then
        if path.Status == Enum.PathStatus.Success then
            return path
        else
            local RETRY_NUM = 0

            -- Retrying again as it is no longer network issue, it's humanoidRoot.Position issue
            repeat
                RETRY_NUM = RETRY_NUM + 1
                print("not close enough")

                local humanPos = humanoidRoot.Position

                humanoid:MoveTo(humanPos + Vector3.new(0, 0, -5)) -- relocationg before recomputing
                humanoid.MoveToFinished:Wait()

                local newPos = humanoidRoot.Position

                if math.floor(newPos.Z) == math.floor(humanPos.Z) then
                    humanoid:MoveTo(humanPos + Vector3.new(-5, 0, 0)) -- relocationg before recomputing
                    humanoid.MoveToFinished:Wait()
                end

                path:ComputeAsync(humanoidRoot.Position, pos)

            until path.Status == Enum.PathStatus.Success or RETRY_NUM > MAX_RETRIES

            if path.Status == Enum.PathStatus.Success then
                return path
            else
                print("Cannot compute path, tweening instead...")
                return nil
            end
        end
    else
        print("Pathfind compute error: " .. errorMessage)
        return nil
    end
end

local function goToLocation(locationPos)
    local path = calcPath(locationPos)

    if not path then
        local tweenService = game:GetService("TweenService")
        local tweenInfo = TweenInfo.new(5)
        local target = {Position = locationPos + Vector3.new(0, 5, 0)}

        local tween = tweenService:Create(humanoidRoot, tweenInfo, target)

        tween:Play()
    end

    local reachedConnection
    local pathBlockedConnection
    local currentWaypointIndex = 1
    local nextWaypointIndex = 2
    local ballParts = {}

    local waypoints = path:GetWaypoints()

    for index, waypoint in ipairs(waypoints) do
        -- spawn dots to destination
        task.wait()
        local part = Instance.new("Part")
        part.Name = "GuideBall"
        part.Shape = "Ball"
        part.Color = Color3.new(255, 0, 0)
        part.Material = "Neon"
        part.Size = Vector3.new(0.6, 0.6, 0.6)
        part.Position = waypoint.Position + Vector3.new(0, 5, 0)
        part.Anchored = true
        part.CanCollide = false
        part.Parent = workspace

        table.insert(ballParts, part)
    end

    for index, waypoint in ipairs(waypoints) do
        -- need to catch blocked waypoints then call function onPathBlocked()
        pathBlockedConnection = path.Blocked:Connect(function(blockedWaypointIndex)

            -- making sure obstacle is further ahead
            if blockedWaypointIndex >= nextWaypointIndex then
                pathBlockedConnection:Disconnect()
                goToLocation(locationPos)
            end
        end)
            
        -- delete the ball
        ballParts[currentWaypointIndex]:Destroy()

        -- update waypoint
        currentWaypointIndex = currentWaypointIndex + 1

        -- jump if needed
        if waypoint.Action == Enum.PathWaypointAction.Jump then
            humanoid.Jump = true
        end

        -- walk to waypoint
        humanoid:MoveTo(waypoint.Position)
        humanoid.MoveToFinished:Wait()

        nextWaypointIndex = nextWaypointIndex + 1
    end

    -- repeat task.wait() until we can meet a condition
end

local function goToItem(itemPos)
    local path = calcPath(itemPos)

    local reachedConnection
    local pathBlockedConnection
    local currentWaypointIndex = 1
    local nextWaypointIndex = currentWaypointIndex + 1

    local waypoints = path:GetWaypoints()

    for index, waypoint in ipairs(waypoints) do

        -- need to catch blocked waypoints then call function onPathBlocked()
            pathBlockedConnection = path.Blocked:Connect(function(blockedWaypointIndex)

                -- making sure obstacle is further ahead
                if blockedWaypointIndex >= nextWaypointIndex then
                    pathBlockedConnection:Disconnect()
                    goToItem(itemPos)
                end
            end)

        -- update waypoint
        currentWaypointIndex = currentWaypointIndex + 1
        nextWaypointIndex = currentWaypointIndex + 1

        -- jump if needed
        if waypoint.Action == Enum.PathWaypointAction.Jump then
            humanoid.Jump = true
        end

        -- walk to waypoint
        humanoid:MoveTo(waypoint.Position)
        humanoid.MoveToFinished:Wait()
    end

    -- repeat task.wait() until we can meet a condition
end

goToLocation(workspace.FlowerZones["Rose Field"].Position)
