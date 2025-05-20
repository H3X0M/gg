local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- Drag utility (kompatibel PC & HP)
local function makeDraggable(frame)
    local dragging, dragInput, startPos, startInputPos

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or
           input.UserInputType == Enum.UserInputType.Touch then
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
                    frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X,
                                               startPos.Y.Scale, startPos.Y.Offset + delta.Y)
                end
            end)
        end
    end)

    UIS.InputEnded:Connect(function(input)
        if input == dragInput then
            dragging = false
        end
    end)
end

-- Fungsi membuat GUI
local function createMenu()
    -- Hapus GUI lama
    local old = player:WaitForChild("PlayerGui"):FindFirstChild("MinimalMenu")
    if old then old:Destroy() end

    local gui = Instance.new("ScreenGui", player:WaitForChild("PlayerGui"))
    gui.Name = "MinimalMenu"
    gui.ResetOnSpawn = false

    -- Posisi awal di samping ikon chat kiri atas
    local toggleFrame = Instance.new("Frame", gui)
    toggleFrame.Size = UDim2.new(0, 50, 0, 50)
    toggleFrame.Position = UDim2.new(0, 120, 0, 40) -- Dekat icon chat kiri atas
    toggleFrame.BackgroundTransparency = 1
    toggleFrame.Active = true

    makeDraggable(toggleFrame) -- Bisa digeser manual

    local toggleBtn = Instance.new("TextButton", toggleFrame)
    toggleBtn.Size = UDim2.new(1, 0, 1, 0)
    toggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    toggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    toggleBtn.Font = Enum.Font.GothamBold
    toggleBtn.TextSize = 20
    toggleBtn.Text = "≡"
    toggleBtn.BorderSizePixel = 0

    local frame = Instance.new("Frame", gui)
    frame.Size = UDim2.new(0, 180, 0, 130)
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
    title.Text = "Fly & No Clip Menu"

    local noclipBtn = Instance.new("TextButton", frame)
    noclipBtn.Size = UDim2.new(1, -20, 0, 40)
    noclipBtn.Position = UDim2.new(0, 10, 0, 40)
    noclipBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    noclipBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    noclipBtn.Font = Enum.Font.Gotham
    noclipBtn.TextSize = 14
    noclipBtn.Text = "No Clip: OFF"

    local flyBtn = Instance.new("TextButton", frame)
    flyBtn.Size = UDim2.new(1, -20, 0, 40)
    flyBtn.Position = UDim2.new(0, 10, 0, 85)
    flyBtn.BackgroundColor3 = Color3.fromRGB(70, 70, 70)
    flyBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    flyBtn.Font = Enum.Font.Gotham
    flyBtn.TextSize = 14
    flyBtn.Text = "Fly: OFF"

    toggleBtn.MouseButton1Click:Connect(function()
        frame.Visible = not frame.Visible
    end)

    -- No Clip
    local noClip = false
    local noClipConn
    noclipBtn.MouseButton1Click:Connect(function()
        noClip = not noClip
        noclipBtn.Text = "No Clip: " .. (noClip and "ON" or "OFF")
        if noClipConn then noClipConn:Disconnect() end
        if noClip then
            noClipConn = RunService.Stepped:Connect(function()
                for _, part in pairs(player.Character:GetChildren()) do
                    if part:IsA("BasePart") then
                        part.CanCollide = false
                    end
                end
            end)
        else
            for _, part in pairs(player.Character:GetChildren()) do
                if part:IsA("BasePart") then
                    part.CanCollide = true
                end
            end
        end
    end)

    -- Fly
    local flying = false
    local flyConn
    local bodyVel, bodyGyro

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
            local dir = cam.CFrame.LookVector * 50 * player.Character.Humanoid.MoveDirection.Magnitude
            bodyVel.Velocity = dir
            bodyGyro.CFrame = CFrame.new(hrp.Position, hrp.Position + cam.CFrame.LookVector)
        end)
    end

    local function stopFly()
        if flyConn then flyConn:Disconnect() end
        if bodyVel then bodyVel:Destroy() end
        if bodyGyro then bodyGyro:Destroy() end
        local hum = player.Character:FindFirstChildOfClass("Humanoid")
        if hum then hum.PlatformStand = false end
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
end

-- Jalankan pertama kali dan setelah respawn/teleport
createMenu()
Players.LocalPlayer.CharacterAdded:Connect(function()
    task.wait(1)
    createMenu()
end)
