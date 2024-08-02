-- Player Variables
local workspace = game:GetService("Workspace")
local player = game:GetService("Players").LocalPlayer
local character = player.Character
local humanoid = character:FindFirstChild("Humanoid")
local humanoidRoot = character:WaitForChild("HumanoidRootPart")

-- Pathfinding Variables
local pathFinding = game:GetService("PathfindingService")

function goTo(pos)
   print("Starting goTo function with position:", pos)

   local path = pathFinding:CreatePath()
   if not path then
       print("Failed to create path.")
       return
   end

   print("Computing path from:", humanoidRoot.Position, "to:", pos)
   path:ComputeAsync(humanoidRoot.Position, pos)

   if path.Status ~= Enum.PathStatus.Success then
       print("Path computation failed with status:", path.Status)
       return
   end

   local waypoints = path:GetWaypoints()
   if #waypoints == 0 then
       print("No waypoints found.")
       return
   end

   local guideBallTable = {}

   for index, waypoint in pairs(waypoints) do
       wait(0.01)
       local part = Instance.new("Part")
       part.Name = "GuideBall"
       part.Shape = "Ball"
       part.Color = Color3.fromRGB(255, 0, 0)
       part.Material = "Neon"
       part.Size = Vector3.new(0.6, 0.6, 0.6)
       part.Position = waypoint.Position + Vector3.new(0, 5, 0)
       part.Anchored = true
       part.CanCollide = false
       part.Parent = workspace

       table.insert(guideBallTable, part)
       print("Created guide ball at waypoint:", waypoint.Position)
   end

   for index, waypoint in pairs(waypoints) do
       if waypoint.Action == Enum.PathWaypointAction.Jump then
           print("Waypoint requires jumping at:", waypoint.Position)
           humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
       end

       print("Moving to waypoint:", waypoint.Position)
       humanoid:MoveTo(waypoint.Position)

       local success = humanoid.MoveToFinished:Wait(1)
       if not success then
           print("Failed to reach waypoint:", waypoint.Position)
       else
           print("Reached waypoint:", waypoint.Position)
       end
   end

   for index, guideBall in pairs(guideBallTable) do
       guideBall:Destroy()
       print("Destroyed guide ball:", guideBall.Position)
   end

   print("Finished goTo function.")
end


print("goTo function loaded")

goTo(player.SpawnPos.Value.Position)