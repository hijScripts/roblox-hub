-- Anti AFK 

game:GetService('Players').LocalPlayer.Idled:Connect(function()
	game:GetService('VirtualUser'):CaptureController()
	game:GetService('VirtualUser'):ClickButton2(Vector2.new())
end)

-- Library Creation 

local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

local Window = Fluent:CreateWindow({
    Title = "Exceed.gg ",
    SubTitle = "Bee Swarm Simulator 🐝 | BETA",
    TabWidth = 160,
    Size = UDim2.fromOffset(680, 560),
    Acrylic = false, -- The blur may be detectable, setting this to false disables blur entirely
    Theme = "Darker",
    MinimizeKey = Enum.KeyCode.LeftControl -- Used when theres no MinimizeKeybind
})

--Fluent provides Lucide Icons https://lucide.dev/icons/ for the tabs, icons are optional

local Tabs = {
    Main = Window:AddTab({ Title = "Main", Icon = "share-2" }),
	Tab5 = Window:AddTab({ Title = "Farming", Icon = "hammer" }),
	Tab7 = Window:AddTab({ Title = "Combat", Icon = "swords" }),
	Tab6 = Window:AddTab({ Title = "Bees", Icon = "currency" }),
	Tab4 = Window:AddTab({ Title = "Tokens", Icon = "globe" }),
	Tab2 = Window:AddTab({ Title = "Shop", Icon = "dollar-sign" }),
	Tab3 = Window:AddTab({ Title = "Equip", Icon = "user-cog" }),
	Tab1 = Window:AddTab({ Title = "Teleports", Icon = "map" }),
	Tab8 = Window:AddTab({ Title = "Local Player", Icon = "user" }),
	Tab10 = Window:AddTab({ Title = "Information", Icon = "bar-chart-3" }),
    Settings = Window:AddTab({ Title = "Settings", Icon = "settings" })
}

-- Tabs.Settings:AddSection({Title = "Settings"})

-- skip-forward
-- trending-up

local Options = Fluent.Options

do
	Fluent:Notify({
    Title = "Notification",
    Content = "Welcome, " .. game.Players.LocalPlayer.Name .. "!",
    SubContent = "Thanks for using Exceed.gg", -- Optional
    Duration = 5, -- Set to nil to make the notification not disappear
	})

	-- Main 

	Tabs.Main:AddParagraph({
        Title = "🎉 Welcome to Exceed.gg, " .. game.Players.LocalPlayer.Name .. "!",
    })
	Tabs.Main:AddParagraph({
        Title = "🚀 Version: 1.4.0 | BETA",
    })
	Tabs.Main:AddParagraph({
        Title = "🛠️ Updated: 23/10/23",
    })
	Tabs.Main:AddParagraph({
        Title = "📈 Created by: Exceed.gg [Emistary#8759 & kanyeeast7169]",
    })
	Tabs.Main:AddParagraph({
        Title = "🛡️ User Interface: Dawid",
    })

	Tabs.Main:AddParagraph({
        Title = "⚙️ More features will be added next update.",
    })

	-- Variables 

	local player = game.Players.LocalPlayer
	local Client = game.Players.LocalPlayer.Name

	local Players = game:GetService("Players")
	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local Workspace = game:GetService("Workspace")
	local pathfindingService = game:GetService("PathfindingService")
	local VirtualInputManager = game:GetService("VirtualInputManager")

	local Client = player.Name
	local character = player.Character
	local humanoid = character:WaitForChild("Humanoid")
	local rootPart = character:WaitForChild("HumanoidRootPart")

	local QPath = game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.Menus.Children.Quests
	local Click = game:GetService("VirtualInputManager")
	local children = QPath.Content:GetChildren()

	-- Functions 

	local function CalculateBag()
		local coreStats = player:FindFirstChild("CoreStats")
		if coreStats then
			local pollen = coreStats:FindFirstChild("Pollen")
			local capacity = coreStats:FindFirstChild("Capacity")

			if pollen and capacity then
				local pollenValue = pollen.Value
				local capacityValue = capacity.Value

				local percentage = (pollenValue / capacityValue) * 100

				if percentage >= 100 then
					return "Full"
				elseif pollenValue <= 0 then
					return "Empty"
				else
					return "In Between"
				end
			end
		end
	end

	

	-- Red : Mushroom Field, Pepper Field, Rose Field

	-- Blue : Blue Flower Field, Bamboo Field

	-- White : Dandelion Field, Spider Field, Pumpkin Patch

	local function ClaimHives()
		for i = 1, 6 do 
			game:GetService("ReplicatedStorage").Events.ClaimHive:FireServer(i)
		end
	end

	ClaimHives()

	local function autoHarvest()
		pcall(function()
			if Client then 
				local workspaceClient = game:GetService("Workspace")[Client]
				if workspaceClient then
					for _, tool in pairs(workspaceClient:GetChildren()) do 
						if tool:IsA("Tool") then
							for _, toolPart in pairs(tool:GetChildren()) do
								if toolPart:IsA("Script") then
									local env = getsenv(toolPart)
									env.collectStart()
								end
							end
						end
					end
				end
			end
		end)
	end

	local function TeleportToHive()
		for i, v in pairs(game:GetService("Workspace").Honeycombs:GetDescendants()) do
			if v.Name == "Owner" then
				if v.Value == player then
					player.Character.HumanoidRootPart.CFrame = v.Parent.LightHolder.CFrame
				end
			end
		end
	end

	--[[

	local function PathFindToHive()
		for i, v in pairs(game:GetService("Workspace").Honeycombs:GetDescendants()) do
			if v.Name == "Owner" then
				if v.Value == player then
					local targetPosition = v.Parent.LightHolder.Position
					pathfind2(targetPosition, false, 30)
				end
			end
		end
	end

	Tabs.Main:AddButton({
        Title = "eButton",
        Description = "Very important button",
        Callback = function()
            Window:Dialog({
                Title = "Title",
                Content = "This is a dialog",
                Buttons = {
                    {
                        Title = "Confirm",
                        Callback = function()
                            --TeleportToHive()

							PathFindToHive()

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

	--]]


	--PathFindToHive()

	local function StartConvert()
		game:GetService("ReplicatedStorage").Events.PlayerHiveCommand:FireServer("ToggleHoneyMaking")
	end

	local function ClickMouse(x, y)
		local Click = game:GetService("VirtualInputManager")

		Click:SendMouseButtonEvent(x, y, 0, true, nil, 1)
		wait(0.1)
		Click:SendMouseButtonEvent(x, y, 0, false, nil, 1)
	end

	-- Player 

	--Tab8

	local SelectedWalkSpeed
	local SelectedJumpPower

	local WalkSpeedSlider = Tabs.Tab8:AddSlider("Slider", {
		Title = "Walk Speed",
		Default = game.Players.LocalPlayer.Character.Humanoid.WalkSpeed,
		Min = 0,
		Max = 150,
		Rounding = 1,
		Callback = function(Value)
			SelectedWalkSpeed = Value
		end
	})

	WalkSpeedSlider:OnChanged(function(Value)
		if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
			game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = Value
		end
	end)

	local JumpPowerSlider = Tabs.Tab8:AddSlider("Slider", {
		Title = "Jump Power",
		Default = 50,
		Min = 0,
		Max = 150,
		Rounding = 1,
		Callback = function(Value)
			SelectedJumpPower = Value
		end
	})

	JumpPowerSlider:OnChanged(function(Value)
		if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
			game.Players.LocalPlayer.Character.Humanoid.JumpPower = Value
		end
	end)

	local WalkSpeedToggle = Tabs.Tab8:AddToggle("WalkSpeedToggle", {Title = "Loop Set Walk Speed", Default = true,})

	local JumpPowerToggle = Tabs.Tab8:AddToggle("JumpPowerToggle", {Title = "Loop Set Jump Power", Default = false,})

	spawn(function()
		while wait() do
			if game.Players.LocalPlayer.Character and game.Players.LocalPlayer.Character:FindFirstChild("Humanoid") then
				if Options.WalkSpeedToggle.Value == true then
					game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = SelectedWalkSpeed
				end
				if Options.JumpPowerToggle.Value == true then
					game.Players.LocalPlayer.Character.Humanoid.JumpPower = SelectedJumpPower
				end
			end
		end
	end)

	-- Auto Quest Functions 

	local BlackBearQuest = {
		"Black Bear: Just Red",
		"Black Bear: Just Blue",
		"Black Bear: Just White",
		"Black Bear: Any Pollen",
		"Black Bear: A Bit Of Both",
		"Black Bear: The Whole Lot",
		"Black Bear: Fun In The Sunflowers",
		"Black Bear: Blue Flower Bliss",
		"Black Bear: Mission For Mushrooms",
		"Black Bear: Delve Into Dandelions",
		"Black Bear: Leisurely Lowlands",
		"Black Bear: Stroll In The Strawberries",
		"Black Bear: Between The Bamboo",
		"Black Bear: Play In The Pumpkins",
		"Black Bear: Plundering Pineapples",
		"Black Bear: Mid-Level Mission",
		"Sunflower Corral",
		"Black Bear's Ornament",
		"Sunflower Start",
		"Dandelion Deed",
		"Pollen Fetcher",
		"Red Request",
		"Into The Blue",
		"Variety Fetcher",
		"Bamboo Boogie",
		"Red Request 2",
		"Cobweb Sweeper",
		"Leisure Loot",
		"White Pollen Wrangler",
		"Pineapple Picking",
		"Pollen Fetcher 2",
		"Weed Wacker",
		"Red + Blue = Gold",
		"Colorless Collection",
		"Spirit Of Springtime",
		"Weed Wacker 2",
		"Pollen Fetcher 3",
		"Lucky Landscaping",
		"Azure Adventure",
		"Pink Pineapples",
		"Blue Mushrooms",
		"Cobweb Sweeper 2",
		"Rojo-A-Go-Go",
		"Pumpkin Plower",
		"Pollen Fetcher 4",
		"Bouncing Around Biomes",
		"Blue Pineapples",
		"Rose Request",
		"Search For The White Clover",
		"Stomping Grounds",
		"Collecting Cliffside",
		"Mountain Meandering",
		"Quest Of Legends",
		"High Altitude",
		"Blissfully Blue",
		"Rouge Round-up",
		"White As Snow",
		"Solo On The Stump",
		"Colorful Craving",
		"Pumpkins, Please!",
		"Smorgasbord",
		"Pollen Fetcher 5",
		"White Clover Redux",
		"Strawberry Field Forever",
		"Tasting The Sky",
		"Whispy And Crispy",
		"Walk Through The Woods",
		"Get Red-y",
		"One Stop On The Tip Top",
		"Blue Mushrooms 2",
		"Pretty Pumpkins",
		"Black Bear, Why?",
		"Bee A Star",
		"Bamboo Boogie 2: Bamboo Boogaloo",
		"Rocky Red Mountain",
		"Can't Without Ants",
		"The 15 Bee Zone",
		"Bubble Trouble",
		"Sweet And Sour",
		"Rare Red Clover",
		"Low Tier Treck",
		"Okey-Pokey",
		"Pollen Fetcher 6",
		"Capsaicin Collector",
		"Mountain Mix",
		"You Blue It",
		"Variety Fetcher 2",
		"Getting Stumped",
		"Weed Wacker 3",
		"All-Whitey Then",
		"Red Delicacy",
		"Boss Battles",
		"Myth In The Making"
	}

	local MotherBearQuest = {
		"Search For A Spotted Chick",
		"Mother Bear's Ornament",
		"Egg Hunt: Mother Bear",
		"Treat Tutorial",
		"Bonding With Bees",
		"Search For A Sunflower Seed",
		"The Gist Of Jellies",
		"Search For Strawberries",
		"Binging On Blueberries",
		"Royal Jelly Jamboree",
		"Search For Sunflower Seeds",
		"Picking Out Pineapples",
		"Seven To Seven",
		"Mother Bear's Midterm",
		"Eight To Eight",
		"Sights On The Stars",
		"The Family Final"
	}

	local ScienceBearQuest = {
		"Corrupting The Glitched Drive",
		"Science Bear's Ornament",
		"Preliminary Research",
		"Biology Study",
		"Proving The Hypothesis",
		"Bear Botany",
		"Kingdom Collection",
		"Defensive Adaptations",
		"Benefits of Technology",
		"Spider Study",
		"Roses And Weeds",
		"Blue Review",
		"Ongoing Progress",
		"Red / Blue Duality",
		"Costs Of Computation",
		"Pollination Practice",
		"Optimizing Abilities",
		"Ready For Infrared",
		"Breaking Down Badges",
		"Subsidized Agriculture",
		"Meticulously Crafted",
		"Smart, Not Hard",
		"Limits of Language",
		"Patterns and Probability",
		"Chemical Analysis",
		"Mark Mechanics",
		"Meditating On Phenomenon",
		"Beesperanto",
		"Hive Minded Bias",
		"Mushroom Measurement Monotony",
		"The Power Of Information",
		"Testing Teamwork",
		"Epistemological Endeavor"
	}

	local BrownBearQuest = {
		"Brown Bear: Sun-Dand",
		"Brown Bear: Mush-Clove",
		"Brown Bear: Bluf-Clove",
		"Brown Bear: White-Mush",
		"Brown Bear: White-Bluf",
		"Brown Bear: Solo-Clove",
		"Brown Bear: Straw-Spide",
		"Brown Bear: Bamb-Spide",
		"Brown Bear: White-Bamb-Mush",
		"Brown Bear: Red-Straw-Sun",
		"Brown Bear: Blue-Clov-Spide",
		"Brown Bear: Solo-Spide",
		"Brown Bear: Solo-Straw",
		"Brown Bear: Solo-Bamb",
		"Brown Bear: Blue-Pinap-Clov",
		"Brown Bear: Red-Pinap-Dand",
		"Brown Bear: Pinap-Bamb",
		"Brown Bear: Pinap-Straw",
		"Brown Bear: Solo-Cact",
		"Brown Bear: White-Cact-Sun",
		"Brown Bear: Blue-Pump-Bluf",
		"Brown Bear: Red-Cact-Rose",
		"Brown Bear: Blue-Pine-Mush",
		"Brown Bear: White-Pine-Straw",
		"Brown Bear: White-Rose-Bamb",
		"Brown Bear: Red-Pump-Dand",
		"Brown Bear: Red-Mount-Mush",
		"Brown Bear: Blue-Mount-Bluf",
		"Brown Bear: Solo-Mount",
		"Brown Bear: Mount-Spide-Rose-Pinap",
		"Brown Bear: Mount-Bamb-Pump-Sun",
		"Brown Bear: Blue-Coco-Bluf",
		"Brown Bear: Red-Coco-Mush",
		"Brown Bear: White-Pepp-Pinap",
		"Brown Bear: White-Pepp-Bamb",
		"Brown Bear: Coco-Pepp-Clove-Pine",
		"Brown Bear: Coco-Mount-Cact-Rose",
		"Brown Bear: Solo-Coco",
		"Brown Bear: Solo-Stump",
		"Brown Bear: Red-Stump-Mush",
		"Brown Bear: Blue-Stump-Rose"
	}

	local PandaBearQuest = {
		"Lesson On Ladybugs",
		"Rhino Rumble",
		"Beetle Battle",
		"Spider Slayer",
		"Ladybug Bonker",
		"Spider Slayer 2",
		"Rhino Wrecking",
		"Final Showdown",
		"Werewolf Hunter",
		"Skirmish With Scorpions",
		"Mantis Massacre",
		"The REAL Final Showdown"
	}

	local AdditionalQuest = {
    "Solo On The Stump",
    "Colorful Craving",
    "Spirit's Starter",
    "The First Offering",
    "Rules of The Road",
    "QR Quest",
    "Pleasant Pastimes",
    "Nature's Lessons",
    "The Gifts Of Life",
    "Out-Questing Questions",
    "Forcefully Friendly",
    "Sway Away",
    "Memories of Memories",
    "Beans Becoming",
    "Do You Bee-lieve In Magic?",
    "The Ways Of The Winds / The Wind And Its Way",
    "Beauty Duty",
    "Witness Grandeur",
    "Beeternity",
    "A Breath Of Blue",
    "Glory Of Goo",
    "Tickle The Wind",
    "Rhubarb That Could Have Been",
    "Dreams Of Being A Bee",
    "The Sky Over The Stump",
    "Space Oblivion",
    "Pollenpalooza",
    "Dancing With Stick Bug",
    "Bean Bug Busser",
    "Bombs, Blueberries, and Bean Bugs",
    "Bean Bugs And Boosts",
    "Make It Hasty",
    "Total Focus",
    "On Your Marks",
    "Look In The Leaves",
    "What About Sprouts",
    "Bean Bug Beatdown",
    "Bear Without Despair",
    "Spirit Spree",
    "Echoing Call",
    "Spring Out Of The Mountain",
    "Riley Bee: Goo",
    "Riley Bee: Medley",
    "Riley Bee: Mushrooms"
	}

	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local CompleteQuestEvent = ReplicatedStorage.Events.CompleteQuest
	local GiveQuestEvent = ReplicatedStorage.Events.GiveQuest

	local Comp = function(q1)
		for _, questName in pairs(q1) do
			CompleteQuestEvent:FireServer(questName)
		end
	end

	local Give = function(q1)
		for _, questName in pairs(q1) do
			GiveQuestEvent:FireServer(questName)
		end
	end

	
	spawn(function() 
		while wait() do 
			if Options.QuestAuto.Value == true then 
				Comp(BlackBearQuest)
				wait(0.5)
				Give(BlackBearQuest)
				wait(0.5)
				Comp(MotherBearQuest)
				wait(0.5)
				Give(MotherBearQuest)
				wait(0.5)
				Comp(ScienceBearQuest)
				wait(0.5)
				Give(ScienceBearQuest)
				wait(0.5)
				Comp(BrownBearQuest)
				wait(0.5)
				Give(BrownBearQuest)
				wait(0.5)
				Comp(PandaBearQuest)
				wait(0.5)
				Give(PandaBearQuest)
			end
		end
	end)

	-- Combat 

	-- Tab7

	local FarmSnailToggle = Tabs.Tab7:AddToggle("FarmSnail", {Title = "🐌 Farm Snail", Default = false })

	spawn(function()
		while wait() do
			if Options.FarmSnail.Value == true then
				local StumpField = game.Workspace.FlowerZones['Stump Field']
				
				local character = game.Players.LocalPlayer.Character
				if character then
					local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
					if humanoidRootPart and StumpField then
						humanoidRootPart.CFrame = CFrame.new(StumpField.Position.X, StumpField.Position.Y - 6, StumpField.Position.Z)
						wait(250)
					end
				end
			end
		end
	end)

	-- 

	local function teleportToPosition(position)
    local player = game.Players.LocalPlayer
    local character = player.Character
    if character then
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			if humanoidRootPart then
				humanoidRootPart.CFrame = position
			end
		end
	end

	--[[

	local function FarmCommandoChick()
		local spawner = game:GetService("Workspace").MonsterSpawners:FindFirstChild("Commando Chick")
		if spawner then
			local spawnerPosition = spawner.Position

			game.Players.LocalPlayer.Character:MoveTo(spawner.Position)
			
			local platform = Instance.new("Part")
			platform.Anchored = true
			platform.Parent = spawner
			platform.Position = spawnerPosition + Vector3.new(-35, -20, 0)
			platform.Size = Vector3.new(10, 1, 10)
			platform.Color = Color3.new(0.4, 0.4, 0.4)
			platform.Transparency = 0.5

			if not platform.Anchored then
				platform.Anchored = true
			end

			wait(0.1)

			game.Players.LocalPlayer.Character:MoveTo(platform.Position + Vector3.new(0, 3, 0))
		end
	end

	--

	local SpawnersTable = {}

	for _, spawner in pairs(game:GetService("Workspace").MonsterSpawners:GetChildren()) do
		if spawner then
			table.insert(SpawnersTable, spawner.Name)
		end
	end

	local MobFarmDropdown = Tabs.Tab7:AddDropdown("Dropdown", {Title = "👾 Spawners", Values = SpawnersTable, Multi = false, Default = "", })

    MobFarmDropdown:OnChanged(function(Value)
        FarmCommandoChick()
    end)

	--]]

	-- Commando Chick

	local FarmCommandoToggle = Tabs.Tab7:AddToggle("FarmCommando", {Title = "🐥 Farm Commando Chick", Default = false })

	spawn(function()
		while wait() do
			if Options.FarmCommando.Value == true then
				local spawner = game:GetService("Workspace").MonsterSpawners:FindFirstChild("Commando Chick")
				if spawner then
					local v = spawner:GetDescendants("TimerLabel")
					if v and not v.Visible then
						local spawnerPosition = spawner.Position

						game.Players.LocalPlayer.Character:MoveTo(spawner.Position)

						local platform = Instance.new("Part")
						platform.Anchored = true
						platform.Parent = spawner
						platform.Position = spawnerPosition + Vector3.new(-35, -29, 0)
						platform.Size = Vector3.new(10, 1, 10)
						platform.Color = Color3.new(0.4, 0.4, 0.4)
						platform.Transparency = 0.5

						wait(0.1)

						game.Players.LocalPlayer.Character:MoveTo(platform.Position + Vector3.new(0, 2, 0))

						--print("Farming Commando Chick...")

						while Options.FarmCommando.Value == true do
							game.Players.LocalPlayer.Character:MoveTo(platform.Position + Vector3.new(0, 2, 0))
							wait(1)  

							local monsters = game:GetService("Workspace").Monsters:GetChildren()
							local hasCommandoMonsters = false
							for _, monster in pairs(monsters) do
								if string.match(monster.Name, "Commando") then
									hasCommandoMonsters = true
									break
								end
							end

							if not hasCommandoMonsters then
								--print("Commando Chick farming complete.")
								break
							end
						end
					else
						--print("Commando Chick is not ready")
					end
				end
			end
		end
	end)

	-- Tunnel Bear 

	local FarmTunnelBearToggle = Tabs.Tab7:AddToggle("FarmTunnelBear", { Title = "🐻 Farm Tunnel Bear", Default = false })

	spawn(function()
		while wait() do
			if Options.FarmTunnelBear.Value == true then
				local spawner = game:GetService("Workspace").MonsterSpawners:FindFirstChild("TunnelBear")  -- Update the spawner name
				if spawner then
					local v = spawner:GetDescendants("TimerLabel")
					-- game:GetService("Workspace").MonsterSpawners.TunnelBear.TimerAttachment.TimerGui.TimerLabel
					if v and not v.Visible then
						game:GetService("Workspace").Decorations.TrapTunnel["Tunnel Ceiling"]:Destroy()
						game:GetService("Workspace").Decorations.TrapTunnel["Tunnel Ceiling Camo"]:Destroy()

						--local spawnerPosition = spawner.Position
						local spawnerPosition = CFrame.new(Vector3.new(452.0803527832031, 6.783017158508301, -49.59326934814453))

						game.Players.LocalPlayer.Character:MoveTo(spawner.Position)

						local platform = Instance.new("Part")
						platform.Anchored = true
						platform.Parent = spawner
						platform.Position = spawnerPosition.Position + Vector3.new(0, 20, 0)
						platform.Size = Vector3.new(10, 1, 10)
						platform.Color = Color3.new(0.4, 0.4, 0.4)
						platform.Transparency = 0.5

						wait(0.1)

						game.Players.LocalPlayer.Character:MoveTo(platform.Position + Vector3.new(0, 2, 0))

						while Options.FarmTunnelBear.Value == true do
							game.Players.LocalPlayer.Character:MoveTo(platform.Position + Vector3.new(0, 2, 0))
							wait(1)

							local monsters = game:GetService("Workspace").Monsters:GetChildren()
							local hasTunnelBearMonsters = false
							for _, monster in pairs(monsters) do
								if string.match(monster.Name, "Tunnel Bear") then
									hasTunnelBearMonsters = true
									break
								end
							end

							if not hasTunnelBearMonsters then
								break
							end
						end
					end
				end
			end
		end
	end)

	-- Honey Gained 

	local Player = game.Players.LocalPlayer
	local InitialHoney = Player:WaitForChild("CoreStats"):WaitForChild("Honey").Value
	local NewHoney = 0

	local function formatNumberWithCommas(number)
		local formatted = tostring(number)
		local k

		while true do
			formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
			if k == 0 then
				break
			end
		end

		return formatted
	end

	local HoneyLabel = Tabs.Tab10:AddParagraph({
		Title = "🍯 Honey Gained: ",
	})

	local StartTime = tick() -- Record the start time

	local ElapsedTimeLabel = Tabs.Tab10:AddParagraph({
		Title = "⌛ Time Elapsed: 00:00:00",
	})

	function formatTime(seconds)
		local hours = math.floor(seconds / 3600)
		local minutes = math.floor((seconds % 3600) / 60)
		local remainingSeconds = seconds % 60
		return string.format("%02d:%02d:%02d", hours, minutes, remainingSeconds)
	end

	spawn(function()
		while wait() do
			local success, CurrentHoney = pcall(function()
				return Player:WaitForChild("CoreStats"):WaitForChild("Honey").Value
			end)

			if success then
				NewHoney =  CurrentHoney - InitialHoney 
				HoneyLabel:SetTitle("🍯 Honey Gained: " .. formatNumberWithCommas(NewHoney))
			else
				--warn("Failed to get CurrentHoney")
			end

			-- Update elapsed time
			local currentTime = tick()
			local elapsedTime = currentTime - StartTime
			ElapsedTimeLabel:SetTitle("⌛ Time Elapsed: " .. formatTime(math.floor(elapsedTime)))
		end
	end)


	-- Time Label



	-- Bee Count

	local HivePath = game:GetService("Workspace").Honeycombs
	local player = game.Players.LocalPlayer
	local paragraphs = {} 

	local newParagraph = Tabs.Tab10:AddParagraph({ Title = "🐝 Number of Bees: " })
	paragraphs["🐝 Number of Bees: "] = newParagraph

	spawn(function()
		while wait() do
			local count = 0

			for _, v in pairs(HivePath:GetDescendants()) do
				if v.Name == "Owner" and v.Value == player then
					for _, cell in pairs(v.Parent.Cells:GetChildren()) do
						if cell.CellType.Value ~= "Empty" then
							count = count + 1
						end
					end
					--break
				end
			end

			local title = "🐝 Number of Bees: " .. count
			newParagraph:SetTitle(title)
			paragraphs[title] = newParagraph
		end
		wait(30)
	end)

	--[[

	Tabs.Tab10:AddParagraph({
        Title = "Mob Statuses",
        Content = ""
    })

	--]]

	local Green = "🟢"
	local Red = "🔴"

	local MonsterTable1 = {}
	local paragraphRefs = {}

	for _, v in pairs(game:GetService("Workspace").MonsterSpawners:GetChildren()) do
		table.insert(MonsterTable1, v)
	end

	spawn(function()
		while wait() do
			for _, v in pairs(MonsterTable1) do
				local timerLabels = v:GetDescendants()
				local status = Green

				for _, label in pairs(timerLabels) do
					if label:IsA("TextLabel") and label.Name == "TimerLabel" then
						if label.Visible == true then
							status = Red
						end
					end
				end

				local paraTitle = v.Name .. " " .. status

				if paragraphRefs[v.Name] then
					paragraphRefs[v.Name]:SetTitle(paraTitle)
				else
					local newParagraph = Tabs.Tab10:AddParagraph({ Title = paraTitle, Content = "" })
					paragraphRefs[v.Name] = newParagraph
				end

				wait()
			end
		end
	end)

	-- Farming -- 🔴

	-- Tab5 


	local function WalkTo(targetPosition, continuousUpdate, timeoutInSeconds)

		local player = Players.LocalPlayer
		local character = player.Character or player.CharacterAdded:Wait()
		local humanoid = character:WaitForChild("Humanoid")
		local rootPart = character:WaitForChild("HumanoidRootPart")
		local pathfindingService = game:GetService("PathfindingService")

		local pathfindingParams = {
			AgentRadius = 2,
			AgentHeight = 5,
			AgentCanJump = true,
			AgentJumpHeight = 50,
			AgentMaxSlope = 60,
			AgentMaxDropHeight = 300,
			AgentMaxStepHeight = 15,
			AgentIgnoreWater = false,
			AgentVelocity = 10,
			AgentAcceleration = 20,
			AgentBrake = 30,
			AgentJumpDuration = 1,
			AgentJumpPower = 150,
			AgentSlopeSliding = true,
			AgentIncludePoints = true,
			AgentCostImportant = true,
			AgentDebugParams = {
				DrawAgentRadius = true,
				DrawAgentHeight = true,
				DrawNavMeshPath = true,
				DrawNavMesh = true,
			},
			StartPosition = rootPart.Position,
			EndPosition = targetPosition,
			PathIndex = 1,
		}

		local path = pathfindingService:CreatePath(pathfindingParams)
		local updateInterval = 0.5
		local startTime = tick()
		local elapsedStartTime = tick()
		local maxRetries = 3

		local function UpdatePath()
			path:ComputeAsync(rootPart.Position, targetPosition)

			local success = path.Status == Enum.PathStatus.Success
			if success then
				local waypoints = path:GetWaypoints()

				for _, waypoint in ipairs(waypoints) do
					humanoid:MoveTo(waypoint.Position)

					local elapsed = tick() - elapsedStartTime

					if elapsed >= timeoutInSeconds then
						--print("Timeout reached. Teleporting to the target.")
						if rootPart then
							rootPart.CFrame = CFrame.new(targetPosition)
						end
						return
					end

					if Options.AutoQuestEnabled.Value == true or Options.AutoQuestEnabled1.Value == true then 

					else 
						break 
					end

					local moveSuccess = humanoid.MoveToFinished:Wait()

					if not moveSuccess then
						maxRetries = maxRetries - 1

						if maxRetries >= 0 then
							--print("Retry #" .. (3 - maxRetries))
							humanoid.Jump = true
							humanoid:MoveTo(waypoint.Position)
							humanoid.MoveToFinished:Wait()
						else
							--print("Max retries reached. Teleporting to the target.")
							if rootPart then
								rootPart.CFrame = CFrame.new(targetPosition)
							end
							return
						end
					else
						maxRetries = 3
					end
				end
			else
				--print("Pathfinding failed.")
				if rootPart then
					rootPart.CFrame = CFrame.new(targetPosition)
				end
				return
			end

			wait(updateInterval)
		end

		if continuousUpdate then
			spawn(UpdatePath)
		else
			path:ComputeAsync(rootPart.Position, targetPosition)

			local success = path.Status == Enum.PathStatus.Success
			if success then
				local waypoints = path:GetWaypoints()

				for _, waypoint in ipairs(waypoints) do
					humanoid:MoveTo(waypoint.Position)

					local elapsed = tick() - elapsedStartTime

					if elapsed >= timeoutInSeconds then
						--print("Timeout reached. Teleporting to the target.")
						if rootPart then
							rootPart.CFrame = CFrame.new(targetPosition)
						end
						return
					end

					local moveSuccess = humanoid.MoveToFinished:Wait()

					if not moveSuccess then
						maxRetries = maxRetries - 1

						if maxRetries >= 0 then
							--print("Retry #" .. (3 - maxRetries))
							humanoid.Jump = true
							humanoid:MoveTo(waypoint.Position)
							humanoid.MoveToFinished:Wait()
						else
							--print("Max retries reached. Teleporting to the target.")
							if rootPart then
								rootPart.CFrame = CFrame.new(targetPosition)
							end
							return
						end
					else
						maxRetries = 3
					end
				end
			else
				--print("Pathfinding failed.")
				if rootPart then
					rootPart.CFrame = CFrame.new(targetPosition)
				end
				return
			end

			local elapsedTime = tick() - startTime

			if elapsedTime >= timeoutInSeconds then
				--print("Timeout reached. Teleporting to the target.")
				if rootPart then
					rootPart.CFrame = CFrame.new(targetPosition)
				end
				return
			end

			wait(updateInterval)
		end
	end

	local TweenService = game:GetService("TweenService")

	local function TweenTo(targetPosition, duration)
		local player = game:GetService("Players").LocalPlayer
		local character = player.Character
		local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

		local offset = CFrame.new(0, 0, 0)
		local twnInput

		if typeof(targetPosition) == "Vector3" then
			twnInput = CFrame.new(targetPosition)
		elseif typeof(targetPosition) == "CFrame" then
			twnInput = targetPosition
		else
			return error("Invalid targetPosition format")
		end

		local distance = (humanoidRootPart.Position - twnInput.Position).Magnitude
		local studsPerSecond = 1000
		local time = distance / studsPerSecond

		local tweenInfo = TweenInfo.new(duration or time, Enum.EasingStyle.Linear)
		local twn = game.TweenService:Create(humanoidRootPart, tweenInfo, {CFrame = twnInput * offset})

		twn:Play()
		twn.Completed:Wait()
	end
	local function FieldWalkV2(character, sideLength, targetPosition)
		local player = game.Players.LocalPlayer
		local character = player.Character

		local pathfindingService = game:GetService("PathfindingService")
		local humanoid = character:FindFirstChildOfClass("Humanoid")
		local rootPart = character:FindFirstChild("HumanoidRootPart")

		if not humanoid or not rootPart then
			--print("Character or root part not found.")
			return
		end

		local centerPosition = targetPosition 
		local halfSideLength = sideLength / 2
		local perimeter = {
			Vector3.new(centerPosition.X - halfSideLength, centerPosition.Y, centerPosition.Z + halfSideLength),
			Vector3.new(centerPosition.X + halfSideLength, centerPosition.Y, centerPosition.Z + halfSideLength),
			Vector3.new(centerPosition.X + halfSideLength, centerPosition.Y, centerPosition.Z - halfSideLength),
			Vector3.new(centerPosition.X - halfSideLength, centerPosition.Y, centerPosition.Z - halfSideLength)
		}

		local currentStatus = CalculateBag()

		if currentStatus == "In Between" or currentStatus == "Empty" then
			currentStatus = CalculateBag()

			for i = 1, 4 do
				local nextIndex = (i % 4) + 1
				local path = pathfindingService:CreatePath({
					AgentRadius = 2,
					AgentHeight = 5,
					AgentCanJump = true,
					AgentJumpHeight = 10,
					AgentMaxSlope = 45,
					AgentMaxDropHeight = 50,
					AgentMaxStepHeight = 5,
					AgentIgnoreWater = false,
					AgentVelocity = 10,
					AgentAcceleration = 20,
					AgentBrake = 30,
					AgentJumpDuration = 1,
					AgentJumpPower = 50,
					AgentSlopeSliding = true,
					AgentIncludePoints = true,
					AgentCostImportant = true,
					AgentDebugParams = {
						DrawAgentRadius = true,
						DrawAgentHeight = true,
						DrawNavMeshPath = true,
						DrawNavMesh = true,
					},
					StartPosition = perimeter[i],
					EndPosition = targetPosition,
					PathIndex = 1,
				})

				currentStatus = CalculateBag()

				path:ComputeAsync(perimeter[i], perimeter[nextIndex])

				local waypoints = path:GetWaypoints()

				for _, waypoint in ipairs(waypoints) do
					humanoid:MoveTo(waypoint.Position)
					humanoid.MoveToFinished:Wait()
				end
			end
		end
	end

	local Status = CalculateBag() 
	local targetCFrameV2
	local targetCFrame
	local fieldDetected
	local fieldDetectedV2
	local originalWalkspeed

	

	local function HandleCharacterDeath(character)
		local humanoid = character:WaitForChild("Humanoid")

		humanoid.Died:Connect(function()
			--print("Death detected")
			if Options.AutoQuestEnabled.Value == true then
				Options.AutoQuestEnabled.Value = false
				StopAutoQuest()
				--print("Died")
				wait(10)
				Options.AutoQuestEnabled.Value = true
				StartAutoQuest()
			end
		end)
	end

	player.CharacterAdded:Connect(HandleCharacterDeath)

	if player.Character then
		HandleCharacterDeath(player.Character)
	end

	--

	local FieldsTable2 = {}

	for _,v in next, game:GetService("Workspace").FlowerZones:GetChildren() do table.insert(FieldsTable2, v.Name) end

	local FieldsTableDropdown2 = Tabs.Tab5:AddDropdown("Dropdown", {
        Title = "🌾 Select Field",
        Values = FieldsTable2,
        Multi = false,
        Default = "Dandelion Field",
    })

	FieldsTableDropdown2:OnChanged(function(Value)
		SelectedField2 = Value
	end)

	Tabs.Settings:AddParagraph({
        Title = "Farm Settings",
    })


	local TransportModeDropdown2 = Tabs.Settings:AddDropdown("Dropdown", {
        Title = "🚲 Select Transport Mode",
        Values = {"Tween", "Teleport", "Path Finding"},
        Multi = false,
        Default = "Tween",
    })

	TransportModeDropdown2:OnChanged(function(Value)
		SelectedTransport2 = Value
	end)

	local ModeDropdown2 = Tabs.Settings:AddDropdown("Dropdown", {
        Title = "⚙️ Select Farm Mode",
        Values = {"Collect Tokens", "Walk Around Field"},
        Multi = false,
        Default = "Collect Tokens",
    })

	ModeDropdown2:OnChanged(function(Value)
		SelectedMode1 = Value
	end)

	local AutoQuestToggle1 = Tabs.Tab5:AddToggle("AutoQuestEnabled1", {Title = "🌳 Auto Field Farm [⚙️]", Default = false })

	--[[
	local ModeDropdown3 = Tabs.Tab5:AddDropdown("Dropdown", {
        Title = "⚙️ Select Mode",
        Values = {"Collect Tokens", "Walk Around Field"},
        Multi = false,
        Default = "Select Mode",
    })

	ModeDropdown3:OnChanged(function(Value)
		SelectedMode2 = Value
	end)

	--]]

	--
	--[[
	Tabs.Tab5:AddParagraph({
        Title = "",
    })
	--]]



	local AutoQuestToggle = Tabs.Tab5:AddToggle("AutoQuestEnabled", {Title = "🌽 Auto Complete Field Quest [⚙️]", Default = false })

	spawn(function() 
		while wait() do 
			if Options.AutoQuestEnabled.Value == true or Options.AutoQuestEnabled1.Value == true then 
				Status = CalculateBag()
				if Status == "In Between" or Status == "Empty" then 
					autoHarvest()
				end
			end
		end
	end)

	--


	local QuestToggle = Tabs.Tab5:AddToggle("QuestAuto", {Title = "📋 Auto Accept / Submit Quest", Default = false })

	-- Comp(AdditionalQuest)
	--wait(0.5)
	--Give(AdditionalQuest)

	-- Auto Harvest

	--[[

	local function pickUpLeaves()
		

		while Options.pickupLeaves.Value == true do
			
				for _, leafBurst in pairs(flowers:GetDescendants()) do
					if string.find(leafBurst.Name, "LeafBurst") then
						local parent = leafBurst.Parent
						
							repeat
								if parent then
									local leafPosition = parent.Position
									local playerPosition = playerCharacter.HumanoidRootPart.Position
									local distance = (leafPosition - playerPosition).Magnitude

									if distance <= 1000 then
										
										playerCharacter:MoveTo(leafPosition)
										wait(0.1)
										
									
									end
								end
							until not parent or Options.pickupLeaves.Value == false
						
					end
				end
			
			wait()
		end
	end

	local LeafToggle = Tabs.Tab5:AddToggle("pickupLeaves", {Title = " Collect Leaves", Default = false })

	spawn(function()
		while wait() do
			if Options.pickupLeaves.Value == true then  
				pickUpLeaves()
				--autoHarvest()
			end
		end
	end)

	--]]
        
	local function pickUpLeaves()
		
		local flowers = game:GetService("Workspace").Flowers
		local playerCharacter = player.Character
		local humanoid = playerCharacter:FindFirstChildOfClass("Humanoid")

		while Options.pickupLeaves.Value == true do
			for _, leafBurst in pairs(flowers:GetDescendants()) do
				if string.find(leafBurst.Name, "LeafBurst") then
					local parent = leafBurst.Parent

					if parent then
						local leafPosition = parent.Position
						local playerPosition = playerCharacter.HumanoidRootPart.Position
						local distance = (leafPosition - playerPosition).Magnitude

						if distance <= 1000 then
							repeat
								playerCharacter:MoveTo(leafPosition)
								wait(0.1)
								parent = leafBurst.Parent -- Update the parent variable
							until not parent or Options.pickupLeaves.Value == false
						end
					end
				end
			end

			wait()
		end
	end

	local LeafToggle = Tabs.Tab5:AddToggle("pickupLeaves", {Title = "🍃 Collect Leaves [⚠️]", Default = false})

	LeafToggle:OnChanged(function(Value)
		if Value then
			spawn(pickUpLeaves)
		end
	end)

	spawn(function()
		while wait() do
			if Options.pickupLeaves.Value == true then  
				autoHarvest()
			end
		end
	end)


	local AutoCollectToggle = Tabs.Tab5:AddToggle("AutoCollect1", {Title = "⛏️ Auto Harvest ", Default = false })

	spawn(function()
		while wait() do
			if Options.AutoCollect1.Value == true then  
				autoHarvest()
			end
		end
	end)

	-- Auto Sprinkler

	local AutoSprinklerToggle = Tabs.Settings:AddToggle("AutoSprinkler1", {Title = "⛲ Auto Place Sprinkler ", Default = true })

	local AvoidMobsToggle = Tabs.Settings:AddToggle("AvoidMobs1", {Title = "🛡️ Avoid Mobs ", Default = true })

	local function checkMonsters()
		local player = game.Players.LocalPlayer
		local character = player.Character or player.CharacterAdded:Wait()
		local humanoidRootPart = character:WaitForChild("HumanoidRootPart")

		local monsters = game:GetService("Workspace").Monsters:GetChildren()
		local closestMonsterDistance = math.huge
		local hasCloseMonsters = false

		for _, monster in pairs(monsters) do
			if monster:IsA("Model") and monster:FindFirstChild("HumanoidRootPart") then
				local monsterRootPart = monster.HumanoidRootPart
				local distance = (monsterRootPart.Position - humanoidRootPart.Position).Magnitude

				if distance <= 60 then
					hasCloseMonsters = true
					if distance < closestMonsterDistance then
						closestMonsterDistance = distance
					end
				end
			end
		end

		if hasCloseMonsters then
				return "MobClose", closestMonsterDistance
			else
				return "NoMobs", nil
			end
		end

	local AvoidCheck, closestMonsterDistance = checkMonsters()

	--[[
	spawn(function()
		while true do 
			local AvoidCheck, closestMonsterDistance = checkMonsters()

			if AvoidCheck == "NoMobs" then 
				print("No Mobs1")
			elseif AvoidCheck == "MobClose" then 
				print("Mob close1")
				game.Players.LocalPlayer.Character.Humanoid.Jump = true
			end

			wait(0.5) -- Adjust the wait time as needed
		end
	end)

	--]]

	--

	-- Field Locations for Functions

	local keywords = {"Red", "Blue", "White", "Dandelion", "Strawberry", "Sunflower", "Mushroom", "Clover", "Bamboo", "Spider", "Cactus", "Pepper", "Coconut", "Mountain", "Pumpkin", "Pineapple", "Pine Tree", "Rose"}

	--  "Pineapple" "PineTree"

	--[[
	local keywordLocations = {
		Red = "Mushroom Field",
		Blue = "Blue Flower Field",
		White = "Dandelion Field",
	}
	--]]

	local Red
	local White 
	local Blue

	local RedDropdown = "Mushroom Field"
	local BlueDropdown = "Blue Flower Field"
	local WhiteDropdown = "Dandelion Field"

	local keywordLocations = {
		Red = RedDropdown,
		Blue = BlueDropdown,
		White = WhiteDropdown,
	}

	local WhiteDropdown1 = Tabs.Settings:AddDropdown("Dropdown", {
		Title = "⬜ Select White Field",
		Values = {"Dandelion Field", "Pineapple Patch", "Pumpkin Patch", "Coconut Field"},
		Multi = false,
		Default = "Dandelion Field",  
	})

	WhiteDropdown1:OnChanged(function(Value)
		keywordLocations.White = Value
	end)

	local RedDropdown1 = Tabs.Settings:AddDropdown("Dropdown", {
		Title = "🟥 Select Red Field",
		Values = {"Mushroom Field", "Strawberry Field", "Rose Field", "Pepper Patch"},
		Multi = false,
		Default = "Mushroom Field", 
	})

	RedDropdown1:OnChanged(function(Value)
		keywordLocations.Red = Value
	end)

	local BlueDropdown1 = Tabs.Settings:AddDropdown("Dropdown", {
		Title = "🟦 Select Blue Field",
		Values = {"Blue Flower Field", "Bamboo Field", "Pine Tree Forest", "Stump Field"},
		Multi = false,
		Default = "Blue Flower Field", 
	})

	BlueDropdown1:OnChanged(function(Value)
		keywordLocations.Blue = Value
	end)

	--


	Tabs.Tab5:AddParagraph({
        Title = "Boosters",
        Content = "Cooldowns: 9s, 20s, 900s"
    })

	local GumDropsToggle = Tabs.Tab5:AddToggle("gumDrops", {Title = "🚀 Auto Gum Drops", Default = false })

	spawn(function() 
		while wait() do 
			if Options.gumDrops.Value == true then 
				game:GetService("ReplicatedStorage").Events.PlayerActivesCommand:FireServer({Name = "Gumdrops"}) 
				wait(9)
			end
		end
	end)

	local JellyBeansToggle = Tabs.Tab5:AddToggle("jellyBeans", {Title = "🚀 Auto Jelly Beans", Default = false})

	spawn(function()
		while wait() do
			if Options.jellyBeans.Value == true then
				game:GetService("ReplicatedStorage").Events.PlayerActivesCommand:FireServer({Name = "Jelly Beans"})
				wait(20)
			end
		end
	end)

	local GlitterToggle = Tabs.Tab5:AddToggle("glitter", {Title = "🚀 Auto Glitter", Default = false})

	spawn(function()
		while wait() do
			if Options.glitter.Value == true then
				game:GetService("ReplicatedStorage").Events.PlayerActivesCommand:FireServer({Name = "Glitter"})
				wait(901)
			end
		end
	end)

	-- Dispensers

	Tabs.Tab5:AddParagraph({
        Title = "Dispensers",
    })

	local MasterToggle = Tabs.Tab5:AddToggle("MasterToggle", {
		Title = "⚖️ Toggle All Dispensers",
		Default = false,
	})

	local toggleData = {
		{ Name = "royalJellyDispenser", Title = "👑 Free Royal Jelly Dispenser", Dispenser = "Free Royal Jelly Dispenser" },
		{ Name = "blueberryDispenser", Title = "🔵 Blueberry Dispenser", Dispenser = "Blueberry Dispenser" },
		{ Name = "strawberryDispenser", Title = "🍓 Strawberry Dispenser", Dispenser = "Strawberry Dispenser" },
		{ Name = "treatDispenser", Title = "🍬 Treat Dispenser", Dispenser = "Treat Dispenser" },
		{ Name = "coconutDispenser", Title = "🥥 Coconut Dispenser", Dispenser = "Coconut Dispenser" },
		{ Name = "glueDispenser", Title = "🧪 Glue Dispenser", Dispenser = "Glue Dispenser" },
		{ Name = "fieldBooster", Title = "🌾 Field Booster", Dispenser = "Field Booster" },
		{ Name = "redFieldBooster", Title = "🔴 Red Field Booster", Dispenser = "Red Field Booster" },
		{ Name = "blueFieldBooster", Title = "🔵 Blue Field Booster", Dispenser = "Blue Field Booster" },
		{ Name = "wealthClock", Title = "💰 Wealth Clock", Dispenser = "Wealth Clock" },
	}

	local toggles = {}

	local function createToggle(tab, data)
		local toggle = tab:AddToggle(data.Name, {
			Title = data.Title,
			Default = false,
		})

		toggles[data.Name] = toggle

		spawn(function()
			while wait() do
				if toggle.Value then
					local eventName = "ToyEvent"

					game.ReplicatedStorage.Events[eventName]:FireServer(data.Dispenser)
					wait(5)
				end
			end
		end)
	end

	for _, data in pairs(toggleData) do
		createToggle(Tabs.Tab5, data)
	end

	MasterToggle:OnChanged(function()
		for _, data in pairs(toggleData) do
			if toggles[data.Name] then
				toggles[data.Name]:SetValue(MasterToggle.Value)
			end
		end
end)

	-- 

	local function pathfind(targetPosition, Timeout1)
		local PathfindingService = game:GetService("PathfindingService")
		local Humanoid = game.Players.LocalPlayer.Character.Humanoid
		local Root = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

		local startTime = tick()
		local elapsedStartTime = tick()

		if Root then
			local path = PathfindingService:CreatePath({
				AgentCanJump = true,
				WaypointSpacing = 1
			})
			path:ComputeAsync(Root.Position, targetPosition)
			local waypoints = path:GetWaypoints()

			for _, waypoint in ipairs(waypoints) do
				Humanoid:MoveTo(waypoint.Position)

				local elapsed = tick() - elapsedStartTime

				if elapsed >= Timeout1 then
					-- Timeout reached. Teleporting to the target.
					Root.CFrame = CFrame.new(targetPosition)
					return
				end

				Humanoid.MoveToFinished:Wait()

				-- Check if the waypoint requires jumping
				if waypoint.Action == Enum.PathWaypointAction.Jump then
					Humanoid.Jump = true
				end
			end
		else
			warn("HumanoidRootPart not found.")
		end
	end

	-- 

	function WalkToTokens()
		local character = game.Players.LocalPlayer.Character
		if character then
			for _, collectible in pairs(workspace.Collectibles:GetChildren()) do
				if collectible:IsA("BasePart") and collectible.Transparency < 0.6 then
					local distance = (character.HumanoidRootPart.Position - collectible.Position).Magnitude
					if tonumber(distance) <= 40 then 
						pathfind(collectible.Position, 5)
						wait()
					end
				end
			end
		end
	end

	--

	local STATUS_FULL = "Full"
	local STATUS_EMPTY = "Empty"

	local function AutoQuestHandler()
		while Options.AutoQuestEnabled.Value == true do
			Status = CalculateBag()
			wait(0.5)
			--print(Status)

			local Match = nil
			local targetCFrameV2
			local fieldDetectedV2
			local STATUS_FULL = "Full"
			local STATUS_EMPTY = "Empty"

			if Status == STATUS_FULL then
				--print("Full Entered")
				originalWalkSpeed = humanoid.WalkSpeed
				humanoid.WalkSpeed = 0

				TeleportToHive()
				wait(1.5)
				StartConvert()
				wait(4)
				Teleported = true

				while Status ~= STATUS_EMPTY do
					Status = CalculateBag()
					wait()
				end

				wait(4)
				humanoid.WalkSpeed = originalWalkSpeed
			elseif Status == STATUS_EMPTY or Status == "In Between" then
				Teleported = false
				local foundQuest = false
				wait()

					QPath = game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.Menus.Children.Quests
					Click = game:GetService("VirtualInputManager")
					children = QPath.Content:GetChildren()
					
					if #children == 0 then
						ClickMouse(84, 105)
					else

					for _, v in pairs(game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.Menus.Children.Quests.Content:GetDescendants()) do
						if v:IsA("TextLabel") and v.Name == "Description" and string.match(v.Text, "Pollen") and v.Parent.Parent.TitleBar.Text ~= BlackListedQuest and v.Parent.Parent.TitleBar.Text ~= BlackListedQuest1 and v.Parent.Parent.TitleBar.Text ~= BlackListedQuest2 then
							local descriptionText = v.Text
							--print(v.Parent.Parent.TitleBar.Text)
							if not string.find(descriptionText, "Complete") then
								for _, keyword in ipairs(keywords) do
									if string.match(descriptionText, keyword) then
										Match = keyword
										--print(Match)
										foundQuest = true
										break
									end
								end
							end
						end
						
					
						if foundQuest then
							--break
						end
					end

					if not foundQuest then
						Match = "Dandelion" 
					end

					local targetField = keywordLocations[Match] or Match
					if targetField then
						--print("Field Found:", targetField)

						for _, v in pairs(game:GetService("Workspace").FlowerZones:GetChildren()) do
							if string.match(v.Name, targetField) then
								--print(targetField)
								targetCFrame = v.CFrame
								fieldDetected = v.Name
								if SelectedTransport2 == "Path Finding" then 
									WalkTo(targetCFrame.Position, false, 50)

									wait(0.2)

									if Options.AutoSprinkler1.Value == true then

										local args = {
											[1] = {
												["Name"] = "Sprinkler Builder"
											}
										}

										game:GetService("ReplicatedStorage").Events.PlayerActivesCommand:FireServer(unpack(args))
									end

								elseif SelectedTransport2 == "Tween" then 
									TweenTo(targetCFrame.Position, 0.5)

									wait(0.2)

									local args = {
										[1] = {
											["Name"] = "Sprinkler Builder"
										}
									}

									game:GetService("ReplicatedStorage").Events.PlayerActivesCommand:FireServer(unpack(args))
								end
							end
						end
					end

					wait()

					while targetCFrame and Status ~= STATUS_FULL and Options.AutoQuestEnabled.Value == true do wait()
						
						QPath = game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.Menus.Children.Quests
						Click = game:GetService("VirtualInputManager")
						children = QPath.Content:GetChildren()
						
						if #children == 0 then

							ClickMouse(84, 105)
						else

							for _, v in pairs(game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.Menus.Children.Quests.Content:GetDescendants()) do
								if v:IsA("TextLabel") and v.Name == "Description" and string.match(v.Text, "Pollen") and v.Parent.Parent.TitleBar.Text ~= BlackListedQuest and v.Parent.Parent.TitleBar.Text ~= BlackListedQuest1 and v.Parent.Parent.TitleBar.Text ~= BlackListedQuest2 then
									local descriptionText = v.Text
									if not string.find(descriptionText, "Complete") then
										--print(descriptionText)
										for _, keyword in ipairs(keywords) do
											if string.match(descriptionText, keyword) then
												--print(Match)
												Match = keyword
												
												break
											end
										end
									end
								end
							end

							if Match then
								local targetField = keywordLocations[Match] or Match
								if targetField then
									--print("Field Found:", targetField)

									for _, v in pairs(game:GetService("Workspace").FlowerZones:GetChildren()) do
										if string.match(v.Name, targetField) then
											targetCFrameV2 = v.CFrame
											fieldDetectedV2 = v.Name
											--print("fieldDetected", fieldDetected)
											--print("fieldDetectedV2:", fieldDetectedV2)
											--print("Walking ...")

											if fieldDetected ~= fieldDetectedV2 then
												--print("Change Detected")
												break
											end

											Status = CalculateBag()

											if Status == STATUS_FULL then
												--print("Status Full")
												break
											end
											
											if SelectedMode1 == "Collect Tokens" then
												-- WalkToTokens()
												if Options.AvoidMobs1.Value == true then
													local AvoidCheck, closestMonsterDistance = checkMonsters()
													
													if AvoidCheck == "NoMobs" then 
														--print("No mobs nearby, walking to tokens.")
														WalkToTokens()
													elseif AvoidCheck == "MobClose" then 
														--print("Mobs are close, jumping!")
														game.Players.LocalPlayer.Character.Humanoid.Jump = true
													end
												else
													WalkToTokens()
												end
											elseif SelectedMode1 == "Walk Around Field" then
												FieldWalkV2(character, 55, targetCFrameV2)
											elseif SelectedMode1 == nil then 
												FieldWalkV2(character, 55, targetCFrameV2)
											end
										end
									end
								end
							end

							if fieldDetected ~= fieldDetectedV2 then
								--print("Change Detected")
								break
							end

							if Status == STATUS_FULL then
								--print("Status Full")
								break
							end
						end
					end
				end
			end
		end
	end

	local Status = CalculateBag() 
	local targetCFrameV2
	local targetCFrame
	local fieldDetected
	local fieldDetectedV2
	local originalWalkspeed

	local player = game.Players.LocalPlayer

	local function HandleCharacterDeath1(character)
		local humanoid = character:WaitForChild("Humanoid")

		humanoid.Died:Connect(function()
			--print("Death detected")
			if Options.AutoQuestEnabled1.Value == true then
				Options.AutoQuestEnabled1.Value = false
				StopAutoQuest1()
				--print("Died")
				wait(10)
				Options.AutoQuestEnabled1.Value = true
				StartAutoQuest1()
			end
		end)
	end

	player.CharacterAdded:Connect(HandleCharacterDeath1)

	if player.Character then
		HandleCharacterDeath1(player.Character)
	end

	local automationThread = nil

	function StartAutoQuest()
		if automationThread then
			automationThread:Stop()
		end
		automationThread = spawn(AutoQuestHandler)
		wait()
	end

	function StopAutoQuest()
		if automationThread then
			automationThread:Stop()
			automationThread = nil
		end
	end

	AutoQuestToggle:OnChanged(function()
        StartAutoQuest()
    end)

	-- Auto Farm

	local function AutoQuestHandler1()
		while Options.AutoQuestEnabled1.Value == true do
			Status = CalculateBag()
			wait(0.5)
			-- print(Status)

			local Match = nil
			local targetCFrameV2
			local fieldDetectedV2
			local STATUS_FULL = "Full"
			local STATUS_EMPTY = "Empty"

			local function TeleportToHive()
				for i, v in pairs(game:GetService("Workspace").Honeycombs:GetDescendants()) do
					if v.Name == "Owner" then
						if v.Value == player then
							player.Character.HumanoidRootPart.CFrame = v.Parent.LightHolder.CFrame
						end
					end
				end
			end

			local function StartConvert()
				game:GetService("ReplicatedStorage").Events.PlayerHiveCommand:FireServer("ToggleHoneyMaking")
			end

			if Status == STATUS_FULL then
				-- print("Full Entered")
				originalWalkSpeed = humanoid.WalkSpeed
				humanoid.WalkSpeed = 0

				TeleportToHive()
				wait(1.5)
				StartConvert()
				wait(4)
				Teleported = true

				while Status ~= STATUS_EMPTY do
					Status = CalculateBag()
					wait()
				end

				wait(4)
				humanoid.WalkSpeed = originalWalkSpeed
			elseif Status == STATUS_EMPTY or Status == "In Between" then
				Teleported = false
				local foundQuest = false
				wait()

				--[[

				QPath = game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.Menus.Children.Quests
				Click = game:GetService("VirtualInputManager")
				children = QPath.Content:GetChildren()

				if #children == 0 then
					ClickMouse(84, 105)
				else
				--[[
				for _, v in pairs(game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.Menus.Children.Quests.Content:GetDescendants()) do
					if v:IsA("TextLabel") and v.Name == "Description" and string.match(v.Text, "Pollen") then
						local descriptionText = v.Text
						if not string.find(descriptionText, "Complete") then
							for _, keyword in ipairs(keywords) do
								if string.match descriptionText, keyword) then
									Match = keyword
									foundQuest = true
									break
								end
							end
						end
					end
					--]]
					if foundQuest then
						-- break
					end
				--]]

				-- print(SelectedField2)

				if not foundQuest then
					Match = SelectedField2
				end

				local targetField = keywordLocations[Match] or Match
				if targetField then
					-- print("Field Found:", targetField)

					for _, v in pairs(game:GetService("Workspace").FlowerZones:GetChildren()) do
						if string.match(v.Name, targetField) then
							targetCFrame = v.CFrame
							fieldDetected = v.Name
							if SelectedTransport2 == "Path Finding" then 
								WalkTo(targetCFrame.Position, false, 50)
							elseif SelectedTransport2 == "Tween" then 
								TweenTo(targetCFrame.Position, 0.5)
							end
						end
					end
				end

				wait(1)

				while targetCFrame and Status ~= STATUS_FULL and Options.AutoQuestEnabled1.Value == true do
					wait()

					--[[
					QPath = game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.Menus.Children.Quests
					Click = game:GetService("VirtualInputManager")
					children = QPath.Content:GetChildren()

					if #children == 0 then
						ClickMouse(84, 105)
					else
					--]]

					--[[
					for _, v in pairs(game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.Menus.Children.Quests.Content:GetDescendants()) do
						if v:IsA("TextLabel") and v.Name == "Description" and string.match(v.Text, "Pollen") then
							local descriptionText = v.Text
							if not string.find(descriptionText, "Complete") then
								for _, keyword in ipairs(keywords) do
									if string.match(descriptionText, keyword) then
										Match = keyword
										break
									end
								end
							end
						end
					end
					--]]

					Match = SelectedField2

					if Match then
						local targetField = Match
						if targetField then
							-- print("Field Found:", targetField)

							for _, v in pairs(game:GetService("Workspace").FlowerZones:GetChildren()) do
								if string.match(v.Name, targetField) then
									targetCFrameV2 = v.CFrame
									fieldDetectedV2 = v.Name
									-- print("fieldDetected", fieldDetected)
									-- print("fieldDetectedV2:", fieldDetectedV2)
									-- print("Walking ...")

									if fieldDetected ~= fieldDetectedV2 then
										-- print("Change Detected")
										break
									end

									Status = CalculateBag()

									if Status == STATUS_FULL then
										-- print("Status Full")
										break
									end

									if SelectedMode1 == "Collect Tokens" then

										WalkToTokens()

									elseif SelectedMode1 == "Walk Around Field" then

										FieldWalkV2(character, 55, targetCFrameV2)
											
									elseif SelectedMode1 == nil then 

										FieldWalkV2(character, 55, targetCFrameV2)

									end

								end
							end
						end
					end

					if fieldDetected ~= fieldDetectedV2 then
						-- print("Change Detected")
						break
					end

					if Status == STATUS_FULL then
						-- print("Status Full")
						break
					end
				end
			end
		end
	end

	local automationThread1 = nil

	function StartAutoQuest1()
		if automationThread1 then
			automationThread1:Stop()
		end
		automationThread1 = spawn(AutoQuestHandler1)
		wait()
	end

	function StopAutoQuest1()
		if automationThread1 then
			automationThread1:Stop()
			automationThread1 = nil
		end
	end

	AutoQuestToggle1:OnChanged(function()
        StartAutoQuest1()
    end)

--[[
	-- Funcs 

	local function FeedLowestBee(Food)
		local lowestNumber = math.huge 
		local lowestParentName = ""

		local HivePath = game:GetService("Workspace").Honeycombs
		local player = game.Players.LocalPlayer
		local playerHive = nil

		for _, v in pairs(HivePath:GetDescendants()) do
			if v.Name == "Owner" then
				if v.Value == player then
					playerHive = v.Parent
					break
				end
			end
		end

		if playerHive then
			for _, Cell in pairs(playerHive.Cells:GetDescendants()) do
				if Cell.Name == "SurfaceGui" then
					for _, Gui in pairs(Cell:GetChildren()) do
						if Gui.Name == "TextLabel" then
							local numberText = Gui.Text
							local number = tonumber(numberText)
							if number and number < lowestNumber then
								lowestNumber = number
								lowestParentName = Gui.Parent.Parent.Parent

								local C1 = lowestParentName:FindFirstChild("CellX")
								local C2 = lowestParentName:FindFirstChild("CellY")

								if C1 and C2 then

									local ohNumber1 = C1.Value
									local ohNumber2 = C2.Value

									game:GetService("ReplicatedStorage").Events.GetBondToLevel:InvokeServer(ohNumber1, ohNumber2)

									local ohNumber1 = C1.Value
									local ohNumber2 = C2.Value
									local ohString3 = Food
									local ohNumber4 = 1
									local ohBoolean5 = false

									game:GetService("ReplicatedStorage").Events.ConstructHiveCellFromEgg:InvokeServer(ohNumber1, ohNumber2, ohString3, ohNumber4, ohBoolean5)
								
									

									wait(0.5)
								end
							end
						end
					end
				end
			end
			wait(1)
		end
	end

	local foodkeywords = {"Treat", "Pineapple", "Strawberry", "Strawb", "Blueberry", "Blueberries", "Sunflower"}

	local fullfoods = {
		["Strawb"] = "Strawberry",
		["Blueberries"] = "Blueberry",
		["Pinea"] = "Pineapple"
	}

	local TreatQuest1 = Tabs.Tab5:AddToggle("TreatQuest2", {Title = "Auto Treat Quest [Buggy]", Default = false })

	spawn(function() 
		while wait() do 
			if Options.TreatQuest2.Value == true then 
				local foodMatch = nil  -- Initialize foodMatch here
				for _, v in pairs(game:GetService("Players").LocalPlayer.PlayerGui.ScreenGui.Menus.Children.Quests.Content:GetDescendants()) do
					if v:IsA("TextLabel") and v.Name == "Description" and string.match(v.Text, "Feed") then
						local descriptionText = v.Text
						if not string.find(descriptionText, "Complete") then
							for _, keyword in ipairs(foodkeywords) do
								if string.match(descriptionText, keyword) then
									local fullFoodName = fullfoods[keyword] or keyword
									foodMatch = fullFoodName  
									--break
									--print(foodMatch)
									wait(1)
								end
							end

							if foodMatch then
								--break
							end
						end
					end
				end

				if foodMatch then
					--print(foodMatch)
					FeedLowestBee(foodMatch)
					--wait(1)
				end
			end
		end
	end)

--]]

	-- Bees 🔴

	-- Functions

	-- Tab6

	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local ConstructHiveCellFromEgg = ReplicatedStorage.Events.ConstructHiveCellFromEgg

	local player = game.Players.LocalPlayer
	local playerHive = nil

	-- Purchase Eggs 

	local function BuyBasicEgg()
		local ohString1 = "Purchase"
		local ohTable2 = {
			["Type"] = "Basic",
			["Amount"] = 1,
			["Category"] = "Eggs"
		}

		game:GetService("ReplicatedStorage").Events.ItemPackageEvent:InvokeServer(ohString1, ohTable2)

		game:GetService("ReplicatedStorage").Events.RetrievePlayerStats:InvokeServer()
	end

	-- Purchase Basic Egg 🔴

	local PurchaseBeeToggle = Tabs.Tab6:AddToggle("PurchaseBee1", {Title = "🐝 Purchase Basic Bee", Default = false })

	spawn(function()
		while wait() do 
			if Options.PurchaseBee1.Value == true then
				BuyBasicEgg()
				wait(2)
			end
		end
	end)

	-- Place Eggs 🔴

	-- Auto Place Bees 

	local function PlaceEggs(Egg)
		local ReplicatedStorage = game:GetService("ReplicatedStorage")
		local ConstructHiveCellFromEgg = ReplicatedStorage.Events.ConstructHiveCellFromEgg

		local function invokeRemote(ohNumber1, ohNumber2)
			local ohString3 = Egg
			local ohNumber4 = 1
			local ohBoolean5 = false
			ConstructHiveCellFromEgg:InvokeServer(ohNumber1, ohNumber2, ohString3, ohNumber4, ohBoolean5)
			
		end

		local player = game.Players.LocalPlayer
		local playerHive = nil

		for _, v in pairs(HivePath:GetDescendants()) do
			if v.Name == "Owner" then
				if v.Value == player then
					playerHive = v.Parent
					break
				end
			end
		end

		if playerHive then
			for _, cell in pairs(playerHive.Cells:GetChildren()) do
				if cell.CellType.Value == "Empty" then
					local C1 = cell.CellX.Value
					local C2 = cell.CellY.Value

					invokeRemote(C1, C2)
					wait(0.1)
					game:GetService("ReplicatedStorage").Events.RetrievePlayerStats:InvokeServer()
					
				end
			end
		end
	end

	local PlaceBeeToggle = Tabs.Tab6:AddToggle("PlaceBee1", {Title = "🐝 Auto Place Bees", Default = false })

	spawn(function()
		while wait() do 
			if Options.PlaceBee1.Value == true then
				PlaceEggs("Basic")
				PlaceEggs("Silver")
				PlaceEggs("Gold")
				PlaceEggs("Diamond")
				wait(2)
			end
		end
	end)

	Tabs.Tab6:AddParagraph({
        Title = "┗› Diamond, Gold, Silver & Basic",
    })

	-- Upgrade Bees 🔴

	function UpgradeBasicBees()
		
		local player = game.Players.LocalPlayer
		local count = 0
		local playerHive = nil

		for _, v in pairs(HivePath:GetDescendants()) do
			if v.Name == "Owner" then
				if v.Value == player then
					playerHive = v.Parent
					break
				end
			end
		end

		if playerHive then
			for _, cell in pairs(playerHive.Cells:GetChildren()) do
				if cell.CellType.Value ~= "Empty" then
					count = count + 1
					--print("Cell Name: " .. cell.Name)

					local CellType = cell:FindFirstChild("CellType")
					if CellType and CellType.Value == "BasicBee" then
						--print("BasicBee Found in " .. cell.Name)
						--print("Cell Coordinates: (" .. cell.CellX.Value .. ", " .. cell.CellY.Value .. ")")

						-- Retrieve the cell coordinates
						local C1 = cell.CellX.Value
						local C2 = cell.CellY.Value

						-- Construct a hive cell using the retrieved coordinates
						local ohNumber1 = C1
						local ohNumber2 = C2
						local ohString3 = "RoyalJelly"
						local ohNumber4 = 1
						local ohBoolean5 = false

						game:GetService("ReplicatedStorage").Events.ConstructHiveCellFromEgg:InvokeServer(ohNumber1, ohNumber2, ohString3, ohNumber4, ohBoolean5)

						wait(0.2) 
					end
				end
			end
		end

		--print("Number of Bees: " .. count)
	end

	local beeTypes = {
    "BomberBee",
    "BraveBee",
    "BumbleBee",
    "CoolBee",
    "HastyBee",
    "LookerBee",
    "RadBee",
    "RascalBee",
    "StubbornBee",
	}

	function UpgradeRares()
		
		local player = game.Players.LocalPlayer
		local count = 0
		local playerHive = nil

		for _, v in pairs(HivePath:GetDescendants()) do
			if v.Name == "Owner" then
				if v.Value == player then
					playerHive = v.Parent
					break
				end
			end
		end

		if playerHive then
			for _, cell in pairs(playerHive.Cells:GetChildren()) do
				if cell.CellType.Value ~= "Empty" then
					count = count + 1
					--print("Cell Name: " .. cell.Name)

					local CellType = cell:FindFirstChild("CellType")
					if CellType and table.find(beeTypes, CellType.Value) then
						--print("BasicBee Found in " .. cell.Name)
						--print("Cell Coordinates: (" .. cell.CellX.Value .. ", " .. cell.CellY.Value .. ")")

						-- Retrieve the cell coordinates
						local C1 = cell.CellX.Value
						local C2 = cell.CellY.Value

						-- Construct a hive cell using the retrieved coordinates
						local ohNumber1 = C1
						local ohNumber2 = C2
						local ohString3 = "RoyalJelly"
						local ohNumber4 = 1
						local ohBoolean5 = false

						game:GetService("ReplicatedStorage").Events.ConstructHiveCellFromEgg:InvokeServer(ohNumber1, ohNumber2, ohString3, ohNumber4, ohBoolean5)

						wait(0.5) 
					end
				end
			end
		end

		--print("Number of Bees: " .. count)
	end

	function UpgradeRareBees()
		local HivePath = game:GetService("Workspace").Honeycombs
		local player = game.Players.LocalPlayer
		local count = 0
		local playerHive = nil

		for _, v in pairs(HivePath:GetDescendants()) do
			if v.Name == "Owner" then
				if v.Value == player then
					playerHive = v.Parent
					break
				end
			end
		end

		if playerHive then
			for _, cell in pairs(playerHive.Cells:GetChildren()) do
				if cell.CellType.Value ~= "Empty" then
					count = count + 1
					--print("Cell Name: " .. cell.Name)

					local CellType = cell:FindFirstChild("CellType")
					if CellType and table.find(beeTypes, CellType.Value) then
						--print("BasicBee Found in " .. cell.Name)
						--print("Cell Coordinates: (" .. cell.CellX.Value .. ", " .. cell.CellY.Value .. ")")

						-- Retrieve the cell coordinates
						local C1 = cell.CellX.Value
						local C2 = cell.CellY.Value

						-- Construct a hive cell using the retrieved coordinates
						local ohNumber1 = C1
						local ohNumber2 = C2
						local ohString3 = "StarJelly"
						local ohNumber4 = 1
						local ohBoolean5 = false

						game:GetService("ReplicatedStorage").Events.ConstructHiveCellFromEgg:InvokeServer(ohNumber1, ohNumber2, ohString3, ohNumber4, ohBoolean5)

						wait(0.5) 
					end
				end
			end
		end

		--print("Number of Bees: " .. count)
	end

	local UpgradeBasicToggle = Tabs.Tab6:AddToggle("UpgradeBee1", {Title = "📈 Auto Upgrade Baic Bees [👑 Royal Jelly]", Default = false })

	spawn(function()
		while wait() do 
			if Options.UpgradeBee1.Value == true then
				UpgradeBasicBees()
				wait(1)
			end
		end
	end)

	local UpgradeRareToggle = Tabs.Tab6:AddToggle("UpgradeBee2", {Title = "📈 Auto Upgrade Rare Bees [👑 Royal Jelly]", Default = false })

	spawn(function()
		while wait() do 
			if Options.UpgradeBee2.Value == true then
				UpgradeRares()
				wait(1)
			end
		end
	end)

	local UpgradeRareToggle2 = Tabs.Tab6:AddToggle("UpgradeBee3", {Title = "📈 Auto Upgrade Rare Bees [⭐ Star Jelly]", Default = false })

	spawn(function()
		while wait() do 
			if Options.UpgradeBee3.Value == true then
				UpgradeRareBees()
				wait(1)
			end
		end
	end)

	-- Auto Feed 🔴

	 Tabs.Tab6:AddParagraph({
        Title = "Treats",
    })

	local Items = require(game:GetService("ReplicatedStorage").EggTypes).GetTypes()

	local TreatTable = {}

	for itemName, itemData in pairs(Items) do
		if itemData.TreatValue then
			table.insert(TreatTable, itemName)
		end
	end

	local SelectedTreat = TreatTable[1]
	local SelectedTreatAmount = 1
	
    local TreatDropdown1 = Tabs.Tab6:AddDropdown("Dropdown", {
        Title = "🍬 Select Treat",
        Values = TreatTable,
        Multi = false,
        Default = "Select Treat",
    })

	TreatDropdown1:OnChanged(function(Value)
		SelectedTreat = Value
	end)

	local function feedAllBees(treat, amt)
		for L = 1, 5 do
			for U = 1, 10 do
				game:GetService("ReplicatedStorage").Events.ConstructHiveCellFromEgg:InvokeServer(L, U, treat, amt)
			end
		end
	end

	local TreatAmount1 = Tabs.Tab6:AddInput("Input", {
        Title = "🔢 Treats to be Fed",
        Default = "1",
        Placeholder = "Placeholder",
        Numeric = true, 
        Finished = true, 
        Callback = function(Value)
            SelectedTreatAmount = tonumber(Value)
        end
    })

	Tabs.Tab6:AddButton({
		Title = "🐝 Feed All Bees",
		Description = "",
		Callback = function()
			if SelectedTreat then
				Window:Dialog({
					Title = "Confirm ",
					Content = "Are you sure you want to perform this action?",
					Buttons = {
						{
							Title = "Confirm",
							Callback = function()
								feedAllBees(SelectedTreat, SelectedTreatAmount)
							end
						},
						{
							Title = "Cancel",
							Callback = function()
								--print("Purchase cancelled.")
							end
						}
					}
				})
			else
				--print("Please select an item to purchase.")
			end
		end
	})

	-- Feed Lowest Bees 🔴 

	local function FeedLowestBee(Food)
		local lowestNumber = math.huge 
		local lowestParentName = ""

		local HivePath = game:GetService("Workspace").Honeycombs
		local player = game.Players.LocalPlayer
		local playerHive = nil

		for _, v in pairs(HivePath:GetDescendants()) do
			if v.Name == "Owner" then
				if v.Value == player then
					playerHive = v.Parent
					break
				end
			end
		end

		if playerHive then
			for _, Cell in pairs(playerHive.Cells:GetDescendants()) do
				if Cell.Name == "SurfaceGui" then
					for _, Gui in pairs(Cell:GetChildren()) do
						if Gui.Name == "TextLabel" then
							local numberText = Gui.Text
							local number = tonumber(numberText)
							if number and number < lowestNumber then
								lowestNumber = number
								lowestParentName = Gui.Parent.Parent.Parent

								local C1 = lowestParentName:FindFirstChild("CellX")
								local C2 = lowestParentName:FindFirstChild("CellY")

								if C1 and C2 then

									local ohNumber1 = C1.Value
									local ohNumber2 = C2.Value

									game:GetService("ReplicatedStorage").Events.GetBondToLevel:InvokeServer(ohNumber1, ohNumber2)

									local ohNumber1 = C1.Value
									local ohNumber2 = C2.Value
									local ohString3 = Food
									local ohNumber4 = 1
									local ohBoolean5 = false

									game:GetService("ReplicatedStorage").Events.ConstructHiveCellFromEgg:InvokeServer(ohNumber1, ohNumber2, ohString3, ohNumber4, ohBoolean5)
						
									wait(0.5)
								end
							end
						end
					end
				end
			end
			wait(1)
		end
	end
	--[[
	Tabs.Tab6:AddParagraph({
        Title = "",
    })
	--]]
	local TreatTable = {}

	for itemName, itemData in pairs(Items) do
		if itemData.TreatValue then
			table.insert(TreatTable, itemName)
		end
	end

	local SelectedTreat1 = TreatTable[1]
	
    local TreatDropdown2 = Tabs.Tab6:AddDropdown("Dropdown", {
        Title = "🍬 Select Treat",
        Values = TreatTable,
        Multi = false,
        Default = "Select Treat",
    })

	TreatDropdown2:OnChanged(function(Value)
		SelectedTreat1 = Value
	end)

	local FeewLowestToggle = Tabs.Tab6:AddToggle("FeedLowest1", {Title = "🐝 Feed Lowest Bees [Lvl 1 >]", Default = false })

	spawn(function()
		while wait() do 
			if Options.FeedLowest1.Value == true then 
				FeedLowestBee(SelectedTreat1)
			end
		end
	end)

	-- Tokens 🔴

	-- Functions 🔴

	local function pathfind(targetPosition)
		local PathfindingService = game:GetService("PathfindingService")
		local Humanoid = game.Players.LocalPlayer.Character.Humanoid
		local Root = game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")

		if Root then
			local path = PathfindingService:CreatePath({
				AgentCanJump = true,
				WaypointSpacing = 1
			})
			path:ComputeAsync(Root.Position, targetPosition)
			local waypoints = path:GetWaypoints()

			for _, waypoint in ipairs(waypoints) do
				Humanoid:MoveTo(waypoint.Position)
				Humanoid.MoveToFinished:Wait()

				-- Check if the waypoint requires jumping
				if waypoint.Action == Enum.PathWaypointAction.Jump then
					Humanoid.Jump = true
				end
			end
		else
			warn("HumanoidRootPart not found.")
		end
	end

	local collectibleConnection = nil
	local collectiblesFolder = game:GetService("Workspace").Collectibles

	local function isWithinDistance(part, maxDistance)
		local player = game.Players.LocalPlayer
		local character = player.Character

		if character and character:FindFirstChild("HumanoidRootPart") and part:IsA("BasePart") then
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			local distance = (humanoidRootPart.Position - part.Position).Magnitude
			return tonumber(distance) <= tonumber(maxDistance)
		end

		return false
	end

	local function teleportToCollectible(collectible, maxDistance)
		if isWithinDistance(collectible, maxDistance) then
			local player = game.Players.LocalPlayer
			local character = player.Character

			if character and character:FindFirstChild("HumanoidRootPart") and collectible:IsA("Part") and collectible.Transparency > 0.9 then
				local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
				humanoidRootPart.CFrame = collectible.CFrame
				
				wait(0.1)
			end
		end
	end

	local function onCollectibleAdded(collectible)
		teleportToCollectible(collectible, maxDistance)
	end

	local collectibleConnection

	local function collectTokens()
		if Options.TokenToggleGlobal1.Value then
			Status = CalculateBag()
			if Status ~= "Full" and not collectibleConnection then
				collectibleConnection = collectiblesFolder.ChildAdded:Connect(onCollectibleAdded)
			end
		elseif collectibleConnection then
			collectibleConnection:Disconnect()
			collectibleConnection = nil
		end
		wait()
	end

	local function collectRareTokens()
			if Options.TokenToggleGlobal2.Value == true then
				for _, collectible in pairs(workspace.Collectibles:GetChildren()) do
					if collectible:IsA("BasePart") and collectible.Transparency == 1 then
						repeat
							local player = game.Players.LocalPlayer
							local character = player.Character or player.CharacterAdded:Wait()

							for _, v in pairs(character:GetDescendants()) do
								pcall(function()
									if v:IsA("BasePart") then
										v.CanCollide = false
									end
								end)
							end

							local teleportPosition = collectible.Position + Vector3.new(0, 3, 0)
							game.Players.LocalPlayer.Character:SetPrimaryPartCFrame(CFrame.new(teleportPosition))
							wait()
						until collectible.Transparency <= 0.5 or collectible.Transparency == 0 or Options.TokenToggleGlobal2.Value == false or not collectible
					end
				end
			end
		wait() 
	end

	-- Toggles 🔴

	local TokenToggle = Tabs.Tab4:AddToggle("TokenToggleGlobal1", {Title = "🟡 Collect Tokens [⚠️]", Default = false })

	local maxDistance = 50

	local function updateMaxDistance(value)
		maxDistance = value
	end

	local MaxDistanceSlider = Tabs.Tab4:AddSlider("MaxDistanceSlider", {
    Title = "┗› Distance",
    Description = "Max distance for tokens",
    Default = maxDistance,
    Min = 1,
    Max = 600,
    Rounding = 0,
    Callback = function(Value)
        updateMaxDistance(Value)
    end
	})

	MaxDistanceSlider:SetValue(maxDistance)

	spawn(function()
		while wait() do 
			if Options.TokenToggleGlobal1.Value then
				Status = CalculateBag()
				if Status ~= "Full" then
					local player = game.Players.LocalPlayer
					local character = player.Character
					if character then
						for _, collectible in pairs(workspace.Collectibles:GetChildren()) do
							if collectible:IsA("BasePart") and collectible.Transparency < 1 then
								local distance = (character.HumanoidRootPart.Position - collectible.Position).Magnitude
								if tonumber(distance) <= tonumber(maxDistance) then
									teleportToCollectible(collectible, maxDistance)
								end
							end
						end
					end
				end
			end
		end
	end)

	-- Run Token Toggles 🔴

	spawn(function()
		while wait() do 
			--collectTokens()
			collectRareTokens()
		end
	end)

	-- 

	local function onCollectibleAdded(collectible)
		if Options.TokenToggleGlobal3.Value == true then
			pathfind(collectible.Position)
		end
	end

	local WalkTokenToggle = Tabs.Tab4:AddToggle("TokenToggleGlobal3", {Title = "🟡 Walk To Tokens", Default = false })

	-- Walk to Tokens 🔴

	local TokenWalkDistance = 50 

	local function updateTokenWalkDistance(value)
		TokenWalkDistance = value
	end

	local WalkDistance = Tabs.Tab4:AddSlider("TokenWalkDistance", {
		Title = "┗› Distance",
		Description = "Max distance for tokens",
		Default = TokenWalkDistance, 
		Min = 0,
		Max = 250,
		Rounding = 1,
		Callback = function(Value)
			updateTokenWalkDistance(Value) 
		end
	})

	WalkDistance:SetValue(TokenWalkDistance)

	spawn(function()
		while wait() do 
			if Options.TokenToggleGlobal3.Value == true then
				local character = game.Players.LocalPlayer.Character
				if character then
					for _, collectible in pairs(workspace.Collectibles:GetChildren()) do
						if collectible:IsA("BasePart") and collectible.Transparency < 1 then
							local distance = (character.HumanoidRootPart.Position - collectible.Position).Magnitude
							if tonumber(distance) <= tonumber(TokenWalkDistance) then
								pathfind(collectible.Position)
								wait() 
							end
						end
					end
				end
			end
		end
	end)

	local RareTokenToggle = Tabs.Tab4:AddToggle("TokenToggleGlobal2", {Title = "🟡 Collect Rare Tokens [⚠️]", Default = false })

	-- Shop -- 🔴

	Tabs.Tab2:AddButton({
        Title = "Purchase Hive Slot",
        --Description = "",
        Callback = function()
            Window:Dialog({
                Title = "Are you sure?",
                --Content = "",
                Buttons = {
                    {
                        Title = "Confirm",
                        Callback = function()
                            local args = {
								[1] = "Purchase",
								[2] = {
									["Type"] = "Hive Slot",
									["Amount"] = 1,
									["Category"] = "HiveSlot"
								}
							}

							game:GetService("ReplicatedStorage").Events.ItemPackageEvent:InvokeServer(unpack(args))

							game:GetService("ReplicatedStorage").Events.RetrievePlayerStats:InvokeServer()
                        end
                    },
                    {
                        Title = "Cancel",
                        Callback = function()
                            --print("Cancelled the dialog.")
                        end
                    }
                }
            })
        end
    })


	local SelectedItem = nil

	local function categorizeItems(itemPath, collectorTable, accessoryTable)
		for _, item in pairs(itemPath:GetDescendants()) do
			if item:FindFirstChild("ItemCategory") then
				local itemCategory = item.ItemCategory.Value
				if itemCategory == "Collector" then
					table.insert(collectorTable, item)
				elseif itemCategory == "Accessory" then
					table.insert(accessoryTable, item)
				end
			end
		end
	end

	local BasicCollectors = {}
	local BasicAccessories = {}
	local ProCollectors = {}
	local ProAccessories = {}

	local BasicPath = game:GetService("Workspace").Shops.BasicShop.Items
	local ProPath = game:GetService("Workspace").Shops.ProShop.Items

	categorizeItems(BasicPath, BasicCollectors, BasicAccessories)

	categorizeItems(ProPath, ProCollectors, ProAccessories)

	local BasicCollectorNames = {}
	local BasicAccessoryNames = {}
	local ProCollectorNames = {}
	local ProAccessoryNames = {}

	for _, collector in ipairs(BasicCollectors) do
		table.insert(BasicCollectorNames, collector.Name)
	end

	for _, accessory in ipairs(BasicAccessories) do
		table.insert(BasicAccessoryNames, accessory.Name)
	end

	for _, collector in ipairs(ProCollectors) do
		table.insert(ProCollectorNames, collector.Name)
	end

	for _, accessory in ipairs(ProAccessories) do
		table.insert(ProAccessoryNames, accessory.Name)
	end

	local BasicCollectorSelected = nil
	local BasicAccessorySelected = nil
	local ProCollectorSelected = nil
	local ProAccessorySelected = nil

	local function BuyCollector(BasicCollectorSelected)
		if BasicCollectorSelected then
			local ohString1 = "Purchase"
			local ohTable2 = {
				["Type"] = BasicCollectorSelected,
				["Category"] = "Collector"
			}

			game:GetService("ReplicatedStorage").Events.ItemPackageEvent:InvokeServer(ohString1, ohTable2)
		end
	end

	local function BuyAccessory(BasicAccessorySelected)
		if BasicAccessorySelected then
			local ohString1 = "Purchase"
			local ohTable2 = {
				["Type"] = BasicAccessorySelected,
				["Category"] = "Accessory"
			}

			game:GetService("ReplicatedStorage").Events.ItemPackageEvent:InvokeServer(ohString1, ohTable2)
		end
	end

	-- 1 Buy Basic Collectors 🔴

	local BasicCollectorDropdown = Tabs.Tab2:AddDropdown("Dropdown", {
        Title = "🏺 Select Basic Collector",
        Values = BasicCollectorNames,
        Multi = false,
        Default = 1,
    })

	BasicCollectorDropdown:OnChanged(function(Value)
		BasicCollectorSelected = Value
	end)

    Tabs.Tab2:AddButton({
    Title = "Purchase",
    Description = "Purchase Basic Collector",
    Callback = function()
        if BasicCollectorSelected then
            Window:Dialog({
                Title = "Confirm Purchase",
                Content = "Are you sure you want to purchase this item?",
                Buttons = {
                    {
                        Title = "Confirm",
                        Callback = function()
                            BuyCollector(BasicCollectorSelected)
                        end
                    },
                    {
                        Title = "Cancel",
                        Callback = function()
                            --print("Purchase cancelled.")
                        end
                    }
                }
            })
        else
            --print("Please select an item to purchase.")
        end
    end
	})

	-- 2 Buy Basic Accessories 🔴

	local BasicAccessoryDropdown = Tabs.Tab2:AddDropdown("Dropdown", {
    Title = "🧣 Select Basic Accessory",
    Values = BasicAccessoryNames,
    Multi = false,
    Default = 1,
	})

	BasicAccessoryDropdown:OnChanged(function(Value)
		BasicAccessorySelected = Value
	end)

	Tabs.Tab2:AddButton({
		Title = "Purchase",
		Description = "Purchase Basic Accessory",
		Callback = function()
			if BasicAccessorySelected then
				Window:Dialog({
					Title = "Confirm Purchase",
					Content = "Are you sure you want to purchase this item?",
					Buttons = {
						{
							Title = "Confirm",
							Callback = function()
								BuyAccessory(BasicAccessorySelected)
							end
						},
						{
							Title = "Cancel",
							Callback = function()
								--print("Purchase cancelled.")
							end
						}
					}
				})
			else
				--print("Please select an item to purchase.")
			end
		end
	})

	-- 3 Buy Pro Collectors 🔵

	local ProCollectorDropdown = Tabs.Tab2:AddDropdown("Dropdown", {
		Title = "🏺 Select Pro Collector",
		Values = ProCollectorNames,
		Multi = false,
		Default = 1,
	})

	local ProCollectorSelected = nil

	ProCollectorDropdown:OnChanged(function(Value)
		ProCollectorSelected = Value
	end)

	Tabs.Tab2:AddButton({
		Title = "Purchase",
		Description = "Purchase Pro Collector",
		Callback = function()
			if ProCollectorSelected then
				Window:Dialog({
					Title = "Confirm Purchase",
					Content = "Are you sure you want to purchase this Pro collector?",
					Buttons = {
						{
							Title = "Confirm",
							Callback = function()
								BuyCollector(ProCollectorSelected)
							end
						},
						{
							Title = "Cancel",
							Callback = function()
								-- print("Purchase cancelled.")
							end
						}
					}
				})
			else
				-- print("Please select a Pro collector to purchase.")
			end
		end
	})

	-- 4 Buy Pro Accessories 🔵

	local ProAccessoryDropdown = Tabs.Tab2:AddDropdown("Dropdown", {
		Title = "🧣 Select Pro Accessory",
		Values = ProAccessoryNames,
		Multi = false,
		Default = 1,
	})

	local ProAccessorySelected = nil

	ProAccessoryDropdown:OnChanged(function(Value)
		ProAccessorySelected = Value
	end)

	Tabs.Tab2:AddButton({
		Title = "Purchase",
		Description = "Purchase Pro Accessory",
		Callback = function()
			if ProAccessorySelected then
				Window:Dialog({
					Title = "Confirm Purchase",
					Content = "Are you sure you want to purchase this Pro accessory?",
					Buttons = {
						{
							Title = "Confirm",
							Callback = function()
								BuyAccessory(ProAccessorySelected)
							end
						},
						{
							Title = "Cancel",
							Callback = function()
								-- print("Purchase cancelled.")
							end
						}
					}
				})
			else
				-- print("Please select a Pro accessory to purchase.")
			end
		end
	})

	-- Equip 🔴

	local AccessoriesTable = {}
	local MaskTable = {}
	local CollectorsTable = {}

	local ReplicatedStorage = game:GetService("ReplicatedStorage")
	local AccessoriesFolder = ReplicatedStorage.Accessories
	local CollectorsModule = require(ReplicatedStorage.Collectors)

	for _, accessory in ipairs(AccessoriesFolder:GetChildren()) do
		if accessory.Name ~= "UpdateMeter" and not string.match(accessory.Name, "Mask") then
			table.insert(AccessoriesTable, accessory.Name)
		end

		if string.match(accessory.Name, "Mask") then
			table.insert(MaskTable, accessory.Name)
		end
	end

	local CollectorsTable = {}

	for _,v in next, getupvalues(require(game:GetService("ReplicatedStorage").Collectors).Exists) do for e,r in next, v do table.insert(CollectorsTable, e) end end

	table.sort(AccessoriesTable)
	table.sort(MaskTable)
	table.sort(CollectorsTable)

	-- 1 Equip Collectors 

	local EquipCollectors = Tabs.Tab3:AddDropdown("Dropdown", {
		Title = "🏺 Select Collector",
		Values = CollectorsTable,
		Multi = false,
		Default = 1,
	})

	local CollectorSelected1 = nil

	EquipCollectors:OnChanged(function(Value)
		CollectorSelected1 = Value
	end)

		Tabs.Tab3:AddButton({
		Title = "Equip",
		Description = "Equip Collector",
		Callback = function()
			if CollectorSelected1 then
				Window:Dialog({
					Title = "Confirm Purchase",
					Content = "Are you sure you want to equip this collector?",
					Buttons = {
						{
							Title = "Confirm",
							Callback = function()
								
							local args = {
								[1] = "Equip",
								[2] = {
									["Type"] = CollectorSelected1,
									["Category"] = "Collector"
									}
								}

								game:GetService("ReplicatedStorage").Events.ItemPackageEvent:InvokeServer(unpack(args))	
							end
						},
						{
							Title = "Cancel",
							Callback = function()
								-- print("Purchase cancelled.")
							end
						}
					}
				})
			else
				-- print("Please select a Pro collector to purchase.")
			end
		end
	})

	-- 2 Equip Accessories 🔴

	local EquipAccessories = Tabs.Tab3:AddDropdown("Dropdown", {
		Title = "🧣 Select Accessory",
		Values = AccessoriesTable,
		Multi = false,
		Default = 1,
	})

	local AccessorySelected1 = nil

	EquipAccessories:OnChanged(function(Value)
		AccessorySelected1 = Value
	end)

		Tabs.Tab3:AddButton({
		Title = "Equip",
		Description = "Equip Accessory",
		Callback = function()
			if AccessorySelected1 then
				Window:Dialog({
					Title = "Confirm Purchase",
					Content = "Are you sure you want to equip this Accessories?",
					Buttons = {
						{
							Title = "Confirm",
							Callback = function()
								
							local args = {
								[1] = "Equip",
								[2] = {
									["Type"] = AccessorySelected1,
									["Category"] = "Accessory"
									}
								}

								game:GetService("ReplicatedStorage").Events.ItemPackageEvent:InvokeServer(unpack(args))	
							end
						},
						{
							Title = "Cancel",
							Callback = function()
								-- print("Purchase cancelled.")
							end
						}
					}
				})
			else
				-- print("Please select a Pro collector to purchase.")
			end
		end
	})

	-- 3 Equip Masks 🔴

	local EquipMasks = Tabs.Tab3:AddDropdown("Dropdown", {
		Title = "🎭 Select Mask",
		Values = MaskTable,
		Multi = false,
		Default = 1,
	})

	local MaskSelected1 = nil

	EquipMasks:OnChanged(function(Value)
		MaskSelected1 = Value
	end)

	Tabs.Tab3:AddButton({
		Title = "Equip",
		Description = "Equip Mask",
		Callback = function()
			if MaskSelected1 then
				Window:Dialog({
					Title = "Confirm Equip",
					Content = "Are you sure you want to equip this mask?",
					Buttons = {
						{
							Title = "Confirm",
							Callback = function()
								local args = {
									[1] = "Equip",
									[2] = {
										["Type"] = MaskSelected1,
										["Category"] = "Mask"
									}
								}
								game:GetService("ReplicatedStorage").Events.ItemPackageEvent:InvokeServer(unpack(args))
							end
						},
						{
							Title = "Cancel",
							Callback = function()
								-- print("Equip cancelled.")
							end
						}
					}
				})
			else
				-- print("Please select a mask to equip.")
			end
		end
	})

	local MaskToggle = Tabs.Tab3:AddToggle("MaskToggle1", {Title = "🎭 Loop Equip Mask", Default = false })

	spawn(function()
		while wait() do
			if Options.MaskToggle1.Value == true then
				local args = {
					[1] = "Equip",
					[2] = {
						["Type"] = MaskSelected1,
						["Category"] = "Mask"
					}
				}
				game:GetService("ReplicatedStorage").Events.ItemPackageEvent:InvokeServer(unpack(args))
				wait(3)
			end
		end
	end)

	-- Teleports 🔴

	-- Functions 🔴

	local function teleportToPosition(position)
    if game.Players.LocalPlayer.Character then
			local humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
			if humanoidRootPart then
				humanoidRootPart.CFrame = position
			end
		end
	end

	local function createDropdown(tab, title, values, teleportFunction)
		local dropdown = tab:AddDropdown("Dropdown", {
			Title = title,
			Values = values,
			Multi = false,
			Default = "Select",
		})

		dropdown:OnChanged(function(Value)
			teleportFunction(Value)
		end)

		return dropdown
	end

	-- 1 Fields 🔴

	local function teleportToField(selectedFieldName)
		local field = game:GetService("Workspace").FlowerZones:FindFirstChild(selectedFieldName)
		if field then
			local fieldPosition = field.Position + Vector3.new(0, 10, 5)
			teleportToPosition(CFrame.new(fieldPosition))
		end
	end

	local FieldsTable = {}

	for _, field in pairs(game:GetService("Workspace").FlowerZones:GetChildren()) do
		if field:IsA("Part") then
			table.insert(FieldsTable, field.Name)
		end
	end

	table.sort(FieldsTable)
	createDropdown(Tabs.Tab1, "🌾 Fields", FieldsTable, teleportToField)

	local function teleportToNPC(selectedNPCName)
		local npc = game:GetService("Workspace").NPCs:FindFirstChild(selectedNPCName)
		if npc then
			local npcPosition = npc.Stand.Position + Vector3.new(0, 10, 5)
			teleportToPosition(CFrame.new(npcPosition))
		end
	end

	-- 2 NPCS 🔴

	local NPCTable = {}

	for _, v in pairs(game:GetService("Workspace").NPCs:GetChildren()) do
		if v then
			table.insert(NPCTable, v.Name)
		end
	end

	createDropdown(Tabs.Tab1, "🕵️‍♂️ NPCs", NPCTable, teleportToNPC)

	local function teleportToSpawner(selectedSpawnerName)
		local spawner = game:GetService("Workspace").MonsterSpawners:FindFirstChild(selectedSpawnerName)
		if spawner then
			local spawnerPosition = spawner.Position + Vector3.new(0, 10, 5)
			teleportToPosition(CFrame.new(spawnerPosition))
		end
	end

	-- 3 Spawners 🔴

	local SpawnersTable = {}

	for _, spawner in pairs(game:GetService("Workspace").MonsterSpawners:GetChildren()) do
		if spawner then
			table.insert(SpawnersTable, spawner.Name)
		end
	end

	createDropdown(Tabs.Tab1, "👾 Spawners", SpawnersTable, teleportToSpawner)

	local function teleportToToy(selectedToyName)
		local toy = game:GetService("Workspace").Toys:FindFirstChild(selectedToyName)
		if toy then
			local toyPosition = toy.Platform.Position
			teleportToPosition(CFrame.new(toyPosition))
		end
	end

	-- 4 Toys 🔴

	local ToysTable = {}

	for _, toy in pairs(game:GetService("Workspace").Toys:GetChildren()) do 
		if toy then 
			table.insert(ToysTable, toy.Name)
		end
	end

	createDropdown(Tabs.Tab1, "🎮 Toys", ToysTable, teleportToToy)

	-- 5 Shops 🔴

	local ShopTeleports = {
		["Bee Shop"] = CFrame.new(-136.8, 4.6, 243.4),
		["Basic Shop"] = CFrame.new(86, 4.6, 294),
		["Pro Shop "] = CFrame.new(165, 69, -161),
		["Mountain Top Shop"] = CFrame.new(-18, 176, -137),
		["Red HQ Shop"] = CFrame.new(-334, 21, 216),
		["Blue HQ Shop"] = CFrame.new(292, 4, 98),
	}

	local ShopTeleportOptions = {}

	for waypointName, _ in pairs(ShopTeleports) do
		table.insert(ShopTeleportOptions, waypointName)
	end

	createDropdown(Tabs.Tab1, "🛒 Shops", ShopTeleportOptions, function(waypointName)
		local targetCFrame = ShopTeleports[waypointName]
		if targetCFrame then
			teleportToPosition(targetCFrame)
		end
	end)

	-- 6 Players 🔴

	local PlayersTable = {}

	for _, player in pairs(game.Players:GetPlayers()) do
		if player ~= game.Players.LocalPlayer then
			table.insert(PlayersTable, player.Name)
		end
	end

	table.sort(PlayersTable)

	createDropdown(Tabs.Tab1, "👤 Players ", PlayersTable, function(playerName)
		local player = game.Players:FindFirstChild(playerName)
		if player then
			local playerPosition = player.Character.HumanoidRootPart.Position
			local playerCFrame = CFrame.new(playerPosition)
			teleportToPosition(playerCFrame)
		end
	end)

	 Tabs.Tab1:AddButton({
        Title = "🍯 Teleport To Hive",
        --Description = "",
        Callback = function()
            Window:Dialog({
                Title = "Teleport To Hive",
                --Content = "This is a dialog",
                Buttons = {
                    {
                        Title = "Confirm",
                        Callback = function()
							TeleportToHive()
                            --print("Confirmed the dialog.")
                        end
					}, 
                    {
                        Title = "Cancel",
                        Callback = function()
                            --print("Cancelled the dialog.")
                        end
                    }
                }
            })
        end
    })



	local Input = Tabs.Settings:AddInput("Input", {
		Title = "🚫 Blacklist Quest",
		Default = "",
		Placeholder = "Full Name",
		Numeric = false, 
		Finished = true, 
		Callback = function(Value)
			--print("Input changed:", Value)
			BlackListedQuest = Value
		end
	})

	Input:OnChanged(function()
		--print("Input updated:", Input.Value)
		BlackListedQuest = Input.Value
	end)

	local Input1 = Tabs.Settings:AddInput("Input1", {
		Title = "🚫 Blacklist Quest",
		Default = "",
		Placeholder = "Full Name",
		Numeric = false, 
		Finished = true, 
		Callback = function(Value)
			--print("Input changed:", Value)
			BlackListedQuest1 = Value
		end
	})

	Input1:OnChanged(function()
		--print("Input1 updated:", Input1.Value)
		BlackListedQuest1 = Input1.Value
	end)

	local Input2 = Tabs.Settings:AddInput("Input1", {
		Title = "🚫 Blacklist Quest",
		Default = "",
		Placeholder = "Full Name",
		Numeric = false, 
		Finished = true, 
		Callback = function(Value)
			--print("Input changed:", Value)
			BlackListedQuest2 = Value
		end
	})

	Input2:OnChanged(function()
		--print("Input1 updated:", Input1.Value)
		BlackListedQuest2 = Input2.Value
	end)

	end

	--[[

	local MultiDropdown = Tabs.Settings:AddDropdown("MultiDropdown", {
		Title = "🗺️ Select Quest",
		Description = "Quest to Accept / Submit [Multi Select]",
		Values = {"Black Bear", "Mother Bear", "Science Bear", "Brown Bear", "Panda Bear"},
		Multi = true,
		Default = {},
	})

	local Values = {}

	MultiDropdown:OnChanged(function(Value)
		Values = {}  -- Reset the Values table
		for questName, isSelected in pairs(Value) do
			if isSelected then
				table.insert(Values, questName)  -- Store selected quests in the Values table
			end
		end
		print("MultiDropdown changed:", table.concat(Values, ", "))
	end)

	spawn(function()
		while wait() do
			if Options.QuestAuto.Value == true then

					local ReplicatedStorage = game:GetService("ReplicatedStorage")
					local CompleteQuestEvent = ReplicatedStorage.Events.CompleteQuest
					local GiveQuestEvent = ReplicatedStorage.Events.GiveQuest

					local Comp = function(q1)
						for _, questName in pairs(q1) do
							CompleteQuestEvent:FireServer(questName)
						end
					end

					local Give = function(q1)
						for _, questName in pairs(q1) do
							GiveQuestEvent:FireServer(questName)
						end
					end
					
				print("QuestAuto is ON")
				for _, questName in pairs(Values) do
					print("Processing quest:", questName)
					if questName == "Black Bear" then 
						print("Completing Black Bear Quest")
						Comp(BlackBearQuest)
						wait(0.5)
						print("Giving Black Bear Quest")
						Give(BlackBearQuest)
						wait(0.5)
					elseif questName == "Mother Bear" then
						print("Completing Mother Bear Quest")
						Comp(MotherBearQuest)
						wait(0.5)
						print("Giving Mother Bear Quest")
						Give(MotherBearQuest)
						wait(0.5)
					-- Add other quest conditions here
					elseif questName == "Science Bear" then
							print("Completing Science Bear Quest")
							Comp(ScienceBearQuest)
							wait(0.5)
							print("Giving Science Bear Quest")
							Give(ScienceBearQuest)
							wait(0.5)
						elseif questName == "Brown Bear" then
							print("Completing Brown Bear Quest")
							Comp(BrownBearQuest)
							wait(0.5)
							print("Giving Brown Bear Quest")
							Give(BrownBearQuest)
							wait(0.5)
						elseif questName == "Panda Bear" then
							print("Completing Panda Bear Quest")
							Comp(PandaBearQuest)
							wait(0.5)
							print("Giving Panda Bear Quest")
							Give(PandaBearQuest)
							wait(0.5)
						end
					end
				
			else
				--print("QuestAuto is OFF")
			end
		end
	end)

	--]]



	-- 🔴

-- Addons:
-- SaveManager (Allows you to have a configuration system)
-- InterfaceManager (Allows you to have a interface managment system)

-- Hand the library over to our managers
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)

-- Ignore keys that are used by ThemeManager.
-- (we dont want configs to save themes, do we?)
SaveManager:IgnoreThemeSettings()

-- You can add indexes of elements the save manager should ignore
SaveManager:SetIgnoreIndexes({})

-- use case for doing it this way:
-- a script hub could have themes in a global folder
-- and game configs in a separate folder per game
InterfaceManager:SetFolder("FluentScriptHub")
SaveManager:SetFolder("FluentScriptHub/specific-game")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

SaveManager:BuildConfigSection(Tabs.Settings)

Window:SelectTab(1)

Fluent:Notify({
    Title = "Fluent",
    Content = "The script has been loaded.",
    Duration = 8
})

-- You can use the SaveManager:LoadAutoloadConfig() to load a config
-- which has been marked to be one that auto loads!
SaveManager:LoadAutoloadConfig()