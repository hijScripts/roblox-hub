-- Player Variables
local workspace = game:GetService("Workspace")
local player = game:GetService("Players").LocalPlayer
local character = player.Character
local humanoid = character:WaitForChild("Humanoid")
local humanoidRoot = character:WaitForChild("HumanoidRootPart")

local pathFinding = game:GetService("PathfindingService")

-- Function to move character to given position
function goTo(pos)
   local path = pathFinding:CreatePath() -- path to desired position
   path:ComputeAsync(humanoidRoot.Position, pos) -- computing path to position

   local waypoints = path:GetWaypoints() -- getting all waypoints of path

   for index, waypoint in pairs(waypoints) do
      if waypoint.Action == Enum.PathWaypointAction.Jump then -- Detecting if character needs to jump
         humanoid:ChangeState(Enum.HumanoidStateType.Jumping) -- Making character jump
      end

      humanoid:MoveTo(waypoint.Position)
      humanoid.MoveToFinished:Wait(1)
   end
end

print("goTo function loaded")

goTo(player.SpawnPos.Value.Position)