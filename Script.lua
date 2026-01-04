local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local lp = Players.LocalPlayer
local mouse = lp:GetMouse()
local cam = workspace.CurrentCamera
local startTime = tick()

--// CONFIG //--
local uiName = "JasperNexus" -- Строго фиксированное название
local DataKey = game.JobId

--// CLEANUP //--
for _, v in pairs(CoreGui:GetChildren()) do
	if v.Name == uiName then v:Destroy() end
end

--// THEME SYSTEM //--
local themes = {
	["Jasper Dark"] = {
		Main = Color3.fromRGB(18, 18, 24),
		Secondary = Color3.fromRGB(25, 25, 35),
		Accent = Color3.fromRGB(90, 140, 255),
		Text = Color3.fromRGB(240, 240, 240),
		TextDim = Color3.fromRGB(160, 160, 170)
	},
	["Toxic Green"] = {
		Main = Color3.fromRGB(10, 15, 10),
		Secondary = Color3.fromRGB(15, 25, 15),
		Accent = Color3.fromRGB(50, 255, 100),
		Text = Color3.fromRGB(220, 255, 220),
		TextDim = Color3.fromRGB(100, 160, 100)
	},
	["Blood Red"] = {
		Main = Color3.fromRGB(20, 10, 10),
		Secondary = Color3.fromRGB(30, 15, 15),
		Accent = Color3.fromRGB(255, 60, 60),
		Text = Color3.fromRGB(255, 230, 230),
		TextDim = Color3.fromRGB(180, 120, 120)
	}
}
local currentTheme = themes["Jasper Dark"]

--// UI ELEMENTS STORAGE (FOR THEME UPDATE) //--
local uiElements = {
	frames = {},
	texts = {},
	buttons = {},
	strokes = {}
}

local gui = Instance.new("ScreenGui")
gui.Name = uiName
gui.Parent = CoreGui
gui.IgnoreGuiInset = true
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

--// UTILS //--
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

-- Плавное и исправленное перетаскивание
local function MakeDraggable(frame)
	local dragging = false
	local dragInput
	local dragStart
	local startPos

	local function update(input)
		local delta = input.Position - dragStart
		frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
	end

	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			dragging = true
			dragStart = input.Position
			startPos = frame.Position
			
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragging = false
				end
			end)
		end
	end)

	frame.InputChanged:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			dragInput = input
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if input == dragInput and dragging then
			update(input)
		end
	end)
end

local function UpdateTheme(themeName)
	currentTheme = themes[themeName]
	for _, v in pairs(uiElements.frames) do v.BackgroundColor3 = v.Name == "Main" and currentTheme.Main or currentTheme.Secondary end
	for _, v in pairs(uiElements.texts) do v.TextColor3 = v.Name == "Dim" and currentTheme.TextDim or (v.Name == "Accent" and currentTheme.Accent or currentTheme.Text) end
	for _, v in pairs(uiElements.strokes) do v.Color = currentTheme.Accent end
	-- Кнопки обновляются при наведении, базовый цвет берется из Secondary
end

--// ENCRYPTION //--
local HashLib = require(ReplicatedStorage:WaitForChild("BoothSystem"):WaitForChild("Packages"):WaitForChild("HashLib"))
local RemotesParent = ReplicatedStorage.BoothSystem.Modules.Remotes
local function GetEncryptedRemote(name)
	local hash = HashLib.sha1(name .. DataKey)
	local bin = HashLib.hex_to_bin(hash)
	local b64 = HashLib.bin_to_base64(bin)
	local r = RemotesParent:WaitForChild(b64, 3)
	if not r then warn("Nexus: Remote not found - "..name) end
	return r
end

--// SCANNER (Fixed) //--
local function scanRemote(name)
	local r = ReplicatedStorage:FindFirstChild(name, true) or workspace:FindFirstChild(name, true)
	if r and r:IsA("RemoteEvent") then return r end
	return nil
end

--// MAIN GUI LOAD //--
local function LoadMain()
	local main = Instance.new("Frame")
	main.Name = "Main"
	main.Size = UDim2.new(0, 700, 0, 450)
	main.Position = UDim2.new(0.5, 0, 0.5, 0)
	main.AnchorPoint = Vector2.new(0.5, 0.5)
	main.BackgroundColor3 = currentTheme.Main
	main.BorderSizePixel = 0
	main.ClipsDescendants = true
	main.Parent = gui
	table.insert(uiElements.frames, main)
	
	MakeDraggable(main)
	
	-- Анимация появления
	main.Size = UDim2.new(0, 100, 0, 100)
	TweenService:Create(main, TweenInfo.new(0.5, Enum.EasingStyle.Back), {Size = UDim2.new(0, 700, 0, 450)}):Play()

	local uic = Instance.new("UICorner", main)
	uic.CornerRadius = UDim.new(0, 10)
	local uis = Instance.new("UIStroke", main)
	uis.Color = currentTheme.Accent
	uis.Thickness = 2
	uis.Transparency = 0.5
	table.insert(uiElements.strokes, uis)

	local sidebar = Instance.new("Frame")
	sidebar.Name = "Sidebar"
	sidebar.Size = UDim2.new(0, 190, 1, 0)
	sidebar.BackgroundColor3 = currentTheme.Secondary
	sidebar.BorderSizePixel = 0
	sidebar.Parent = main
	table.insert(uiElements.frames, sidebar)
	
	local title = Instance.new("TextLabel")
	title.Name = "Accent"
	title.Text = "JASPER"
	title.Font = Enum.Font.GothamBlack
	title.TextSize = 30
	title.TextColor3 = currentTheme.Accent
	title.Size = UDim2.new(1, 0, 0, 50)
	title.Position = UDim2.new(0,0,0,10)
	title.BackgroundTransparency = 1
	title.Parent = sidebar
	table.insert(uiElements.texts, title)
	
	local subTitle = Instance.new("TextLabel")
	subTitle.Name = "Dim"
	subTitle.Text = "NEXUS V9"
	subTitle.Font = Enum.Font.GothamBold
	subTitle.TextSize = 14
	subTitle.TextColor3 = currentTheme.TextDim
	subTitle.Size = UDim2.new(1, 0, 0, 20)
	subTitle.Position = UDim2.new(0,0,0,45)
	subTitle.BackgroundTransparency = 1
	subTitle.Parent = sidebar
	table.insert(uiElements.texts, subTitle)
	
	local sessionTime = Instance.new("TextLabel")
	sessionTime.Name = "Dim"
	sessionTime.Size = UDim2.new(1, 0, 0, 30)
	sessionTime.Position = UDim2.new(0, 0, 1, -40)
	sessionTime.BackgroundTransparency = 1
	sessionTime.Font = Enum.Font.Code
	sessionTime.TextColor3 = currentTheme.TextDim
	sessionTime.TextSize = 12
	sessionTime.Parent = sidebar
	table.insert(uiElements.texts, sessionTime)

	task.spawn(function()
		while gui.Parent do
			local t = tick() - startTime
			sessionTime.Text = string.format("%02d:%02d:%02d", math.floor(t/3600), math.floor(t/60)%60, t%60)
			task.wait(1)
		end
	end)

	local container = Instance.new("Frame")
	container.Name = "Container"
	container.Size = UDim2.new(1, -200, 1, -20)
	container.Position = UDim2.new(0, 200, 0, 10)
	container.BackgroundTransparency = 1
	container.Parent = main

	local tabs = {}
	local currentTab = nil

	local function SwitchTab(tab)
		playClick()
		if currentTab then currentTab.Visible = false end
		tab.Visible = true
		currentTab = tab
	end

	local function CreateTab(name)
		local page = Instance.new("ScrollingFrame")
		page.Size = UDim2.new(1, 0, 1, 0)
		page.BackgroundTransparency = 1
		page.Visible = false
		page.ScrollBarThickness = 2
		page.BorderSizePixel = 0
		page.Parent = container
		
		local layout = Instance.new("UIListLayout", page)
		layout.Padding = UDim.new(0, 8)
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		
		page.CanvasSize = UDim2.new(0,0,0,0)
		layout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			page.CanvasSize = UDim2.new(0,0,0,layout.AbsoluteContentSize.Y + 20)
		end)
		
		local btn = Instance.new("TextButton")
		btn.Name = "TabBtn"
		btn.Size = UDim2.new(0.9, 0, 0, 35)
		btn.Position = UDim2.new(0.05, 0, 0, 90 + (#tabs * 40))
		btn.BackgroundColor3 = currentTheme.Main
		btn.Text = name
		btn.Font = Enum.Font.GothamBold
		btn.TextColor3 = currentTheme.TextDim
		btn.TextSize = 12
		btn.AutoButtonColor = false
		btn.Parent = sidebar
		Instance.new("UICorner", btn).CornerRadius = UDim.new(0, 6)
		table.insert(uiElements.frames, btn)
		
		btn.MouseButton1Click:Connect(function()
			for _, v in pairs(sidebar:GetChildren()) do
				if v.Name == "TabBtn" then
					TweenService:Create(v, TweenInfo.new(0.2), {BackgroundColor3 = currentTheme.Main, TextColor3 = currentTheme.TextDim}):Play()
				end
			end
			TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = currentTheme.Accent, TextColor3 = Color3.new(1,1,1)}):Play()
			SwitchTab(page)
		end)
		
		table.insert(tabs, page)
		return page
	end
	
	local function CreateBtn(parent, text, cb)
		local b = Instance.new("TextButton")
		b.Size = UDim2.new(0.98, 0, 0, 40)
		b.BackgroundColor3 = currentTheme.Secondary
		b.Text = text
		b.Font = Enum.Font.GothamBold
		b.TextColor3 = currentTheme.Text
		b.TextSize = 13
		b.Parent = parent
		b.AutoButtonColor = false
		
		Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
		local s = Instance.new("UIStroke", b)
		s.Color = currentTheme.Accent
		s.Transparency = 0.7
		s.Thickness = 1
		table.insert(uiElements.strokes, s)
		
		b.MouseButton1Click:Connect(function() playClick(); cb(b) end)
		b.MouseEnter:Connect(function() TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = currentTheme.Accent, TextColor3 = Color3.new(1,1,1)}):Play() end)
		b.MouseLeave:Connect(function() TweenService:Create(b, TweenInfo.new(0.2), {BackgroundColor3 = currentTheme.Secondary, TextColor3 = currentTheme.Text}):Play() end)
		
		return b
	end
	
	local function CreateInput(parent, ph, def)
		local b = Instance.new("TextBox")
		b.Size = UDim2.new(0.98, 0, 0, 35)
		b.BackgroundColor3 = currentTheme.Main
		b.Text = def
		b.PlaceholderText = ph
		b.Font = Enum.Font.GothamBold
		b.TextColor3 = currentTheme.Text
		b.PlaceholderColor3 = currentTheme.TextDim
		b.TextSize = 13
		b.Parent = parent
		
		Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
		local s = Instance.new("UIStroke", b)
		s.Color = currentTheme.Accent
		s.Transparency = 0.5
		table.insert(uiElements.strokes, s)
		
		return b
	end
	
	--// TABS SETUP //--
	local pMain = CreateTab("MAIN")
	local pDraw = CreateTab("DRAWING")
	local pBooth = CreateTab("BOOTH")
	local pDev = CreateTab("DEVICES")
	local pLag = CreateTab("LAG SERVER")
	local pSet = CreateTab("THEMES")
	
	SwitchTab(pMain)
	
	--// MAIN TAB //--
	CreateBtn(pMain, "LOAD INFINITY YIELD", function() loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))() end)
	CreateBtn(pMain, "LOAD DEX EXPLORER", function() loadstring(game:HttpGet("https://raw.githubusercontent.com/infyiff/backup/main/dex.lua"))() end)
	
	CreateBtn(pMain, "GET FREE PUSH (FIXED)", function(b)
		b.Text = "SCANNING..."
		local r = scanRemote("PushRequest")
		if r then
			local t = Instance.new("Tool")
			t.Name = "Push Ability"
			t.RequiresHandle = false
			t.Parent = lp.Backpack
			t.Activated:Connect(function() r:FireServer() end)
			b.Text = "SUCCESS! CHECK BACKPACK"
			task.wait(1.5)
			b.Text = "GET FREE PUSH (FIXED)"
		else
			b.Text = "REMOTE NOT FOUND"
			task.wait(1.5)
			b.Text = "GET FREE PUSH (FIXED)"
		end
	end)
	
	local cflySpeedInput = CreateInput(pMain, "CFrame Fly Speed", "50")
	local cfLoop = nil
	CreateBtn(pMain, "TOGGLE CFRAME FLY", function(b)
		if cfLoop then
			cfLoop:Disconnect()
			cfLoop = nil
			if lp.Character and lp.Character:FindFirstChild("Humanoid") then lp.Character.Humanoid.PlatformStand = false end
			if lp.Character and lp.Character:FindFirstChild("Head") then lp.Character.Head.Anchored = false end
			b.Text = "TOGGLE CFRAME FLY (OFF)"
		else
			if not lp.Character then return end
			b.Text = "TOGGLE CFRAME FLY (ON)"
			local hum = lp.Character:FindFirstChild("Humanoid")
			local head = lp.Character:FindFirstChild("Head")
			if hum then hum.PlatformStand = true end
			if head then head.Anchored = true end
			
			cfLoop = RunService.Heartbeat:Connect(function(dt)
				local spd = tonumber(cflySpeedInput.Text) or 50
				local move = hum.MoveDirection * (spd * dt)
				local camCF = cam.CFrame
				local headCF = head.CFrame
				local offset = headCF:ToObjectSpace(camCF).Position
				camCF = camCF * CFrame.new(-offset.X, -offset.Y, -offset.Z + 1)
				local objVel = CFrame.new(camCF.Position, Vector3.new(headCF.Position.X, camCF.Position.Y, headCF.Position.Z)):VectorToObjectSpace(move)
				head.CFrame = CFrame.new(headCF.Position) * (camCF - camCF.Position) * CFrame.new(objVel)
			end)
		end
	end)
	
	--// BOOTH TAB (RESTORED) //--
	local rainbowBooth = false
	local colorSpeed = CreateInput(pBooth, "Rainbow Speed (0.2)", "0.2")
	CreateBtn(pBooth, "RAINBOW TEXT TOGGLE", function(b)
		rainbowBooth = not rainbowBooth
		b.Text = rainbowBooth and "RAINBOW TEXT: ON" or "RAINBOW TEXT: OFF"
		if rainbowBooth then
			task.spawn(function()
				local evt = GetEncryptedRemote("ChangeTextColorEvent")
				while rainbowBooth do
					if not evt then break end
					local spd = tonumber(colorSpeed.Text) or 0.2
					local c = Color3.fromHSV(tick()*(1/spd)*0.1%1, 1, 1)
					local hex = string.format("#%02X%02X%02X", c.R*255, c.G*255, c.B*255)
					pcall(function() evt:FireServer(hex) end)
					task.wait(spd)
				end
			end)
		end
	end)
	
	local randFont = false
	CreateBtn(pBooth, "RANDOM FONT TOGGLE", function(b)
		randFont = not randFont
		b.Text = randFont and "RANDOM FONT: ON" or "RANDOM FONT: OFF"
		if randFont then
			task.spawn(function()
				local evt = GetEncryptedRemote("ChangeTextFontEvent")
				local fonts = {"SourceSans", "Gotham", "AmaticSC", "Jura", "Oswald", "Code", "SourceSansBold"}
				while randFont do
					if not evt then break end
					pcall(function() evt:FireServer(fonts[math.random(1, #fonts)]) end)
					task.wait(0.5)
				end
			end)
		end
	end)
	
	CreateBtn(pBooth, "TRANSFER BOOTH (RANDOM)", function(b)
		local evt = GetEncryptedRemote("TransferBooth1")
		local plrs = Players:GetPlayers()
		if #plrs < 2 then return end
		local t = plrs[math.random(1, #plrs)]
		while t == lp do t = plrs[math.random(1, #plrs)] end
		if evt then
			evt:FireServer(t)
			b.Text = "SENT TO: "..t.Name
			task.wait(1)
			b.Text = "TRANSFER BOOTH (RANDOM)"
		end
	end)
	
	local crashLoop = false
	CreateBtn(pBooth, "CRASH SERVER (REFRESH LOOP)", function(b)
		crashLoop = not crashLoop
		b.Text = crashLoop and "CRASHING..." or "CRASH SERVER (REFRESH LOOP)"
		if crashLoop then
			task.spawn(function()
				local evt = GetEncryptedRemote("RefreshEvent")
				while crashLoop do
					if not evt then break end
					evt:FireServer(true)
					task.wait()
				end
			end)
		end
	end)
	
	--// DEVICES TAB //--
	local devs = {"Phone", "Computer", "Console"}
	for _, d in ipairs(devs) do
		CreateBtn(pDev, "SET DEVICE TAG: "..d, function()
			local system = ReplicatedStorage:FindFirstChild("uxrOverheadSystem#RS@4.1")
			if system then System.overheadEvents.RemoteEvent:FireServer("LoadDeviceNametag", d) end
		end)
	end
	
	--// DRAWING TAB (CORRECTED LOGIC) //--
	local drawColor = Color3.new(1,1,1)
	local drawShape = "Dot"
	local isRainbowDraw = false
	local isDrawing = false
	local chalkEvent = ReplicatedStorage:WaitForChild("GameCore"):WaitForChild("Remotes"):WaitForChild("ChalkEvent")
	
	-- Palette
	local palette = Instance.new("Frame", pDraw)
	palette.Size = UDim2.new(0.98, 0, 0, 80)
	palette.BackgroundTransparency = 1
	local pGrid = Instance.new("UIGridLayout", palette)
	pGrid.CellSize = UDim2.new(0, 35, 0, 35)
	pGrid.CellPadding = UDim2.new(0, 5, 0, 5)
	
	local colors = {Color3.new(1,1,1), Color3.new(0,0,0), Color3.new(1,0,0), Color3.new(0,1,0), Color3.new(0,0,1), Color3.new(1,1,0), Color3.new(1,0,1), Color3.fromRGB(255,100,0)}
	for _, c in ipairs(colors) do
		local b = Instance.new("TextButton", palette)
		b.Text = ""
		b.BackgroundColor3 = c
		Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
		b.MouseButton1Click:Connect(function() drawColor = c playClick() end)
	end
	
	-- Shapes
	local shapeFrame = Instance.new("Frame", pDraw)
	shapeFrame.Size = UDim2.new(0.98, 0, 0, 30)
	shapeFrame.BackgroundTransparency = 1
	local sl = Instance.new("UIListLayout", shapeFrame)
	sl.FillDirection = Enum.FillDirection.Horizontal
	sl.Padding = UDim.new(0, 5)
	
	local function makeShapeBtn(n)
		local b = Instance.new("TextButton", shapeFrame)
		b.Size = UDim2.new(0.23, 0, 1, 0)
		b.BackgroundColor3 = currentTheme.Main
		b.TextColor3 = currentTheme.Text
		b.Text = n
		b.Font = Enum.Font.Gotham
		b.TextSize = 11
		Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
		local st = Instance.new("UIStroke", b)
		st.Color = currentTheme.Accent
		table.insert(uiElements.strokes, st)
		b.MouseButton1Click:Connect(function() drawShape = n playClick() end)
	end
	makeShapeBtn("Dot"); makeShapeBtn("Circle"); makeShapeBtn("Square")
	
	CreateBtn(pDraw, "RAINBOW DRAW: OFF", function(b)
		isRainbowDraw = not isRainbowDraw
		b.Text = isRainbowDraw and "RAINBOW DRAW: ON" or "RAINBOW DRAW: OFF"
	end)
	
	CreateBtn(pDraw, "ENABLE MOUSE DRAW (ALL SURFACES)", function(b)
		isDrawing = not isDrawing
		b.BackgroundColor3 = isDrawing and currentTheme.Accent or currentTheme.Secondary
	end)
	
	local textIn = CreateInput(pDraw, "Text to Draw", "JASPER")
	local sizeIn = CreateInput(pDraw, "Size (1-5)", "2")
	
	-- Helper Drawing Functions
	local function safeDraw(batch)
		local MAX = 1800
		if #batch <= MAX then pcall(function() chalkEvent:FireServer(batch) end)
		else task.spawn(function() for i = 1, #batch, MAX do local sub = {} for j = i, math.min(i+MAX-1, #batch) do table.insert(sub, batch[j]) end pcall(function() chalkEvent:FireServer(sub) end) task.wait(0.05) end end) end
	end
	
	-- Вспомогательная функция Raycast (для всех поверхностей при рисовании мышью)
	local function getSurfacePos(origin, dir)
		local params = RaycastParams.new()
		params.FilterDescendantsInstances = {lp.Character, workspace:FindFirstChild("Art")}
		params.FilterType = Enum.RaycastFilterType.Exclude
		local res = workspace:Raycast(origin, dir*20, params)
		if res then return res.Position + (res.Normal*0.05), res.Normal end
		return nil, nil
	end

	-- Функция Raycast ТОЛЬКО ВНИЗ (для текста)
	local function getGroundPos(startPos)
		local params = RaycastParams.new()
		params.FilterDescendantsInstances = {lp.Character, workspace:FindFirstChild("Art")}
		params.FilterType = Enum.RaycastFilterType.Exclude
		local res = workspace:Raycast(startPos + Vector3.new(0, 5, 0), Vector3.new(0, -20, 0), params)
		if res then return res.Position + Vector3.new(0, 0.1, 0), res.Normal end
		return nil, nil
	end
	
	-- Интерполяция ЛИНИИ НА ЗЕМЛЕ
	local function interpolateGroundLine(Batch, p1_rel, p2_rel, frame, col, sz)
		local spacing = 0.15 * sz
		local dist = (p1_rel - p2_rel).Magnitude
		local segs = math.max(1, math.ceil(dist/spacing))
		for i=0, segs do
			local t = i/segs
			local rel = p1_rel:Lerp(p2_rel, t)
			local worldRaw = frame * rel -- Проекция координат на CFrame игрока
			local pos, n = getGroundPos(worldRaw) -- Стреляем ТОЛЬКО ВНИЗ
			if pos then
				table.insert(Batch, {cframe = CFrame.lookAt(pos, pos+n)*CFrame.Angles(0, math.rad(90), 0), color = col})
			end
		end
	end
	
	local function P(x, z) return {x, z} end
	local FONT_LINES = {} 
	FONT_LINES['A']={{P(0,0),P(1,4)},{P(1,4),P(2,0)},{P(0.4,1.6),P(1.6,1.6)}}
	FONT_LINES['B']={{P(0,0),P(0,4)},{P(0,4),P(1.5,3.5)},{P(1.5,3.5),P(0,2)},{P(0,2),P(1.8,1.5)},{P(1.8,1.5),P(0,0)}}
	FONT_LINES['C']={{P(2,3.5),P(1,4)},{P(1,4),P(0.2,3)},{P(0.2,3),P(0.2,1)},{P(0.2,1),P(1,0)},{P(1,0),P(2,0.5)}}
	FONT_LINES['D']={{P(0,0),P(0,4)},{P(0,4),P(1,4)},{P(1,4),P(2,2)},{P(2,2),P(1,0)},{P(1,0),P(0,0)}}
	FONT_LINES['E']={{P(0,0),P(0,4)},{P(0,4),P(2,4)},{P(0,2),P(1.5,2)},{P(0,0),P(2,0)}}
	FONT_LINES['F']={{P(0,0),P(0,4)},{P(0,4),P(2,4)},{P(0,2),P(1.5,2)}}
	FONT_LINES['G']={{P(2,3),P(1,4)},{P(1,4),P(0.2,3)},{P(0.2,3),P(0.2,1)},{P(0.2,1),P(1,0)},{P(1,0),P(2,0)},{P(2,0),P(2,2)},{P(2,2),P(1.2,2)}}
	FONT_LINES['H']={{P(0,0),P(0,4)},{P(2,0),P(2,4)},{P(0,2),P(2,2)}}
	FONT_LINES['I']={{P(1,0),P(1,4)},{P(0,0),P(2,0)},{P(0,4),P(2,4)}}
	FONT_LINES['J']={{P(0,1),P(1,0)},{P(1,0),P(1.8,0.5)},{P(1.8,0.5),P(1.8,4)}}
	FONT_LINES['K']={{P(0,0),P(0,4)},{P(0,2),P(2,4)},{P(0,2),P(2,0)}}
	FONT_LINES['L']={{P(0,4),P(0,0)},{P(0,0),P(2,0)}}
	FONT_LINES['M']={{P(0,0),P(0,4)},{P(0,4),P(1.2,2)},{P(1.2,2),P(2.4,4)},{P(2.4,4),P(2.4,0)}}
	FONT_LINES['N']={{P(0,0),P(0,4)},{P(0,4),P(2,0)},{P(2,0),P(2,4)}}
	FONT_LINES['O']={{P(1,4),P(0.2,3)},{P(0.2,3),P(0.2,1)},{P(0.2,1),P(1,0)},{P(1,0),P(1.8,1)},{P(1.8,1),P(1.8,3)},{P(1.8,3),P(1,4)}}
	FONT_LINES['P']={{P(0,0),P(0,4)},{P(0,4),P(1.5,4)},{P(1.5,4),P(2,3)},{P(2,3),P(1.5,2)},{P(1.5,2),P(0,2)}}
	FONT_LINES['Q']={{P(1,4),P(0.2,3)},{P(0.2,3),P(0.2,1)},{P(0.2,1),P(1,0)},{P(1,0),P(1.8,1)},{P(1.8,1),P(1.8,3)},{P(1.8,3),P(1,4)},{P(1.2,1),P(2,0)}}
	FONT_LINES['R']={{P(0,0),P(0,4)},{P(0,4),P(1.5,4)},{P(1.5,4),P(2,3)},{P(2,3),P(1.5,2)},{P(1.5,2),P(0,2)},{P(1.2,2),P(2,0)}}
	FONT_LINES['S']={{P(2,3.5),P(1,4)},{P(1,4),P(0,3.5)},{P(0,3.5),P(2,1)},{P(2,1),P(1,0)},{P(1,0),P(0,0.5)}}
	FONT_LINES['T']={{P(1,0),P(1,4)},{P(0,4),P(2,4)}}
	FONT_LINES['U']={{P(0,4),P(0,1)},{P(0,1),P(1,0)},{P(1,0),P(1.8,1)},{P(1.8,1),P(1.8,4)}}
	FONT_LINES['V']={{P(0,4),P(1,0)},{P(1,0),P(2,4)}}
	FONT_LINES['W']={{P(0,4),P(0.6,0)},{P(0.6,0),P(1.5,2)},{P(1.5,2),P(2.4,0)},{P(2.4,0),P(3,4)}}
	FONT_LINES['X']={{P(0,0),P(2,4)},{P(0,4),P(2,0)}}
	FONT_LINES['Y']={{P(1,0),P(1,2)},{P(1,2),P(0,4)},{P(1,2),P(2,4)}}
	FONT_LINES['Z']={{P(0,4),P(2,4)},{P(2,4),P(0,0)},{P(0,0),P(2,0)}}
	FONT_LINES['1']={{P(1,0),P(1,4)},{P(1,4),P(0.3,3)}}
	FONT_LINES['2']={{P(0,3.2),P(1,4)},{P(1,4),P(1.8,3.2)},{P(1.8,3.2),P(0,0)},{P(0,0),P(2,0)}}
	FONT_LINES['3']={{P(0,3.2),P(1,4)},{P(1,4),P(1.8,3.2)},{P(1.8,3.2),P(0.8,2)},{P(0.8,2),P(1.8,0.8)},{P(1.8,0.8),P(1,0)},{P(1,0),P(0,0.8)}}
	FONT_LINES['4']={{P(1.5,0),P(1.5,4)},{P(1.5,4),P(0,1)},{P(0,1),P(2,1)}}
	FONT_LINES['5']={{P(1.8,4),P(0,4)},{P(0,4),P(0,2.3)},{P(0,2.3),P(1.5,2.5)},{P(1.5,2.5),P(1.8,1.5)}, {P(1.8,1.5),P(1.8,0.8)},{P(1.8,0.8),P(1,0)},{P(1,0),P(0,0.5)}}
	FONT_LINES['6']={{P(1.5,3.5),P(0.5,2)},{P(0.5,2),P(1.8,2)},{P(1.8,2),P(1.8,0.8)},{P(1.8,0.8),P(1,0)},{P(1,0),P(0.2,1)},{P(0.2,1),P(0.2,2.5)},{P(0.2,2.5),P(1,4)}}
	FONT_LINES['7']={{P(0,4),P(2,4)},{P(2,4),P(0.5,0)}}
	FONT_LINES['8']={{P(1,2),P(0.2,1)},{P(0.2,1),P(1,0)},{P(1,0),P(1.8,1)},{P(1.8,1),P(1,2)},{P(1,2),P(1.8,3)},{P(1.8,3),P(1,4)},{P(1,4),P(0.2,3)},{P(0.2,3),P(1,2)}}
	FONT_LINES['9']={{P(0.2,0.5),P(1.5,2)},{P(1.5,2),P(0.2,2)},{P(0.2,2),P(0.2,3.2)},{P(0.2,3.2),P(1,4)},{P(1,4),P(1.8,3)},{P(1.8,3),P(1.8,1.5)},{P(1.8,1.5),P(1,0)}}
	FONT_LINES['0']={{P(1,0),P(0.2,1)},{P(0.2,1),P(0.2,3)},{P(0.2,3),P(1,4)},{P(1,4),P(1.8,3)},{P(1.8,3),P(1.8,1)},{P(1.8,1),P(1,0)}}
	FONT_LINES[' ']={}
	setmetatable(FONT_LINES, {__index = function() return {{P(0,0),P(0,4)},{P(0,4),P(2,4)},{P(2,4),P(2,0)},{P(2,0),P(0,0)}} end}) -- Fallback box
	
	-- Рисование ТЕКСТА ТОЛЬКО НА ЗЕМЛЕ (V9/V10 логика)
	CreateBtn(pDraw, "DRAW TEXT (GROUND ONLY)", function(b)
		if not lp.Character or not lp.Character:FindFirstChild("HumanoidRootPart") then return end
		if not lp.Character:FindFirstChildOfClass("Tool") then b.Text = "HOLD TOOL!"; task.wait(1); b.Text = "DRAW TEXT (GROUND ONLY)"; return end
		
		b.Text = "CALCULATING..."
		local txt = textIn.Text:upper()
		local sz = tonumber(sizeIn.Text) or 2
		local batch = {}
		local charSpacing = 2.5 * sz
		local totalW = #txt * charSpacing
		local offset = -totalW / 2
		
		local root = lp.Character.HumanoidRootPart
		local centerFrame = root.CFrame * CFrame.new(0, 0, -12) -- В 12 студах впереди
		local density = 0.5 * sz

		for i=1, #txt do
			local char = txt:sub(i,i)
			local lines = FONT_LINES[char]
			local col = isRainbowDraw and Color3.fromHSV((tick()%1 + i/#txt)%1, 1, 1) or drawColor
			for _, l in ipairs(lines) do
				-- Скейлинг координат
				local startRel = Vector3.new(l[1][1] * density, 0, l[1][2] * density)
				local endRel = Vector3.new(l[2][1] * density, 0, l[2][2] * density)
				
				local offsetCharX = offset + (i-1)*charSpacing
				
				-- Применение офсета и инверсии Z
				local finalS = Vector3.new(offsetCharX + startRel.X, 0, -startRel.Z)
				local finalE = Vector3.new(offsetCharX + endRel.X, 0, -endRel.Z)
				
				interpolateGroundLine(batch, finalS, finalE, centerFrame, col, sz)
			end
		end
		
		if #batch > 0 then safeDraw(batch) end
		b.Text = "SENT!"
		task.wait(0.5)
		b.Text = "DRAW TEXT (GROUND ONLY)"
	end)
	
	-- Цикл мышиного рисования (ВСЕ ПОВЕРХНОСТИ)
	task.spawn(function()
		while gui.Parent do
			if isDrawing and UserInputService:IsMouseButtonPressed(Enum.UserInputType.MouseButton1) then
				if lp.Character and lp.Character:FindFirstChildOfClass("Tool") then
					local b = {}
					local p = mouse.Hit.Position
					local dir = (mouse.Hit.Position - cam.CFrame.Position).Unit
					local n = mouse.Hit.LookVector
					local c = isRainbowDraw and Color3.fromHSV(tick()%1, 1, 1) or drawColor
					
					if drawShape == "Dot" then
						local pos, nr = getSurfacePos(cam.CFrame.Position, dir) -- Рейкаст от камеры к мыши
						if pos then table.insert(b, {cframe = CFrame.lookAt(pos, pos+nr)*CFrame.Angles(0, math.rad(90), 0), color = c}) end
					elseif drawShape == "Circle" then
						-- Упрощенный круг на поверхности
						local cf = mouse.Hit
						for i=1, 16 do
							local a = (i/16)*math.pi*2
							local off = cf * Vector3.new(math.cos(a)*3, math.sin(a)*3, 0)
							local pos, nr = getSurfacePos(off + n*2, -n)
							if pos then table.insert(b, {cframe = CFrame.lookAt(pos, pos+nr)*CFrame.Angles(0, math.rad(90), 0), color = c}) end
						end
					elseif drawShape == "Square" then
						local cf = mouse.Hit
						local sz = 3
						local points = {cf*Vector3.new(sz,sz,0), cf*Vector3.new(sz,-sz,0), cf*Vector3.new(-sz,-sz,0), cf*Vector3.new(-sz,sz,0), cf*Vector3.new(sz,sz,0)}
						for i=1, #points-1 do
							local p1 = points[i]
							local p2 = points[i+1]
							for t=0, 1, 0.2 do
								local lp_ = p1:Lerp(p2, t)
								local pos, nr = getSurfacePos(lp_ + n*2, -n)
								if pos then table.insert(b, {cframe = CFrame.lookAt(pos, pos+nr)*CFrame.Angles(0, math.rad(90), 0), color = c}) end
							end
						end
					end
					if #b > 0 then chalkEvent:FireServer(b) end -- Маленькие пакеты шлем сразу
				end
			end
			task.wait(0.05) -- Частота рисования мышью
		end
	end)
	
	--// LAG TAB //--
	CreateBtn(pLag, "PUSH REQUEST SPAM", function()
		local r = scanRemote("PushRequest")
		if r then for i=1,50 do r:FireServer() end end
	end)
	CreateBtn(pLag, "MONEY GUN LAG SPAM", function()
		local t = lp.Backpack:FindFirstChild("Superme Money Gun") or lp.Character:FindFirstChild("Superme Money Gun")
		if t then for i=1,40 do t.RemoteEvent:FireServer() end end
	end)
	
	--// THEME TAB //--
	for name, _ in pairs(themes) do
		CreateBtn(pSet, "APPLY: "..name:upper(), function()
			playClick()
			UpdateTheme(name)
		end)
	end
end

--// KEY SYSTEM //--
local keyFrame = Instance.new("Frame", gui)
keyFrame.Size = UDim2.new(0, 400, 0, 250)
keyFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
keyFrame.AnchorPoint = Vector2.new(0.5, 0.5)
keyFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
Instance.new("UICorner", keyFrame).CornerRadius = UDim.new(0, 15)
local ks = Instance.new("UIStroke", keyFrame)
ks.Color = Color3.fromRGB(90, 140, 255)
ks.Thickness = 2
ks.Transparency = 0.5
MakeDraggable(keyFrame)

local kt = Instance.new("TextLabel", keyFrame)
kt.Text = "JASPER NEXUS"
kt.Font = Enum.Font.GothamBlack
kt.TextSize = 24
kt.TextColor3 = Color3.fromRGB(255, 255, 255)
kt.Size = UDim2.new(1, 0, 0, 80)
kt.BackgroundTransparency = 1
kt.Parent = keyFrame

local ki = Instance.new("TextBox", keyFrame)
ki.Size = UDim2.new(0.8, 0, 0, 45)
ki.Position = UDim2.new(0.1, 0, 0.4, 0)
ki.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
ki.Text = ""
ki.PlaceholderText = "ENTER KEY"
ki.TextColor3 = Color3.new(1,1,1)
ki.Font = Enum.Font.GothamBold
ki.TextSize = 14
ki.Parent = keyFrame
Instance.new("UICorner", ki)

local kb = Instance.new("TextButton", keyFrame)
kb.Size = UDim2.new(0.5, 0, 0, 45)
kb.Position = UDim2.new(0.25, 0, 0.7, 0)
kb.BackgroundColor3 = Color3.fromRGB(90, 140, 255)
kb.Text = "ENTER"
kb.Font = Enum.Font.GothamBlack
kb.TextColor3 = Color3.new(1,1,1)
kb.TextSize = 16
kb.Parent = keyFrame
Instance.new("UICorner", kb)

kb.MouseButton1Click:Connect(function()
	if ki.Text == "JASPERISTHEBEST" then
		playClick()
		kb.Text = "AUTHORIZED"
		kb.BackgroundColor3 = Color3.fromRGB(50, 200, 100)
		TweenService:Create(keyFrame, TweenInfo.new(0.6, Enum.EasingStyle.Back), {Position = UDim2.new(0.5, 0, 1.5, 0)}):Play()
		task.wait(0.6)
		keyFrame:Destroy()
		LoadMain()
	else
		kb.Text = "WRONG KEY"
		kb.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
		task.wait(1)
		kb.Text = "ENTER"
		kb.BackgroundColor3 = Color3.fromRGB(90, 140, 255)
	end
end)
