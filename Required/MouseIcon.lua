--Fixed by SebasRomTen/"nikitass__" on discord

Mouse_Icon = "rbxasset://textures/GunCursor.png"
Reloading_Icon = "rbxasset://textures/GunWaitCursor.png"

Tool = script.Parent
Eq = nil
Mouse = nil

function UpdateIcon()
	if Mouse and Eq then
		Mouse.Icon = Tool.Enabled and Mouse_Icon or Reloading_Icon
	end
end

function OnEquipped(ToolMouse)
	Mouse = ToolMouse
	Eq = true
	UpdateIcon()
end

function OnChanged(Property)
	if Property == "Enabled" then
		UpdateIcon()
	end
end

Tool.Equipped:Connect(OnEquipped)
Tool.Unequipped:Connect(function() Eq = false end)
Tool.Changed:Connect(OnChanged)