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

local function v9(v10, ...)
    table.insert(v10, ...)
end

local function v11(v12, ...)
    table.insert(v12, ...)
end

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Debris = game:GetService("Debris")
local LocalPlayer = Players.LocalPlayer
local ChickenOrHero = game.ReplicatedStorage:WaitForChild("ChickenOrHero")
local v13 = require(ChickenOrHero.Weapons:WaitForChild("CloneAbilityConfig"))
local CloneAbilityEvent = ChickenOrHero.Weapons:WaitForChild("CloneAbilityEvent")
local v14 = require(ChickenOrHero.Weapons:WaitForChild("CloneSplitEffects"))
local v15 = require(game:GetService("ReplicatedStorage"):WaitForChild("ChickenOrHero"):WaitForChild("OldUIReskin"):WaitForChild("Skin"))
local Panels = v15.Panels
local Theme = v15.Theme
local ControlGate = require(ChickenOrHero.Movement.ControlGate)
local v16 = require(ChickenOrHero.Presentation:WaitForChild("EquipmentHudLayoutLegacy"))
local HudNavigation = require(ChickenOrHero.Presentation.HudNavigation)
local Session = ChickenOrHero.Game.Session
local v17 = Panels.screen(LocalPlayer, "KnifeAbilityHUD", 35)
local v18 = Panels.button(v17, "Clone", "", 0, 0, 156, 80)
Theme.button(v18, Theme.Blue)
local v19 = v15.HudAccents.clone[1]
local v20 = v15.HudAccents.clone[2]
local v21 = ColorSequence.new({
    ColorSequenceKeypoint.new(0, Theme.Ink),
    ColorSequenceKeypoint.new(0.55, Theme.Ink),
    ColorSequenceKeypoint.new(1, v20)
})

v18.BackgroundColor3 = Color3.new(1, 1, 1)
v18.Border.Color = v19
v18.Corner.CornerRadius = UDim.new(0, 12)
v18.AnchorPoint = Vector2.new(1, 0.5)
v18.Position = UDim2.new(1, -24, 0.43, 0)
v18.Visible = false

local v22 = Panels.text(v18, "Label", "CLONE", 49, 13, 100, 22, 15, Theme.Paper)

v22.TextXAlignment = Enum.TextXAlignment.Center

local v23 = Panels.text(v18, "Hint", "R  /  2 COPIES", 49, 39, 100, 18, 10, v19)

v23.TextXAlignment = Enum.TextXAlignment.Center
v22.Font = Enum.Font.GothamBold
v23.Font = Enum.Font.GothamBold

local v24 = Panels.make("UIGradient", v18, "Shimmer", {
    Rotation = 25,
    Color = v21
})
for v25 = 1, 3 do
    local v26 = (v25 - 1) * 9 + 9
    local make = Panels.make
    local v27 = "CloneHead" .. v25
    local v28 = { BorderSizePixel = 0 }
    local fromOffset = UDim2.fromOffset
    local v29 = if v25 == 2 then 4 else 0
    v28.Position = fromOffset(v26, 22 - v29)
    v28.Size = UDim2.fromOffset(10, 10)
    v28.BackgroundColor3 = v19
    if v25 == 2 then
        v28.BackgroundTransparency = 0
    else
        v28.BackgroundTransparency = 0.4
    end
    local v30 = make("Frame", v18, v27, v28)
    Panels.corner(v30, 5)
    local make_2 = Panels.make
    local v31 = "CloneBody" .. v25
    local v32 = { BorderSizePixel = 0 }
    local fromOffset_2 = UDim2.fromOffset
    local v33 = v26 - 2
    local v34 = if v25 == 2 then 4 else 0
    v32.Position = fromOffset_2(v33, 33 - v34)
    v32.Size = UDim2.fromOffset(14, 20)
    v32.BackgroundColor3 = v19
    if v25 == 2 then
        v32.BackgroundTransparency = 0
    else
        v32.BackgroundTransparency = 0.4
    end
    local v35 = make_2("Frame", v18, v31, v32)
    Panels.corner(v35, 4)
end
local v36 = Panels.make("Frame", v18, "Track", {
    BorderSizePixel = 0,
    Position = UDim2.fromOffset(12, 69),
    Size = UDim2.fromOffset(132, 4),
    BackgroundColor3 = v15.Palette.track
})
Panels.corner(v36, 4)
local v37 = Panels.make("Frame", v36, "Fill", {
    BorderSizePixel = 0,
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = v19
})
Panels.corner(v37, 4)
local UIScale = Instance.new("UIScale")

UIScale.Parent = v18

local function pop() -- line 80 | captures: TweenService, v18
    TweenService:Create(v18, TweenInfo.new(0.09), { Rotation = 3 }):Play()
    task.delay(0.09, function() -- line 82 | captures: TweenService, v18
        if v18.Parent then
            TweenService:Create(v18, TweenInfo.new(0.25, Enum.EasingStyle.Back), { Rotation = 0 }):Play()
        end
    end)
end

local v38 = (-1/0)
local v39 = {}

local function on(v40, v41) -- line 90 | captures: v39
    local function v42(v43, ...)
        table.insert(v43, ...)
    end

    v42(v39, v40:Connect(v41))
end

local function available() -- line 93 | captures: LocalPlayer, v13, Session
    local Enabled = v13.Enabled
    local v44, v45
    if Enabled then
        if LocalPlayer:GetAttribute("ClientReady") == true and LocalPlayer:GetAttribute("EquippedKnife") == v13.Skin and LocalPlayer:GetAttribute("InMatch") == true and LocalPlayer:GetAttribute("RunState") == "Active" and (LocalPlayer:GetAttribute("GameRole") == "Runner" or LocalPlayer:GetAttribute("GameRole") == "Catcher") then
            v45 = false
        else
            v44 = false
            v45 = true
        end
    else
        v44 = Enabled
        v45 = true
    end
    if not v45 then
        v44 = not Session:GetAttribute("GlobalPaused") and not Session:GetAttribute("MapChanging")
    end
    return v44
end

local function request() -- line 103 | captures: v38, LocalPlayer, CloneAbilityEvent, v14, ControlGate, pop, available
    if not available() or ControlGate.reason(LocalPlayer) or os.clock() - v38 < 0.5 then
        return
    end
    local v46 = LocalPlayer:GetAttribute("CloneAbilityReadyAt") or 0
    if workspace:GetServerTimeNow() < v46 then
        return
    end
    v38 = os.clock()
    pop()
    CloneAbilityEvent:FireServer("Activate")
    local v47 = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
    if v47 then
        v14.play(v47.Position)
    end
end

v1(v39, v18.Activated:Connect(request))
local MouseEnter = v18.MouseEnter
v3(v39, MouseEnter:Connect(function() -- line 119 | captures: TweenService, v24
    TweenService:Create(v24, TweenInfo.new(0.2), { Rotation = 70 }):Play()
end))
local MouseLeave = v18.MouseLeave
v5(v39, MouseLeave:Connect(function() -- line 122 | captures: TweenService, v24
    TweenService:Create(v24, TweenInfo.new(0.2), { Rotation = 25 }):Play()
end))
local InputBegan = UserInputService.InputBegan
v7(v39, InputBegan:Connect(function(v48, v49) -- line 125 | captures: request
    if not (v49 or v48.KeyCode ~= Enum.KeyCode.R and v48.KeyCode ~= Enum.KeyCode.ButtonL1) then
        request()
    end
end))

local function pulse(v50) -- line 130 | captures: TweenService, Debris, Theme
    if typeof(v50) == "Vector3" then
        local CurrentCamera = workspace.CurrentCamera
        if CurrentCamera and not ((CurrentCamera.CFrame.Position - v50).Magnitude > 110) then
            local Part = Instance.new("Part")
            Part.Name = "ClonePulse"
            Part.Shape = Enum.PartType.Ball
            Part.Size = Vector3.new(2, 4, 2)
            Part.CFrame = CFrame.new(v50)
            Part.Material = Enum.Material.Neon
            Part.Color = Theme.Blue
            Part.Transparency = 0.65
            Part.Anchored = true
            Part.CanCollide = false
            Part.CanTouch = false
            Part.CanQuery = false
            Part.CastShadow = false
            Part.Parent = workspace
            TweenService:Create(Part, TweenInfo.new(0.4, Enum.EasingStyle.Quad), {
                Size = Vector3.new(6, 6, 6),
                Transparency = 1
            }):Play()
            Debris:AddItem(Part, 0.45)
        end
    end
end

local OnClientEvent = CloneAbilityEvent.OnClientEvent
v9(v39, OnClientEvent:Connect(function(v51, v52) -- line 156 | captures: v38, LocalPlayer, v14, HudNavigation, pulse
    if not (v51 == "Notice" and type(v52) == "string") then
        if not (v51 == "Split" and type(v52) == "table") then
            if v51 == "Dissolve" and type(v52) == "table" then
                pulse(v52.position)
            end
        elseif v52.ownerId ~= LocalPlayer.UserId or os.clock() - v38 > 1 then
            v14.play(v52.position)
        end
    else
        HudNavigation.Notice:Fire(v52)
    end
end))
local v53 = 0
local v54 = false
local RenderStepped = RunService.RenderStepped
v11(v39, RenderStepped:Connect(function(v55) -- line 170 | captures: v53, v54, UserInputService, LocalPlayer, v13, Theme, ControlGate, v16, v17, v18, v19, v22, v23, v37, UIScale, pop, available
    v53 += v55
    if v53 < 0.1 then
        return
    end
    v53 = 0
    v18.Visible = available() and not ControlGate.reason(LocalPlayer)
    local AbsoluteSize = v17.AbsoluteSize
    local v56 = AbsoluteSize.X / 1000
    local v57 = AbsoluteSize.Y / 650
    local v58 = math.min(v56, v57)
    UIScale.Scale = math.clamp(v58, 0.58, 1)
    local v59 = UserInputService.TouchEnabled and v16.touchStack
    if v59 then
        UIScale.Scale = v59.factor
        v18.AnchorPoint = Vector2.new(1, 1)
        local AbsolutePosition = v17.AbsolutePosition
        v18.Position = UDim2.fromOffset(v59.right - AbsolutePosition.X, v59.top - v59.gap - AbsolutePosition.Y)
    else
        v18.AnchorPoint = Vector2.new(1, 0.5)
        v18.Position = UDim2.new(1, -24, 0.5, -140 * UIScale.Scale)
    end
    if not v18.Visible then
        return
    end
    local v60 = workspace:GetServerTimeNow()
    local v61 = (LocalPlayer:GetAttribute("CloneAbilityReadyAt") or 0) - v60
    local v62 = math.ceil(v61)
    local v63 = math.max(0, v62)
    local v64 = v60 < (LocalPlayer:GetAttribute("CloneAbilityActiveUntil") or 0)
    local v65
    if v64 then
        v65 = "CLONES OUT"
    elseif v63 > 0 then
        local format = string.format
        local v66 = v63 / 60
        v65 = format("%d:%02d", math.floor(v66), v63 % 60) or "CLONE"
    else
        v65 = "CLONE"
    end
    v22.Text = v65
    local v67
    if v64 then
        v67 = "TWO OF A KIND"
    elseif v63 > 0 then
        v67 = "RECHARGING"
    elseif UserInputService.TouchEnabled then
        v67 = "TAP TO SPLIT"
    elseif UserInputService.GamepadEnabled then
        v67 = "L1  /  2 COPIES"
    else
        v67 = "R  /  2 COPIES"
    end
    v23.Text = v67
    local v68 = if v63 > 0 then 0.5 else 0.15
    v18.BackgroundTransparency = v68
    local fromScale = UDim2.fromScale
    local v69 = 1 - v63 / (v13.Cooldown or 45)
    v37.Size = fromScale(math.clamp(v69, 0, 1), 1)
    local Paper = v64 and Theme.Paper or v19
    v37.BackgroundColor3 = Paper
    local v70 = v63 == 0
    if v70 and not v54 then
        pop()
    end
    v54 = v70
end))
script.Destroying:Connect(function() -- line 213 | captures: v17, v39
    for v71, v72 in v39 do
        v72:Disconnect()
    end
    v17:Destroy()
end)
