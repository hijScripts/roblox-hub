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

-- Function to get position of a field
function getFieldPos(fieldName)
    for index, field in pairs(fields) do
        if field.Name == fieldName then
            return field.Position
        end
    end
end

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

-- Auto Farm Function
function autoFarm() -- weapon cd maybe? 
    game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("ToolCollect"):FireServer()
end

-- Auto Quest
function autoQuest()

    -- 1. Get the quest frame
    local questFrame = getFrame("Quests")

    -- 2. Get list of all quests
    local questList = questFrame.Content:FindFirstChild("Frame"):GetChildren()

    --3. Get all tasks for a quest
    for index, quest in pairs(questList) do
        local taskList = quest:GetChildren()

        -- 4. Check completion status
        for index, task in pairs(taskList) do
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

    for index, npc in pairs(npcList) do
        local name = npc -- name of selected npc
        local tempName = "" -- temp name used to append to list, resets for every npc

        for word in string.gmatch(name, "[^%s]+") do -- removing blank spaces from the name
            tempName = tempName .. word
        end

        table.insert(updatedNpcList, tempName .. "Xmas24")
    end

    for index, npc in pairs(updatedNpcList) do -- Brute force accepting all Xmas 2024 quests
        local args = {
            [1] = npc
        }

        game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("GiveQuest"):FireServer(unpack(args))
    end
end

-- Auto Farm Function
function autoFarm() -- weapon cd maybe? 
    game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("ToolCollect"):FireServer()
end

-- Function to move character to given position
function goTo(pos)
    local path = pathFinding:CreatePath() -- path to desired position
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

        repeat
            capacity = player.CoreStats.Pollen.Value / player.CoreStats.Capacity.Value
        until capacity <= 0

        wait(5)
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
function checkHives()
    for index, hive in pairs(hives) do
        if hive.Owner.Value == player.DisplayName then
            return true
        else
            return false
        end 
    end
end

-- Catch users death to toggle off all cheats
-- function catchDeath()
--     print("You have died!")
--     for toggle in toggleList do 
--         local toggleFunc = toggleList[toggle] -- storing function into a variable so i can toggle off

--         toggleFunc:SetValue(false) -- Turning off all toggles off
--     end
-- end

-- Redeem Code Function
function redeemCode(code)
    local args = {
        [1] = code
    }
    
    game:GetService("ReplicatedStorage"):WaitForChild("Events"):WaitForChild("PromoCodeEvent"):FireServer(unpack(args))
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
        Title = "Go to Hive",
        Description = "Takes you to your hive",
        Callback = function()
            Window:Dialog({
                Title = "Are you sure?",
                Content = "Did you mean to go back to your hive?",
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
        for index, field in pairs(fields) do
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
        for index, npc in pairs(npcs) do
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