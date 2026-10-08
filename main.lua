local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--------------------------------------------------------------------------------
-- CONFIGURATION & STATE
--------------------------------------------------------------------------------

local StickyAim_Enabled = false
local WallCheck_Enabled = false
local IgnoreDead_Enabled = true
local TeamCheck_Enabled = false
local VisualESP_Enabled = false

local FOV_Radius = 82
local Aim_Smoothness = 0.25
local LockTarget = nil

-- Theme Palette (Cyberpunk Landscape)
local UI_Accent = Color3.fromRGB(0, 230, 255)
local UI_AccentGlow = Color3.fromRGB(0, 150, 255)
local UI_BgColor = Color3.fromRGB(11, 14, 22)
local UI_HeaderBg = Color3.fromRGB(15, 20, 32)
local UI_CardColor = Color3.fromRGB(18, 24, 38)
local UI_CardBorder = Color3.fromRGB(30, 42, 65)
local UI_ToggleOff = Color3.fromRGB(32, 42, 60)
local UI_TextPrimary = Color3.fromRGB(240, 246, 255)
local UI_TextSecondary = Color3.fromRGB(120, 140, 170)

--------------------------------------------------------------------------------
-- GUI SETUP (LANDSCAPE DESIGN)
--------------------------------------------------------------------------------

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GabsPanel_Landscape"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999
screenGui.Parent = PlayerGui

-- Floating Mobile Button
local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "MobileToggleBtn"
toggleBtn.Size = UDim2.new(0, 52, 0, 52)
toggleBtn.Position = UDim2.new(0.02, 0, 0.2, 0)
toggleBtn.BackgroundColor3 = UI_BgColor
toggleBtn.Text = "GAB"
toggleBtn.TextColor3 = UI_Accent
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 14
toggleBtn.Active = true
toggleBtn.Draggable = true
toggleBtn.Parent = screenGui

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(0, 14)
toggleCorner.Parent = toggleBtn

local toggleStroke = Instance.new("UIStroke")
toggleStroke.Color = UI_Accent
toggleStroke.Thickness = 2
toggleStroke.Parent = toggleBtn

-- Main Frame (Wide Landscape Aspect)
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 440, 0, 260)
mainFrame.Position = UDim2.new(0.5, -220, 0.5, -130)
mainFrame.BackgroundColor3 = UI_BgColor
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Visible = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 14)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = UI_Accent
mainStroke.Thickness = 1.5
mainStroke.Transparency = 0.2
mainStroke.Parent = mainFrame

-- Header Bar
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 42)
header.BackgroundColor3 = UI_HeaderBg
header.BorderSizePixel = 0
header.Parent = mainFrame

local headerCorner = Instance.new("UICorner")
headerCorner.CornerRadius = UDim.new(0, 14)
headerCorner.Parent = header

-- Header Flat Bottom Fix
local headerFix = Instance.new("Frame")
headerFix.Size = UDim2.new(1, 0, 0, 10)
headerFix.Position = UDim2.new(0, 0, 1, -10)
headerFix.BackgroundColor3 = UI_HeaderBg
headerFix.BorderSizePixel = 0
headerFix.Parent = header

local title = Instance.new("TextLabel")
title.Size = UDim2.new(0, 180, 1, 0)
title.Position = UDim2.new(0, 16, 0, 0)
title.BackgroundTransparency = 1
title.Text = "GAB'S PANEL"
title.TextColor3 = UI_Accent
title.Font = Enum.Font.GothamBold
title.TextSize = 15
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local statusIndicator = Instance.new("Frame")
statusIndicator.Size = UDim2.new(0, 8, 0, 8)
statusIndicator.Position = UDim2.new(1, -78, 0.5, -4)
statusIndicator.BackgroundColor3 = Color3.fromRGB(0, 255, 140)
statusIndicator.Parent = header

local statusCorner = Instance.new("UICorner")
statusCorner.CornerRadius = UDim.new(1, 0)
statusCorner.Parent = statusIndicator

local statusText = Instance.new("TextLabel")
statusText.Size = UDim2.new(0, 60, 1, 0)
statusText.Position = UDim2.new(1, -66, 0, 0)
statusText.BackgroundTransparency = 1
statusText.Text = "ACTIVE"
statusText.TextColor3 = UI_TextSecondary
statusText.Font = Enum.Font.GothamBold
statusText.TextSize = 10
statusText.TextXAlignment = Enum.TextXAlignment.Left
statusText.Parent = header

local headerDivider = Instance.new("Frame")
headerDivider.Size = UDim2.new(1, 0, 0, 1)
headerDivider.Position = UDim2.new(0, 0, 1, -1)
headerDivider.BackgroundColor3 = UI_CardBorder
headerDivider.BorderSizePixel = 0
headerDivider.Parent = header

-- Dual Column Content Container
local leftColumn = Instance.new("Frame")
leftColumn.Size = UDim2.new(0.5, -16, 1, -54)
leftColumn.Position = UDim2.new(0, 12, 0, 48)
leftColumn.BackgroundTransparency = 1
leftColumn.Parent = mainFrame

local leftLayout = Instance.new("UIListLayout")
leftLayout.Padding = UDim.new(0, 6)
leftLayout.SortOrder = Enum.SortOrder.LayoutOrder
leftLayout.Parent = leftColumn

local rightColumn = Instance.new("Frame")
rightColumn.Size = UDim2.new(0.5, -16, 1, -54)
rightColumn.Position = UDim2.new(0.5, 4, 0, 48)
rightColumn.BackgroundTransparency = 1
rightColumn.Parent = mainFrame

local rightLayout = Instance.new("UIListLayout")
rightLayout.Padding = UDim.new(0, 6)
rightLayout.SortOrder = Enum.SortOrder.LayoutOrder
rightLayout.Parent = rightColumn

toggleBtn.MouseButton1Click:Connect(function()
	mainFrame.Visible = not mainFrame.Visible
end)

--------------------------------------------------------------------------------
-- UI COMPONENTS (LANDSCAPE DESIGN)
--------------------------------------------------------------------------------

local function createToggle(text, defaultState, parentColumn, callback)
	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, 0, 0, 34)
	card.BackgroundColor3 = UI_CardColor
	card.Parent = parentColumn

	local cardCorner = Instance.new("UICorner")
	cardCorner.CornerRadius = UDim.new(0, 8)
	cardCorner.Parent = card

	local cardStroke = Instance.new("UIStroke")
	cardStroke.Color = UI_CardBorder
	cardStroke.Thickness = 1
	cardStroke.Parent = card

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -50, 1, 0)
	label.Position = UDim2.new(0, 10, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = UI_TextPrimary
	label.Font = Enum.Font.GothamSemibold
	label.TextSize = 11
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = card

	local switchBg = Instance.new("TextButton")
	switchBg.Size = UDim2.new(0, 32, 0, 16)
	switchBg.Position = UDim2.new(1, -40, 0.5, -8)
	switchBg.BackgroundColor3 = defaultState and UI_Accent or UI_ToggleOff
	switchBg.Text = ""
	switchBg.AutoButtonColor = false
	switchBg.Parent = card

	local switchCorner = Instance.new("UICorner")
	switchCorner.CornerRadius = UDim.new(1, 0)
	switchCorner.Parent = switchBg

	local switchDot = Instance.new("Frame")
	switchDot.Size = UDim2.new(0, 12, 0, 12)
	switchDot.Position = defaultState and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
	switchDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	switchDot.Parent = switchBg

	local dotCorner = Instance.new("UICorner")
	dotCorner.CornerRadius = UDim.new(1, 0)
	dotCorner.Parent = switchDot

	local state = defaultState
	switchBg.MouseButton1Click:Connect(function()
		state = not state
		local targetBg = state and UI_Accent or UI_ToggleOff
		local targetDotPos = state and UDim2.new(1, -14, 0.5, -6) or UDim2.new(0, 2, 0.5, -6)
		local targetBorder = state and UI_Accent or UI_CardBorder

		TweenService:Create(switchBg, TweenInfo.new(0.2), {BackgroundColor3 = targetBg}):Play()
		TweenService:Create(switchDot, TweenInfo.new(0.2), {Position = targetDotPos}):Play()
		TweenService:Create(cardStroke, TweenInfo.new(0.2), {Color = targetBorder}):Play()
		callback(state)
	end)
end

local function createSlider(titleText, minVal, maxVal, defaultVal, parentColumn, callback)
	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, 0, 0, 42)
	card.BackgroundColor3 = UI_CardColor
	card.Parent = parentColumn

	local cardCorner = Instance.new("UICorner")
	cardCorner.CornerRadius = UDim.new(0, 8)
	cardCorner.Parent = card

	local cardStroke = Instance.new("UIStroke")
	cardStroke.Color = UI_CardBorder
	cardStroke.Thickness = 1
	cardStroke.Parent = card

	local sliderTitle = Instance.new("TextLabel")
	sliderTitle.Size = UDim2.new(1, -20, 0, 16)
	sliderTitle.Position = UDim2.new(0, 10, 0, 4)
	sliderTitle.BackgroundTransparency = 1
	sliderTitle.Text = titleText
	sliderTitle.TextColor3 = UI_TextSecondary
	sliderTitle.Font = Enum.Font.GothamSemibold
	sliderTitle.TextSize = 10
	sliderTitle.TextXAlignment = Enum.TextXAlignment.Left
	sliderTitle.Parent = card

	local valLabel = Instance.new("TextLabel")
	valLabel.Size = UDim2.new(0, 50, 0, 16)
	valLabel.Position = UDim2.new(1, -60, 0, 4)
	valLabel.BackgroundTransparency = 1
	valLabel.Text = tostring(defaultVal)
	valLabel.TextColor3 = UI_Accent
	valLabel.Font = Enum.Font.GothamBold
	valLabel.TextSize = 10
	valLabel.TextXAlignment = Enum.TextXAlignment.Right
	valLabel.Parent = card

	local sliderBtn = Instance.new("TextButton")
	sliderBtn.Size = UDim2.new(1, -20, 0, 6)
	sliderBtn.Position = UDim2.new(0, 10, 0, 26)
	sliderBtn.BackgroundColor3 = UI_ToggleOff
	sliderBtn.Text = ""
	sliderBtn.AutoButtonColor = false
	sliderBtn.Parent = card

	local sliderBtnCorner = Instance.new("UICorner")
	sliderBtnCorner.CornerRadius = UDim.new(1, 0)
	sliderBtnCorner.Parent = sliderBtn

	local sliderFill = Instance.new("Frame")
	sliderFill.Size = UDim2.new((defaultVal - minVal) / (maxVal - minVal), 0, 1, 0)
	sliderFill.BackgroundColor3 = UI_Accent
	sliderFill.BorderSizePixel = 0
	sliderFill.Parent = sliderBtn

	local sliderFillCorner = Instance.new("UICorner")
	sliderFillCorner.CornerRadius = UDim.new(1, 0)
	sliderFillCorner.Parent = sliderFill

	local dragging = false
	local function update(input)
		local pos = input.Position.X
		local barPos = sliderBtn.AbsolutePosition.X
		local barWidth = sliderBtn.AbsoluteSize.X
		local rel = math.clamp((pos - barPos) / barWidth, 0, 1)
		local val = math.floor(minVal + (rel * (maxVal - minVal)))
		
		sliderFill.Size = UDim2.new(rel, 0, 1, 0)
		valLabel.Text = tostring(val)
		callback(val, rel)
	end

	sliderBtn.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			update(input)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			update(input)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
end

--------------------------------------------------------------------------------
-- FOV CIRCLE
--------------------------------------------------------------------------------

local FOVFrame = Instance.new("Frame")
FOVFrame.AnchorPoint = Vector2.new(0.5, 0.5)
FOVFrame.Size = UDim2.new(0, FOV_Radius * 2, 0, FOV_Radius * 2)
FOVFrame.BackgroundTransparency = 1
FOVFrame.Visible = false
FOVFrame.Parent = screenGui

local FOVCorner = Instance.new("UICorner")
FOVCorner.CornerRadius = UDim.new(1, 0)
FOVCorner.Parent = FOVFrame

local FOVStroke = Instance.new("UIStroke")
FOVStroke.Color = UI_Accent
FOVStroke.Thickness = 1.5
FOVStroke.Parent = FOVFrame

--------------------------------------------------------------------------------
-- HELPER FUNCTIONS
--------------------------------------------------------------------------------

local function isPlayerAlive(player)
	if not player or not player.Character then return false end
	local char = player.Character
	
	if not char:IsDescendantOf(workspace) or char.Parent.Name == "Ragdolls" or char.Parent.Name == "Dead" then
		return false
	end

	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if not humanoid or humanoid.Health <= 0 or humanoid:GetState() == Enum.HumanoidStateType.Dead then
		return false
	end

	local head = char:FindFirstChild("Head")
	local hrp = char:FindFirstChild("HumanoidRootPart")
	if not head or not hrp then return false end

	local neck = head:FindFirstChild("Neck") or char:FindFirstChild("Neck", true)
	if neck and not neck.Enabled then
		return false
	end

	if char:GetAttribute("IsDead") == true or char:GetAttribute("Dead") == true or char:GetAttribute("Downed") == true then
		return false
	end

	return true
end

local function isTargetVisible(targetHead)
	if not WallCheck_Enabled then return true end

	local rayParams = RaycastParams.new()
	rayParams.FilterType = Enum.RaycastFilterType.Exclude
	
	local ignoreList = {Camera}
	if LocalPlayer.Character then
		table.insert(ignoreList, LocalPlayer.Character)
	end
	
	rayParams.FilterDescendantsInstances = ignoreList
	rayParams.IgnoreWater = true

	local origin = Camera.CFrame.Position
	local direction = targetHead.Position - origin
	local raycastResult = workspace:Raycast(origin, direction, rayParams)

	if raycastResult then
		if raycastResult.Instance:IsDescendantOf(targetHead.Parent) then
			return true
		end
		return false
	end

	return true
end

local function getCenterScreenPos()
	local viewportSize = Camera.ViewportSize
	local inset = GuiService:GetGuiInset()
	return Vector2.new(viewportSize.X / 2, (viewportSize.Y / 2) - inset.Y)
end

local function getClosestTarget()
	local closestPlayer = nil
	local shortestDistance = FOV_Radius
	local centerPos = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild("Head") then
			if IgnoreDead_Enabled and not isPlayerAlive(player) then
				continue
			end

			if TeamCheck_Enabled and player.Team and player.Team == LocalPlayer.Team then
				continue
			end

			local head = player.Character.Head

			if not isTargetVisible(head) then
				continue
			end

			local screenPos, onScreen = Camera:WorldToViewportPoint(head.Position)

			if onScreen and screenPos.Z > 0 then
				local targetVector = Vector2.new(screenPos.X, screenPos.Y)
				local dist = (targetVector - centerPos).Magnitude

				if dist <= shortest
