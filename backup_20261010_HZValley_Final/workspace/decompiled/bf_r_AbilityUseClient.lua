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

local function dashDirection() -- line 16 | captures: LocalPlayer
    local Character = LocalPlayer.Character
    local v18 = Character and Character:FindFirstChildOfClass("Humanoid")
    local MoveDirection = v18 and v18.MoveDirection or Vector3.new(0, 0, 0)
    if MoveDirection.Magnitude > 0.05 then
        return MoveDirection.Unit
    end
    local CurrentCamera = workspace.CurrentCamera
    local LookVector = CurrentCamera and CurrentCamera.CFrame.LookVector or Vector3.new(0, 0, 0)
    local X = LookVector.X
    local Z = LookVector.Z
    local v19 = Vector3.new(X, 0, Z)
    if v19.Magnitude > 0.01 then
        return v19.Unit
    end
    local v20 = Character and Character:FindFirstChild("HumanoidRootPart")
    return v20 and v20.CFrame.LookVector or Vector3.new(0, 0, 1)
end

local v21 = Panels.screen(LocalPlayer, "AbilityControls", 63)
local v22 = Panels.button(v21, "Use", "", 0, 0, 226, 88, Panels.Ink)

v22.AnchorPoint = Vector2.new(1, 0.5)
v22.Position = UDim2.new(1, -24, 0.58, 0)
v22.AutoButtonColor = false
Panels.stroke(v22, Panels.Gold, 0.25)
local Outline = v22:FindFirstChild("Outline")
local surface = v15.Palette.surface

local function cardColors(v23) -- line 43 | captures: surface
    return ColorSequence.new({
        ColorSequenceKeypoint.new(0, surface),
        ColorSequenceKeypoint.new(0.55, surface),
        ColorSequenceKeypoint.new(1, v23:Lerp(Color3.new(0, 0, 0), 0.4))
    })
end

v22.BackgroundColor3 = Color3.new(1, 1, 1)
v22.BackgroundTransparency = 0.12
v22.Corner.CornerRadius = UDim.new(0, 12)

local SkinStroke = v22:FindFirstChild("SkinStroke")

if SkinStroke then
    SkinStroke.Enabled = false
end
local v24 = Panels.make("UIScale", v22, "Scale", {})
v16.register(v22, v24, 1)
local v25 = Panels.make("UIGradient", v22, "Gradient", {
    Rotation = 25,
    Color = cardColors(Panels.Gold)
})
local v26 = Panels.make("ViewportFrame", v22, "Item", {
    BackgroundTransparency = 1,
    LightDirection = Vector3.new(-1, -2, -2),
    Position = UDim2.fromOffset(1, 2),
    Size = UDim2.fromOffset(80, 78),
    Ambient = Color3.fromRGB(210, 210, 210),
    LightColor = Color3.new(1, 1, 1)
})
local v27 = Panels.make("ImageLabel", v22, "AbilityIcon", {
    BackgroundTransparency = 1,
    Visible = false,
    Position = v26.Position,
    Size = v26.Size,
    ScaleType = Enum.ScaleType.Fit
})
local Camera = Instance.new("Camera")

Camera.Parent = v26
v26.CurrentCamera = Camera

local WorldModel = Instance.new("WorldModel")

WorldModel.Parent = v26

local v28 = Panels.text(v22, "Title", "", 80, 11, 138, 35, 15, Panels.Paper)

v28.Font = Enum.Font.GothamBold

local v29 = Panels.text(v22, "Hint", "", 81, 48, 137, 18, 11, Panels.Gold)

v29.Font = Enum.Font.GothamBold

local v30 = Panels.text(v22, "Charges", "", 8, 6, 48, 17, 11, Panels.Paper)

v30.Font = Enum.Font.GothamBold
v30.TextStrokeTransparency = 0.3

local v31 = Panels.make("Frame", v22, "Track", {
    BorderSizePixel = 0,
    Position = UDim2.fromOffset(12, 77),
    Size = UDim2.fromOffset(202, 4),
    BackgroundColor3 = v15.Palette.track
})
Panels.corner(v31, 4)
local v32 = Panels.make("Frame", v31, "Fill", {
    BorderSizePixel = 0,
    Size = UDim2.fromScale(1, 1),
    BackgroundColor3 = Panels.Gold
})
Panels.corner(v32, 4)
local v33 = Panels.text(v21, "Notice", "", 0, 0, 380, 45, 14, Panels.Gold)

v33.AnchorPoint = Vector2.new(0.5, 0.5)
v33.Position = UDim2.fromScale(0.5, 0.76)
v33.TextXAlignment = Enum.TextXAlignment.Center
v33.TextStrokeTransparency = 0.4

local v34 = {}
local v35 = v34

v34.abilities = {}

local v36 = 0
local v37 = 0
local v38
local v39 = 0
local v40 = {}

local function on(v41, v42) -- line 110 | captures: v40
    local function v43(v44, ...)
        table.insert(v44, ...)
    end

    v43(v40, v41:Connect(v42))
end

local function active() -- line 113 | captures: v35, LocalPlayer, ChickenOrHero, ControlGate, GearCatalog
    local v45 = GearCatalog.get(GearCatalog.equippedForRole(v35, LocalPlayer:GetAttribute("GameRole")))
    local v46, v47
    if v45 then
        if v45.Kind == "Ability" and v35.abilities[GearCatalog.equippedForRole(v35, LocalPlayer:GetAttribute("GameRole"))] == true then
            local loaded = v35.loaded
            if loaded then
                if LocalPlayer:GetAttribute("InMatch") == true and LocalPlayer:GetAttribute("RunState") == "Active" then
                    if v45.UseRole then
                        if LocalPlayer:GetAttribute("GameRole") == v45.UseRole then
                            v47 = false
                        else
                            v46 = false
                            v47 = true
                        end
                    else
                        v47 = false
                    end
                else
                    v46 = false
                    v47 = true
                end
            else
                v46 = loaded
                v47 = true
            end
        else
            v46 = false
            v47 = true
        end
    else
        v46 = v45
        v47 = true
    end
    if not v47 then
        v46 = not ControlGate.reason(LocalPlayer) and not ChickenOrHero.Game.Session:GetAttribute("GlobalPaused") and not ChickenOrHero.Game.Session:GetAttribute("MapChanging")
    end
    return v46
end

local function pop() -- line 126 | captures: TweenService, v22
    TweenService:Create(v22, TweenInfo.new(0.08), { Rotation = -3 }):Play()
    task.delay(0.08, function() -- line 128 | captures: TweenService, v22
        if v22.Parent then
            TweenService:Create(v22, TweenInfo.new(0.22, Enum.EasingStyle.Back), { Rotation = 0 }):Play()
        end
    end)
end

local function request() -- line 134 | captures: v35, v36, LocalPlayer, GearCatalog, v17, dashDirection, active, pop
    if not active() or os.clock() < v36 or workspace:GetServerTimeNow() < (LocalPlayer:GetAttribute("AbilityReadyAt") or 0) then
        return
    end
    v36 = os.clock() + 0.6
    pop()
    v17.request(GearCatalog.equippedForRole(v35, LocalPlayer:GetAttribute("GameRole")), dashDirection(), "UseAbility")
end

local function preview(v48) -- line 146 | captures: v35, LocalPlayer, ChickenOrHero, GearCatalog, v26, v27, Camera, WorldModel
    WorldModel:ClearAllChildren()
    v27.Visible = v48.IconImage ~= nil
    v26.Visible = not v27.Visible
    v27.Image = v48.IconImage or ""
    v27.ImageRectOffset = v48.IconRectOffset or Vector2.zero
    v27.ImageRectSize = v48.IconRectSize or Vector2.zero
    if not v27.Visible then
        local v49 = ChickenOrHero.Gear.Assets:FindFirstChild(v48.Preview or GearCatalog.equippedForRole(v35, LocalPlayer:GetAttribute("GameRole")))
        if v49 then
            local Model = Instance.new("Model")
            local v50 = v49:Clone()
            for v51, v52 in v50:GetDescendants() do
                if v52:IsA("LuaSourceContainer") then
                    v52:Destroy()
                elseif v52:IsA("BasePart") then
                    v52.Anchored = true
                    v52.CanCollide = false
                end
            end
            if v50:IsA("BasePart") then
                v50.Anchored = true
            end
            v50.Parent = Model
            Model.Parent = WorldModel
            local v53, v54 = Model:GetBoundingBox()
            local X = v54.X
            local Y = v54.Y
            local Z = v54.Z
            local v55 = math.max(X, Y, Z) * 1.8
            local lookAt = CFrame.lookAt
            local Position = v53.Position
            local v56 = v55 * 0.65
            local v57 = v55 * 0.35
            Camera.CFrame = lookAt(Position + Vector3.new(v56, v57, v55), v53.Position)
            Camera.FieldOfView = 40
        end
    end
end

v1(v40, v22.Activated:Connect(request))
local MouseEnter = v22.MouseEnter
v3(v40, MouseEnter:Connect(function() -- line 182 | captures: TweenService, v25
    TweenService:Create(v25, TweenInfo.new(0.2), { Rotation = 65 }):Play()
end))
local MouseLeave = v22.MouseLeave
v5(v40, MouseLeave:Connect(function() -- line 185 | captures: TweenService, v25
    TweenService:Create(v25, TweenInfo.new(0.2), { Rotation = 25 }):Play()
end))
local InputBegan = UserInputService.InputBegan
v7(v40, InputBegan:Connect(function(v58, v59) -- line 188 | captures: UserInputService, request
    if not (v59 or UserInputService:GetFocusedTextBox() or v58.KeyCode ~= Enum.KeyCode.Q and v58.KeyCode ~= Enum.KeyCode.ButtonR1) then
        request()
    end
end))
v9(v40, ChickenOrHero.Weapons.ArmoryEvent.OnClientEvent:Connect(function(v60, v61) -- line 197 | captures: v35
    if not (v60 == "State" and type(v61) == "table") then
        return
    end
    v35 = v61
    v35.abilities = v35.abilities or {}
end))
local OnClientEvent = GearEvent.OnClientEvent
v11(v40, OnClientEvent:Connect(function(v62, v63) -- line 203 | captures: v36, v37, v33
    if not (v62 == "Notice" and type(v63) == "string") then
        return
    end
    v33.Text = ""
    v37 = 0
    v36 = 0
end))
local v64 = v22:Clone()

v64.Name = "ChaserEquipped"
v64.Visible = false
v64.Active = false
v64.Selectable = false
v64.Parent = v21
v16.register(v64, v64.Scale, 2)
local v65 = false
local v66, Color
local Heartbeat = RunService.Heartbeat
v13(v40, Heartbeat:Connect(function(v67) -- line 219 | captures: v35, v36, v37, v38, v39, v65, v66, Color, UserInputService, LocalPlayer, Panels, v16, ControlGate, GearCatalog, v22, Outline, cardColors, v25, v26, v27, v28, v29, v30, v32, v33, active, pop, preview, v64
    v39 += v67
    if v39 < 0.05 then
        return
    end
    v39 = 0
    local v68 = LocalPlayer:GetAttribute("InMatch") ~= true
    local v69
    if v68 then
        v69 = "Runner"
    else
        v69 = LocalPlayer:GetAttribute("GameRole")
    end
    local v70 = GearCatalog.equippedForRole(v35, v69)
    local v71 = GearCatalog.get(v70)
    local v72 = if v35.loaded == true and LocalPlayer:GetAttribute("ClientReady") == true then not ControlGate.reason(LocalPlayer) else false
    local v73
    if v72 then
        if v71 == nil then
            v73 = false
        else
            v73 = v71.Kind == "Ability"
        end
    else
        v73 = v72
    end
    v22.Visible = v73
    local v74 = v68 and GearCatalog.get(GearCatalog.equippedForRole(v35, "Catcher")) or nil
    if v72 then
        if v74 == nil then
            v72 = false
        else
            v72 = v74.Kind == "Ability"
        end
    end
    v64.Visible = v72
    if v74 then
        v64.Title.Text = string.upper(v74.Name)
        v64.Hint.Text = "EQUIPPED \194\183 CHASER"
        v64.Hint.TextColor3 = v74.Accent or Panels.Gold
        v64.Charges.Text = "ABILITY"
        v64.Item.Visible = false
        v64.AbilityIcon.Visible = true
        v64.AbilityIcon.Image = v74.IconImage or ""
        v64.AbilityIcon.ImageRectOffset = v74.IconRectOffset or Vector2.zero
        v64.AbilityIcon.ImageRectSize = v74.IconRectSize or Vector2.zero
        v64.Outline.Color = v74.Accent or Panels.Gold
        if Color ~= v64.Outline.Color then
            Color = v64.Outline.Color
            v64.Gradient.Color = cardColors(Color)
        end
        v64.Track.Fill.BackgroundColor3 = v74.Accent or Panels.Gold
    end
    local v75 = (LocalPlayer:GetAttribute("AbilityReadyAt") or 0) - workspace:GetServerTimeNow()
    local v76 = math.max(0, v75)
    local v77 = active()
    if v77 then
        if v76 == 0 then
            local v78 = os.clock()
            v77 = v36 <= v78
        else
            v77 = false
        end
    end
    v22.Active = not not v77
    if v71 then
        if v38 ~= v70 then
            v38 = v70
            preview(v71)
        end
        local v79
        if UserInputService.PreferredInput == Enum.PreferredInput.Gamepad then
            v79 = "R1"
        elseif UserInputService.PreferredInput == Enum.PreferredInput.Touch then
            v79 = "TAP"
        else
            v79 = "Q"
        end
        v28.Text = string.upper(v71.Name)
        v30.Text = "ABILITY"
        local v80 = v71.UseRole and v71.UseRole ~= LocalPlayer:GetAttribute("GameRole")
        local v81
        if v68 then
            v81 = "EQUIPPED \194\183 RUNNER"
        else
            local v82
            if v80 then
                local v83 = if v71.UseRole == "Catcher" then "CHASERS" else "RUNNERS"
                local v84 = v83 .. " ONLY"
                if v84 then
                    v81 = v84
                    v82 = true
                else
                    v82 = false
                end
            else
                v82 = false
            end
            if not v82 then
                local v85
                if v76 > 0 then
                    local v86 = string.format("READY IN %.1fs", v76)
                    if v86 then
                        v81 = v86
                        v85 = true
                    elseif v77 then
                        local v87 = v79 .. "  \194\183  LET\226\128\153S GO!"
                        if v87 then
                            v81 = v87
                            v85 = true
                        else
                            v85 = false
                        end
                    else
                        v85 = false
                    end
                elseif v77 then
                    local v88 = v79 .. "  \194\183  LET\226\128\153S GO!"
                    if v88 then
                        v81 = v88
                        v85 = true
                    else
                        v85 = false
                    end
                else
                    v85 = false
                end
                if not v85 then
                    if LocalPlayer:GetAttribute("RunState") == "Caught" then
                        v81 = "CAUGHT"
                    elseif LocalPlayer:GetAttribute("RunState") == "Active" then
                        v81 = "NOT READY"
                    else
                        v81 = "WAIT FOR ROUND"
                    end
                end
            end
        end
        v29.Text = v81
        local v89 = v71.Accent or Panels.Gold
        v29.TextColor3 = v89
        v32.BackgroundColor3 = v89
        Outline.Color = v89
        if v66 ~= v89 then
            v66 = v89
            v25.Color = cardColors(v89)
        end
        local fromScale = UDim2.fromScale
        local v90 = 1 - v76 / (v71.Cooldown or 12)
        v32.Size = fromScale(math.clamp(v90, 0, 1), 1)
    end
    if v77 and not v65 and v22.Visible then
        pop()
    end
    v65 = v77
    local v91
    if v77 then
        local v92 = os.clock() * 3
        v91 = math.sin(v92) * 0.12 + 0.25 or 0.65
    else
        v91 = 0.65
    end
    Outline.Transparency = v91
    local v93 = if v77 then 0 else 0.3
    v28.TextTransparency = v93
    local v94 = if v77 then 0 else 0.35
    v26.ImageTransparency = v94
    local v95 = if v77 then 0 else 0.35
    v27.ImageTransparency = v95
    v33.Visible = os.clock() < v37
    v16.update(LocalPlayer.PlayerGui)
end))
script.Destroying:Connect(function() -- line 292 | captures: v21, v40
    for v96, v97 in v40 do
        v97:Disconnect()
    end
    v21:Destroy()
end)
ChickenOrHero.Weapons.ArmoryEvent:FireServer("Get")
