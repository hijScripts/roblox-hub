-- Player Variables
local workspace = game:GetService("Workspace")
local player = game:GetService("Players").LocalPlayer
local character = player.Character
local humanoid = character:FindFirstChild("Humanoid")
local humanoidRoot = character:WaitForChild("HumanoidRootPart")

-- Pathfinding Variables
local pathFinding = game:GetService("PathfindingService")

-- Variables used for functions handling hives
local hiveFolder = workspace.Honeycombs
local hives = hiveFolder:GetChildren()

-- Variables used for functions handling fields
local fieldsFolder = workspace.FlowerZones
local fields = fieldsFolder:GetChildren()

-- Variables used for functions handling NPCs
local npcFolder = workspace.NPCs
local npcs = npcFolder:GetChildren()

-- Variable for all toggles
local toggleList = {}

-- Variable for menus
local menu = player.PlayerGui.ScreenGui:FindFirstChild("Menus")
local menuOptions = menu.Children:GetChildren()

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

-- Get Selected Menu frame
function getFrame(name)
    for index, option in pairs(menuOptions) do
        if option.Name == name then
            return option
        end
    end
end

-- Analyse desc of task
function analyseDesc(desc)
    local descTable = {} -- Table to return values
    local wordsList = {} -- Variable to store words in sentence to access previous words

    for word in string.gmatch(desc, "%a+") do
        table.insert(wordsList, word)

        if word == "Collect" then
            table.insert(descTable, "Pollen")
        end

        if word == "Field" or word == "Patch" or word == "Forest" then
            table.insert(descTable, wordsList[#wordsList - 1] .. " " .. word)

            return descTable
        end
    end

    return nil
end

-- Function to get position of a field
function getFieldPos(fieldName)
    for index, field in pairs(fields) do
        if field.Name == fieldName then
            return field.Position
        end
    end
end

-- Complete a task
function completeTask(item, field)
    local fieldPos = getFieldPos(field) -- Position to move character to

    goTo(fieldPos)

    local i = 0 -- test vari
    while i<10 do
        wait(0.5)
        autoFarm()
        i = i + 1
    end

    print(field .. " Has been farmed.")

end

-- Auto Farm Function
function autoFarm() -- weapon cd maybe? 
    game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("ToolCollect"):FireServer()
end

-- Auto Quest
function autoQuest()

    -- 1. Get the quest frame
    local questFrame = getFrame("Quests")

    -- 2. Get list of all quests
    local questList = questFrame.Content:FindFirstChild("Frame"):GetChildren()

    --3. Get all tasks for a quest
    for index, quest in pairs(questList) do
        local taskList = quest:GetChildren()

        -- 4. Check completion status
        for index, task in pairs(taskList) do
            local tempTask = task
            if tempTask.Name ~= "TitleBar" then -- name of quest irrelevant
                if #tempTask.FillBar:GetChildren() <= 0 then -- Comparing length of list. Completed tasks have length > 0
                    local desc = tempTask.Description.ContentText -- Description of task
                    
                    if analyseDesc(desc) ~= nil then
                        local args = analyseDesc(desc)
                        local item = args[1]
                        local field = args[2]
                        if item ~= nil and field ~= nil then
                            completeTask(item, field)
                        end
                    end
                end
            end
        end
    end
end

autoQuest()