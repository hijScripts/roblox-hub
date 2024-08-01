-- Player Variables
local workspace = game:GetService("Workspace")
local player = game:GetService("Players").LocalPlayer
local character = player.Character
local humanoid = character:FindFirstChild("Humanoid")
local humanoidRoot = player.Character.HumanoidRootPart

-- Variable for menus
local menu = player.PlayerGui.ScreenGui:FindFirstChild("Menus")
local menuOptions = menu.Children:GetChildren()

-- Variables used for functions handling hives
local hiveFolder = workspace.Honeycombs
local hives = hiveFolder:GetChildren()

-- Variables used for functions handling fields
local fieldsFolder = workspace.FlowerZones
local fields = fieldsFolder:GetChildren()

-- Variables used for functions handling NPCs
local npcFolder = workspace.NPCs
local npcs = npcFolder:GetChildren()

print("Variables loaded")

-- Get Selected Menu frame
function getFrame(name)
    for index, option in ipairs(menuOptions) do
        if option.Name == name then
            return option
        end
    end
end

print("getFrame function loaded")
--
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

print("analyseDesc function loaded")


-- Teleport Function // takes CFrame as pos
function goTo(pos)
    character:MoveTo(pos)
end

print("goTo function loaded")

-- Function to get position of a field
function getFieldPos(fieldName)
    for index, field in ipairs(fields) do
        if field.Name == fieldName then
            return field.Position
        end
    end
end

print("getFieldPos function loaded")

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

print("completeTask function loaded")

-- Auto Farm Function
function autoFarm() -- weapon cd maybe? 
    game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("ToolCollect"):FireServer()
end

print("autoFarm function loaded")

-- Auto Quest
function autoQuest()

    -- 1. Get the quest frame
    local questFrame = getFrame("Quests")

    -- 2. Get list of all quests
    local questList = questFrame.Content:FindFirstChild("Frame"):GetChildren()

    --3. Get all tasks for a quest
    for index, quest in ipairs(questList) do
        local taskList = quest:GetChildren()

        -- 4. Check completion status
        for index, task in ipairs(taskList) do
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

print("autoQuest function loaded")

autoQuest()

print("Executed autoQuest")