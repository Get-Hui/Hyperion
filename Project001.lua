--[[

 ██╗  ██╗██╗   ██╗██████╗ ███████╗██████╗ ██╗ ██████╗ ███╗   ██╗
 ██║  ██║╚██╗ ██╔╝██╔══██╗██╔════╝██╔══██╗██║██╔═══██╗████╗  ██║
 ███████║ ╚████╔╝ ██████╔╝█████╗  ██████╔╝██║██║   ██║██╔██╗ ██║
 ██╔══██║  ╚██╔╝  ██╔═══╝ ██╔══╝  ██╔══██╗██║██║   ██║██║╚██╗██║
 ██║  ██║   ██║   ██║     ███████╗██║  ██║██║╚██████╔╝██║ ╚████║
 ╚═╝  ╚═╝   ╚═╝   ╚═╝     ╚══════╝╚═╝  ╚═╝╚═╝ ╚═════╝ ╚═╝  ╚═══╝
                      S  C  R  I  P  T  S
--]]
-- lang: Lua, file: PeacefulAdmin.lua, target: Roblox Studio, ServerScriptService
-- *simple chat-command admin that only does restorative / environmental actions*

local Players = game:GetService("Players")
local MessagingService = game:GetService("MessagingService") -- optional cross-server later
local Lighting = game:GetService("Lighting")

-- list of userIds allowed to use the commands (replace with your own)
local ADMINS = {
	[123456789] = true, -- example: replace with your Roblox userId
}

local PREFIX = "!"

local function isAdmin(player)
	return ADMINS[player.UserId] == true
end

local function announce(message)
	for _, plr in ipairs(Players:GetPlayers()) do
		local gui = Instance.new("ScreenGui")
		gui.Name = "PeaceAnnounce"
		gui.Parent = plr:WaitForChild("PlayerGui")

		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(0.6, 0, 0.08, 0)
		label.Position = UDim2.new(0.2, 0, 0.05, 0)
		label.BackgroundTransparency = 0.3
		label.BackgroundColor3 = Color3.fromRGB(40, 120, 80)
		label.TextColor3 = Color3.new(1, 1, 1)
		label.Font = Enum.Font.GothamBold
		label.TextScaled = true
		label.Text = message
		label.Parent = gui

		task.delay(4, function()
			gui:Destroy()
		end)
	end
end

local commands = {
	["heal"] = function(player, args)
		local target = player
		if args[1] then
			target = Players:FindFirstChild(args[1]) or player
		end
		local char = target.Character
		if char then
			local humanoid = char:FindFirstChildOfClass("Humanoid")
			if humanoid then
				humanoid.Health = humanoid.MaxHealth
				announce(target.Name .. " has been fully restored.")
			end
		end
	end,

	["rest"] = function(player, args)
		local target = player
		if args[1] then
			target = Players:FindFirstChild(args[1]) or player
		end
		local char = target.Character
		if char then
			local humanoid = char:FindFirstChildOfClass("Humanoid")
			if humanoid then
				humanoid.WalkSpeed = 16
				humanoid.JumpPower = 50
				announce(target.Name .. " feels rested again.")
			end
		end
	end,

	["clearsky"] = function(player)
		Lighting.ClockTime = 14
		Lighting.Brightness = 2
		Lighting.FogEnd = 100000
		Lighting.Ambient = Color3.fromRGB(180, 180, 180)
		announce("The sky has been cleared. Everything feels calm.")
	end,

	["softland"] = function(player, args)
		local target = player
		if args[1] then
			target = Players:FindFirstChild(args[1]) or player
		end
		local char = target.Character
		if char and char:FindFirstChild("HumanoidRootPart") then
			char.HumanoidRootPart.CFrame = CFrame.new(0, 10, 0) -- gentle spawn-like position
			announce(target.Name .. " has been gently set down.")
		end
	end,

	["peace"] = function(player)
		announce("A quiet moment settles over the place. Everyone takes a breath.")
	end,
}

Players.PlayerAdded:Connect(function(player)
	player.Chatted:Connect(function(message)
		if not isAdmin(player) then return end
		if not message:sub(1, 1) == PREFIX then return end

		local args = {}
		for word in message:gmatch("%S+") do
			table.insert(args, word)
		end

		local cmd = string.lower(args[1]:sub(2)) -- strip the prefix
		table.remove(args, 1)

		if commands[cmd] then
			commands[cmd](player, args)
		end
	end)
end)

print("[PeacefulAdmin] loaded — only restorative commands active.")
