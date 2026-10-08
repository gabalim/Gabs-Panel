local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local GuiService = game:GetService("GuiService")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera
local PlayerGui = LocalPlayer:WaitForChild("PlayerGui")

--------------------------------------------------------------------------------
-- CONFIGURATION & STATE
--------------------------------------------------------------------------------

local StickyAim_Enabled = false
local IgnoreDead_Enabled = true
local TeamCheck_Enabled = false
local VisualESP_Enabled = false

local FOV_Radius = 82
local Aim_Smoothness = 0.25
local LockTarget = nil

-- Color Theme (Neon Blue)
local UI_PrimaryColor = Color3.fromRGB(0, 170, 255)
local UI_BgColor = Color3.fromRGB(15, 20, 28)
local UI_CardColor = Color3.fromRGB(22, 30, 42)

--------------------------------------------------------------------------------
-- GUI SETUP
--------------------------------------------------------------------------------

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "GabsPanel_Mobile"
screenGui.ResetOnSpawn = false
screenGui.DisplayOrder = 999
screenGui.Parent = PlayerGui

-- Mobile Floating Toggle Button
local toggleBtn = Instance.new("TextButton")
toggleBtn.Name = "MobileToggleBtn"
toggleBtn.Size = UDim2.new(0, 48, 0, 48)
toggleBtn.Position = UDim2.new(0.02, 0, 0.25, 0)
toggleBtn.BackgroundColor3 = UI_BgColor
toggleBtn.Text = "GAB"
toggleBtn.TextColor3 = UI_PrimaryColor
toggleBtn.Font = Enum.Font.GothamBold
toggleBtn.TextSize = 14
toggleBtn.Active = true
toggleBtn.Draggable = true
toggleBtn.Parent = screenGui

local toggleCorner = Instance.new("UICorner")
toggleCorner.CornerRadius = UDim.new(1, 0)
toggleCorner.Parent = toggleBtn

local toggleStroke = Instance.new("UIStroke")
toggleStroke.Color = UI_PrimaryColor
toggleStroke.Thickness = 2
toggleStroke.Parent = toggleBtn

-- Main Frame
local mainFrame = Instance.new("Frame")
mainFrame.Name = "MainFrame"
mainFrame.Size = UDim2.new(0, 250, 0, 370)
mainFrame.Position = UDim2.new(0.5, -125, 0.35, -185)
mainFrame.BackgroundColor3 = UI_BgColor
mainFrame.BorderSizePixel = 0
mainFrame.Active = true
mainFrame.Draggable = true
mainFrame.Visible = true
mainFrame.Parent = screenGui

local mainCorner = Instance.new("UICorner")
mainCorner.CornerRadius = UDim.new(0, 10)
mainCorner.Parent = mainFrame

local mainStroke = Instance.new("UIStroke")
mainStroke.Color = UI_PrimaryColor
mainStroke.Thickness = 2
mainStroke.Parent = mainFrame

local title = Instance.new("TextLabel")
title.Size = UDim2.new(1, 0, 0, 38)
title.BackgroundTransparency = 1
title.Text = "Gab's Panel"
title.TextColor3 = UI_PrimaryColor
title.Font = Enum.Font.GothamBold
title.TextSize = 16
title.Parent = mainFrame

local container = Instance.new("Frame")
container.Size = UDim2.new(1, -20, 1, -48)
container.Position = UDim2.new(0, 10, 0, 40)
container.BackgroundTransparency = 1
container.Parent = mainFrame

local layout = Instance.new("UIListLayout")
layout.Padding = UDim.new(0, 6)
layout.SortOrder = Enum.SortOrder.LayoutOrder
layout.Parent = container

toggleBtn.MouseButton1Click:Connect(function()
	mainFrame.Visible = not mainFrame.Visible
end)

--------------------------------------------------------------------------------
-- UI COMPONENTS
--------------------------------------------------------------------------------

local function createToggle(text, defaultState, callback)
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 0, 34)
	btn.BackgroundColor3 = UI_CardColor
	btn.Text = "  " .. text
	btn.TextColor3 = Color3.fromRGB(230, 230, 230)
	btn.Font = Enum.Font.GothamSemibold
	btn.TextSize = 12
	btn.TextXAlignment = Enum.TextXAlignment.Left
	btn.Parent = container

	local btnCorner = Instance.new("UICorner")
	btnCorner.CornerRadius = UDim.new(0, 8)
	btnCorner.Parent = btn

	local stateLabel = Instance.new("TextLabel")
	stateLabel.Size = UDim2.new(0, 50, 1, 0)
	stateLabel.Position = UDim2.new(1, -55, 0, 0)
	stateLabel.BackgroundTransparency = 1
	stateLabel.Font = Enum.Font.GothamBold
	stateLabel.TextSize = 12
	stateLabel.Parent = btn

	local state = defaultState
	local function updateVisuals()
		stateLabel.Text = state and "ON" or "OFF"
		stateLabel.TextColor3 = state and UI_PrimaryColor or Color3.fromRGB(150, 150, 150)
		btn.BackgroundColor3 = state and Color3.fromRGB(28, 42, 60) or UI_CardColor
	end

	updateVisuals()
	btn.MouseButton1Click:Connect(function()
		state = not state
		updateVisuals()
		callback(state)
	end)
end

local function createSlider(titleText, minVal, maxVal, defaultVal, callback)
	local sliderContainer = Instance.new("Frame")
	sliderContainer.Size = UDim2.new(1, 0, 0, 44)
	sliderContainer.BackgroundColor3 = UI_CardColor
	sliderContainer.Parent = container

	local sliderCorner = Instance.new("UICorner")
	sliderCorner.CornerRadius = UDim.new(0, 8)
	sliderCorner.Parent = sliderContainer

	local sliderTitle = Instance.new("TextLabel")
	sliderTitle.Size = UDim2.new(1, -10, 0, 18)
	sliderTitle.Position = UDim2.new(0, 10, 0, 4)
	sliderTitle.BackgroundTransparency = 1
	sliderTitle.Text = titleText .. ": " .. tostring(defaultVal)
	sliderTitle.TextColor3 = Color3.fromRGB(230, 230, 230)
	sliderTitle.Font = Enum.Font.GothamSemibold
	sliderTitle.TextSize = 11
	sliderTitle.TextXAlignment = Enum.TextXAlignment.Left
	sliderTitle.Parent = sliderContainer

	local sliderBtn = Instance.new("TextButton")
	sliderBtn.Size = UDim2.new(1, -20, 0, 12)
	sliderBtn.Position = UDim2.new(0, 10, 0, 24)
	sliderBtn.BackgroundColor3 = Color3.fromRGB(10, 15, 22)
	sliderBtn.Text = ""
	sliderBtn.AutoButtonColor = false
	sliderBtn.Parent = sliderContainer

	local sliderBtnCorner = Instance.new("UICorner")
	sliderBtnCorner.CornerRadius = UDim.new(1, 0)
	sliderBtnCorner.Parent = sliderBtn

	local sliderFill = Instance.new("Frame")
	sliderFill.Size = UDim2.new((defaultVal - minVal) / (maxVal - minVal), 0, 1, 0)
	sliderFill.BackgroundColor3 = UI_PrimaryColor
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
		sliderTitle.Text = titleText .. ": " .. tostring(val)
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
FOVStroke.Color = UI_PrimaryColor
FOVStroke.Thickness = 2
FOVStroke.Parent = FOVFrame

--------------------------------------------------------------------------------
-- ALIVE CHECK & TARGET SELECTION
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
	if player:GetAttribute("IsDead") == true or player:GetAttribute("Dead") == true then
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
		if not LockTarget or not LockTarget.Character or not LockTarget.Character:FindFirstChild("Head") or (IgnoreDead_Enabled and not isPlayerAlive(LockTarget)) then
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
					FOVStroke.Color = Color3.fromRGB(0, 255, 120)
				else
					LockTarget = nil
					FOVStroke.Color = UI_PrimaryColor
				end
			else
				LockTarget = nil
				FOVStroke.Color = UI_PrimaryColor
			end
		else
			FOVStroke.Color = UI_PrimaryColor
		end
	end

	-- ESP Highlights (No Tracers)
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
					highlight.FillColor = alive and Color3.fromRGB(0, 255, 120) or Color3.fromRGB(120, 120, 120)
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
