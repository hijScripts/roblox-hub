-- Player Variables
local workspace = game:GetService("Workspace")
local player = game:GetService("Players").LocalPlayer
local character = player.Character
local humanoid = character:FindFirstChild("Humanoid")
local humanoidRoot = player.Character.HumanoidRootPart

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

-- Code table
codes = {"summersmas", "15MMembers", "WalmartToys", "WeekExtension",
"38217", "Banned", "BeesBuzz123", "BopMaster", "Buzz", "CarmenSanDiego", 
"ClubBean", "ClubConverters", "Cog", "Connoisseur", "Crawlers", "Cubly", "Dysentery",
"GumdropsForScience", "Jumpstart", "Luther", "Marshmallow", "Millie", "Nectar", "Roof", 
"SecretProfileCode", "Sure", "Troggles", "Wax", "WordFactory", "Wink", "DarzethDoodads", 
"ThnxCyasToyBox"}


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
    teleportTab = Window:AddTab({ Title = "Teleports", Icon = "" })
}

local Options = Fluent.Options

-- Get Selected Menu frame
function getFrame(name)
    for index, option in ipairs(menuOptions) do
        if option.Name == name then
            return option
        end
    end
end

-- Determing if function is into
function isInt(char)
    local numList = {"1", "2", "3", "4", "5", "6", "7", "8", "9", "0"} -- List of integers to compare to char passed through

    for index, value in ipairs(numList) do
        if value == char then
            return true
        end
    end

    return false
end

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

-- Complete a task
function completeTask(item, field)
    print(item, field.Name)
end

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

-- Auto Holiday Quest Function
function autoHolidayQuest()
    local npcList = populateList(npcs) -- List of NPCs
    local updatedNpcList = {} -- List to store the name of each npc with no spaces

    for index, npc in ipairs(npcList) do
        local name = npc -- name of selected npc
        local tempName = "" -- temp name used to append to list, resets for every npc

        for word in string.gmatch(name, "[^%s]+") do -- removing blank spaces from the name
            tempName = tempName .. word
        end

        table.insert(updatedNpcList, tempName .. "Xmas24")
    end

    for index, npc in ipairs(updatedNpcList) do -- Brute force accepting all Xmas 2024 quests
        local args = {
            [1] = npc
        }

        game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("GiveQuest"):FireServer(unpack(args))
    end
end

-- Auto Farm Function
function autoFarm()
    game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("ToolCollect"):FireServer()
end

-- Auto Sell Function
function autoSell()
    wait(0.5)
    local capacity = player.CoreStats.Pollen.Value / player.CoreStats.Capacity.Value -- Value used to check whether backpack is full or not

    if capacity >= 1 then -- Backpack capacity check
        wait(0.1)
        goTo(player.SpawnPos.Value.Position)
        wait(0.1)
        local args = {
            [1] = "ToggleHoneyMaking"
        }
        game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("PlayerHiveCommand"):FireServer(unpack(args))
        wait(5)
    end
end

-- Teleport Function // takes CFrame as pos
function goTo(pos)
    character:MoveTo(pos)
end

-- Populate list with all fields
function populateList(list)
    local itemList = {} -- list to return of all fields

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
function checkHives()
    for index, hive in ipairs(hives) do
        if hive.Owner.Value == player.DisplayName then
            return true
        else
            return false
        end 
    end
end

-- Catch users death to toggle off all cheats
function catchDeath()
    print("You have died!")
    for toggle in toggleList do 
        local toggleFunc = toggleList[toggle] -- storing function into a variable so i can toggle off

        toggleFunc:SetValue(false) -- Turning off all toggles off
    end
end

-- Redeem Code Function
function redeemCode(code)
    local args = {
        [1] = code
    }
    
    game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("PromoCodeEvent"):FireServer(unpack(args))
end



-- Check item amount // returns amount
-- function checkItemCount(item)
-- 1. find item
-- local eggsMenu = menu.Children.Eggs.Content:WaitForChild("EggRows") -- The list of items in inventory
-- local inv = eggsMenu:GetChildren()

-- for row in inv do
--     print(row)
-- end

-- 2. find count


-- 3. return count

-- end


do
    Fluent:Notify({
        Title = "Notification",
        Content = "Good on ya",
        SubContent = "You've loaded the best Bee Sim Script lad", -- Optional
        Duration = 5 -- Set to nil to make the notification not disappear
    })

    -- Claim Hive Button
    Tabs.mainTab:AddButton({
        Title = "Claim Hive",
        Description = "Claims an empty hive",
        Callback = function()
            Window:Dialog({
                Title = "Claim a hive?",
                Content = "",
                Buttons = {
                    {
                        Title = "Confirm",
                        Callback = function()
                            if not checkHives() then claimHive() end
                        end
                    },
                    {
                        Title = "Cancel",
                        Callback = function()
                            print("Cancelled the dialog.")
                        end
                    }
                }
            })
        end
    })

    -- TP to Hive 
    Tabs.mainTab:AddButton({
        Title = "TP to Hive",
        Description = "Teleports you to your hive",
        Callback = function()
            Window:Dialog({
                Title = "Are you sure?",
                Content = "Did you mean to teleport back to your hive?",
                Buttons = {
                    {
                        Title = "Confirm",
                        Callback = function()
                            if player.Honeycomb then
                                goTo(player.SpawnPos.Value.Position)
                            end
                        end
                    },
                    {
                        Title = "Cancel",
                        Callback = function()
                            print("Cancelled the dialog.")
                        end
                    }
                }
            })
        end
    })
    Tabs.mainTab:AddButton({
        Title = "Redeem All Codes",
        Description = "Redeems all Active Codes",
        Callback = function()
            Window:Dialog({
                Title = "Are you sure?",
                Content = "Do you want to redeem all your codes",
                Buttons = {
                    {
                        Title = "Confirm",
                        Callback = function()
                            for code in codes do
                                wait(0.1)
                                redeemCode(code)
                            end
                        end
                    },
                    {
                        Title = "Cancel",
                        Callback = function()
                            print("Cancelled the dialog.")
                        end
                    }
                }
            })
        end
    })
    -- Auto Farm Toggle
    local farmToggle = Tabs.mainTab:AddToggle("autoFarmToggle", {Title = "Auto Farm", Default = false})
    table.insert(toggleList, Options.autoFarmToggle)

    farmToggle:OnChanged(function()
        if Options.autoFarmToggle.Value == true then
            repeat
                wait(0.5)
                --if character:FindFirstChild("Humanoid").Health <= 0 then catchDeath() end -- catch death
                autoFarm()
            until Options.autoFarmToggle.Value == false
        end
    end)

    -- Auto Sell Toggle
    local sellToggle = Tabs.mainTab:AddToggle("autoSellToggle", {Title = "Auto Sell", Default = false})
    table.insert(toggleList, Options.autoSellToggle)

    sellToggle:OnChanged(function()
        if Options.autoSellToggle.Value == true then
            if not checkHives() then claimHive() end -- Making sure user owns a hive otherwise it claims one for them
            repeat
                wait(0.5)
                --if humanoid.Health <= 0 then catchDeath() end -- catch death
                autoSell()
            until Options.autoSellToggle.Value == false
        end
    end)

    -- Auto Xmas Quests
    Tabs.mainTab:AddButton({
        Title = "Auto Accept Xmas Quests",
        Description = "Accepts all available Xmas Quests",
        Callback = function()
            Window:Dialog({
                Title = "Are you sure?",
                Content = "Would you like to accept all Xmas Quests?",
                Buttons = {
                    {
                        Title = "Confirm",
                        Callback = function()
                            --if humanoid and humanoid.Health >= 0 then -- Checking to ensure user is alive to avoid breaking
                                autoHolidayQuest()
                            end
                        --end
                    },
                    {
                        Title = "Cancel",
                        Callback = function()
                            print("Cancelled the dialog.")
                        end
                    }
                }
            })
            
        end
    })

    -- Flower Zones TP
    local zoneDropdown = Tabs.teleportTab:AddDropdown("zoneTP", {
        Title = "Flower Zones TP",
        Values = populateList(fields),
        Multi = false,
        Default = 1
    })

    zoneDropdown:OnChanged(function(value)
        for index, field in ipairs(fields) do
            if field.Name == value then
                goTo(field.Position)
            end
        end
    end)

    -- NPC TP
    local npcDropdown = Tabs.teleportTab:AddDropdown("npcTP", {
        Title = "NPC TP",
        Values = populateList(npcs),
        Multi = false,
        Default = 1
    })

    npcDropdown:OnChanged(function(value)
        for index, npc in ipairs(npcs) do
            if npc.Name == value then
                goTo(npc.Circle.Position)
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
--     [1] = "Black Bear",
--     [2] = 6,
--     [3] = "Ongoing"
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