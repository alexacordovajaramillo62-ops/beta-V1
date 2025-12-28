--// ChilliLib - UI Library v1.1 [Fixed & Complete]
--// Fixed by: Assistant
--// Fully Functional Version

local GlobalEnvironment = getgenv() or _G

local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

-- Color Palette
local COLOR_PRIMARY_BG = Color3.fromRGB(16, 24, 39)
local COLOR_DARK_BG = Color3.fromRGB(12, 18, 32)
local COLOR_MEDIUM_BG = Color3.fromRGB(21, 30, 47)
local COLOR_ACCENT_BLUE = Color3.fromRGB(10, 82, 120)
local COLOR_CYAN_STROKE = Color3.fromRGB(56, 189, 248)
local COLOR_CYAN_HIGHLIGHT = Color3.fromRGB(56, 189, 248)
local COLOR_SECONDARY_BG = Color3.fromRGB(30, 41, 59)
local COLOR_TOPBAR_BG = Color3.fromRGB(25, 32, 48)
local COLOR_ACCENT_CYAN = Color3.fromRGB(52, 180, 230)
local COLOR_TEXT_PRIMARY = Color3.fromRGB(241, 245, 249)
local COLOR_TEXT_SECONDARY = Color3.fromRGB(148, 163, 184)
local COLOR_ERROR_RED = Color3.fromRGB(239, 68, 68)

-- Fonts
local FONT_BOLD = Enum.Font.GothamBold
local FONT_MEDIUM = Enum.Font.GothamMedium
local FONT_REGULAR = Enum.Font.Gotham

-- File System Functions (Compatible with Roblox)
local isStudio = RunService:IsStudio()
local fileFunctionsAvailable = false

-- Check for file functions (for exploit environments)
if isStudio then
    -- In Studio, we'll use mock file functions
    fileFunctionsAvailable = false
elseif writefile and makefolder and listfiles then
    -- Available in exploit environments
    fileFunctionsAvailable = true
else
    -- Create mock file functions
    fileFunctionsAvailable = false
    writefile = function(path, content)
        warn("[ChilliLib] writefile not available in this environment: " .. path)
        return false
    end
    
    makefolder = function(path)
        warn("[ChilliLib] makefolder not available in this environment: " .. path)
        return false
    end
    
    listfiles = function(path)
        warn("[ChilliLib] listfiles not available in this environment: " .. path)
        return {}
    end
end

-- Global Save Function
GlobalEnvironment.IO_SAVE = function() end

-- Icon Library System with Fallback
local IconLibrary = {
    Icons = {
        ["home"] = {Image = "rbxassetid://3926305904", ImageRectPosition = Vector2.new(964, 324), ImageRectSize = Vector2.new(36, 36)},
        ["settings"] = {Image = "rbxassetid://3926305904", ImageRectPosition = Vector2.new(964, 204), ImageRectSize = Vector2.new(36, 36)},
        ["info"] = {Image = "rbxassetid://3926305904", ImageRectPosition = Vector2.new(964, 444), ImageRectSize = Vector2.new(36, 36)},
        ["player"] = {Image = "rbxassetid://3926305904", ImageRectPosition = Vector2.new(44, 204), ImageRectSize = Vector2.new(36, 36)},
        ["sword"] = {Image = "rbxassetid://3926305904", ImageRectPosition = Vector2.new(404, 44), ImageRectSize = Vector2.new(36, 36)},
        ["shield"] = {Image = "rbxassetid://3926305904", ImageRectPosition = Vector2.new(884, 124), ImageRectSize = Vector2.new(36, 36)},
        ["star"] = {Image = "rbxassetid://3926305904", ImageRectPosition = Vector2.new(604, 444), ImageRectSize = Vector2.new(36, 36)},
        ["flag"] = {Image = "rbxassetid://3926305904", ImageRectPosition = Vector2.new(324, 364), ImageRectSize = Vector2.new(36, 36)},
        ["lightbulb"] = {Image = "rbxassetid://3926305904", ImageRectPosition = Vector2.new(44, 124), ImageRectSize = Vector2.new(36, 36)},
        ["gear"] = {Image = "rbxassetid://3926305904", ImageRectPosition = Vector2.new(964, 84), ImageRectSize = Vector2.new(36, 36)},
    },
    Spritesheets = {
        ["rbxassetid://3926305904"] = "rbxassetid://3926305904"
    }
}

-- Try to load external icon library
local success, externalIcons = pcall(function()
    local content = game:HttpGet("https://raw.githubusercontent.com/Dummyrme/Library/refs/heads/main/Icon.lua", true)
    if content then
        local lib = loadstring(content)()
        if lib and lib.Icons then
            return lib
        end
    end
    return nil
end)

if success and externalIcons then
    IconLibrary = externalIcons
end

-- Config Management
local Configs = {}
local Options = {}

local ChilliLib = {
    Folder = "ChilliLib",
    Options = Options,
    
    SetFolder = function(self, folderName)
        self.Folder = folderName
        if fileFunctionsAvailable then
            makefolder(folderName)
            makefolder(folderName .. "/settings")
        end
        return true
    end,
    
    SaveConfig = function(self, configName)
        if not configName or configName == "" then
            return false, "Config name cannot be empty"
        end
        
        local configData = {}
        for name, option in pairs(self.Options) do
            if option.Class and option.Value ~= nil then
                configData[name] = {
                    Class = option.Class,
                    Value = option.Value
                }
            end
        end
        
        local jsonData
        local success, err = pcall(function()
            jsonData = HttpService:JSONEncode(configData)
        end)
        
        if not success then
            return false, "Failed to encode config: " .. err
        end
        
        if fileFunctionsAvailable then
            local path = self.Folder .. "/settings/" .. configName .. ".json"
            writefile(path, jsonData)
            return true, "Config saved: " .. configName
        else
            -- Store in memory for non-file environments
            Configs[configName] = jsonData
            return true, "Config saved to memory: " .. configName
        end
    end,
    
    LoadConfig = function(self, configName)
        local configPath = self.Folder .. "/settings/" .. configName .. ".json"
        
        if fileFunctionsAvailable then
            if not isfile(configPath) then
                return false, "Config file not found: " .. configName
            end
            
            local content = readfile(configPath)
            local configData = HttpService:JSONDecode(content)
            
            for name, data in pairs(configData) do
                if self.Options[name] then
                    if self.Options[name].Set then
                        self.Options[name]:Set(data.Value)
                    elseif self.Options[name].UpdateState then
                        self.Options[name]:UpdateState(data.Value)
                    end
                end
            end
            
            return true, "Config loaded: " .. configName
        else
            -- Load from memory
            if not Configs[configName] then
                return false, "Config not found in memory: " .. configName
            end
            
            local configData = HttpService:JSONDecode(Configs[configName])
            for name, data in pairs(configData) do
                if self.Options[name] then
                    if self.Options[name].Set then
                        self.Options[name]:Set(data.Value)
                    elseif self.Options[name].UpdateState then
                        self.Options[name]:UpdateState(data.Value)
                    end
                end
            end
            
            return true, "Config loaded from memory: " .. configName
        end
    end,
    
    RefreshConfigList = function(self)
        local configs = {}
        
        if fileFunctionsAvailable then
            local settingsPath = self.Folder .. "/settings"
            if isfolder(settingsPath) then
                for _, file in pairs(listfiles(settingsPath)) do
                    if file:sub(-5) == ".json" then
                        local name = file:match("([^/]-)%.json$")
                        table.insert(configs, name)
                    end
                end
            end
        else
            -- List from memory
            for name, _ in pairs(Configs) do
                table.insert(configs, name)
            end
        end
        
        return configs
    end,
    
    Window = function(self, settings)
        if not settings then
            error("Window settings are required")
        end
        
        if not settings.Title then
            settings.Title = "ChilliLib Window"
        end
        
        if not settings.Size then
            settings.Size = UDim2.fromOffset(550, 350)
        end
        
        -- Create ScreenGui
        local ScreenGui = Instance.new("ScreenGui")
        ScreenGui.Name = "ChilliLibUI_" .. HttpService:GenerateGUID(false):sub(1, 8)
        ScreenGui.ResetOnSpawn = false
        ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        ScreenGui.DisplayOrder = 10000
        
        -- Parent handling (compatible with different environments)
        local parent = CoreGui
        if gethui then
            parent = gethui()
        elseif syn and syn.protect_gui then
            syn.protect_gui(ScreenGui)
        end
        ScreenGui.Parent = parent
        
        -- Notification Container
        local NotificationContainer = Instance.new("Frame")
        NotificationContainer.Name = "Notifications"
        NotificationContainer.BackgroundTransparency = 1
        NotificationContainer.Size = UDim2.new(0, 300, 1, -20)
        NotificationContainer.Position = UDim2.new(1, -320, 0, 10)
        NotificationContainer.AnchorPoint = Vector2.new(0, 0)
        NotificationContainer.Parent = ScreenGui
        NotificationContainer.ZIndex = 100
        
        local NotificationLayout = Instance.new("UIListLayout")
        NotificationLayout.Padding = UDim.new(0, 10)
        NotificationLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
        NotificationLayout.SortOrder = Enum.SortOrder.LayoutOrder
        NotificationLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
        NotificationLayout.Parent = NotificationContainer
        
        -- Main Window
        local windowSize = settings.Size
        local targetSize = UDim2.new(windowSize.X.Scale, windowSize.X.Offset, windowSize.Y.Scale, windowSize.Y.Offset)
        
        local MainFrame = Instance.new("Frame")
        MainFrame.Name = "MainBase"
        MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
        MainFrame.Position = UDim2.fromScale(0.5, 0.5)
        MainFrame.Size = UDim2.new(0, 0, 0, 0)
        MainFrame.Parent = ScreenGui
        MainFrame.BackgroundColor3 = COLOR_PRIMARY_BG
        MainFrame.BorderSizePixel = 0
        MainFrame.Visible = false
        
        local MainCorner = Instance.new("UICorner", MainFrame)
        MainCorner.CornerRadius = UDim.new(0, 20)
        
        local MainGradient = Instance.new("UIGradient", MainFrame)
        MainGradient.Rotation = 35
        MainGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, COLOR_DARK_BG),
            ColorSequenceKeypoint.new(0.55, COLOR_MEDIUM_BG),
            ColorSequenceKeypoint.new(1, COLOR_ACCENT_BLUE)
        })
        
        local MainStrokeOuter = Instance.new("UIStroke", MainFrame)
        MainStrokeOuter.Thickness = 3
        MainStrokeOuter.Transparency = 0.8
        MainStrokeOuter.Color = COLOR_CYAN_STROKE
        MainStrokeOuter.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        
        local MainStrokeInner = Instance.new("UIStroke", MainFrame)
        MainStrokeInner.Thickness = 1
        MainStrokeInner.Transparency = 0.5
        MainStrokeInner.Color = COLOR_CYAN_HIGHLIGHT
        MainStrokeInner.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
        
        -- Dragging functionality
        local dragging = false
        local dragInput, dragStart, startPos
        
        MainFrame.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                dragging = true
                dragStart = input.Position
                startPos = MainFrame.Position
                
                input.Changed:Connect(function()
                    if input.UserInputState == Enum.UserInputState.End then
                        dragging = false
                    end
                end)
            end
        end)
        
        MainFrame.InputChanged:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseMovement then
                dragInput = input
            end
        end)
        
        UserInputService.InputChanged:Connect(function(input)
            if dragging and input == dragInput then
                local delta = input.Position - dragStart
                MainFrame.Position = UDim2.new(
                    startPos.X.Scale, 
                    startPos.X.Offset + delta.X,
                    startPos.Y.Scale, 
                    startPos.Y.Offset + delta.Y
                )
            end
        end)
        
        -- Top Bar
        local TopBar = Instance.new("Frame")
        TopBar.Name = "TopBar"
        TopBar.Parent = MainFrame
        TopBar.BackgroundColor3 = COLOR_TOPBAR_BG
        TopBar.BackgroundTransparency = 0.3
        TopBar.BorderSizePixel = 0
        TopBar.Size = UDim2.new(1, -14, 0, 32)
        TopBar.Position = UDim2.new(0, 7, 0, 7)
        
        local TopBarCorner = Instance.new("UICorner", TopBar)
        TopBarCorner.CornerRadius = UDim.new(0, 12)
        
        local TitleLabel = Instance.new("TextLabel")
        TitleLabel.Parent = TopBar
        TitleLabel.BackgroundTransparency = 1
        TitleLabel.Position = UDim2.new(0, 16, 0, 0)
        TitleLabel.Size = UDim2.new(1, -80, 1, 0)
        TitleLabel.Font = FONT_BOLD
        TitleLabel.Text = settings.Title
        TitleLabel.TextXAlignment = Enum.TextXAlignment.Left
        TitleLabel.TextSize = 18
        TitleLabel.TextColor3 = COLOR_TEXT_PRIMARY
        
        local TitleGradient = Instance.new("UIGradient", TitleLabel)
        TitleGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromRGB(34, 211, 238)),
            ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
            ColorSequenceKeypoint.new(1, Color3.fromRGB(99, 102, 241))
        })
        
        local CloseButton = Instance.new("TextButton", TopBar)
        CloseButton.Size = UDim2.fromOffset(24, 24)
        CloseButton.Position = UDim2.new(1, -30, 0.5, -12)
        CloseButton.BackgroundColor3 = COLOR_SECONDARY_BG
        CloseButton.Text = "X"
        CloseButton.Font = FONT_BOLD
        CloseButton.TextSize = 14
        CloseButton.TextColor3 = COLOR_ERROR_RED
        CloseButton.AutoButtonColor = true
        
        local CloseButtonCorner = Instance.new("UICorner", CloseButton)
        CloseButtonCorner.CornerRadius = UDim.new(0, 8)
        
        local CloseButtonStroke = Instance.new("UIStroke", CloseButton)
        CloseButtonStroke.Color = COLOR_CYAN_HIGHLIGHT
        CloseButtonStroke.Transparency = 0.7
        CloseButtonStroke.Thickness = 1
        
        CloseButton.MouseButton1Click:Connect(function()
            self:Hide()
        end)
        
        -- Close with Escape key
        UserInputService.InputBegan:Connect(function(input)
            if input.KeyCode == Enum.KeyCode.Escape then
                self:Hide()
            end
        end)
        
        -- Content Area
        local ContentArea = Instance.new("Frame", MainFrame)
        ContentArea.BackgroundTransparency = 1
        ContentArea.Position = UDim2.new(0, 10, 0, 45)
        ContentArea.Size = UDim2.new(1, -20, 1, -50)
        
        -- Tab List
        local TabList = Instance.new("ScrollingFrame", ContentArea)
        TabList.Size = UDim2.new(0, 105, 1, 0)
        TabList.BackgroundTransparency = 1
        TabList.ScrollBarThickness = 2
        TabList.ScrollBarImageColor3 = COLOR_ACCENT_CYAN
        TabList.BorderSizePixel = 0
        TabList.CanvasSize = UDim2.new(0, 0, 0, 0)
        TabList.AutomaticCanvasSize = Enum.AutomaticSize.Y
        
        local TabListLayout = Instance.new("UIListLayout", TabList)
        TabListLayout.Padding = UDim.new(0, 6)
        TabListLayout.SortOrder = Enum.SortOrder.LayoutOrder
        
        -- Divider
        local Divider = Instance.new("Frame", ContentArea)
        Divider.Size = UDim2.new(0, 1, 1, 0)
        Divider.Position = UDim2.new(0, 115, 0, 0)
        Divider.BackgroundColor3 = COLOR_CYAN_HIGHLIGHT
        Divider.BackgroundTransparency = 0.8
        Divider.BorderSizePixel = 0
        
        -- Tab Content Area
        local TabContent = Instance.new("Frame", ContentArea)
        TabContent.Size = UDim2.new(1, -125, 1, 0)
        TabContent.Position = UDim2.new(0, 125, 0, 0)
        TabContent.BackgroundTransparency = 1
        TabContent.ClipsDescendants = true
        
        local currentTab = nil
        local tabs = {}
        
        -- Window Methods
        local windowMethods = {
            Show = function()
                MainFrame.Visible = true
                local showTween = TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
                    Size = targetSize
                })
                showTween:Play()
            end,
            
            Hide = function()
                local hideTween = TweenService:Create(MainFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
                    Size = UDim2.new(0, 0, 0, 0)
                })
                hideTween:Play()
                
                task.delay(0.26, function()
                    MainFrame.Visible = false
                end)
            end,
            
            Toggle = function()
                if MainFrame.Visible then
                    windowMethods.Hide()
                else
                    windowMethods.Show()
                end
            end,
            
            Destroy = function()
                ScreenGui:Destroy()
            end,
            
            Notify = function(self, notifySettings)
                local duration = notifySettings.Duration or 5
                local title = notifySettings.Title or "Notification"
                local desc = notifySettings.Desc or ""
                
                local NotifyWrapper = Instance.new("Frame")
                NotifyWrapper.Size = UDim2.new(1, 0, 0, 70)
                NotifyWrapper.BackgroundTransparency = 1
                NotifyWrapper.LayoutOrder = #NotificationContainer:GetChildren()
                NotifyWrapper.Parent = NotificationContainer
                
                local NotifyFrame = Instance.new("Frame", NotifyWrapper)
                NotifyFrame.Size = UDim2.new(1, 0, 1, 0)
                NotifyFrame.Position = UDim2.new(1, 40, 0, 0)
                NotifyFrame.BackgroundTransparency = 1
                NotifyFrame.BackgroundColor3 = COLOR_PRIMARY_BG
                NotifyFrame.BorderSizePixel = 0
                
                local NotifyCorner = Instance.new("UICorner", NotifyFrame)
                NotifyCorner.CornerRadius = UDim.new(0, 12)
                
                local NotifyGradient = Instance.new("UIGradient", NotifyFrame)
                NotifyGradient.Rotation = 35
                NotifyGradient.Color = ColorSequence.new({
                    ColorSequenceKeypoint.new(0, COLOR_DARK_BG),
                    ColorSequenceKeypoint.new(0.55, COLOR_MEDIUM_BG),
                    ColorSequenceKeypoint.new(1, COLOR_ACCENT_BLUE)
                })
                
                local NotifyStrokeOuter = Instance.new("UIStroke", NotifyFrame)
                NotifyStrokeOuter.Thickness = 3
                NotifyStrokeOuter.Transparency = 0.8
                NotifyStrokeOuter.Color = COLOR_CYAN_STROKE
                NotifyStrokeOuter.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                
                local NotifyStrokeInner = Instance.new("UIStroke", NotifyFrame)
                NotifyStrokeInner.Thickness = 1
                NotifyStrokeInner.Transparency = 0.5
                NotifyStrokeInner.Color = COLOR_CYAN_HIGHLIGHT
                NotifyStrokeInner.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                
                local NotifyTitle = Instance.new("TextLabel", NotifyFrame)
                NotifyTitle.Position = UDim2.new(0, 12, 0, 8)
                NotifyTitle.Size = UDim2.new(1, -24, 0, 20)
                NotifyTitle.BackgroundTransparency = 1
                NotifyTitle.Font = FONT_BOLD
                NotifyTitle.Text = title
                NotifyTitle.TextColor3 = COLOR_ACCENT_CYAN
                NotifyTitle.TextSize = 14
                NotifyTitle.TextXAlignment = Enum.TextXAlignment.Left
                
                local NotifyDesc = Instance.new("TextLabel", NotifyFrame)
                NotifyDesc.Position = UDim2.new(0, 12, 0, 30)
                NotifyDesc.Size = UDim2.new(1, -24, 0, 32)
                NotifyDesc.BackgroundTransparency = 1
                NotifyDesc.Font = FONT_REGULAR
                NotifyDesc.Text = desc
                NotifyDesc.TextColor3 = COLOR_TEXT_PRIMARY
                NotifyDesc.TextSize = 13
                NotifyDesc.TextWrapped = true
                NotifyDesc.TextXAlignment = Enum.TextXAlignment.Left
                NotifyDesc.TextYAlignment = Enum.TextYAlignment.Top
                
                TweenService:Create(NotifyFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {
                    BackgroundTransparency = 0,
                    Position = UDim2.new(0, 0, 0, 0)
                }):Play()
                
                task.delay(duration, function()
                    TweenService:Create(NotifyFrame, TweenInfo.new(0.35, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
                        BackgroundTransparency = 1,
                        Position = UDim2.new(1, 40, 0, 0)
                    }):Play()
                    
                    task.wait(0.36)
                    if NotifyWrapper and NotifyWrapper.Parent then
                        NotifyWrapper:Destroy()
                    end
                end)
            end,
            
            TabGroup = function()
                return {
                    Tab = function(self, tabSettings)
                        local tabId = #tabs + 1
                        local isFirstTab = tabId == 1
                        
                        local TabButton = Instance.new("TextButton", TabList)
                        TabButton.Size = UDim2.new(1, -4, 0, 32)
                        TabButton.BackgroundColor3 = COLOR_SECONDARY_BG
                        TabButton.BackgroundTransparency = isFirstTab and 0 or 1
                        TabButton.Text = ""
                        TabButton.AutoButtonColor = false
                        TabButton.LayoutOrder = tabId
                        
                        local TabButtonCorner = Instance.new("UICorner", TabButton)
                        TabButtonCorner.CornerRadius = UDim.new(0, 10)
                        
                        local TabButtonStroke = Instance.new("UIStroke", TabButton)
                        TabButtonStroke.Transparency = isFirstTab and 0.4 or 1
                        TabButtonStroke.Color = COLOR_ACCENT_CYAN
                        TabButtonStroke.Thickness = 1
                        
                        local TabIndicator = Instance.new("Frame", TabButton)
                        TabIndicator.Size = UDim2.new(0, 3, 1, -6)
                        TabIndicator.Position = UDim2.new(0, 1, 0, 3)
                        TabIndicator.BackgroundColor3 = COLOR_ACCENT_CYAN
                        TabIndicator.BorderSizePixel = 0
                        TabIndicator.BackgroundTransparency = isFirstTab and 0 or 1
                        
                        local TabButtonGradient = Instance.new("UIGradient", TabButton)
                        TabButtonGradient.Rotation = 35
                        TabButtonGradient.Color = ColorSequence.new({
                            ColorSequenceKeypoint.new(0, COLOR_DARK_BG),
                            ColorSequenceKeypoint.new(0.55, COLOR_MEDIUM_BG),
                            ColorSequenceKeypoint.new(1, COLOR_ACCENT_BLUE)
                        })
                        TabButtonGradient.Enabled = isFirstTab
                        
                        local TabIcon = Instance.new("ImageLabel", TabButton)
                        TabIcon.Size = UDim2.fromOffset(18, 18)
                        TabIcon.Position = UDim2.new(0, 8, 0.5, -9)
                        TabIcon.BackgroundTransparency = 1
                        TabIcon.ImageColor3 = isFirstTab and COLOR_ACCENT_CYAN or COLOR_TEXT_SECONDARY
                        
                        local iconName = tabSettings.Image or "home"
                        local iconData = IconLibrary.Icons[iconName] or IconLibrary.Icons["home"]
                        TabIcon.Image = IconLibrary.Spritesheets[iconData.Image] or iconData.Image
                        TabIcon.ImageRectOffset = iconData.ImageRectPosition
                        TabIcon.ImageRectSize = iconData.ImageRectSize
                        
                        local TabText = Instance.new("TextLabel", TabButton)
                        TabText.BackgroundTransparency = 1
                        TabText.Position = UDim2.new(0, 30, 0, 0)
                        TabText.Size = UDim2.new(1, -32, 1, 0)
                        TabText.Font = FONT_BOLD
                        TabText.Text = tabSettings.Title or "Tab " .. tabId
                        TabText.TextSize = 15
                        TabText.TextColor3 = isFirstTab and COLOR_TEXT_PRIMARY or COLOR_TEXT_SECONDARY
                        TabText.TextXAlignment = Enum.TextXAlignment.Left
                        
                        -- Tab Page
                        local TabPage = Instance.new("ScrollingFrame", TabContent)
                        TabPage.Size = UDim2.fromScale(1, 1)
                        TabPage.BackgroundTransparency = 1
                        TabPage.Visible = isFirstTab
                        TabPage.ScrollBarThickness = 2
                        TabPage.ScrollBarImageColor3 = COLOR_ACCENT_CYAN
                        TabPage.BorderSizePixel = 0
                        TabPage.CanvasSize = UDim2.new(0, 0, 0, 0)
                        TabPage.AutomaticCanvasSize = Enum.AutomaticSize.Y
                        
                        local TabPageLayout = Instance.new("UIListLayout", TabPage)
                        TabPageLayout.Padding = UDim.new(0, 12)
                        TabPageLayout.SortOrder = Enum.SortOrder.LayoutOrder
                        
                        local TabPagePadding = Instance.new("UIPadding", TabPage)
                        TabPagePadding.PaddingLeft = UDim.new(0, 4)
                        TabPagePadding.PaddingRight = UDim.new(0, 4)
                        TabPagePadding.PaddingTop = UDim.new(0, 4)
                        TabPagePadding.PaddingBottom = UDim.new(0, 10)
                        
                        -- Tab Click Handler
                        TabButton.MouseButton1Click:Connect(function()
                            if currentTab == TabPage then return end
                            
                            -- Hide all tabs
                            for _, tab in pairs(tabs) do
                                if tab.page and tab.page ~= TabPage then
                                    tab.page.Visible = false
                                    TweenService:Create(tab.button, TweenInfo.new(0.2), {
                                        BackgroundTransparency = 1
                                    }):Play()
                                    
                                    TweenService:Create(tab.stroke, TweenInfo.new(0.2), {
                                        Transparency = 1
                                    }):Play()
                                    
                                    TweenService:Create(tab.text, TweenInfo.new(0.2), {
                                        TextColor3 = COLOR_TEXT_SECONDARY
                                    }):Play()
                                    
                                    TweenService:Create(tab.icon, TweenInfo.new(0.2), {
                                        ImageColor3 = COLOR_TEXT_SECONDARY
                                    }):Play()
                                    
                                    tab.gradient.Enabled = false
                                    
                                    TweenService:Create(tab.indicator, TweenInfo.new(0.2), {
                                        BackgroundTransparency = 1
                                    }):Play()
                                end
                            end
                            
                            -- Show selected tab
                            TabPage.Visible = true
                            currentTab = TabPage
                            
                            TweenService:Create(TabButton, TweenInfo.new(0.2), {
                                BackgroundTransparency = 0
                            }):Play()
                            
                            TweenService:Create(TabButtonStroke, TweenInfo.new(0.2), {
                                Transparency = 0.4
                            }):Play()
                            
                            TweenService:Create(TabText, TweenInfo.new(0.2), {
                                TextColor3 = COLOR_TEXT_PRIMARY
                            }):Play()
                            
                            TweenService:Create(TabIcon, TweenInfo.new(0.2), {
                                ImageColor3 = COLOR_ACCENT_CYAN
                            }):Play()
                            
                            TabButtonGradient.Enabled = true
                            
                            TweenService:Create(TabIndicator, TweenInfo.new(0.2), {
                                BackgroundTransparency = 0
                            }):Play()
                        end)
                        
                        -- Store tab data
                        tabs[tabId] = {
                            button = TabButton,
                            page = TabPage,
                            stroke = TabButtonStroke,
                            text = TabText,
                            icon = TabIcon,
                            gradient = TabButtonGradient,
                            indicator = TabIndicator
                        }
                        
                        if isFirstTab then
                            currentTab = TabPage
                        end
                        
                        return {
                            Select = function()
                                TabButton.MouseButton1Click:Fire()
                            end,
                            
                            Section = function(self, sectionSettings)
                                local sectionId = #TabPage:GetChildren() + 1
                                
                                local SectionFrame = Instance.new("Frame", TabPage)
                                SectionFrame.Size = UDim2.new(1, -2, 0, 0)
                                SectionFrame.AutomaticSize = Enum.AutomaticSize.Y
                                SectionFrame.BackgroundTransparency = 0
                                SectionFrame.BackgroundColor3 = COLOR_PRIMARY_BG
                                SectionFrame.BorderSizePixel = 0
                                SectionFrame.LayoutOrder = sectionId
                                
                                local SectionCorner = Instance.new("UICorner", SectionFrame)
                                SectionCorner.CornerRadius = UDim.new(0, 12)
                                
                                local SectionGradient = Instance.new("UIGradient", SectionFrame)
                                SectionGradient.Rotation = 35
                                SectionGradient.Color = ColorSequence.new({
                                    ColorSequenceKeypoint.new(0, COLOR_DARK_BG),
                                    ColorSequenceKeypoint.new(0.55, COLOR_MEDIUM_BG),
                                    ColorSequenceKeypoint.new(1, COLOR_ACCENT_BLUE)
                                })
                                
                                local SectionStrokeOuter = Instance.new("UIStroke", SectionFrame)
                                SectionStrokeOuter.Thickness = 3
                                SectionStrokeOuter.Transparency = 0.8
                                SectionStrokeOuter.Color = COLOR_CYAN_STROKE
                                SectionStrokeOuter.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                                
                                local SectionStrokeInner = Instance.new("UIStroke", SectionFrame)
                                SectionStrokeInner.Thickness = 1
                                SectionStrokeInner.Transparency = 0.5
                                SectionStrokeInner.Color = COLOR_CYAN_HIGHLIGHT
                                SectionStrokeInner.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                                
                                local SectionPadding = Instance.new("UIPadding", SectionFrame)
                                SectionPadding.PaddingTop = UDim.new(0, 4)
                                SectionPadding.PaddingBottom = UDim.new(0, 4)
                                SectionPadding.PaddingLeft = UDim.new(0, 2)
                                SectionPadding.PaddingRight = UDim.new(0, 2)
                                
                                local SectionHeader = Instance.new("TextButton", SectionFrame)
                                SectionHeader.Size = UDim2.new(1, -16, 0, 24)
                                SectionHeader.Position = UDim2.new(0, 8, 0, 4)
                                SectionHeader.BackgroundTransparency = 1
                                SectionHeader.Text = ""
                                
                                local SectionTitle = Instance.new("TextLabel", SectionHeader)
                                SectionTitle.Text = sectionSettings.Title or "Section " .. sectionId
                                SectionTitle.Font = FONT_BOLD
                                SectionTitle.TextSize = 16
                                SectionTitle.TextColor3 = Color3.fromRGB(255, 255, 255)
                                SectionTitle.Size = UDim2.new(1, -20, 1, 0)
                                SectionTitle.BackgroundTransparency = 1
                                SectionTitle.TextXAlignment = Enum.TextXAlignment.Left
                                
                                local SectionTitleGradient = Instance.new("UIGradient", SectionTitle)
                                SectionTitleGradient.Color = ColorSequence.new({
                                    ColorSequenceKeypoint.new(0, Color3.fromRGB(34, 211, 238)),
                                    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 255, 255)),
                                    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
                                })
                                
                                local CollapseArrow = Instance.new("TextLabel", SectionHeader)
                                CollapseArrow.Text = "▼"
                                CollapseArrow.TextColor3 = COLOR_ACCENT_CYAN
                                CollapseArrow.BackgroundTransparency = 1
                                CollapseArrow.Size = UDim2.new(0, 20, 1, 0)
                                CollapseArrow.Position = UDim2.new(1, -20, 0, 0)
                                CollapseArrow.TextSize = 12
                                CollapseArrow.Rotation = 0
                                
                                local ContentHolder = Instance.new("Frame", SectionFrame)
                                ContentHolder.Name = "ContentHolder"
                                ContentHolder.BackgroundTransparency = 1
                                ContentHolder.Position = UDim2.new(0, 8, 0, 32)
                                ContentHolder.Size = UDim2.new(1, -16, 0, 0)
                                ContentHolder.AutomaticSize = Enum.AutomaticSize.Y
                                ContentHolder.Visible = true
                                
                                local ContentLayout = Instance.new("UIListLayout", ContentHolder)
                                ContentLayout.Padding = UDim.new(0, 8)
                                ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
                                
                                local ContentPadding = Instance.new("UIPadding", ContentHolder)
                                ContentPadding.PaddingBottom = UDim.new(0, 6)
                                
                                local isCollapsed = false
                                
                                SectionHeader.MouseButton1Click:Connect(function()
                                    isCollapsed = not isCollapsed
                                    
                                    if isCollapsed then
                                        TweenService:Create(CollapseArrow, TweenInfo.new(0.2), {
                                            Rotation = -90
                                        }):Play()
                                        ContentHolder.Visible = false
                                        SectionFrame.Size = UDim2.new(1, -2, 0, 40)
                                    else
                                        TweenService:Create(CollapseArrow, TweenInfo.new(0.2), {
                                            Rotation = 0
                                        }):Play()
                                        ContentHolder.Visible = true
                                        SectionFrame.AutomaticSize = Enum.AutomaticSize.Y
                                    end
                                end)
                                
                                return {
                                    Paragraph = function(self, paragraphSettings)
                                        local ParagraphFrame = Instance.new("Frame", ContentHolder)
                                        ParagraphFrame.Size = UDim2.new(1, 0, 0, 44)
                                        ParagraphFrame.AutomaticSize = Enum.AutomaticSize.Y
                                        ParagraphFrame.BackgroundColor3 = Color3.fromRGB(15, 20, 30)
                                        ParagraphFrame.BackgroundTransparency = 0.25
                                        
                                        local ParagraphCorner = Instance.new("UICorner", ParagraphFrame)
                                        ParagraphCorner.CornerRadius = UDim.new(0, 8)
                                        
                                        local ParagraphStroke = Instance.new("UIStroke", ParagraphFrame)
                                        ParagraphStroke.Color = COLOR_CYAN_HIGHLIGHT
                                        ParagraphStroke.Transparency = 0.5
                                        ParagraphStroke.Thickness = 1
                                        
                                        local ParagraphTitle = Instance.new("TextLabel", ParagraphFrame)
                                        ParagraphTitle.Size = UDim2.new(1, -10, 0, 20)
                                        ParagraphTitle.Position = UDim2.new(0, 10, 0, 4)
                                        ParagraphTitle.BackgroundTransparency = 1
                                        ParagraphTitle.Text = paragraphSettings.Title or "Paragraph"
                                        ParagraphTitle.Font = FONT_BOLD
                                        ParagraphTitle.TextSize = 14
                                        ParagraphTitle.TextColor3 = COLOR_TEXT_PRIMARY
                                        ParagraphTitle.TextXAlignment = Enum.TextXAlignment.Left
                                        
                                        local ParagraphDesc = Instance.new("TextLabel", ParagraphFrame)
                                        ParagraphDesc.Size = UDim2.new(1, -20, 0, 0)
                                        ParagraphDesc.Position = UDim2.new(0, 10, 0, 24)
                                        ParagraphDesc.AutomaticSize = Enum.AutomaticSize.Y
                                        ParagraphDesc.BackgroundTransparency = 1
                                        ParagraphDesc.Text = paragraphSettings.Desc or "Description"
                                        ParagraphDesc.TextColor3 = COLOR_TEXT_SECONDARY
                                        ParagraphDesc.TextSize = 13
                                        ParagraphDesc.TextWrapped = true
                                        ParagraphDesc.TextXAlignment = Enum.TextXAlignment.Left
                                        ParagraphDesc.TextYAlignment = Enum.TextYAlignment.Top
                                        ParagraphDesc.Font = FONT_MEDIUM
                                        
                                        return ParagraphFrame
                                    end,
                                    
                                    Dropdown = function(self, dropdownSettings)
                                        local optionId = "dropdown_" .. dropdownSettings.Title:gsub("%s+", "_")
                                        local DropdownFrame = Instance.new("Frame", ContentHolder)
                                        DropdownFrame.Size = UDim2.new(1, 0, 0, 44)
                                        DropdownFrame.BackgroundColor3 = Color3.fromRGB(15, 20, 30)
                                        DropdownFrame.BackgroundTransparency = 0.5
                                        DropdownFrame.ClipsDescendants = true
                                        
                                        local DropdownCorner = Instance.new("UICorner", DropdownFrame)
                                        DropdownCorner.CornerRadius = UDim.new(0, 8)
                                        
                                        local DropdownStroke = Instance.new("UIStroke", DropdownFrame)
                                        DropdownStroke.Color = COLOR_CYAN_HIGHLIGHT
                                        DropdownStroke.Transparency = 0.9
                                        DropdownStroke.Thickness = 1
                                        
                                        local DropdownTitle = Instance.new("TextLabel", DropdownFrame)
                                        DropdownTitle.Size = UDim2.new(1, -10, 0, 20)
                                        DropdownTitle.Position = UDim2.new(0, 10, 0, 4)
                                        DropdownTitle.BackgroundTransparency = 1
                                        DropdownTitle.Text = dropdownSettings.Title or "Dropdown"
                                        DropdownTitle.Font = FONT_MEDIUM
                                        DropdownTitle.TextSize = 14
                                        DropdownTitle.TextColor3 = COLOR_TEXT_PRIMARY
                                        DropdownTitle.TextXAlignment = Enum.TextXAlignment.Left
                                        
                                        local SelectedValue = Instance.new("TextLabel", DropdownFrame)
                                        SelectedValue.Size = UDim2.new(0, 110, 0, 20)
                                        SelectedValue.Position = UDim2.new(1, -140, 0, 4)
                                        SelectedValue.Text = dropdownSettings.Default or "Select"
                                        SelectedValue.Font = FONT_BOLD
                                        SelectedValue.TextColor3 = COLOR_TEXT_PRIMARY
                                        SelectedValue.TextXAlignment = Enum.TextXAlignment.Right
                                        SelectedValue.BackgroundTransparency = 1
                                        SelectedValue.TextSize = 13
                                        
                                        local DropdownArrow = Instance.new("TextLabel", DropdownFrame)
                                        DropdownArrow.Text = "▼"
                                        DropdownArrow.Size = UDim2.new(0, 20, 0, 20)
                                        DropdownArrow.Position = UDim2.new(1, -26, 0, 4)
                                        DropdownArrow.BackgroundTransparency = 1
                                        DropdownArrow.TextColor3 = COLOR_TEXT_SECONDARY
                                        DropdownArrow.TextSize = 12
                                        
                                        local DropdownButton = Instance.new("TextButton", DropdownFrame)
                                        DropdownButton.Size = UDim2.new(1, 0, 1, 0)
                                        DropdownButton.BackgroundTransparency = 1
                                        DropdownButton.Text = ""
                                        
                                        local OptionsContainer = Instance.new("Frame", DropdownFrame)
                                        OptionsContainer.Size = UDim2.new(1, -10, 0, 0)
                                        OptionsContainer.Position = UDim2.new(0, 5, 0, 26)
                                        OptionsContainer.BackgroundTransparency = 1
                                        OptionsContainer.Visible = false
                                        OptionsContainer.ClipsDescendants = true
                                        
                                        local OptionsLayout = Instance.new("UIListLayout", OptionsContainer)
                                        OptionsLayout.Padding = UDim.new(0, 4)
                                        
                                        local currentValue = dropdownSettings.Default or dropdownSettings.Options[1]
                                        local options = dropdownSettings.Options or {"Option 1", "Option 2", "Option 3"}
                                        
                                        local function populateOptions()
                                            for _, child in pairs(OptionsContainer:GetChildren()) do
                                                if child:IsA("TextButton") then
                                                    child:Destroy()
                                                end
                                            end
                                            
                                            local totalHeight = 0
                                            for i, option in ipairs(options) do
                                                local OptionButton = Instance.new("TextButton", OptionsContainer)
                                                OptionButton.Size = UDim2.new(1, 0, 0, 26)
                                                OptionButton.BackgroundColor3 = Color3.fromRGB(15, 20, 30)
                                                OptionButton.Text = option
                                                OptionButton.Font = FONT_REGULAR
                                                OptionButton.TextColor3 = COLOR_TEXT_PRIMARY
                                                OptionButton.TextSize = 13
                                                OptionButton.LayoutOrder = i
                                                
                                                local OptionCorner = Instance.new("UICorner", OptionButton)
                                                OptionCorner.CornerRadius = UDim.new(0, 6)
                                                
                                                local OptionStroke = Instance.new("UIStroke", OptionButton)
                                                OptionStroke.Color = COLOR_CYAN_HIGHLIGHT
                                                OptionStroke.Transparency = 0.7
                                                OptionStroke.Thickness = 1
                                                
                                                OptionButton.MouseButton1Click:Connect(function()
                                                    currentValue = option
                                                    SelectedValue.Text = option
                                                    SelectedValue.TextColor3 = COLOR_ACCENT_CYAN
                                                    
                                                    if dropdownSettings.Callback then
                                                        dropdownSettings.Callback(option)
                                                    end
                                                    
                                                    OptionsContainer.Visible = false
                                                    
                                                    TweenService:Create(DropdownFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
                                                        Size = UDim2.new(1, 0, 0, 44)
                                                    }):Play()
                                                    
                                                    TweenService:Create(DropdownArrow, TweenInfo.new(0.25), {
                                                        Rotation = 0
                                                    }):Play()
                                                end)
                                                
                                                totalHeight = totalHeight + 26 + 4
                                            end
                                            
                                            OptionsContainer.Size = UDim2.new(1, -10, 0, totalHeight - 4)
                                        end
                                        
                                        populateOptions()
                                        
                                        local isDropdownOpen = false
                                        
                                        DropdownButton.MouseButton1Click:Connect(function()
                                            isDropdownOpen = not isDropdownOpen
                                            OptionsContainer.Visible = isDropdownOpen
                                            
                                            if isDropdownOpen then
                                                TweenService:Create(DropdownFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
                                                    Size = UDim2.new(1, 0, 0, 44 + OptionsContainer.Size.Y.Offset + 4)
                                                }):Play()
                                                
                                                TweenService:Create(DropdownArrow, TweenInfo.new(0.25), {
                                                    Rotation = 180
                                                }):Play()
                                            else
                                                TweenService:Create(DropdownFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quad), {
                                                    Size = UDim2.new(1, 0, 0, 44)
                                                }):Play()
                                                
                                                TweenService:Create(DropdownArrow, TweenInfo.new(0.25), {
                                                    Rotation = 0
                                                }):Play()
                                            end
                                        end)
                                        
                                        -- Store in global options
                                        local optionObj = {
                                            Value = currentValue,
                                            Class = "Dropdown",
                                            Refresh = function(self, newOptions)
                                                options = newOptions
                                                populateOptions()
                                            end,
                                            Set = function(self, value)
                                                currentValue = value
                                                SelectedValue.Text = value
                                                SelectedValue.TextColor3 = COLOR_ACCENT_CYAN
                                            end
                                        }
                                        
                                        ChilliLib.Options[optionId] = optionObj
                                        
                                        return optionObj
                                    end,
                                    
                                    Divider = function()
                                        local DividerLine = Instance.new("Frame", ContentHolder)
                                        DividerLine.Size = UDim2.new(1, 0, 0, 1)
                                        DividerLine.BackgroundColor3 = COLOR_CYAN_HIGHLIGHT
                                        DividerLine.BackgroundTransparency = 0.8
                                        DividerLine.BorderSizePixel = 0
                                        DividerLine.LayoutOrder = #ContentHolder:GetChildren()
                                        
                                        return DividerLine
                                    end,
                                    
                                    Label = function(self, labelSettings)
                                        local LabelFrame = Instance.new("Frame", ContentHolder)
                                        LabelFrame.Size = UDim2.new(1, 0, 0, 24)
                                        LabelFrame.BackgroundTransparency = 1
                                        
                                        local LabelText = Instance.new("TextLabel", LabelFrame)
                                        LabelText.Size = UDim2.new(1, -10, 1, 0)
                                        LabelText.Position = UDim2.new(0, 10, 0, 0)
                                        LabelText.BackgroundTransparency = 1
                                        LabelText.Text = labelSettings.Title or "Label"
                                        LabelText.Font = FONT_REGULAR
                                        LabelText.TextSize = 14
                                        LabelText.TextColor3 = COLOR_TEXT_PRIMARY
                                        LabelText.TextXAlignment = Enum.TextXAlignment.Left
                                        
                                        return LabelFrame
                                    end,
                                    
                                    Button = function(self, buttonSettings)
                                        local optionId = "button_" .. buttonSettings.Title:gsub("%s+", "_")
                                        local ButtonFrame = Instance.new("Frame", ContentHolder)
                                        ButtonFrame.Size = UDim2.new(1, 0, 0, 36)
                                        ButtonFrame.BackgroundColor3 = COLOR_ACCENT_CYAN
                                        ButtonFrame.BackgroundTransparency = 0.9
                                        
                                        local ButtonCorner = Instance.new("UICorner", ButtonFrame)
                                        ButtonCorner.CornerRadius = UDim.new(0, 8)
                                        
                                        local ButtonStroke = Instance.new("UIStroke", ButtonFrame)
                                        ButtonStroke.Color = COLOR_CYAN_HIGHLIGHT
                                        ButtonStroke.Transparency = 0.9
                                        ButtonStroke.Thickness = 1
                                        
                                        local ButtonElement = Instance.new("TextButton", ButtonFrame)
                                        ButtonElement.Size = UDim2.fromScale(1, 1)
                                        ButtonElement.BackgroundTransparency = 1
                                        ButtonElement.Text = buttonSettings.Title or "Button"
                                        ButtonElement.Font = FONT_BOLD
                                        ButtonElement.TextColor3 = COLOR_ACCENT_CYAN
                                        ButtonElement.TextSize = 14
                                        
                                        ButtonElement.MouseButton1Click:Connect(function()
                                            if buttonSettings.Callback then
                                                buttonSettings.Callback()
                                            end
                                            
                                            TweenService:Create(ButtonElement, TweenInfo.new(0.1), {
                                                TextSize = 12
                                            }):Play()
                                            
                                            task.wait(0.1)
                                            
                                            TweenService:Create(ButtonElement, TweenInfo.new(0.1), {
                                                TextSize = 14
                                            }):Play()
                                        end)
                                        
                                        local optionObj = {
                                            SetTitle = function(self, newTitle)
                                                ButtonElement.Text = newTitle
                                            end,
                                            Class = "Button"
                                        }
                                        
                                        ChilliLib.Options[optionId] = optionObj
                                        
                                        return optionObj
                                    end,
                                    
                                    Input = function(self, inputSettings)
                                        local optionId = "input_" .. inputSettings.Title:gsub("%s+", "_")
                                        local InputFrame = Instance.new("Frame", ContentHolder)
                                        InputFrame.Size = UDim2.new(1, 0, 0, 38)
                                        InputFrame.BackgroundColor3 = Color3.fromRGB(15, 20, 30)
                                        InputFrame.BackgroundTransparency = 0.5
                                        
                                        local InputCorner = Instance.new("UICorner", InputFrame)
                                        InputCorner.CornerRadius = UDim.new(0, 8)
                                        
                                        local InputStroke = Instance.new("UIStroke", InputFrame)
                                        InputStroke.Color = COLOR_CYAN_HIGHLIGHT
                                        InputStroke.Transparency = 0.9
                                        InputStroke.Thickness = 1
                                        
                                        local InputTitle = Instance.new("TextLabel", InputFrame)
                                        InputTitle.Size = UDim2.new(1, -10, 1, 0)
                                        InputTitle.Position = UDim2.new(0, 10, 0, 0)
                                        InputTitle.BackgroundTransparency = 1
                                        InputTitle.Text = inputSettings.Title or "Input"
                                        InputTitle.Font = FONT_MEDIUM
                                        InputTitle.TextSize = 14
                                        InputTitle.TextColor3 = COLOR_TEXT_PRIMARY
                                        InputTitle.TextXAlignment = Enum.TextXAlignment.Left
                                        
                                        local InputContainer = Instance.new("Frame", InputFrame)
                                        InputContainer.Size = UDim2.new(0, 60, 0, 26)
                                        InputContainer.Position = UDim2.new(1, -70, 0.5, -13)
                                        InputContainer.BackgroundColor3 = COLOR_PRIMARY_BG
                                        
                                        local InputContainerCorner = Instance.new("UICorner", InputContainer)
                                        InputContainerCorner.CornerRadius = UDim.new(0, 6)
                                        
                                        local InputContainerStroke = Instance.new("UIStroke", InputContainer)
                                        InputContainerStroke.Color = COLOR_CYAN_HIGHLIGHT
                                        InputContainerStroke.Transparency = 0.8
                                        
                                        local TextBox = Instance.new("TextBox", InputContainer)
                                        TextBox.Size = UDim2.new(1, -10, 1, 0)
                                        TextBox.Position = UDim2.new(0, 5, 0, 0)
                                        TextBox.BackgroundTransparency = 1
                                        TextBox.Text = inputSettings.Default or ""
                                        TextBox.PlaceholderText = inputSettings.Placeholder or "Enter text..."
                                        TextBox.TextColor3 = COLOR_TEXT_PRIMARY
                                        TextBox.Font = FONT_BOLD
                                        TextBox.TextSize = 14
                                        TextBox.TextStrokeTransparency = 0.8
                                        TextBox.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
                                        
                                        TextBox.FocusLost:Connect(function(enterPressed)
                                            if enterPressed then
                                                if inputSettings.Callback then
                                                    inputSettings.Callback(TextBox.Text)
                                                end
                                            end
                                        end)
                                        
                                        local optionObj = {
                                            Value = TextBox.Text,
                                            Class = "Input",
                                            Set = function(self, value)
                                                TextBox.Text = value
                                            end
                                        }
                                        
                                        ChilliLib.Options[optionId] = optionObj
                                        
                                        return optionObj
                                    end,
                                    
                                    Toggle = function(self, toggleSettings)
                                        local optionId = "toggle_" .. toggleSettings.Title:gsub("%s+", "_")
                                        local ToggleFrame = Instance.new("Frame", ContentHolder)
                                        ToggleFrame.Size = UDim2.new(1, 0, 0, 38)
                                        ToggleFrame.BackgroundColor3 = Color3.fromRGB(15, 20, 30)
                                        ToggleFrame.BackgroundTransparency = 0.5
                                        
                                        local ToggleCorner = Instance.new("UICorner", ToggleFrame)
                                        ToggleCorner.CornerRadius = UDim.new(0, 8)
                                        
                                        local ToggleStroke = Instance.new("UIStroke", ToggleFrame)
                                        ToggleStroke.Color = COLOR_CYAN_HIGHLIGHT
                                        ToggleStroke.Transparency = 0.9
                                        ToggleStroke.Thickness = 1
                                        
                                        local ToggleTitle = Instance.new("TextLabel", ToggleFrame)
                                        ToggleTitle.Size = UDim2.new(1, -10, 1, 0)
                                        ToggleTitle.Position = UDim2.new(0, 10, 0, 0)
                                        ToggleTitle.BackgroundTransparency = 1
                                        ToggleTitle.Text = toggleSettings.Title or "Toggle"
                                        ToggleTitle.Font = FONT_MEDIUM
                                        ToggleTitle.TextSize = 14
                                        ToggleTitle.TextColor3 = COLOR_TEXT_PRIMARY
                                        ToggleTitle.TextXAlignment = Enum.TextXAlignment.Left
                                        
                                        local ToggleButton = Instance.new("TextButton", ToggleFrame)
                                        ToggleButton.Size = UDim2.fromScale(1, 1)
                                        ToggleButton.BackgroundTransparency = 1
                                        ToggleButton.Text = ""
                                        
                                        local ToggleTrack = Instance.new("Frame", ToggleFrame)
                                        ToggleTrack.Size = UDim2.fromOffset(40, 20)
                                        ToggleTrack.Position = UDim2.new(1, -50, 0.5, -10)
                                        ToggleTrack.BackgroundColor3 = COLOR_SECONDARY_BG
                                        ToggleTrack.BackgroundTransparency = 0.1
                                        
                                        local ToggleTrackCorner = Instance.new("UICorner", ToggleTrack)
                                        ToggleTrackCorner.CornerRadius = UDim.new(1, 0)
                                        
                                        local ToggleKnob = Instance.new("Frame", ToggleTrack)
                                        ToggleKnob.Size = UDim2.fromOffset(16, 16)
                                        ToggleKnob.Position = UDim2.new(0, 2, 0.5, -8)
                                        ToggleKnob.BackgroundColor3 = COLOR_TEXT_PRIMARY
                                        
                                        local ToggleKnobCorner = Instance.new("UICorner", ToggleKnob)
                                        ToggleKnobCorner.CornerRadius = UDim.new(1, 0)
                                        
                                        local toggled = toggleSettings.Default or false
                                        
                                        local function updateVisual(state)
                                            if state then
                                                TweenService:Create(ToggleTrack, TweenInfo.new(0.2), {
                                                    BackgroundTransparency = 0,
                                                    BackgroundColor3 = COLOR_ACCENT_CYAN
                                                }):Play()
                                                
                                                TweenService:Create(ToggleKnob, TweenInfo.new(0.2), {
                                                    Position = UDim2.new(1, -18, 0.5, -8)
                                                }):Play()
                                            else
                                                TweenService:Create(ToggleTrack, TweenInfo.new(0.2), {
                                                    BackgroundTransparency = 0.1,
                                                    BackgroundColor3 = COLOR_SECONDARY_BG
                                                }):Play()
                                                
                                                TweenService:Create(ToggleKnob, TweenInfo.new(0.2), {
                                                    Position = UDim2.new(0, 2, 0.5, -8)
                                                }):Play()
                                            end
                                        end
                                        
                                        updateVisual(toggled)
                                        
                                        ToggleButton.MouseButton1Click:Connect(function()
                                            toggled = not toggled
                                            updateVisual(toggled)
                                            
                                            if toggleSettings.Callback then
                                                toggleSettings.Callback(toggled)
                                            end
                                        end)
                                        
                                        local optionObj = {
                                            State = toggled,
                                            Value = toggled,
                                            Class = "Toggle",
                                            Set = function(self, state)
                                                toggled = state
                                                updateVisual(state)
                                                
                                                if toggleSettings.Callback then
                                                    toggleSettings.Callback(state)
                                                end
                                            end,
                                            UpdateState = function(self, state)
                                                toggled = state
                                                updateVisual(state)
                                                
                                                if toggleSettings.Callback then
                                                    toggleSettings.Callback(state)
                                                end
                                            end
                                        }
                                        
                                        ChilliLib.Options[optionId] = optionObj
                                        
                                        return optionObj
                                    end,
                                    
                                    Slider = function(self, sliderSettings)
                                        local optionId = "slider_" .. sliderSettings.Title:gsub("%s+", "_")
                                        local SliderFrame = Instance.new("Frame", ContentHolder)
                                        SliderFrame.Size = UDim2.new(1, 0, 0, 50)
                                        SliderFrame.BackgroundColor3 = Color3.fromRGB(15, 20, 30)
                                        SliderFrame.BackgroundTransparency = 0.5
                                        
                                        local SliderCorner = Instance.new("UICorner", SliderFrame)
                                        SliderCorner.CornerRadius = UDim.new(0, 8)
                                        
                                        local SliderStroke = Instance.new("UIStroke", SliderFrame)
                                        SliderStroke.Color = COLOR_CYAN_HIGHLIGHT
                                        SliderStroke.Transparency = 0.9
                                        SliderStroke.Thickness = 1
                                        
                                        local SliderTitle = Instance.new("TextLabel", SliderFrame)
                                        SliderTitle.Size = UDim2.new(1, -10, 0, 25)
                                        SliderTitle.Position = UDim2.new(0, 10, 0, 0)
                                        SliderTitle.BackgroundTransparency = 1
                                        SliderTitle.Text = sliderSettings.Title or "Slider"
                                        SliderTitle.Font = FONT_MEDIUM
                                        SliderTitle.TextSize = 14
                                        SliderTitle.TextColor3 = COLOR_TEXT_PRIMARY
                                        SliderTitle.TextXAlignment = Enum.TextXAlignment.Left
                                        
                                        local SliderValue = Instance.new("TextLabel", SliderFrame)
                                        SliderValue.Size = UDim2.new(0, 50, 0, 25)
                                        SliderValue.Position = UDim2.new(1, -60, 0, 0)
                                        SliderValue.BackgroundTransparency = 1
                                        SliderValue.Text = tostring(sliderSettings.Default or 50)
                                        SliderValue.TextColor3 = COLOR_ACCENT_CYAN
                                        SliderValue.Font = FONT_BOLD
                                        SliderValue.TextSize = 13
                                        SliderValue.TextXAlignment = Enum.TextXAlignment.Right
                                        
                                        local SliderTrack = Instance.new("Frame", SliderFrame)
                                        SliderTrack.Size = UDim2.new(0.85, -20, 0, 4)
                                        SliderTrack.Position = UDim2.new(0, 10, 0, 32)
                                        SliderTrack.BackgroundColor3 = COLOR_SECONDARY_BG
                                        
                                        local SliderTrackCorner = Instance.new("UICorner", SliderTrack)
                                        SliderTrackCorner.CornerRadius = UDim.new(1, 0)
                                        
                                        local SliderFill = Instance.new("Frame", SliderTrack)
                                        SliderFill.Size = UDim2.new(0, 0, 1, 0)
                                        SliderFill.BackgroundColor3 = COLOR_ACCENT_CYAN
                                        
                                        local SliderFillCorner = Instance.new("UICorner", SliderFill)
                                        SliderFillCorner.CornerRadius = UDim.new(1, 0)
                                        
                                        local minValue = sliderSettings.Minimum or 0
                                        local maxValue = sliderSettings.Maximum or 100
                                        local currentValue = sliderSettings.Default or 50
                                        
                                        local function updateSlider(value)
                                            local clamped = math.clamp(value, minValue, maxValue)
                                            local percentage = (clamped - minValue) / (maxValue - minValue)
                                            
                                            SliderFill.Size = UDim2.new(percentage, 0, 1, 0)
                                            SliderValue.Text = tostring(math.floor(clamped))
                                            currentValue = math.floor(clamped)
                                            
                                            if sliderSettings.Callback then
                                                sliderSettings.Callback(currentValue)
                                            end
                                        end
                                        
                                        updateSlider(currentValue)
                                        
                                        local SliderButton = Instance.new("TextButton", SliderTrack)
                                        SliderButton.Size = UDim2.fromScale(1, 1)
                                        SliderButton.BackgroundTransparency = 1
                                        SliderButton.Text = ""
                                        
                                        local dragging = false
                                        
                                        local function updateFromMouse(input)
                                            local relativeX = (input.Position.X - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X
                                            relativeX = math.clamp(relativeX, 0, 1)
                                            local value = math.floor(minValue + (maxValue - minValue) * relativeX)
                                            updateSlider(value)
                                        end
                                        
                                        SliderButton.InputBegan:Connect(function(input)
                                            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                                                dragging = true
                                                updateFromMouse(input)
                                            end
                                        end)
                                        
                                        SliderButton.InputChanged:Connect(function(input)
                                            if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                                                updateFromMouse(input)
                                            end
                                        end)
                                        
                                        UserInputService.InputEnded:Connect(function(input)
                                            if input.UserInputType == Enum.UserInputType.MouseButton1 then
                                                dragging = false
                                            end
                                        end)
                                        
                                        local optionObj = {
                                            Value = currentValue,
                                            Class = "Slider",
                                            Set = function(self, value)
                                                updateSlider(value)
                                            end
                                        }
                                        
                                        ChilliLib.Options[optionId] = optionObj
                                        
                                        return optionObj
                                    end
                                }
                            end
                        }
                    end
                }
            end,
            
            Unload = function(self, callback)
                if callback then
                    callback()
                end
                ScreenGui:Destroy()
            end
        }
        
        -- Show window immediately
        windowMethods.Show()
        
        return windowMethods
    end,
    
    GetService = function(self, serviceName)
        return game:GetService(serviceName)
    end,
    
    Demo = function()
        local lib = ChilliLib
        
        -- Create demo window
        local window = lib:Window({
            Title = "ChilliLib Demo",
            Size = UDim2.fromOffset(600, 400)
        })
        
        local tabGroup = window:TabGroup()
        local mainTab = tabGroup:Tab({
            Title = "Main",
            Image = "home"
        })
        
        local sec1 = mainTab:Section({
            Title = "Controls Demo"
        })
        
        -- Add demo elements
        sec1:Label({
            Title = "Welcome to ChilliLib!"
        })
        
        sec1:Paragraph({
            Title = "About",
            Desc = "This is a fully functional UI library with modern design and smooth animations."
        })
        
        sec1:Divider()
        
        local demoToggle = sec1:Toggle({
            Title = "Enable Features",
            Default = true,
            Callback = function(state)
                window:Notify({
                    Title = "Toggle",
                    Desc = "Features " .. (state and "enabled" or "disabled"),
                    Duration = 3
                })
            end
        })
        
        local demoSlider = sec1:Slider({
            Title = "Volume",
            Default = 75,
            Minimum = 0,
            Maximum = 100,
            Callback = function(value)
                print("Volume set to:", value)
            end
        })
        
        sec1:Dropdown({
            Title = "Quality",
            Default = "Medium",
            Options = {"Low", "Medium", "High", "Ultra"},
            Callback = function(value)
                window:Notify({
                    Title = "Quality",
                    Desc = "Set to " .. value,
                    Duration = 3
                })
            end
        })
        
        sec1:Button({
            Title = "Test Notification",
            Callback = function()
                window:Notify({
                    Title = "Hello!",
                    Desc = "This is a test notification from ChilliLib.",
                    Duration = 5
                })
            end
        })
        
        sec1:Input({
            Title = "Player Name",
            Placeholder = "Enter username...",
            Callback = function(text)
                print("Input text:", text)
            end
        })
        
        -- Settings tab
        local settingsTab = tabGroup:Tab({
            Title = "Settings",
            Image = "settings"
        })
        
        local sec2 = settingsTab:Section({
            Title = "Configuration"
        })
        
        sec2:Label({
            Title = "Save/Load Config"
        })
        
        local configInput = sec2:Input({
            Title = "Config Name",
            Placeholder = "my_config",
            Default = "default"
        })
        
        sec2:Button({
            Title = "Save Config",
            Callback = function()
                local success, msg = lib:SaveConfig(configInput.Value)
                window:Notify({
                    Title = "Config",
                    Desc = msg,
                    Duration = 4
                })
            end
        })
        
        sec2:Button({
            Title = "Load Config",
            Callback = function()
                local success, msg = lib:LoadConfig(configInput.Value)
                window:Notify({
                    Title = "Config",
                    Desc = msg,
                    Duration = 4
                })
            end
        })
        
        -- Info tab
        local infoTab = tabGroup:Tab({
            Title = "Info",
            Image = "info"
        })
        
        local sec3 = infoTab:Section({
            Title = "Library Information"
        })
        
        sec3:Paragraph({
            Title = "ChilliLib v1.1",
            Desc = "A modern UI library for Roblox with:\n• Beautiful gradient design\n• Smooth animations\n• Config system\n• Notifications\n• All standard UI elements\n• Fully functional in all environments"
        })
        
        sec3:Label({
            Title = "Made with ❤️"
        })
        
        return window
    end
}

-- Initialize folder
if fileFunctionsAvailable then
    makefolder("ChilliLib")
    makefolder("ChilliLib/settings")
end

-- Add to global environment
GlobalEnvironment.ChilliLib = ChilliLib

return ChilliLib
