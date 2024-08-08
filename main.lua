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

-- Variables used for functions handling hives
local hiveFolder = workspace.Honeycombs
local hives = hiveFolder:GetChildren()

-- Variables used for functions handling fields
local fieldsFolder = workspace.FlowerZones
local fields = fieldsFolder:GetChildren()

local redFields = {
    "Mushroom Field",
    "Strawberry Field",
    "Rose Field",
    "Pepper Patch"
}

local blueFields = {
    "Blue Flower Field",
    "Bamboo Field",
    "Pine Tree Forest",
    "Stump Field"
}

local whiteFields = {
    "Dandelion Field",
    "Pineapple Patch",
    "Pumpkin Patch",
    "Coconut Field"
}

local colours = {"Red", "Blue", "White"}

-- Variables used for functions handling FlowerZones
local flowersFolder = workspace.Flowers
local flowers = flowersFolder:GetChildren()

-- Gadget Variables
local gadgetsFolder = workspace.Gadgets
local gadgets = gadgetsFolder:GetChildren()

-- Variable for menus
local menu = player.PlayerGui.ScreenGui:FindFirstChild("Menus")
local menuOptions = menu.Children:GetChildren()

-- Anti AFK
local player = game:GetService("Players").LocalPlayer
player.Idled:connect(function()
virtualUser:CaptureController()virtualUser:ClickButton2(Vector2.new())
end)

-- Allowing pathfinding to go through invisible walls / objects / etc
for index, ballBarrier in ipairs(game.workspace:GetDescendants()) do
    if ballBarrier:IsA("BasePart") and ballBarrier.CollisionGroup == "BoostBallBarrier" then
        ballBarrier.CanCollide = false
    end
end

for index, ball in ipairs(game.Workspace.BoostBalls:GetChildren()) do
    if ball.CanCollide == true then
        ball.CanCollide = false
    end
end

-- Get Selected Menu frame
local function getFrame(name)
    for index, option in ipairs(menuOptions) do
        if option.Name == name then
            return option
        end
    end
end

-- Using user's left click 
local function clickMouse(x, y)
    local click = game:GetService("VirtualInputManager")

    click:SendMouseButtonEvent(x, y, 0, true, nil, 1)
    task.wait(0.1)
    click:SendMouseButtonEvent(x, y, 0, false, nil, 1)
end

-- Opens quest tab and checks for quests
local function checkForQuest()

    -- Variables used for functions handling NPCs
    local npcFolder = workspace.NPCs
    local npcs = npcFolder:GetChildren()
    local questFrame = getFrame("Quests")
    local questContent = questFrame.Content:GetChildren()

    print("Checking if quest tab is open")
    if #questContent <= 0 then -- If length 0 then quest tab will be opened.
        clickMouse(84, 105)

        repeat -- letting frame load before continuing
            task.wait()
            local questContent = questFrame.Content:GetChildren()
        until #questContent > 0
    end

    local quests = questFrame.Content.Frame:GetChildren()

    print("Checking if quest count is less than 0")
    if #quests <= 0 then -- If no quests, returning false
        return false
    else
        return true
    end
end

-- Checking status of a task
local function checkTaskStatus(task)
    if #task.FillBar:GetChildren() >= 1 then
        return true
    else
        return false
    end
end

-- checking status of a quest
local function checkQuestStatus(quest)

    local tasks = {}
    
    for index, task in ipairs(quest:GetChildren()) do
        if task.Name == "TaskBar" then
            table.insert(tasks, task)
        end
    end

    local amountToBeCompleted = #tasks
    local tasksCompleted = 0

    for index, task in ipairs(tasks) do
        if checkTaskStatus(task) then
            tasksCompleted = tasksCompleted + 1
        end
    end

    print("Amount of tasks completed:", tasksCompleted, "/", amountToBeCompleted)
    if tasksCompleted == amountToBeCompleted then
        return true
    else
        return false
    end
end

-- Return all tasks organized into categories
local function taskSorter()
    
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
            if task.Name == "TaskBar" then -- Ignore the title bar
                if not checkTaskStatus(task) then
                    local desc = task.Description.ContentText -- Get the description

                    -- Handle different task types
                    local quantity, itemType, field = desc:match("Collect (%d+[%.,]*%d*)%s*(%a+)%s*from the (%a+)")
                    if quantity and itemType and field then
                        table.insert(fieldQuests, quantity .. " " .. itemType .. " from " .. field)
                    else
                        local quantity, itemType = desc:match("Collect (%d+[%.,]*%d*)%s*(%a+)")
                        if quantity and itemType then

                            -- Remove commas from the quantity and convert it to a number
                            local numericQuantity = quantity:gsub(",", "")
                            table.insert(fieldQuests, numericQuantity .. " " .. itemType)
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
        end
    end

    return mobQuests, fieldQuests, foodQuests 
end

-- Functions to move character to given position
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

-- function to walk user to location
local function goToLocation(locationPos)
    local path = calcPath(locationPos)

    if not path then
        local tweenService = game:GetService("TweenService")
        local tweenInfo = TweenInfo.new(3)
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
    repeat
        task.wait()
    until (humanoidRoot.Position - locationPos).Magnitude < 10
end

-- function to walk user to an item
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
    repeat
        task.wait()
    until (humanoidRoot.Position - itemPos).Magnitude < 10
end

-- Check capacity of backpack
local function backpackFull()
    if player.CoreStats.Pollen.Value / player.CoreStats.Capacity.Value >= 1 then
        return true
    end

    return false
end

-- Auto Sell Function
local function autoSell() 
    if backpackFull() then -- Backpack capacity check
        local pos = humanoidRoot.Position

        goToLocation(player.SpawnPos.Value.Position)

        task.wait(1.5)

        local args = {
            [1] = "ToggleHoneyMaking"
        }
        game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("PlayerHiveCommand"):FireServer(unpack(args))

        repeat -- this repeat segment prevents AI from moving back to field POS before backpack empty.
            task.wait()
        until player.CoreStats.Pollen.Value / player.CoreStats.Capacity.Value <= 0

        task.wait(5) -- Getting last drops of pollen out

        goToLocation(pos) -- Returning to original position
    end
end

-- Populate list with all objects/instances
local function populateList(list)
    local itemList = {"Empty"} -- list to return of all objects/instances

    for index, item in ipairs(list) do
        table.insert(itemList, item.Name)
    end

    return itemList
end

-- Find and Claim a Hive function
local function claimHive()
    for hiveID=1, #hives do
        local args = {
            [1] = hiveID
        }    
        game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("ClaimHive"):FireServer(unpack(args))
    end
end

-- Check if hive exists
local function checkOwnsHive()
    for index, hive in ipairs(hives) do
        if tostring(hive.Owner.Value) == player.Name then
            return true
        else
            return false
        end 
    end
end

-- Checks if in field
local function inField(farmField)
    for index, field in ipairs(fields) do
        if field.Name == farmField then
            local mag = math.floor((humanoidRoot.Position - field.Position).Magnitude) -- getting distance between humanoid and field centre
            if mag <= 100 and touchingFlower(humanoidRoot.Position) then
                return true
            end
        end
    end

    return false
end

-- Checks for nearby monster
local function checkForMonster()
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
local function viciousNearby()
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
                        goToLocation(player.SpawnPos.Value.Position)

                        repeat
                            task.wait()
                        until not mob:FindFirstChild("HumanoidRootPart")
                    end
                end
            end
        end
    end
end

-- Auto summon eggs

-- shop TPs

-- Function to follow clouds
local function followCloud()
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
        goToItem(fieldClouds[1].Root.Position)
    end
end

-- Check if human is inside a gadget
local function touchingGadget(pos)
    
    for index, gadget in ipairs(gadgets) do
        if (pos - gadget.WorldPivot.Position).Magnitude <= 4 then
            return true
        end
    end

    return false
end

-- Check if item is inside a flower tile
local function touchingFlower(pos)

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

-- Auto collect loot
local function collectLoot()
    local collectiblesFolder = workspace.Collectibles
    local collectibles = collectiblesFolder:GetChildren()
    local pos = humanoidRoot.Position

    if #collectibles > 0 then
        for index, collectible in ipairs(collectibles) do
            local mag = math.floor((pos - collectible.Position).Magnitude) -- getting distance between humanoid and collectible
            if mag <= 50 and touchingFlower(collectible.Position) then
                goToItem(collectible.Position)
            end
        end
    end
end

-- Function to accept and claim quests.
local function updateQuest(npc)

    -- Variables used for functions handling NPCs
    local npcFolder = workspace.NPCs
    local npcs = npcFolder:GetChildren()

    for index, NPC in ipairs(npcs) do
        if NPC.Name == npc then -- going to selected NPC
            goToLocation(NPC.Circle.Position)

            clickMouse(500, 50) -- Clicking activate button to claim the quest

            local i = 0
            repeat -- clicking through dialog
                task.wait()
                i = i + 1
                clickMouse(666, 503)
            until i > 15

            task.wait(2)

            clickMouse(500, 50) -- Clicking activate button to start the next quest

            local i = 0
            repeat -- clicking through dialog
                task.wait()
                i = i + 1
                clickMouse(666, 503)
            until i > 15
        end
    end
end

-- Auto Farm Function
local function autoFarm() -- weapon cd maybe? 
    local pos = humanoidRoot.Position
    
    if touchingFlower(pos) then
        require(game.ReplicatedStorage.Collectors.LocalCollect).Run()
   end
end

-- Move to random point in field
local function goToRandomPoint()
    local pos = humanoidRoot.Position
    local newPos -- new POS to go to

    repeat -- generating new X & Y coords until they are within the field area
        task.wait()

        local randX = math.random(pos.X - 10, pos.X + 10)
        local randZ = math.random(pos.Z - 10, pos.Z + 10)

        newPos = Vector3.new(randX, pos.Y, randZ)

    until touchingFlower(newPos)

    goToItem(newPos)
end

-- Auto Quest function
local function autoQuest()

    -- Quest Frame & List of all Quests and Tasks
    local questFrame = getFrame("Quests")
    local quests = {}
    local taskList

    -- Variables used for functions handling NPCs
    local npcFolder = workspace.NPCs
    local npcs = npcFolder:GetChildren()

    print("Checking status of quests.")
    if checkForQuest() then
        print("Quests Found! Adding to quests table.")
        for index, quest in questFrame.Content.Frame:GetChildren() do
            if quest.Name:match("QuestBox") then
                table.insert(quests, quest)
            end
        end
    else
        print("No quest found, accepting one now.")
        updateQuest("Black Bear")
    end

    print("Going over all quests to check for any completed ones.")
    for index, quest in ipairs(quests) do -- claiming any quests completed
        if checkQuestStatus(quest) then
            print("Quest completed! Finding NPC of quest.")
            for index, NPC in ipairs(npcs) do

                -- Remove all numbers from NPC.Name
                local modifiedName = NPC.Name:gsub("%d+", "")

                -- Trim leading and trailing whitespace
                modifiedName = modifiedName:match("^%s*(.-)%s*$")

                if quest:FindFirstChild("TaskBar").Description.ContentText:match(modifiedName) then
                    print("Matched the NPC: " .. NPC.Name .. " Claiming quest now.")
                    updateQuest(NPC.Name)

                    print("Removing quest from table")
                    table.remove(quests, index)

                    break -- breaking out of NPC loop as quest is completed
                end
            end
        end
    end

    print("Sorting tasks into 3 lists now.")
    local mobTasks, fieldTasks, foodQuests = taskSorter() -- Sorting incomplete tasks into different lists

    if #fieldTasks > 0 then
        print("Completing field tasks.")
        for index, fieldTask in ipairs(fieldTasks) do
            for index, field in ipairs(fields) do
                local firstWord = field.Name:match("^%S+") -- getting first word of field

                if fieldTask:match(firstWord) then
                    print("Matched: ", firstWord)
                    goToLocation(field.Position)

                    local pollen = player.CoreStats.Pollen.Value
                    local pollenNeeded = fieldTask:match("(%d+[%.,]*%d*)%s*Pollen from")
                    pollenNeeded = pollenNeeded:gsub(",", "")

                    repeat
                        task.wait()
                        local newPollen = player.CoreStats.Pollen.Value
                        local pos = humanoidRoot.Position

                        if checkForMonster() then print("Mob nearby!") repeat task.wait(0.1) humanoid.Jump = true until not checkForMonster() end -- jumps to avoid being hit by monster

                        autoSell()
                        collectLoot()
                        goToRandomPoint()

                        autoFarm()
                    until pollen + tonumber(pollenNeeded) < newPollen

                    break
                elseif fieldTask:match("Red") then
                    print("Farming red pollen")

                    for index, field in ipairs(fields) do
                        if field.Name == redFields[3] then
                            goToLocation(field.Position)
                        end
                    end

                    local pollen = player.CoreStats.Pollen.Value
                    local pollenNeeded = fieldTask:match("(%d+)")
                    pollenNeeded = pollenNeeded:gsub(",", "")

                    repeat
                        task.wait()
                        local newPollen = player.CoreStats.Pollen.Value

                        if checkForMonster() then print("Mob nearby!") repeat task.wait(0.1) humanoid.Jump = true until not checkForMonster() end -- jumps to avoid being hit by monster

                        autoSell()
                        collectLoot()
                        goToRandomPoint()

                        autoFarm()
                    until pollen + tonumber(pollenNeeded) < newPollen

                    break
                elseif fieldTask:match("Blue") then
                    print("Farming blue pollen")
                    
                    for index, field in ipairs(fields) do
                        if field.Name == blueFields[3] then
                            goToLocation(field.Position)
                        end
                    end

                    local pollen = player.CoreStats.Pollen.Value
                    local pollenNeeded = fieldTask:match("(%d+)")
                    pollenNeeded = pollenNeeded:gsub(",", "")

                    repeat
                        task.wait()
                        local newPollen = player.CoreStats.Pollen.Value

                        if checkForMonster() then print("Mob nearby!") repeat task.wait(0.1) humanoid.Jump = true until not checkForMonster() end -- jumps to avoid being hit by monster

                        autoSell()
                        collectLoot()
                        goToRandomPoint()

                        autoFarm()
                    until pollen + tonumber(pollenNeeded) < newPollen

                    break
                elseif fieldTask:match("White") then
                    print("Farming white pollen")
                    
                    for index, field in ipairs(fields) do
                        if field.Name == whiteFields[3] then
                            goToLocation(field.Position)
                        end
                    end

                    local pollen = player.CoreStats.Pollen.Value
                    local pollenNeeded = fieldTask:match("(%d+)")
                    pollenNeeded = pollenNeeded:gsub(",", "")

                    repeat
                        task.wait()
                        local newPollen = player.CoreStats.Pollen.Value

                        if checkForMonster() then print("Mob nearby!") repeat task.wait(0.1) humanoid.Jump = true until not checkForMonster() end -- jumps to avoid being hit by monster

                        autoSell()
                        collectLoot()
                        goToRandomPoint()

                        autoFarm()
                    until pollen + tonumber(pollenNeeded) < newPollen
                    break
                elseif fieldTask:match("^Collect%s%d[%d,]*%sPollen$") then
                    print("Farming ANY pollen")

                    for index, field in ipairs(fields) do
                        if field.Name == redFields[3] then
                            goToLocation(field.Position)
                        end
                    end

                    local pollen = player.CoreStats.Pollen.Value
                    local pollenNeeded = fieldTask:match("(%d+)")
                    pollenNeeded = pollenNeeded:gsub(",", "")

                    repeat
                        task.wait()
                        local newPollen = player.CoreStats.Pollen.Value

                        if checkForMonster() then print("Mob nearby!") repeat task.wait(0.1) humanoid.Jump = true until not checkForMonster() end -- jumps to avoid being hit by monster

                        autoSell()
                        collectLoot()
                        goToRandomPoint()

                        autoFarm()
                    until pollen + tonumber(pollenNeeded) < newPollen

                    break
                end
            end
        end
    end
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
                        goToLocation(field.Position) 
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
                                goToLocation(field.Position)
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

                -- Going to new POS within the field after all Checks
                goToRandomPoint()

            until Options.autoFarmToggle.Value == false
        else
            print("Auto farm toggled off.")
        end
    end)

    -- Auto swing script
    swingToggle:OnChanged(function()
        if Options.autoSwingToggle.Value == true then
            print("Auto swing toggled on.")
            repeat
                task.wait()
                autoFarm()
            until Options.autoSwingToggle.Value == false
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

-- Auto Quest Tab --
    -- Select red farming field
    local redDropdown = Tabs.autoQuestTab:AddDropdown("selectRedField", {
        Title = "Select Red Field",
        Values = redFields,
        Multi = false,
        Default = 1
    })

    -- Select red farming field
    local blueDropdown = Tabs.autoQuestTab:AddDropdown("selectBlueField", {
        Title = "Select Blue Field",
        Values = blueFields,
        Multi = false,
        Default = 1
    })

    -- Select white farming field
    local whiteDropdown = Tabs.autoQuestTab:AddDropdown("selectWhiteField", {
        Title = "Select White Field",
        Values = whiteFields,
        Multi = false,
        Default = 1
    })

    -- Auto Quest Toggle
    local questToggle = Tabs.autoQuestTab:AddToggle("autoQuestToggle", {Title = "Auto Quest [BETA]", Default = false})

    -- Auto quest script
    questToggle:OnChanged(function()
        if Options.autoQuestToggle.Value and Options.autoQuestToggle.Value == true then
            if not checkOwnsHive() then claimHive() end -- Making sure user owns a hive otherwise it claims one for them
            repeat
                task.wait()
                autoQuest()
            until Options.autoQuestToggle.Value == false
        else
            task.wait(1)
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

    -- Auto boss toggle
    bossToggle:OnChanged(function()
        if Options.autoBossToggle.Value and Options.autoBossToggle.Value == true then
            repeat
                task.wait()
            until Options.autoBossToggle.Value == false
        else
            task.wait(1)
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
            goToLocation(player.SpawnPos.Value.Position)
        end
    })

    -- Field dropdown
    local fieldTP = Tabs.teleportTab:AddDropdown("FieldTeleport", {
        Title = "Select Field",
        Values = populateList(fields),
        Multi = false,
        Default = 1
    })


    -- field on change
    fieldTP:OnChanged(function(value)
        for index, field in ipairs(fields) do
            if field.Name == value then
                goToLocation(field.Position)
            end
        end
    end)

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