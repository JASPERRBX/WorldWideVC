local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local lp = Players.LocalPlayer
local mouse = lp:GetMouse()

local uiName = "JasperNexus_V6_Fixed"
for _, v in pairs(CoreGui:GetChildren()) do
	if v.Name == uiName then v:Destroy() end
end

local gui = Instance.new("ScreenGui")
gui.Name = uiName
gui.ResetOnSpawn = false
gui.Parent = CoreGui
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local clickSound = Instance.new("Sound")
clickSound.SoundId = "rbxassetid://9119713951"
clickSound.Volume = 0.5
clickSound.Parent = gui

local function playClick()
	local s = clickSound:Clone()
	s.Parent = gui
	s:Play()
	game.Debris:AddItem(s, 1)
end

local HashLib = require(ReplicatedStorage:WaitForChild("BoothSystem"):WaitForChild("Packages"):WaitForChild("HashLib"))
local RemotesParent = ReplicatedStorage.BoothSystem.Modules.Remotes
local DataKey = game.JobId

local function GetEncryptedRemote(name)
	local hash = HashLib.sha1(name .. DataKey)
	local bin = HashLib.hex_to_bin(hash)
	local b64 = HashLib.bin_to_base64(bin)
	return RemotesParent:WaitForChild(b64, 5)
end

local loader = Instance.new("Frame")
loader.Name = "Loader"
loader.Size = UDim2.new(1, 0, 1, 0)
loader.BackgroundColor3 = Color3.fromRGB(10, 10, 12)
loader.ZIndex = 100
loader.Parent = gui

local lGrad = Instance.new("UIGradient")
lGrad.Color = ColorSequence.new{
	ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 15, 20)),
	ColorSequenceKeypoint.new(1, Color3.fromRGB(5, 5, 8))
}
lGrad.Rotation = -45
lGrad.Parent = loader

local keyContainer = Instance.new("Frame")
keyContainer.Name = "KeyFrame"
keyContainer.Size = UDim2.new(0, 420, 0, 260)
keyContainer.AnchorPoint = Vector2.new(0.5, 0.5)
keyContainer.Position = UDim2.new(0.5, 0, 0.5, 0)
keyContainer.BackgroundColor3 = Color3.fromRGB(25, 25, 30)
keyContainer.BorderSizePixel = 0
keyContainer.ZIndex = 101
keyContainer.Parent = loader

Instance.new("UICorner", keyContainer).CornerRadius = UDim.new(0, 12)
local kStroke = Instance.new("UIStroke")
kStroke.Color = Color3.fromRGB(60, 60, 100)
kStroke.Thickness = 2
kStroke.Parent = keyContainer

local keyTitle = Instance.new("TextLabel")
keyTitle.Size = UDim2.new(1, 0, 0, 60)
keyTitle.Position = UDim2.new(0, 0, 0.05, 0)
keyTitle.BackgroundTransparency = 1
keyTitle.Text = "SECURITY GATEWAY"
keyTitle.Font = Enum.Font.GothamBlack
keyTitle.TextSize = 26
keyTitle.TextColor3 = Color3.fromRGB(110, 160, 255)
keyTitle.ZIndex = 102
keyTitle.Parent = keyContainer

local keyBox = Instance.new("TextBox")
keyBox.Size = UDim2.new(0.8, 0, 0, 55)
keyBox.Position = UDim2.new(0.5, 0, 0.4, 0)
keyBox.AnchorPoint = Vector2.new(0.5, 0.5)
keyBox.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
keyBox.Text = ""
keyBox.PlaceholderText = "Enter Key..."
keyBox.TextColor3 = Color3.fromRGB(255, 255, 255)
keyBox.PlaceholderColor3 = Color3.fromRGB(100, 100, 100)
keyBox.Font = Enum.Font.GothamBold
keyBox.TextSize = 18
keyBox.ZIndex = 102
keyBox.Parent = keyContainer
Instance.new("UICorner", keyBox).CornerRadius = UDim.new(0, 8)

local submitBtn = Instance.new("TextButton")
submitBtn.Size = UDim2.new(0.5, 0, 0, 45)
submitBtn.Position = UDim2.new(0.5, 0, 0.75, 0)
submitBtn.AnchorPoint = Vector2.new(0.5, 0.5)
submitBtn.BackgroundColor3 = Color3.fromRGB(60, 90, 200)
submitBtn.Text = "ACCESS"
submitBtn.Font = Enum.Font.GothamBlack
submitBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
submitBtn.TextSize = 16
submitBtn.ZIndex = 102
submitBtn.Parent = keyContainer
Instance.new("UICorner", submitBtn).CornerRadius = UDim.new(0, 8)

local function LoadMain()
	local tInfo = TweenInfo.new(0.6, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	TweenService:Create(loader, tInfo, {BackgroundTransparency = 1}):Play()
	TweenService:Create(keyContainer, tInfo, {Position = UDim2.new(0.5, 0, 1.5, 0)}):Play()
	
	task.wait(0.6)
	loader:Destroy()
	
	local main = Instance.new("Frame")
	main.Name = "MainFrame"
	main.Size = UDim2.new(0, 0, 0, 0) 
	main.Position = UDim2.new(0.5, 0, 0.5, 0)
	main.BackgroundColor3 = Color3.fromRGB(18, 18, 22)
	main.BorderSizePixel = 0
	main.ClipsDescendants = true
	main.AnchorPoint = Vector2.new(0.5, 0.5)
	main.Parent = gui

	local mGrad = Instance.new("UIGradient")
	mGrad.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 30)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 20))
	}
	mGrad.Rotation = 45
	mGrad.Parent = main
	
	TweenService:Create(main, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Size = UDim2.new(0, 650, 0, 420)}):Play()
	
	local mStroke = Instance.new("UIStroke")
	mStroke.Color = Color3.fromRGB(70, 70, 100)
	mStroke.Thickness = 1.5
	mStroke.Parent = main
	Instance.new("UICorner", main).CornerRadius = UDim.new(0, 12)

	local sidebar = Instance.new("Frame")
	sidebar.Size = UDim2.new(0, 170, 1, 0)
	sidebar.BackgroundColor3 = Color3.fromRGB(22, 22, 28)
	sidebar.BorderSizePixel = 0
	sidebar.Parent = main
	Instance.new("UICorner", sidebar).CornerRadius = UDim.new(0, 12)
	
	local title = Instance.new("TextLabel")
	title.Text = "JASPER"
	title.Font = Enum.Font.GothamBlack
	title.TextSize = 26
	title.TextColor3 = Color3.fromRGB(120, 160, 255)
	title.Size = UDim2.new(1, 0, 0, 60)
	title.BackgroundTransparency = 1
	title.Parent = sidebar
	
	local dragging, dragStart, startPos
	main.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = main.Position
		end
	end)
	main.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
			local delta = input.Position - dragStart
			main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
		end
	end)
	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging = false end
	end)

	local container = Instance.new("Frame")
	container.Size = UDim2.new(1, -180, 1, -20)
	container.Position = UDim2.new(0, 180, 0, 10)
	container.BackgroundTransparency = 1
	container.Parent = main
	
	local tabs = {}
	local currentTab = nil

	local function switchTab(page)
		playClick()
		if currentTab then currentTab.Visible = false end
		page.Visible = true
		currentTab = page
	end

	local function createTab(name)
		local page = Instance.new("ScrollingFrame")
		page.Size = UDim2.new(1, 0, 1, 0)
		page.BackgroundTransparency = 1
		page.Visible = false
		page.ScrollBarThickness = 2
		page.BorderSizePixel = 0
		page.Parent = container
		
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(0.85, 0, 0, 38)
		btn.Position = UDim2.new(0.075, 0, 0, 70 + (#tabs * 44))
		btn.BackgroundColor3 = Color3.fromRGB(30, 30, 36)
		btn.Text = name
		btn.Font = Enum.Font.GothamBold
		btn.TextColor3 = Color3.fromRGB(150, 150, 160)
		btn.TextSize = 13
		btn.AutoButtonColor = false
		btn.Parent = sidebar
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 8)
		
		btn.MouseButton1Click:Connect(function()
			for _, b in pairs(sidebar:GetChildren()) do
				if b:IsA("TextButton") then
					TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(30, 30, 36), TextColor3 = Color3.fromRGB(150, 150, 160)}):Play()
				end
			end
			TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(50, 60, 100), TextColor3 = Color3.fromRGB(255, 255, 255)}):Play()
			switchTab(page)
		end)
		
		local layout = Instance.new("UIListLayout", page)
		layout.Padding = UDim.new(0, 10)
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		
		page.CanvasSize = UDim2.new(0, 0, 0, 0)
		layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			page.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
		end)
		
		table.insert(tabs, page)
		return page
	end

	local function createBtn(parent, text, col, cb)
		local b = Instance.new("TextButton")
		b.Size = UDim2.new(0.98, 0, 0, 45)
		b.BackgroundColor3 = col
		b.Text = text
		b.Font = Enum.Font.GothamBold
		b.TextColor3 = Color3.new(1,1,1)
		b.TextSize = 14
		b.Parent = parent
		Instance.new("UICorner", b).CornerRadius = UDim.new(0, 8)
		b.MouseButton1Click:Connect(function()
			playClick()
			cb(b)
		end)
		return b
	end
	
	local pageMain = createTab("Main")
	local pageBooth = createTab("Booth")
	local pageDev = createTab("Devices")
	local pageDraw = createTab("Drawing")
	local pageFarm = createTab("Farming")
	local pagePass = createTab("Gamepass")
	local pageLag = createTab("Lag Server")
	
	if #tabs > 0 then switchTab(tabs[1]) end
	
	local function scanRemote()
		for _, v in pairs(workspace:GetDescendants()) do if v.Name == "PushRequest" and v:IsA("RemoteEvent") then return v end end
		for _, v in pairs(ReplicatedStorage:GetDescendants()) do if v.Name == "PushRequest" and v:IsA("RemoteEvent") then return v end end
		return nil
	end

	createBtn(pageMain, "GET FREE PUSH", Color3.fromRGB(0, 110, 200), function(b)
		local r = scanRemote()
		if r then
			local t = Instance.new("Tool")
			t.Name = "Push Ability"
			t.RequiresHandle = false
			t.Parent = lp.Backpack
			t.Activated:Connect(function() r:FireServer() end)
			b.Text = "TOOL GIVEN"
			task.wait(1)
			b.Text = "GET FREE PUSH"
		else
			b.Text = "REMOTE MISSING"
			task.wait(1)
			b.Text = "GET FREE PUSH"
		end
	end)
	
	local rainbowBooth = false
	createBtn(pageBooth, "Rainbow Text: OFF", Color3.fromRGB(80, 50, 120), function(b)
		rainbowBooth = not rainbowBooth
		b.Text = rainbowBooth and "Rainbow Text: ON" or "Rainbow Text: OFF"
		if rainbowBooth then
			task.spawn(function()
				local evt = GetEncryptedRemote("ChangeTextColorEvent")
				if not evt then return end
				while rainbowBooth do
					local t = tick() * 0.5
					local col = Color3.fromHSV(t%1, 1, 1)
					local hex = string.format("#%02X%02X%02X", math.floor(col.R*255), math.floor(col.G*255), math.floor(col.B*255))
					evt:FireServer(hex)
					task.wait(0.2)
				end
			end)
		end
	end)
	
	local randFont = false
	local fontList = {"SourceSans", "Gotham", "GothamBlack", "AmaticSC", "Jura", "Oswald", "Code"}
	createBtn(pageBooth, "Random Font: OFF", Color3.fromRGB(80, 50, 120), function(b)
		randFont = not randFont
		b.Text = randFont and "Random Font: ON" or "Random Font: OFF"
		if randFont then
			task.spawn(function()
				local evt = GetEncryptedRemote("ChangeTextFontEvent")
				if not evt then return end
				while randFont do
					local f = fontList[math.random(1, #fontList)]
					evt:FireServer(f)
					task.wait(0.5)
				end
			end)
		end
	end)
	
	createBtn(pageBooth, "Give Booth To Random", Color3.fromRGB(200, 100, 50), function(b)
		local evt = GetEncryptedRemote("TransferBooth1")
		if evt then
			local plrs = Players:GetPlayers()
			local target = plrs[math.random(1, #plrs)]
			if target == lp then target = plrs[math.random(1, #plrs)] end
			if target then
				evt:FireServer(target)
				b.Text = "Sent to: " .. target.Name
				task.wait(1)
				b.Text = "Give Booth To Random"
			end
		end
	end)
	
	local crashRef = false
	createBtn(pageBooth, "CRASH: BOOTH REFRESH LOOP", Color3.fromRGB(180, 40, 40), function(b)
		crashRef = not crashRef
		b.Text = crashRef and "CRASHING (STOP)" or "CRASH: BOOTH REFRESH LOOP"
		if crashRef then
			task.spawn(function()
				local evt = GetEncryptedRemote("RefreshEvent")
				if not evt then return end
				while crashRef do
					evt:FireServer(true)
					task.wait()
				end
			end)
		end
	end)

	local devs = {"Phone", "Computer", "Console"}
	for _, d in ipairs(devs) do
		createBtn(pageDev, "Set: "..d, Color3.fromRGB(50, 55, 65), function()
			pcall(function() ReplicatedStorage["uxrOverheadSystem#RS@4.1"].overheadEvents.RemoteEvent:FireServer("LoadDeviceNametag", d) end)
		end)
	end

	local drawColor = Color3.new(1,1,1)
	local drawShape = "Circle"
	local isRainbow = false
	local isDrawing = false
	local chalkEvent = ReplicatedStorage:WaitForChild("GameCore"):WaitForChild("Remotes"):WaitForChild("ChalkEvent")

	local palette = Instance.new("Frame", pageDraw)
	palette.Size = UDim2.new(1, 0, 0, 80)
	palette.BackgroundTransparency = 1
	local pGrid = Instance.new("UIGridLayout", palette)
	pGrid.CellSize = UDim2.new(0, 40, 0, 40)
	
	local colors = {Color3.new(1,1,1), Color3.new(0,0,0), Color3.new(1,0,0), Color3.new(0,1,0), Color3.new(0,0,1), Color3.new(1,1,0), Color3.new(0,1,1), Color3.new(1,0,1)}
	for _, c in ipairs(colors) do
		local b = Instance.new("TextButton", palette)
		b.Text = ""
		b.BackgroundColor3 = c
		Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
		b.MouseButton1Click:Connect(function() drawColor = c playClick() end)
	end
	
	local shapeFrame = Instance.new("Frame", pageDraw)
	shapeFrame.Size = UDim2.new(1, 0, 0, 35)
	shapeFrame.BackgroundTransparency = 1
	local sl = Instance.new("UIListLayout", shapeFrame)
	sl.FillDirection = Enum.FillDirection.Horizontal
	sl.Padding = UDim.new(0, 5)
	
	local function sBtn(n)
		local b = Instance.new("TextButton", shapeFrame)
		b.Size = UDim2.new(0.3, 0, 1, 0)
		b.BackgroundColor3 = Color3.fromRGB(40,40,50)
		b.Text = n
		b.TextColor3 = Color3.new(1,1,1)
		b.Font = Enum.Font.Gotham
		Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
		b.MouseButton1Click:Connect(function() drawShape = n playClick() end)
	end
	sBtn("Circle")
	sBtn("Square")
	sBtn("Dot")
	
	createBtn(pageDraw, "Rainbow Mode: OFF", Color3.fromRGB(80, 50, 120), function(b)
		isRainbow = not isRainbow
		b.Text = isRainbow and "Rainbow Mode: ON" or "Rainbow Mode: OFF"
	end)
	
	createBtn(pageDraw, "ENABLE DRAWING (HOLD CLICK)", Color3.fromRGB(150, 50, 50), function(b)
		isDrawing = not isDrawing
		b.BackgroundColor3 = isDrawing and Color3.fromRGB(50, 150, 80) or Color3.fromRGB(150, 50, 50)
	end)
	
	local function getGroundPos(startPos)
		local params = RaycastParams.new()
		params.FilterDescendantsInstances = {lp.Character, workspace:FindFirstChild("Art")}
		params.FilterType = Enum.RaycastFilterType.Exclude
		local res = workspace:Raycast(startPos + Vector3.new(0, 5, 0), Vector3.new(0, -20, 0), params)
		if res then return res.Position + Vector3.new(0, 0.1, 0), res.Normal end
		return nil, nil
	end
	
	task.spawn(function()
		while true do
			if isDrawing and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
				local char = lp.Character
				if char then
					local batch = {}
					local center = mouse.Hit.Position
					local col = isRainbow and Color3.fromHSV(tick()%1, 1, 1) or drawColor
					
					if drawShape == "Circle" then
						for i = 1, 20 do
							local ang = (i/20) * math.pi * 2
							local raw = center + Vector3.new(math.cos(ang)*4, 0, math.sin(ang)*4)
							local pos, norm = getGroundPos(raw)
							if pos then
								table.insert(batch, {cframe = CFrame.lookAt(pos, pos+norm)*CFrame.Angles(0, math.rad(90), 0), color = col})
							end
						end
					elseif drawShape == "Square" then
						local s = 4
						local pts = {Vector3.new(s,0,s), Vector3.new(-s,0,s), Vector3.new(s,0,-s), Vector3.new(-s,0,-s)}
						for _, p in ipairs(pts) do
							local pos, norm = getGroundPos(center+p)
							if pos then
								table.insert(batch, {cframe = CFrame.lookAt(pos, pos+norm)*CFrame.Angles(0, math.rad(90), 0), color = col})
							end
						end
					else
						local pos, norm = getGroundPos(center)
						if pos then
							table.insert(batch, {cframe = CFrame.lookAt(pos, pos+norm)*CFrame.Angles(0, math.rad(90), 0), color = col})
						end
					end
					
					if #batch > 0 then pcall(function() chalkEvent:FireServer(batch) end) end
				end
			end
			task.wait(0.1)
		end
	end)
	
	local farming = false
	createBtn(pageFarm, "Toggle Fishing", Color3.fromRGB(100, 150, 50), function(b)
		farming = not farming
		b.Text = farming and "FARMING: ON" or "FARMING: OFF"
		if farming then
			task.spawn(function()
				while farming do
					if lp.Character and lp.Character:FindFirstChild("ServerSide Fishing Rod") then
						pcall(function() ReplicatedStorage.Fishing_System.Remotes.SendPosition:FireServer(mouse.Hit.Position) end)
					end
					task.wait(0.2)
				end
			end)
		end
	end)
	
	local function pass(n) if lp:FindFirstChild("PassStates") then lp.PassStates[n].Value = true end end
	createBtn(pagePass, "Unlock Gravity", Color3.fromRGB(70, 70, 90), function() pass("CanChangeGravity") end)
	createBtn(pagePass, "Unlock Speed", Color3.fromRGB(70, 70, 90), function() pass("CanChangeSpeed") end)
	createBtn(pagePass, "Unlock Size", Color3.fromRGB(70, 70, 90), function() pass("CanChangeSize") end)

	createBtn(pageLag, "LAG: MONEY GUN", Color3.fromRGB(180, 50, 50), function()
		local g = lp.Backpack:FindFirstChild("Superme Money Gun") or lp.Character:FindFirstChild("Superme Money Gun")
		if g then for i=1,30 do g.RemoteEvent:FireServer() end end
	end)
	
	createBtn(pageLag, "LAG: PUSH SPAM", Color3.fromRGB(180, 50, 50), function()
		local r = scanRemote()
		if r then for i=1,50 do r:FireServer() end end
	end)
end

submitBtn.MouseButton1Click:Connect(function()
	if keyBox.Text == "JASPERISTHEBEST" then
		playClick()
		submitBtn.Text = "AUTHORIZED"
		submitBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 100)
		task.wait(0.5)
		LoadMain()
	else
		submitBtn.Text = "INVALID KEY"
		submitBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
		task.wait(1)
		submitBtn.Text = "ACCESS"
		submitBtn.BackgroundColor3 = Color3.fromRGB(60, 90, 200)
	end
end)
