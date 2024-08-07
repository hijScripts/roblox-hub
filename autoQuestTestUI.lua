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

-- Variables used for functions handling NPCs
local npcFolder = workspace.NPCs
local npcs = npcFolder:GetChildren()

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
end

-- Get Selected Menu frame
local function getFrame(name)
    for index, option in ipairs(menuOptions) do
        if option.Name == name then
            return option
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

    return mobQuests, fieldQuests, foodQuests 
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
    local questFrame = getFrame("Quests")
    local questContent = questFrame.Content:GetChildren()

    print("Checking if quest tab is open")
    if #questContent <= 0 then -- If length 0 then quest tab will be opened.
        clickMouse(84, 105)
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
    end

    return false
end

-- checking status of a quest
local function checkQuestStatus(quest)
    local tasks = quest:GetChildren()

    if #tasks > 0 then
        for index, task in tasks do
            if checkTaskStatus(task) then
                return true
            end
        end
    end

    return false
end

-- Function to accept and claim quests.
local function updateQuest(npc)
    for index, NPC in ipairs(npcs) do
        if NPC.Name == npc then -- going to selected NPC
            goToLocation(NPC.Circle.Position)
        end
    end

    if player.PlayerGui.ScreenGui.ActivateButton.Position.Y.Offset >= 0 then -- if user is on NPC circle, activating dialog
        clickMouse(378, 6)
    else
        repeat
            task.wait()
        until player.PlayerGui.ScreenGui.ActivateButton.Position.Y.Offset >= 0 -- in case goTo function is running behind, halting user until it catches up
        
        clickMouse(378, 6)
    end

    local i = 0
    repeat -- clicking through dialog
        task.wait()
        i = i + 1
        clickMouse(666, 503)
    until i > 10
end

-- Auto Quest
local function autoQuest(npc)

    -- Quest Frame & List of all Quests and Tasks
    local questFrame = getFrame("Quests")
    local quests
    local taskList

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
        updateQuest(npc)
    end

    print("Going over all quests to check for any completed ones.")
    for index, quest in ipairs(quests) do -- claiming any quests completed
        if checkQuestStatus(quest) then
            print("Quest completed! Finding NPC of quest.")
            for index, NPC in ipairs(npcs) do
                if quest:FindFirstChild("TaskBar").Description:match(NPC.Name) then
                    print("Matched the NPC: " .. NPC.Name .. " Claiming quest now.")
                    updateQuest(NPC.Name)
                    table.remove(quests, quests[index])
                end
            end
        end
    end

    print("Sorting tasks into 3 lists now.")
    local mobTasks, fieldTasks, foodQuests = taskSorter() -- Sorting tasks into different lists
end

do
    local autoQ = Tabs.autoQuestTab:AddToggle("autoQuestToggle", {Title = "Auto Quest [BETA]", Default = false})

    autoQ:OnChanged(function()
        if Options.autoQuestToggle.Value == true then
            repeat
                task.wait()
                autoQuest("Bee Bear")
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