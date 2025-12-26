-- PureFX UI Library - Version 1.0
-- Librería de interfaz 100% sin imágenes, solo efectos visuales

local PureFX = {
    Version = "1.0",
    Theme = "Dark",
    Windows = {},
    CurrentWindow = nil
}

-- Servicios
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")

-- Paleta de colores para efectos
PureFX.ColorSchemes = {
    Dark = {
        Background = Color3.fromRGB(18, 18, 24),
        Surface = Color3.fromRGB(30, 30, 40),
        SurfaceLight = Color3.fromRGB(45, 45, 60),
        Primary = Color3.fromRGB(100, 150, 255),
        Secondary = Color3.fromRGB(120, 220, 180),
        Accent = Color3.fromRGB(255, 120, 100),
        Text = Color3.fromRGB(240, 240, 245),
        TextMuted = Color3.fromRGB(180, 180, 200),
        Border = Color3.fromRGB(60, 60, 80),
        Success = Color3.fromRGB(100, 220, 140),
        Warning = Color3.fromRGB(255, 200, 80),
        Error = Color3.fromRGB(255, 100, 100)
    },
    Light = {
        Background = Color3.fromRGB(245, 245, 250),
        Surface = Color3.fromRGB(255, 255, 255),
        SurfaceLight = Color3.fromRGB(240, 240, 245),
        Primary = Color3.fromRGB(80, 130, 235),
        Secondary = Color3.fromRGB(100, 200, 160),
        Accent = Color3.fromRGB(235, 100, 80),
        Text = Color3.fromRGB(30, 30, 40),
        TextMuted = Color3.fromRGB(100, 100, 120),
        Border = Color3.fromRGB(220, 220, 230),
        Success = Color3.fromRGB(80, 200, 120),
        Warning = Color3.fromRGB(235, 180, 60),
        Error = Color3.fromRGB(235, 80, 80)
    },
    Neon = {
        Background = Color3.fromRGB(10, 10, 20),
        Surface = Color3.fromRGB(20, 20, 35),
        SurfaceLight = Color3.fromRGB(30, 30, 50),
        Primary = Color3.fromRGB(0, 255, 255),
        Secondary = Color3.fromRGB(255, 0, 255),
        Accent = Color3.fromRGB(255, 255, 0),
        Text = Color3.fromRGB(255, 255, 255),
        TextMuted = Color3.fromRGB(180, 180, 220),
        Border = Color3.fromRGB(80, 80, 120),
        Success = Color3.fromRGB(0, 255, 150),
        Warning = Color3.fromRGB(255, 150, 0),
        Error = Color3.fromRGB(255, 50, 50)
    }
}

-- Configuración actual de colores
PureFX.Colors = PureFX.ColorSchemes.Dark

-- Función para cambiar tema
function PureFX:SetTheme(themeName)
    if self.ColorSchemes[themeName] then
        self.Colors = self.ColorSchemes[themeName]
        self.Theme = themeName
        return true
    end
    return false
end

-- ======================
-- FUNCIONES DE EFECTOS VISUALES
-- ======================

-- Efecto de pulso luminoso
function PureFX:CreatePulseEffect(frame, color, speed)
    local pulseFrame = Instance.new("Frame")
    pulseFrame.Size = UDim2.new(1, 0, 1, 0)
    pulseFrame.BackgroundColor3 = color
    pulseFrame.BackgroundTransparency = 0.8
    pulseFrame.BorderSizePixel = 0
    pulseFrame.ZIndex = frame.ZIndex - 1
    pulseFrame.Parent = frame
    
    local pulseTween = TweenService:Create(pulseFrame, TweenInfo.new(
        speed or 1, 
        Enum.EasingStyle.Sine, 
        Enum.EasingDirection.InOut, 
        -1, 
        true
    ), {
        BackgroundTransparency = 0.3,
        Size = UDim2.new(1.2, 0, 1.2, 0),
        Position = UDim2.new(-0.1, 0, -0.1, 0)
    })
    
    pulseTween:Play()
    return pulseFrame, pulseTween
end

-- Efecto de gradiente animado
function PureFX:CreateAnimatedGradient(frame, colors, rotationSpeed)
    local gradient = Instance.new("UIGradient")
    gradient.Color = ColorSequence.new(colors)
    gradient.Rotation = 0
    gradient.Parent = frame
    
    if rotationSpeed then
        local connection
        connection = RunService.RenderStepped:Connect(function(delta)
            gradient.Rotation = (gradient.Rotation + rotationSpeed * delta) % 360
        end)
        
        -- Guardar conexión para limpiar después
        gradient:SetAttribute("RotationConnection", connection)
    end
    
    return gradient
end

-- Efecto de borde brillante
function PureFX:CreateGlowBorder(frame, thickness, color)
    local border = Instance.new("UIStroke")
    border.Thickness = thickness or 2
    border.Color = color or self.Colors.Primary
    border.Transparency = 0.3
    border.Parent = frame
    
    local glowTween = TweenService:Create(border, TweenInfo.new(
        1.5, 
        Enum.EasingStyle.Sine, 
        Enum.EasingDirection.InOut, 
        -1, 
        true
    ), {
        Transparency = 0.7
    })
    
    glowTween:Play()
    return border, glowTween
end

-- Efecto de partículas simuladas (usando frames)
function PureFX:CreateParticleEffect(container, count, color)
    for i = 1, count do
        local particle = Instance.new("Frame")
        particle.Size = UDim2.new(0, math.random(2, 6), 0, math.random(2, 6))
        particle.Position = UDim2.new(
            math.random() * 0.9, 
            0, 
            math.random() * 0.9, 
            0
        )
        particle.BackgroundColor3 = color or self.Colors.Primary
        particle.BorderSizePixel = 0
        particle.ZIndex = container.ZIndex + 1
        particle.Parent = container
        
        -- Animación de flotación
        local floatTween = TweenService:Create(particle, TweenInfo.new(
            math.random(2, 4), 
            Enum.EasingStyle.Sine, 
            Enum.EasingDirection.InOut, 
            -1, 
            true
        ), {
            Position = UDim2.new(
                particle.Position.X.Scale + math.random() * 0.1 - 0.05,
                0,
                particle.Position.Y.Scale + math.random() * 0.1 - 0.05,
                0
            ),
            BackgroundTransparency = math.random() * 0.7 + 0.3
        })
        
        floatTween:Play()
        particle:SetAttribute("FloatTween", floatTween)
    end
end

-- ======================
-- COMPONENTES BÁSICOS
-- ======================

-- Crear un botón con efectos
function PureFX:CreateButton(parent, config)
    config = config or {}
    local buttonFrame = Instance.new("Frame")
    buttonFrame.Size = config.Size or UDim2.new(1, 0, 0, 36)
    buttonFrame.BackgroundColor3 = self.Colors.Surface
    buttonFrame.BorderSizePixel = 0
    buttonFrame.Parent = parent
    
    -- Esquinas redondeadas
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = buttonFrame
    
    -- Borde con efecto de glow
    local border = self:CreateGlowBorder(buttonFrame, 2, self.Colors.Primary)
    
    -- Texto del botón
    local buttonText = Instance.new("TextLabel")
    buttonText.Size = UDim2.new(1, 0, 1, 0)
    buttonText.BackgroundTransparency = 1
    buttonText.Text = config.Text or "Button"
    buttonText.Font = Enum.Font.GothamBold
    buttonText.TextColor3 = self.Colors.Text
    buttonText.TextSize = 14
    buttonText.Parent = buttonFrame
    
    -- Efecto de hover
    local hoverEffect = Instance.new("Frame")
    hoverEffect.Size = UDim2.new(1, 0, 1, 0)
    hoverEffect.BackgroundColor3 = self.Colors.Primary
    hoverEffect.BackgroundTransparency = 1
    hoverEffect.BorderSizePixel = 0
    hoverEffect.Parent = buttonFrame
    
    local hoverCorner = Instance.new("UICorner")
    hoverCorner.CornerRadius = UDim.new(0, 8)
    hoverCorner.Parent = hoverEffect
    
    -- Eventos de interactividad
    local isHovering = false
    
    buttonFrame.MouseEnter:Connect(function()
        isHovering = true
        TweenService:Create(hoverEffect, TweenInfo.new(0.2)):Play({
            BackgroundTransparency = 0.8
        })
        TweenService:Create(buttonFrame, TweenInfo.new(0.2)):Play({
            BackgroundColor3 = self.Colors.SurfaceLight
        })
    end)
    
    buttonFrame.MouseLeave:Connect(function()
        isHovering = false
        TweenService:Create(hoverEffect, TweenInfo.new(0.2)):Play({
            BackgroundTransparency = 1
        })
        TweenService:Create(buttonFrame, TweenInfo.new(0.2)):Play({
            BackgroundColor3 = self.Colors.Surface
        })
    end)
    
    -- Click effect
    buttonFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            -- Efecto de pulsación
            local clickTween = TweenService:Create(buttonFrame, TweenInfo.new(0.1)):Play({
                Size = UDim2.new(0.98, 0, 0.95, 0),
                Position = UDim2.new(0.01, 0, 0.025, 0)
            })
            
            task.wait(0.1)
            
            TweenService:Create(buttonFrame, TweenInfo.new(0.1)):Play({
                Size = config.Size or UDim2.new(1, 0, 0, 36),
                Position = UDim2.new(0, 0, 0, 0)
            })
            
            -- Ejecutar callback
            if config.Callback then
                config.Callback()
            end
        end
    end)
    
    return {
        Frame = buttonFrame,
        Text = buttonText,
        SetText = function(self, newText)
            buttonText.Text = newText
        end,
        SetEnabled = function(self, enabled)
            buttonFrame.BackgroundTransparency = enabled and 0 or 0.5
            buttonText.TextTransparency = enabled and 0 or 0.5
        end
    }
end

-- Crear un toggle switch
function PureFX:CreateToggle(parent, config)
    config = config or {}
    local toggleFrame = Instance.new("Frame")
    toggleFrame.Size = config.Size or UDim2.new(1, 0, 0, 38)
    toggleFrame.BackgroundColor3 = self.Colors.Surface
    toggleFrame.BorderSizePixel = 0
    toggleFrame.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = toggleFrame
    
    -- Texto del toggle
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 1, 0)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = config.Text or "Toggle"
    label.Font = Enum.Font.GothamMedium
    label.TextColor3 = self.Colors.Text
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = toggleFrame
    
    -- Switch
    local switchFrame = Instance.new("Frame")
    switchFrame.Size = UDim2.new(0, 50, 0, 24)
    switchFrame.Position = UDim2.new(1, -60, 0.5, -12)
    switchFrame.BackgroundColor3 = self.Colors.Border
    switchFrame.BorderSizePixel = 0
    switchFrame.Parent = toggleFrame
    
    local switchCorner = Instance.new("UICorner")
    switchCorner.CornerRadius = UDim.new(1, 0)
    switchCorner.Parent = switchFrame
    
    -- Knob del switch
    local knob = Instance.new("Frame")
    knob.Size = UDim2.new(0, 20, 0, 20)
    knob.Position = UDim2.new(0, 2, 0.5, -10)
    knob.BackgroundColor3 = self.Colors.Text
    knob.BorderSizePixel = 0
    knob.Parent = switchFrame
    
    local knobCorner = Instance.new("UICorner")
    knobCorner.CornerRadius = UDim.new(1, 0)
    knobCorner.Parent = knob
    
    -- Estado
    local state = config.Default or false
    
    -- Actualizar visualmente
    local function updateVisual()
        if state then
            TweenService:Create(switchFrame, TweenInfo.new(0.2)):Play({
                BackgroundColor3 = self.Colors.Primary
            })
            TweenService:Create(knob, TweenInfo.new(0.2)):Play({
                Position = UDim2.new(1, -22, 0.5, -10)
            })
        else
            TweenService:Create(switchFrame, TweenInfo.new(0.2)):Play({
                BackgroundColor3 = self.Colors.Border
            })
            TweenService:Create(knob, TweenInfo.new(0.2)):Play({
                Position = UDim2.new(0, 2, 0.5, -10)
            })
        end
    end
    
    -- Click
    toggleFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            state = not state
            updateVisual()
            
            if config.Callback then
                config.Callback(state)
            end
        end
    end)
    
    -- Inicializar
    updateVisual()
    
    return {
        Frame = toggleFrame,
        State = state,
        SetState = function(self, newState)
            state = newState
            updateVisual()
        end,
        Toggle = function(self)
            state = not state
            updateVisual()
            if config.Callback then
                config.Callback(state)
            end
        end
    }
end

-- Crear un slider
function PureFX:CreateSlider(parent, config)
    config = config or {}
    config.Min = config.Min or 0
    config.Max = config.Max or 100
    config.Default = config.Default or 50
    
    local sliderFrame = Instance.new("Frame")
    sliderFrame.Size = config.Size or UDim2.new(1, 0, 0, 50)
    sliderFrame.BackgroundColor3 = self.Colors.Surface
    sliderFrame.BorderSizePixel = 0
    sliderFrame.Parent = parent
    
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 8)
    corner.Parent = sliderFrame
    
    -- Texto
    local label = Instance.new("TextLabel")
    label.Size = UDim2.new(0.7, 0, 0, 25)
    label.Position = UDim2.new(0, 10, 0, 0)
    label.BackgroundTransparency = 1
    label.Text = config.Text or "Slider"
    label.Font = Enum.Font.GothamMedium
    label.TextColor3 = self.Colors.Text
    label.TextSize = 14
    label.TextXAlignment = Enum.TextXAlignment.Left
    label.Parent = sliderFrame
    
    -- Valor
    local valueLabel = Instance.new("TextLabel")
    valueLabel.Size = UDim2.new(0, 60, 0, 25)
    valueLabel.Position = UDim2.new(1, -70, 0, 0)
    valueLabel.BackgroundTransparency = 1
    valueLabel.Text = tostring(config.Default)
    valueLabel.Font = Enum.Font.GothamBold
    valueLabel.TextColor3 = self.Colors.Primary
    valueLabel.TextSize = 14
    valueLabel.TextXAlignment = Enum.TextXAlignment.Right
    valueLabel.Parent = sliderFrame
    
    -- Track
    local track = Instance.new("Frame")
    track.Size = UDim2.new(1, -20, 0, 6)
    track.Position = UDim2.new(0, 10, 0, 32)
    track.BackgroundColor3 = self.Colors.Border
    track.BorderSizePixel = 0
    track.Parent = sliderFrame
    
    local trackCorner = Instance.new("UICorner")
    trackCorner.CornerRadius = UDim.new(1, 0)
    trackCorner.Parent = track
    
    -- Fill
    local fill = Instance.new("Frame")
    fill.Size = UDim2.new((config.Default - config.Min) / (config.Max - config.Min), 0, 1, 0)
    fill.BackgroundColor3 = self.Colors.Primary
    fill.BorderSizePixel = 0
    fill.Parent = track
    
    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(1, 0)
    fillCorner.Parent = fill
    
    -- Handle
    local handle = Instance.new("Frame")
    handle.Size = UDim2.new(0, 16, 0, 16)
    handle.Position = UDim2.new(fill.Size.X.Scale, -8, 0.5, -8)
    handle.BackgroundColor3 = self.Colors.Text
    handle.BorderSizePixel = 0
    handle.Parent = track
    
    local handleCorner = Instance.new("UICorner")
    handleCorner.CornerRadius = UDim.new(1, 0)
    handleCorner.Parent = handle
    
    -- Efecto de glow en el handle
    self:CreateGlowBorder(handle, 2, self.Colors.Primary)
    
    -- Lógica del slider
    local isDragging = false
    local currentValue = config.Default
    
    local function updateValue(xPosition)
        local relativeX = math.clamp(
            (xPosition - track.AbsolutePosition.X) / track.AbsoluteSize.X,
            0, 1
        )
        
        currentValue = math.floor(
            config.Min + (config.Max - config.Min) * relativeX
        )
        
        if config.Step then
            currentValue = math.floor(currentValue / config.Step) * config.Step
        end
        
        valueLabel.Text = tostring(currentValue)
        fill.Size = UDim2.new(relativeX, 0, 1, 0)
        handle.Position = UDim2.new(relativeX, -8, 0.5, -8)
        
        if config.Callback then
            config.Callback(currentValue)
        end
    end
    
    -- Eventos
    track.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            updateValue(input.Position.X)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            updateValue(input.Position.X)
        end
    end)
    
    return {
        Frame = sliderFrame,
        Value = currentValue,
        SetValue = function(self, value)
            currentValue = math.clamp(value, config.Min, config.Max)
            updateValue(
                track.AbsolutePosition.X + 
                ((currentValue - config.Min) / (config.Max - config.Min)) * track.AbsoluteSize.X
            )
        end
    }
end

-- ======================
-- SISTEMA DE VENTANAS
-- ======================

function PureFX:CreateWindow(config)
    config = config or {}
    config.Title = config.Title or "PureFX Window"
    config.Size = config.Size or UDim2.new(0, 500, 0, 400)
    config.Theme = config.Theme or self.Theme
    
    -- Crear ScreenGui
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "PureFX_" .. config.Title
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = game.CoreGui
    
    -- Ventana principal
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainWindow"
    mainFrame.Size = config.Size
    mainFrame.Position = UDim2.new(0.5, -config.Size.X.Offset/2, 0.5, -config.Size.Y.Offset/2)
    mainFrame.BackgroundColor3 = self.Colors.Background
    mainFrame.BorderSizePixel = 0
    mainFrame.ClipsDescendants = true
    mainFrame.Parent = screenGui
    
    -- Esquinas redondeadas
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, 12)
    corner.Parent = mainFrame
    
    -- Sombra/glow alrededor
    self:CreateGlowBorder(mainFrame, 4, self.Colors.Primary)
    
    -- Gradiente animado de fondo
    self:CreateAnimatedGradient(mainFrame, {
        self.Colors.Background,
        Color3.fromRGB(
            math.floor(self.Colors.Background.R * 255 * 1.2),
            math.floor(self.Colors.Background.G * 255 * 1.2),
            math.floor(self.Colors.Background.B * 255 * 1.2)
        ),
        self.Colors.Background
    }, 5)
    
    -- Barra de título
    local titleBar = Instance.new("Frame")
    titleBar.Size = UDim2.new(1, 0, 0, 40)
    titleBar.BackgroundColor3 = self.Colors.Surface
    titleBar.BorderSizePixel = 0
    titleBar.Parent = mainFrame
    
    local titleBarCorner = Instance.new("UICorner")
    titleBarCorner.CornerRadius = UDim.new(0, 12, 0, 0)
    titleBarCorner.Parent = titleBar
    
    -- Efecto de partículas en la barra de título
    self:CreateParticleEffect(titleBar, 15, self.Colors.Primary)
    
    -- Título
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -100, 1, 0)
    titleLabel.Position = UDim2.new(0, 15, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = config.Title
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextColor3 = self.Colors.Text
    titleLabel.TextSize = 18
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = titleBar
    
    -- Gradiente en el texto del título
    self:CreateAnimatedGradient(titleLabel, {
        self.Colors.Primary,
        self.Colors.Secondary,
        self.Colors.Accent,
        self.Colors.Primary
    }, 10)
    
    -- Botón de cerrar (solo símbolo)
    local closeButton = Instance.new("TextButton")
    closeButton.Size = UDim2.new(0, 30, 0, 30)
    closeButton.Position = UDim2.new(1, -40, 0.5, -15)
    closeButton.BackgroundColor3 = self.Colors.Error
    closeButton.Text = "✕"
    closeButton.Font = Enum.Font.GothamBold
    closeButton.TextColor3 = Color3.new(1, 1, 1)
    closeButton.TextSize = 18
    closeButton.AutoButtonColor = false
    closeButton.Parent = titleBar
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(1, 0)
    closeCorner.Parent = closeButton
    
    -- Efecto de pulso en el botón de cerrar
    self:CreatePulseEffect(closeButton, self.Colors.Error, 0.8)
    
    -- Contenido
    local contentFrame = Instance.new("Frame")
    contentFrame.Size = UDim2.new(1, -20, 1, -60)
    contentFrame.Position = UDim2.new(0, 10, 0, 50)
    contentFrame.BackgroundTransparency = 1
    contentFrame.Parent = mainFrame
    
    -- Sistema de pestañas
    local tabContainer = Instance.new("Frame")
    tabContainer.Size = UDim2.new(1, 0, 0, 40)
    tabContainer.BackgroundTransparency = 1
    tabContainer.Parent = contentFrame
    
    local tabsContent = Instance.new("Frame")
    tabsContent.Size = UDim2.new(1, 0, 1, -50)
    tabsContent.Position = UDim2.new(0, 0, 0, 50)
    tabsContent.BackgroundTransparency = 1
    tabsContent.Parent = contentFrame
    
    -- Variables internas
    local windowObj = {
        ScreenGui = screenGui,
        MainFrame = mainFrame,
        Content = contentFrame,
        TabContainer = tabContainer,
        TabsContent = tabsContent,
        Tabs = {},
        CurrentTab = nil
    }
    
    -- Funciones
    function windowObj:CreateTab(tabConfig)
        tabConfig = tabConfig or {}
        tabConfig.Name = tabConfig.Name or "Tab"
        tabConfig.Icon = tabConfig.Icon or "✦"
        
        -- Botón de pestaña
        local tabButton = Instance.new("TextButton")
        tabButton.Size = UDim2.new(0, 100, 1, 0)
        tabButton.Position = UDim2.new(#self.Tabs * 0.2, 10, 0, 0)
        tabButton.BackgroundColor3 = PureFX.Colors.SurfaceLight
        tabButton.Text = tabConfig.Icon .. " " .. tabConfig.Name
        tabButton.Font = Enum.Font.GothamMedium
        tabButton.TextColor3 = PureFX.Colors.TextMuted
        tabButton.TextSize = 14
        tabButton.AutoButtonColor = false
        tabButton.Parent = self.TabContainer
        
        local tabCorner = Instance.new("UICorner")
        tabCorner.CornerRadius = UDim.new(0, 8, 0, 0)
        tabCorner.Parent = tabButton
        
        -- Contenido de la pestaña
        local tabContent = Instance.new("ScrollingFrame")
        tabContent.Size = UDim2.new(1, 0, 1, 0)
        tabContent.BackgroundTransparency = 1
        tabContent.ScrollBarThickness = 4
        tabContent.ScrollBarImageColor3 = PureFX.Colors.Primary
        tabContent.Visible = false
        tabContent.Parent = self.TabsContent
        
        local tabContentLayout = Instance.new("UIListLayout")
        tabContentLayout.Padding = UDim.new(0, 10)
        tabContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        tabContentLayout.Parent = tabContent
        
        local tabContentPadding = Instance.new("UIPadding")
        tabContentPadding.PaddingTop = UDim.new(0, 10)
        tabContentPadding.PaddingLeft = UDim.new(0, 10)
        tabContentPadding.PaddingRight = UDim.new(0, 10)
        tabContentPadding.Parent = tabContent
        
        -- Lógica de pestañas
        local tabObj = {
            Button = tabButton,
            Content = tabContent,
            Name = tabConfig.Name
        }
        
        tabButton.MouseButton1Click:Connect(function()
            -- Ocultar todas las pestañas
            for _, otherTab in pairs(self.Tabs) do
                otherTab.Content.Visible = false
                otherTab.Button.BackgroundColor3 = PureFX.Colors.SurfaceLight
                otherTab.Button.TextColor3 = PureFX.Colors.TextMuted
            end
            
            -- Mostrar esta pestaña
            tabContent.Visible = true
            tabButton.BackgroundColor3 = PureFX.Colors.Primary
            tabButton.TextColor3 = PureFX.Colors.Text
            
            -- Efecto de selección
            PureFX:CreatePulseEffect(tabButton, PureFX.Colors.Primary, 0.5)
            
            self.CurrentTab = tabObj
        end)
        
        -- Función para añadir secciones
        function tabObj:CreateSection(sectionConfig)
            sectionConfig = sectionConfig or {}
            sectionConfig.Name = sectionConfig.Name or "Section"
            
            local sectionFrame = Instance.new("Frame")
            sectionFrame.Size = UDim2.new(1, 0, 0, 0)
            sectionFrame.AutomaticSize = Enum.AutomaticSize.Y
            sectionFrame.BackgroundColor3 = PureFX.Colors.Surface
            sectionFrame.BorderSizePixel = 0
            sectionFrame.LayoutOrder = #tabContent:GetChildren()
            sectionFrame.Parent = tabContent
            
            local sectionCorner = Instance.new("UICorner")
            sectionCorner.CornerRadius = UDim.new(0, 8)
            sectionCorner.Parent = sectionFrame
            
            -- Borde con efecto
            PureFX:CreateGlowBorder(sectionFrame, 2, PureFX.Colors.Border)
            
            -- Encabezado
            local header = Instance.new("TextButton")
            header.Size = UDim2.new(1, 0, 0, 40)
            header.BackgroundTransparency = 1
            header.Text = "▶ " .. sectionConfig.Name
            header.Font = Enum.Font.GothamBold
            header.TextColor3 = PureFX.Colors.Text
            header.TextSize = 16
            header.TextXAlignment = Enum.TextXAlignment.Left
            header.Parent = sectionFrame
            
            local headerPadding = Instance.new("UIPadding")
            headerPadding.PaddingLeft = UDim.new(0, 15)
            headerPadding.Parent = header
            
            -- Contenido
            local sectionContent = Instance.new("Frame")
            sectionContent.Size = UDim2.new(1, -20, 0, 0)
            sectionContent.Position = UDim2.new(0, 10, 0, 50)
            sectionContent.AutomaticSize = Enum.AutomaticSize.Y
            sectionContent.BackgroundTransparency = 1
            sectionContent.Visible = false
            sectionContent.Parent = sectionFrame
            
            local contentLayout = Instance.new("UIListLayout")
            contentLayout.Padding = UDim.new(0, 10)
            contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
            contentLayout.Parent = sectionContent
            
            -- Toggle contenido
            local isExpanded = false
            header.MouseButton1Click:Connect(function()
                isExpanded = not isExpanded
                
                if isExpanded then
                    header.Text = "▼ " .. sectionConfig.Name
                    sectionContent.Visible = true
                    
                    -- Efecto de expansión
                    TweenService:Create(sectionFrame, TweenInfo.new(0.3)):Play({
                        BackgroundColor3 = PureFX.Colors.SurfaceLight
                    })
                else
                    header.Text = "▶ " .. sectionConfig.Name
                    sectionContent.Visible = false
                    
                    TweenService:Create(sectionFrame, TweenInfo.new(0.3)):Play({
                        BackgroundColor3 = PureFX.Colors.Surface
                    })
                end
            end)
            
            -- Retornar objeto de sección con métodos para añadir elementos
            local sectionObj = {
                Frame = sectionFrame,
                Content = sectionContent,
                
                AddButton = function(self, buttonConfig)
                    return PureFX:CreateButton(sectionContent, buttonConfig)
                end,
                
                AddToggle = function(self, toggleConfig)
                    return PureFX:CreateToggle(sectionContent, toggleConfig)
                end,
                
                AddSlider = function(self, sliderConfig)
                    return PureFX:CreateSlider(sectionContent, sliderConfig)
                end,
                
                AddLabel = function(self, text)
                    local label = Instance.new("TextLabel")
                    label.Size = UDim2.new(1, 0, 0, 30)
                    label.BackgroundTransparency = 1
                    label.Text = text
                    label.Font = Enum.Font.Gotham
                    label.TextColor3 = PureFX.Colors.TextMuted
                    label.TextSize = 14
                    label.TextWrapped = true
                    label.Parent = sectionContent
                    return label
                end
            }
            
            return sectionObj
        end
        
        table.insert(self.Tabs, tabObj)
        
        -- Seleccionar primera pestaña
        if #self.Tabs == 1 then
            tabButton:MouseButton1Click()
        end
        
        return tabObj
    end
    
    -- Función para cerrar la ventana
    closeButton.MouseButton1Click:Connect(function()
        local closeTween = TweenService:Create(mainFrame, TweenInfo.new(0.3)):Play({
            Size = UDim2.new(0, 0, 0, 0),
            Position = UDim2.new(0.5, 0, 0.5, 0)
        })
        
        task.wait(0.3)
        screenGui:Destroy()
        
        -- Eliminar de la lista de ventanas
        for i, win in pairs(PureFX.Windows) do
            if win == windowObj then
                table.remove(PureFX.Windows, i)
                break
            end
        end
    end)
    
    -- Hacer la ventana arrastrable
    local isDragging = false
    local dragStart, frameStart
    
    titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = true
            dragStart = input.Position
            frameStart = mainFrame.Position
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if isDragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local delta = input.Position - dragStart
            mainFrame.Position = UDim2.new(
                frameStart.X.Scale,
                frameStart.X.Offset + delta.X,
                frameStart.Y.Scale,
                frameStart.Y.Offset + delta.Y
            )
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            isDragging = false
        end
    end)
    
    -- Guardar referencia
    table.insert(self.Windows, windowObj)
    self.CurrentWindow = windowObj
    
    return windowObj
end

-- ======================
-- SISTEMA DE NOTIFICACIONES
-- ======================

function PureFX:Notify(title, message, duration, notificationType)
    duration = duration or 5
    notificationType = notificationType or "Info"
    
    -- Colores según tipo
    local colorMap = {
        Info = self.Colors.Primary,
        Success = self.Colors.Success,
        Warning = self.Colors.Warning,
        Error = self.Colors.Error
    }
    
    local color = colorMap[notificationType] or self.Colors.Primary
    
    -- Crear notificación en todas las ventanas activas
    for _, window in pairs(self.Windows) do
        if window.ScreenGui and window.ScreenGui.Parent then
            -- Crear contenedor de notificaciones si no existe
            local notificationContainer = window.MainFrame:FindFirstChild("NotificationContainer")
            if not notificationContainer then
                notificationContainer = Instance.new("Frame")
                notificationContainer.Name = "NotificationContainer"
                notificationContainer.Size = UDim2.new(0.3, 0, 0, 0)
                notificationContainer.Position = UDim2.new(0.7, 0, 0.05, 0)
                notificationContainer.BackgroundTransparency = 1
                notificationContainer.Parent = window.MainFrame
                
                local containerLayout = Instance.new("UIListLayout")
                containerLayout.Padding = UDim.new(0, 10)
                containerLayout.SortOrder = Enum.SortOrder.LayoutOrder
                containerLayout.HorizontalAlignment = Enum.HorizontalAlignment.Right
                containerLayout.Parent = notificationContainer
            end
            
            -- Crear notificación
            local notification = Instance.new("Frame")
            notification.Size = UDim2.new(1, 0, 0, 80)
            notification.BackgroundColor3 = self.Colors.Surface
            notification.BorderSizePixel = 0
            notification.LayoutOrder = #notificationContainer:GetChildren()
            notification.Parent = notificationContainer
            
            local notificationCorner = Instance.new("UICorner")
            notificationCorner.CornerRadius = UDim.new(0, 8)
            notificationCorner.Parent = notification
            
            -- Borde de color según tipo
            self:CreateGlowBorder(notification, 3, color)
            
            -- Icono según tipo (símbolos Unicode)
            local icons = {
                Info = "ℹ️",
                Success = "✅",
                Warning = "⚠️",
                Error = "❌"
            }
            
            local iconLabel = Instance.new("TextLabel")
            iconLabel.Size = UDim2.new(0, 40, 0, 40)
            iconLabel.Position = UDim2.new(0, 10, 0, 10)
            iconLabel.BackgroundTransparency = 1
            iconLabel.Text = icons[notificationType] or "ℹ️"
            iconLabel.Font = Enum.Font.GothamBold
            iconLabel.TextColor3 = color
            iconLabel.TextSize = 24
            iconLabel.Parent = notification
            
            -- Título
            local titleLabel = Instance.new("TextLabel")
            titleLabel.Size = UDim2.new(1, -60, 0, 25)
            titleLabel.Position = UDim2.new(0, 60, 0, 10)
            titleLabel.BackgroundTransparency = 1
            titleLabel.Text = title
            titleLabel.Font = Enum.Font.GothamBold
            titleLabel.TextColor3 = self.Colors.Text
            titleLabel.TextSize = 16
            titleLabel.TextXAlignment = Enum.TextXAlignment.Left
            titleLabel.Parent = notification
            
            -- Mensaje
            local messageLabel = Instance.new("TextLabel")
            messageLabel.Size = UDim2.new(1, -60, 0, 35)
            messageLabel.Position = UDim2.new(0, 60, 0, 35)
            messageLabel.BackgroundTransparency = 1
            messageLabel.Text = message
            messageLabel.Font = Enum.Font.Gotham
            messageLabel.TextColor3 = self.Colors.TextMuted
            messageLabel.TextSize = 14
            messageLabel.TextWrapped = true
            messageLabel.TextXAlignment = Enum.TextXAlignment.Left
            messageLabel.TextYAlignment = Enum.TextYAlignment.Top
            messageLabel.Parent = notification
            
            -- Barra de progreso (para duración)
            local progressBar = Instance.new("Frame")
            progressBar.Size = UDim2.new(1, 0, 0, 3)
            progressBar.Position = UDim2.new(0, 0, 1, -3)
            progressBar.BackgroundColor3 = color
            progressBar.BorderSizePixel = 0
            progressBar.Parent = notification
            
            local progressCorner = Instance.new("UICorner")
            progressCorner.CornerRadius = UDim.new(0, 0, 0, 8)
            progressCorner.Parent = progressBar
            
            -- Animación de entrada
            notification.Position = UDim2.new(2, 0, 0, 0)
            TweenService:Create(notification, TweenInfo.new(0.3)):Play({
                Position = UDim2.new(0, 0, 0, 0)
            })
            
            -- Animación de la barra de progreso
            local progressTween = TweenService:Create(progressBar, TweenInfo.new(duration)):Play({
                Size = UDim2.new(0, 0, 0, 3)
            })
            
            -- Temporizador para cerrar
            task.delay(duration, function()
                TweenService:Create(notification, TweenInfo.new(0.3)):Play({
                    Position = UDim2.new(2, 0, 0, 0)
                })
                task.wait(0.3)
                notification:Destroy()
            end)
            
            break -- Solo mostrar en una ventana
        end
    end
end

-- ======================
-- FUNCIÓN DE DEMOSTRACIÓN
-- ======================

function PureFX:ShowDemo()
    local demoWindow = self:CreateWindow({
        Title = "PureFX UI Library - Demo",
        Size = UDim2.new(0, 600, 0, 500),
        Theme = "Dark"
    })
    
    -- Pestaña principal
    local mainTab = demoWindow:CreateTab({
        Name = "Principal",
        Icon = "★"
    })
    
    -- Sección de controles
    local controlsSection = mainTab:CreateSection({
        Name = "Controles"
    })
    
    -- Botones de ejemplo
    controlsSection:AddButton({
        Text = "Botón Primario",
        Callback = function()
            self:Notify("Éxito", "Botón presionado correctamente", 3, "Success")
        end
    })
    
    controlsSection:AddButton({
        Text = "Botón con Efecto",
        Callback = function()
            -- Efecto especial
            for i = 1, 3 do
                self:Notify("Efecto", "Efecto visual #" .. i, 1, "Info")
                task.wait(0.5)
            end
        end
    })
    
    -- Toggles
    controlsSection:AddToggle({
        Text = "Habilitar Efectos",
        Default = true,
        Callback = function(state)
            self:Notify("Toggle", "Efectos: " .. (state and "Activados" or "Desactivados"), 2, state and "Success" or "Warning")
        end
    })
    
    controlsSection:AddToggle({
        Text = "Modo Nocturno",
        Default = false,
        Callback = function(state)
            self:SetTheme(state and "Neon" or "Dark")
            self:Notify("Tema", "Tema cambiado a: " .. (state and "Neon" or "Dark"), 2, "Info")
        end
    })
    
    -- Slider
    controlsSection:AddSlider({
        Text = "Intensidad Efectos",
        Min = 0,
        Max = 100,
        Default = 50,
        Step = 5,
        Callback = function(value)
            print("Intensidad ajustada a:", value)
        end
    })
    
    -- Pestaña de efectos
    local effectsTab = demoWindow:CreateTab({
        Name = "Efectos",
        Icon = "✨"
    })
    
    local effectsSection = effectsTab:CreateSection({
        Name = "Efectos Visuales"
    })
    
    effectsSection:AddButton({
        Text = "Efecto de Pulso",
        Callback = function()
            local btn = effectsSection:AddButton({
                Text = "Pulsando...",
                Callback = function() end
            })
            
            -- Añadir efecto de pulso
            local pulseFrame = Instance.new("Frame")
            pulseFrame.Size = UDim2.new(1, 0, 1, 0)
            pulseFrame.BackgroundColor3 = self.Colors.Primary
            pulseFrame.BackgroundTransparency = 0.8
            pulseFrame.BorderSizePixel = 0
            pulseFrame.ZIndex = -1
            pulseFrame.Parent = btn.Frame
            
            TweenService:Create(pulseFrame, TweenInfo.new(
                1, 
                Enum.EasingStyle.Sine, 
                Enum.EasingDirection.InOut, 
                -1, 
                true
            )):Play({
                BackgroundTransparency = 0.3,
                Size = UDim2.new(1.2, 0, 1.2, 0),
                Position = UDim2.new(-0.1, 0, -0.1, 0)
            })
        end
    })
    
    effectsSection:AddButton({
        Text = "Efecto Partículas",
        Callback = function()
            self:CreateParticleEffect(demoWindow.MainFrame, 20, self.Colors.Accent)
            self:Notify("Partículas", "Efecto de partículas activado", 3, "Info")
        end
    })
    
    -- Pestaña de información
    local infoTab = demoWindow:CreateTab({
        Name = "Información",
        Icon = "ℹ️"
    })
    
    local infoSection = infoTab:CreateSection({
        Name = "Acerca de PureFX"
    })
    
    infoSection:AddLabel("PureFX UI Library v" .. self.Version)
    infoSection:AddLabel("Librería 100% libre de imágenes")
    infoSection:AddLabel("Solo efectos visuales y formas básicas")
    infoSection:AddLabel("")
    infoSection:AddLabel("Características:")
    infoSection:AddLabel("• Gradientes animados")
    infoSection:AddLabel("• Efectos de pulso y glow")
    infoSection:AddLabel("• Partículas simuladas")
    infoSection:AddLabel("• Sistema de notificaciones")
    infoSection:AddLabel("• 3 temas predefinidos")
    
    infoSection:AddButton({
        Text = "Mostrar Notificaciones de Prueba",
        Callback = function()
            self:Notify("Info", "Esta es una notificación informativa", 4, "Info")
            task.wait(0.5)
            self:Notify("Éxito", "Operación completada con éxito", 4, "Success")
            task.wait(0.5)
            self:Notify("Advertencia", "Esto es una advertencia", 4, "Warning")
            task.wait(0.5)
            self:Notify("Error", "¡Algo salió mal!", 4, "Error")
        end
    })
    
    return demoWindow
end

-- ======================
-- INICIALIZACIÓN FÁCIL
-- ======================

-- Función para inicializar rápidamente
function PureFX:Init()
    print("PureFX UI Library v" .. self.Version .. " inicializada")
    print("Tema activo: " .. self.Theme)
    print("Efectos disponibles: Pulso, Glow, Partículas, Gradientes")
    return self
end

-- Exportar la librería
return PureFX:Init()
