--!nocheck
--!nolint UnknownGlobal
-- Volt | Pirate Piece Auto Farm Suite
local Players = game:GetService("Players")
if not game:IsLoaded() then game.Loaded:Wait() end
while not Players.LocalPlayer do task.wait() end
local LocalPlayer = Players.LocalPlayer
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")

local HttpService = game:GetService("HttpService")

-- Cleanup previous execution
if _G.VoltCleanup then
    pcall(_G.VoltCleanup)
end

_G.VoltPiratePieceStop = false
_G.VoltCleanup = function()
    _G.VoltPiratePieceStop = true
    local ui = CoreGui:FindFirstChild("VoltPiratePieceUI")
    if ui then ui:Destroy() end
    
    pcall(function()
        local char = LocalPlayer.Character
        local hrp = char and char:FindFirstChild("HumanoidRootPart")
        if hrp and hrp:FindFirstChild("VoltFarmBV") then
            hrp.VoltFarmBV:Destroy()
        end
    end)
end

-- Automatic Quest Loop Toggle Logic
local function fireQuestRemotes()
    -- Esperar a que el personaje y el HumanoidRootPart existan
    local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    char:WaitForChild("HumanoidRootPart", 10)
    
    -- Un pequeño delay extra para asegurar que los remotos del servidor ya respondan
    task.wait(2)
    
    local remotes = ReplicatedStorage:WaitForChild("Remotes", 10)
    local toggleQuest = remotes and remotes:WaitForChild("ToggleQuestLoop", 10)
    
    if toggleQuest then
        pcall(function() toggleQuest:FireServer(1) end)
        task.wait(0.5)
        pcall(function() toggleQuest:FireServer(2) end)
    end
end

-- Run on startup
task.spawn(fireQuestRemotes)

-- Run on shutdown/exit
game:BindToClose(fireQuestRemotes)

-- Helper Functions (for RJ, ServerHop, Shutdown)
local function serverHop()
    fireQuestRemotes()
    task.wait(0.5)
    local Http = game:GetService("HttpService")
    local TPS = game:GetService("TeleportService")
    local Api = "https://games.roblox.com/v1/games/" .. game.PlaceId .. "/servers/Public?sortOrder=Desc&limit=100"
    local function GetServers(cursor)
        local Raw = game:HttpGet(Api .. (cursor and "&cursor=" .. cursor or ""))
        return Http:JSONDecode(Raw)
    end
    local Servers = GetServers()
    local Server = Servers.data[math.random(1, #Servers.data)]
    TPS:TeleportToPlaceInstance(game.PlaceId, Server.id, LocalPlayer)
end

local function reJoin()
    fireQuestRemotes()
    task.wait(0.5)
    game:GetService("TeleportService"):Teleport(game.PlaceId, LocalPlayer)
end

local function safeShutdown()
    fireQuestRemotes()
    task.wait(0.5)
    LocalPlayer:Kick("Safe Shutdown Initiated")
end

-- Configuration & State
local Config = {
    Island1 = false,
    Island2 = false,
    Island3 = false,
    Island4 = false,
    Island5 = false,
    Island6 = false,
    AutoBoss = false,
    AllNPCs = false,
    AllBosses = false,
    AllFarm = false,
    SelectedBoss = "Rayleigh [Lv. 30]",
    Distance = 4,
    Position = "Behind",
    AttackDelay = 0.5,
    AutoCommonChest = false,
    AutoRareChest = false,
    AutoEpicChest = false,
    AutoLegendaryChest = false,
    AutoMythicChest = false,
    AutoSecretChest = false,
    SelectedWeapon = "",
    ShowProfile = true,
    RGBMode = false,
    AutoEquip = false,
    MenuWidth = 500,
    MenuHeight = 350,
    SidebarWidth = 130,
    Island7 = false,
    AutoHaki = false,
    AutoTower = false,
}

local BossData = {
    ["Rayleigh [Lv. 30]"] = {Island = "island1", Giver = "bossEnemyQuestGiver1"},
    ["Mihawk [Lv. 500]"] = {Island = "island2", Giver = "bossEnemyQuestGiver2"},
    ["Blackbeard [Lv. 1000]"] = {Island = "island3", Giver = "bossEnemyQuestGiver3"},
    ["Gojo Boss [Lv. 3333]"] = {Island = "island3", Giver = "", IsGlobal = true},
    ["Shanks [Lv. 2000]"] = {Island = "island4", Giver = "bossEnemyQuestGiver4"},
    ["Grimmjow [Lv. 5000]"] = {Island = "island5", Giver = "bossEnemyQuestGiver5"},
    ["Aizen Boss [Lv. 6666]"] = {Island = "island5", Giver = "", IsGlobal = true},
    ["Mahogara [Lv. 6500]"] = {Island = "island6", Giver = "bossEnemyQuestGiver6"},
    ["Sukona Boss [Lv. 8888]"] = {Island = "island6", Giver = "", IsGlobal = true},
    ["Aokeejee [Lv. 7500]"] = {Island = "island7", Giver = "bossEnemyQuestGiver7"},
}

-- NPC index per island (which GetChildren() index to target)
local _NpcData = {
    {Island = "island1", Index = 3},
    {Island = "island2", Index = 6},
    {Island = "island3", Name = "Whitebeard [Lv. 750]"},
    {Island = "island4", Index = 3},
    {Island = "island5", Index = 5},
    {Island = "island6", Index = 4},
    {Island = "island7", Index = 6},
}

-- All bosses list (non-global regular bosses per island)
local AllBossList = {
    {Island = "island1", Name = "Rayleigh [Lv. 30]"},
    {Island = "island2", Name = "Mihawk [Lv. 500]"},
    {Island = "island3", Name = "Blackbeard [Lv. 1000]"},
    {Island = "island3", Name = "Gojo Boss [Lv. 3333]", IsGlobal = true},
    {Island = "island4", Name = "Shanks [Lv. 2000]"},
    {Island = "island5", Name = "Grimmjow [Lv. 5000]"},
    {Island = "island5", Name = "Aizen Boss [Lv. 6666]", IsGlobal = true},
    {Island = "island6", Name = "Mahogara [Lv. 6500]"},
    {Island = "island6", Name = "Sukona Boss [Lv. 8888]", IsGlobal = true},
    {Island = "island7", Name = "Aokeejee [Lv. 7500]"},
}

local bossQuestTaken = false
local toggleFuncs = {}

local configFileName = "PiratePieceConfig.json"

local function saveConfig()
    if writefile then
        local success, json = pcall(function() return HttpService:JSONEncode(Config) end)
        if success then
            pcall(function() writefile(configFileName, json) end)
        end
    end
end

local function loadConfig()
    if isfile and readfile then
        local success, result = pcall(function()
            if isfile(configFileName) then
                return HttpService:JSONDecode(readfile(configFileName))
            end
            return nil
        end)
        if success and type(result) == "table" then
            for k, v in pairs(result) do
                if Config[k] ~= nil then -- Only load known keys
                    Config[k] = v
                end
            end
        end
    end
end

-- Auto Load Config
loadConfig()

-- Anti AFK
LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- UI Cleanup
if CoreGui:FindFirstChild("VoltPiratePieceUI") then
    CoreGui.VoltPiratePieceUI:Destroy()
end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "VoltPiratePieceUI"
ScreenGui.Parent = CoreGui
ScreenGui.ResetOnSpawn = false
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Parent = ScreenGui
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
MainFrame.Position = UDim2.new(0.5, -250, 0.5, -175)
MainFrame.Size = UDim2.new(0, Config.MenuWidth or 500, 0, Config.MenuHeight or 350)
MainFrame.BorderSizePixel = 0
MainFrame.ClipsDescendants = true
MainFrame.BackgroundTransparency = 1

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 12)
UICorner.Parent = MainFrame

-- Drop Shadow
local Shadow = Instance.new("ImageLabel")
Shadow.Name = "Shadow"
Shadow.Parent = MainFrame
Shadow.BackgroundTransparency = 1
Shadow.Position = UDim2.new(0, -15, 0, -15)
Shadow.Size = UDim2.new(1, 30, 1, 30)
Shadow.ZIndex = 0
Shadow.Image = "rbxassetid://6015897843"
Shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
Shadow.ImageTransparency = 0.5
Shadow.ScaleType = Enum.ScaleType.Slice
Shadow.SliceCenter = Rect.new(49, 49, 450, 450)

local MainStroke = Instance.new("UIStroke")
MainStroke.Parent = MainFrame
MainStroke.Thickness = 1.5
MainStroke.Color = Color3.fromRGB(60, 60, 90)
MainStroke.Transparency = 0.5

local StrokeGradient = Instance.new("UIGradient")
StrokeGradient.Parent = MainStroke

local hue = 0
RunService.RenderStepped:Connect(function(dt)
    if Config.RGBMode then
        MainStroke.Enabled = true
        MainStroke.Transparency = 0
        MainStroke.Thickness = 2
        hue = (hue + dt * 0.2) % 1
        StrokeGradient.Color = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHSV(hue, 1, 1)),
            ColorSequenceKeypoint.new(0.5, Color3.fromHSV((hue + 0.3) % 1, 1, 1)),
            ColorSequenceKeypoint.new(1, Color3.fromHSV((hue + 0.6) % 1, 1, 1))
        })
    else
        MainStroke.Thickness = 1.5
        MainStroke.Transparency = 0.5
        StrokeGradient.Color = ColorSequence.new(Color3.fromRGB(60, 60, 90))
    end
end)

-- Open Animation
task.spawn(function()
    MainFrame.BackgroundTransparency = 1
    local targetSize = MainFrame.Size
    MainFrame.Size = UDim2.new(0, targetSize.X.Offset * 0.9, 0, targetSize.Y.Offset * 0.9)
    MainFrame.Position = UDim2.new(0.5, -(targetSize.X.Offset * 0.9)/2, 0.5, -(targetSize.Y.Offset * 0.9)/2)
    task.wait(0.05)
    TweenService:Create(MainFrame, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        BackgroundTransparency = 0,
        Size = targetSize,
        Position = UDim2.new(0.5, -targetSize.X.Offset/2, 0.5, -targetSize.Y.Offset/2)
    }):Play()
end)

-- Topbar
local Topbar = Instance.new("Frame")
Topbar.Name = "Topbar"
Topbar.Parent = MainFrame
Topbar.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
Topbar.Size = UDim2.new(1, 0, 0, 44)
Topbar.BorderSizePixel = 0

local TopbarGradient = Instance.new("UIGradient")
TopbarGradient.Parent = Topbar
TopbarGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(25, 25, 40)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(18, 18, 28))
})

local TopbarCorner = Instance.new("UICorner")
TopbarCorner.CornerRadius = UDim.new(0, 12)
TopbarCorner.Parent = Topbar

local TopbarFix = Instance.new("Frame")
TopbarFix.Parent = Topbar
TopbarFix.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
TopbarFix.Position = UDim2.new(0, 0, 0.5, 0)
TopbarFix.Size = UDim2.new(1, 0, 0.5, 0)
TopbarFix.BorderSizePixel = 0

-- Topbar accent line
local TopbarLine = Instance.new("Frame")
TopbarLine.Parent = Topbar
TopbarLine.BackgroundColor3 = Color3.fromRGB(80, 120, 255)
TopbarLine.Position = UDim2.new(0, 0, 1, -2)
TopbarLine.Size = UDim2.new(1, 0, 0, 2)
TopbarLine.BorderSizePixel = 0
local TopLineGrad = Instance.new("UIGradient")
TopLineGrad.Parent = TopbarLine
TopLineGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 120, 255)),
    ColorSequenceKeypoint.new(0.5, Color3.fromRGB(160, 100, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(80, 120, 255))
})
TopLineGrad.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 0.5), NumberSequenceKeypoint.new(0.5, 0), NumberSequenceKeypoint.new(1, 0.5)})

local Title = Instance.new("TextLabel")
Title.Parent = Topbar
Title.BackgroundTransparency = 1
Title.Position = UDim2.new(0, 15, 0, 0)
Title.Size = UDim2.new(1, -100, 1, 0)
Title.Font = Enum.Font.GothamBold
Title.Text = "⚡ Volt | Pirate Piece"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.TextSize = 15
Title.TextXAlignment = Enum.TextXAlignment.Left

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Parent = Topbar
CloseBtn.BackgroundColor3 = Color3.fromRGB(255, 70, 70)
CloseBtn.BackgroundTransparency = 0.8
CloseBtn.Position = UDim2.new(1, -38, 0, 10)
CloseBtn.Size = UDim2.new(0, 24, 0, 24)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.Text = "✕"
CloseBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseBtn.TextSize = 12
CloseBtn.AutoButtonColor = false
CloseBtn.BorderSizePixel = 0
local CloseBtnCorner = Instance.new("UICorner")
CloseBtnCorner.CornerRadius = UDim.new(0, 6)
CloseBtnCorner.Parent = CloseBtn
CloseBtn.MouseEnter:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0.2}):Play()
end)
CloseBtn.MouseLeave:Connect(function()
    TweenService:Create(CloseBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0.8}):Play()
end)
CloseBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

-- Minimize Button
local MinBtn = Instance.new("TextButton")
MinBtn.Parent = Topbar
MinBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
MinBtn.BackgroundTransparency = 0.8
MinBtn.Position = UDim2.new(1, -68, 0, 10)
MinBtn.Size = UDim2.new(0, 24, 0, 24)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.Text = "─"
MinBtn.TextColor3 = Color3.fromRGB(255, 200, 100)
MinBtn.TextSize = 12
MinBtn.AutoButtonColor = false
MinBtn.BorderSizePixel = 0
local MinBtnCorner = Instance.new("UICorner")
MinBtnCorner.CornerRadius = UDim.new(0, 6)
MinBtnCorner.Parent = MinBtn
MinBtn.MouseEnter:Connect(function()
    TweenService:Create(MinBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0.2}):Play()
end)
MinBtn.MouseLeave:Connect(function()
    TweenService:Create(MinBtn, TweenInfo.new(0.15), {BackgroundTransparency = 0.8}):Play()
end)
MinBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
end)

-- Dragging Logic
local dragging = false
local dragInput, mousePos, framePos

Topbar.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
        mousePos = input.Position
        framePos = MainFrame.Position
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                dragging = false
            end
        end)
    end
end)

Topbar.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement then
        dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - mousePos
        MainFrame.Position = UDim2.new(framePos.X.Scale, framePos.X.Offset + delta.X, framePos.Y.Scale, framePos.Y.Offset + delta.Y)
    end
end)

-- Resizing Logic
local ResizeHandle = Instance.new("TextButton")
ResizeHandle.Name = "ResizeHandle"
ResizeHandle.Parent = MainFrame
ResizeHandle.BackgroundColor3 = Color3.fromRGB(30, 30, 35)
ResizeHandle.Position = UDim2.new(1, -15, 1, -15)
ResizeHandle.Size = UDim2.new(0, 15, 0, 15)
ResizeHandle.BorderSizePixel = 0
ResizeHandle.ZIndex = 100
ResizeHandle.Text = "↘"
ResizeHandle.TextColor3 = Color3.fromRGB(150, 150, 150)
ResizeHandle.TextSize = 12
ResizeHandle.AutoButtonColor = false

local resizing = false
local resizeStartPos, startSize

ResizeHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        resizing = true
        resizeStartPos = input.Position
        startSize = MainFrame.Size
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                resizing = false
                Config.MenuWidth = MainFrame.Size.X.Offset
                Config.MenuHeight = MainFrame.Size.Y.Offset
                saveConfig()
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and resizing then
        local delta = input.Position - resizeStartPos
        local newWidth = math.max(400, startSize.X.Offset + delta.X)
        local newHeight = math.max(250, startSize.Y.Offset + delta.Y)
        MainFrame.Size = UDim2.new(0, newWidth, 0, newHeight)
    end
end)

-- Toggle Menu with Insert
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.Insert then
        MainFrame.Visible = not MainFrame.Visible
    end
end)

-- Sidebar
local sidebarWidth = Config.SidebarWidth or 140

local Sidebar = Instance.new("Frame")
Sidebar.Name = "Sidebar"
Sidebar.Parent = MainFrame
Sidebar.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
Sidebar.Position = UDim2.new(0, 0, 0, 44)
Sidebar.Size = UDim2.new(0, sidebarWidth, 1, -100)
Sidebar.BorderSizePixel = 0

local ProfileFrame = Instance.new("Frame")
ProfileFrame.Name = "ProfileFrame"
ProfileFrame.Parent = MainFrame
ProfileFrame.BackgroundColor3 = Color3.fromRGB(18, 18, 28)
ProfileFrame.Position = UDim2.new(0, 0, 1, -56)
ProfileFrame.Size = UDim2.new(0, sidebarWidth, 0, 56)
ProfileFrame.BorderSizePixel = 0
ProfileFrame.Visible = Config.ShowProfile

-- Profile separator line
local ProfileSep = Instance.new("Frame")
ProfileSep.Parent = ProfileFrame
ProfileSep.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
ProfileSep.Position = UDim2.new(0.1, 0, 0, 0)
ProfileSep.Size = UDim2.new(0.8, 0, 0, 1)
ProfileSep.BorderSizePixel = 0

local ProfileImage = Instance.new("ImageLabel")
ProfileImage.Parent = ProfileFrame
ProfileImage.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
ProfileImage.Position = UDim2.new(0, 12, 0, 12)
ProfileImage.Size = UDim2.new(0, 32, 0, 32)
ProfileImage.Image = "rbxthumb://type=AvatarHeadShot&id=" .. LocalPlayer.UserId .. "&w=150&h=150"

local ProfileImageCorner = Instance.new("UICorner")
ProfileImageCorner.CornerRadius = UDim.new(1, 0)
ProfileImageCorner.Parent = ProfileImage

-- Profile image glow ring
local ProfileRing = Instance.new("UIStroke")
ProfileRing.Parent = ProfileImage
ProfileRing.Thickness = 2
ProfileRing.Color = Color3.fromRGB(80, 120, 255)
ProfileRing.Transparency = 0.5

local ProfileName = Instance.new("TextLabel")
ProfileName.Parent = ProfileFrame
ProfileName.BackgroundTransparency = 1
ProfileName.Position = UDim2.new(0, 50, 0, 12)
ProfileName.Size = UDim2.new(1, -58, 0, 16)
ProfileName.Font = Enum.Font.GothamBold
ProfileName.Text = LocalPlayer.DisplayName
ProfileName.TextColor3 = Color3.fromRGB(240, 240, 255)
ProfileName.TextSize = 12
ProfileName.TextXAlignment = Enum.TextXAlignment.Left
ProfileName.TextTruncate = Enum.TextTruncate.AtEnd

local ProfileUser = Instance.new("TextLabel")
ProfileUser.Parent = ProfileFrame
ProfileUser.BackgroundTransparency = 1
ProfileUser.Position = UDim2.new(0, 50, 0, 28)
ProfileUser.Size = UDim2.new(1, -58, 0, 14)
ProfileUser.Font = Enum.Font.Gotham
ProfileUser.Text = "@" .. LocalPlayer.Name
ProfileUser.TextColor3 = Color3.fromRGB(100, 110, 140)
ProfileUser.TextSize = 10
ProfileUser.TextXAlignment = Enum.TextXAlignment.Left
ProfileUser.TextTruncate = Enum.TextTruncate.AtEnd

local TabContainer = Instance.new("Frame")
TabContainer.Name = "TabContainer"
TabContainer.Parent = MainFrame
TabContainer.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
TabContainer.Position = UDim2.new(0, sidebarWidth, 0, 44)
TabContainer.Size = UDim2.new(1, -sidebarWidth, 1, -44)
TabContainer.BorderSizePixel = 0

local ResizeSidebarHandle = Instance.new("TextButton")
ResizeSidebarHandle.Name = "ResizeSidebarHandle"
ResizeSidebarHandle.Parent = MainFrame
ResizeSidebarHandle.BackgroundColor3 = Color3.fromRGB(40, 40, 65)
ResizeSidebarHandle.Position = UDim2.new(0, sidebarWidth, 0, 44)
ResizeSidebarHandle.Size = UDim2.new(0, 3, 1, -44)
ResizeSidebarHandle.BorderSizePixel = 0
ResizeSidebarHandle.ZIndex = 101
ResizeSidebarHandle.Text = ""
ResizeSidebarHandle.AutoButtonColor = false
ResizeSidebarHandle.BackgroundTransparency = 0.6

local resizingSidebar = false
local resizeSidebarStartPos, startSidebarWidth

ResizeSidebarHandle.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        resizingSidebar = true
        resizeSidebarStartPos = input.Position
        startSidebarWidth = sidebarWidth
        
        input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                resizingSidebar = false
                Config.SidebarWidth = sidebarWidth
                saveConfig()
            end
        end)
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement and resizingSidebar then
        local delta = input.Position.X - resizeSidebarStartPos.X
        sidebarWidth = math.clamp(startSidebarWidth + delta, 100, 300)
        
        Sidebar.Size = UDim2.new(0, sidebarWidth, 1, -100)
        ProfileFrame.Size = UDim2.new(0, sidebarWidth, 0, 56)
        TabContainer.Position = UDim2.new(0, sidebarWidth, 0, 44)
        TabContainer.Size = UDim2.new(1, -sidebarWidth, 1, -44)
        ResizeSidebarHandle.Position = UDim2.new(0, sidebarWidth, 0, 44)
    end
end)

local UIListLayout_Sidebar = Instance.new("UIListLayout")
UIListLayout_Sidebar.Parent = Sidebar
UIListLayout_Sidebar.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout_Sidebar.Padding = UDim.new(0, 4)

local UIPadding_Sidebar = Instance.new("UIPadding")
UIPadding_Sidebar.Parent = Sidebar
UIPadding_Sidebar.PaddingTop = UDim.new(0, 12)
UIPadding_Sidebar.PaddingLeft = UDim.new(0, 8)
UIPadding_Sidebar.PaddingRight = UDim.new(0, 8)

local tabs = {}
local activeTab = nil

local function switchTab(name)
    for tabName, tabData in pairs(tabs) do
        local bar = tabData.Button:FindFirstChild("ActiveBar")
        local icon = tabData.Button:FindFirstChildWhichIsA("TextLabel")
        if tabName == name then
            TweenService:Create(tabData.Button, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
                BackgroundColor3 = Color3.fromRGB(40, 50, 80),
                BackgroundTransparency = 0,
                TextColor3 = Color3.fromRGB(255, 255, 255)
            }):Play()
            if bar then bar.Visible = true end
            if icon then TweenService:Create(icon, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(100, 160, 255)}):Play() end
            tabData.Content.Visible = true
        else
            TweenService:Create(tabData.Button, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {
                BackgroundColor3 = Color3.fromRGB(25, 25, 38),
                BackgroundTransparency = 0.5,
                TextColor3 = Color3.fromRGB(150, 155, 175)
            }):Play()
            if bar then bar.Visible = false end
            if icon then TweenService:Create(icon, TweenInfo.new(0.2), {TextColor3 = Color3.fromRGB(150, 155, 175)}):Play() end
            tabData.Content.Visible = false
        end
    end
    activeTab = name
end



local function createTab(name, emoji)
    local TabButton = Instance.new("TextButton")
    TabButton.Name = name .. "Tab"
    TabButton.Parent = Sidebar
    TabButton.BackgroundColor3 = Color3.fromRGB(25, 25, 38)
    TabButton.BackgroundTransparency = 0.5
    TabButton.Size = UDim2.new(1, 0, 0, 34)
    TabButton.Font = Enum.Font.GothamBold
    TabButton.Text = name
    TabButton.TextColor3 = Color3.fromRGB(150, 155, 175)
    TabButton.TextSize = 13
    TabButton.TextXAlignment = Enum.TextXAlignment.Left
    TabButton.AutoButtonColor = false
    
    local TabPadding = Instance.new("UIPadding")
    TabPadding.PaddingLeft = UDim.new(0, 34)
    TabPadding.Parent = TabButton
    
    local TabIcon = Instance.new("TextLabel")
    TabIcon.Parent = TabButton
    TabIcon.BackgroundTransparency = 1
    TabIcon.Position = UDim2.new(0, 8, 0.5, -8)
    TabIcon.Size = UDim2.new(0, 18, 0, 18)
    TabIcon.Font = Enum.Font.Gotham
    TabIcon.Text = emoji or ""
    TabIcon.TextSize = 15
    TabIcon.TextColor3 = Color3.fromRGB(150, 155, 175)
    
    local TabCorner = Instance.new("UICorner")
    TabCorner.CornerRadius = UDim.new(0, 8)
    TabCorner.Parent = TabButton
    
    -- Active indicator bar on the left
    local ActiveBar = Instance.new("Frame")
    ActiveBar.Name = "ActiveBar"
    ActiveBar.Parent = TabButton
    ActiveBar.BackgroundColor3 = Color3.fromRGB(80, 120, 255)
    ActiveBar.Position = UDim2.new(0, -2, 0.2, 0)
    ActiveBar.Size = UDim2.new(0, 3, 0.6, 0)
    ActiveBar.BorderSizePixel = 0
    ActiveBar.Visible = false
    local ActiveBarCorner = Instance.new("UICorner")
    ActiveBarCorner.CornerRadius = UDim.new(1, 0)
    ActiveBarCorner.Parent = ActiveBar
    
    -- Hover effect
    TabButton.MouseEnter:Connect(function()
        if activeTab ~= name then
            TweenService:Create(TabButton, TweenInfo.new(0.15), {BackgroundTransparency = 0.3, BackgroundColor3 = Color3.fromRGB(30, 30, 48)}):Play()
        end
    end)
    TabButton.MouseLeave:Connect(function()
        if activeTab ~= name then
            TweenService:Create(TabButton, TweenInfo.new(0.15), {BackgroundTransparency = 0.5, BackgroundColor3 = Color3.fromRGB(25, 25, 38)}):Play()
        end
    end)
    
    local TabContent = Instance.new("ScrollingFrame")
    TabContent.Name = name .. "Content"
    TabContent.Parent = TabContainer
    TabContent.BackgroundTransparency = 1
    TabContent.Size = UDim2.new(1, 0, 1, 0)
    TabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
    TabContent.ScrollBarThickness = 3
    TabContent.Visible = false
    TabContent.BorderSizePixel = 0
    TabContent.ScrollBarImageColor3 = Color3.fromRGB(80, 120, 255)
    
    local UIListLayout_Content = Instance.new("UIListLayout")
    UIListLayout_Content.Parent = TabContent
    UIListLayout_Content.SortOrder = Enum.SortOrder.LayoutOrder
    UIListLayout_Content.Padding = UDim.new(0, 6)
    
    local UIPadding_Content = Instance.new("UIPadding")
    UIPadding_Content.Parent = TabContent
    UIPadding_Content.PaddingTop = UDim.new(0, 12)
    UIPadding_Content.PaddingLeft = UDim.new(0, 14)
    UIPadding_Content.PaddingRight = UDim.new(0, 14)
    UIPadding_Content.PaddingBottom = UDim.new(0, 12)
    
    UIListLayout_Content:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabContent.CanvasSize = UDim2.new(0, 0, 0, UIListLayout_Content.AbsoluteContentSize.Y + 24)
    end)
    
    TabButton.MouseButton1Click:Connect(function()
        switchTab(name)
    end)
    
    tabs[name] = {Button = TabButton, Content = TabContent}
    return TabContent
end

local function createToggle(parent, text, defaultState, callback)
    local ToggleFrame = Instance.new("Frame")
    ToggleFrame.Name = text .. "Toggle"
    ToggleFrame.Parent = parent
    ToggleFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 34)
    ToggleFrame.Size = UDim2.new(1, 0, 0, 38)
    ToggleFrame.BorderSizePixel = 0
    
    local ToggleCorner = Instance.new("UICorner")
    ToggleCorner.CornerRadius = UDim.new(0, 8)
    ToggleCorner.Parent = ToggleFrame
    
    -- Subtle border
    local ToggleStroke = Instance.new("UIStroke")
    ToggleStroke.Parent = ToggleFrame
    ToggleStroke.Thickness = 1
    ToggleStroke.Color = Color3.fromRGB(40, 40, 60)
    ToggleStroke.Transparency = 0.6
    
    -- Hover effect on frame
    local hoverBtn = Instance.new("TextButton")
    hoverBtn.Parent = ToggleFrame
    hoverBtn.BackgroundTransparency = 1
    hoverBtn.Size = UDim2.new(1, 0, 1, 0)
    hoverBtn.Text = ""
    hoverBtn.ZIndex = 1
    hoverBtn.AutoButtonColor = false
    hoverBtn.MouseEnter:Connect(function()
        TweenService:Create(ToggleFrame, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(28, 28, 42)}):Play()
    end)
    hoverBtn.MouseLeave:Connect(function()
        TweenService:Create(ToggleFrame, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(22, 22, 34)}):Play()
    end)
    
    -- Status dot
    local StatusDot = Instance.new("Frame")
    StatusDot.Parent = ToggleFrame
    StatusDot.BackgroundColor3 = defaultState and Color3.fromRGB(80, 220, 120) or Color3.fromRGB(80, 80, 100)
    StatusDot.Position = UDim2.new(0, 12, 0.5, -3)
    StatusDot.Size = UDim2.new(0, 6, 0, 6)
    StatusDot.ZIndex = 2
    local StatusDotCorner = Instance.new("UICorner")
    StatusDotCorner.CornerRadius = UDim.new(1, 0)
    StatusDotCorner.Parent = StatusDot
    
    local Label = Instance.new("TextLabel")
    Label.Parent = ToggleFrame
    Label.BackgroundTransparency = 1
    Label.Position = UDim2.new(0, 24, 0, 0)
    Label.Size = UDim2.new(1, -72, 1, 0)
    Label.Font = Enum.Font.Gotham
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(200, 205, 220)
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    Label.ZIndex = 2
    
    local ToggleButton = Instance.new("TextButton")
    ToggleButton.Parent = ToggleFrame
    ToggleButton.BackgroundColor3 = defaultState and Color3.fromRGB(70, 110, 235) or Color3.fromRGB(35, 35, 50)
    ToggleButton.Position = UDim2.new(1, -50, 0.5, -11)
    ToggleButton.Size = UDim2.new(0, 40, 0, 22)
    ToggleButton.Text = ""
    ToggleButton.AutoButtonColor = false
    ToggleButton.ZIndex = 3
    
    local ToggleButtonCorner = Instance.new("UICorner")
    ToggleButtonCorner.CornerRadius = UDim.new(1, 0)
    ToggleButtonCorner.Parent = ToggleButton
    
    local Indicator = Instance.new("Frame")
    Indicator.Parent = ToggleButton
    Indicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Indicator.Position = defaultState and UDim2.new(1, -20, 0.5, -9) or UDim2.new(0, 2, 0.5, -9)
    Indicator.Size = UDim2.new(0, 18, 0, 18)
    Indicator.ZIndex = 4
    
    local IndicatorCorner = Instance.new("UICorner")
    IndicatorCorner.CornerRadius = UDim.new(1, 0)
    IndicatorCorner.Parent = Indicator
    
    local state = defaultState
    
    local function setState(newState)
        if state ~= newState then
            state = newState
            if state then
                TweenService:Create(Indicator, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {Position = UDim2.new(1, -20, 0.5, -9)}):Play()
                TweenService:Create(ToggleButton, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {BackgroundColor3 = Color3.fromRGB(70, 110, 235)}):Play()
                TweenService:Create(StatusDot, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(80, 220, 120)}):Play()
            else
                TweenService:Create(Indicator, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {Position = UDim2.new(0, 2, 0.5, -9)}):Play()
                TweenService:Create(ToggleButton, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {BackgroundColor3 = Color3.fromRGB(35, 35, 50)}):Play()
                TweenService:Create(StatusDot, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(80, 80, 100)}):Play()
            end
        end
    end

    ToggleButton.MouseButton1Click:Connect(function()
        setState(not state)
        callback(state)
        saveConfig()
    end)
    
    return setState
end

local function createSlider(parent, text, min, max, default, callback)
    local SliderFrame = Instance.new("Frame")
    SliderFrame.Name = text .. "Slider"
    SliderFrame.Parent = parent
    SliderFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 34)
    SliderFrame.Size = UDim2.new(1, 0, 0, 52)
    SliderFrame.BorderSizePixel = 0
    
    local SliderCorner = Instance.new("UICorner")
    SliderCorner.CornerRadius = UDim.new(0, 8)
    SliderCorner.Parent = SliderFrame
    
    local SliderStroke = Instance.new("UIStroke")
    SliderStroke.Parent = SliderFrame
    SliderStroke.Thickness = 1
    SliderStroke.Color = Color3.fromRGB(40, 40, 60)
    SliderStroke.Transparency = 0.6
    
    local Label = Instance.new("TextLabel")
    Label.Parent = SliderFrame
    Label.BackgroundTransparency = 1
    Label.Position = UDim2.new(0, 14, 0, 4)
    Label.Size = UDim2.new(1, -60, 0, 20)
    Label.Font = Enum.Font.Gotham
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(200, 205, 220)
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local ValueLabel = Instance.new("TextLabel")
    ValueLabel.Parent = SliderFrame
    ValueLabel.BackgroundTransparency = 1
    ValueLabel.Position = UDim2.new(1, -50, 0, 4)
    ValueLabel.Size = UDim2.new(0, 36, 0, 20)
    ValueLabel.Font = Enum.Font.GothamBold
    ValueLabel.Text = tostring(default)
    ValueLabel.TextColor3 = Color3.fromRGB(100, 160, 255)
    ValueLabel.TextSize = 12
    ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
    
    local SliderBG = Instance.new("Frame")
    SliderBG.Parent = SliderFrame
    SliderBG.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    SliderBG.Position = UDim2.new(0, 14, 0, 32)
    SliderBG.Size = UDim2.new(1, -28, 0, 6)
    SliderBG.BorderSizePixel = 0
    
    local BGCorner = Instance.new("UICorner")
    BGCorner.CornerRadius = UDim.new(1, 0)
    BGCorner.Parent = SliderBG
    
    local SliderFill = Instance.new("Frame")
    SliderFill.Parent = SliderBG
    SliderFill.BackgroundColor3 = Color3.fromRGB(70, 110, 235)
    SliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
    SliderFill.BorderSizePixel = 0
    
    local FillCorner = Instance.new("UICorner")
    FillCorner.CornerRadius = UDim.new(1, 0)
    FillCorner.Parent = SliderFill
    
    local FillGrad = Instance.new("UIGradient")
    FillGrad.Parent = SliderFill
    FillGrad.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(60, 100, 220)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(120, 80, 255))
    })
    
    -- Knob
    local Knob = Instance.new("Frame")
    Knob.Parent = SliderFill
    Knob.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    Knob.Position = UDim2.new(1, -6, 0.5, -6)
    Knob.Size = UDim2.new(0, 12, 0, 12)
    Knob.ZIndex = 5
    local KnobCorner = Instance.new("UICorner")
    KnobCorner.CornerRadius = UDim.new(1, 0)
    KnobCorner.Parent = Knob
    
    local SliderButton = Instance.new("TextButton")
    SliderButton.Parent = SliderBG
    SliderButton.BackgroundTransparency = 1
    SliderButton.Size = UDim2.new(1, 20, 0, 40)
    SliderButton.Position = UDim2.new(0, -10, 0, -17)
    SliderButton.Text = ""
    SliderButton.ZIndex = 6
    
    local dragging = false
    local function updateSlider(input)
        local inputPos = input.Position.X
        local pos = math.clamp((inputPos - SliderBG.AbsolutePosition.X) / SliderBG.AbsoluteSize.X, 0, 1)
        local value = math.floor(min + (max - min) * pos)
        ValueLabel.Text = tostring(value)
        TweenService:Create(SliderFill, TweenInfo.new(0.08), {Size = UDim2.new(pos, 0, 1, 0)}):Play()
        callback(value)
    end
    
    SliderButton.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            updateSlider(input)
        end
    end)
    
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                dragging = false
                saveConfig()
            end
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            updateSlider(input)
        end
    end)
end

local function createDropdown(parent, text, options, default, callback)
    local DropdownFrame = Instance.new("Frame")
    DropdownFrame.Name = text .. "Dropdown"
    DropdownFrame.Parent = parent
    DropdownFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 34)
    DropdownFrame.Size = UDim2.new(1, 0, 0, 38)
    DropdownFrame.BorderSizePixel = 0
    DropdownFrame.ClipsDescendants = true
    
    local DropdownCorner = Instance.new("UICorner")
    DropdownCorner.CornerRadius = UDim.new(0, 8)
    DropdownCorner.Parent = DropdownFrame
    
    local DropStroke = Instance.new("UIStroke")
    DropStroke.Parent = DropdownFrame
    DropStroke.Thickness = 1
    DropStroke.Color = Color3.fromRGB(40, 40, 60)
    DropStroke.Transparency = 0.6
    
    local DropdownButton = Instance.new("TextButton")
    DropdownButton.Parent = DropdownFrame
    DropdownButton.BackgroundColor3 = Color3.fromRGB(22, 22, 34)
    DropdownButton.Size = UDim2.new(1, 0, 0, 38)
    DropdownButton.Font = Enum.Font.Gotham
    DropdownButton.Text = ""
    DropdownButton.AutoButtonColor = false
    
    local Label = Instance.new("TextLabel")
    Label.Parent = DropdownButton
    Label.BackgroundTransparency = 1
    Label.Position = UDim2.new(0, 14, 0, 0)
    Label.Size = UDim2.new(1, -50, 1, 0)
    Label.Font = Enum.Font.Gotham
    Label.Text = text .. ": " .. default
    Label.TextColor3 = Color3.fromRGB(200, 205, 220)
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local Icon = Instance.new("TextLabel")
    Icon.Parent = DropdownButton
    Icon.BackgroundTransparency = 1
    Icon.Position = UDim2.new(1, -30, 0, 0)
    Icon.Size = UDim2.new(0, 20, 1, 0)
    Icon.Font = Enum.Font.GothamBold
    Icon.Text = "\226\150\188"
    Icon.TextColor3 = Color3.fromRGB(100, 160, 255)
    Icon.TextSize = 10
    
    local OptionContainer = Instance.new("Frame")
    OptionContainer.Parent = DropdownFrame
    OptionContainer.BackgroundColor3 = Color3.fromRGB(26, 26, 40)
    OptionContainer.Position = UDim2.new(0, 0, 0, 38)
    OptionContainer.Size = UDim2.new(1, 0, 1, -38)
    OptionContainer.BorderSizePixel = 0
    
    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Parent = OptionContainer
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local isOpen = false
    DropdownButton.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        if isOpen then
            TweenService:Create(DropdownFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {Size = UDim2.new(1, 0, 0, 38 + (#options * 30))}):Play()
            Icon.Text = "\226\150\178"
        else
            TweenService:Create(DropdownFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {Size = UDim2.new(1, 0, 0, 38)}):Play()
            Icon.Text = "\226\150\188"
        end
    end)
    
    for _, option in ipairs(options) do
        local OptionButton = Instance.new("TextButton")
        OptionButton.Parent = OptionContainer
        OptionButton.BackgroundColor3 = Color3.fromRGB(26, 26, 40)
        OptionButton.Size = UDim2.new(1, 0, 0, 30)
        OptionButton.Font = Enum.Font.Gotham
        OptionButton.Text = "  " .. option
        OptionButton.TextColor3 = Color3.fromRGB(180, 185, 200)
        OptionButton.TextSize = 12
        OptionButton.TextXAlignment = Enum.TextXAlignment.Left
        OptionButton.AutoButtonColor = false
        
        OptionButton.MouseEnter:Connect(function()
            TweenService:Create(OptionButton, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(35, 40, 60)}):Play()
        end)
        OptionButton.MouseLeave:Connect(function()
            TweenService:Create(OptionButton, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(26, 26, 40)}):Play()
        end)
        
        OptionButton.MouseButton1Click:Connect(function()
            Label.Text = text .. ": " .. option
            isOpen = false
            TweenService:Create(DropdownFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {Size = UDim2.new(1, 0, 0, 38)}):Play()
            Icon.Text = "\226\150\188"
            callback(option)
            saveConfig()
        end)
    end
end

local function _createTextBox(parent, text, default, callback)
    local TextBoxFrame = Instance.new("Frame")
    TextBoxFrame.Name = text .. "TextBox"
    TextBoxFrame.Parent = parent
    TextBoxFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 34)
    TextBoxFrame.Size = UDim2.new(1, 0, 0, 38)
    TextBoxFrame.BorderSizePixel = 0
    
    local TextBoxCorner = Instance.new("UICorner")
    TextBoxCorner.CornerRadius = UDim.new(0, 8)
    TextBoxCorner.Parent = TextBoxFrame
    
    local TBStroke = Instance.new("UIStroke")
    TBStroke.Parent = TextBoxFrame
    TBStroke.Thickness = 1
    TBStroke.Color = Color3.fromRGB(40, 40, 60)
    TBStroke.Transparency = 0.6
    
    local Label = Instance.new("TextLabel")
    Label.Parent = TextBoxFrame
    Label.BackgroundTransparency = 1
    Label.Position = UDim2.new(0, 14, 0, 0)
    Label.Size = UDim2.new(0.5, -14, 1, 0)
    Label.Font = Enum.Font.Gotham
    Label.Text = text
    Label.TextColor3 = Color3.fromRGB(200, 205, 220)
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local InputBox = Instance.new("TextBox")
    InputBox.Parent = TextBoxFrame
    InputBox.BackgroundColor3 = Color3.fromRGB(35, 35, 50)
    InputBox.Position = UDim2.new(0.5, 0, 0.5, -12)
    InputBox.Size = UDim2.new(0.5, -10, 0, 24)
    InputBox.Font = Enum.Font.Gotham
    InputBox.Text = default
    InputBox.TextColor3 = Color3.fromRGB(255, 255, 255)
    InputBox.TextSize = 11
    InputBox.ClearTextOnFocus = false
    
    local InputCorner = Instance.new("UICorner")
    InputCorner.CornerRadius = UDim.new(0, 6)
    InputCorner.Parent = InputBox
    
    InputBox.FocusLost:Connect(function()
        callback(InputBox.Text)
        saveConfig()
    end)
    return TextBoxFrame
end

local function createDynamicDropdown(parent, text, default, getOptionsCallback, callback)
    local DropdownFrame = Instance.new("Frame")
    DropdownFrame.Name = text .. "Dropdown"
    DropdownFrame.Parent = parent
    DropdownFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 34)
    DropdownFrame.Size = UDim2.new(1, 0, 0, 38)
    DropdownFrame.BorderSizePixel = 0
    DropdownFrame.ClipsDescendants = true
    
    local DropdownCorner = Instance.new("UICorner")
    DropdownCorner.CornerRadius = UDim.new(0, 8)
    DropdownCorner.Parent = DropdownFrame
    
    local DDStroke = Instance.new("UIStroke")
    DDStroke.Parent = DropdownFrame
    DDStroke.Thickness = 1
    DDStroke.Color = Color3.fromRGB(40, 40, 60)
    DDStroke.Transparency = 0.6
    
    local DropdownButton = Instance.new("TextButton")
    DropdownButton.Parent = DropdownFrame
    DropdownButton.BackgroundColor3 = Color3.fromRGB(22, 22, 34)
    DropdownButton.Size = UDim2.new(1, 0, 0, 38)
    DropdownButton.Font = Enum.Font.Gotham
    DropdownButton.Text = ""
    DropdownButton.AutoButtonColor = false
    
    local Label = Instance.new("TextLabel")
    Label.Parent = DropdownButton
    Label.BackgroundTransparency = 1
    Label.Position = UDim2.new(0, 14, 0, 0)
    Label.Size = UDim2.new(1, -50, 1, 0)
    Label.Font = Enum.Font.Gotham
    Label.Text = text .. ": " .. (default ~= "" and default or "Select...")
    Label.TextColor3 = Color3.fromRGB(200, 205, 220)
    Label.TextSize = 12
    Label.TextXAlignment = Enum.TextXAlignment.Left
    
    local Icon = Instance.new("TextLabel")
    Icon.Parent = DropdownButton
    Icon.BackgroundTransparency = 1
    Icon.Position = UDim2.new(1, -30, 0, 0)
    Icon.Size = UDim2.new(0, 20, 1, 0)
    Icon.Font = Enum.Font.GothamBold
    Icon.Text = "\226\150\188"
    Icon.TextColor3 = Color3.fromRGB(100, 160, 255)
    Icon.TextSize = 10
    
    local OptionContainer = Instance.new("Frame")
    OptionContainer.Parent = DropdownFrame
    OptionContainer.BackgroundColor3 = Color3.fromRGB(26, 26, 40)
    OptionContainer.Position = UDim2.new(0, 0, 0, 38)
    OptionContainer.Size = UDim2.new(1, 0, 1, -38)
    OptionContainer.BorderSizePixel = 0
    
    local UIListLayout = Instance.new("UIListLayout")
    UIListLayout.Parent = OptionContainer
    UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
    
    local isOpen = false
    DropdownButton.MouseButton1Click:Connect(function()
        isOpen = not isOpen
        
        if isOpen then
            for _, child in ipairs(OptionContainer:GetChildren()) do
                if child:IsA("TextButton") then child:Destroy() end
            end
            
            local options = getOptionsCallback()
            if #options == 0 then options = {"None Found"} end
            
            for _, option in ipairs(options) do
                local OptionBtn = Instance.new("TextButton")
                OptionBtn.Parent = OptionContainer
                OptionBtn.BackgroundColor3 = Color3.fromRGB(26, 26, 40)
                OptionBtn.Size = UDim2.new(1, 0, 0, 30)
                OptionBtn.Font = Enum.Font.Gotham
                OptionBtn.Text = "  " .. option
                OptionBtn.TextColor3 = Color3.fromRGB(180, 185, 200)
                OptionBtn.TextSize = 12
                OptionBtn.TextXAlignment = Enum.TextXAlignment.Left
                OptionBtn.AutoButtonColor = false
                
                OptionBtn.MouseEnter:Connect(function()
                    TweenService:Create(OptionBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(35, 40, 60)}):Play()
                end)
                OptionBtn.MouseLeave:Connect(function()
                    TweenService:Create(OptionBtn, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(26, 26, 40)}):Play()
                end)
                
                OptionBtn.MouseButton1Click:Connect(function()
                    Label.Text = text .. ": " .. option
                    isOpen = false
                    TweenService:Create(DropdownFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {Size = UDim2.new(1, 0, 0, 38)}):Play()
                    Icon.Text = "\226\150\188"
                    callback(option)
                    saveConfig()
                end)
            end
            TweenService:Create(DropdownFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {Size = UDim2.new(1, 0, 0, 38 + (#options * 30))}):Play()
            Icon.Text = "\226\150\178"
        else
            TweenService:Create(DropdownFrame, TweenInfo.new(0.25, Enum.EasingStyle.Quint), {Size = UDim2.new(1, 0, 0, 38)}):Play()
            Icon.Text = "\226\150\188"
        end
    end)
end



local function setExclusiveFarm(farmKey, state)
    Config[farmKey] = state
    if state then
        local targetIslandStr
        if string.match(farmKey, "Island") then
            targetIslandStr = string.lower(farmKey)
        elseif farmKey == "AutoBoss" then
            local data = BossData[Config.SelectedBoss]
            if data then targetIslandStr = data.Island end
        end
        
        if targetIslandStr then
            pcall(function()
                local teleportEvent = ReplicatedStorage:FindFirstChild("Remotes")
                    and ReplicatedStorage.Remotes:FindFirstChild("Events")
                    and ReplicatedStorage.Remotes.Events:FindFirstChild("TeleportToIslandRequest")
                
                if teleportEvent then
                    teleportEvent:FireServer(targetIslandStr)
                end
            end)
        end

        for name, _ in pairs(Config) do
            if name ~= farmKey and (string.match(name, "Island") or name == "AutoBoss" or name == "AutoTower") then
                Config[name] = false
                if toggleFuncs[name] then
                    toggleFuncs[name](false)
                end
            end
        end
    end
    saveConfig()
end

-- Create Tabs
local MainTab = createTab("Farming", "⚔️")
local TowerTab = createTab("Tower", "🏰")
local ChestsTab = createTab("Chests", "🎁")
local SettingsTab = createTab("Settings", "⚙️")

-- Add elements to Main Tab
toggleFuncs["Island1"] = createToggle(MainTab, "Auto Farm Island 1", Config.Island1, function(state) setExclusiveFarm("Island1", state) end)
toggleFuncs["Island2"] = createToggle(MainTab, "Auto Farm Island 2", Config.Island2, function(state) setExclusiveFarm("Island2", state) end)
toggleFuncs["Island3"] = createToggle(MainTab, "Auto Farm Island 3", Config.Island3, function(state) setExclusiveFarm("Island3", state) end)
toggleFuncs["Island4"] = createToggle(MainTab, "Auto Farm Island 4", Config.Island4, function(state) setExclusiveFarm("Island4", state) end)
toggleFuncs["Island5"] = createToggle(MainTab, "Auto Farm Island 5", Config.Island5, function(state) setExclusiveFarm("Island5", state) end)
toggleFuncs["Island6"] = createToggle(MainTab, "Auto Farm Island 6", Config.Island6, function(state) setExclusiveFarm("Island6", state) end)
toggleFuncs["Island7"] = createToggle(MainTab, "Auto Farm Island 7", Config.Island7, function(state) setExclusiveFarm("Island7", state) end)

-- Add elements to Tower Tab
toggleFuncs["AutoTower"] = createToggle(TowerTab, "Auto Farm Tower", Config.AutoTower, function(state) setExclusiveFarm("AutoTower", state) end)

local BossList = {"Rayleigh [Lv. 30]", "Mihawk [Lv. 500]", "Blackbeard [Lv. 1000]", "Gojo Boss [Lv. 3333]", "Shanks [Lv. 2000]", "Grimmjow [Lv. 5000]", "Aizen Boss [Lv. 6666]", "Mahogara [Lv. 6500]", "Sukona Boss [Lv. 8888]", "Aokeejee [Lv. 7500]"}
createDropdown(MainTab, "Select Boss", BossList, Config.SelectedBoss, function(value)
    Config.SelectedBoss = value
    bossQuestTaken = false
    if Config.AutoBoss then
        setExclusiveFarm("AutoBoss", true)
    end
end)
toggleFuncs["AutoBoss"] = createToggle(MainTab, "Auto Boss", Config.AutoBoss, function(state) setExclusiveFarm("AutoBoss", state) end)

-- ══════════════════════════════════════
-- ALL ISLANDS FARM SECTION
-- ══════════════════════════════════════
local AllSepFrame = Instance.new("Frame")
AllSepFrame.Parent = MainTab
AllSepFrame.BackgroundTransparency = 1
AllSepFrame.Size = UDim2.new(1, 0, 0, 24)

local AllSepLine = Instance.new("Frame")
AllSepLine.Parent = AllSepFrame
AllSepLine.BackgroundColor3 = Color3.fromRGB(80, 120, 255)
AllSepLine.Position = UDim2.new(0, 0, 0.5, 0)
AllSepLine.Size = UDim2.new(1, 0, 0, 1)
AllSepLine.BorderSizePixel = 0
local SepGrad = Instance.new("UIGradient")
SepGrad.Parent = AllSepLine
SepGrad.Transparency = NumberSequence.new({NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.3, 0.3), NumberSequenceKeypoint.new(0.7, 0.3), NumberSequenceKeypoint.new(1, 1)})

local AllLabel = Instance.new("TextLabel")
AllLabel.Parent = AllSepFrame
AllLabel.BackgroundColor3 = Color3.fromRGB(15, 15, 22)
AllLabel.Position = UDim2.new(0.5, -60, 0, 4)
AllLabel.Size = UDim2.new(0, 120, 0, 16)
AllLabel.Font = Enum.Font.GothamBold
AllLabel.Text = " Farm All Islands "
AllLabel.TextColor3 = Color3.fromRGB(100, 160, 255)
AllLabel.TextSize = 10

toggleFuncs["AllNPCs"] = createToggle(MainTab, "All Islands: NPCs Only", Config.AllNPCs, function(state)
    Config.AllNPCs = state
    if state then
        Config.AllBosses = false
        Config.AllFarm = false
        -- disable individual farms
        for _, k in ipairs({"Island1","Island2","Island3","Island4","Island5","Island6","Island7","AutoBoss"}) do
            Config[k] = false
            if toggleFuncs[k] then toggleFuncs[k](false) end
        end
        if toggleFuncs["AllBosses"] then toggleFuncs["AllBosses"](false) end
        if toggleFuncs["AllFarm"] then toggleFuncs["AllFarm"](false) end
    end
    saveConfig()
end)

toggleFuncs["AllBosses"] = createToggle(MainTab, "All Islands: Bosses Only", Config.AllBosses, function(state)
    Config.AllBosses = state
    if state then
        Config.AllNPCs = false
        Config.AllFarm = false
        for _, k in ipairs({"Island1","Island2","Island3","Island4","Island5","Island6","Island7","AutoBoss"}) do
            Config[k] = false
            if toggleFuncs[k] then toggleFuncs[k](false) end
        end
        if toggleFuncs["AllNPCs"] then toggleFuncs["AllNPCs"](false) end
        if toggleFuncs["AllFarm"] then toggleFuncs["AllFarm"](false) end
    end
    saveConfig()
end)

toggleFuncs["AllFarm"] = createToggle(MainTab, "All Islands: NPCs + Bosses", Config.AllFarm, function(state)
    Config.AllFarm = state
    if state then
        Config.AllNPCs = false
        Config.AllBosses = false
        for _, k in ipairs({"Island1","Island2","Island3","Island4","Island5","Island6","Island7","AutoBoss"}) do
            Config[k] = false
            if toggleFuncs[k] then toggleFuncs[k](false) end
        end
        if toggleFuncs["AllNPCs"] then toggleFuncs["AllNPCs"](false) end
        if toggleFuncs["AllBosses"] then toggleFuncs["AllBosses"](false) end
    end
    saveConfig()
end)

-- Add elements to Chests Tab
createToggle(ChestsTab, "Auto Common Chest", Config.AutoCommonChest, function(state) Config.AutoCommonChest = state end)
createToggle(ChestsTab, "Auto Rare Chest", Config.AutoRareChest, function(state) Config.AutoRareChest = state end)
createToggle(ChestsTab, "Auto Epic Chest", Config.AutoEpicChest, function(state) Config.AutoEpicChest = state end)
createToggle(ChestsTab, "Auto Legendary Chest", Config.AutoLegendaryChest, function(state) Config.AutoLegendaryChest = state end)
createToggle(ChestsTab, "Auto Mythic Chest", Config.AutoMythicChest, function(state) Config.AutoMythicChest = state end)
createToggle(ChestsTab, "Auto Secret Chest", Config.AutoSecretChest, function(state) Config.AutoSecretChest = state end)

-- Settings UI
createDynamicDropdown(SettingsTab, "Auto Equip Tool", Config.SelectedWeapon, function()
    local weapons = {}
    if LocalPlayer:FindFirstChild("Backpack") then
        for _, item in ipairs(LocalPlayer.Backpack:GetChildren()) do
            if item:IsA("Tool") then table.insert(weapons, item.Name) end
        end
    end
    if LocalPlayer.Character then
        for _, item in ipairs(LocalPlayer.Character:GetChildren()) do
            if item:IsA("Tool") then table.insert(weapons, item.Name) end
        end
    end
    return weapons
end, function(value)
    Config.SelectedWeapon = value
end)

createToggle(SettingsTab, "Auto Equip Weapon", Config.AutoEquip, function(state) Config.AutoEquip = state end)
createToggle(SettingsTab, "Auto Haki", Config.AutoHaki, function(state) Config.AutoHaki = state end)
createSlider(SettingsTab, "Attack Delay (ms)", 100, 2000, Config.AttackDelay * 1000, function(value) Config.AttackDelay = value / 1000 end)

createDropdown(SettingsTab, "Attack Position", {"Behind", "Above", "Below", "Front", "Left", "Right"}, Config.Position, function(value)
    Config.Position = value
end)

createSlider(SettingsTab, "Enemy Distance", 0, 20, Config.Distance, function(value)
    Config.Distance = value
end)

createToggle(SettingsTab, "Show Profile", Config.ShowProfile, function(state)
    Config.ShowProfile = state
    local pFrame = MainFrame:FindFirstChild("ProfileFrame")
    if pFrame then pFrame.Visible = state end
end)

createToggle(SettingsTab, "RGB Border Mode", Config.RGBMode, function(state)
    Config.RGBMode = state
end)

-- Settings Tab Info
local InfoFrame = Instance.new("Frame")
InfoFrame.Parent = SettingsTab
InfoFrame.BackgroundColor3 = Color3.fromRGB(22, 22, 34)
InfoFrame.Size = UDim2.new(1, 0, 0, 32)
InfoFrame.BorderSizePixel = 0
local InfoFrameCorner = Instance.new("UICorner")
InfoFrameCorner.CornerRadius = UDim.new(0, 8)
InfoFrameCorner.Parent = InfoFrame
local InfoLabel = Instance.new("TextLabel")
InfoLabel.Parent = InfoFrame
InfoLabel.BackgroundTransparency = 1
InfoLabel.Size = UDim2.new(1, 0, 1, 0)
InfoLabel.Font = Enum.Font.Gotham
InfoLabel.Text = "⌨  Menu hotkey: INSERT"
InfoLabel.TextColor3 = Color3.fromRGB(90, 100, 130)
InfoLabel.TextSize = 11

-- Initialize Tab
switchTab("Farming")

-- Auto-Resume: re-trigger teleport for any farm state loaded from config
task.spawn(function()
    task.wait(3) -- wait for character and game to fully load
    
    local islandKeys = {"Island1", "Island2", "Island3", "Island4", "Island5", "Island6", "Island7"}
    local activeKey = nil
    
    if Config.AutoBoss then
        activeKey = "AutoBoss"
    else
        for _, key in ipairs(islandKeys) do
            if Config[key] then
                activeKey = key
                break
            end
        end
    end
    
    if activeKey then
        -- Determine the island string to teleport to
        local targetIslandStr
        if activeKey == "AutoBoss" then
            local data = BossData[Config.SelectedBoss]
            if data then targetIslandStr = data.Island end
        else
            targetIslandStr = string.lower(activeKey) -- e.g. "Island6" -> "island6"
        end
        
        if targetIslandStr then
            pcall(function()
                local teleportEvent = ReplicatedStorage:WaitForChild("Remotes", 5)
                    and ReplicatedStorage.Remotes:WaitForChild("Events", 5)
                    and ReplicatedStorage.Remotes.Events:FindFirstChild("TeleportToIslandRequest")
                if teleportEvent then
                    teleportEvent:FireServer(targetIslandStr)
                end
            end)
        end
    end
end)

-- Farming Logic
local function getEnemy(islandFolderStr)
    local gameFolder = workspace:FindFirstChild("Game")
    if not gameFolder then return nil end
    local npcFolder = gameFolder:FindFirstChild("EnemyNpcs")
    if not npcFolder then return nil end
    local islandFolder = npcFolder:FindFirstChild(islandFolderStr)
    if not islandFolder then return nil end
    
    for _, enemy in ipairs(islandFolder:GetChildren()) do
        if enemy:IsA("Model") then
            local humanoid = enemy:FindFirstChild("Humanoid") or enemy:FindFirstChildWhichIsA("Humanoid")
            local enemyHrp = enemy:FindFirstChild("HumanoidRootPart")
            
            if humanoid and enemyHrp and humanoid.Health > 0 then
                -- Immediately return the first alive enemy for fast farming
                return enemy
            end
        end
    end
    return nil
end

local function getTowerEnemy()
    local tower = workspace:FindFirstChild("infinite Tower") or workspace:FindFirstChild("Infinite Tower")
    local enemies = tower and (tower:FindFirstChild("RuntimeEnemies") or tower:FindFirstChild("enemies"))
    if not enemies then return nil end
    
    for _, enemy in ipairs(enemies:GetChildren()) do
        if enemy:IsA("Model") then
            local humanoid = enemy:FindFirstChild("Humanoid") or enemy:FindFirstChildWhichIsA("Humanoid")
            local hrp = enemy:FindFirstChild("HumanoidRootPart")
            
            if humanoid and hrp and humanoid.Health > 0 then
                return enemy
            end
        end
    end
    return nil
end

local function equipTool(name)
    if name == "" then return nil end
    local character = LocalPlayer.Character
    local humanoid = character and character:FindFirstChild("Humanoid")
    if not character or not humanoid then return nil end
    local tool = character:FindFirstChild(name)
    if tool and tool:IsA("Tool") then return tool end
    local backpack = LocalPlayer:FindFirstChild("Backpack")
    if backpack then
        tool = backpack:FindFirstChild(name)
        if tool and tool:IsA("Tool") then
            pcall(function() humanoid:EquipTool(tool) end)
            return character:FindFirstChild(name) or tool
        end
    end
    return nil
end

local function getOffsetCFrame()
    local d = Config.Distance
    local p = Config.Position
    if     p == "Above" then return CFrame.new(0,  d, 0)
    elseif p == "Below" then return CFrame.new(0, -d, 0)
    elseif p == "Front" then return CFrame.new(0,  0, -d)
    elseif p == "Left"  then return CFrame.new(-d, 0, 0)
    elseif p == "Right" then return CFrame.new( d, 0, 0)
    else                      return CFrame.new(0,  0,  d) end
end

local function ensureBV(hrp)
    if not hrp:FindFirstChild("VoltFarmBV") then
        local bv = Instance.new("BodyVelocity")
        bv.Name = "VoltFarmBV"
        bv.MaxForce = Vector3.new(math.huge, math.huge, math.huge)
        bv.Velocity = Vector3.zero
        bv.Parent = hrp
    end
end

local function removeBV(hrp)
    local bv = hrp and hrp:FindFirstChild("VoltFarmBV")
    if bv then bv:Destroy() end
end

-- Pre-build boss name lookup (static)
local isBossName = {}
for _, b in ipairs(AllBossList) do isBossName[b.Name] = true end

task.spawn(function()
    local lastAttack = 0
    local currentAllFarmIsland = 1
    local lastIslandSwitch = os.clock()

    local function performAttack(targetHrp, myHrp)
        ensureBV(myHrp)
        myHrp.CFrame = CFrame.new((targetHrp.CFrame * getOffsetCFrame()).Position, targetHrp.Position)
        local now = os.clock()
        if now - lastAttack >= Config.AttackDelay then
            lastAttack = now
            local tool = equipTool(Config.SelectedWeapon)
            if tool then pcall(function() tool:Activate() end) end
        end
    end

    while task.wait() do
        if _G.VoltPiratePieceStop then break end
        local activeIsland = nil
        if     Config.Island1 then activeIsland = "island1"
        elseif Config.Island2 then activeIsland = "island2"
        elseif Config.Island3 then activeIsland = "island3"
        elseif Config.Island4 then activeIsland = "island4"
        elseif Config.Island5 then activeIsland = "island5"
        elseif Config.Island6 then activeIsland = "island6"
        elseif Config.Island7 then activeIsland = "island7"
        end
        
        local character = LocalPlayer.Character
        local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
        local myHrp = character and character:FindFirstChild("HumanoidRootPart")
        if humanoid and humanoid.Health > 0 and myHrp then
            local gameFolder = workspace:FindFirstChild("Game")
            local enemyNpcs = gameFolder and gameFolder:FindFirstChild("EnemyNpcs")

            if activeIsland then
                local enemy = getEnemy(activeIsland)
                if enemy then
                    local enemyHrp = enemy:FindFirstChild("HumanoidRootPart")
                    if enemyHrp then performAttack(enemyHrp, myHrp) end
                else
                    removeBV(myHrp)
                end

            elseif Config.AutoTower then
                local enemy = getTowerEnemy()
                if enemy then
                    local enemyHrp = enemy:FindFirstChild("HumanoidRootPart")
                    if enemyHrp then performAttack(enemyHrp, myHrp) end
                else
                    removeBV(myHrp)
                end

            elseif Config.AutoBoss then
                local data = BossData[Config.SelectedBoss]
                if data and enemyNpcs then
                    local bossIsland = enemyNpcs:FindFirstChild(data.Island)
                    local bossModel = bossIsland and bossIsland:FindFirstChild(Config.SelectedBoss)
                    local bossHumanoid = bossModel and (bossModel:FindFirstChild("Humanoid") or bossModel:FindFirstChildWhichIsA("Humanoid"))
                    local bossHrp = bossModel and bossModel:FindFirstChild("HumanoidRootPart")

                    if bossHumanoid and bossHrp and bossHumanoid.Health > 0 then
                        if not bossQuestTaken then
                            local serviceNpcs = gameFolder:FindFirstChild("ServiceNpcs")
                            local questGivers = serviceNpcs and serviceNpcs:FindFirstChild("QuestGivers")
                            local questGiver = questGivers and questGivers:FindFirstChild(data.Giver)
                            local promptPart = questGiver and questGiver:FindFirstChild("nameDontMatterQu3stG1v3rP4rt")
                            local prompt = promptPart and promptPart:FindFirstChild("nameDontMatterProximityPrompt")
                            if promptPart and prompt then
                                removeBV(myHrp)
                                myHrp.CFrame = promptPart.CFrame * CFrame.new(0, 3, 3)
                                task.wait(0.2)
                                pcall(function() fireproximityprompt(prompt) end)
                                task.wait(0.2)
                                bossQuestTaken = true
                            end
                        else
                            performAttack(bossHrp, myHrp)
                        end
                    else
                        bossQuestTaken = false
                        removeBV(myHrp)
                    end
                end

            elseif Config.AllNPCs or Config.AllBosses or Config.AllFarm then
                local islandKey = "island" .. currentAllFarmIsland
                local islandF = enemyNpcs and enemyNpcs:FindFirstChild(islandKey)
                local attacked = false

                if islandF then
                    if Config.AllNPCs or Config.AllFarm then
                        for _, child in ipairs(islandF:GetChildren()) do
                            if child:IsA("Model") and not isBossName[child.Name] then
                                local h = child:FindFirstChildWhichIsA("Humanoid")
                                local hrp = child:FindFirstChild("HumanoidRootPart")
                                if h and hrp and h.Health > 0 then
                                    performAttack(hrp, myHrp)
                                    attacked = true
                                    break
                                end
                            end
                        end
                    end
                    if not attacked and (Config.AllBosses or Config.AllFarm) then
                        for _, entry in ipairs(AllBossList) do
                            if entry.Island == islandKey then
                                local boss = islandF:FindFirstChild(entry.Name)
                                local h = boss and (boss:FindFirstChild("Humanoid") or boss:FindFirstChildWhichIsA("Humanoid"))
                                local hrp = boss and boss:FindFirstChild("HumanoidRootPart")
                                if h and hrp and h.Health > 0 then
                                    performAttack(hrp, myHrp)
                                    attacked = true
                                    break
                                end
                            end
                        end
                    end
                end

                if not attacked then
                    removeBV(myHrp)
                    if os.clock() - lastIslandSwitch >= 2 then
                        currentAllFarmIsland = currentAllFarmIsland % 7 + 1
                        pcall(function()
                            local ev = ReplicatedStorage:FindFirstChild("Remotes")
                                and ReplicatedStorage.Remotes:FindFirstChild("Events")
                                and ReplicatedStorage.Remotes.Events:FindFirstChild("TeleportToIslandRequest")
                            if ev then ev:FireServer("island" .. currentAllFarmIsland) end
                        end)
                        lastIslandSwitch = os.clock()
                    end
                end
            else
                removeBV(myHrp)
            end
        else
            removeBV(myHrp)
        end
    end
end)

-- Auto Open Chests Logic
task.spawn(function()
    while task.wait(0.1) do
        if _G.VoltPiratePieceStop then break end
        local useItemEvent
        pcall(function()
            useItemEvent = ReplicatedStorage:FindFirstChild("Remotes") and ReplicatedStorage.Remotes:FindFirstChild("Events") and ReplicatedStorage.Remotes.Events:FindFirstChild("UseInventoryItem")
        end)
        
        if useItemEvent then
            if Config.AutoCommonChest then pcall(function() useItemEvent:FireServer("Common Chest") end) end
            if Config.AutoRareChest then pcall(function() useItemEvent:FireServer("Rare Chest") end) end
            if Config.AutoEpicChest then pcall(function() useItemEvent:FireServer("Epic Chest") end) end
            if Config.AutoLegendaryChest then pcall(function() useItemEvent:FireServer("Legendary Chest") end) end
            if Config.AutoMythicChest then pcall(function() useItemEvent:FireServer("Mythic Chest") end) end
            if Config.AutoSecretChest then pcall(function() useItemEvent:FireServer("Secret Chest") end) end
        end
    end
end)

-- Auto Equip Logic
task.spawn(function()
    while task.wait(0.5) do
        if _G.VoltPiratePieceStop then break end
        if Config.AutoEquip and Config.SelectedWeapon ~= "" then
            pcall(function()
                local character = LocalPlayer.Character
                local backpack = LocalPlayer:FindFirstChild("Backpack")
                local humanoid = character and character:FindFirstChildWhichIsA("Humanoid")
                
                if character and humanoid and humanoid.Health > 0 then
                    local toolInChar = character:FindFirstChild(Config.SelectedWeapon)
                    if not toolInChar and backpack then
                        local toolInBackpack = backpack:FindFirstChild(Config.SelectedWeapon)
                        if toolInBackpack then
                            humanoid:EquipTool(toolInBackpack)
                        end
                    end
                end
            end)
        end
    end
end)

task.spawn(function()
    while task.wait(1.5) do
        if _G.VoltPiratePieceStop then break end
        if Config.AutoHaki then
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 then
                local hasHaki = false
                
                -- Check for common Haki indicators
                if char:FindFirstChild("Haki") or char:FindFirstChild("Buso") or char:FindFirstChild("Armament") or char:FindFirstChild("Aura") then
                    hasHaki = true
                elseif char:GetAttribute("Haki") or char:GetAttribute("Buso") then
                    hasHaki = true
                else
                    -- Check if arms have changed color/material (Neon/Black)
                    for _, part in ipairs(char:GetChildren()) do
                        if part:IsA("BasePart") and (part.Name:match("Arm") or part.Name:match("Hand")) then
                            if part.Material == Enum.Material.Neon or part.Color == Color3.new(0, 0, 0) or part.Color == Color3.fromRGB(17, 17, 17) then
                                hasHaki = true
                                break
                            end
                        end
                    end
                end
                
                if not hasHaki then
                    pcall(function()
                        local args = { "Activate", "Armament" }
                        game:GetService("ReplicatedStorage"):WaitForChild("Remotes"):WaitForChild("Events"):WaitForChild("VersatileHakiEvent"):FireServer(unpack(args))
                    end)
                    task.wait(2) -- Wait to prevent spamming
                end
            end
        end
    end
end)

-- Floating Toggle Button
local FloatButton = Instance.new("TextButton")
FloatButton.Name = "FloatButton"
FloatButton.Parent = ScreenGui
FloatButton.BackgroundColor3 = Color3.fromRGB(22, 22, 32)
FloatButton.Position = UDim2.new(0, 20, 0.5, -25)
FloatButton.Size = UDim2.new(0, 50, 0, 50)
FloatButton.Text = "⚡"
FloatButton.TextColor3 = Color3.fromRGB(80, 120, 255)
FloatButton.Font = Enum.Font.GothamBold
FloatButton.TextSize = 24
FloatButton.ZIndex = 1000
FloatButton.AutoButtonColor = false

local FloatCorner = Instance.new("UICorner")
FloatCorner.CornerRadius = UDim.new(1, 0)
FloatCorner.Parent = FloatButton

local FloatStroke = Instance.new("UIStroke")
FloatStroke.Parent = FloatButton
FloatStroke.Thickness = 2
FloatStroke.Color = Color3.fromRGB(80, 120, 255)
FloatStroke.Transparency = 0.5

local FloatGrad = Instance.new("UIGradient")
FloatGrad.Parent = FloatButton
FloatGrad.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(80, 120, 255)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(160, 100, 255))
})

-- Dragging for FloatButton
local f_dragging = false
local f_dragInput, f_mousePos, f_framePos

FloatButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        f_dragging = true
        f_mousePos = input.Position
        f_framePos = FloatButton.Position
        
        local connection
        connection = input.Changed:Connect(function()
            if input.UserInputState == Enum.UserInputState.End then
                f_dragging = false
                if connection then connection:Disconnect() end
            end
        end)
    end
end)

FloatButton.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
        f_dragInput = input
    end
end)

UserInputService.InputChanged:Connect(function(input)
    if input == f_dragInput and f_dragging then
        local delta = input.Position - f_mousePos
        FloatButton.Position = UDim2.new(f_framePos.X.Scale, f_framePos.X.Offset + delta.X, f_framePos.Y.Scale, f_framePos.Y.Offset + delta.Y)
    end
end)

FloatButton.MouseButton1Click:Connect(function()
    MainFrame.Visible = not MainFrame.Visible
end)

