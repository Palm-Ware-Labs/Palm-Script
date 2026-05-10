local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TeleportService = game:GetService("TeleportService")
local GuiService = game:GetService("GuiService")
local HttpService = game:GetService("HttpService")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local Player = Players.LocalPlayer

local function create(className, properties)
    local inst = Instance.new(className)
    for k, v in pairs(properties) do inst[k] = v end
    return inst
end

local function tween(obj, props, time)
    TweenService:Create(obj, TweenInfo.new(time or 0.2, Enum.EasingStyle.Sine, Enum.EasingDirection.Out), props):Play()
end

local Icons = {
    Close = "rbxassetid://73433330733472",
    PalmTree = "rbxassetid://90776422052941" 
}

local UI = {}
UI.Theme = {
    Main = Color3.fromRGB(22, 22, 24),
    Container = Color3.fromRGB(30, 30, 34),
    Element = Color3.fromRGB(35, 35, 40),
    Hover = Color3.fromRGB(45, 45, 50),
    Accent = Color3.fromRGB(255, 255, 255),
    Text = Color3.fromRGB(255, 255, 255),
    SubText = Color3.fromRGB(170, 170, 170),
    DarkText = Color3.fromRGB(100, 100, 100)
}

function UI:CreateWindow(config)
    local targetGui = pcall(function() return CoreGui.Name end) and CoreGui or Player:WaitForChild("PlayerGui")
    if targetGui:FindFirstChild("PalmUI") then targetGui.PalmUI:Destroy() end

    local ScreenGui = create("ScreenGui", {Name = "PalmUI", Parent = targetGui, ResetOnSpawn = false})
    
    local MainFrame = create("Frame", {
        Name = "Main", 
        Parent = ScreenGui, 
        Size = UDim2.new(0, 600, 0, 400), 
        Position = UDim2.new(0.5, -300, 0.5, -200), 
        BackgroundColor3 = UI.Theme.Main, 
        ClipsDescendants = true
    })
    create("UICorner", {Parent = MainFrame, CornerRadius = UDim.new(0, 10)})

    local TopBar = create("Frame", {Parent = MainFrame, Size = UDim2.new(1, 0, 0, 40), BackgroundTransparency = 1})
    
    local TitleIcon = create("ImageLabel", {
        Parent = TopBar,
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(0, 15, 0.5, -10),
        BackgroundTransparency = 1,
        Image = Icons.PalmTree,
        ImageColor3 = UI.Theme.Text
    })
    
    local Title = create("TextLabel", {
        Parent = TopBar, 
        Size = UDim2.new(0, 100, 1, 0), 
        Position = UDim2.new(0, 42, 0, 0), -- Shifted right to accommodate the icon
        BackgroundTransparency = 1, 
        Text = config.Name, 
        Font = Enum.Font.GothamBold, 
        TextSize = 16, 
        TextColor3 = UI.Theme.Text, 
        TextXAlignment = Enum.TextXAlignment.Left
    })
    
    local CloseBtn = create("ImageButton", {
        Parent = TopBar,
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(1, -30, 0.5, -10),
        BackgroundTransparency = 1,
        Image = Icons.Close,
        ImageColor3 = UI.Theme.SubText
    })

    local TabContainer = create("ScrollingFrame", {
        Parent = TopBar, 
        Size = UDim2.new(1, -185, 0, 28), 
        Position = UDim2.new(0, 145, 0.5, -14), 
        BackgroundColor3 = UI.Theme.Container,
        BackgroundTransparency = 0, 
        ScrollBarThickness = 0, 
        CanvasSize = UDim2.new(0, 0, 0, 0), 
        AutomaticCanvasSize = Enum.AutomaticSize.X, 
        ScrollingDirection = Enum.ScrollingDirection.X
    })
    create("UICorner", {Parent = TabContainer, CornerRadius = UDim.new(0, 6)})

    create("UIListLayout", {
        Parent = TabContainer, 
        FillDirection = Enum.FillDirection.Horizontal, 
        SortOrder = Enum.SortOrder.LayoutOrder, 
        Padding = UDim.new(0, 4), 
        VerticalAlignment = Enum.VerticalAlignment.Center
    })
    create("UIPadding", {Parent = TabContainer, PaddingLeft = UDim.new(0, 4), PaddingRight = UDim.new(0, 4)})

    local ContentContainer = create("Frame", {
        Parent = MainFrame, 
        Size = UDim2.new(1, -20, 1, -55), 
        Position = UDim2.new(0, 10, 0, 45), 
        BackgroundTransparency = 1
    })

    CloseBtn.MouseEnter:Connect(function() tween(CloseBtn, {ImageColor3 = Color3.fromRGB(255, 80, 80)}) end)
    CloseBtn.MouseLeave:Connect(function() tween(CloseBtn, {ImageColor3 = UI.Theme.SubText}) end)
    CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

    local dragging, dragInput, dragStart, startPos
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true dragStart = input.Position startPos = MainFrame.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    TopBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)

    local Window = {Tabs = {}, CurrentTab = nil, ScreenGui = ScreenGui}

    function Window:CreateTab(name)
        local TabBtn = create("TextButton", {
            Parent = TabContainer, 
            Size = UDim2.new(0, 0, 1, -8), 
            AutomaticSize = Enum.AutomaticSize.X,
            BackgroundColor3 = UI.Theme.Accent, 
            BackgroundTransparency = 1,
            Text = "", 
            AutoButtonColor = false
        })
        create("UICorner", {Parent = TabBtn, CornerRadius = UDim.new(1, 0)}) 
        create("UIPadding", {Parent = TabBtn, PaddingLeft = UDim.new(0, 16), PaddingRight = UDim.new(0, 16)})
        
        local TabText = create("TextLabel", {
            Parent = TabBtn,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            Text = name,
            Font = Enum.Font.GothamSemibold,
            TextSize = 13,
            TextColor3 = UI.Theme.SubText
        })

        local ContentScroll = create("ScrollingFrame", {
            Parent = ContentContainer, 
            Size = UDim2.new(1, 0, 1, 0), 
            BackgroundTransparency = 1, 
            ScrollBarThickness = 2, 
            ScrollBarImageColor3 = UI.Theme.Accent, 
            Visible = false, 
            AutomaticCanvasSize = Enum.AutomaticSize.Y, 
            CanvasSize = UDim2.new(0, 0, 0, 0)
        })
        create("UIPadding", {Parent = ContentScroll, PaddingTop = UDim.new(0, 5), PaddingLeft = UDim.new(0, 5), PaddingRight = UDim.new(0, 5), PaddingBottom = UDim.new(0, 10)})
        create("UIListLayout", {Parent = ContentScroll, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 8)})

        TabBtn.MouseEnter:Connect(function() 
            if Window.CurrentTab ~= name then 
                tween(TabText, {TextColor3 = UI.Theme.Text})
            end 
        end)
        
        TabBtn.MouseLeave:Connect(function() 
            if Window.CurrentTab ~= name then 
                tween(TabText, {TextColor3 = UI.Theme.SubText})
            end 
        end)

        TabBtn.MouseButton1Click:Connect(function()
            for tName, tData in pairs(Window.Tabs) do
                tData.Content.Visible = false
                tween(tData.Btn, {BackgroundTransparency = 1})
                tween(tData.Text, {TextColor3 = UI.Theme.SubText})
            end
            ContentScroll.Visible = true
            tween(TabBtn, {BackgroundTransparency = 0})
            tween(TabText, {TextColor3 = UI.Theme.Main})
            Window.CurrentTab = name
        end)

        Window.Tabs[name] = {Btn = TabBtn, Text = TabText, Content = ContentScroll}

        if not Window.CurrentTab then 
            ContentScroll.Visible = true
            TabBtn.BackgroundTransparency = 0
            TabText.TextColor3 = UI.Theme.Main
            Window.CurrentTab = name
        end

        local Tab = {}
        function Tab:CreateSection(secName)
            local SecFrame = create("Frame", {Parent = ContentScroll, Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1})
            create("TextLabel", {Parent = SecFrame, Size = UDim2.new(1, -25, 1, 0), Position = UDim2.new(0, 5, 0, 0), BackgroundTransparency = 1, Text = secName, Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = UI.Theme.Accent, TextXAlignment = Enum.TextXAlignment.Left})
        end

        function Tab:CreateInput(iConfig)
            local InpFrame = create("Frame", {Parent = ContentScroll, Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = UI.Theme.Container})
            create("UICorner", {Parent = InpFrame, CornerRadius = UDim.new(0, 6)})
            
            create("TextLabel", {Parent = InpFrame, Size = UDim2.new(0.4, 0, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = iConfig.Name, Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = UI.Theme.Text, TextXAlignment = Enum.TextXAlignment.Left})
            
            local TextBox = create("TextBox", {Parent = InpFrame, Size = UDim2.new(0.5, -20, 0, 30), Position = UDim2.new(0.5, 10, 0.5, -15), BackgroundColor3 = UI.Theme.Element, Text = "", PlaceholderText = iConfig.Placeholder or "", Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = UI.Theme.Text, ClearTextOnFocus = false})
            create("UICorner", {Parent = TextBox, CornerRadius = UDim.new(0, 4)})
            
            TextBox.FocusLost:Connect(function()
                if iConfig.Callback then iConfig.Callback(TextBox.Text) end
            end)
        end

        function Tab:CreateDashboard()
            local HeaderFrame = create("Frame", {Parent = ContentScroll, Size = UDim2.new(1, 0, 0, 80), BackgroundColor3 = UI.Theme.Container})
            create("UICorner", {Parent = HeaderFrame, CornerRadius = UDim.new(0, 6)})
            
            local PlaceLabel = create("TextLabel", {Parent = HeaderFrame, Size = UDim2.new(0.5, 0, 0.33, 0), Position = UDim2.new(0, 10, 0, 5), BackgroundTransparency = 1, Text = "Place ID: " .. game.PlaceId, Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = UI.Theme.Text, TextXAlignment = Enum.TextXAlignment.Left})
            
            local PlayerCountLabel = create("TextLabel", {Parent = HeaderFrame, Size = UDim2.new(0.5, 0, 0.33, 0), Position = UDim2.new(0, 10, 0.33, 0), BackgroundTransparency = 1, Text = "Players: " .. #Players:GetPlayers(), Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = UI.Theme.SubText, TextXAlignment = Enum.TextXAlignment.Left})
            
            local UptimeLabel = create("TextLabel", {Parent = HeaderFrame, Size = UDim2.new(0.5, 0, 0.33, 0), Position = UDim2.new(0, 10, 0.66, 0), BackgroundTransparency = 1, Text = "Uptime: 00:00:00", Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = UI.Theme.SubText, TextXAlignment = Enum.TextXAlignment.Left})

            task.spawn(function()
                while task.wait(1) do
                    if not UptimeLabel.Parent then break end
                    local diff = math.floor(workspace.DistributedGameTime)
                    local h = math.floor(diff / 3600)
                    local m = math.floor((diff % 3600) / 60)
                    local s = diff % 60
                    UptimeLabel.Text = string.format("Uptime: %02d:%02d:%02d", h, m, s)
                end
            end)
            
            Players.PlayerAdded:Connect(function() PlayerCountLabel.Text = "Players: " .. #Players:GetPlayers() end)
            Players.PlayerRemoving:Connect(function() PlayerCountLabel.Text = "Players: " .. #Players:GetPlayers() end)

            create("TextLabel", {Parent = ContentScroll, Size = UDim2.new(1, 0, 0, 20), BackgroundTransparency = 1, Text = "Friends Playing", Font = Enum.Font.GothamBold, TextSize = 12, TextColor3 = UI.Theme.Accent, TextXAlignment = Enum.TextXAlignment.Left})
            
            local FriendsContainer = create("Frame", {Parent = ContentScroll, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1})
            create("UIListLayout", {Parent = FriendsContainer, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6)})

            local function updateFriends()
                for _, child in ipairs(FriendsContainer:GetChildren()) do
                    if child:IsA("Frame") then child:Destroy() end
                end

                local success, friends = pcall(function() return Player:GetFriendsOnline(200) end)
                local foundPlaying = false

                if success and friends then
                    for _, friend in ipairs(friends) do
                        if friend.LocationType == 4 then 
                            foundPlaying = true
                            local fRow = create("Frame", {Parent = FriendsContainer, Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = UI.Theme.Container})
                            create("UICorner", {Parent = fRow, CornerRadius = UDim.new(0, 6)})

                            create("TextLabel", {Parent = fRow, Size = UDim2.new(0.4, 0, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = friend.UserName, Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = UI.Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd})
                            create("TextLabel", {Parent = fRow, Size = UDim2.new(0.4, -20, 1, 0), Position = UDim2.new(0.4, 10, 0, 0), BackgroundTransparency = 1, Text = friend.LastLocation, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = UI.Theme.SubText, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd})

                            local JoinBtn = create("TextButton", {Parent = fRow, Size = UDim2.new(0, 65, 0, 26), Position = UDim2.new(1, -75, 0.5, -13), BackgroundColor3 = UI.Theme.Element, Text = "Join", Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = UI.Theme.Text})
                            create("UICorner", {Parent = JoinBtn, CornerRadius = UDim.new(0, 4)})
                            
                            JoinBtn.MouseEnter:Connect(function() tween(JoinBtn, {BackgroundColor3 = UI.Theme.Hover}) end)
                            JoinBtn.MouseLeave:Connect(function() tween(JoinBtn, {BackgroundColor3 = UI.Theme.Element}) end)

                            JoinBtn.MouseButton1Click:Connect(function()
                                Window:Notify({Title = "Joining", Content = "Attempting to join " .. friend.UserName .. "...", Duration = 3})
                                local s, e = pcall(function()
                                    TeleportService:TeleportToPlaceInstance(friend.PlaceId, friend.GameId, Player)
                                end)
                                if not s then
                                    Window:Notify({Title = "Error", Content = "Failed to join: " .. tostring(e), Duration = 3})
                                end
                            end)
                        end
                    end
                end

                if not foundPlaying then
                    local emptyRow = create("Frame", {Parent = FriendsContainer, Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = UI.Theme.Container})
                    create("UICorner", {Parent = emptyRow, CornerRadius = UDim.new(0, 6)})
                    create("TextLabel", {Parent = emptyRow, Size = UDim2.new(1, -20, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = "No friends are currently playing a game.", Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = UI.Theme.SubText, TextXAlignment = Enum.TextXAlignment.Center})
                end
            end

            updateFriends()

            local RefreshBtn = create("TextButton", {Parent = ContentScroll, Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = UI.Theme.Container, Text = "Refresh Friends List", Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = UI.Theme.Text})
            create("UICorner", {Parent = RefreshBtn, CornerRadius = UDim.new(0, 6)})
            RefreshBtn.MouseButton1Click:Connect(updateFriends)
        end

        function Tab:CreatePlayerList()
            local Container = create("Frame", {Parent = ContentScroll, Size = UDim2.new(1, 0, 0, 0), AutomaticSize = Enum.AutomaticSize.Y, BackgroundTransparency = 1})
            create("UIListLayout", {Parent = Container, SortOrder = Enum.SortOrder.Name, Padding = UDim.new(0, 6)})
            
            local function updateList()
                for _, child in ipairs(Container:GetChildren()) do
                    if child:IsA("Frame") then child:Destroy() end
                end
                for _, plr in ipairs(Players:GetPlayers()) do
                    if plr == Player then continue end
                    
                    local pRow = create("Frame", {Parent = Container, Size = UDim2.new(1, 0, 0, 50), BackgroundColor3 = UI.Theme.Container, Name = plr.Name})
                    create("UICorner", {Parent = pRow, CornerRadius = UDim.new(0, 6)})
                    
                    local pfp = create("ImageLabel", {Parent = pRow, Size = UDim2.new(0, 40, 0, 40), Position = UDim2.new(0, 5, 0.5, -20), BackgroundColor3 = UI.Theme.Element})
                    create("UICorner", {Parent = pfp, CornerRadius = UDim.new(0, 6)})
                    task.spawn(function()
                        local content = Players:GetUserThumbnailAsync(plr.UserId, Enum.ThumbnailType.HeadShot, Enum.ThumbnailSize.Size48x48)
                        pfp.Image = content
                    end)
                    
                    create("TextLabel", {Parent = pRow, Size = UDim2.new(0, 150, 1, 0), Position = UDim2.new(0, 55, 0, 0), BackgroundTransparency = 1, Text = plr.Name, Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = UI.Theme.Text, TextXAlignment = Enum.TextXAlignment.Left, TextTruncate = Enum.TextTruncate.AtEnd})
                    
                    local HealthLabel = create("TextLabel", {Parent = pRow, Size = UDim2.new(0, 60, 1, 0), Position = UDim2.new(0, 205, 0, 0), BackgroundTransparency = 1, Text = "N/A HP", Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = UI.Theme.SubText, TextXAlignment = Enum.TextXAlignment.Left})
                    
                    task.spawn(function()
                        while pRow.Parent do
                            if plr.Character and plr.Character:FindFirstChild("Humanoid") then
                                local hp = math.floor(plr.Character.Humanoid.Health)
                                local maxHp = math.floor(plr.Character.Humanoid.MaxHealth)
                                HealthLabel.Text = hp .. " / " .. maxHp .. " HP"
                                if hp <= 0 then HealthLabel.TextColor3 = Color3.fromRGB(255, 80, 80)
                                elseif hp < (maxHp / 2) then HealthLabel.TextColor3 = Color3.fromRGB(255, 200, 80)
                                else HealthLabel.TextColor3 = Color3.fromRGB(80, 255, 80) end
                            else
                                HealthLabel.Text = "No Char"
                                HealthLabel.TextColor3 = UI.Theme.SubText
                            end
                            task.wait(0.5)
                        end
                    end)

                    local ActionsFrame = create("Frame", {Name = "Actions", Parent = pRow, Size = UDim2.new(0, 210, 1, 0), Position = UDim2.new(1, -215, 0, 0), BackgroundTransparency = 1})
                    create("UIListLayout", {Parent = ActionsFrame, FillDirection = Enum.FillDirection.Horizontal, SortOrder = Enum.SortOrder.LayoutOrder, Padding = UDim.new(0, 6), HorizontalAlignment = Enum.HorizontalAlignment.Right, VerticalAlignment = Enum.VerticalAlignment.Center})
                    
                    local function createActionBtn(name, btnName, callback)
                        local btn = create("TextButton", {Name = btnName, Parent = ActionsFrame, Size = UDim2.new(0, 65, 0, 30), BackgroundColor3 = UI.Theme.Element, Text = name, Font = Enum.Font.Gotham, TextSize = 12, TextColor3 = UI.Theme.Text, AutoButtonColor = false})
                        create("UICorner", {Parent = btn, CornerRadius = UDim.new(0, 4)})
                        btn.MouseEnter:Connect(function() tween(btn, {BackgroundColor3 = UI.Theme.Hover}) end)
                        btn.MouseLeave:Connect(function() tween(btn, {BackgroundColor3 = UI.Theme.Element}) end)
                        btn.MouseButton1Click:Connect(function() callback(btn) end)
                        return btn
                    end
                    
                    createActionBtn("Teleport", "TeleportBtn", function()
                        if plr and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") and Player.Character and Player.Character:FindFirstChild("HumanoidRootPart") then
                            Player.Character.HumanoidRootPart.CFrame = plr.Character.HumanoidRootPart.CFrame
                        end
                    end)
                    
                    local currentSubject = workspace.CurrentCamera.CameraSubject
                    local isSpectating = currentSubject and (currentSubject == plr.Character or (plr.Character and currentSubject:IsDescendantOf(plr.Character)))
                    local initialSpecText = isSpectating and "Unspectate" or "Spectate"

                    createActionBtn(initialSpecText, "SpectateBtn", function(btn)
                        if btn.Text == "Spectate" then
                            if plr and plr.Character and plr.Character:FindFirstChild("Humanoid") then
                                workspace.CurrentCamera.CameraSubject = plr.Character.Humanoid
                                for _, otherRow in ipairs(Container:GetChildren()) do
                                    if otherRow:IsA("Frame") then
                                        local acts = otherRow:FindFirstChild("Actions")
                                        if acts then
                                            local sBtn = acts:FindFirstChild("SpectateBtn")
                                            if sBtn then sBtn.Text = "Spectate" end
                                        end
                                    end
                                end
                                btn.Text = "Unspectate"
                            end
                        else
                            if Player.Character and Player.Character:FindFirstChild("Humanoid") then
                                workspace.CurrentCamera.CameraSubject = Player.Character.Humanoid
                            end
                            btn.Text = "Spectate"
                        end
                    end)
                    
                    createActionBtn("Fling", "FlingBtn", function()
                        if plr then _G.FlingTargetRef(plr) end
                    end)
                end
            end
            
            updateList()
            Players.PlayerAdded:Connect(updateList)
            Players.PlayerRemoving:Connect(updateList)
        end

        function Tab:CreateToggle(tConfig)
            local TglFrame = create("Frame", {Parent = ContentScroll, Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = UI.Theme.Container})
            create("UICorner", {Parent = TglFrame, CornerRadius = UDim.new(0, 6)})
            
            create("TextLabel", {Parent = TglFrame, Size = UDim2.new(1, -60, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = tConfig.Name, Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = UI.Theme.Text, TextXAlignment = Enum.TextXAlignment.Left})
            
            local TglBtn = create("TextButton", {Parent = TglFrame, Size = UDim2.new(1, 0, 1, 0), BackgroundTransparency = 1, Text = ""})
            local TglBg = create("Frame", {Parent = TglFrame, Size = UDim2.new(0, 40, 0, 20), Position = UDim2.new(1, -50, 0.5, -10), BackgroundColor3 = tConfig.CurrentValue and UI.Theme.Accent or UI.Theme.Element})
            create("UICorner", {Parent = TglBg, CornerRadius = UDim.new(1, 0)})
            local TglCirc = create("Frame", {Parent = TglBg, Size = UDim2.new(0, 16, 0, 16), Position = tConfig.CurrentValue and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8), BackgroundColor3 = tConfig.CurrentValue and UI.Theme.Main or UI.Theme.Text})
            create("UICorner", {Parent = TglCirc, CornerRadius = UDim.new(1, 0)})

            local state = tConfig.CurrentValue or false
            TglBtn.MouseButton1Click:Connect(function()
                state = not state
                tween(TglBg, {BackgroundColor3 = state and UI.Theme.Accent or UI.Theme.Element})
                tween(TglCirc, {Position = state and UDim2.new(1, -18, 0.5, -8) or UDim2.new(0, 2, 0.5, -8), BackgroundColor3 = state and UI.Theme.Main or UI.Theme.Text})
                if tConfig.Callback then tConfig.Callback(state) end
            end)
        end

        function Tab:CreateSlider(sConfig)
            local SldFrame = create("Frame", {Parent = ContentScroll, Size = UDim2.new(1, 0, 0, 50), BackgroundColor3 = UI.Theme.Container})
            create("UICorner", {Parent = SldFrame, CornerRadius = UDim.new(0, 6)})
            local sVal = sConfig.CurrentValue or sConfig.Range[1]
            
            create("TextLabel", {Parent = SldFrame, Size = UDim2.new(1, -20, 0, 20), Position = UDim2.new(0, 10, 0, 5), BackgroundTransparency = 1, Text = sConfig.Name, Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = UI.Theme.Text, TextXAlignment = Enum.TextXAlignment.Left})
            local ValLabel = create("TextLabel", {Parent = SldFrame, Size = UDim2.new(1, -20, 0, 20), Position = UDim2.new(0, 10, 0, 5), BackgroundTransparency = 1, Text = tostring(sVal) .. (sConfig.Suffix and " " .. sConfig.Suffix or ""), Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = UI.Theme.SubText, TextXAlignment = Enum.TextXAlignment.Right})
            
            local SldBg = create("Frame", {Parent = SldFrame, Size = UDim2.new(1, -20, 0, 6), Position = UDim2.new(0, 10, 1, -15), BackgroundColor3 = UI.Theme.Element})
            create("UICorner", {Parent = SldBg, CornerRadius = UDim.new(1, 0)})
            local SldFill = create("Frame", {Parent = SldBg, Size = UDim2.new((sVal - sConfig.Range[1]) / (sConfig.Range[2] - sConfig.Range[1]), 0, 1, 0), BackgroundColor3 = UI.Theme.Accent})
            create("UICorner", {Parent = SldFill, CornerRadius = UDim.new(1, 0)})
            local SldBtn = create("TextButton", {Parent = SldBg, Size = UDim2.new(1, 0, 1, 10), Position = UDim2.new(0, 0, 0, -5), BackgroundTransparency = 1, Text = ""})

            local draggingSld = false
            local function updateSld(input)
                local pos = math.clamp((input.Position.X - SldBg.AbsolutePosition.X) / SldBg.AbsoluteSize.X, 0, 1)
                local value = pos * (sConfig.Range[2] - sConfig.Range[1]) + sConfig.Range[1]
                value = math.floor(value / (sConfig.Increment or 1) + 0.5) * (sConfig.Increment or 1)
                value = math.clamp(value, sConfig.Range[1], sConfig.Range[2])
                local exactPos = (value - sConfig.Range[1]) / (sConfig.Range[2] - sConfig.Range[1])
                tween(SldFill, {Size = UDim2.new(exactPos, 0, 1, 0)}, 0.1)
                ValLabel.Text = tostring(value) .. (sConfig.Suffix and " " .. sConfig.Suffix or "")
                if sConfig.Callback then sConfig.Callback(value) end
            end

            SldBtn.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingSld = true updateSld(input) end
            end)
            SldBtn.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then draggingSld = false end
            end)
            UserInputService.InputChanged:Connect(function(input)
                if draggingSld and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then updateSld(input) end
            end)
        end

        function Tab:CreateButton(bConfig)
            local BtnFrame = create("TextButton", {Parent = ContentScroll, Size = UDim2.new(1, 0, 0, 40), BackgroundColor3 = UI.Theme.Container, Text = "", AutoButtonColor = false})
            create("UICorner", {Parent = BtnFrame, CornerRadius = UDim.new(0, 6)})
            
            create("TextLabel", {Parent = BtnFrame, Size = UDim2.new(1, 0, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = bConfig.Name, Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = UI.Theme.Text, TextXAlignment = Enum.TextXAlignment.Left})
            
            BtnFrame.MouseEnter:Connect(function() tween(BtnFrame, {BackgroundColor3 = UI.Theme.Hover}) end)
            BtnFrame.MouseLeave:Connect(function() tween(BtnFrame, {BackgroundColor3 = UI.Theme.Container}) end)
            BtnFrame.MouseButton1Down:Connect(function() tween(BtnFrame, {BackgroundColor3 = UI.Theme.Element}) end)
            BtnFrame.MouseButton1Up:Connect(function() tween(BtnFrame, {BackgroundColor3 = UI.Theme.Hover}) if bConfig.Callback then bConfig.Callback() end end)
        end

        function Tab:CreateLabel(text)
            local LblFrame = create("Frame", {Parent = ContentScroll, Size = UDim2.new(1, 0, 0, 30), BackgroundColor3 = UI.Theme.Container})
            create("UICorner", {Parent = LblFrame, CornerRadius = UDim.new(0, 6)})
            create("TextLabel", {Parent = LblFrame, Size = UDim2.new(1, -20, 1, 0), Position = UDim2.new(0, 10, 0, 0), BackgroundTransparency = 1, Text = text, Font = Enum.Font.Gotham, TextSize = 14, TextColor3 = UI.Theme.SubText, TextXAlignment = Enum.TextXAlignment.Left})
        end

        return Tab
    end

    function Window:Notify(nConfig)
        local NGui = targetGui:FindFirstChild("PalmNotify")
        if not NGui then
            NGui = create("ScreenGui", {Name = "PalmNotify", Parent = targetGui, ResetOnSpawn = false})
        end
        local NFrame = create("Frame", {Parent = NGui, Size = UDim2.new(0, 250, 0, 70), Position = UDim2.new(1, 10, 1, -80), BackgroundColor3 = UI.Theme.Container})
        create("UICorner", {Parent = NFrame, CornerRadius = UDim.new(0, 6)})
        create("Frame", {Parent = NFrame, Size = UDim2.new(0, 4, 1, 0), BackgroundColor3 = UI.Theme.Accent})
        create("TextLabel", {Parent = NFrame, Size = UDim2.new(1, -15, 0, 25), Position = UDim2.new(0, 10, 0, 5), BackgroundTransparency = 1, Text = nConfig.Title or "Notification", Font = Enum.Font.GothamBold, TextSize = 14, TextColor3 = UI.Theme.Text, TextXAlignment = Enum.TextXAlignment.Left})
        create("TextLabel", {Parent = NFrame, Size = UDim2.new(1, -15, 0, 30), Position = UDim2.new(0, 10, 0, 30), BackgroundTransparency = 1, Text = nConfig.Content or "", Font = Enum.Font.Gotham, TextSize = 13, TextColor3 = UI.Theme.SubText, TextXAlignment = Enum.TextXAlignment.Left, TextWrapped = true})
        
        local currentY = 10
        for _, v in pairs(NGui:GetChildren()) do
            if v ~= NFrame then tween(v, {Position = UDim2.new(1, -260, 1, -currentY - 80)}) currentY = currentY + 80 end
        end
        tween(NFrame, {Position = UDim2.new(1, -260, 1, -currentY - 70)})
        
        task.delay(nConfig.Duration or 3, function()
            tween(NFrame, {Position = UDim2.new(1, 10, 1, NFrame.Position.Y.Offset)})
            task.wait(0.3)
            NFrame:Destroy()
        end)
    end

    return Window
end

local Window = UI:CreateWindow({Name = "Palm-Script"})

local FlyEnabled = false 
local FlySpeed = 50 
local SpeedValue = 16 
local JumpValue = 50 
local NoclipEnabled = false 
local InvincibilityEnabled = false
local ESPEnabled = false 
local ESPInstances = {} 
local flyBV, flyBG 
local AutoRejoinEnabled = false

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
    flyBG = create("BodyGyro", {Parent = root, P = 9e4, MaxTorque = Vector3.new(9e9, 9e9, 9e9)}) 
    flyBV = create("BodyVelocity", {Parent = root, MaxForce = Vector3.new(9e9, 9e9, 9e9)}) 
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
        end 
        StopFlight() 
    end) 
end

RunService.Stepped:Connect(function() 
    if NoclipEnabled and Player.Character then
        for _, part in pairs(Player.Character:GetDescendants()) do 
            if part:IsA("BasePart") then part.CanCollide = false end 
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
    local attachment = create("Attachment", {Parent = root}) 
    local FlingVelocity = create("AngularVelocity", {Attachment0 = attachment, AngularVelocity = Vector3.new(99999, 99999, 99999), MaxTorque = math.huge, Parent = root}) 
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
_G.FlingTargetRef = FlingTarget 

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
        local highlight = create("Highlight", {FillColor = Color3.fromRGB(255, 0, 0), OutlineColor = Color3.fromRGB(255, 255, 255), Parent = plr.Character})
        table.insert(ESPInstances[plr], highlight) 
        local billboard = create("BillboardGui", {AlwaysOnTop = true, Size = UDim2.new(0, 100, 0, 50), StudsOffset = Vector3.new(0, 3, 0), Parent = plr.Character:FindFirstChild("Head") or plr.Character:FindFirstChild("HumanoidRootPart")}) 
        create("TextLabel", {Parent = billboard, BackgroundTransparency = 1, Size = UDim2.new(1, 0, 1, 0), Text = plr.Name, TextColor3 = Color3.fromRGB(255, 255, 255), TextStrokeTransparency = 0, TextSize = 14, Font = Enum.Font.GothamBold})
        table.insert(ESPInstances[plr], billboard) 
    end 
end

local function RefreshAllESP() 
    for _, p in pairs(Players:GetPlayers()) do 
        if p ~= Player then 
            if ESPEnabled then ApplyESP(p) else RemoveESP(p) end 
        end 
    end 
end

Players.PlayerAdded:Connect(function(p) 
    p.CharacterAdded:Connect(function()
        task.wait(1) 
        if ESPEnabled then ApplyESP(p) end 
    end) 
end)
Players.PlayerRemoving:Connect(function(p) RemoveESP(p) end)

Player.Idled:Connect(function() 
    VirtualUser:Button2Down(Vector2.new(0,0), workspace.CurrentCamera.CFrame) 
    task.wait(1)
    VirtualUser:Button2Up(Vector2.new(0,0), workspace.CurrentCamera.CFrame) 
end)

GuiService.ErrorMessageChanged:Connect(function() 
    if AutoRejoinEnabled then
        TeleportService:TeleportToPlaceInstance(game.PlaceId, game.JobId, Player) 
    end
end)

-- Main Tabs Setup
local DashboardTab = Window:CreateTab("Dashboard")
local PlayersTab = Window:CreateTab("Players") 
local VisualsTab = Window:CreateTab("Visuals") 
local MiscTab = Window:CreateTab("Misc") 
local NDSTab = game.PlaceId == 189707 and Window:CreateTab("NDS") or nil 

DashboardTab:CreateSection("Server Overview")
DashboardTab:CreateDashboard()

PlayersTab:CreateSection("Player List")
PlayersTab:CreatePlayerList()

VisualsTab:CreateSection("Player ESP") 
VisualsTab:CreateToggle({Name = "Enable ESP", CurrentValue = false, Callback = function(Value) 
    ESPEnabled = Value
    RefreshAllESP() 
end}) 

VisualsTab:CreateSection("Environment")
VisualsTab:CreateToggle({Name = "Fullbright", CurrentValue = false, Callback = function(Value) 
    game:GetService("Lighting").Brightness = Value and 2 or 1
    game:GetService("Lighting").ClockTime = Value and 14 or 12
    game:GetService("Lighting").GlobalShadows = not Value 
end})

MiscTab:CreateSection("Character Physics") 
MiscTab:CreateToggle({Name = "God Mode", CurrentValue = false, Callback = function(Value) 
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
            if char:FindFirstChild("Animate") then 
                char.Animate.Disabled = true
                char.Animate.Disabled = false 
            end 
        end 
    else 
        if Player.Character and Player.Character:FindFirstChild("Humanoid") then
            Player.Character.Humanoid.Health = 0 
        end 
    end 
end}) 

MiscTab:CreateSlider({Name = "WalkSpeed", Range = {16, 500}, Increment = 1, Suffix = "Speed", CurrentValue = 16, Callback = function(Value) 
    SpeedValue = Value 
    if Player.Character and Player.Character:FindFirstChild("Humanoid") then
        Player.Character.Humanoid.WalkSpeed = Value 
    end 
end}) 

MiscTab:CreateSlider({Name = "Jump Power", Range = {50, 1000}, Increment = 1, Suffix = "Power", CurrentValue = 50, Callback = function(Value) 
    JumpValue = Value 
    if Player.Character and Player.Character:FindFirstChild("Humanoid") then
        Player.Character.Humanoid.UseJumpPower = true
        Player.Character.Humanoid.JumpPower = Value 
    end 
end})

MiscTab:CreateSection("Advanced Movement") 
MiscTab:CreateToggle({Name = "Enable Flight", CurrentValue = false, Callback = function(Value) 
    FlyEnabled = Value 
    if Value then StartFlight() else StopFlight() end 
end}) 

MiscTab:CreateSlider({Name = "Flight Speed", Range = {10, 300}, Increment = 5, Suffix = "Speed", CurrentValue = 50, Callback = function(Value) 
    FlySpeed = Value 
end})

MiscTab:CreateToggle({Name = "Noclip", CurrentValue = false, Callback = function(Value) 
    NoclipEnabled = Value 
    if not Value and Player.Character then 
        for _, part in pairs(Player.Character:GetDescendants()) do 
            if part:IsA("BasePart") then part.CanCollide = true end 
        end 
    end 
end})

MiscTab:CreateSection("Utility") 
MiscTab:CreateButton({Name = "Infinite Yield", Callback = function()
    loadstring(game:HttpGet('https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source'))()
end}) 

MiscTab:CreateToggle({Name = "Auto Rejoin", CurrentValue = false, Callback = function(Value) 
    AutoRejoinEnabled = Value 
end}) 

MiscTab:CreateButton({Name = "Server Hop", Callback = function() 
    local servers = {} 
    local req = (request or http_request or syn.request)({Url = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Asc&limit=100"}) 
    if req and req.StatusCode == 200 then 
        local body = HttpService:JSONDecode(req.Body) 
        for _, v in pairs(body.data) do 
            if v.playing < v.maxPlayers and v.id ~= game.JobId then
                table.insert(servers, v.id) 
            end 
        end 
        if #servers > 0 then
            TeleportService:TeleportToPlaceInstance(game.PlaceId, servers[math.random(1, #servers)], Player) 
        end 
    end 
end})

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
        if SuperRingEnabled and RetainPart(part) then superRingParts[part] = true end 
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
                local targetPos = Vector3.new(center.X + math.cos(angle) * SuperRingRadius, center.Y + SuperRingHeight, center.Z + math.sin(angle) * SuperRingRadius) 
                part.AssemblyLinearVelocity = (targetPos - part.Position) * SuperRingStrength 
                part.AssemblyAngularVelocity = Vector3.new(SuperRingStrength * 0.5, SuperRingStrength * 0.5, SuperRingStrength * 0.5) 
            end 
        end 
    end)

    NDSTab:CreateSection("Natural Disaster Survival") 
    NDSTab:CreateToggle({Name = "Super Ring", CurrentValue = false, Callback = function(Value) 
        SuperRingEnabled = Value 
        if Value then ScanForParts() else superRingParts = {} end 
    end})
    
    NDSTab:CreateSlider({Name = "Radius", Range = {5, 200}, Increment = 1, CurrentValue = 50, Callback = function(Value) SuperRingRadius = Value end})
    NDSTab:CreateSlider({Name = "Height Offset", Range = {-50, 100}, Increment = 1, CurrentValue = 5, Callback = function(Value) SuperRingHeight = Value end})
    NDSTab:CreateSlider({Name = "Rotation Speed", Range = {1, 50}, Increment = 1, CurrentValue = 10, Callback = function(Value) SuperRingSpeed = Value end})
    NDSTab:CreateSlider({Name = "Strength", Range = {10, 300}, Increment = 5, CurrentValue = 60, Callback = function(Value) SuperRingStrength = Value end})
end

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

Window:Notify({Title = "Palm-Script Loaded", Content = "Welcome to Palm-Script!", Duration = 3})
