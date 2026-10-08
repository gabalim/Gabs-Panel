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

-- Cyberpunk Color Palette
local UI_Accent = Color3.fromRGB(0, 225, 255)
local UI_AccentGlow = Color3.fromRGB(0, 140, 255)
local UI_BgColor = Color3.fromRGB(10, 13, 20)
local UI_CardColor = Color3.fromRGB(16, 22, 34)
local UI_ToggleOff = Color3.fromRGB(28, 36, 52)
local UI_TextPrimary = Color3.fromRGB(240, 245, 255)
local UI_TextSecondary = Color3.fromRGB(110, 130, 160)

--------------------------------------------------------------------------------
-- GUI SETUP
--------------------------------------------------------------------------------

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GabsPanel_V2"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999
screenGui.Parent = PlayerGui

-- Sleek Floating Logo Button
local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "MobileToggleBtn"
toggleBtn.Size = UDim2.new(0, 50, 0, 50)
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
toggleStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
toggleStroke.Parent = toggleBtn

-- Main Cyberpunk Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 260, 0, 430)
mainFrame.Position = UDim2.new(0.5, -130, 0.3, -215)
mainFrame.BackgroundColor3 = UI_BgColor
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Visible = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 16)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = UI_Accent
mainStroke.Thickness = 1.5
mainStroke.Transparency = 0.2
mainStroke.Parent = mainFrame

-- Header
local header = Instance.new("Frame")
header.Size = UDim2.new(1, 0, 0, 48)
header.BackgroundTransparency = 1
header.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, -20, 1, 0)
title.Position = UDim2.new(0, 16, 0, 0)
title.BackgroundTransparency = 1
title.Text = "GAB'S PANEL"
title.TextColor3 = UI_Accent
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.TextXAlignment = Enum.TextXAlignment.Left
title.Parent = header

local versionTag = Instance.new("TextLabel")
versionTag.Size = UDim2.new(0, 50, 0, 18)
versionTag.Position = UDim2.new(1, -66, 0.5, -9)
versionTag.BackgroundColor3 = Color3.fromRGB(0, 50, 80)
versionTag.Text = "v2.0"
versionTag.TextColor3 = UI_Accent
versionTag.Font = Enum.Font.GothamBold
versionTag.TextSize = 10
versionTag.Parent = header

local tagCorner = Instance.new("UICorner")
tagCorner.CornerRadius = UDim.new(0, 6)
tagCorner.Parent = versionTag

local divider = Instance.new("Frame")
divider.Size = UDim2.new(1, -32, 0, 1)
divider.Position = UDim2.new(0, 16, 0, 48)
divider.BackgroundColor3 = Color3.fromRGB(30, 42, 62)
divider.BorderSizePixel = 0
divider.Parent = mainFrame

local container = Instance.new("Frame")
container.Size = UDim2.new(1, -24, 1, -64)
container.Position = UDim2.new(0, 12, 0, 56)
container.BackgroundTransparency = 1
container.Parent = mainFrame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 8)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = container

toggleBtn.MouseButton1Click:Connect(function()
	mainFrame.Visible = not mainFrame.Visible
end)

--------------------------------------------------------------------------------
-- UI COMPONENTS (SMOOTH ANIMATED TOGGLES & SLIDERS)
--------------------------------------------------------------------------------

local function createToggle(text, defaultState, callback)
	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, 0, 0, 38)
	card.BackgroundColor3 = UI_CardColor
	card.Parent = container

	local cardCorner = Instance.new("UICorner")
	cardCorner.CornerRadius = UDim.new(0, 10)
	cardCorner.Parent = card

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, -60, 1, 0)
	label.Position = UDim2.new(0, 12, 0, 0)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextColor3 = UI_TextPrimary
	label.Font = Enum.Font.GothamSemibold
	label.TextSize = 12
	label.TextXAlignment = Enum.TextXAlignment.Left
	label.Parent = card

	local switchBg = Instance.new("TextButton")
	switchBg.Size = UDim2.new(0, 38, 0, 20)
	switchBg.Position = UDim2.new(1, -48, 0.5, -10)
	switchBg.BackgroundColor3 = defaultState and UI_Accent or UI_ToggleOff
	switchBg.Text = ""
	switchBg.AutoButtonColor = false
	switchBg.Parent = card

	local switchCorner = Instance.new("UICorner")
	switchCorner.CornerRadius = UDim.new(1, 0)
	switchCorner.Parent = switchBg

	local switchDot = Instance.new("Frame")
	switchDot.Size = UDim2.new(0, 14, 0, 14)
	switchDot.Position = defaultState and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)
	switchDot.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
	switchDot.Parent = switchBg

	local dotCorner = Instance.new("UICorner")
	dotCorner.CornerRadius = UDim.new(1, 0)
	dotCorner.Parent = switchDot

	local state = defaultState
	switchBg.MouseButton1Click:Connect(function()
		state = not state
		local targetBg = state and UI_Accent or UI_ToggleOff
		local targetDotPos = state and UDim2.new(1, -17, 0.5, -7) or UDim2.new(0, 3, 0.5, -7)

		TweenService:Create(switchBg, TweenInfo.new(0.2), {BackgroundColor3 = targetBg}):Play()
		TweenService:Create(switchDot, TweenInfo.new(0.2), {Position = targetDotPos}):Play()
		callback(state)
	end)
end

local function createSlider(titleText, minVal, maxVal, defaultVal, callback)
	local card = Instance.new("Frame")
	card.Size = UDim2.new(1, 0, 0, 46)
	card.BackgroundColor3 = UI_CardColor
	card.Parent = container

	local cardCorner = Instance.new("UICorner")
	cardCorner.CornerRadius = UDim.new(0, 10)
	cardCorner.Parent = card

	local sliderTitle = Instance.new("TextLabel")
	sliderTitle.Size = UDim2.new(1, -24, 0, 18)
	sliderTitle.Position = UDim2.new(0, 12, 0, 4)
	sliderTitle.BackgroundTransparency = 1
	sliderTitle.Text = titleText .. "  "
	sliderTitle.TextColor3 = UI_TextSecondary
	sliderTitle.Font = Enum.Font.GothamSemibold
	sliderTitle.TextSize = 11
	sliderTitle.TextXAlignment = Enum.TextXAlignment.Left
	sliderTitle.Parent = card

	local valLabel = Instance.new("TextLabel")
	valLabel.Size = UDim2.new(0, 50, 0, 18)
	valLabel.Position = UDim2.new(1, -62, 0, 4)
	valLabel.BackgroundTransparency = 1
	valLabel.Text = tostring(defaultVal)
	valLabel.TextColor3 = UI_Accent
	valLabel.Font = Enum.Font.GothamBold
	valLabel.TextSize = 11
	valLabel.TextXAlignment = Enum.TextXAlignment.Right
	valLabel.Parent = card

	local sliderBtn = Instance.new("TextButton")
	sliderBtn.Size = UDim2.new(1, -24, 0, 8)
	sliderBtn.Position = UDim2.new(0, 12, 0, 28)
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
-- CHECKS & HELPER FUNCTIONS
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

				if dist <= shortestDistance then
					shortestDistance = dist
					closestPlayer = player
				end
			end
		end
	end
	return closestPlayer
end

--------------------------------------------------------------------------------
-- REGISTER CONTROLS
--------------------------------------------------------------------------------

createToggle("Sticky Aim", false, function(state)
	StickyAim_Enabled = state
	FOVFrame.Visible = state
	if not state then LockTarget = nil end
end)

createToggle("Wall Check", false, function(state)
	WallCheck_Enabled = state
	if state and LockTarget and LockTarget.Character and LockTarget.Character:FindFirstChild("Head") then
		if not isTargetVisible(LockTarget.Character.Head) then
			LockTarget = nil
		end
	end
end)

createToggle("Ignore Dead", true, function(state)
	IgnoreDead_Enabled = state
end)

createToggle("Team Check", false, function(state)
	TeamCheck_Enabled = state
end)

createToggle("Visual ESP", false, function(state)
	VisualESP_Enabled = state
end)

createSlider("FOV Radius", 40, 300, FOV_Radius, function(val)
	FOV_Radius = val
end)

createSlider("Aim Smoothness", 1, 100, math.floor(Aim_Smoothness * 100), function(val, rel)
	Aim_Smoothness = math.clamp(rel, 0.05, 1.0)
end)

--------------------------------------------------------------------------------
-- MAIN EXECUTION LOOP
--------------------------------------------------------------------------------

RunService.RenderStepped:Connect(function(deltaTime)
	-- Sync FOV Ring Position
	local centerScreen = getCenterScreenPos()
	FOVFrame.Size = UDim2.new(0, FOV_Radius * 2, 0, FOV_Radius * 2)
	FOVFrame.Position = UDim2.new(0, centerScreen.X, 0, centerScreen.Y)

	-- Sticky Aim Execution
	if StickyAim_Enabled then
		if not LockTarget or not LockTarget.Character or not LockTarget.Character:FindFirstChild("Head") 
		   or (IgnoreDead_Enabled and not isPlayerAlive(LockTarget)) 
		   or (WallCheck_Enabled and not isTargetVisible(LockTarget.Character.Head)) then
			LockTarget = getClosestTarget()
		end

		if LockTarget and LockTarget.Character and LockTarget.Character:FindFirstChild("Head") then
			local headPos = LockTarget.Character.Head.Position
			local screenPos, onScreen = Camera:WorldToViewportPoint(headPos)

			if onScreen and screenPos.Z > 0 then
				local distFromCenter = (Vector2.new(screenPos.X, screenPos.Y) - Vector2.new(Camera.ViewportSize.X/2, Camera.ViewportSize.Y/2)).Magnitude

				if distFromCenter <= FOV_Radius then
					local currentCFrame = Camera.CFrame
					local targetCFrame = CFrame.lookAt(currentCFrame.Position, headPos)
					local lerpAlpha = math.clamp(deltaTime * (Aim_Smoothness * 20), 0, 1)
					
					Camera.CFrame = currentCFrame:Lerp(targetCFrame, lerpAlpha)
					FOVStroke.Color = Color3.fromRGB(0, 255, 150)
				else
					LockTarget = nil
					FOVStroke.Color = UI_Accent
				end
			else
				LockTarget = nil
				FOVStroke.Color = UI_Accent
			end
		else
			FOVStroke.Color = UI_Accent
		end
	end

	-- ESP Highlights
	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer then
			if VisualESP_Enabled and player.Character and player.Character:FindFirstChild("HumanoidRootPart") then
				local isSameTeam = TeamCheck_Enabled and player.Team and player.Team == LocalPlayer.Team
				local alive = isPlayerAlive(player)

				if not isSameTeam and (not IgnoreDead_Enabled or alive) then
					local highlight = player.Character:FindFirstChild("ESPHighlight")
					if not highlight then
						highlight = Instance.new("Highlight")
						highlight.Name = "ESPHighlight"
						highlight.FillTransparency = 0.5
						highlight.OutlineTransparency = 0
						highlight.Parent = player.Character
					end

					highlight.Enabled = true
					highlight.FillColor = alive and Color3.fromRGB(0, 225, 255) or Color3.fromRGB(100, 115, 130)
				else
					if player.Character:FindFirstChild("ESPHighlight") then
						player.Character.ESPHighlight.Enabled = false
					end
				end
			else
				if player.Character and player.Character:FindFirstChild("ESPHighlight") then
					player.Character.ESPHighlight.Enabled = false
				end
			end
		end
	end
end)
