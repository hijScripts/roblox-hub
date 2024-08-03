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


-- Function to move character to given position
function goTo(targetPos)
    local path = PathfindingService:CreatePath()
    local reachedConnection
    local pathBlockedConnection

    local RETRY_NUM = 0
    local success, errorMessage

    repeat
        RETRY_NUM = RETRY_NUM + 1 
        success, errorMessage = pcall(path.ComputeAsync, path, humanoidRoot.Position, targetPos)
        if not success then -- if fails, warn console
            warn("Pathfind compute path error: " .. errorMessage)
            task.wait(RETRY_COOLDOWN)
        end
    until success == true or RETRY_NUM > MAX_RETRIES

    if success then
        if path.Status == Enum.PathStatus.Success then
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
                        reachedConnection = nil -- you need to manually set this to nil! because calling disconnect function does not make the variable to be nil.
                        pathBlockedConnection = nil
                    end
                end)
            end

            pathBlockedConnection = path.Blocked:Connect(function(waypointNumber)
                if waypointNumber > currentWaypointIndex then -- blocked path is ahead of the BoostBallBarrier
                    reachedConnection:Disconnect()
                    pathBlockedConnection:Disconnect()
                    reachedConnection = nil
                    pathBlockedConnection = nil
                    goTo(player.SpawnPos.Value.Position, true) -- new path
                end
            end)
            
            humanoid:MoveTo(waypoints[currentWaypointIndex].Position) -- move to the nth waypoint
            if waypoints[currentWaypointIndex].Action == Enum.PathWaypointAction.Jump then
                humanoid.Jump = true
            end

        else -- if the path can't be computed between two points, do nothing!
            return
        end
    else -- this only runs IF the function has problems computing the path in its backend, NOT if a path can't be created between two points.
        warn("Pathfind compute retry maxed out, error: " .. errorMessage)
        return
    end
end

goTo(player.SpawnPos.Value.Position)