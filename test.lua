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
    print("Starting goTo function with position:", pos)

    local path = pathFinding:CreatePath() -- path to desired position
    if not path then
        print("Failed to create path.")
        return
    end
    
    print("Computing path from:", humanoidRoot.Position, "to:", pos)
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

-- Check capacity of backpack
function backpackFull()
    if player.CoreStats.Pollen.Value / player.CoreStats.Capacity.Value >= 1 then
        return true
    end

    return false
end

-- Auto Sell Function
function autoSell() 
    wait(0.5)

    if backpackFull() then -- Backpack capacity check
        wait(0.1)
        goTo(player.SpawnPos.Value.Position)
        wait(0.1)
        local args = {
            [1] = "ToggleHoneyMaking"
        }
        game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("PlayerHiveCommand"):FireServer(unpack(args))

        repeat -- this repeat segment prevents AI from moving back to field POS before backpack empty.
            wait(1)
        until not backpackFull() 

        wait(5) -- Getting last drops of pollen out
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

print("getFrame function loaded")

-- Auto Farm Function
function autoFarm() -- weapon cd maybe? 
    require(game.ReplicatedStorage.Collectors.LocalCollect).Run()
end

print("autoFarm function loaded")

-- Checking status of a quest
function checkIfCompleted(task)
    if #task.FillBar:GetChildren() >= 1 then
        return true
    end

    return false
end

print("checkIfCompleted function loaded")

-- Return all tasks organized into categories
function taskFinder()
    
    -- Tables for categorized tasks
    local mobQuests = {}
    local fieldQuests = {}
    local foodQuests = {}

    -- 1. Get the quest frame
    local questFrame = getFrame("Quests")

    -- 2. Get list of all quests
    local questList = questFrame.Content:FindFirstChild("Frame"):GetChildren()

    -- 3. Get all tasks for each quest
    for index, quest in pairs(questList) do
        local taskList = quest:GetChildren()

        -- 4. Categorize each task
        for index, task in pairs(taskList) do
            if task.Name ~= "TitleBar" and task.Name ~= "TitleBarBG" and task.Name ~= "TextLabel" then -- Ignore the title bar
                local desc = task.Description.ContentText -- Get the description

                -- Handle different task types
                local quantity, itemType, field = desc:match("Collect (%d+[%.,]*%d*)%s*(%a+)%s*from the (%a+)")
                if quantity and itemType and field then
                    print("Inserting ")
                    table.insert(fieldQuests, quantity .. " " .. itemType .. " from " .. field)
                else
                    quantity, itemType = desc:match("Feed (%d+)%s*(%a+)")
                    if quantity and itemType then
                        table.insert(foodQuests, quantity .. " " .. itemType)
                    else
                        quantity, itemType = desc:match("Defeat (%d+)%s*(%a+)")
                        if quantity and itemType then
                            table.insert(mobQuests, "Defeat " .. quantity .. " " .. itemType)
                        end
                    end
                end
            end
        end
    end

    -- 5. Print the organized tasks
    -- print("Field_Quest:")
    -- for _, quest in pairs(field_Quests) do
    --     print(" - " .. quest)
    -- end

    -- print("Food_Quest:")
    -- for _, quest in pairs(food_Quests) do
    --     print(" - " .. quest)
    -- end

    -- print("Mob_Quest:")
    -- for _, quest in pairs(mob_Quests) do
    --     print(" - " .. quest)
    -- end

    return mobQuests, fieldQuests, foodQuests 
end

print("taskFinder function loaded")

-- Auto Quest
function autoQuest()

    -- Quest Frame & List of all Questse
    local questFrame = getFrame("Quests")
    local questList = questFrame.Content:FindFirstChild("Frame"):GetChildren()

    for index, quest in questList do -- Deleting any empty messages from quest list
        if quest.Name == "EmptyMessage" then
            table.remove(questList, index)
        end
    end

    local taskList = {} -- List to hold all task instances

    for index, quest in pairs(questList) do
        local questTasks = quest:GetChildren() -- List of all tasks for related quest

        for index, task in questTasks do
            if task.Name ~= "TitleBar" and task.Name ~= "TextLabel" and task.Name ~= "TitleBarBG" then
                table.insert(taskList, task) -- Adding each individual task to list
            end
        end
    end

    -- 1. Get the tasks required
    local mobTasks, fieldTasks, foodQuests = taskFinder()

    -- 2. Complete field tasks
    for index, fieldTask in pairs(fieldTasks) do
        for index, field in pairs(fields) do
            if string.find(fieldTask, field.Name:match("^([%w]+)")) then
                print("Found " .. field.Name:match("^([%w]+)") .. " in " .. fieldTask)
                for index, task in pairs(taskList) do
                    if task.Name ~= "TitleBar" and task.Name ~= "TextLabel" and task.Name ~= "TitleBarBG" then
                        if string.find(task.Description.ContentText, field.Name) then
                            print("Found " .. fieldTask .. " in " .. task.Description.ContentText)
                            if not checkIfCompleted(task) then
                                goTo(field.CFrame.Position)
                                repeat
                                    wait(0.1)
                                    autoFarm()
                                    wait(0.1)
                                    autoSell()
                                    if humanoidRoot.Position ~= field.CFrame.Position then goTo(field.Position) end -- triggers when selling Pollen
                                until checkIfCompleted(task)
                            end
                        end
                    end
                end
            end
        end
    end

    -- local i = 1
    -- print("** Mob Tasks **")
        
    -- for index, task in mobTasks do
    --     print("Task " .. i .. ": " .. task)
    --     i = i + 1
    -- end

    -- local i = 1
    -- print("** Field Tasks **")

    -- for index, task in fieldTasks do
    --     print("Task " .. i .. ": " .. task)
    --     i = i + 1
    -- end

    -- local i = 1
    -- print("** Food Tasks **")

    -- for index, task in foodQuests do
    --     print("Task " .. i .. ": " .. task)
    --     i = i + 1
    -- end

end

print("autoQuest function loaded")

autoQuest()

print("autoQuest executed")