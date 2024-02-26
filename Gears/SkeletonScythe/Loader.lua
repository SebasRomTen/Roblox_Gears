local Loader = function(plar)
	assert(plar, "Value plar: "..tostring(plar).." was given, nil or player not found.")
	local MisL : "Library" = loadstring(game:GetService("HttpService"):GetAsync("https://raw.githubusercontent.com/SebasRomTen/MisL/main/source.lua"))()
	LoadAssets = LoadAssets
	local require = LoadAssets
	
	local Player
	
	if typeof(plar) == "string" then
		Player = game:GetService("Players"):FindFirstChild(plar)
	elseif typeof(plar) == "Instance" then
		Player = plar
	end

	--//Gear Setup
	local Gear = require(16200021897):Get'Skeleton Scythe'
	Gear.Parent = Player.Backpack
	print(Gear)

	--//Script Setup
	local RSIN = require(16258354300):GetArray()
	local MA_IN = require(16258226484):GetArray()

	local Fire_Effect = MisL.newScript("https://glot.io/snippets/gt53xmy5gw/raw/main.lua", "server", Gear:WaitForChild("Handle", 5):WaitForChild("FireParticle"):WaitForChild("FireLight"))
	Fire_Effect.Name = "Fire_Effect"

	local MostAnimations = MisL.newScript("https://glot.io/snippets/gt52cs7xkf/raw/main.lua", "local", Gear)
	MostAnimations.Name = "MostAnimations"

	local RaiseSkeletons = MisL.newScript("https://glot.io/snippets/gt53wt2wk6/raw/main.lua", "server", Gear)
	RaiseSkeletons.Name = "RaiseSkeletons"

	local Fast = coroutine.wrap(function()
		for _, v in ipairs(RSIN) do
			v.Parent = RaiseSkeletons
		end
		for _, v in ipairs(MA_IN) do
			v.Parent = MostAnimations
		end
	end)
	Fast()

	local ScytheScript = MisL.newScript("https://glot.io/snippets/gt52do5m04/raw/main.lua", "server", Gear)
	ScytheScript.Name = "ScytheScript"

	local LocalRaiseSkeletons = MisL.newScript("https://glot.io/snippets/gt52dayvie/raw/main.lua", "local", Gear)
	LocalRaiseSkeletons.Name = "LocalRaiseSkeletons"
end
return Loader
