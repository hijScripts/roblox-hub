-- Player Variables
local workspace = game:GetService("Workspace")
local player = game:GetService("Players").LocalPlayer
local character = player.Character
local humanoid = character:FindFirstChild("Humanoid")
local humanoidRoot = character:WaitForChild("HumanoidRootPart")

-- Pathfinding Variables
local pathFinding = game:GetService("PathfindingService")

-- Function to move character to given position
function goTo(pos)
   local path = pathFinding:CreatePath() -- path to desired position
   path:ComputeAsync(humanoidRoot.Position, pos) -- computing path to position

   local waypoints = path:GetWaypoints() -- getting all waypoints of path
   
   local guideBallTable = {}

   for index, waypoint in pairs(waypoints) do -- creating guide balls to visualise path being calculated
      wait(0.01)
      local part = Instance.new("Part")
      part.Name = "GuideBall"
      part.Shape = "Ball"
      part.Color = Color3.fromRGB(255,0,0)
      part.Material = "Neon"
      part.Size = Vector3.new(0.6, 0.6, 0.6)
      part.Position = waypoint.Position + Vector3.new(0,5,0)
      part.Anchored = true
      part.CanCollide = false
      part.Parent = workspace

      table.insert(guideBallTable, part) -- adding to table so i can destroy at end of script
   end

   for index, waypoint in pairs(waypoints) do
      if waypoint.Action == Enum.PathWaypointAction.Jump then -- Detecting if character needs to jump
         humanoid:ChangeState(Enum.HumanoidStateType.Jumping) -- Making character jump
      end

      humanoid:MoveTo(waypoint.Position)
      humanoid.MoveToFinished:Wait(1)
   end

   for index, guideBall in pairs(guideBallTable) do -- destroying all balls made
      guideBall:Destroy()
   end
end


print("goTo function loaded")

goTo(player.SpawnPos.Value.Position)