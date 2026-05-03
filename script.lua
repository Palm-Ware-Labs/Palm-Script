local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local Window = Rayfield:CreateWindow({
    Name = "Palm-Script",
    LoadingTitle = "Palm-Script",
    LoadingSubtitle = "by Palm-Labs",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "PalmScript",
        FileName = "Config"
    },
    Discord = {
        Enabled = true,
        Invite = "az9USTNcy7",
        RememberJoins = true
    },
    KeySystem = false,
})

local Players = game:GetService("Players")
local Player = Players.LocalPlayer
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local GuiService = game:GetService("GuiService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui")

local FlyEnabled = false
local FlySpeed = 50
local SpeedValue = 16
local JumpValue = 50
local NoclipEnabled = false
local InvincibilityEnabled = false
local ESPEnabled = false
local ESPInstances = {}
local SelectedPlayer = nil
local flyBV, flyBG
local AutoRejoinEnabled = false

local PfpGui = Instance.new("ScreenGui")
PfpGui.Name = "PalmPfpGui"
PfpGui.ResetOnSpawn = false
PfpGui.Parent = CoreGui

local PfpFrame = Instance.new("Frame")
PfpFrame.Size = UDim2.new(0, 150, 0, 150)
PfpFrame.Position = UDim2.new(1, -170, 0.5, -75)
PfpFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
PfpFrame.BorderSizePixel = 0
PfpFrame.Visible = false
PfpFrame.Parent = PfpGui

local PfpCorner = Instance.new("UICorner")
PfpCorner.CornerRadius = UDim.new(0, 10)
PfpCorner.Parent = PfpFrame

local PfpImage = Instance.new("ImageLabel")
PfpImage.Size = UDim2.new(1, -10, 1, -10)
PfpImage.Position = UDim2.new(0, 5, 0, 5)
PfpImage.BackgroundTransparency = 1
PfpImage.Image = ""
PfpImage.Parent = PfpFrame

local PfpImageCorner = Instance.new("UICorner")
PfpImageCorner.CornerRadius = UDim.new(0, 10)
PfpImageCorner.Parent = PfpImage

local PfpLabel = Instance.new("TextLabel")
PfpLabel.Size = UDim2.new(1, 0, 0, 20)
PfpLabel.Position = UDim2.new(0, 0, 1, 5)
PfpLabel.BackgroundTransparency = 1
PfpLabel.Text = "Selected Player"
PfpLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
PfpLabel.Font = Enum.Font.GothamBold
PfpLabel.TextSize = 12
PfpLabel.Parent = PfpFrame

local function StopFlight()
    if flyBV then flyBV:Destroy() flyBV = nil end
    if flyBG then flyBG:Destroy() flyBG = nil end
    if Player.Character and Player.Character:FindFirstChild("Humanoid") then
        Player.Character.Humanoid.PlatformStand = false
    end
end

local function StartFlight()
    local char = Player.Character
    if not char or not char:FindFirstChild("HumanoidRootPart") or not char:FindFirstChild("Humanoid") then return end
    local root = char.HumanoidRootPart
    local hum = char.Humanoid
    if flyBG then flyBG:Destroy() end
    if flyBV then flyBV:Destroy() end
    flyBG = Instance.new("BodyGyro", root)
    flyBG.P = 9e4
    flyBG.MaxTorque = Vector3.new(9e9, 9e9, 9e9)
    flyBV = Instance.new("BodyVelocity", root)
    flyBV.MaxForce = Vector3.new(9e9, 9e9, 9e9)
    hum.PlatformStand = true
    task.spawn(function()
        while FlyEnabled and char and char.Parent and root and root.Parent and hum and hum.Parent do
            local cam = workspace.CurrentCamera
            RunService.RenderStepped:Wait()
            local moveDir = hum.MoveDirection
            local yMove = 0
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then yMove = 1
            elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then yMove = -1 end
            if moveDir.Magnitude > 0 or yMove ~= 0 then
                local direction = cam.CFrame:VectorToObjectSpace(moveDir)
                local flyVec = (cam.CFrame.LookVector * -direction.Z) + (cam.CFrame.RightVector * direction.X) + Vector3.new(0, yMove, 0)
                if flyVec.Magnitude > 0 then flyBV.Velocity = flyVec.Unit * FlySpeed
                else flyBV.Velocity = Vector3.new(0, 0.1, 0) end
            else flyBV.Velocity = Vector3.new(0, 0.1, 0) end
            flyBG.CFrame = cam.CFrame
        end
        StopFlight()
    end)
end

RunService.Stepped:Connect(function()
    if NoclipEnabled and Player.Character then
        for _, part in pairs(Player.Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    end
end)

local function FlingTarget(TargetPlayer)
    local char = Player.Character
    local targetChar = TargetPlayer.Character
    if not char or not targetChar then return end
    local root = char:FindFirstChild("HumanoidRootPart")
    local targetRoot = targetChar:FindFirstChild("HumanoidRootPart")
    if not root or not targetRoot then return end
    local oldPos = root.CFrame
    local attachment = Instance.new("Attachment", root)
    local FlingVelocity = Instance.new("AngularVelocity")
    FlingVelocity.Attachment0 = attachment
    FlingVelocity.AngularVelocity = Vector3.new(99999, 99999, 99999)
    FlingVelocity.MaxTorque = math.huge
    FlingVelocity.Parent = root
    local connection
    connection = RunService.Stepped:Connect(function()
        if char and targetChar and root and targetRoot then
            root.CFrame = targetRoot.CFrame
            for _, v in pairs(char:GetChildren()) do
                if v:IsA("BasePart") then v.CanCollide = false end
            end
        end
    end)
    task.wait(0.5)
    connection:Disconnect()
    if FlingVelocity then FlingVelocity:Destroy() end
    if attachment then attachment:Destroy() end
    if root then
        root.AssemblyLinearVelocity = Vector3.new(0,0,0)
        root.AssemblyAngularVelocity = Vector3.new(0,0,0)
        root.CFrame = oldPos
    end
end

local function RemoveESP(plr)
    if ESPInstances[plr] then
        for _, instance in pairs(ESPInstances[plr]) do
            if instance then instance:Destroy() end
        end
        ESPInstances[plr] = nil
    end
end

local function ApplyESP(plr)
    if plr == Player then return end
    RemoveESP(plr)
    if ESPEnabled and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
        ESPInstances[plr] = {}
        local highlight = Instance.new("Highlight")
        highlight.FillColor = Color3.fromRGB(255, 0, 0)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.Parent = plr.Character
        table.insert(ESPInstances[plr], highlight)
        local billboard = Instance.new("BillboardGui")
        billboard.AlwaysOnTop = true
        billboard.Size = UDim2.new(0, 100, 0, 50)
        billboard.StudsOffset = Vector3.new(0, 3, 0)
        local textLabel = Instance.new("TextLabel")
        textLabel.Parent = billboard
        textLabel.BackgroundTransparency = 1
        textLabel.Size = UDim2.new(1, 0, 1, 0)
        textLabel.Text = plr.Name
        textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        textLabel.TextStrokeTransparency = 0
        textLabel.TextSize = 14
        textLabel.Font = Enum.Font.GothamBold
        billboard.Parent = plr.Character:FindFirstChild("Head") or plr.Character:FindFirstChild("HumanoidRootPart")
        table.insert(ESPInstances[plr], billboard)
    end
end

local function RefreshAllESP()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= Player then if ESPEnabled then ApplyESP(p) else RemoveESP(p) end end
    end
end

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function() task.wait(1) if ESPEnabled then ApplyESP(p) end end)
end)
Players.PlayerRemoving:Connect(function(p) RemoveESP(p) end)

local function GetPlayerNames()
    local names = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= Player then table.insert(names, p.Name) end
    end
    return names
end

Player.Idled:Connect(function()
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame)
end)

GuiService.ErrorMessageChanged:Connect(function()
    if AutoRejoinEnabled then TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Player) end
end)

local MainTab = Window:CreateTab("Movement", 4483362458)
local PlayersTab = Window:CreateTab("Players", 4483362458)
local VisualsTab = Window:CreateTab("Visuals", 4483362458)
local MiscTab = Window:CreateTab("Misc", 4483362458)
local NDSTab
if game.PlaceId == 189707 then NDSTab = Window:CreateTab("NDS", 4483362458) end
local InfoTab = Window:CreateTab("Credits", 4483362458)

MainTab:CreateSection("Character Physics")
MainTab:CreateToggle({
    Name = "God Mode",
    CurrentValue = false,
    Flag = "GodMode",
    Callback = function(Value)
        InvincibilityEnabled = Value
        if Value then
            local char = Player.Character
            if char and char:FindFirstChild("Humanoid") then
                local hum = char.Humanoid
                hum.Name = "1"
                local clone = hum:Clone()
                clone.Name = "Humanoid"
                clone.Parent = char
                hum:Destroy()
                workspace.CurrentCamera.CameraSubject = clone
                if char:FindFirstChild("Animate") then char.Animate.Disabled = true char.Animate.Disabled = false end
            end
        else
            if Player.Character and Player.Character:FindFirstChild("Humanoid") then Player.Character.Humanoid.Health = 0 end
        end
    end,
})

MainTab:CreateSlider({
    Name = "WalkSpeed",
    Range = {16, 500},
    Increment = 1,
    Suffix = "Speed",
    CurrentValue = 16,
    Flag = "WS",
    Callback = function(Value)
        SpeedValue = Value
        if Player.Character and Player.Character:FindFirstChild("Humanoid") then Player.Character.Humanoid.WalkSpeed = Value end
    end,
})

MainTab:CreateSlider({
    Name = "Jump Power",
    Range = {50, 1000},
    Increment = 1,
    Suffix = "Power",
    CurrentValue = 50,
    Flag = "JP",
    Callback = function(Value)
        JumpValue = Value
        if Player.Character and Player.Character:FindFirstChild("Humanoid") then
            Player.Character.Humanoid.UseJumpPower = true
            Player.Character.Humanoid.JumpPower = Value
        end
    end,
})

MainTab:CreateSection("Advanced Movement")
MainTab:CreateToggle({
    Name = "Enable Flight",
    CurrentValue = false,
    Flag = "Fly",
    Callback = function(Value) FlyEnabled = Value if Value then StartFlight() else StopFlight() end end,
})
MainTab:CreateSlider({
    Name = "Flight Speed",
    Range = {10, 300},
    Increment = 5,
    Suffix = "Speed",
    CurrentValue = 50,
    Flag = "FlySpeed",
    Callback = function(Value) FlySpeed = Value end,
})
MainTab:CreateToggle({
    Name = "Noclip",
    CurrentValue = false,
    Flag = "Noclip",
    Callback = function(Value) 
        NoclipEnabled = Value 
        if not Value and Player.Character then
            for _, part in pairs(Player.Character:GetDescendants()) do
                if part:IsA("BasePart") then part.CanCollide = true end
            end
        end
    end,
})

PlayersTab:CreateSection("Target Selection")
local PlayerDropdown = PlayersTab:CreateDropdown({
    Name = "Select Player",
    Options = GetPlayerNames(),
    CurrentOption = "",
    MultipleOptions = false,
    Flag = "PlayerSelect",
    Callback = function(Option)
        SelectedPlayer = Option[1]
        if SelectedPlayer then
            local target = Players:FindFirstChild(SelectedPlayer)
            if target then
                task.spawn(function()
                    local thumbType = Enum.ThumbnailType.AvatarBust
                    local thumbSize = Enum.ThumbnailSize.Size420x420
                    local content, isReady = Players:GetUserThumbnailAsync(target.UserId, thumbType, thumbSize)
                    PfpImage.Image = content
                    PfpLabel.Text = target.Name
                    PfpFrame.Visible = true
                end)
            end
        else
            PfpFrame.Visible = false
        end
    end,
})

Players.PlayerAdded:Connect(function() PlayerDropdown:Refresh(GetPlayerNames()) end)
Players.PlayerRemoving:Connect(function() PlayerDropdown:Refresh(GetPlayerNames()) end)

PlayersTab:CreateSection("Actions")
PlayersTab:CreateButton({
    Name = "Teleport To",
    Callback = function()
        if SelectedPlayer then
            local target = Players:FindFirstChild(SelectedPlayer)
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                Player.Character.HumanoidRootPart.CFrame = target.Character.HumanoidRootPart.CFrame
            end
        end
    end,
})
PlayersTab:CreateButton({ Name = "Spectate", Callback = function() if SelectedPlayer then local target = Players:FindFirstChild(SelectedPlayer) if target and target.Character and target.Character:FindFirstChild("Humanoid") then workspace.CurrentCamera.CameraSubject = target.Character.Humanoid end end end })
PlayersTab:CreateButton({ Name = "Unspectate", Callback = function() if Player.Character and Player.Character:FindFirstChild("Humanoid") then workspace.CurrentCamera.CameraSubject = Player.Character.Humanoid end end })
PlayersTab:CreateButton({ Name = "Fling Player", Callback = function() if SelectedPlayer then local target = Players:FindFirstChild(SelectedPlayer) if target then FlingTarget(target) end end end })

VisualsTab:CreateSection("Player ESP")
VisualsTab:CreateToggle({
    Name = "Enable ESP",
    CurrentValue = false,
    Flag = "ESP",
    Callback = function(Value) ESPEnabled = Value RefreshAllESP() end,
})
VisualsTab:CreateSection("Environment")
VisualsTab:CreateToggle({
    Name = "Fullbright",
    CurrentValue = false,
    Flag = "FB",
    Callback = function(Value)
        game:GetService("Lighting").Brightness = Value and 2 or 1
        game:GetService("Lighting").ClockTime = Value and 14 or 12
        game:GetService("Lighting").GlobalShadows = not Value
    end,
})

MiscTab:CreateSection("Utility")
MiscTab:CreateButton({ Name = "Infinite Yield", Callback = function() loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))() end })
MiscTab:CreateToggle({ Name = "Auto Rejoin", CurrentValue = false, Flag = "AutoRejoin", Callback = function(Value) AutoRejoinEnabled = Value end })
MiscTab:CreateButton({
    Name = "Server Hop",
    Callback = function()
        local servers = {}
        local req = (request or http_request or syn.request)({Url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"})
        if req and req.StatusCode == 200 then
            local body = HttpService:JSONDecode(req.Body)
            for _, v in pairs(body.data) do
                if v.playing < v.maxPlayers and v.id ~= game.JobId then table.insert(servers, v.id) end
            end
            if #servers > 0 then TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], Player) end
        end
    end,
})

if NDSTab then
    local superRingParts = {}
    local SuperRingEnabled = false
    local SuperRingRadius = 50
    local SuperRingHeight = 5
    local SuperRingSpeed = 10
    local SuperRingStrength = 60

    local function RetainPart(Part)
        if Part:IsA("BasePart") and not Part.Anchored and Part:IsDescendantOf(workspace) then
            for _, p in pairs(Players:GetPlayers()) do
                if p.Character and Part:IsDescendantOf(p.Character) then return false end
            end
            if superRingParts[Part] then return false end
            pcall(function()
                Part.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
                Part.CanCollide = false
            end)
            return true
        end
        return false
    end

    local function ScanForParts()
        for _, part in pairs(workspace:GetDescendants()) do 
            if RetainPart(part) then superRingParts[part] = true end 
        end
    end

    workspace.DescendantAdded:Connect(function(part)
        if SuperRingEnabled and RetainPart(part) then
            superRingParts[part] = true
        end
    end)

    task.spawn(function()
        while task.wait(2) do
            if SuperRingEnabled then ScanForParts() end
        end
    end)

    RunService.Heartbeat:Connect(function()
        if SuperRingEnabled and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
            local hrp = Player.Character.HumanoidRootPart
            local center = hrp.Position
            local timeVar = os.clock() * (SuperRingSpeed * 0.3)
            
            local validParts = {}
            for part, _ in pairs(superRingParts) do
                if part and part.Parent and not part.Anchored and part:IsDescendantOf(workspace) then
                    table.insert(validParts, part)
                else
                    superRingParts[part] = nil
                end
            end
            
            local totalParts = #validParts
            for i, part in ipairs(validParts) do
                local angle = timeVar + ((i / math.max(1, totalParts)) * math.pi * 2)
                local targetPos = Vector3.new(
                    center.X + math.cos(angle) * SuperRingRadius,
                    center.Y + SuperRingHeight,
                    center.Z + math.sin(angle) * SuperRingRadius
                )
                
                local dir = targetPos - part.Position
                part.AssemblyLinearVelocity = dir * SuperRingStrength
                local angForce = SuperRingStrength * 0.5
                part.AssemblyAngularVelocity = Vector3.new(angForce, angForce, angForce)
            end
        end
    end)

    NDSTab:CreateSection("Natural Disaster Survival")
    NDSTab:CreateToggle({
        Name = "Super Ring",
        CurrentValue = false,
        Flag = "NDSSuperRing",
        Callback = function(Value) 
            SuperRingEnabled = Value 
            if Value then ScanForParts() else superRingParts = {} end 
        end,
    })
    NDSTab:CreateSlider({
        Name = "Radius",
        Range = {5, 200},
        Increment = 1,
        CurrentValue = 50,
        Callback = function(Value) SuperRingRadius = Value end,
    })
    NDSTab:CreateSlider({
        Name = "Height Offset",
        Range = {-50, 100},
        Increment = 1,
        CurrentValue = 5,
        Callback = function(Value) SuperRingHeight = Value end,
    })
    NDSTab:CreateSlider({
        Name = "Rotation Speed",
        Range = {1, 50},
        Increment = 1,
        CurrentValue = 10,
        Callback = function(Value) SuperRingSpeed = Value end,
    })
    NDSTab:CreateSlider({
        Name = "Strength",
        Range = {10, 300},
        Increment = 5,
        CurrentValue = 60,
        Callback = function(Value) SuperRingStrength = Value end,
    })
end

InfoTab:CreateLabel("Palm-Script v1.1")
InfoTab:CreateLabel("Created by Palm-Labs.")

Player.CharacterAdded:Connect(function(NewChar)
    task.wait(0.5)
    local hum = NewChar:WaitForChild("Humanoid")
    if InvincibilityEnabled then
        hum.Name = "1"
        local clone = hum:Clone()
        clone.Name = "Humanoid"
        clone.Parent = NewChar
        hum:Destroy()
        hum = clone
        workspace.CurrentCamera.CameraSubject = hum
    end
    hum.WalkSpeed = SpeedValue
    hum.UseJumpPower = true
    hum.JumpPower = JumpValue
    if FlyEnabled then StartFlight() end
end)

Rayfield:Notify({ Title = "Palm-Script Loaded", Content = "Welcome to Palm-Script!", Duration = 3 })
