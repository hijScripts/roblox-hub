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

-- Analyse desc of task
function analyseDesc(desc)
    local tempItem = "" -- variable to return what i need to collect/obtain/etc
    local tempField = "" -- variable to return what field i need to be in

    for word in string.gmatch(desc, "%a+") do
        if word == "Collect" then
            tempItem = "Pollen"
            tempField = "field"

            return {tempItem, tempField}
        end
    end

    return nil
end

print("analyseDesc function loaded")

-- Complete a task
function completeTask(item, field)
    print(item, field.Name)
end

print("completeTask function loaded")

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