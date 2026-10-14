-- https://sitetest1.lua.expert

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local v1 = {}
local v2 = Color3.fromRGB(110, 205, 255)
local OneHitShield = game:GetService("ReplicatedStorage"):WaitForChild("ChickenOrHero"):WaitForChild("Gear"):WaitForChild("Assets"):WaitForChild("OneHitShield")

local function cloakAlpha(v3) -- line 15 | captures: Players
    local Character = Players.LocalPlayer.Character
    local v4 = Character and Character:FindFirstChild("HumanoidRootPart")
    local v5 = if v4 then v4.Position else workspace.CurrentCamera.CFrame.Position
    local v6 = ((v3.Position - v5).Magnitude - 0.5) / 19.5
    return (math.clamp(v6, 0, 1))
end

local Folder = Instance.new("Folder")

Folder.Name = "LocalShieldBubbles"
Folder.Parent = workspace

local function dropShield(v7) -- line 26
    if not v7.shield then
        return
    end
    v7.shield:Destroy()
    v7.shield = nil
    v7.shieldAlpha = nil
end

local function showShield(v8, v9, v10) -- line 32 | captures: v2, OneHitShield, Folder
    local shield = v8.shield
    if not shield then
        local v11 = OneHitShield:FindFirstChildWhichIsA("BasePart", true)
        if v11 then
            shield = v11:Clone()
            for v12, v13 in shield:GetChildren() do
                if v13:IsA("JointInstance") or v13:IsA("Constraint") or v13:IsA("LuaSourceContainer") then
                    v13:Destroy()
                end
            end
        else
            shield = Instance.new("Part")
            shield.Shape = Enum.PartType.Ball
            shield.Size = Vector3.new(6.400000095367432, 6.400000095367432, 6.400000095367432)
            shield.Material = Enum.Material.ForceField
            shield.Color = v2
        end
        shield.Name = "OneHitShieldBubble"
        shield.Anchored = true
        shield.CanCollide = false
        shield.CanTouch = false
        shield.CanQuery = false
        shield.CastShadow = false
        shield.Parent = Folder
        v8.shield = shield
    end
    if v8.shieldAlpha ~= v10 then
        v8.shieldAlpha = v10
        shield.Transparency = v10
    end
    shield.CFrame = v9.CFrame
end

local v14 = NumberSequence.new(1)

local function isEffect(v15) -- line 69
    return v15:IsA("ParticleEmitter") or v15:IsA("Trail") or v15:IsA("Beam")
end

local function showEffect(v16, v17) -- line 72
    v16.watches[v17]:Disconnect()
    v17.Transparency = v16.effects[v17]
    local effects = v16.effects
    local watches = v16.watches
    effects[v17] = nil
    watches[v17] = nil
end

local function hideEffect(v18, v19) -- line 78 | captures: v14
    if v18.effects[v19] then
        return
    end
    v18.effects[v19] = v19.Transparency
    local watches = v18.watches
    local Transparency = v19:GetPropertyChangedSignal("Transparency")
    watches[v19] = Transparency:Connect(function() -- line 84 | captures: v18, v19, v14
        local Transparency = v19.Transparency
        if v18.effects and v18.effects[v19] and Transparency ~= v14 then
            v18.effects[v19] = Transparency
            v19.Transparency = v14
        end
    end)
    v19.Transparency = v14
    if not v19:IsA("Beam") then
        v19:Clear()
    end
end

local function conceal(v20, v21) -- line 98 | captures: hideEffect
    if v20.effects then
        return
    end
    local v22 = {}
    v20.effects = {}
    v20.watches = v22
    for v23, v24 in v21:GetDescendants() do
        if v24:IsA("ParticleEmitter") or v24:IsA("Trail") or v24:IsA("Beam") then
            hideEffect(v20, v24)
        end
    end
    local DescendantAdded = v21.DescendantAdded
    v20.added = DescendantAdded:Connect(function(v25) -- line 108 | captures: v20, hideEffect
        if not v20.effects then
            return
        end
        if v25:IsA("ParticleEmitter") or v25:IsA("Trail") or v25:IsA("Beam") then
            hideEffect(v20, v25)
        end
    end)
    local DescendantRemoving = v21.DescendantRemoving
    v20.removing = DescendantRemoving:Connect(function(v26) -- line 114 | captures: v20
        if not (v20.effects and v20.effects[v26]) then
            return
        end
        v20.watches[v26]:Disconnect()
        v26.Transparency = v20.effects[v26]
        local effects = v20.effects
        local watches = v20.watches
        effects[v26] = nil
        watches[v26] = nil
    end)
end

local function reveal(v27) -- line 120
    if not v27.effects then
        return
    end
    v27.added:Disconnect()
    v27.removing:Disconnect()
    for v28 in v27.effects do
        v27.watches[v28]:Disconnect()
        v28.Transparency = v27.effects[v28]
        local effects = v27.effects
        local watches = v27.watches
        effects[v28] = nil
        watches[v28] = nil
    end
    v27.effects = nil
    v27.watches = nil
    v27.added = nil
    v27.removing = nil
end

local function restore(v29) -- line 131 | captures: reveal
    reveal(v29)
    for v30, v31 in v29.hidden do
        if v30.Parent then
            for v32, v33 in v31 do
                v30[v32] = v33
            end
        end
    end
    table.clear(v29.hidden)
end

local function hide(v34, v35, v36) -- line 142
    for v37, v38 in v35:GetDescendants() do
        local v39 = v34.hidden[v38]
        if not v39 then
            if v38:IsA("BasePart") then
                v39 = { LocalTransparencyModifier = v38.LocalTransparencyModifier }
            elseif v38:IsA("Decal") then
                v39 = { Transparency = v38.Transparency }
            elseif v38:IsA("Humanoid") then
                v39 = { DisplayDistanceType = v38.DisplayDistanceType }
            elseif v38:IsA("BillboardGui") or v38:IsA("Highlight") or v38:IsA("Light") or v38:IsA("Fire") or v38:IsA("Smoke") or v38:IsA("Sparkles") then
                v39 = {}
                v39.Enabled = v38.Enabled
            end
            v34.hidden[v38] = v39
        end
        if v39 then
            for v40, v41 in v39 do
                if v40 == "Enabled" then
                    v38[v40] = false
                elseif v40 == "DisplayDistanceType" then
                    v38[v40] = Enum.HumanoidDisplayDistanceType.None
                else
                    v38[v40] = v41 + (1 - v41) * v36
                end
            end
        end
    end
end

local function resetBlade(v42) -- line 177
    if v42.blade and v42.blade.Parent then
        v42.blade.Size = v42.size
    end
    if v42.weld and v42.weld.Parent then
        local weld = v42.weld
        local weld_2 = v42.weld
        local c0 = v42.c0
        local c1 = v42.c1
        weld.C0 = c0
        weld_2.C1 = c1
    end
    if v42.glow then
        v42.glow:Destroy()
    end
    if v42.light then
        v42.light:Destroy()
    end
    v42.blade = nil
    v42.weld = nil
    v42.glow = nil
    v42.light = nil
end

local function watch(v43) -- line 192 | captures: v1
    v1[v43] = {
        hidden = {}
    }
end

local function playerAdded(v44) -- line 195 | captures: v1, watch
    v44.CharacterAdded:Connect(watch)
    if v44.Character then
        local Character = v44.Character
        v1[Character] = {
            hidden = {}
        }
    end
end

Players.PlayerAdded:Connect(playerAdded)
for v45, v46 in Players:GetPlayers() do
    v46.CharacterAdded:Connect(watch)
    if v46.Character then
        v1[v46.Character] = {
            hidden = {}
        }
    end
end

local function scaled(v47, v48) -- line 205
    return CFrame.new(v47.Position * v48) * v47.Rotation
end

local Value = Enum.RenderPriority.Last.Value
RunService:BindToRenderStep("AbilityBuffVisuals", Value, function() -- line 208 | captures: Players, v1, showShield, conceal, restore, hide, resetBlade
    for v49, v50 in v1 do
        if v49.Parent then
            local HumanoidRootPart = v49:FindFirstChild("HumanoidRootPart")
            local v51 = v49 == Players.LocalPlayer.Character
            local v52 = v49:GetAttribute("Cloaked") == true
            local v53
            if v51 then
                v53 = 0.8
            elseif HumanoidRootPart then
                local Character = Players.LocalPlayer.Character
                local v54 = Character and Character:FindFirstChild("HumanoidRootPart")
                local v55 = if v54 then v54.Position else workspace.CurrentCamera.CFrame.Position
                local v56 = ((HumanoidRootPart.Position - v55).Magnitude - 0.5) / 19.5
                v53 = math.clamp(v56, 0, 1)
            else
                v53 = 1
            end
            if HumanoidRootPart and v49:GetAttribute("HitShielded") == true then
                local v57
                if v52 then
                    if v51 then
                        v57 = 0.6
                    else
                        v57 = v53
                    end
                else
                    v57 = 0
                end
                showShield(v50, HumanoidRootPart, v57)
            elseif v50.shield and v50.shield then
                v50.shield:Destroy()
                v50.shield = nil
                v50.shieldAlpha = nil
            end
            if v49:GetAttribute("Ghosted") == true then
                conceal(v50, v49)
                hide(v50, v49, 0.8)
            elseif v52 then
                conceal(v50, v49)
                hide(v50, v49, v53)
            elseif v50.effects or next(v50.hidden) then
                restore(v50)
            end
            local v58 = v49:GetAttribute("BigDaggerActive") == true
            local EquippedDagger = v49:FindFirstChild("EquippedDagger")
            local v59 = EquippedDagger and EquippedDagger:FindFirstChild("Blade")
            if v50.blade and v50.blade ~= v59 then
                resetBlade(v50)
            end
            if v58 and v59 and not v50.blade then
                local Handle = EquippedDagger:FindFirstChild("Handle")
                local v60 = Handle and Handle:FindFirstChild("BladeWeld")
                if v60 then
                    local Size = v59.Size
                    local C0 = v60.C0
                    local C1 = v60.C1
                    v50.blade = v59
                    v50.size = Size
                    v50.weld = v60
                    v50.c0 = C0
                    v50.c1 = C1
                    local Highlight = Instance.new("Highlight")
                    Highlight.Name = "BigDaggerGlow"
                    Highlight.Adornee = v59
                    Highlight.DepthMode = Enum.HighlightDepthMode.Occluded
                    Highlight.FillColor = Color3.fromRGB(255, 207, 64)
                    Highlight.OutlineColor = Color3.fromRGB(255, 235, 120)
                    Highlight.FillTransparency = 0.55
                    Highlight.OutlineTransparency = 0.08
                    Highlight.Parent = v59
                    v50.glow = Highlight
                    local PointLight = Instance.new("PointLight")
                    PointLight.Name = "BigDaggerLight"
                    PointLight.Color = Color3.fromRGB(255, 216, 86)
                    PointLight.Brightness = 1.1
                    PointLight.Range = 7
                    PointLight.Shadows = false
                    PointLight.Parent = v59
                    v50.light = PointLight
                end
            end
            if v50.blade then
                if v58 then
                    v50.blade.Size = v50.size * 2
                    local weld = v50.weld
                    local weld_2 = v50.weld
                    local c0 = v50.c0
                    local v61 = CFrame.new(c0.Position * 2) * c0.Rotation
                    local c1 = v50.c1
                    local v62 = CFrame.new(c1.Position * 2) * c1.Rotation
                    weld.C0 = v61
                    weld_2.C1 = v62
                else
                    resetBlade(v50)
                end
            end
        else
            restore(v50)
            resetBlade(v50)
            if v50.shield then
                v50.shield:Destroy()
                v50.shield = nil
                v50.shieldAlpha = nil
            end
            v1[v49] = nil
        end
    end
end)
script.Destroying:Connect(function() -- line 277 | captures: RunService, v1, Folder, restore, resetBlade
    RunService:UnbindFromRenderStep("AbilityBuffVisuals")
    for v63, v64 in v1 do
        restore(v64)
        resetBlade(v64)
        if v64.shield then
            v64.shield:Destroy()
            v64.shield = nil
            v64.shieldAlpha = nil
        end
    end
    Folder:Destroy()
end)
