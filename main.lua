-- UI Library Variable
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

-- Loading UI 
local Window = Fluent:CreateWindow({
    Title = "Fluent " .. Fluent.Version,
    SubTitle = "by dawid",
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 460),
    Acrylic = false, -- The blur may be detectable, setting this to false disables blur entirely
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.LeftControl -- Used when theres no MinimizeKeybind
})

-- Creating Tabs
local Tabs = {
    mainTab = Window:AddTab({ Title = "Main", Icon = "" }),
    autoFarmTab = Window:AddTab({ Title = "AutoFarm", Icon = "" }),
    teleportTab = Window:AddTab({ Title = "Teleports", Icon = "" })
}

local Options = Fluent.Options

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

-- Get Selected Menu frame
function getFrame(name)
    for index, option in pairs(menuOptions) do
        if option.Name == name then
            return option
        end
    end
end

-- Auto Farm Function
function autoFarm() -- weapon cd maybe? 
    require(game.ReplicatedStorage.Collectors.LocalCollect).Run()
end

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
            if task.Name ~= "TitleBar" and task.Name ~= "TextLabel" and task.Name ~= "TitleBarBG" then -- Ignore the title bar
                local desc = task.Description.ContentText -- Get the description

                -- Handle different task types
                local quantity, itemType, field = desc:match("Collect (%d+[%.,]*%d*)%s*(%a+)%s*from the (%a+)")
                if quantity and itemType and field then
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

-- Checking status of a quest
function checkIfCompleted(task)
    if #task.FillBar:GetChildren() >= 1 then
        return true
    end

    return false
end

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
                                print("going to field")
                                goTo(field.Position)
                                repeat
                                    wait(0.1)
                                    autoFarm()
                                    wait(0.1)
                                    if Options.autoSellToggle.Value == true then 
                                        autoSell() 
                                        goTo(field.Position)
                                    end
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

-- Auto Holiday Quest Function
function claimQuest(npc)

    local questNum = 0 -- number to iterate with
    while questNum <= 20 do
        wait(0.1)
        print("Attempting to claim Quest Number: " .. questNum)
        local args = {
            [1] = npc,
            [2] = questNum, -- brute forcing quest number
            [3] = "Completed"
        }

        game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("GiveQuest"):FireServer(unpack(args))

        questNum = questNum + 1
    end
end

-- Check all quest status
function getQuestStatus()
    local questFrame = getFrame("Quests")
    local quests = questFrame.Content:FindFirstChild("Frame"):GetChildren()
    

    for index, quest in pairs(quests) do -- Going through each quest and checking task individually
        if quest.Name == "QuestBox" then
            local tasks = {} -- table to go over tasks in each quest

            for index, task in quest:GetChildren() do -- loop to get rid of unnecessary children
                if task.Name == "TaskBar" then
                    table.insert(tasks, task)
                end
            end

            local i = 0 -- number of completed tasks
            local numOfTasks = #tasks


            for index, task in pairs(tasks) do 
                if task.Name == "TaskBar" then -- getting rid of non-task children
                    if #task.FillBar:GetChildren() >= 1 then -- if length found, task is complete
                        i = i + 1
                    end
                end
            end

            if i == numOfTasks then
                for index, npc in pairs(npcs) do
                    if npc.Name ~= "Honey Bee" then
                        if tasks[1].Description.ContentText:match(npc.Name) then
                            print("Claiming quest for " .. npc.Name)
                            goTo(npc.Platform.Position)
                            claimQuest(npc.Name)
                        end
                    end
                end
            end
        end
    end
end

-- Auto Farm Function
function autoFarm() -- weapon cd maybe? 
    require(game.ReplicatedStorage.Collectors.LocalCollect).Run()
end

-- Function to move character to given position
function goTo(pos)
    print("Starting goTo function with position:", pos)

    for index, item in pairs(game.workspace:GetDescendants()) do
        if item:IsA("BasePart") and item.CollisionGroup == "BoostBallBarrier" then
            item.CanCollide = false
        end
    end

    local path = pathFinding:CreatePath() -- path to desired position

    if not path then
        print("Failed to create path.")
        return
    end

    print("Computing path from:", humanoidRoot.Position, "to:", pos)
    path:ComputeAsync(humanoidRoot.Position, pos) -- computing path to position

    if path.Status ~= Enum.PathStatus.Success then
        print("Path computation failed with status:", path.Status)
        return
    end

    local waypoints = path:GetWaypoints() -- getting all waypoints of path
    if #waypoints == 0 then
        print("No waypoints found.")
        return
    end

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
        humanoid.MoveToFinished:Wait(0.001)
    end

    for index, guideBall in pairs(guideBallTable) do -- destroying all balls made
       guideBall:Destroy()
    end

    wait(1)
end

-- Check capacity of backpack
function backpackFull()
    if player.CoreStats.Pollen.Value / player.CoreStats.Capacity.Value >= 1 then
        return true
    end

    return false
end

-- Auto Sell Function
function autoSell() 

    wait(1) -- gives time for humanoid to get onto platform

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
        until player.CoreStats.Pollen.Value / player.CoreStats.Capacity.Value <= 0

        wait(5) -- Getting last drops of pollen out
    end
end

-- Populate list with all fields
function populateList(list)
    local itemList = {"Empty"} -- list to return of all fields

    for index, item in pairs(list) do
        table.insert(itemList, item.Name)
    end

    return itemList
end

-- Find and Claim a Hive function
function claimHive()
    for hiveID=1, #hives do
        local args = {
            [1] = hiveID
        }    
        game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("ClaimHive"):FireServer(unpack(args))
    end
end

-- Check if hive exists
function checkOwnsHive()
    for index, hive in pairs(hives) do
        if hive.Owner.Value == player.DisplayName then
            return true
        else
            return false
        end 
    end
end

-- Function to auto collect dropped items

-- Auto summon eggs

-- Auto upgrade items

-- auto jump when enemy near

-- shop TPs

-- collect token spawns

-- auto use abilities

-- auto under cloud

-- auto claim badge

-- "INJECTING" UI
do
    Fluent:Notify({
        Title = "Notification",
        Content = "Good on ya",
        SubContent = "You've loaded the best Bee Sim Script lad", -- Optional
        Duration = 5 -- Set to nil to make the notification not disappear
    })

    -- Auto Farm Tab --

    -- Enable auto farm toggle
    local autoFarmToggle = Tabs.autoFarmTab:AddToggle("farmToggle", {Title = "Enabled", Default = false})

    -- Select field dropdown
    local fieldDropdown = Tabs.autoFarmTab:AddDropdown("fieldTP", {
        Title = "Select Field",
        Values = populateList(fields),
        Multi = false,
        Default = 1
    })

    -- Auto Sell Toggle
    local sellToggle = Tabs.autoFarmTab:AddToggle("autoSellToggle", {Title = "Auto Sell", Default = false})

    -- Auto Quest Toggle
    local questToggle = Tabs.autoFarmTab:AddToggle("autoQuestToggle", {Title = "Auto Quest [BETA]", Default = false})

    -- Auto Claim Quest Toggle
    local claimToggle = Tabs.autoFarmTab:AddToggle("autoClaimToggle", {Title = "Auto Claim Quest [BETA]", Default = false})

    -- Auto Farm script
    autoFarmToggle:OnChanged(function()
        if Options.farmToggle.Value == true then 
            print("Auto Farm Toggled On") 
        else
            print("Auto Farm Toggled Off")
        end
    end)

    -- field selection script
    fieldDropdown:OnChanged(function(value)
        print("Selected: " .. value)
        if Options.farmToggle.Value == true then
            for index, field in pairs(fields) do
                if field.Name == value then
                    wait(0.1)
                    goTo(field.Position)
                    repeat
                        wait(0.1)
                        autoFarm() -- farms with animation
                        wait(0.1)
                        if Options.autoSellToggle.Value == true then autoSell() end
                        if math.floor(humanoidRoot.Position.Z) ~= math.floor(field.Position.Z) then goTo(field.Position) end
                    until Options.farmToggle.Value == false
                end
            end
            
        end
    end)

    -- Auto sell script
    sellToggle:OnChanged(function()
        if Options.autoSellToggle.Value == true then
            if not checkOwnsHive() then claimHive() end -- Making sure user owns a hive otherwise it claims one for them
        end
    end)

    -- Auto quest script
    questToggle:OnChanged(function()
        if Options.autoQuestToggle.Value == true then
            if not checkOwnsHive() then claimHive() end -- Making sure user owns a hive otherwise it claims one for them
            repeat
                autoQuest()
            until Options.autoQuestToggle.Value == false
        end
    end)

    -- Auto sell script
    claimToggle:OnChanged(function()
        if Options.autoClaimToggle.Value == true then
            repeat
                wait(0.1)
                getQuestStatus()
            until Options.autoClaimToggle.Value == false
        end
    end)

    -- Claim Hive Button
    Tabs.mainTab:AddButton({
        Title = "Claim Hive",
        Description = "Claims an empty hive",
        Callback = function()
            if not checkOwnsHive() then claimHive() end
        end
    })

    -- TP to Hive 
    Tabs.mainTab:AddButton({
        Title = "Go to Hive",
        Description = "Takes you to your hive",
        Callback = function()
            goTo(player.SpawnPos.Value.Position)
        end
    })

    -- Test
    Tabs.mainTab:AddButton({
        Title = "Test Farm",
        Description = "test",
        Callback = function()
            require(game.ReplicatedStorage.Collectors.LocalCollect).Run()
        end
    })
end
-- Update quests
-- local args = {
--     [1] = "Bee Bear 6",
--     [2] = 1,
--     [3] = "Completed"
-- }

-- game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("UpdatePlayerNPCState"):FireServer(unpack(args))

-- local args = {
--     [1] = "Mother Bear",
--     [2] = 4,
--     [3] = "Ongoing"
-- }

-- local args = {
--     [1] = "Sun Bear",
--     [2] = 1,
--     [3] = "Finish"
-- }

-- game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("UpdatePlayerNPCState"):FireServer(unpack(args))


-- Select Option
-- game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("UpdatePlayerNPCState"):FireServer(unpack(args))

-- local args = {
--     [1] = "GivePresentMother BearXmas2024"
-- }

-- Give Quest
-- game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("SelectNPCOption"):FireServer(unpack(args))

-- local args = {
--     [1] = "MotherBearXmas24"
-- }

-- game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("GiveQuest"):FireServer(unpack(args))

-- local args = {
--     [1] = "BlackBearXmas24"
-- }

-- -- game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("GiveQuest"):FireServer(unpack(args))


-- -- treats
-- local args = {
--     [1] = "Purchase",
--     [2] = {
--         ["Type"] = "Treat",
--         ["Category"] = "Eggs",
--         ["Amount"] = 1
--     }
-- }

-- game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("ItemPackageEvent"):InvokeServer(unpack(args))


-- game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("RetrievePlayerStats"):InvokeServer()



-- local args = {
--     [1] = 1,
--     [2] = 3
-- }

-- game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("GetBondToLevel"):InvokeServer(unpack(args))



-- local args = {
--     [1] = 1,
--     [2] = 3,
--     [3] = "Treat",
--     [4] = 1,
--     [5] = false
-- }

-- game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("ConstructHiveCellFromEgg"):InvokeServer(unpack(args))


-- -- collecting badges
-- local args = {
--     [1] = "Collect",
--     [2] = "Playtime"
-- }

-- game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("BadgeEvent"):FireServer(unpack(args))

-- local args = {
--     [1] = "Panda Bear",
--     [2] = 2,
--     [3] = "Finish"
-- }

-- game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("UpdatePlayerNPCState"):FireServer(unpack(args))

-- local args = {
--     [1] = "Rhino Rumble"
-- }

-- game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("CompleteQuest"):FireServer(unpack(args))
--