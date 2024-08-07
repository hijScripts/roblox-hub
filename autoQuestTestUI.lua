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

-- Get Selected Menu frame
local function getFrame(name)
    for index, option in ipairs(menuOptions) do
        if option.Name == name then
            return option
        end
    end
end

-- Return all tasks organized into categories
local function taskFinder()
    
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

-- Checking for quests
local function checkForQuest()
    local questFrame = getFrame("Quests")
    local quests = questFrame.Content:GetChildren()

    if #quests <= 0 then
        clickMouse(84, 105)
    end
end

-- Checking status of a quest
local function checkIfCompleted(task)
    if #task.FillBar:GetChildren() >= 1 then
        return true
    end

    return false
end

do
    Tabs.autoQuestTab:AddButton({
        Title = "Check Quest",
        Description = "Checks quest status",
        Callback = function()
            checkForQuest()
        end 
    })
end