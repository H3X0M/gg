local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer

local rememberedMonsters = {}
local rememberedPolisi = {}

-- Fungsi drag frame
local function makeDraggable(frame)
	local dragging, dragInput, startPos, startInputPos
	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			startInputPos = input.Position
			startPos = frame.Position
			dragInput = input
		end
	end)
	frame.InputChanged:Connect(function(input)
		if input == dragInput then
			RunService.RenderStepped:Connect(function()
				if dragging then
					local delta = input.Position - startInputPos
					frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
				end
			end)
		end
	end)
	UIS.InputEnded:Connect(function(input)
		if input == dragInput then dragging = false end
	end)
end

-- Tentukan role player dengan cache agar tidak cek berulang
local function getRole(plr)
	if rememberedMonsters[plr] then
		return "Monster", Color3.fromRGB(255, 0, 0)
	elseif rememberedPolisi[plr] then
		return "Polisi", Color3.fromRGB(0, 170, 255)
	end

	local char = plr.Character
	if char then
		if char:FindFirstChild("MonsterClaw") or char:FindFirstChild("Monster") or plr.Name:lower():find("monster") then
			rememberedMonsters[plr] = true
			return "Monster", Color3.fromRGB(255, 0, 0)
		elseif char:FindFirstChild("Gun") or char:FindFirstChild("PoliceBadge") or plr.Name:lower():find("police") then
			rememberedPolisi[plr] = true
			return "Polisi", Color3.fromRGB(0, 170, 255)
		end
	end
	return "Player", Color3.fromRGB(0, 255, 0)
end

-- Buat ESP label dan highlight glow
local function createESP(plr)
	if plr == player then return end -- Skip karakter sendiri
	local function setup()
		local char = plr.Character
		if not char then return end
		local head = char:FindFirstChild("Head")
		if head and not head:FindFirstChild("ESPLabel") then
			local role, color = getRole(plr)

			local billboard = Instance.new("BillboardGui", head)
			billboard.Name = "ESPLabel"
			billboard.Size = UDim2.new(0, 100, 0, 40)
			billboard.Adornee = head
			billboard.AlwaysOnTop = true

			local label = Instance.new("TextLabel", billboard)
			label.Size = UDim2.new(1, 0, 1, 0)
			label.BackgroundTransparency = 1
			label.TextColor3 = color
			label.TextStrokeTransparency = 0
			label.Text = role
			label.Font = Enum.Font.SourceSansBold
			label.TextSize = 14

			if not char:FindFirstChild("HighlightForXRay") then
				local highlight = Instance.new("Highlight", char)
				highlight.Name = "HighlightForXRay"
				highlight.FillColor = color
				highlight.OutlineColor = Color3.new(1, 1, 1)
				highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			end

			RunService.Stepped:Connect(function()
				if plr and plr.Character and plr.Character:FindFirstChild("Head") and label then
					local newRole, newColor = getRole(plr)
					label.Text = newRole
					label.TextColor3 = newColor
					local highlight = plr.Character:FindFirstChild("HighlightForXRay")
					if highlight then
						highlight.FillColor = newColor
					end
				end
			end)
		end
	end
	if plr.Character then
		setup()
	else
		plr.CharacterAdded:Once(function()
			task.wait(1)
			setup()
		end)
	end
end

-- Hapus ESP label dan highlight
local function removeESP(plr)
	if plr.Character then
		local head = plr.Character:FindFirstChild("Head")
		if head then
			local esp = head:FindFirstChild("ESPLabel")
			if esp then esp:Destroy() end
		end
		local highlight = plr.Character:FindFirstChild("HighlightForXRay")
		if highlight then highlight:Destroy() end
	end
end

-- UI dan logika menu utility
local function createMenu()
	local old = player:WaitForChild("PlayerGui"):FindFirstChild("MinimalMenu")
	if old then old:Destroy() end

	local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
	gui.Name = "MinimalMenu"
	gui.ResetOnSpawn = false

	local toggleFrame = Instance.new("Frame", gui)
	toggleFrame.Size = UDim2.new(0, 50, 0, 50)
	toggleFrame.Position = UDim2.new(0, 120, 0, 40)
	toggleFrame.BackgroundTransparency = 1
	toggleFrame.Active = true
	makeDraggable(toggleFrame)

	local toggleBtn = Instance.new("TextButton", toggleFrame)
	toggleBtn.Size = UDim2.new(1, 0, 1, 0)
	toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
	toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	toggleBtn.Font = Enum.Font.GothamBold
	toggleBtn.TextSize = 20
	toggleBtn.Text = "≡"
	toggleBtn.BorderSizePixel = 0

	local frame = Instance.new("Frame", gui)
	frame.Size = UDim2.new(0, 180, 0, 215)
	frame.Position = UDim2.new(0, 180, 0, 40)
	frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
	frame.Visible = false
	frame.BorderSizePixel = 0

	local title = Instance.new("TextLabel", frame)
	title.Size = UDim2.new(1, 0, 0, 30)
	title.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
	title.TextColor3 = Color3.fromRGB(255, 255, 255)
	title.Font = Enum.Font.GothamBold
	title.TextSize = 14
	title.Text = "Ryan Menu"

	local noclipBtn = Instance.new("TextButton", frame)
	noclipBtn.Size = UDim2.new(1, -20, 0, 35)
	noclipBtn.Position = UDim2.new(0, 10, 0, 35)
	noclipBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
	noclipBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	noclipBtn.Font = Enum.Font.Gotham
	noclipBtn.TextSize = 14
	noclipBtn.Text = "No Clip: OFF"

	local flyBtn = noclipBtn:Clone()
	flyBtn.Position = UDim2.new(0, 10, 0, 75)
	flyBtn.Text = "Fly: OFF"
	flyBtn.Parent = frame

	local fastRunBtn = noclipBtn:Clone()
	fastRunBtn.Position = UDim2.new(0, 10, 0, 115)
	fastRunBtn.Text = "Fast Run: OFF"
	fastRunBtn.Parent = frame

	local xrayBtn = noclipBtn:Clone()
	xrayBtn.Position = UDim2.new(0, 10, 0, 155)
	xrayBtn.Text = "X-Ray: OFF"
	xrayBtn.Parent = frame

	toggleBtn.MouseButton1Click:Connect(function()
		frame.Visible = not frame.Visible
	end)

	-- No Clip logic
	local noClip = false
	local noClipConn
	noclipBtn.MouseButton1Click:Connect(function()
		noClip = not noClip
		noclipBtn.Text = "No Clip: " .. (noClip and "ON" or "OFF")
		if noClipConn then noClipConn:Disconnect() end
		if noClip then
			noClipConn = RunService.Stepped:Connect(function()
				if player.Character then
					for _, part in pairs(player.Character:GetChildren()) do
						if part:IsA("BasePart") then
							part.CanCollide = false
						end
					end
				end
			end)
		else
			if player.Character then
				for _, part in pairs(player.Character:GetChildren()) do
					if part:IsA("BasePart") then
						part.CanCollide = true
					end
				end
			end
		end
	end)

	-- Fly logic
	local flying = false
	local flyConn, bodyVel, bodyGyro
	local function startFly()
		local char = player.Character or player.CharacterAdded:Wait()
		local hrp = char:WaitForChild("HumanoidRootPart")
		local hum = char:WaitForChild("Humanoid")
		bodyVel = Instance.new("BodyVelocity", hrp)
		bodyVel.Velocity = Vector3.zero
		bodyVel.MaxForce = Vector3.new(1e5, 1e5, 1e5)
		bodyGyro = Instance.new("BodyGyro", hrp)
		bodyGyro.CFrame = hrp.CFrame
		bodyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
		bodyGyro.P = 9e4
		hum.PlatformStand = true
		flyConn = RunService.RenderStepped:Connect(function()
			local cam = workspace.CurrentCamera
			local dir = cam.CFrame.LookVector * 50 * hum.MoveDirection.Magnitude
			bodyVel.Velocity = dir
			bodyGyro.CFrame = cam.CFrame
		end)
	end
	local function stopFly()
		if flyConn then flyConn:Disconnect() end
		if bodyVel then bodyVel:Destroy() end
		if bodyGyro then bodyGyro:Destroy() end
		if player.Character then
			local hum = player.Character:FindFirstChild("Humanoid")
			if hum then hum.PlatformStand = false end
		end
	end

	flyBtn.MouseButton1Click:Connect(function()
		flying = not flying
		flyBtn.Text = "Fly: " .. (flying and "ON" or "OFF")
		if flying then
			startFly()
		else
			stopFly()
		end
	end)

	-- Fast Run logic
	local fastRun = false
	local fastRunConn
	fastRunBtn.MouseButton1Click:Connect(function()
		fastRun = not fastRun
		fastRunBtn.Text = "Fast Run: " .. (fastRun and "ON" or "OFF")
		if fastRun then
			if fastRunConn then fastRunConn:Disconnect() end
			fastRunConn = RunService.Stepped:Connect(function()
				local hum = player.Character and player.Character:FindFirstChild("Humanoid")
				if hum then
					hum.WalkSpeed = 23
				end
			end)
		else
			if fastRunConn then fastRunConn:Disconnect() end
			local hum = player.Character and player.Character:FindFirstChild("Humanoid")
			if hum then
				hum.WalkSpeed = 16
			end
		end
	end)

	-- X-Ray toggle
	local xray = false
	xrayBtn.MouseButton1Click:Connect(function()
	xray = not xray
	xrayBtn.Text = "X-Ray: " .. (xray and "ON" or "OFF")

	-- Bersihkan cache agar tidak menyebabkan deteksi invalid
	table.clear(rememberedMonsters)
	table.clear(rememberedPolisi)

	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= player then
			if xray then
				createESP(plr)
			else
				removeESP(plr)
			end
		end
	end
end)

	-- Update ESP setiap ada player baru atau karakter muncul
	Players.PlayerAdded:Connect(function(plr)
		plr.CharacterAdded:Connect(function()
			if xray then createESP(plr) end
		end)
	end)
	Players.PlayerRemoving:Connect(function(plr)
		removeESP(plr)
		rememberedMonsters[plr] = nil
		rememberedPolisi[plr] = nil
	end)

	-- Awal cek semua player
	for _, plr in pairs(Players:GetPlayers()) do
		plr.CharacterAdded:Connect(function()
			if xray then createESP(plr) end
		end)
	end
end

createMenu()
