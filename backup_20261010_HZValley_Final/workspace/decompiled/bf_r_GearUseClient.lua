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

local function v13(v14, ...)
    table.insert(v14, ...)
end

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local ChickenOrHero = game.ReplicatedStorage:WaitForChild("ChickenOrHero")
local v15 = require(game:GetService("ReplicatedStorage"):WaitForChild("ChickenOrHero"):WaitForChild("OldUIReskin"):WaitForChild("Skin"))
local Panels = v15.Panels
local v16 = require(ChickenOrHero.Presentation:WaitForChild("EquipmentHudLayoutLegacy"))
local ControlGate = require(ChickenOrHero.Movement.ControlGate)
local GearCatalog = require(ChickenOrHero.Gear.GearCatalog)
local GearEvent = ChickenOrHero.Gear:WaitForChild("GearEvent")
local v17 = require(ChickenOrHero.Gear:WaitForChild("GearPredictionClient"))
local v18 = Panels.screen(LocalPlayer, "GearControls", 63)
local v19 = Panels.button(v18, "Use", "", 0, 0, 226, 88, Panels.Ink)

v19.AnchorPoint = Vector2.new(1, 0.5)
v19.Position = UDim2.new(1, -24, 0.58, 0)
v19.AutoButtonColor = false
Panels.stroke(v19, Panels.Gold, 0.25)
local Outline = v19:FindFirstChild("Outline")
local surface = v15.Palette.surface

local function cardColors(v20) -- line 26 | captures: surface
    return ColorSequence.new({
        ColorSequenceKeypoint.new(0, surface),
        ColorSequenceKeypoint.new(0.55, surface),
        ColorSequenceKeypoint.new(1, v20:Lerp(Color3.new(0, 0, 0), 0.4))
    })
end

v19.BackgroundColor3 = Color3.new(1, 1, 1)
v19.BackgroundTransparency = 0.12
v19.Corner.CornerRadius = UDim.new(0, 12)

local SkinStroke = v19:FindFirstChild("SkinStroke")

if SkinStroke then
    SkinStroke.Enabled = false
end
local v21 = Panels.make("UIScale", v19, "Scale", {})
v16.register(v19, v21, 3)
local v22 = Panels.make("UIGradient", v19, "Gradient", {
    Rotation = 25,
    Color = cardColors(Panels.Gold)
})
local v23 = Panels.make("ViewportFrame", v19, "Item", {
    BackgroundTransparency = 1,
    LightDirection = Vector3.new(-1, -2, -2),
    Position = UDim2.fromOffset(1, 2),
    Size = UDim2.fromOffset(80, 78),
    Ambient = Color3.fromRGB(210, 210, 210),
    LightColor = Color3.new(1, 1, 1)
})
local Camera = Instance.new("Camera")

Camera.Parent = v23
v23.CurrentCamera = Camera

local WorldModel = Instance.new("WorldModel")

WorldModel.Parent = v23

local v24 = Panels.text(v19, "Title", "", 80, 11, 138, 35, 15, Panels.Paper)

v24.Font = Enum.Font.GothamBold

local v25 = Panels.text(v19, "Hint", "", 81, 48, 137, 18, 11, Panels.Gold)

v25.Font = Enum.Font.GothamBold

local v26 = Panels.text(v19, "Charges", "", 8, 6, 48, 17, 11, Panels.Paper)

v26.Font = Enum.Font.GothamBold
v26.TextStrokeTransparency = 0.3

local v27 = Panels.make("Frame", v19, "Track", {
    BorderSizePixel = 0,
    Position = UDim2.fromOffset(12, 77),
    Size = UDim2.fromOffset(202, 4),
    BackgroundColor3 = v15.Palette.track
})
Panels.corner(v27, 4)
local v28 = Panels.make("Frame", v27, "Fill", {
    BorderSizePixel = 0,
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = Panels.Gold
})
Panels.corner(v28, 4)
local v29 = Panels.text(v18, "Notice", "", 0, 0, 380, 45, 14, Panels.Gold)

v29.AnchorPoint = Vector2.new(0.5, 0.5)
v29.Position = UDim2.fromScale(0.5, 0.76)
v29.TextXAlignment = Enum.TextXAlignment.Center
v29.TextStrokeTransparency = 0.4

local v30 = {}
local v31 = v30

v30.gear = {}

local v32 = 0
local v33 = 0
local equippedGear
local v34 = 0
local v35 = {}

local function on(v36, v37) -- line 86 | captures: v35
    local function v38(v39, ...)
        table.insert(v39, ...)
    end

    v38(v35, v36:Connect(v37))
end

local function active() -- line 89 | captures: v31, LocalPlayer, ChickenOrHero, ControlGate, GearCatalog
    local v40 = GearCatalog.get(v31.equippedGear)
    local v41, v42
    if v40 then
        if v40.Kind == "Ability" then
            v41 = false
            v42 = true
        elseif (v31.gear[v31.equippedGear] or 0) > 0 then
            local loaded = v31.loaded
            if loaded then
                if LocalPlayer:GetAttribute("InMatch") == true then
                    if v31.equippedGear == "RescueKit" and LocalPlayer:GetAttribute("RunState") == "Caught" and LocalPlayer.Character and LocalPlayer.Character:GetAttribute("RescueAvailable") == true then
                        v42 = false
                    elseif v31.equippedGear == "RescueKit" then
                        v41 = false
                        v42 = true
                    elseif LocalPlayer:GetAttribute("RunState") == "Active" then
                        v42 = false
                    else
                        v41 = false
                        v42 = true
                    end
                else
                    v41 = false
                    v42 = true
                end
            else
                v41 = loaded
                v42 = true
            end
        else
            v41 = false
            v42 = true
        end
    else
        v41 = v40
        v42 = true
    end
    if not v42 then
        local v43
        if v40.UseRole then
            if LocalPlayer:GetAttribute("GameRole") == v40.UseRole then
                if ControlGate.reason(LocalPlayer) then
                    if v31.equippedGear == "RescueKit" and ControlGate.reason(LocalPlayer) == "Spectating" then
                        v43 = false
                    else
                        v41 = false
                        v43 = true
                    end
                else
                    v43 = false
                end
            else
                v41 = false
                v43 = true
            end
        elseif ControlGate.reason(LocalPlayer) then
            if v31.equippedGear == "RescueKit" and ControlGate.reason(LocalPlayer) == "Spectating" then
                v43 = false
            else
                v41 = false
                v43 = true
            end
        else
            v43 = false
        end
        if not v43 then
            v41 = not ChickenOrHero.Game.Session:GetAttribute("GlobalPaused") and not ChickenOrHero.Game.Session:GetAttribute("MapChanging")
        end
    end
    return v41
end

local function pop() -- line 104 | captures: TweenService, v19
    TweenService:Create(v19, TweenInfo.new(0.08), { Rotation = -3 }):Play()
    task.delay(0.08, function() -- line 106 | captures: TweenService, v19
        if v19.Parent then
            TweenService:Create(v19, TweenInfo.new(0.22, Enum.EasingStyle.Back), { Rotation = 0 }):Play()
        end
    end)
end

local function request() -- line 112 | captures: v31, v32, LocalPlayer, v17, active, pop
    if not active() or os.clock() < v32 or workspace:GetServerTimeNow() < (LocalPlayer:GetAttribute("GearReadyAt") or 0) then
        return
    end
    v32 = os.clock() + 0.6
    pop()
    v17.request(v31.equippedGear, nil, "Use")
end

local function preview(v44) -- line 124 | captures: v31, ChickenOrHero, Camera, WorldModel
    WorldModel:ClearAllChildren()
    local v45 = ChickenOrHero.Gear.Assets:FindFirstChild(v44.Preview or v31.equippedGear)
    if not v45 then
        return
    end
    local Model = Instance.new("Model")
    local v46 = v45:Clone()
    for v47, v48 in v46:GetDescendants() do
        if v48:IsA("LuaSourceContainer") then
            v48:Destroy()
        elseif v48:IsA("BasePart") then
            v48.Anchored = true
            v48.CanCollide = false
        end
    end
    if v46:IsA("BasePart") then
        v46.Anchored = true
    end
    v46.Parent = Model
    Model.Parent = WorldModel
    local v49, v50 = Model:GetBoundingBox()
    local X = v50.X
    local Y = v50.Y
    local Z = v50.Z
    local v51 = math.max(X, Y, Z) * 1.8
    local lookAt = CFrame.lookAt
    local Position = v49.Position
    local v52 = v51 * 0.65
    local v53 = v51 * 0.35
    Camera.CFrame = lookAt(Position + Vector3.new(v52, v53, v51), v49.Position)
    Camera.FieldOfView = 40
end

v1(v35, v19.Activated:Connect(request))
local MouseEnter = v19.MouseEnter
v3(v35, MouseEnter:Connect(function() -- line 151 | captures: TweenService, v22
    TweenService:Create(v22, TweenInfo.new(0.2), { Rotation = 65 }):Play()
end))
local MouseLeave = v19.MouseLeave
v5(v35, MouseLeave:Connect(function() -- line 154 | captures: TweenService, v22
    TweenService:Create(v22, TweenInfo.new(0.2), { Rotation = 25 }):Play()
end))
local InputBegan = UserInputService.InputBegan
v7(v35, InputBegan:Connect(function(v54, v55) -- line 157 | captures: UserInputService, request
    if not (v55 or UserInputService:GetFocusedTextBox() or v54.KeyCode ~= Enum.KeyCode.C and v54.KeyCode ~= Enum.KeyCode.ButtonB) then
        request()
    end
end))
v9(v35, ChickenOrHero.Weapons.ArmoryEvent.OnClientEvent:Connect(function(v56, v57) -- line 166 | captures: v31
    if not (v56 == "State" and type(v57) == "table") then
        return
    end
    v31 = v57
    v31.gear = v31.gear or {}
end))
local OnClientEvent = GearEvent.OnClientEvent
v11(v35, OnClientEvent:Connect(function(v58, v59) -- line 172 | captures: v32, v33, v29
    if not (v58 == "Notice" and type(v59) == "string") then
        return
    end
    v29.Text = v59
    v33 = os.clock() + 4
    v32 = 0
end))
local v60 = false
local v61
local Heartbeat = RunService.Heartbeat
v13(v35, Heartbeat:Connect(function(v62) -- line 181 | captures: v31, v32, v33, equippedGear, v34, v60, v61, UserInputService, LocalPlayer, Panels, v16, ControlGate, GearCatalog, v19, Outline, cardColors, v22, v23, v24, v25, v26, v28, v29, active, pop, preview
    v34 += v62
    if v34 < 0.05 then
        return
    end
    v34 = 0
    local v63 = GearCatalog.get(v31.equippedGear)
    local v64 = LocalPlayer:GetAttribute("InMatch") ~= true
    local v65
    if v63 == nil or v63.Kind == "Ability" then
        v65 = false
    elseif v31.loaded == true and LocalPlayer:GetAttribute("ClientReady") == true then
        v65 = not ControlGate.reason(LocalPlayer)
        if not v65 then
            if v31.equippedGear == "RescueKit" then
                v65 = ControlGate.reason(LocalPlayer) == "Spectating"
            else
                v65 = false
            end
        end
    else
        v65 = false
    end
    v19.Visible = v65
    local v66 = (LocalPlayer:GetAttribute("GearReadyAt") or 0) - workspace:GetServerTimeNow()
    local v67 = math.max(0, v66)
    local v68 = active()
    if v68 then
        if v67 == 0 then
            local v69 = os.clock()
            v68 = v32 <= v69
        else
            v68 = false
        end
    end
    v19.Active = not not v68
    if v63 then
        if equippedGear ~= v31.equippedGear then
            equippedGear = v31.equippedGear
            preview(v63)
        end
        local v70
        if UserInputService.PreferredInput == Enum.PreferredInput.Gamepad then
            v70 = "B"
        elseif UserInputService.PreferredInput == Enum.PreferredInput.Touch then
            v70 = "TAP"
        else
            v70 = "C"
        end
        v24.Text = string.upper(v63.Name)
        local v71 = v31.gear[v31.equippedGear] or 0
        v26.Text = "\195\151" .. tostring(v71)
        local v72 = v63.UseRole and v63.UseRole ~= LocalPlayer:GetAttribute("GameRole")
        local v73
        if v64 then
            v73 = "EQUIPPED \194\183 ITEM"
        else
            local v74
            if v72 then
                local v75 = if v63.UseRole == "Catcher" then "CHASERS" else "RUNNERS"
                local v76 = v75 .. " ONLY"
                if v76 then
                    v73 = v76
                    v74 = true
                else
                    v74 = false
                end
            else
                v74 = false
            end
            if not v74 then
                local v77
                if v67 > 0 then
                    local v78 = string.format("READY IN %.1fs", v67)
                    if v78 then
                        v73 = v78
                        v77 = true
                    elseif v31.equippedGear == "RescueKit" and v68 then
                        local v79 = v70 .. "  \194\183  REVIVE YOURSELF"
                        if v79 then
                            v73 = v79
                            v77 = true
                        else
                            v77 = false
                        end
                    else
                        v77 = false
                    end
                elseif v31.equippedGear == "RescueKit" and v68 then
                    local v80 = v70 .. "  \194\183  REVIVE YOURSELF"
                    if v80 then
                        v73 = v80
                        v77 = true
                    else
                        v77 = false
                    end
                else
                    v77 = false
                end
                if not v77 then
                    if not (v31.equippedGear == "RescueKit" and LocalPlayer:GetAttribute("RunState") == "Active") then
                        local v81 = if v68 then v70 .. "  \194\183  LET\226\128\153S GO!" else nil
                        if not v68 or not v81 then
                            v73 = "NOT READY"
                        else
                            v73 = v81
                        end
                    else
                        v73 = "USE WHEN DOWNED"
                    end
                end
            end
        end
        v25.Text = v73
        local v82 = v63.Accent or Panels.Gold
        v25.TextColor3 = v82
        v28.BackgroundColor3 = v82
        Outline.Color = v82
        if v61 ~= v82 then
            v61 = v82
            v22.Color = cardColors(v82)
        end
        local fromScale = UDim2.fromScale
        local v83 = 1 - v67 / (v63.Cooldown or 12)
        v28.Size = fromScale(math.clamp(v83, 0, 1), 1)
    end
    if v68 and not v60 and v19.Visible then
        pop()
    end
    v60 = v68
    local v84
    if v68 then
        local v85 = os.clock() * 3
        v84 = math.sin(v85) * 0.12 + 0.25 or 0.65
    else
        v84 = 0.65
    end
    Outline.Transparency = v84
    local v86 = if v68 then 0 else 0.3
    v24.TextTransparency = v86
    local v87 = if v68 then 0 else 0.35
    v23.ImageTransparency = v87
    v29.Visible = os.clock() < v33
    v16.update(LocalPlayer.PlayerGui)
end))
script.Destroying:Connect(function() -- line 235 | captures: v18, v35
    for v88, v89 in v35 do
        v89:Disconnect()
    end
    v18:Destroy()
end)
ChickenOrHero.Weapons.ArmoryEvent:FireServer("Get")
