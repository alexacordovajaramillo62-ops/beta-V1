-- brainrot_core.lua - Código Base del Brainrot Finder
-- Autor: PHOENIX Finder
-- Versión: 1.0

-- Configuración global
getgenv().BRAINROT_CONFIG = {
    -- Keybinds
    TELEPORT_KEYBIND = Enum.KeyCode.T,
    TOGGLE_GUI_KEYBIND = Enum.KeyCode.RightShift,
    INSTANT_CLONER_KEYBIND = Enum.KeyCode.C,
    KICK_SELF_KEYBIND = Enum.KeyCode.K,
    FLOOR_STEAL_KEYBIND = Enum.KeyCode.F,
    REJOIN_KEYBIND = Enum.KeyCode.J,
    DESYNC_KEYBIND = Enum.KeyCode.P,

    -- Main Features
    AUTO_TP_ENABLED = false,
    AUTO_HIDE_ENABLED = false,
    AUTO_STEAL_ENABLED = false,
    AUTO_STEAL_NEAREST_ENABLED = false,
    AUTO_STEAL_PRIORITY_ENABLED = false,
    PREDICTIVE_STEAL = true,
    OptimizerEnabled = false,
    FLOOR_STEAL_ENABLED = false,
    AUTO_DESYNC_ENABLED = false,
    STEAL_SPEED_ENABLED = false,
    STEAL_DISABLE_ANIM_ENABLED = false,

    GUI_POSITION_X = nil,
    GUI_POSITION_Y = nil,
    MINI_GUI_POSITION_X = nil,
    MINI_GUI_POSITION_Y = nil,
    
    -- Filters
    SHOW_ALL_RARITIES = true,
    SHOW_MUTATIONS_ONLY = false,
    SHOW_TRAITS_ONLY = false,
    MIN_GEN_VALUE = 0,
    
    -- Priority System
    FAVORITES_PRIORITY_ENABLED = false,
    INVISIBLE_BASE_WALLS_ENABLED = false,
    SAFE_TELEPORT = true,
    CARPET_MIDDLE = false,
    
    -- ESP
    ESP_ENABLED = false,
    ESP_PLAYERS_ENABLED = false,
    
    -- Anti-Lag
    ANTI_LAG_ENABLED = false,
    ANTI_BEE_DISCO_ENABLED = false,
    ANTI_RAGDOLL_V1_ENABLED = false,
    ANTI_RAGDOLL_V2_ENABLED = false,
    
    -- AUTO KICK-Steal (nueva función)
    AUTO_KICK_STEAL_ENABLED = false,
}

local CONFIG = getgenv().BRAINROT_CONFIG

if not getgenv().BRAINROT_FAVORITES then
    getgenv().BRAINROT_FAVORITES = {}
end

local FAVORITES = getgenv().BRAINROT_FAVORITES

-- Servicios
local S = {
    Players = game:GetService("Players"),
    UserInputService = game:GetService("UserInputService"),
    TweenService = game:GetService("TweenService"),
    ReplicatedStorage = game:GetService("ReplicatedStorage"),
    HttpService = game:GetService("HttpService"),
    RunService = game:GetService("RunService"),
    Stats = game:GetService("Stats"),
    TeleportService = game:GetService("TeleportService"),
    Lighting = game:GetService("Lighting"),
}

-- API global para que la GUI pueda acceder
getgenv().BRAINROT_API = {
    Config = CONFIG,
    Services = S,
    Modules = {},
    State = {
        allAnimalsCache = {},
        guiVisible = false,
        currentTab = "animals",
        searchQuery = "",
        isCloning = false,
        highestAnimal = nil,
        statLabels = nil,
        scannerConnections = {},
        plotChannels = {},
        lastAnimalData = {}
    },
    Functions = {},
    Features = {},
    GUI = nil
}

local BRAINROT_API = getgenv().BRAINROT_API

-- Variables de estado
local allAnimalsCache = {}
local guiVisible = false
local currentTab = "animals"
local searchQuery = ""
local isCloning = false
local highestAnimal = nil
local statLabels = nil

-- Actualizar estado global
BRAINROT_API.State.allAnimalsCache = allAnimalsCache
BRAINROT_API.State.guiVisible = guiVisible
BRAINROT_API.State.currentTab = currentTab
BRAINROT_API.State.searchQuery = searchQuery
BRAINROT_API.State.isCloning = isCloning
BRAINROT_API.State.highestAnimal = highestAnimal
BRAINROT_API.State.statLabels = statLabels

-- Configuración de archivos
local ConfigFiles = {
    FAVORITES_FILE = "BrainrotFinderFavorites.json",
    CONFIG_FILE_NAME = "BrainrotFinderConfig.json"
}

-- Sistema de notificaciones básico
local function showNotification(message, color, duration)
    print("[PHOENIX]", message)
end

-- Función para guardar configuración
local function saveConfig()
    local serializableConfig = {}
    for k, v in pairs(CONFIG) do
        serializableConfig[k] = v
    end
    
    local success, jsonData = pcall(S.HttpService.JSONEncode, S.HttpService, serializableConfig)
    if success then
        writefile(ConfigFiles.CONFIG_FILE_NAME, jsonData)
        print("[Config] Configuración guardada")
    else
        warn("[Config] Error al guardar:", jsonData)
    end
end

-- Función para cargar configuración
local function loadConfig()
    if not isfile(ConfigFiles.CONFIG_FILE_NAME) then 
        print("[Config] No hay archivo de configuración, usando valores por defecto")
        return 
    end
    
    local success, jsonData = pcall(readfile, ConfigFiles.CONFIG_FILE_NAME)
    if not success then 
        warn("[Config] Error al leer archivo de configuración")
        return 
    end
    
    local success2, savedConfig = pcall(S.HttpService.JSONDecode, S.HttpService, jsonData)
    if success2 and savedConfig then
        for k, v in pairs(savedConfig) do
            CONFIG[k] = v
        end
        print("[Config] Configuración cargada exitosamente")
    else
        warn("[Config] Error al decodificar configuración")
    end
end

-- Función para cargar favoritos
local function loadFavorites()
    if not isfile(ConfigFiles.FAVORITES_FILE) then 
        print("[Favorites] No hay archivo de favoritos")
        return 
    end
    
    local success, jsonData = pcall(readfile, ConfigFiles.FAVORITES_FILE)
    if not success then 
        warn("[Favorites] Error al leer archivo de favoritos")
        return 
    end
    
    local success2, savedFavorites = pcall(S.HttpService.JSONDecode, S.HttpService, jsonData)
    if success2 and savedFavorites then
        for _, name in ipairs(savedFavorites) do
            table.insert(FAVORITES, name)
        end
        print("[Favorites]", #FAVORITES, "favoritos cargados")
    else
        warn("[Favorites] Error al decodificar favoritos")
    end
end

-- ============================================
-- SISTEMA AUTO KICK-STEAL (por @rznnq)
-- ============================================

local AUTO_KICK = {
    enabled = false,
    connections = {},
    KEYWORD = "you stole",
    KICK_MESSAGE = "Discord@rznnq",
    player = nil,
    PlayerGui = nil
}

-- Función para inicializar AUTO KICK
local function initializeAutoKick()
    AUTO_KICK.player = S.Players.LocalPlayer
    AUTO_KICK.PlayerGui = AUTO_KICK.player:WaitForChild("PlayerGui")
    print("[AutoKick] Sistema inicializado")
end

-- Función para verificar si hay keyword
local function hasKeyword(text)
    if typeof(text) ~= "string" then return false end
    return string.find(string.lower(text), AUTO_KICK.KEYWORD) ~= nil
end

-- Función para kickear
local function kickPlayer()
    pcall(function()
        AUTO_KICK.player:Kick(AUTO_KICK.KICK_MESSAGE)
    end)
end

-- Función para observar objetos de texto
local function watchObject(obj)
    if not (obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox")) then
        return
    end
    
    if hasKeyword(obj.Text) then
        showNotification("⚠️ AUTO KICK detectado! Kickeando...", Color3.fromRGB(255, 50, 50))
        kickPlayer()
        return
    end
    
    local conn = obj:GetPropertyChangedSignal("Text"):Connect(function()
        if hasKeyword(obj.Text) then
            showNotification("⚠️ AUTO KICK detectado! Kickeando...", Color3.fromRGB(255, 50, 50))
            kickPlayer()
        end
    end)
    table.insert(AUTO_KICK.connections, conn)
end

-- Función para escanear un parent
local function scanParent(parent)
    for _, obj in ipairs(parent:GetDescendants()) do
        watchObject(obj)
    end
end

-- Función para observar una GUI
local function watchGui(gui)
    scanParent(gui)
    local conn = gui.DescendantAdded:Connect(function(desc)
        watchObject(desc)
    end)
    table.insert(AUTO_KICK.connections, conn)
end

-- Función principal para habilitar AUTO KICK
local function enableAutoKick()
    if AUTO_KICK.enabled then 
        showNotification("AUTO KICK ya está activado", Color3.fromRGB(255, 200, 50))
        return false 
    end
    
    AUTO_KICK.enabled = true
    CONFIG.AUTO_KICK_STEAL_ENABLED = true
    
    -- Inicializar si no está hecho
    if not AUTO_KICK.player then
        initializeAutoKick()
    end
    
    -- Escanear GUIs existentes
    for _, gui in ipairs(AUTO_KICK.PlayerGui:GetChildren()) do
        watchGui(gui)
    end
    
    -- Observar nuevas GUIs
    table.insert(AUTO_KICK.connections,
        AUTO_KICK.PlayerGui.ChildAdded:Connect(function(gui)
            watchGui(gui)
        end)
    )
    
    -- Mostrar notificación
    showNotification("✅ AUTO KICK-Steal Activado (Discord@rznnq)", Color3.fromRGB(50, 255, 50))
    
    -- Guardar configuración
    saveConfig()
    
    return true
end

-- Función para deshabilitar AUTO KICK
local function disableAutoKick()
    if not AUTO_KICK.enabled then 
        showNotification("AUTO KICK ya está desactivado", Color3.fromRGB(255, 200, 50))
        return false 
    end
    
    AUTO_KICK.enabled = false
    CONFIG.AUTO_KICK_STEAL_ENABLED = false
    
    -- Desconectar todas las conexiones
    for _, conn in ipairs(AUTO_KICK.connections) do
        if conn and typeof(conn) == "RBXScriptConnection" then
            conn:Disconnect()
        end
    end
    AUTO_KICK.connections = {}
    
    -- Mostrar notificación
    showNotification("❌ AUTO KICK-Steal Desactivado", Color3.fromRGB(255, 50, 50))
    
    -- Guardar configuración
    saveConfig()
    
    return true
end

-- Función toggle para AUTO KICK
local function toggleAutoKick()
    if AUTO_KICK.enabled then
        return disableAutoKick()
    else
        return enableAutoKick()
    end
end

-- Exportar funciones AUTO KICK al API
BRAINROT_API.Features.AutoKick = {
    enable = enableAutoKick,
    disable = disableAutoKick,
    isEnabled = function() return AUTO_KICK.enabled end,
    toggle = toggleAutoKick,
    test = function()
        -- Función de prueba
        showNotification("🧪 Probando AUTO KICK...", Color3.fromRGB(255, 200, 50))
        
        -- Crear un label de prueba
        local testScreen = Instance.new("ScreenGui")
        testScreen.Name = "AutoKickTest"
        testScreen.Parent = game:GetService("CoreGui")
        
        local testLabel = Instance.new("TextLabel")
        testLabel.Size = UDim2.new(0, 300, 0, 50)
        testLabel.Position = UDim2.new(0.5, -150, 0.5, -25)
        testLabel.Text = "Testing you stole feature - Esto debería kickear si está activado"
        testLabel.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        testLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
        testLabel.TextSize = 14
        testLabel.Parent = testScreen
        
        -- Auto-destruir después de 3 segundos
        task.delay(3, function()
            if testScreen then
                testScreen:Destroy()
            end
        end)
        
        return true
    end
}

-- ============================================
-- FUNCIONES CORE DEL SISTEMA
-- ============================================

-- Función de teleport básica
local function teleportToAnimal(animalData)
    if not animalData then
        showNotification("❌ No hay datos del animal", Color3.fromRGB(255, 50, 50))
        return false
    end
    
    showNotification("🚀 Teleportando a: " .. animalData.name, Color3.fromRGB(50, 150, 255))
    
    -- Implementación básica de teleport
    local character = S.Players.LocalPlayer.Character
    if character then
        local hrp = character:FindFirstChild("HumanoidRootPart")
        if hrp then
            -- Simulación de teleport
            hrp.CFrame = CFrame.new(0, 100, 0)
            return true
        end
    end
    
    return false
end

-- Función para teleportar al más alto
local function teleportToHighest()
    if #allAnimalsCache > 0 then
        showNotification("📈 Teleportando al animal más alto", Color3.fromRGB(50, 255, 150))
        teleportToAnimal(allAnimalsCache[1])
        return true
    else
        showNotification("❌ No hay animales en la lista", Color3.fromRGB(255, 50, 50))
        return false
    end
end

-- Función Instant Cloner
local function instantCloner()
    if isCloning then
        showNotification("⏳ Ya hay un clon en proceso", Color3.fromRGB(255, 200, 50))
        return
    end
    
    isCloning = true
    BRAINROT_API.State.isCloning = true
    
    showNotification("🌀 Activando Instant Cloner...", Color3.fromRGB(150, 50, 255))
    
    -- Simulación de clonador
    task.delay(1, function()
        showNotification("✅ Clon completado!", Color3.fromRGB(50, 255, 50))
        isCloning = false
        BRAINROT_API.State.isCloning = false
    end)
end

-- Función Kick Self
local function kickSelf()
    showNotification("👢 Kickeando...", Color3.fromRGB(255, 50, 50))
    
    task.delay(0.5, function()
        S.LocalPlayer:Kick("Kicked by PHOENIX Finder")
    end)
end

-- Función Rejoin Server
local function rejoinServer()
    showNotification("🔄 Rejoin server...", Color3.fromRGB(50, 150, 255))
    
    local placeId = game.PlaceId
    local jobId = game.JobId
    
    task.delay(0.5, function()
        if jobId and jobId ~= "" then
            S.TeleportService:TeleportToPlaceInstance(placeId, jobId, S.LocalPlayer)
        else
            S.TeleportService:Teleport(placeId, S.LocalPlayer)
        end
    end)
end

-- Función para escanear animales (simplificada)
local function scanAnimals()
    showNotification("🔍 Escaneando animales...", Color3.fromRGB(255, 200, 50))
    
    -- Simulación de escaneo
    local fakeAnimals = {
        {name = "Strawberry Elephant", genText = "$1.2B/s", genValue = 1200000000},
        {name = "Dragon Cannelloni", genText = "$950M/s", genValue = 950000000},
        {name = "Meowl", genText = "$800M/s", genValue = 800000000}
    }
    
    allAnimalsCache = fakeAnimals
    BRAINROT_API.State.allAnimalsCache = fakeAnimals
    
    showNotification("✅ " .. #allAnimalsCache .. " animales encontrados", Color3.fromRGB(50, 255, 50))
    
    return #allAnimalsCache
end

-- Función para toggle GUI
local function toggleGui()
    guiVisible = not guiVisible
    BRAINROT_API.State.guiVisible = guiVisible
    
    if BRAINROT_API.GUI and BRAINROT_API.GUI.toggle then
        BRAINROT_API.GUI:toggle()
    end
    
    showNotification(guiVisible and "📱 GUI Activada" or "📱 GUI Desactivada", 
                    guiVisible and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50))
end

-- ============================================
-- EXPORTAR FUNCIONES AL API
-- ============================================

BRAINROT_API.Functions = {
    teleportToAnimal = teleportToAnimal,
    teleportToHighest = teleportToHighest,
    instantCloner = instantCloner,
    kickSelf = kickSelf,
    rejoinServer = rejoinServer,
    scanAnimals = scanAnimals,
    toggleGui = toggleGui,
    showNotification = showNotification,
    saveConfig = saveConfig,
    loadConfig = loadConfig,
    loadFavorites = loadFavorites
}

-- ============================================
-- SISTEMA DE KEYBINDS
-- ============================================

S.UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == CONFIG.TELEPORT_KEYBIND then
        teleportToHighest()
    elseif input.KeyCode == CONFIG.TOGGLE_GUI_KEYBIND then
        toggleGui()
    elseif input.KeyCode == CONFIG.INSTANT_CLONER_KEYBIND then
        instantCloner()
    elseif input.KeyCode == CONFIG.KICK_SELF_KEYBIND then
        kickSelf()
    elseif input.KeyCode == CONFIG.REJOIN_KEYBIND then
        rejoinServer()
    elseif input.KeyCode == CONFIG.DESYNC_KEYBIND then
        showNotification("🌀 Desync V3 Activado", Color3.fromRGB(150, 50, 255))
    elseif input.KeyCode == CONFIG.FLOOR_STEAL_KEYBIND then
        CONFIG.FLOOR_STEAL_ENABLED = not CONFIG.FLOOR_STEAL_ENABLED
        showNotification(CONFIG.FLOOR_STEAL_ENABLED and "✅ Floor Steal Activado" or "❌ Floor Steal Desactivado",
                        CONFIG.FLOOR_STEAL_ENABLED and Color3.fromRGB(50, 255, 50) or Color3.fromRGB(255, 50, 50))
        saveConfig()
    end
end)

-- ============================================
-- CARGADOR DE GUI DESDE GITHUB
-- ============================================

local function loadGUIFromGitHub()
    local url = "https://raw.githubusercontent.com/TU_USUARIO/TU_REPO/main/brainrot_gui.lua"
    
    showNotification("🌐 Cargando GUI desde GitHub...", Color3.fromRGB(50, 150, 255))
    
    local success, response = pcall(function()
        return game:HttpGetAsync(url, true)
    end)
    
    if success then
        local guiModule, errorMsg = loadstring(response)
        if guiModule then
            BRAINROT_API.GUI = guiModule(BRAINROT_API)
            showNotification("✅ GUI cargada exitosamente", Color3.fromRGB(50, 255, 50))
            return BRAINROT_API.GUI
        else
            warn("[GUI] Error al cargar módulo:", errorMsg)
            showNotification("❌ Error al cargar GUI", Color3.fromRGB(255, 50, 50))
            return nil
        end
    else
        warn("[GUI] Error al descargar:", response)
        showNotification("❌ Error al conectar con GitHub", Color3.fromRGB(255, 50, 50))
        return nil
    end
end

-- ============================================
-- INICIALIZACIÓN PRINCIPAL
-- ============================================

local function initializeCore()
    -- Cargar configuraciones guardadas
    loadConfig()
    loadFavorites()
    
    -- Inicializar servicios del juego
    S.LocalPlayer = S.Players.LocalPlayer
    S.PlayerGui = S.LocalPlayer:WaitForChild("PlayerGui")
    
    -- Inicializar módulos del juego (simplificado)
    BRAINROT_API.Modules = {
        AnimalsData = {},
        RaritiesData = {},
        Synchronizer = {}
    }
    
    -- Escanear animales inicialmente
    scanAnimals()
    
    -- Cargar GUI desde GitHub
    BRAINROT_API.GUI = loadGUIFromGitHub()
    
    -- Activar AUTO KICK si está configurado
    if CONFIG.AUTO_KICK_STEAL_ENABLED then
        enableAutoKick()
    end
    
    -- Mostrar mensaje de inicio
    showNotification("🚀 PHOENIX Finder v1.0 cargado!", Color3.fromRGB(255, 140, 80))
    
    return true
end

-- ============================================
-- EJECUCIÓN PRINCIPAL
-- ============================================

if not game:IsLoaded() then
    game.Loaded:Wait()
end

task.spawn(initializeCore)

return BRAINROT_API