--[[
    RIVALS — complete custom suite
    made by c9sp
    Modules : Aimbot, Silent Aim, ESP, Fly, Speed, Noclip, Skin Changer, Warp, Visuals, Unload
]]

local Players           = game:GetService("Players")
local RunService        = game:GetService("RunService")
local UserInputService  = game:GetService("UserInputService")
local Workspace         = game:GetService("Workspace")
local HttpService       = game:GetService("HttpService")
local TweenService      = game:GetService("TweenService")
local Lighting          = game:GetService("Lighting")
local LocalPlayer       = Players.LocalPlayer
local Camera            = Workspace.CurrentCamera

local ASSET_ID = "rbxassetid://109498791987569" 
local DISCORD_LINK = "https://discord.gg/EWy8JuY4kB"

-- ============================================================
-- CONFIG & STATE
-- ============================================================
local CONFIG_FOLDER = "RivalsCustom"
local CONFIG_FILE   = CONFIG_FOLDER .. "/config.json"
if not isfolder(CONFIG_FOLDER) then makefolder(CONFIG_FOLDER) end

local State = {
    ToggleKey = Enum.KeyCode.RightShift,
    Colors = {
        Background   = {18, 18, 22},
        Panel        = {26, 26, 32},
        Accent       = {160, 90, 255},
        Text         = {235, 235, 245},
        TextDim      = {140, 140, 160},
        Border       = {45, 45, 55},
        ToggleOn     = {160, 90, 255},
        ToggleOff    = {60, 60, 70},
        SliderFill   = {160, 90, 255},
        SliderBg     = {40, 40, 50},
        Danger       = {255, 80, 100},
        Discord      = {88, 101, 242},
    },
    ESP = {
        Enabled=true, Box=true, Skeleton=true, Tracer=true,
        Name=true, Distance=true, Health=true, TeamCheck=true, MaxDist=1500,
    },
    Aimbot = {
        Enabled=false, Silent=false, AlwaysOn=false,
        Key=Enum.KeyCode.E, FOV=140, Smooth=0.15, Part="Head",
        WallCheck=true, Prediction=true,
    },
    Movement = { Fly=false, FlySpeed=80, Speed=false, WalkSpeed=24, Noclip=false },
    ESPColors = {
        Box={188,78,255}, Skeleton={210,120,255},
        Tracer={160,60,240}, Name={240,230,255},
        HealthFull={100,255,140}, HealthLow={255,80,80},
    },
    Skin = { MeshId="", TextureId="" },
    Warp = { CustomPoints={} },
}

local function deepCopy(t)
    local c = {}
    for k, v in pairs(t) do
        if type(v) == "table" then c[k] = deepCopy(v) else c[k] = v end
    end
    return c
end

local function saveConfig()
    local data = deepCopy(State)
    data.ToggleKey = State.ToggleKey.Name
    data.Aimbot.Key = State.Aimbot.Key.Name
    local ok, encoded = pcall(function() return HttpService:JSONEncode(data) end)
    if ok then writefile(CONFIG_FILE, encoded) end
end

local function loadConfig()
    if not isfile(CONFIG_FILE) then return end
    local ok, decoded = pcall(function() return HttpService:JSONDecode(readfile(CONFIG_FILE)) end)
    if not ok or not decoded then return end
    local function merge(dst, src)
        for k, v in pairs(src) do
            if type(v) == "table" and type(dst[k]) == "table" then merge(dst[k], v)
            elseif dst[k] ~= nil then dst[k] = v end
        end
    end
    merge(State, decoded)
    State.ToggleKey = Enum.KeyCode[decoded.ToggleKey] or Enum.KeyCode.RightShift
    State.Aimbot.Key = Enum.KeyCode[decoded.Aimbot.Key] or Enum.KeyCode.E
end
loadConfig()

local function C(rgb) return Color3.fromRGB(rgb[1], rgb[2], rgb[3]) end
local function lerp(a, b, t) return a + (b - a) * t end

-- ============================================================
-- LOADING SCREEN
-- ============================================================
local LoadGui = Instance.new("ScreenGui")
LoadGui.Name = "RivalsLoader"
LoadGui.ResetOnSpawn = false
LoadGui.IgnoreGuiInset = true
LoadGui.DisplayOrder = 1000
LoadGui.Parent = game:GetService("CoreGui")

local LoadBg = Instance.new("Frame")
LoadBg.Size = UDim2.new(1, 0, 1, 0)
LoadBg.BackgroundColor3 = C(State.Colors.Background)
LoadBg.BorderSizePixel = 0
LoadBg.Parent = LoadGui

local BgGradient = Instance.new("UIGradient")
BgGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, C(State.Colors.Background)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(10, 10, 14))
})
BgGradient.Rotation = 45
BgGradient.Parent = LoadBg

local LoadCard = Instance.new("Frame")
LoadCard.Size = UDim2.new(0, 420, 0, 400)
LoadCard.Position = UDim2.new(0.5, -210, 0.5, -200)
LoadCard.BackgroundColor3 = C(State.Colors.Panel)
LoadCard.BackgroundTransparency = 0.1
LoadCard.BorderSizePixel = 0
LoadCard.Parent = LoadBg
local cardCorner = Instance.new("UICorner"); cardCorner.CornerRadius = UDim.new(0, 12); cardCorner.Parent = LoadCard
local cardStroke = Instance.new("UIStroke"); cardStroke.Color = C(State.Colors.Accent); cardStroke.Transparency = 0.6; cardStroke.Thickness = 1.5; cardStroke.Parent = LoadCard

local LogoContainer = Instance.new("Frame")
LogoContainer.Size = UDim2.new(0, 160, 0, 160)
LogoContainer.Position = UDim2.new(0.5, -80, 0, 30)
LogoContainer.BackgroundTransparency = 1
LogoContainer.Parent = LoadCard

local Ring1 = Instance.new("ImageLabel")
Ring1.Size = UDim2.new(0, 180, 0, 180)
Ring1.Position = UDim2.new(0.5, -90, 0.5, -90)
Ring1.BackgroundTransparency = 1
Ring1.Image = "rbxassetid://5028857084"
Ring1.ImageColor3 = C(State.Colors.Accent)
Ring1.ImageTransparency = 0.5
Ring1.Parent = LogoContainer

local Ring2 = Instance.new("ImageLabel")
Ring2.Size = UDim2.new(0, 150, 0, 150)
Ring2.Position = UDim2.new(0.5, -75, 0.5, -75)
Ring2.BackgroundTransparency = 1
Ring2.Image = "rbxassetid://5028857472"
Ring2.ImageColor3 = C(State.Colors.Accent)
Ring2.ImageTransparency = 0.3
Ring2.Parent = LogoContainer

local LogoGlow = Instance.new("ImageLabel")
LogoGlow.Size = UDim2.new(0, 140, 0, 140)
LogoGlow.Position = UDim2.new(0.5, -70, 0.5, -70)
LogoGlow.BackgroundTransparency = 1
LogoGlow.Image = ASSET_ID
LogoGlow.ImageTransparency = 0.7
LogoGlow.ImageColor3 = C(State.Colors.Accent)
LogoGlow.ScaleType = Enum.ScaleType.Fit
LogoGlow.Parent = LogoContainer

local Logo = Instance.new("ImageLabel")
Logo.Size = UDim2.new(0, 110, 0, 110)
Logo.Position = UDim2.new(0.5, -55, 0.5, -55)
Logo.BackgroundTransparency = 1
Logo.Image = ASSET_ID
Logo.ScaleType = Enum.ScaleType.Fit
Logo.ZIndex = 2
Logo.Parent = LogoContainer

local LoadTitle = Instance.new("TextLabel")
LoadTitle.Size = UDim2.new(1, -40, 0, 40)
LoadTitle.Position = UDim2.new(0, 0, 0, 200)
LoadTitle.BackgroundTransparency = 1
LoadTitle.Text = "R I V A L S"
LoadTitle.TextColor3 = C(State.Colors.Text)
LoadTitle.Font = Enum.Font.GothamBold
LoadTitle.TextSize = 32
LoadTitle.Parent = LoadCard

local AccentLine = Instance.new("Frame")
AccentLine.Size = UDim2.new(0, 100, 0, 3)
AccentLine.Position = UDim2.new(0.5, -50, 0, 245)
AccentLine.BackgroundColor3 = C(State.Colors.Accent)
AccentLine.BorderSizePixel = 0
AccentLine.Parent = LoadCard
local AccentCorner = Instance.new("UICorner"); AccentCorner.CornerRadius = UDim.new(0, 2); AccentCorner.Parent = AccentLine
local AccentGradient = Instance.new("UIGradient")
AccentGradient.Color = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
    ColorSequenceKeypoint.new(0.5, C(State.Colors.Accent)),
    ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
})
AccentGradient.Parent = AccentLine

local LoadStatus = Instance.new("TextLabel")
LoadStatus.Size = UDim2.new(1, -40, 0, 20)
LoadStatus.Position = UDim2.new(0, 20, 0, 280)
LoadStatus.BackgroundTransparency = 1
LoadStatus.Text = "initializing..."
LoadStatus.TextColor3 = C(State.Colors.TextDim)
LoadStatus.Font = Enum.Font.Gotham
LoadStatus.TextSize = 12
LoadStatus.TextXAlignment = Enum.TextXAlignment.Left
LoadStatus.Parent = LoadCard

local BarBg = Instance.new("Frame")
BarBg.Size = UDim2.new(1, -40, 0, 8)
BarBg.Position = UDim2.new(0, 20, 0, 310)
BarBg.BackgroundColor3 = Color3.fromRGB(30, 30, 38)
BarBg.BorderSizePixel = 0
BarBg.ClipsDescendants = true
BarBg.Parent = LoadCard
local barBgCorner = Instance.new("UICorner"); barBgCorner.CornerRadius = UDim.new(0, 4); barBgCorner.Parent = BarBg

local BarFill = Instance.new("Frame")
BarFill.Size = UDim2.new(0, 0, 1, 0)
BarFill.BackgroundColor3 = C(State.Colors.Accent)
BarFill.BorderSizePixel = 0
BarFill.Parent = BarBg
local barFillCorner = Instance.new("UICorner"); barFillCorner.CornerRadius = UDim.new(0, 4); barFillCorner.Parent = BarFill

local BarShine = Instance.new("Frame")
BarShine.Size = UDim2.new(0, 60, 1, 0)
BarShine.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
BarShine.BackgroundTransparency = 0.6
BarShine.BorderSizePixel = 0
BarShine.Parent = BarFill
local BarShineGradient = Instance.new("UIGradient")
BarShineGradient.Transparency = NumberSequence.new({
    NumberSequenceKeypoint.new(0, 1),
    NumberSequenceKeypoint.new(0.5, 0.4),
    NumberSequenceKeypoint.new(1, 1)
})
BarShineGradient.Parent = BarShine

local PercentLabel = Instance.new("TextLabel")
PercentLabel.Size = UDim2.new(0, 50, 0, 20)
PercentLabel.Position = UDim2.new(1, -70, 0, 280)
PercentLabel.BackgroundTransparency = 1
PercentLabel.Text = "0%"
PercentLabel.TextColor3 = C(State.Colors.Accent)
PercentLabel.Font = Enum.Font.GothamBold
PercentLabel.TextSize = 12
PercentLabel.TextXAlignment = Enum.TextXAlignment.Right
PercentLabel.Parent = LoadCard

local Credit = Instance.new("TextLabel")
Credit.Size = UDim2.new(1, -40, 0, 20)
Credit.Position = UDim2.new(0, 20, 1, -35)
Credit.BackgroundTransparency = 1
Credit.Text = "made by c9sp"
Credit.TextColor3 = C(State.Colors.TextDim)
Credit.Font = Enum.Font.GothamBold
Credit.TextSize = 11
Credit.Parent = LoadCard

-- Animations Loader
task.spawn(function()
    while LoadGui.Parent do
        Ring1.Rotation = Ring1.Rotation + 1
        Ring2.Rotation = Ring2.Rotation - 2
        task.wait(0.01)
    end
end)
task.spawn(function()
    while LoadGui.Parent do
        TweenService:Create(LogoGlow, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {ImageTransparency = 0.2, Size = UDim2.new(0, 150, 0, 150), Position = UDim2.new(0.5, -75, 0.5, -75)}):Play()
        task.wait(1)
        TweenService:Create(LogoGlow, TweenInfo.new(1, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut), {ImageTransparency = 0.7, Size = UDim2.new(0, 140, 0, 140), Position = UDim2.new(0.5, -70, 0.5, -70)}):Play()
        task.wait(1)
    end
end)
task.spawn(function()
    while LoadGui.Parent do
        BarShine.Position = UDim2.new(-0.5, 0, 0, 0)
        TweenService:Create(BarShine, TweenInfo.new(1.5, Enum.EasingStyle.Linear), {Position = UDim2.new(1.5, 0, 0, 0)}):Play()
        task.wait(1.5)
    end
end)

-- ============================================================
-- MODULE LOGIC
-- ============================================================
local function getAlivePlayers()
    local list = {}
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local hum = p.Character:FindFirstChildOfClass("Humanoid")
            local root = p.Character:FindFirstChild("HumanoidRootPart")
            if hum and root and hum.Health > 0 then
                table.insert(list, { player = p, hum = hum, root = root })
            end
        end
    end
    return list
end

local function getAimPart(entry)
    local part = entry.player.Character:FindFirstChild(State.Aimbot.Part)
    return part and part.Position or entry.root.Position
end

local aimbotConn
local function startAimbot()
    if aimbotConn then return end
    aimbotConn = RunService.RenderStepped:Connect(function(dt)
        if not State.Aimbot.Enabled then return end
        local targets = getAlivePlayers()
        local best, bestDist = nil, State.Aimbot.FOV
        for _, e in ipairs(targets) do
            local screenPos, onScreen = Camera:WorldToViewportPoint(getAimPart(e))
            if onScreen then
                local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                local d = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                if d < bestDist then bestDist = d; best = e end
            end
        end
        if best then
            local targetPos = getAimPart(best)
            if State.Aimbot.Prediction and best.root.AssemblyLinearVelocity then
                targetPos = targetPos + best.root.AssemblyLinearVelocity * 0.09
            end
            if State.Aimbot.WallCheck then
                local rayOrigin = Camera.CFrame.Position
                local rayDirection = (targetPos - rayOrigin)
                local raycastParams = RaycastParams.new()
                raycastParams.FilterDescendantsInstances = {LocalPlayer.Character}
                raycastParams.FilterType = Enum.RaycastFilterType.Exclude
                local raycastResult = Workspace:Raycast(rayOrigin, rayDirection, raycastParams)
                if raycastResult and not raycastResult.Instance:IsDescendantOf(best.player.Character) then return end
            end
            local desired = CFrame.new(Camera.CFrame.Position, targetPos)
            Camera.CFrame = Camera.CFrame:Lerp(desired, State.Aimbot.Smooth)
        end
    end)
end

local silentConn, originalNamecall
local function startSilentAim()
    if silentConn then return end
    local mt = getrawmetatable(game)
    originalNamecall = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if State.Aimbot.Silent and (method == "Raycast" or method == "FindPartOnRay" or method == "FindPartOnRayWithIgnoreList") then
            local targets = getAlivePlayers()
            local best, bestDist = nil, State.Aimbot.FOV
            for _, e in ipairs(targets) do
                local screenPos, onScreen = Camera:WorldToViewportPoint(getAimPart(e))
                if onScreen then
                    local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                    local d = (Vector2.new(screenPos.X, screenPos.Y) - center).Magnitude
                    if d < bestDist then bestDist = d; best = e end
                end
            end
            if best then
                local origin = Camera.CFrame.Position
                local dir = (getAimPart(best) - origin)
                return originalNamecall(self, origin, dir, ...)
            end
        end
        return originalNamecall(self, ...)
    end)
    setreadonly(mt, true)
    silentConn = true
end

local flyBody, flyGyro, flyConn
local function toggleFly(on)
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    if on then
        flyBody = Instance.new("BodyVelocity")
        flyBody.MaxForce = Vector3.new(1e5, 1e5, 1e5)
        flyBody.Velocity = Vector3.zero
        flyBody.Parent = hrp
        flyGyro = Instance.new("BodyGyro")
        flyGyro.MaxTorque = Vector3.new(1e5, 1e5, 1e5)
        flyGyro.CFrame = hrp.CFrame
        flyGyro.Parent = hrp
        flyConn = RunService.RenderStepped:Connect(function()
            if not State.Movement.Fly then return end
            local cam = Camera.CFrame
            local move = Vector3.zero
            local look = cam.LookVector
            local right = cam.RightVector
            if UserInputService:IsKeyDown(Enum.KeyCode.W) then move = move + look end
            if UserInputService:IsKeyDown(Enum.KeyCode.S) then move = move - look end
            if UserInputService:IsKeyDown(Enum.KeyCode.D) then move = move + right end
            if UserInputService:IsKeyDown(Enum.KeyCode.A) then move = move - right end
            if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move = move + Vector3.new(0,1,0) end
            if UserInputService:IsKeyDown(Enum.KeyCode.LeftControl) then move = move - Vector3.new(0,1,0) end
            flyBody.Velocity = move * State.Movement.FlySpeed
            flyGyro.CFrame = cam
        end)
    else
        if flyBody then flyBody:Destroy(); flyBody = nil end
        if flyGyro then flyGyro:Destroy(); flyGyro = nil end
        if flyConn then flyConn:Disconnect(); flyConn = nil end
    end
end

local moveConn = RunService.Stepped:Connect(function()
    local char = LocalPlayer.Character
    if not char then return end
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = State.Movement.Speed and State.Movement.WalkSpeed or 16
    end
    if State.Movement.Noclip then
        for _, v in ipairs(char:GetDescendants()) do
            if v:IsA("BasePart") and v.CanCollide then v.CanCollide = false end
        end
    end
end)

local function applySkin()
    local char = LocalPlayer.Character
    if not char then return end
    for _, tool in ipairs(char:GetChildren()) do
        if tool:IsA("Tool") then
            local handle = tool:FindFirstChild("Handle")
            if handle then
                for _, v in ipairs(handle:GetDescendants()) do
                    if v:IsA("SpecialMesh") or v:IsA("MeshPart") then
                        if State.Skin.MeshId ~= "" then v.MeshId = State.Skin.MeshId end
                        if State.Skin.TextureId ~= "" then
                            if v:IsA("SpecialMesh") then v.TextureId = State.Skin.TextureId
                            elseif v:IsA("MeshPart") then v.TextureID = State.Skin.TextureId end
                        end
                    end
                end
            end
        end
    end
end

local function scanWaypoints()
    local found = {}
    for _, v in ipairs(Workspace:GetDescendants()) do
        if v:IsA("BasePart") then
            local n = v.Name:lower()
            if n:find("spawn") or n:find("portal") or n:find("waypoint") or n:find("checkpoint") then
                table.insert(found, v)
            end
        end
    end
    return found
end

local function teleportTo(cf)
    local char = LocalPlayer.Character
    if not char then return end
    local hrp = char:FindFirstChild("HumanoidRootPart")
    if hrp then hrp.CFrame = cf end
end

-- ============================================================
-- MAIN GUI
-- ============================================================
local function buildMainGUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "RivalsCustomGUI"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.DisplayOrder = 999
    ScreenGui.Parent = game:GetService("CoreGui")

    local Main = Instance.new("Frame")
    Main.Size = UDim2.new(0, 520, 0, 600)
    Main.Position = UDim2.new(0.5, -260, 0.5, -300)
    Main.BackgroundColor3 = C(State.Colors.Background)
    Main.BorderSizePixel = 0
    Main.Active = true
    Main.ClipsDescendants = true
    Main.Visible = false
    Main.Parent = ScreenGui
    local MainCorner = Instance.new("UICorner"); MainCorner.CornerRadius = UDim.new(0, 8); MainCorner.Parent = Main
    local MainStroke = Instance.new("UIStroke"); MainStroke.Color = C(State.Colors.Border); MainStroke.Thickness = 1; MainStroke.Parent = Main

    local BgLogo = Instance.new("ImageLabel")
    BgLogo.Size = UDim2.new(0, 400, 0, 400)
    BgLogo.Position = UDim2.new(0.5, -200, 0.5, -200)
    BgLogo.BackgroundTransparency = 1
    BgLogo.Image = ASSET_ID
    BgLogo.ScaleType = Enum.ScaleType.Fit
    BgLogo.ImageTransparency = 0.9
    BgLogo.ImageColor3 = C(State.Colors.Accent)
    BgLogo.ZIndex = 0
    BgLogo.Parent = Main

    local TitleBar = Instance.new("Frame")
    TitleBar.Size = UDim2.new(1, 0, 0, 40)
    TitleBar.BackgroundColor3 = C(State.Colors.Panel)
    TitleBar.BorderSizePixel = 0
    TitleBar.ZIndex = 2
    TitleBar.Parent = Main
    local TitleCorner = Instance.new("UICorner"); TitleCorner.CornerRadius = UDim.new(0, 8); TitleCorner.Parent = TitleBar

    local MenuLogo = Instance.new("ImageLabel")
    MenuLogo.Size = UDim2.new(0, 28, 0, 28)
    MenuLogo.Position = UDim2.new(0, 8, 0, 6)
    MenuLogo.BackgroundTransparency = 1
    MenuLogo.Image = ASSET_ID
    MenuLogo.ScaleType = Enum.ScaleType.Fit
    MenuLogo.ZIndex = 3
    MenuLogo.Parent = TitleBar

    local TitleText = Instance.new("TextLabel")
    TitleText.Size = UDim2.new(1, -130, 1, 0)
    TitleText.Position = UDim2.new(0, 42, 0, 0)
    TitleText.BackgroundTransparency = 1
    TitleText.Text = "RIVALS — custom  |  c9sp"
    TitleText.TextColor3 = C(State.Colors.Text)
    TitleText.TextXAlignment = Enum.TextXAlignment.Left
    TitleText.Font = Enum.Font.GothamBold
    TitleText.TextSize = 15
    TitleText.ZIndex = 3
    TitleText.Parent = TitleBar

    local UnloadBtn = Instance.new("TextButton")
    UnloadBtn.Size = UDim2.new(0, 30, 0, 30)
    UnloadBtn.Position = UDim2.new(1, -75, 0, 5)
    UnloadBtn.BackgroundColor3 = C(State.Colors.Danger)
    UnloadBtn.Text = "🗑"
    UnloadBtn.TextColor3 = C(State.Colors.Text)
    UnloadBtn.Font = Enum.Font.GothamBold
    UnloadBtn.TextSize = 16
    UnloadBtn.BorderSizePixel = 0
    UnloadBtn.ZIndex = 3
    UnloadBtn.Parent = TitleBar
    local UnloadCorner = Instance.new("UICorner"); UnloadCorner.CornerRadius = UDim.new(0, 6); UnloadCorner.Parent = UnloadBtn

    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -38, 0, 5)
    CloseBtn.BackgroundColor3 = C(State.Colors.ToggleOff)
    CloseBtn.Text = "×"
    CloseBtn.TextColor3 = C(State.Colors.Text)
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.TextSize = 18
    CloseBtn.BorderSizePixel = 0
    CloseBtn.ZIndex = 3
    CloseBtn.Parent = TitleBar
    local CloseCorner = Instance.new("UICorner"); CloseCorner.CornerRadius = UDim.new(0, 6); CloseCorner.Parent = CloseBtn
    CloseBtn.MouseButton1Click:Connect(function() Main.Visible = false end)

    -- Drag System
    local dragging, dragInput, dragStart, startPos
    TitleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = Main.Position
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then dragging = false end
    end)

    -- Resize System
    local ResizeHandle = Instance.new("TextButton")
    ResizeHandle.Size = UDim2.new(0, 16, 0, 16)
    ResizeHandle.Position = UDim2.new(1, -16, 1, -16)
    ResizeHandle.BackgroundColor3 = C(State.Colors.Accent)
    ResizeHandle.BackgroundTransparency = 0.5
    ResizeHandle.Text = "◢"
    ResizeHandle.TextColor3 = C(State.Colors.Text)
    ResizeHandle.TextSize = 12
    ResizeHandle.Font = Enum.Font.GothamBold
    ResizeHandle.BorderSizePixel = 0
    ResizeHandle.ZIndex = 10
    ResizeHandle.Parent = Main
    local ResizeCorner = Instance.new("UICorner"); ResizeCorner.CornerRadius = UDim.new(0, 4); ResizeCorner.Parent = ResizeHandle

    local resizing, resizeStart, startSize
    ResizeHandle.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            resizing = true; resizeStart = input.Position; startSize = Main.Size
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if resizing and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
            local delta = input.Position - resizeStart
            Main.Size = UDim2.new(0, math.max(400, startSize.X.Offset + delta.X), 0, math.max(300, startSize.Y.Offset + delta.Y))
        end
    end)
    UserInputService.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then resizing = false end
    end)

    -- Unload System
    UnloadBtn.MouseButton1Click:Connect(function()
        if aimbotConn then aimbotConn:Disconnect() end
        if moveConn then moveConn:Disconnect() end
        if flyConn then flyConn:Disconnect() end
        if originalNamecall then
            pcall(function()
                local mt = getrawmetatable(game)
                setreadonly(mt, false)
                mt.__namecall = originalNamecall
                setreadonly(mt, true)
            end)
        end
        if ScreenGui then ScreenGui:Destroy() end
    end)

    local TabBar = Instance.new("ScrollingFrame")
    TabBar.Size = UDim2.new(1, -20, 0, 36)
    TabBar.Position = UDim2.new(0, 10, 0, 48)
    TabBar.BackgroundColor3 = C(State.Colors.Background)
    TabBar.BackgroundTransparency = 0.4
    TabBar.BorderSizePixel = 0
    TabBar.ScrollBarThickness = 0
    TabBar.ScrollingDirection = Enum.ScrollingDirection.X
    TabBar.ZIndex = 2
    TabBar.Parent = Main
    local TabLayout = Instance.new("UIListLayout"); TabLayout.FillDirection = Enum.FillDirection.Horizontal; TabLayout.Padding = UDim.new(0, 6); TabLayout.Parent = TabBar

    local Content = Instance.new("Frame")
    Content.Size = UDim2.new(1, -20, 1, -100)
    Content.Position = UDim2.new(0, 10, 0, 92)
    Content.BackgroundTransparency = 1
    Content.ClipsDescendants = true
    Content.ZIndex = 2
    Content.Parent = Main

    -- Helpers
    local function makeCorner(p, r) local c=Instance.new("UICorner"); c.CornerRadius=UDim.new(0,r or 6); c.Parent=p; return c end
    local function makeStroke(p, col) local s=Instance.new("UIStroke"); s.Color=col; s.Thickness=1; s.Parent=p; return s end
    local function makeLabel(parent, text, size, pos, color, bold)
        local l = Instance.new("TextLabel"); l.Size=size; l.Position=pos; l.BackgroundTransparency=1
        l.Text=text; l.TextColor3=color or C(State.Colors.Text); l.TextXAlignment=Enum.TextXAlignment.Left
        l.Font=bold and Enum.Font.GothamBold or Enum.Font.Gotham; l.TextSize=13; l.ZIndex=3; l.Parent=parent
        return l
    end

    local function makeToggle(parent, labelText, initialValue, callback)
        local frame = Instance.new("Frame"); frame.Size=UDim2.new(1,-10,0,32); frame.BackgroundTransparency=1; frame.ZIndex=3; frame.Parent=parent
        local label = Instance.new("TextLabel"); label.Size=UDim2.new(1,-50,1,0); label.BackgroundTransparency=1
        label.Text=labelText; label.TextColor3=C(State.Colors.Text); label.TextXAlignment=Enum.TextXAlignment.Left
        label.Font=Enum.Font.Gotham; label.TextSize=13; label.ZIndex=3; label.Parent=frame
        local btn = Instance.new("TextButton"); btn.Size=UDim2.new(0,38,0,20); btn.Position=UDim2.new(1,-38,0.5,-10)
        btn.BackgroundColor3=initialValue and C(State.Colors.ToggleOn) or C(State.Colors.ToggleOff)
        btn.Text=""; btn.BorderSizePixel=0; btn.ZIndex=3; btn.Parent=frame
        makeCorner(btn,10)
        local knob = Instance.new("Frame"); knob.Size=UDim2.new(0,16,0,16)
        knob.Position=UDim2.new(0,initialValue and 20 or 2,0.5,-8)
        knob.BackgroundColor3=Color3.fromRGB(255,255,255); knob.BorderSizePixel=0; knob.ZIndex=3; knob.Parent=btn
        makeCorner(knob,8)
        local value = initialValue
        local function update()
            btn.BackgroundColor3 = value and C(State.Colors.ToggleOn) or C(State.Colors.ToggleOff)
            knob.Position = UDim2.new(0, value and 20 or 2, 0.5, -8)
        end
        btn.MouseButton1Click:Connect(function()
            value = not value; update(); if callback then callback(value) end; saveConfig()
        end)
        return { Set = function(v) value=v; update() end, Get = function() return value end }
    end

    local function makeSlider(parent, labelText, min, max, initialValue, callback)
        local frame = Instance.new("Frame"); frame.Size=UDim2.new(1,-10,0,50); frame.BackgroundTransparency=1; frame.ZIndex=3; frame.Parent=parent
        local label = Instance.new("TextLabel"); label.Size=UDim2.new(1,-60,0,22); label.BackgroundTransparency=1
        label.Text=labelText; label.TextColor3=C(State.Colors.Text); label.TextXAlignment=Enum.TextXAlignment.Left
        label.Font=Enum.Font.Gotham; label.TextSize=13; label.ZIndex=3; label.Parent=frame
        local valLabel = Instance.new("TextLabel"); valLabel.Size=UDim2.new(0,50,0,22); valLabel.Position=UDim2.new(1,-50,0,0)
        valLabel.BackgroundTransparency=1; valLabel.Text=tostring(initialValue); valLabel.TextColor3=C(State.Colors.Accent)
        valLabel.TextXAlignment=Enum.TextXAlignment.Right; valLabel.Font=Enum.Font.GothamBold; valLabel.TextSize=13
        valLabel.ZIndex=3; valLabel.Parent=frame
        local bar = Instance.new("Frame"); bar.Size=UDim2.new(1,0,0,6); bar.Position=UDim2.new(0,0,0,30)
        bar.BackgroundColor3=C(State.Colors.SliderBg); bar.BorderSizePixel=0; bar.ZIndex=3; bar.Parent=frame
        makeCorner(bar,3)
        local fill = Instance.new("Frame"); fill.Size=UDim2.new((initialValue-min)/(max-min),0,1,0)
        fill.BackgroundColor3=C(State.Colors.SliderFill); fill.BorderSizePixel=0; fill.ZIndex=3; fill.Parent=bar
        makeCorner(fill,3)
        local knob = Instance.new("Frame"); knob.Size=UDim2.new(0,14,0,14)
        knob.Position=UDim2.new((initialValue-min)/(max-min),-7,0.5,-7)
        knob.BackgroundColor3=Color3.fromRGB(255,255,255); knob.BorderSizePixel=0; knob.ZIndex=3; knob.Parent=bar
        makeCorner(knob,7)
        local dragging = false
        local function setFromMouse(x)
            local rel = math.clamp((x - bar.AbsolutePosition.X) / bar.AbsoluteSize.X, 0, 1)
            local v = min + rel * (max - min); v = math.floor(v*10+0.5)/10
            fill.Size = UDim2.new(rel,0,1,0); knob.Position = UDim2.new(rel,-7,0.5,-7)
            valLabel.Text = tostring(v); if callback then callback(v) end
        end
        bar.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then dragging=true; setFromMouse(input.Position.X) end end)
        UserInputService.InputChanged:Connect(function(input) if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then setFromMouse(input.Position.X) end end)
        UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then if dragging then saveConfig() end; dragging = false end end)
        return { Set = function(v) local rel = (v-min)/(max-min); fill.Size = UDim2.new(rel,0,1,0); knob.Position = UDim2.new(rel,-7,0.5,-7); valLabel.Text = tostring(v) end }
    end

    local function makeColorPicker(parent, labelText, initialRGB, callback)
        local frame = Instance.new("Frame"); frame.Size=UDim2.new(1,-10,0,36); frame.BackgroundTransparency=1; frame.ZIndex=3; frame.Parent=parent
        local label = Instance.new("TextLabel"); label.Size=UDim2.new(1,-70,1,0); label.BackgroundTransparency=1
        label.Text=labelText; label.TextColor3=C(State.Colors.Text); label.TextXAlignment=Enum.TextXAlignment.Left
        label.Font=Enum.Font.Gotham; label.TextSize=13; label.ZIndex=3; label.Parent=frame
        local swatch = Instance.new("TextButton"); swatch.Size=UDim2.new(0,40,0,22); swatch.Position=UDim2.new(1,-70,0.5,-11)
        swatch.BackgroundColor3=Color3.fromRGB(initialRGB[1],initialRGB[2],initialRGB[3])
        swatch.Text=""; swatch.BorderSizePixel=0; swatch.ZIndex=3; swatch.Parent=frame
        makeCorner(swatch,4); makeStroke(swatch, C(State.Colors.Border))
        local rgbLabel = Instance.new("TextLabel"); rgbLabel.Size=UDim2.new(0,20,1,0); rgbLabel.Position=UDim2.new(1,-24,0,0)
        rgbLabel.BackgroundTransparency=1; rgbLabel.Text="…"; rgbLabel.TextColor3=C(State.Colors.TextDim)
        rgbLabel.Font=Enum.Font.GothamBold; rgbLabel.TextSize=16; rgbLabel.ZIndex=3; rgbLabel.Parent=frame
        swatch.MouseButton1Click:Connect(function()
            local popup = Instance.new("Frame")
            popup.Size=UDim2.new(0,240,0,180)
            popup.Position = UDim2.new(0, math.clamp(swatch.AbsolutePosition.X - Main.AbsolutePosition.X - 100, 10, 270), 0, math.clamp(swatch.AbsolutePosition.Y - Main.AbsolutePosition.Y + 30, 10, 400))
            popup.BackgroundColor3=C(State.Colors.Panel); popup.BorderSizePixel=0; popup.ZIndex=10; popup.Parent=Main
            makeCorner(popup,6); makeStroke(popup, C(State.Colors.Border))
            local current = {initialRGB[1], initialRGB[2], initialRGB[3]}
            local preview = Instance.new("Frame"); preview.Size=UDim2.new(1,-20,0,30); preview.Position=UDim2.new(0,10,0,8)
            preview.BackgroundColor3=Color3.fromRGB(current[1],current[2],current[3]); preview.BorderSizePixel=0
            preview.ZIndex=11; preview.Parent=popup; makeCorner(preview,4)
            for i, ch in ipairs({"R","G","B"}) do
                local y = 48 + (i-1)*40
                local lbl = Instance.new("TextLabel"); lbl.Size=UDim2.new(0,20,0,20); lbl.Position=UDim2.new(0,10,0,y)
                lbl.BackgroundTransparency=1; lbl.Text=ch; lbl.TextColor3=C(State.Colors.TextDim)
                lbl.Font=Enum.Font.GothamBold; lbl.TextSize=12; lbl.ZIndex=11; lbl.Parent=popup
                local bar = Instance.new("Frame"); bar.Size=UDim2.new(1,-50,0,8); bar.Position=UDim2.new(0,35,0,y+6)
                bar.BackgroundColor3=C(State.Colors.SliderBg); bar.BorderSizePixel=0; bar.ZIndex=11; bar.Parent=popup
                makeCorner(bar,4)
                local fill = Instance.new("Frame"); fill.Size=UDim2.new(current[i]/255,0,1,0)
                fill.BackgroundColor3 = (i==1 and Color3.fromRGB(255,80,80)) or (i==2 and Color3.fromRGB(80,255,80)) or Color3.fromRGB(80,80,255)
                fill.BorderSizePixel=0; fill.ZIndex=11; fill.Parent=bar; makeCorner(fill,4)
                local drag = false
                bar.InputBegan:Connect(function(input)
                    if input.UserInputType == Enum.UserInputType.MouseButton1 then
                        drag = true
                        local rel = math.clamp((input.Position.X - bar.AbsolutePosition.X)/bar.AbsoluteSize.X, 0, 1)
                        current[i] = math.floor(rel*255); fill.Size = UDim2.new(rel,0,1,0)
                        preview.BackgroundColor3 = Color3.fromRGB(current[1],current[2],current[3])
                    end
                end)
                UserInputService.InputChanged:Connect(function(input)
                    if drag and input.UserInputType == Enum.UserInputType.MouseMovement then
                        local rel = math.clamp((input.Position.X - bar.AbsolutePosition.X)/bar.AbsoluteSize.X, 0, 1)
                        current[i] = math.floor(rel*255); fill.Size = UDim2.new(rel,0,1,0)
                        preview.BackgroundColor3 = Color3.fromRGB(current[1],current[2],current[3])
                    end
                end)
                UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then drag=false end end)
            end
            local okBtn = Instance.new("TextButton"); okBtn.Size=UDim2.new(0,60,0,24); okBtn.Position=UDim2.new(1,-70,1,-32)
            okBtn.BackgroundColor3=C(State.Colors.Accent); okBtn.Text="OK"; okBtn.TextColor3=Color3.fromRGB(255,255,255)
            okBtn.Font=Enum.Font.GothamBold; okBtn.TextSize=12; okBtn.BorderSizePixel=0; okBtn.ZIndex=11; okBtn.Parent=popup
            makeCorner(okBtn,4)
            okBtn.MouseButton1Click:Connect(function()
                swatch.BackgroundColor3 = Color3.fromRGB(current[1],current[2],current[3])
                if callback then callback(current) end; saveConfig(); popup:Destroy()
            end)
        end)
    end

    local function makeKeybind(parent, labelText, currentKey, callback)
        local frame = Instance.new("Frame"); frame.Size=UDim2.new(1,-10,0,36); frame.BackgroundTransparency=1; frame.ZIndex=3; frame.Parent=parent
        local label = Instance.new("TextLabel"); label.Size=UDim2.new(1,-80,1,0); label.BackgroundTransparency=1
        label.Text=labelText; label.TextColor3=C(State.Colors.Text); label.TextXAlignment=Enum.TextXAlignment.Left
        label.Font=Enum.Font.Gotham; label.TextSize=13; label.ZIndex=3; label.Parent=frame
        local btn = Instance.new("TextButton"); btn.Size=UDim2.new(0,70,0,24); btn.Position=UDim2.new(1,-70,0.5,-12)
        btn.BackgroundColor3=C(State.Colors.ToggleOff); btn.Text=currentKey.Name; btn.TextColor3=C(State.Colors.Text)
        btn.Font=Enum.Font.GothamBold; btn.TextSize=12; btn.BorderSizePixel=0; btn.ZIndex=3; btn.Parent=frame
        makeCorner(btn,4)
        local listening = false
        btn.MouseButton1Click:Connect(function() listening = true; btn.Text = "…"; btn.BackgroundColor3 = C(State.Colors.Accent) end)
        UserInputService.InputBegan:Connect(function(input, gp)
            if not listening or gp then return end
            if input.UserInputType ~= Enum.UserInputType.Keyboard then return end
            listening = false; btn.Text = input.KeyCode.Name; btn.BackgroundColor3 = C(State.Colors.ToggleOff)
            if callback then callback(input.KeyCode) end; saveConfig()
        end)
    end

    local function makeButton(parent, labelText, callback, customColor)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(1, -10, 0, 34); btn.BackgroundColor3 = customColor or C(State.Colors.Panel)
        btn.Text = labelText; btn.TextColor3 = C(State.Colors.Text)
        btn.Font = Enum.Font.GothamBold; btn.TextSize = 13; btn.BorderSizePixel = 0; btn.ZIndex = 3; btn.Parent = parent
        makeCorner(btn, 6); makeStroke(btn, C(State.Colors.Border))
        btn.MouseButton1Click:Connect(function() if callback then callback() end end)
        return btn
    end

    local function makeTextbox(parent, placeholder, callback)
        local box = Instance.new("TextBox")
        box.Size = UDim2.new(1, -10, 0, 30); box.BackgroundColor3 = C(State.Colors.Panel)
        box.Text = ""; box.PlaceholderText = placeholder; box.PlaceholderColor3 = C(State.Colors.TextDim)
        box.TextColor3 = C(State.Colors.Text); box.Font = Enum.Font.Gotham; box.TextSize = 12
        box.BorderSizePixel = 0; box.ZIndex = 3; box.Parent = parent
        makeCorner(box, 6); makeStroke(box, C(State.Colors.Border))
        box.FocusLost:Connect(function() if callback then callback(box.Text) end end)
        return box
    end

    local tabs = {}
    local function createTab(name)
        local btn = Instance.new("TextButton")
        btn.Size = UDim2.new(0, 75, 0, 32); btn.BackgroundColor3 = C(State.Colors.Background)
        btn.Text = name; btn.TextColor3 = C(State.Colors.TextDim)
        btn.Font = Enum.Font.GothamBold; btn.TextSize = 11; btn.BorderSizePixel = 0; btn.ZIndex = 3; btn.Parent = TabBar
        makeCorner(btn, 6)
        local page = Instance.new("ScrollingFrame")
        page.Size = UDim2.new(1, 0, 1, 0); page.BackgroundTransparency = 1; page.BorderSizePixel = 0
        page.ScrollBarThickness = 4; page.ScrollBarImageColor3 = C(State.Colors.Accent)
        page.Visible = false; page.ZIndex = 2; page.Parent = Content
        local layout = Instance.new("UIListLayout"); layout.Padding = UDim.new(0, 8); layout.Parent = page
        local padding = Instance.new("UIPadding")
        padding.PaddingTop = UDim.new(0, 8); padding.PaddingLeft = UDim.new(0, 4); padding.PaddingRight = UDim.new(0, 4)
        padding.Parent = page
        tabs[name] = { button = btn, page = page }
        btn.MouseButton1Click:Connect(function()
            for _, t in pairs(tabs) do
                t.page.Visible = false; t.button.BackgroundColor3 = C(State.Colors.Background); t.button.TextColor3 = C(State.Colors.TextDim)
            end
            page.Visible = true; btn.BackgroundColor3 = C(State.Colors.Accent); btn.TextColor3 = C(State.Colors.Text)
        end)
        return page
    end

    -- COMBAT
    local Combat = createTab("Combat")
    makeToggle(Combat, "Aimbot", State.Aimbot.Enabled, function(v) State.Aimbot.Enabled = v; if v then startAimbot() end end)
    makeToggle(Combat, "Silent Aim", State.Aimbot.Silent, function(v) State.Aimbot.Silent = v; if v then startSilentAim() end end)
    makeToggle(Combat, "Always On", State.Aimbot.AlwaysOn, function(v) State.Aimbot.AlwaysOn = v end)
    makeSlider(Combat, "FOV", 10, 360, State.Aimbot.FOV, function(v) State.Aimbot.FOV = v end)
    makeSlider(Combat, "Smoothness", 0.01, 1, State.Aimbot.Smooth, function(v) State.Aimbot.Smooth = v end)
    makeToggle(Combat, "Wall Check", State.Aimbot.WallCheck, function(v) State.Aimbot.WallCheck = v end)
    makeToggle(Combat, "Prediction", State.Aimbot.Prediction, function(v) State.Aimbot.Prediction = v end)
    makeLabel(Combat, "Aimbot Key", UDim2.new(1,0,0,20), UDim2.new(0,4,0,0), C(State.Colors.TextDim))
    makeKeybind(Combat, "", State.Aimbot.Key, function(k) State.Aimbot.Key = k end)

    -- ESP
    local ESPTab = createTab("ESP")
    makeToggle(ESPTab, "ESP Enabled", State.ESP.Enabled, function(v) State.ESP.Enabled = v end)
    makeToggle(ESPTab, "Box", State.ESP.Box, function(v) State.ESP.Box = v end)
    makeToggle(ESPTab, "Skeleton", State.ESP.Skeleton, function(v) State.ESP.Skeleton = v end)
    makeToggle(ESPTab, "Tracer", State.ESP.Tracer, function(v) State.ESP.Tracer = v end)
    makeToggle(ESPTab, "Name", State.ESP.Name, function(v) State.ESP.Name = v end)
    makeToggle(ESPTab, "Distance", State.ESP.Distance, function(v) State.ESP.Distance = v end)
    makeToggle(ESPTab, "Health Bar", State.ESP.Health, function(v) State.ESP.Health = v end)
    makeToggle(ESPTab, "Team Check", State.ESP.TeamCheck, function(v) State.ESP.TeamCheck = v end)
    makeSlider(ESPTab, "Max Distance", 100, 5000, State.ESP.MaxDist, function(v) State.ESP.MaxDist = v end)
    makeLabel(ESPTab, "— ESP Colors —", UDim2.new(1,0,0,20), UDim2.new(0,4,0,0), C(State.Colors.Accent), true)
    makeColorPicker(ESPTab, "Box Color", State.ESPColors.Box, function(rgb) State.ESPColors.Box = rgb end)
    makeColorPicker(ESPTab, "Skeleton Color", State.ESPColors.Skeleton, function(rgb) State.ESPColors.Skeleton = rgb end)
    makeColorPicker(ESPTab, "Tracer Color", State.ESPColors.Tracer, function(rgb) State.ESPColors.Tracer = rgb end)
    makeColorPicker(ESPTab, "Name Color", State.ESPColors.Name, function(rgb) State.ESPColors.Name = rgb end)

    -- MOVES
    local MovementTab = createTab("Moves")
    makeToggle(MovementTab, "Fly", State.Movement.Fly, function(v) State.Movement.Fly = v; toggleFly(v) end)
    makeSlider(MovementTab, "Fly Speed", 10, 300, State.Movement.FlySpeed, function(v) State.Movement.FlySpeed = v end)
    makeToggle(MovementTab, "Speed Hack", State.Movement.Speed, function(v) State.Movement.Speed = v end)
    makeSlider(MovementTab, "WalkSpeed", 16, 200, State.Movement.WalkSpeed, function(v) State.Movement.WalkSpeed = v end)
    makeToggle(MovementTab, "Noclip", State.Movement.Noclip, function(v) State.Movement.Noclip = v end)

    -- VISUALS
    local VisualsTab = createTab("Visuals")
    makeLabel(VisualsTab, "Graphics optimization", UDim2.new(1,0,0,20), UDim2.new(0,4,0,0), C(State.Colors.TextDim))
    makeButton(VisualsTab, "Remove Game Quality (FPS Boost)", function()
        Lighting.GlobalShadows = false; Lighting.FogEnd = 1000000; Lighting.Brightness = 1; Lighting.EnvironmentDiffuseScale = 0; Lighting.EnvironmentSpecularScale = 0
        for _, effect in ipairs(Lighting:GetChildren()) do if effect:IsA("PostEffect") or effect:IsA("Atmosphere") or effect:IsA("Clouds") then effect:Destroy() end end
        pcall(function() settings().Rendering.QualityLevel = 1 end)
        pcall(function() UserGameSettings.SavedQualityLevel = Enum.SavedQualitySetting.QualityLevel1 end)
        local toast = Instance.new("TextLabel"); toast.Size = UDim2.new(0, 250, 0, 40); toast.Position = UDim2.new(0.5, -125, 0, 100)
        toast.BackgroundColor3 = C(State.Colors.Accent); toast.Text = "Minimum quality applied!"; toast.TextColor3 = Color3.fromRGB(255, 255, 255)
        toast.Font = Enum.Font.GothamBold; toast.TextSize = 14; toast.ZIndex = 100; toast.Parent = Main; makeCorner(toast, 8)
        task.delay(2, function() toast:Destroy() end)
    end, C(State.Colors.Danger))
    makeButton(VisualsTab, "Restore Game Quality", function()
        Lighting.GlobalShadows = true; Lighting.FogEnd = 100000; Lighting.Brightness = 2; Lighting.EnvironmentDiffuseScale = 0.5; Lighting.EnvironmentSpecularScale = 0.5
        pcall(function() settings().Rendering.QualityLevel = 10 end)
        pcall(function() UserGameSettings.SavedQualityLevel = Enum.SavedQualitySetting.Automatic end)
    end, C(State.Colors.ToggleOn))

    -- SKIN
    local SkinTab = createTab("Skin")
    makeLabel(SkinTab, "Mesh ID (rbxassetid://...)", UDim2.new(1,0,0,20), UDim2.new(0,4,0,0), C(State.Colors.TextDim))
    makeTextbox(SkinTab, "rbxassetid://...", function(t) State.Skin.MeshId = t; saveConfig() end)
    makeLabel(SkinTab, "Texture ID (rbxassetid://...)", UDim2.new(1,0,0,20), UDim2.new(0,4,0,0), C(State.Colors.TextDim))
    makeTextbox(SkinTab, "rbxassetid://...", function(t) State.Skin.TextureId = t; saveConfig() end)
    makeButton(SkinTab, "Apply Skin to Equipped Tool", function() applySkin() end)
    makeButton(SkinTab, "Reset Skin", function() State.Skin.MeshId = ""; State.Skin.TextureId = ""; applySkin() end)

    -- WARP
    local WarpTab = createTab("Warp")
    makeButton(WarpTab, "Scan Waypoints", function()
        local pts = scanWaypoints()
        for _, child in ipairs(WarpTab:GetChildren()) do if child:IsA("TextButton") and child:GetAttribute("waypointBtn") then child:Destroy() end end
        for i, part in ipairs(pts) do
            local btn = makeButton(WarpTab, part.Name .. "  (" .. tostring(i) .. ")", function() teleportTo(part.CFrame + Vector3.new(0, 3, 0)) end)
            btn:SetAttribute("waypointBtn", true)
        end
    end)
    makeButton(WarpTab, "Save Current Position", function()
        local char = LocalPlayer.Character
        if char and char:FindFirstChild("HumanoidRootPart") then
            local cf = char.HumanoidRootPart.CFrame
            table.insert(State.Warp.CustomPoints, {X=cf.Position.X, Y=cf.Position.Y, Z=cf.Position.Z}); saveConfig()
        end
    end)
    makeButton(WarpTab, "Teleport to Saved Points", function()
        for i, p in ipairs(State.Warp.CustomPoints) do
            local btn = makeButton(WarpTab, "Saved Point #" .. i, function() teleportTo(CFrame.new(p.X, p.Y, p.Z)) end)
            btn:SetAttribute("waypointBtn", true)
        end
    end)

    -- JOIN US
    local JoinTab = createTab("Join Us")
    local discordLogo = Instance.new("TextLabel"); discordLogo.Size = UDim2.new(1, -10, 0, 60); discordLogo.BackgroundTransparency = 1
    discordLogo.Text = "💬"; discordLogo.TextColor3 = C(State.Colors.Discord); discordLogo.TextSize = 50
    discordLogo.Font = Enum.Font.GothamBold; discordLogo.ZIndex = 3; discordLogo.Parent = JoinTab
    makeLabel(JoinTab, "Join the community!", UDim2.new(1,-10,0,25), UDim2.new(0, 4, 0, 0), C(State.Colors.Text), true).TextXAlignment = Enum.TextXAlignment.Center
    makeLabel(JoinTab, "Support, updates, and exclusive scripts.", UDim2.new(1,-10,0,20), UDim2.new(0, 4, 0, 0), C(State.Colors.TextDim)).TextXAlignment = Enum.TextXAlignment.Center
    makeButton(JoinTab, "Join our Discord", function()
        pcall(function() setclipboard(DISCORD_LINK) end)
        pcall(function() request({Url = DISCORD_LINK, Method = "GET"}) end)
        pcall(function() os.execute("start " .. DISCORD_LINK) end)
        local toast = Instance.new("TextLabel"); toast.Size = UDim2.new(0, 250, 0, 40); toast.Position = UDim2.new(0.5, -125, 0, 100)
        toast.BackgroundColor3 = C(State.Colors.Discord); toast.Text = "Link copied and opened!"; toast.TextColor3 = Color3.fromRGB(255, 255, 255)
        toast.Font = Enum.Font.GothamBold; toast.TextSize = 14; toast.ZIndex = 100; toast.Parent = Main; makeCorner(toast, 8)
        TweenService:Create(toast, TweenInfo.new(0.3), {Position = UDim2.new(0.5, -125, 0, 120)}):Play()
        task.delay(2, function()
            TweenService:Create(toast, TweenInfo.new(0.3), {Position = UDim2.new(0.5, -125, 0, 100), BackgroundTransparency = 1, TextTransparency = 1}):Play()
            task.wait(0.35); toast:Destroy()
        end)
    end, C(State.Colors.Discord))

    -- THEME
    local ThemeTab = createTab("Theme")
    makeLabel(ThemeTab, "Menu Toggle Key", UDim2.new(1,0,0,20), UDim2.new(0,4,0,0), C(State.Colors.TextDim))
    makeKeybind(ThemeTab, "", State.ToggleKey, function(k) State.ToggleKey = k end)
    makeLabel(ThemeTab, "— UI Colors —", UDim2.new(1,0,0,20), UDim2.new(0,4,0,0), C(State.Colors.Accent), true)
    local function refreshTheme()
        Main.BackgroundColor3 = C(State.Colors.Background); TitleBar.BackgroundColor3 = C(State.Colors.Panel)
        TitleText.TextColor3 = C(State.Colors.Text); MainStroke.Color = C(State.Colors.Border)
        BgLogo.ImageColor3 = C(State.Colors.Accent)
    end
    makeColorPicker(ThemeTab, "Background", State.Colors.Background, function(rgb) State.Colors.Background = rgb; refreshTheme() end)
    makeColorPicker(ThemeTab, "Panel", State.Colors.Panel, function(rgb) State.Colors.Panel = rgb; refreshTheme() end)
    makeColorPicker(ThemeTab, "Accent", State.Colors.Accent, function(rgb) State.Colors.Accent = rgb; refreshTheme() end)
    makeColorPicker(ThemeTab, "Text", State.Colors.Text, function(rgb) State.Colors.Text = rgb; refreshTheme() end)
    makeColorPicker(ThemeTab, "Border", State.Colors.Border, function(rgb) State.Colors.Border = rgb; refreshTheme() end)

    -- Activate first tab
    for _, t in pairs(tabs) do t.page.Visible = false; t.button.BackgroundColor3 = C(State.Colors.Background); t.button.TextColor3 = C(State.Colors.TextDim) end
    tabs["Combat"].page.Visible = true; tabs["Combat"].button.BackgroundColor3 = C(State.Colors.Accent); tabs["Combat"].button.TextColor3 = C(State.Colors.Text)

    UserInputService.InputBegan:Connect(function(input, gp)
        if gp then return end
        if input.KeyCode == State.ToggleKey then Main.Visible = not Main.Visible end
    end)

    return Main
end

-- ============================================================
-- LOADING SEQUENCE
-- ============================================================
local steps = {
    { "Initializing core...",      0.15 },
    { "Loading modules...",       0.35 },
    { "Injecting security hooks...", 0.55 },
    { "Preparing ESP engine...",    0.75 },
    { "Calibrating Aimbot...",      0.90 },
    { "Ready.",                           1.00 },
}

local function tweenProgress(target)
    TweenService:Create(BarFill, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), { Size = UDim2.new(target, 0, 1, 0) }):Play()
    TweenService:Create(PercentLabel, TweenInfo.new(0.4), { Text = tostring(math.floor(target * 100)) .. "%" }):Play()
end

task.spawn(function()
    task.wait(0.5)
    for _, step in ipairs(steps) do
        LoadStatus.Text = step[1]; tweenProgress(step[2]); task.wait(0.35)
    end
    task.wait(0.6)
    local exitTween = TweenInfo.new(0.6, Enum.EasingStyle.Exponential, Enum.EasingDirection.In)
    TweenService:Create(LoadCard, exitTween, { BackgroundTransparency = 1, Size = UDim2.new(0, 450, 0, 430), Position = UDim2.new(0.5, -225, 0.5, -215) }):Play()
    for _, v in ipairs(LoadCard:GetDescendants()) do
        if v:IsA("TextLabel") then TweenService:Create(v, exitTween, { TextTransparency = 1 }):Play() 
        elseif v:IsA("ImageLabel") then TweenService:Create(v, exitTween, { ImageTransparency = 1 }):Play() 
        elseif v:IsA("Frame") then TweenService:Create(v, exitTween, { BackgroundTransparency = 1 }):Play() 
        elseif v:IsA("UIStroke") then TweenService:Create(v, exitTween, { Transparency = 1 }):Play() end
    end
    TweenService:Create(LoadBg, exitTween, { BackgroundTransparency = 1 }):Play()
    task.wait(0.65)
    LoadGui:Destroy()

    local main = buildMainGUI()
    main.Visible = true
    main.Size = UDim2.new(0, 400, 0, 500); main.Position = UDim2.new(0.5, -200, 0.5, -250)
    TweenService:Create(main, TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
        Size = UDim2.new(0, 520, 0, 600), Position = UDim2.new(0.5, -260, 0.5, -300)
    }):Play()
end)

startAimbot()
