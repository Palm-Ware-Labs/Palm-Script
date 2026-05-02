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
            
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then
                yMove = 1
            elseif UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then
                yMove = -1
            end
            
            if moveDir.Magnitude > 0 or yMove ~= 0 then
                local direction = cam.CFrame:VectorToObjectSpace(moveDir)
                local flyVec = (cam.CFrame.LookVector * -direction.Z) + (cam.CFrame.RightVector * direction.X) + Vector3.new(0, yMove, 0)
                
                if flyVec.Magnitude > 0 then
                    flyBV.Velocity = flyVec.Unit * FlySpeed
                else
                    flyBV.Velocity = Vector3.new(0, 0.1, 0)
                end
            else
                flyBV.Velocity = Vector3.new(0, 0.1, 0)
            end
            flyBG.CFrame = cam.CFrame
        end -- [FIXED]: Added the missing 'end' to close the while loop
        
        if flyBV then flyBV:Destroy() end
        if flyBG then flyBG:Destroy() end
        if hum and hum.Parent then hum.PlatformStand = false end
    end)
end

RunService.Stepped:Connect(function()
    if NoclipEnabled and Player.Character then
        -- [FIXED]: Changed GetDescendants() to GetChildren() to prevent severe lag
        for _, part in pairs(Player.Character:GetChildren()) do
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
    
    -- [FIXED]: Replaced deprecated BodyAngularVelocity with modern AngularVelocity
    local attachment = Instance.new("Attachment", root)
    local FlingVelocity = Instance.new("AngularVelocity")
    FlingVelocity.Attachment0 = attachment
    FlingVelocity.AngularVelocity = Vector3.new(99999, 99999, 99999)
    FlingVelocity.MaxTorque = math.huge
    FlingVelocity.Parent = root

    local startTime = tick()
    local connection
    
    connection = RunService.Stepped:Connect(function()
        if char and targetChar and root and targetRoot then
            root.CFrame = targetRoot.CFrame
            for _, v in pairs(char:GetChildren()) do
                if v:IsA("BasePart") then
                    v.CanCollide = false
                end
            end
        end
    end)

    task.wait(0.5)
    
    connection:Disconnect()
    if FlingVelocity then FlingVelocity:Destroy() end
    if attachment then attachment:Destroy() end
    if root then
        -- [FIXED]: Replaced deprecated Velocity and RotVelocity
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
        highlight.Name = "PalmESP"
        highlight.FillColor = Color3.fromRGB(255, 0, 0)
        highlight.OutlineColor = Color3.fromRGB(255, 255, 255)
        highlight.FillTransparency = 0.5
        highlight.OutlineTransparency = 0
        highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
        highlight.Parent = plr.Character
        table.insert(ESPInstances[plr], highlight)
        
        local billboard = Instance.new("BillboardGui")
        billboard.Name = "PalmNameTag"
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
        if p ~= Player then
            if ESPEnabled then
                ApplyESP(p)
            else
                RemoveESP(p)
            end
        end
    end
end

Players.PlayerAdded:Connect(function(p)
    p.CharacterAdded:Connect(function()
        task.wait(1)
        if ESPEnabled then ApplyESP(p) end
    end)
end)

Players.PlayerRemoving:Connect(function(p)
    RemoveESP(p)
end)

for _, p in pairs(Players:GetPlayers()) do
    if p ~= Player then
        p.CharacterAdded:Connect(function()
            task.wait(1)
            if ESPEnabled then ApplyESP(p) end
        end)
    end
end

local function GetPlayerNames()
    local names = {}
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= Player then
            table.insert(names, p.Name)
        end
    end
    return names
end

local MainTab = Window:CreateTab("Movement", 4483362458)
local PlayersTab = Window:CreateTab("Players", 4483362458)
local VisualsTab = Window:CreateTab("Visuals", 4483362458)
local InfoTab = Window:CreateTab("Credits", 4483362458)

-- Movement Section
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
              
              if FlyEnabled then
                  StartFlight()
              end
          end
      else
          local char = Player.Character
          if char and char:FindFirstChild("Humanoid") then
              char.Humanoid.Health = 0
          end
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
      if Player.Character and Player.Character:FindFirstChild("Humanoid") then
          Player.Character.Humanoid.WalkSpeed = Value
      end
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
   Callback = function(Value)
      FlyEnabled = Value
      if Value then
          StartFlight()
      else
          StopFlight()
      end
   end,
})

MainTab:CreateSlider({
   Name = "Flight Speed",
   Range = {10, 300},
   Increment = 5,
   Suffix = "Speed",
   CurrentValue = 50,
   Flag = "FlySpeed",
   Callback = function(Value)
      FlySpeed = Value
   end,
})

MainTab:CreateToggle({
   Name = "Noclip",
   CurrentValue = false,
   Flag = "Noclip",
   Callback = function(Value)
      NoclipEnabled = Value
   end,
})

-- Players Section
PlayersTab:CreateSection("Target Selection")

local PlayerDropdown = PlayersTab:CreateDropdown({
   Name = "Select Player",
   Options = GetPlayerNames(),
   CurrentOption = "",
   MultipleOptions = false,
   Flag = "PlayerSelect",
   Callback = function(Option)
      SelectedPlayer = Option[1]
   end,
})

Players.PlayerAdded:Connect(function()
    PlayerDropdown:Refresh(GetPlayerNames())
end)
Players.PlayerRemoving:Connect(function()
    PlayerDropdown:Refresh(GetPlayerNames())
end)

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

PlayersTab:CreateButton({
   Name = "Spectate",
   Callback = function()
      if SelectedPlayer then
          local target = Players:FindFirstChild(SelectedPlayer)
          if target and target.Character and target.Character:FindFirstChild("Humanoid") then
              workspace.CurrentCamera.CameraSubject = target.Character.Humanoid
          end
      end
   end,
})

PlayersTab:CreateButton({
   Name = "Unspectate",
   Callback = function()
      if Player.Character and Player.Character:FindFirstChild("Humanoid") then
          workspace.CurrentCamera.CameraSubject = Player.Character.Humanoid
      end
   end,
})

PlayersTab:CreateButton({
   Name = "Fling Player",
   Callback = function()
      if SelectedPlayer then
          local target = Players:FindFirstChild(SelectedPlayer)
          if target then
              FlingTarget(target)
          end
      end
   end,
})

-- Visuals Section
VisualsTab:CreateSection("Player ESP")

VisualsTab:CreateToggle({
   Name = "Enable ESP (Name & Highlight)",
   CurrentValue = false,
   Flag = "ESP",
   Callback = function(Value)
      ESPEnabled = Value
      
      if Value and #Players:GetPlayers() > 31 then
          Rayfield:Notify({
             Title = "ESP Limit Reached",
             Content = "Roblox limits Highlights to 31. Some players may not be highlighted.",
             Duration = 5,
             Image = 4483362458,
          })
      end
      
      RefreshAllESP()
   end,
})

VisualsTab:CreateSection("Environment")

VisualsTab:CreateToggle({
   Name = "Fullbright",
   CurrentValue = false,
   Flag = "FB",
   Callback = function(Value)
      if Value then
          game:GetService("Lighting").Brightness = 2
          game:GetService("Lighting").ClockTime = 14
          game:GetService("Lighting").GlobalShadows = false
      else
          game:GetService("Lighting").Brightness = 1
          game:GetService("Lighting").GlobalShadows = true
      end
   end,
})

-- Info Section
InfoTab:CreateLabel("Palm-Script v1.0")
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
    
    if FlyEnabled then
        StartFlight()
    end
    
    if not InvincibilityEnabled then
        workspace.CurrentCamera.CameraSubject = hum
    end
end)

Rayfield:Notify({
   Title = "Palm-Script Loaded",
   Content = "Welcome to Palm-Script!",
   Duration = 3,
   Image = 4483362458,
})
