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
    autoFarmTab = Window:AddTab({ Title = "AutoFarm", Icon = "" }),
    autoQuestTab = Window:AddTab({ Title = "AutoQuest", Icon = "" }),
    autoMobTab = Window:AddTab({ Title = "AutoMob", Icon = "" }),
    teleportTab = Window:AddTab({ Title = "Teleports", Icon = "" })
}

local Options = Fluent.Options

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

-- -- Tween Variables
-- local tweenService = game:GetService("TweenService")
-- local tweenInfo = TweenInfo.New(3)

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

-- Variable for all toggles
local toggleList = {}

-- Variable for menus
local menu = player.PlayerGui.ScreenGui:FindFirstChild("Menus")
local menuOptions = menu.Children:GetChildren()

-- Anti AFK
player.Idled:connect(function()
virtualUser:CaptureController()virtualUser:ClickButton2(Vector2.new())
end)

-- Allowing pathfinding to go through invisible walls / objects / etc
for index, ballBarrier in ipairs(game.workspace:GetDescendants()) do
    if ballBarrier:IsA("BasePart") and ballBarrier.CollisionGroup == "BoostBallBarrier" then
        print("Found barrier")
        ballBarrier.CanCollide = false
    end
end

for index, ball in ipairs(game.Workspace.BoostBalls:GetChildren()) do
    if ball.CanCollide == true then
        ball.CanCollide = false
    end
end

-- Get Selected Menu frame
function getFrame(name)
    for index, option in ipairs(menuOptions) do
        if option.Name == name then
            return option
        end
    end
end

-- Auto Farm Function
function autoFarm() -- weapon cd maybe? 
    local pos = humanoidRoot.Position

    if touchingFlower(pos) then
        require(game.ReplicatedStorage.Collectors.LocalCollect).Run()
   end
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
    for index, quest in ipairs(questList) do
        local taskList = quest:GetChildren()

        -- 4. Categorize each task
        for index, task in ipairs(taskList) do
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
    -- for _, quest in ipairs(field_Quests) do
    --     print(" - " .. quest)
    -- end

    -- print("Food_Quest:")
    -- for _, quest in ipairs(food_Quests) do
    --     print(" - " .. quest)
    -- end

    -- print("Mob_Quest:")
    -- for _, quest in ipairs(mob_Quests) do
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

    for index, quest in ipairs(questList) do
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
    for index, fieldTask in ipairs(fieldTasks) do
        for index, field in ipairs(fields) do
            if string.find(fieldTask, field.Name:match("^([%w]+)")) then
                print("Found " .. field.Name:match("^([%w]+)") .. " in " .. fieldTask)
                for index, task in ipairs(taskList) do
                    if task.Name ~= "TitleBar" and task.Name ~= "TextLabel" and task.Name ~= "TitleBarBG" then
                        if string.find(task.Description.ContentText, field.Name) then
                            print("Found " .. fieldTask .. " in " .. task.Description.ContentText)
                            if not checkIfCompleted(task) then
                                print("going to field")
                                goTo(field.Position)
                                repeat
                                    task.wait()
                                    autoFarm()
                                    task.wait()
                                    if Options.autoSellToggle.Value == true then autoSell() end
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
        task.wait()
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
    

    for index, quest in ipairs(quests) do -- Going through each quest and checking task individually
        if quest.Name == "QuestBox" then
            local tasks = {} -- table to go over tasks in each quest

            for index, task in quest:GetChildren() do -- loop to get rid of unnecessary children
                if task.Name == "TaskBar" then
                    table.insert(tasks, task)
                end
            end

            local i = 0 -- number of completed tasks
            local numOfTasks = #tasks


            for index, task in ipairs(tasks) do 
                if task.Name == "TaskBar" then -- getting rid of non-task children
                    if #task.FillBar:GetChildren() >= 1 then -- if length found, task is complete
                        i = i + 1
                    end
                end
            end

            if i == numOfTasks then
                for index, npc in ipairs(npcs) do
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
        print("success: ", success)
        if not success then -- if fails, warn console
            print("Pathfind compute path error: " .. errorMessage)
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
                        reachedConnection = nil -- you need to manually set this to nil because calling disconnect function does not make the variable to be nil.
                        pathBlockedConnection = nil
                    end
                end)
            end

            pathBlockedConnection = path.Blocked:Connect(function(waypointNumber)
                if waypointNumber > currentWaypointIndex then -- blocked path is ahead of the BoostBallBarrier
                    -- reachedConnection:Disconnect()
                    -- pathBlockedConnection:Disconnect()
                    -- reachedConnection = nil
                    -- pathBlockedConnection = nil
                    goTo(targetPos) -- new path
                end
            end)
            
            humanoid:MoveTo(waypoints[currentWaypointIndex].Position) -- move to the nth waypoint
            if waypoints[currentWaypointIndex].Action == Enum.PathWaypointAction.Jump then
                humanoid.Jump = true
            end

        else -- if the path can't be computed between two points, do nothing!
            print("Error:", path.Status)
        end
    else -- this only runs IF the function has problems computing the path in its backend, NOT if a path can't be created between two points.
        print("Pathfind compute retry maxed out, error: " .. errorMessage)
        return
    end

    repeat
        task.wait()
    until (humanoidRoot.Position - targetPos).Magnitude < 10
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
    if backpackFull() then -- Backpack capacity check
        local pos = humanoidRoot.Position

        goTo(player.SpawnPos.Value.Position)

        task.wait(1.5)

        local args = {
            [1] = "ToggleHoneyMaking"
        }
        game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("PlayerHiveCommand"):FireServer(unpack(args))

        repeat -- this repeat segment prevents AI from moving back to field POS before backpack empty.
            task.wait()
        until player.CoreStats.Pollen.Value / player.CoreStats.Capacity.Value <= 0

        task.wait(5) -- Getting last drops of pollen out

        goTo(pos) -- Returning to original position
    end
end

-- Populate list with all fields
function populateList(list)
    local itemList = {"Empty"} -- list to return of all fields

    for index, item in ipairs(list) do
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
    for index, hive in ipairs(hives) do
        if tostring(hive.Owner.Value) == player.Name then
            return true
        else
            return false
        end 
    end
end

-- Checks if in field
function inField(farmField)
    for index, field in ipairs(fields) do
        if field.Name == farmField then
            local mag = math.floor((humanoidRoot.Position - field.Position).Magnitude) -- getting distance between humanoid and field centre
            if mag <= 45 and touchingFlower(humanoidRoot.Position) then
                return true
            end
        end
    end

    return false
end

-- Checks for nearby monster
function checkForMonster()
    -- Variable for mobs
    local mobFolder = workspace.Monsters
    local mobs = mobFolder:GetChildren()

    if #mobs > 0 then -- Making sure there are mobs
        for index, mob in mobs do
            if mob:FindFirstChild("HumanoidRootPart") then
                local mag = math.floor((humanoidRoot.Position - mob.HumanoidRootPart.Position).Magnitude) -- getting distance between humanoid and field centre
                if mag <= 35 then
                    return true
                end
            end
        end
    end

    return false
end

-- Function to check for vicious bee
function viciousNearby()
    local mobFolder = workspace.Monsters
    local mobs = mobFolder:GetChildren()

    if #mobs > 0 then -- Making sure there are mobs
        for index, mob in mobs do
            if mob.Name:match("Vicious") then
                if mob:FindFirstChild("HumanoidRootPart") then
                    local mag = math.floor((humanoidRoot.Position - mob.HumanoidRootPart.Position).Magnitude) -- getting distance between humanoid and field centre
                    if mag <= 50 then
                        print("Vicious Bee in area... Fleeing to safety.")
                        -- local pos = {position = Vector3.new(player.SpawnPos.Value.Position.X, player.SpawnPos.Value.Position.Y, player.SpawnPos.Value.Position.Z)}
                        -- local tween = tweenService:Create(humanoidRoot, tweenInfo, pos)
                        -- tween:Play()
                        goTo(player.SpawnPos.Value.Position)

                        repeat
                            task.wait(1)
                        until not mob:FindFirstChild("HumanoidRootPart")
                    end
                end
            end
        end
    end
end

-- Function to check for collectibles

-- Auto collect loot
function collectLoot()
    local collectiblesFolder = workspace.Collectibles
    local collectibles = collectiblesFolder:GetChildren()
    local pos = humanoidRoot.Position

    if #collectibles > 0 then
        for index, collectible in ipairs(collectibles) do
            local mag = math.floor((humanoidRoot.Position - collectible.Position).Magnitude) -- getting distance between humanoid and collectible
            if mag <= 30 and touchingFlower(collectible.Position) then
                goTo(collectible.Position)
                repeat
                    task.wait()
                until collectible.Parent == nil
            end
        end
    end
end

-- Function to auto collect dropped items

-- Auto summon eggs

-- shop TPs

-- auto use abilities

-- Function to follow clouds
function followCloud()
    local cloudFolder = workspace.Clouds
    local clouds = cloudFolder:GetChildren()
    local pos = humanoidRoot.Position
    local fieldClouds = {}

    if #clouds > 0 then
        for index, cloud in ipairs(clouds) do
            if ((pos - cloud.Root.Position).Magnitude) < 50 then
                table.insert(fieldClouds, cloud)
            end
        end
    end

    if #fieldClouds > 0 then
        goTo(fieldClouds[1].Root.Position)
    end
end

-- Check if item is inside a flower tile
function touchingFlower(pos)

    for index, flower in ipairs(flowers) do
        if (pos - flower.Position).Magnitude <= 4 then
            return true
        end
    end

    if touchingGadget(pos) then -- sometimes gadget can take over flower tile which causes issues
        return true
    end

    return false
end

-- Check if human is inside a gadget
function touchingGadget(pos)
    
    for index, gadget in ipairs(gadgets) do
        if (pos - gadget.Position).Magnitude <= 4 then
            return true
        end
    end

    return false
end

-- auto claim badge

--################################# "INJECTING" UI #################################--
do
    Fluent:Notify({
        Title = "Notification",
        Content = "Good on ya",
        SubContent = "You've loaded the best Bee Sim Script lad", -- Optional
        Duration = 5 -- Set to nil to make the notification not disappear
    })

    -- Auto Farm Tab --

    -- Select field dropdown
    local fieldDropdown = Tabs.autoFarmTab:AddDropdown("fieldTP", {
        Title = "Select Field",
        Values = populateList(fields),
        Multi = false,
        Default = 1
    })
    
    -- Enable auto farm toggle
    local farmToggle = Tabs.autoFarmTab:AddToggle("autoFarmToggle", {Title = "Enabled", Default = false})

    -- Auto Swing Toggle
    local swingToggle = Tabs.autoFarmTab:AddToggle("autoSwingToggle", {Title = "Auto Swing", Default = false})

    -- Auto Sell Toggle
    local sellToggle = Tabs.autoFarmTab:AddToggle("autoSellToggle", {Title = "Auto Sell", Default = false})

    -- Auto Pickup Loot Toggle
    local lootToggle = Tabs.autoFarmTab:AddToggle("autoLootToggle", {Title = "Auto Loot Pickup", Default = false})

    -- Auto Follow Cloud Toggle
    local cloudToggle = Tabs.autoFarmTab:AddToggle("autoFollowCloud", {Title = "Auto Follow Cloud", Default = false})

    -- Avoid Vicious Bee Toggle
    local avoidVicious = Tabs.autoFarmTab:AddToggle("autoAvoidVicious", {Title = "Auto Avoid Vicious Bee", Default = false})

    -- Auto Sprinkler Toggle
    local sprinklerToggle = Tabs.autoFarmTab:AddToggle("autoSprinklerToggle", {Title = "Auto Sprinkler", Default = false})

    -- Auto Bubbles Toggle
    local bubblesToggle = Tabs.autoFarmTab:AddToggle("autoBubblesToggle", {Title = "Auto Farm Bubbles", Default = false})

    -- Auto Falling Lights Toggle
    local lightsToggle = Tabs.autoFarmTab:AddToggle("autoLightsToggle", {Title = "Auto Farm Falling Lights", Default = false})

    -- Auto Fuzz Bombs Toggle
    local fuzzToggle = Tabs.autoFarmTab:AddToggle("autoFuzzToggle", {Title = "Auto Fuzz Bombs", Default = false})

    -- Auto Snowbear Toggle
    local snowbearToggle = Tabs.autoFarmTab:AddToggle("autoSnowbearToggle", {Title = "Auto Farm Snow Bear", Default = false})

    -- Auto avoid spikes
    -- Auto Farm script
    farmToggle:OnChanged(function()
        if Options.autoFarmToggle.Value == true then
            task.wait()
            print("Auto farm toggled on.")
            local selectedField = fieldDropdown.Value -- value to check for if user changes field

            -- going to selected field
            if selectedField ~= "Empty" then 
                for index, field in ipairs(fields) do
                    print("Matching " .. field.Name .. " Type : " .. type(field.Name) .. " to " .. selectedField .. " Type : " .. type(field.Name))
                    if field.Name == selectedField then
                        print("Matched " .. field.Name .. " and " .. selectedField)
                        goTo(field.Position) 
                    end
                end
            end 

            repeat
                task.wait()
                local pos = humanoidRoot.Position
                local newSelectedField = fieldDropdown.Value

                -- field change check
                if newSelectedField ~= selectedField then
                    print("Field changed to", selectedField)
                    if newSelectedField ~= "Empty" then
                        for index, field in ipairs(fields) do
                            if field.Name == newSelectedField then
                                goTo(field.Position)
                                selectedField = newSelectedField
                            end
                        end
                    end
                end

                -- Mob nearby check
                if checkForMonster() then print("Mob nearby!") repeat task.wait(0.1) humanoid.Jump = true until not checkForMonster() end -- jumps to avoid being hit by monster

                -- Executing all activated functions
                if Options.autoAvoidVicious.Value == true then viciousNearby() end
                if Options.autoLootToggle.Value == true then collectLoot() end -- checking for nearby loot
                if Options.autoSellToggle.Value == true then autoSell() end -- selling if backpack full
                if Options.autoFollowCloud.Value == true then followCloud() end -- following first cloud in field

                -- Stuck user check
                task.wait()
                if not inField(selectedField) or not touchingFlower(pos) then
                    for index, field in ipairs(fields) do 
                        if field.Name == newSelectedField then
                            print("Returning user to " .. field.Name)
                            goTo(field.Position)
                        end
                    end
                end
            until Options.autoFarmToggle.Value == false
        else
            print("Auto farm toggled off.")
        end
    end)

    -- field selection script
    fieldDropdown:OnChanged(function(value)
        print("Selected: " .. value)
    end)

    -- Auto swing script
    swingToggle:OnChanged(function()
        if Options.autoSwingToggle.Value == true and Options.autoFarmToggle.Value == true then
            print("Auto swing toggled on.")
            repeat
                task.wait()
                autoFarm()
            until Options.autoSwingToggle.Value == false or Options.autoFarmToggle.Value == false
        else
            print("Auto swing toggled off.")
        end
    end)

    -- Auto sell script
    sellToggle:OnChanged(function()
        if Options.autoSellToggle.Value == true then
            print("Auto sell toggled on.")
            if not checkOwnsHive() then claimHive() end -- Making sure user owns a hive otherwise it claims one for them
        else
            print("Auto sell toggled off.")
        end
    end)

    -- Auto pickup loot script
    lootToggle:OnChanged(function()
        if Options.autoLootToggle.Value == true then
            print("Auto pickup loot toggled on.")
        else
            print("Auto pickup loot toggled off.")
        end
    end)

    -- Auto pickup loot script
    cloudToggle:OnChanged(function()
        if Options.autoFollowCloud.Value == true then
            print("Auto follow cloud toggled on.")
        else
            print("Auto follow cloud toggled off.")
        end
    end)

-- Auto Quest Tab --
    -- Auto Quest Toggle
    local questToggle = Tabs.autoQuestTab:AddToggle("autoQuestToggle", {Title = "Auto Quest [BETA]", Default = false})

    -- Auto Claim Quest Toggle
    local claimToggle = Tabs.autoQuestTab:AddToggle("autoClaimToggle", {Title = "Auto Claim Quest [BETA]", Default = false})

    -- Auto quest script
    questToggle:OnChanged(function()
        if Options.autoQuestToggle.Value == true then
            if not checkOwnsHive() then claimHive() end -- Making sure user owns a hive otherwise it claims one for them
            repeat
                autoQuest()
            until Options.autoQuestToggle.Value == false
        end
    end)

    -- Auto claim script
    claimToggle:OnChanged(function()
        if Options.autoClaimToggle.Value == true then
            repeat
                task.wait(0.1)
                getQuestStatus()
            until Options.autoClaimToggle.Value == false
        end
    end)

    -- Auto avoid vicious script
    avoidVicious:OnChanged(function()
        if Options.autoAvoidVicious.Value == true then
            print("Auto avoid vicious toggled on.")
        else
            print("Auto avoid vicious toggled off.")
        end
    end)

-- Auto Mob Tab -- 
    -- Select mob dropdown
    local mobDropdown = Tabs.autoMobTab:AddDropdown("selectMob", {
        Title = "Select Mob",
        Values = {"Mob 1", "Mob 2", "Mob 3", "Mob 4", "Mob 5", "Mob 6"},
        Multi = false,
        Default = 1
    })

    -- Auto Kill Mob 
    local mobToggle = Tabs.autoMobTab:AddToggle("autoMobToggle", {Title = "Auto Kill Mob", Default = false})

    -- Select boss dropdown
    local bossDropdown = Tabs.autoMobTab:AddDropdown("selectBoss", {
        Title = "Select Boss",
        Values = {"Boss 1", "Boss 2", "Boss 3", "Boss 4", "Boss 5", "Boss 6"},
        Multi = false,
        Default = 1
    })

    -- Auto Boss Toggle
    local bossToggle = Tabs.autoMobTab:AddToggle("autoBossToggle", {Title = "Auto Kill Boss", Default = false})

    -- auto boss dropdown
    bossDropdown:OnChanged(function(value)
        task.wait()
    end)

    -- Auto boss toggle
    bossToggle:OnChanged(function()
        if Options.autoBossToggle.Value == true then
            repeat
                task.wait()
            until Options.autoBossToggle.Value == false
        end
    end)

-- Teleport Tab --
    -- Claim Hive Button
    Tabs.teleportTab:AddButton({
        Title = "Claim Hive",
        Description = "Claims an empty hive",
        Callback = function()
            if not checkOwnsHive() then claimHive() end
        end
    })

    -- Go to Hive 
    Tabs.teleportTab:AddButton({
        Title = "Go to Hive",
        Description = "Takes you to your hive",
        Callback = function()
            goTo(player.SpawnPos.Value.Position)
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