-- https://sitetest1.lua.expert

local function v1(v2, ...)
    table.insert(v2, ...)
end

local function v3(v4, ...)
    table.insert(v4, ...)
end

local function v5(v6, ...)
    table.insert(v6, ...)
end

local function v7(v8, ...)
    table.insert(v8, ...)
end

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local LocalPlayer = Players.LocalPlayer
local ChickenOrHero = game.ReplicatedStorage:WaitForChild("ChickenOrHero")
local GhostAbilityEvent = ChickenOrHero.Weapons:WaitForChild("GhostAbilityEvent")
local v9 = require(game:GetService("ReplicatedStorage"):WaitForChild("ChickenOrHero"):WaitForChild("OldUIReskin"):WaitForChild("Skin"))
local Panels = v9.Panels
local Theme = v9.Theme
local ControlGate = require(ChickenOrHero.Movement.ControlGate)
local v10 = require(ChickenOrHero.Presentation:WaitForChild("EquipmentHudLayoutLegacy"))
local Session = ChickenOrHero.Game.Session
local v11 = Panels.screen(LocalPlayer, "GhostAbilityHUD", 35)
local v12 = Panels.button(v11, "Ghost", "", 0, 0, 156, 80)
Theme.button(v12, Color3.fromRGB(74, 175, 166))
local v13 = v9.HudAccents.ghost[1]
local v14 = v9.HudAccents.ghost[2]
local v15 = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Theme.Ink),
    ColorSequenceKeypoint.new(0.55, Theme.Ink),
    ColorSequenceKeypoint.new(1, v14)
})

v12.BackgroundColor3 = Color3.new(1, 1, 1)
v12.Border.Color = v13
v12.Corner.CornerRadius = UDim.new(0, 12)

local v16 = v12:FindFirstChild("SkinGradient") or Instance.new("UIGradient")

v16.Name = "SkinGradient"
v16.Rotation = 90
v16.Color = v15
v16.Parent = v12
v12.AnchorPoint = Vector2.new(1, 0.5)
v12.Visible = false

local v17 = Panels.text(v12, "Label", "GHOST", 12, 13, 132, 27, 18, Theme.Paper)

v17.TextXAlignment = Enum.TextXAlignment.Center
v17.Font = Enum.Font.GothamBold

local v18 = Panels.text(v12, "Hint", "R / FADE", 12, 45, 132, 19, 11, v13)

v18.TextXAlignment = Enum.TextXAlignment.Center

local v19 = Panels.make("Frame", v12, "Track", {
    BorderSizePixel = 0,
    Position = UDim2.fromOffset(12, 69),
    Size = UDim2.fromOffset(132, 4),
    BackgroundColor3 = v9.Palette.track
})
Panels.corner(v19, 4)
local v20 = Panels.make("Frame", v19, "Fill", {
    BorderSizePixel = 0,
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = v13
})
Panels.corner(v20, 4)
local UIScale = Instance.new("UIScale")

UIScale.Parent = v12

local v21 = {}

local function on(v22, v23) -- line 59 | captures: v21
    local function v24(v25, ...)
        table.insert(v25, ...)
    end

    v24(v21, v22:Connect(v23))
end

local function available() -- line 62 | captures: LocalPlayer, Session
    if LocalPlayer:GetAttribute("ClientReady") == true and LocalPlayer:GetAttribute("EquippedKnife") == "GhostScythe" and LocalPlayer:GetAttribute("InMatch") == true and LocalPlayer:GetAttribute("RunState") == "Active" and (LocalPlayer:GetAttribute("GameRole") == "Runner" or LocalPlayer:GetAttribute("GameRole") == "Catcher") then
        return not Session:GetAttribute("GlobalPaused") and not Session:GetAttribute("MapChanging")
    end
    return false
end

local v26 = (-1/0)

local function request() -- line 72 | captures: v26, LocalPlayer, GhostAbilityEvent, ControlGate, available
    if not available() or ControlGate.reason(LocalPlayer) or os.clock() - v26 < 0.5 then
        return
    end
    local v27 = LocalPlayer:GetAttribute("GhostAbilityReadyAt") or 0
    if not (workspace:GetServerTimeNow() < v27) then
        v26 = os.clock()
        GhostAbilityEvent:FireServer("Activate")
    end
end

v1(v21, v12.Activated:Connect(request))
local InputBegan = UserInputService.InputBegan
v3(v21, InputBegan:Connect(function(v28, v29) -- line 83 | captures: request
    if not (v29 or v28.KeyCode ~= Enum.KeyCode.R and v28.KeyCode ~= Enum.KeyCode.ButtonL1) then
        request()
    end
end))

local function cue(v30) -- line 88 | captures: TweenService, Debris
    local Character = v30.Character
    local v31 = Character and Character:FindFirstChild("HumanoidRootPart")
    if not v31 then
        return
    end
    local Sound = Instance.new("Sound")
    Sound.SoundId = "rbxassetid://8408521761"
    Sound.Volume = 0.35
    Sound.RollOffMaxDistance = 100
    Sound.Parent = v31
    Sound:Play()
    Debris:AddItem(Sound, 3)
    local Part = Instance.new("Part")
    Part.Name = "GhostScythePulse"
    Part.Shape = Enum.PartType.Ball
    Part.Material = Enum.Material.Neon
    Part.Color = Color3.fromRGB(155, 255, 230)
    Part.Transparency = 0.55
    Part.Size = Vector3.new(2, 3, 2)
    Part.CFrame = CFrame.new(v31.Position)
    Part.Anchored = true
    Part.CanCollide = false
    Part.CanTouch = false
    Part.CanQuery = false
    Part.Parent = workspace
    TweenService:Create(Part, TweenInfo.new(0.45, Enum.EasingStyle.Quad), {
        Size = Vector3.new(9, 9, 9),
        Transparency = 1
    }):Play()
    Debris:AddItem(Part, 0.5)
end

local OnClientEvent = GhostAbilityEvent.OnClientEvent
v5(v21, OnClientEvent:Connect(function(v32, v33) -- line 120 | captures: Players, cue
    if v32 == "Activated" and type(v33) == "number" then
        local v34 = Players:GetPlayerByUserId(v33)
        if v34 then
            cue(v34)
        end
    end
end))
local v35 = 0
local RenderStepped = RunService.RenderStepped
v7(v21, RenderStepped:Connect(function(v36) -- line 129 | captures: v35, UserInputService, LocalPlayer, ControlGate, v10, v11, v12, v17, v18, v20, UIScale, available
    v35 += v36
    if v35 < 0.1 then
        return
    end
    v35 = 0
    v12.Visible = available() and not ControlGate.reason(LocalPlayer)
    local AbsoluteSize = v11.AbsoluteSize
    local v37 = AbsoluteSize.X / 1000
    local v38 = AbsoluteSize.Y / 650
    local v39 = math.min(v37, v38)
    UIScale.Scale = math.clamp(v39, 0.58, 1)
    local v40 = UserInputService.TouchEnabled and v10.touchStack
    if v40 then
        UIScale.Scale = v40.factor
        v12.AnchorPoint = Vector2.new(1, 1)
        local AbsolutePosition = v11.AbsolutePosition
        v12.Position = UDim2.fromOffset(v40.right - AbsolutePosition.X, v40.top - v40.gap - AbsolutePosition.Y)
    else
        v12.AnchorPoint = Vector2.new(1, 0.5)
        v12.Position = UDim2.new(1, -24, 0.5, -140 * UIScale.Scale)
    end
    if not v12.Visible then
        return
    end
    local v41 = workspace:GetServerTimeNow()
    local v42 = (LocalPlayer:GetAttribute("GhostAbilityReadyAt") or 0) - v41
    local v43 = math.ceil(v42)
    local v44 = math.max(0, v43)
    local v45 = v41 < (LocalPlayer:GetAttribute("GhostImmuneUntil") or 0)
    local v46
    if v45 then
        v46 = "GHOSTED"
    elseif v44 > 0 then
        local format = string.format
        local v47 = v44 / 60
        v46 = format("%d:%02d", math.floor(v47), v44 % 60) or "GHOST"
    else
        v46 = "GHOST"
    end
    v17.Text = v46
    local v48
    if v45 then
        v48 = "IMMUNE \194\183 2 SECONDS"
    elseif v44 > 0 then
        v48 = "RECHARGING"
    elseif UserInputService.TouchEnabled then
        v48 = "TAP TO FADE"
    elseif UserInputService.GamepadEnabled then
        v48 = "L1 / FADE"
    else
        v48 = "R / FADE"
    end
    v18.Text = v48
    local v49 = if v44 > 0 then 0.5 else 0.15
    v12.BackgroundTransparency = v49
    local fromScale = UDim2.fromScale
    local v50 = 1 - v44 / 45
    v20.Size = fromScale(math.clamp(v50, 0, 1), 1)
end))
script.Destroying:Connect(function() -- line 166 | captures: v21
    for v51, v52 in v21 do
        v52:Disconnect()
    end
end)
