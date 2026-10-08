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
local BehindWarning_Enabled = true

local FOV_Radius = 82
local Aim_Smoothness = 0.25
local Behind_Distance = 30
local LockTarget = nil

-- Theme Palette (Cyberpunk Landscape)
local UI_Accent = Color3.fromRGB(0, 230, 255)
local UI_AccentGlow = Color3.fromRGB(0, 150, 255)
local UI_WarningRed = Color3.fromRGB(255, 50, 80)
local UI_BgColor = Color3.fromRGB(11, 14, 22)
local UI_HeaderBg = Color3.fromRGB(15, 20, 32)
local UI_CardColor = Color3.fromRGB(18, 24, 38)
local UI_CardBorder = Color3.fromRGB(30, 42, 65)
local UI_ToggleOff = Color3.fromRGB(32, 42, 60)
local UI_TextPrimary = Color3.fromRGB(240, 246, 255)
local UI_TextSecondary = Color3.fromRGB(120, 140, 170)

--------------------------------------------------------------------------------
-- GUI SETUP
--------------------------------------------------------------------------------

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GabsPanel_Landscape"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999
screenGui.Parent = PlayerGui

-- Behind Warning Popup Box
local warningFrame = Instance.new("Frame")
warningFrame.Name = "WarningFrame"
warningFrame.Size = UDim2.new(0, 280, 0, 45)
warningFrame.Position = UDim2.new(0.5, -140, 0.12, 0)
warningFrame.BackgroundColor3 = Color3.fromRGB(25, 10, 15)
warningFrame.BorderSizePixel = 0
warningFrame.Visible = false
warningFrame.Parent = screenGui

local warningCorner = Instance.new("UICorner")
warningCorner.CornerRadius = UDim.new(0, 10)
warningCorner.Parent = warningFrame

local warningStroke = Instance.new("UIStroke")
warningStroke.Color = UI_WarningRed
warningStroke.Thickness = 2
warningStroke.Parent = warningFrame

local warningText = Instance.new("TextLabel")
warningText.Size = UDim2.new(1, -20, 1, 0)
warningText.Position = UDim2.new(0, 10, 0, 0)
warningText.BackgroundTransparency = 1
warningText.Text = "⚠️ ENEMY BEHIND YOU!"
warningText.TextColor3 = UI_WarningRed
warningText.Font = Enum.Font.GothamBold
warningText.TextSize = 12
warningText.Parent = warningFrame

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
mainFrame.Size = UDim2.new(0, 440, 0, 290)
mainFrame.Position = UDim2.new(0.5, -220, 0.5, -145)
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
-- UI COMPONENTS
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

local function checkEnemiesBehind()
	if not BehindWarning_Enabled or not LocalPlayer.Character or not LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
		return nil, 0
	end

	local myHRP = LocalPlayer.Character.HumanoidRootPart
	local myLookVector = myHRP.CFrame.LookVector

	local closestEnemy = nil
	local closestDist = Behind_Distance

	for _, player in ipairs(Players:GetPlayers()) do
		if player ~= LocalPlayer and isPlayerAlive(player) then
			if TeamCheck_Enabled and player.Team and player.Team == LocalPlayer.Team then
				continue
			end

			local enemyHRP = player.Character:FindFirstChild("HumanoidRootPart")
			if enemyHRP then
				local dirToEnemy = (enemyHRP.Position - myHRP.Position)
				local dist = dirToEnemy.Magnitude

				if dist <= Behind_Distance then
					local dotProduct = myLookVector:Dot(dirToEnemy.Unit)
					-- Dot product < -0.5 means the enemy is behind you in a 120-degree cone
					if dotProduct < -0.3 then
						if dist < closestDist then
							closestDist = dist
							closestEnemy = player
						end
					end
				end
			end
		end
	end

	return closestEnemy, math.floor(closestDist)
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

-- Left Column (Combat Settings)
createToggle("Sticky Aim", false, leftColumn, function(state)
	StickyAim_Enabled = state
	FOVFrame.Visible = state
	if not state then LockTarget = nil end
end)

createToggle("Wall Check", false, leftColumn, function(state)
	WallCheck_Enabled = state
	if state and LockTarget and LockTarget.Character and LockTarget.Character:FindFirstChild("Head") then
		if not isTargetVisible(LockTarget.Character.Head) then
			LockTarget = nil
		end
	end
end)

createSlider("FOV Radius", 40, 300, FOV_Radius, leftColumn, function(val)
	FOV_Radius = val
end)

createSlider("Aim Smoothness", 1, 100, math.floor(Aim_Smoothness * 100), leftColumn, function(val, rel)
	Aim_Smoothness = math.clamp(rel, 0.05, 1.0)
end)

-- Right Column (Alerts & Visuals)
createToggle("Behind Warning", true, rightColumn, function(state)
	BehindWarning_Enabled = state
	if not state then warningFrame.Visible = false end
end)

createSlider("Warning Range", 10, 60, Behind_Distance, rightColumn, function(val)
	Behind_Distance = val
end)

createToggle("Ignore Dead", true, rightColumn, function(state)
	IgnoreDead_Enabled = state
end)

createToggle("Team Check", false, rightColumn, function(state)
	TeamCheck_Enabled = state
end)

createToggle("Visual ESP", false, rightColumn, function(state)
	VisualESP_Enabled = state
end)

--------------------------------------------------------------------------------
-- MAIN LOOP
--------------------------------------------------------------------------------

RunService.RenderStepped:Connect(function(deltaTime)
	local centerScreen = getCenterScreenPos()
	FOVFrame.Size = UDim2.new(0, FOV_Radius * 2, 0, FOV_Radius * 2)
	FOVFrame.Position = UDim2.new(0, centerScreen.X, 0, centerScreen.Y)

	-- Behind Warning Check
	if BehindWarning_Enabled then
		local enemyBehind, distance = checkEnemiesBehind()
		if enemyBehind then
			warningText.Text = "⚠️ " .. enemyBehind.DisplayName:upper() .. " IS BEHIND YOU! (" .. distance .. "m)"
			warningFrame.Visible = true
		else
			warningFrame.Visible = false
		end
	else
		warningFrame.Visible = false
	end

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
