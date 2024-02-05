--[[
	Gear Library by ArceusInator.
	
	Using this to make it easy to make and edit gear.
	
	Converted to script by SebasRomTen
--]]

local Instance_new = Instance.new
local BaseEvent = Instance_new'BindableEvent'
local Signal_connect = BaseEvent.Event.connect
local Event_Fire = BaseEvent.Fire
local Event_Destroy = BaseEvent.Destroy
local Players = game:GetService'Players'

local cooldowns = {}
local RenderStepped = game:GetService'RunService'.RenderStepped
local CAS = game:GetService'ContextActionService'

local Debris = game:GetService'Debris'

local Lib = {}

Lib.Script = script

Lib.GetDescendants = function(object)
	local list = {}

	local search;search = function(parent)
		for index, child in next, parent:GetChildren() do
			table.insert(list, child)
			search(child)
		end
	end

	search(object)

	return list
end

Lib.CFrameModel = function(model, target, primary)
	local descendants = Lib.GetDescendants(model)
		
	local primary = primary or target.CFrame
		
	--
	local localCFrames = {}
	for i, object in next, descendants do
		if object:IsA'BasePart' then
			localCFrames[object] = primary.CFrame:toObjectSpace(object.CFrame)
		end
	end
		
	primary.CFrame = target
	
	for part, localCFrame in next, localCFrames do
		part.CFrame = target:toWorldSpace(localCFrame)
	end
end
	
Lib.Create = function(className, defaultParent)
	return function(propList)
		local new = Instance.new(className)
		local parent = defaultParent
		
		for index, value in next, propList do
			if type(index)=='string' then
				if index == 'Parent' then
					parent = value
				else
					new[index] = value
				end
			elseif type(index)=='number' then
				value.Parent = new
			end
		end
		
		new.Parent = parent	
		return new
	end
end

Lib.FastSpawn = function(callback, ...)
	local event = Instance_new'BindableEvent'

	--event.Event:connect(callback)
	Signal_connect(event.Event, callback)

	--event:Fire(...)
	Event_Fire(event, ...)

	--event:Destroy()
	Event_Destroy(event)
end

local fullmeta;fullmeta = function(t, meta)
	setmetatable(t, meta)
	for index, other in next, t do
		if type(other) == 'table' then
			fullmeta(other, meta)
		end
	end

	return t
end

Lib.FullMeta = fullmeta

Lib.GetHumanoid = function(obj)
	if obj then
		for i, child in next, obj:GetChildren() do
			if child:IsA'Humanoid' then
				return child
			end
		end
	else
		return nil
	end
end

Lib.GetCharacterFromPart = function(part)
	local current = part
	local character = nil
	local humanoid = nil
	local player = nil
	while true do
		for i, child in next, current:GetChildren() do
			if child:IsA'Humanoid' then
				character = current
				humanoid = child
				break
			end
		end
		if current:IsA'Player' then
			local GLib = require(script.Parent)
			character = current.Character
			humanoid = character and Lib.GetHumanoid(character)
			player = current
			break
		end

		if character then
			break
		else
			current = current.Parent

			if not current or current == game then
				break
			end
		end
	end

	return character, player or (character and Players:GetPlayerFromCharacter(character)), humanoid
end

Lib.GetCharacter = Lib.GetCharacterFromPart

Lib.GetPlayerFromPart = function(part)
	if not part then return nil end

	local player
	local current = part
	while true do
		player = Players:GetPlayerFromCharacter(current)
		if not player then
			current = current.Parent
			if not current or current == game then
				break
			end
		else
			break
		end
	end

	return player, player and player.Character
end

Lib.IsProtected = function(obj)
	local protected = false
	local check = obj
	while true do
		local hasFF = false
		for index, child in next, check:GetChildren() do
			if child:IsA'ForceField' then
				hasFF = true
				break
			end
		end
		if hasFF then
			protected = true
			break
		else
			check = check.Parent
			if check == nil or check == game or check.Parent == game then
				break
			end
		end
	end

	return protected
end

Lib.IsTeammate = function(a, b)
	if not a or not b then return nil end
	return a and b and a:IsA'Player' and b:IsA'Player' and a.Neutral==false and b.Neutral==false and a.TeamColor==b.TeamColor
end

Lib.TagHumanoid = function(player, humanoid, t)
	if humanoid == nil then return end
	if player == nil then return end
	if humanoid:IsA'Player' then player,humanoid = humanoid,player end

	if humanoid:FindFirstChild'creator' then
		humanoid.creator:Destroy()
	end

	local tag = Instance.new'ObjectValue'
	tag.Name = 'creator'
	tag.Value = player
	tag.Parent = humanoid

	Debris:AddItem(tag, t or 1)
end



local function remove(name)
	local info = cooldowns[name]
	if info then
		info.ShaderFrame:Destroy()
		info.ShadowImage:Destroy()
		cooldowns[name] = nil
	end
end

if not game:FindService'NetworkServer' then
	RenderStepped:connect(function()
		for name, info in next, cooldowns do
			local alpha = math.min((tick()-info.StartedAt)/info.Length, 1)
			info.ShaderFrame.Position = UDim2.new(0, 0, alpha, 0)
			info.ShaderFrame.Size = UDim2.new(1, 0, 1-alpha, 0)
			info.ShadowImage.Position = UDim2.new(0, 0, 0, -alpha*info.ShaderFrame.AbsoluteSize.x)
			if alpha == 1 then
				remove(name)
			end
		end
	end)
end

Lib.SetButtonCooldown = function(name, t)
	remove(name)

	if t and t > 0 then
		local button = CAS:GetButton(name)
		local info = {
			StartedAt = tick(),
			Length = t,
			ShaderFrame = GLib.Create'Frame'{
				Name = 'Shader',
				BackgroundTransparency = 1,
				Parent = button,
				Size = UDim2.new(1, 0, 1, 0),
				ClipsDescendants = true
			},
			ShadowImage = GLib.Create'ImageLabel'{
				Name = 'Image',
				BackgroundTransparency = 1,
				Image = button.Image,
				ImageRectSize = button.ImageRectSize,
				ImageRectOffset = button.ImageRectOffset,
				Size = button.Size,
				ZIndex = button.ZIndex+1
			},
			Button = button
		}
		info.ShadowImage.ImageColor3 = Color3.new(.5, .5, .5)
		info.ShadowImage.Parent = info.ShaderFrame

		cooldowns[name] = info
	end
end

-- Return
return Lib