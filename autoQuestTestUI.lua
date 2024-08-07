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
    autoQuestTab = Window:AddTab({ Title = "Auto Quest", Icon = "" }),
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

-- Auto Farm Function
local function autoFarm() -- weapon cd maybe? 
    local pos = humanoidRoot.Position
    
    if touchingFlower(pos) then
        require(game.ReplicatedStorage.Collectors.LocalCollect).Run()
   end
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
    until (humanoidRoot.Position - locationPos).Magnitude < 10
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

-- Function to accept and claim quests.
local function updateQuest(npc)

    -- Variables used for functions handling NPCs
    local npcFolder = workspace.NPCs
    local npcs = npcFolder:GetChildren()

    for index, NPC in ipairs(npcs) do
        if NPC.Name == npc then -- going to selected NPC
            goToLocation(NPC.Circle.Position)

            clickMouse(500, 50) -- Clicking activate button

            local i = 0
            repeat -- clicking through dialog
                task.wait()
                i = i + 1
                clickMouse(666, 503)
            until i > 15
        end
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

    return mobQuests, fieldQuests, foodQuests 
end

-- Auto Quest
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
                print(index)
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
                    goToLocation(field.Position)

                    local i = 0
                    repeat
                        task.wait()
                        i = i + 1
                        autoFarm()
                    until i == 10

                    break
                end
            end
        end
    end
end

do
    local autoQ = Tabs.autoQuestTab:AddToggle("autoQuestToggle", {Title = "Auto Quest [BETA]", Default = false})

    autoQ:OnChanged(function()
        if Options.autoQuestToggle.Value == true then
            repeat
                task.wait()
                autoQuest("Black Bear")
            until Options.autoQuestToggle.Value == false
        end
    end)

    Tabs.autoQuestTab:AddButton({
        Title = "Check Quest",
        Description = "Checks quest status",
        Callback = function()
            checkForQuest()
        end 
    })
end