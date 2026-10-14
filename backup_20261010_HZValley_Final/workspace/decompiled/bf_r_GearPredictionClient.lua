-- https://sitetest1.lua.expert

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")
local LocalPlayer = Players.LocalPlayer
local ChickenOrHero = game.ReplicatedStorage:WaitForChild("ChickenOrHero")
local Assets = ChickenOrHero.Gear:WaitForChild("Assets")
local GearEvent = ChickenOrHero.Gear:WaitForChild("GearEvent")
local v1 = require(ChickenOrHero.Gear:WaitForChild("AirhornCone"))
local v2 = require(ChickenOrHero.Gear:WaitForChild("GearCatalog"))
local ClientBots = require(game:GetService("ReplicatedFirst"):WaitForChild("FFlags")).ClientBots
local v3 = {
    FX = Instance.new("BindableEvent"),
    Cancel = Instance.new("BindableEvent")
}
local Folder = Instance.new("Folder")

Folder.Name = "PredictedGearPresentation"
Folder.Parent = workspace

local v4 = {}
local v5 = {}
local v6 = {}
local v7 = {}
local v8 = {}
local v9 = {
    BananaPeel = 15.75,
    PocketDoor = 6,
    BowlingBall = 2,
    RufusLeash = 0.45,
    BearTrap = 0.9 + v2.Items.BearTrap.TrapDuration
}
local v10 = {
    BowlingBall = 42,
    RufusLeash = 65
}
local v11 = {
    BananaPeel = "BananaThrow",
    RescueKit = "Rescue",
    Adrenaline = "Adrenaline",
    EmergencyAirhorn = "Airhorn",
    RocketShoes = "Rocket",
    InflatableDecoy = "DecoyInflate",
    PocketDoor = "DoorSlam",
    RufusLeash = "LeashThrow",
    BowlingBall = "BowlingUse",
    BearTrap = "BearTrapThrow"
}
local v12 = {
    BananaPeel = true,
    BearTrap = true
}

local function flat(v13) -- line 47
    local v14 = v13 * Vector3.new(1, 0, 1)
    return v14.Magnitude > 0.01 and v14.Unit or Vector3.new(0, 0, 1)
end

local function count(v15) -- line 51
    local v16 = 0
    for v17 in v15 do
        v16 += 1
    end
    return v16
end

local function params() -- line 58 | captures: Players, CollectionService, ClientBots, Folder
    local v18 = RaycastParams.new()
    v18.FilterType = Enum.RaycastFilterType.Exclude
    v18.RespectCanCollide = true
    local v19 = { Folder }
    for v20, v21 in Players:GetPlayers() do
        if v21.Character then
            local Character = v21.Character
            table.insert(v19, Character)
        end
    end
    for v22, v23 in CollectionService:GetTagged("PredictedGearVisual") do
        table.insert(v19, v23)
    end
    local v24 = ClientBots and workspace:FindFirstChild("ClientBots")
    if v24 then
        table.insert(v19, v24)
    end
    v18.FilterDescendantsInstances = v19
    return v18
end

local function pivot(v25) -- line 78
    return v25:IsA("Model") and v25:GetPivot() or v25.CFrame
end

local function move(v26, v27) -- line 81
    if v26:IsA("Model") then
        v26:PivotTo(v27)
    else
        v26.CFrame = v27
    end
end

local function descendants(v28) -- line 88
    local v29 = v28:GetDescendants()
    table.insert(v29, v28)
    return v29
end

local function cloneVisual(v30) -- line 93 | captures: CollectionService, Folder
    if not v30 then
        return
    end
    local Archivable = v30.Archivable
    v30.Archivable = true
    local v31, v32 = pcall(function() -- line 99 | captures: v30
        return v30:Clone()
    end)
    v30.Archivable = Archivable
    if not v31 or not v32 then
        return
    end
    local v33 = v32:GetDescendants()
    table.insert(v33, v32)
    for v34, v35 in v33 do
        for v36, v37 in CollectionService:GetTags(v35) do
            CollectionService:RemoveTag(v35, v37)
        end
        if v35:IsA("LuaSourceContainer") or v35:IsA("Sound") or v35:IsA("ProximityPrompt") or v35:IsA("ForceField") then
            v35:Destroy()
        elseif v35:IsA("BasePart") then
            v35.Anchored = true
            v35.CanCollide = false
            v35.CanTouch = false
            v35.CanQuery = false
            v35.Massless = true
            v35.LocalTransparencyModifier = 0
        elseif v35:IsA("Humanoid") then
            v35.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
            v35.HealthDisplayType = Enum.HumanoidHealthDisplayType.AlwaysOff
        end
    end
    v32.Name = "PredictedVisual"
    v32.Parent = Folder
    return v32
end

local function restore(v38) -- line 128
    for v39, v40 in v38.hidden or {} do
        if v39.Parent then
            if v39:IsA("BasePart") then
                v39.LocalTransparencyModifier = v40
            elseif v39:IsA("Decal") or v39:IsA("Texture") then
                v39.Transparency = v40
            else
                v39.Enabled = v40
            end
        end
    end
    if v38.added then
        v38.added:Disconnect()
    end
end

local function remove(v41) -- line 144 | captures: v4, restore
    if v41.proxy then
        v41.proxy:Destroy()
    end
    restore(v41)
    if v4[v41.id] == v41 then
        v4[v41.id] = nil
    end
end

local function hide(v42, v43) -- line 153
    v42.hidden = {}

    local function one(v44) -- line 155 | captures: v42
        if v42.hidden[v44] == nil then
            if v44:IsA("BasePart") then
                v42.hidden[v44] = v44.LocalTransparencyModifier
                v44.LocalTransparencyModifier = 1
            elseif not (v44:IsA("Decal") or v44:IsA("Texture")) then
                if v44:IsA("ParticleEmitter") or v44:IsA("Trail") or v44:IsA("Beam") or v44:IsA("Light") or v44:IsA("BillboardGui") then
                    v42.hidden[v44] = v44.Enabled
                    v44.Enabled = false
                end
            else
                v42.hidden[v44] = v44.Transparency
                v44.Transparency = 1
            end
        end
    end

    local v45 = v43:GetDescendants()
    table.insert(v45, v43)
    for v46, v47 in v45 do
        one(v47)
    end
    v42.added = v43.DescendantAdded:Connect(one)
end

local function plan(v48, v49) -- line 181 | captures: LocalPlayer, Assets, v2, v12, params
    local Character = LocalPlayer.Character
    local v50 = Character and Character:FindFirstChild("HumanoidRootPart")
    if not v50 then
        return
    end
    local v51 = v50.CFrame.LookVector * Vector3.new(1, 0, 1)
    local Unit = v51.Magnitude > 0.01 and v51.Unit or Vector3.new(0, 0, 1)
    local v52, v53
    if v48 == "RocketShoes" and typeof(v49) == "Vector3" then
        local v54 = v49 * Vector3.new(1, 0, 1)
        if v54.Magnitude > 0.01 then
            local Unit = v54.Unit
            if Unit then
                v52 = Unit
                v53 = true
            else
                v53 = false
            end
        else
            v53 = false
        end
    else
        v52 = Unit
        v53 = true
    end
    if not v53 then
        v52 = Vector3.new(0, 0, 1)
    end
    local v55 = {
        item = v48,
        origin = v50.Position,
        direction = v52
    }
    local v56 = params()
    if v12[v48] then
        local v57 = Assets:FindFirstChild(v48)
        if not v57 or not v57:IsA("BasePart") and not v57:IsA("Model") then
            return
        end
        local ThrowRange = v48 == "BearTrap" and v2.Items.BearTrap.ThrowRange or 10
        local v58 = workspace:Raycast(v50.Position + v50.CFrame.LookVector * ThrowRange, Vector3.new(0, -8, 0), v56)
        local RightHand, v59
        if v58 then
            if v58.Normal.Y < 0.65 then
                v59 = true
            else
                RightHand = Character:FindFirstChild("RightHand") or Character:FindFirstChild("Right Arm") or v50
                v59 = false
            end
        else
            v59 = true
        end
        if v59 then
            return
        end
        v55.hand = RightHand
        v55.origin = v55.hand.Position - v55.hand.CFrame.UpVector * v55.hand.Size.Y * 0.35
        local Y = v57:IsA("Model") and v57:GetExtentsSize().Y or v57.Size.Y
        local v60 = v58.Position + v58.Normal * (Y * 0.5 + 0.06)
        local v61 = v50.CFrame.LookVector - v58.Normal * v50.CFrame.LookVector:Dot(v58.Normal)
        if v61.Magnitude < 0.01 then
            v61 = Vector3.new(0, 0, 1)
        end
        v55.landing = CFrame.lookAt(v60, v60 + v61, v58.Normal)
    elseif v48 == "PocketDoor" then
        local v62 = workspace:Raycast(v50.Position + v52 * 5, Vector3.new(0, -9, 0), v56)
        if not v62 or v62.Normal.Y < 0.85 then
            return
        end
        v55.origin = v62.Position + Vector3.new(0, 3.799999952316284, 0)
        v55.cf = CFrame.lookAt(v55.origin, v55.origin + v52)
    else
        if v48 == "BowlingBall" then
            local v63 = workspace:Raycast(v50.Position + v52 * 3, Vector3.new(0, -9, 0), v56)
            if v63 then
                v55.origin = v63.Position + Vector3.new(0, 1.0499999523162842, 0)
                return v55
            end
            return
        end
        if v48 == "InflatableDecoy" then
            local v64 = v50.Position + v50.CFrame.RightVector * 2.7
            local v65 = workspace:Raycast(v64, Vector3.new(0, -9, 0), v56)
            local X, Y, v66
            if v65 then
                local v67 = workspace:Raycast(v50.Position, Vector3.new(0, -9, 0), v56)
                X = v64.X
                Y = v65.Position.Y
                if v67 then
                    local v68 = v50.Position.Y - v67.Position.Y
                    v66 = math.clamp(v68, 2, 5) or 3
                else
                    v66 = 3
                end
            else
                return
            end
            local v69 = Y + v66
            local Z = v64.Z
            v55.origin = Vector3.new(X, v69, Z)
        end
    end
    return v55
end

local function build(v70, v71) -- line 240 | captures: Assets, v4, v9, v10, v12, cloneVisual
    local v72 = v9[v70.item]
    local v73
    if v72 then
        local v74 = 0
        for v75 in v4 do
            v74 += 1
        end
        v73 = v74 >= 64
    end
    if v72 and not v73 then
        v70.proxy = cloneVisual(v71 or Assets:FindFirstChild(v70.item))
        if v70.proxy then
            v70.started = v70.started or workspace:GetServerTimeNow()
            v70.duration = v9[v70.item]
            v70.speed = v10[v70.item] or 0
            v70.distance = 0
            if v12[v70.item] or v70.item == "RufusLeash" then
                local proxy = v70.proxy:IsA("BasePart") and v70.proxy or v70.proxy:FindFirstChildWhichIsA("BasePart", true)
                if proxy then
                    local v76 = v70.proxy:FindFirstChildWhichIsA("Trail", true)
                    if v76 then
                        v70.trail = v76
                    else
                        local Attachment = Instance.new("Attachment")
                        Attachment.Position = Vector3.new(-0.20000000298023224, 0, 0)
                        Attachment.Parent = proxy
                        local Attachment_2 = Instance.new("Attachment")
                        Attachment_2.Position = Vector3.new(0.20000000298023224, 0, 0)
                        Attachment_2.Parent = proxy
                        local Trail = Instance.new("Trail")
                        Trail.Attachment0 = Attachment
                        Trail.Attachment1 = Attachment_2
                        Trail.Lifetime = 0.25
                        Trail.Color = ColorSequence.new(v70.item == "BananaPeel" and Color3.fromRGB(255, 214, 90) or v70.item == "BearTrap" and Color3.fromRGB(186, 192, 204) or Color3.fromRGB(119, 229, 255))
                        Trail.Transparency = NumberSequence.new(0.1, 1)
                        Trail.FaceCamera = true
                        Trail.LightEmission = 0.85
                        Trail.Parent = proxy
                        v70.trail = Trail
                    end
                end
            end
            if v70.item == "BowlingBall" then
                local proxy = v70.proxy:IsA("BasePart") and v70.proxy or v70.proxy:FindFirstChildWhichIsA("BasePart", true)
                if proxy then
                    local Sound = Instance.new("Sound")
                    Sound.Name = "BowlingRoll"
                    Sound.SoundId = "rbxassetid://9125752846"
                    Sound.Volume = 0.35
                    Sound.RollOffMaxDistance = 100
                    Sound.RollOffMinDistance = 7
                    Sound.RollOffMode = Enum.RollOffMode.InverseTapered
                    Sound.PlaybackSpeed = 3
                    Sound.Looped = true
                    Sound.Parent = proxy
                    Sound:Play()
                end
            end
            v70.position = v70.origin
            v70.display = v70.cf or CFrame.lookAt(v70.origin, v70.origin + v70.direction)
            if v70.item == "PocketDoor" and v70.proxy:IsA("BasePart") then
                v70.proxy.Size = Vector3.new(5.199999809265137, 7.199999809265137, 0.699999988079071)
            end
            local proxy = v70.proxy
            local display = v70.display
            if proxy:IsA("Model") then
                proxy:PivotTo(display)
            else
                proxy.CFrame = display
            end
            v4[v70.id] = v70
            return v70
        end
    end
end

local v77, v78

local function stopRocket(v79, v80) -- line 310 | captures: v77, v78, LocalPlayer, v2
    local v81 = v77
    if not v81 or v79 and v81.id ~= v79 then
        return
    end
    v77 = nil
    v81.velocity:Destroy()
    v81.attachment:Destroy()
    v81.velocity = nil
    v81.attachment = nil
    if v81.root.Parent and v81.character == LocalPlayer.Character then
        if v80 then
            local v82 = v81.root.AssemblyLinearVelocity:Dot(v81.direction)
            v81.speed = math.clamp(v82, 0, 64)
            v81.carryEnds = v81.ends + v2.Items.RocketShoes.CarrySeconds
            v78 = v81
        else
            v81.root.AssemblyLinearVelocity = Vector3.new(0, 1, 0) * v81.root.AssemblyLinearVelocity.Y
        end
    end
end

local function settleRocket(v83) -- line 330 | captures: v77, LocalPlayer, stopRocket
    local v84 = v77
    if not v84 then
        return
    end
    if v84.character == LocalPlayer.Character and v84.root.Parent and not v84.character:GetAttribute("Ragdolled") then
        if v84.ends <= v83 then
            stopRocket(v84.id, true)
        end
    else
        local id = v84.id
        local v85 = v77
        if v85 and (not id or v85.id == id) then
            v77 = nil
            v85.velocity:Destroy()
            v85.attachment:Destroy()
            v85.velocity = nil
            v85.attachment = nil
            if v85.root.Parent and v85.character == LocalPlayer.Character then
                v85.root.AssemblyLinearVelocity = Vector3.new(0, 1, 0) * v85.root.AssemblyLinearVelocity.Y
            end
        end
    end
end

local function watchFlag(v86) -- line 347
    if v86.character:GetAttribute("GearMotion") == true then
        v86.flag = v86.flag or "Set"
    elseif v86.flag == "Set" then
        v86.flag = "Cleared"
    end
end

local function startRocket(v87, v88, v89) -- line 354 | captures: v77, v78, stopRocket
    local v90 = v88 and v88:FindFirstChild("HumanoidRootPart")
    local Unit, v91
    if v90 then
        if v90.Anchored then
            v91 = true
        elseif typeof(v89) == "Vector3" then
            stopRocket()
            v78 = nil
            local v92 = v89 * Vector3.new(1, 0, 1)
            Unit = v92.Magnitude > 0.01 and v92.Unit or Vector3.new(0, 0, 1)
            v91 = false
        else
            v91 = true
        end
    else
        v91 = true
    end
    if v91 then
        return
    end
    local Attachment = Instance.new("Attachment")
    Attachment.Name = "PredictedRocketAttachment"
    Attachment.Parent = v90
    local LinearVelocity = Instance.new("LinearVelocity")
    LinearVelocity.Name = "PredictedRocketVelocity"
    LinearVelocity.Attachment0 = Attachment
    LinearVelocity.RelativeTo = Enum.ActuatorRelativeTo.World
    LinearVelocity.VelocityConstraintMode = Enum.VelocityConstraintMode.Plane
    LinearVelocity.PrimaryTangentAxis = Vector3.new(1, 0, 0)
    LinearVelocity.SecondaryTangentAxis = Vector3.new(0, 0, 1)
    LinearVelocity.PlaneVelocity = Vector2.new(Unit.X, Unit.Z) * 64
    LinearVelocity.ForceLimitsEnabled = true
    LinearVelocity.ForceLimitMode = Enum.ForceLimitMode.Magnitude
    local AssemblyMass = v90.AssemblyMass
    LinearVelocity.MaxForce = math.max(1, AssemblyMass) * 2500
    LinearVelocity.Parent = v90
    v90.AssemblyLinearVelocity = Unit * 64 + Vector3.new(0, 1, 0) * v90.AssemblyLinearVelocity.Y
    v77 = {
        id = v87,
        root = v90,
        character = v88,
        direction = Unit,
        velocity = LinearVelocity,
        attachment = Attachment,
        ends = workspace:GetServerTimeNow() + 0.42
    }
end

function v3.rocket(v93) -- line 391 | captures: v77, v78, v2, settleRocket
    local v94 = workspace:GetServerTimeNow()
    settleRocket(v94)
    if v77 and v77.character == v93 then
        return "Boost"
    end
    local v95 = v78
    if v95 and v95.character == v93 and not (v95.carryEnds <= v94) then
        if v95.handed then
            if v95.flag == "Cleared" then
                return nil
            end
            return "Tail"
        end
        v95.handed = true
        return "Carry", v95.speed, v95.direction, v2.Items.RocketShoes.CarrySeconds
    end
    return nil
end

local function airhornReport() -- line 407 | captures: Players, LocalPlayer, ChickenOrHero, v1, params
    local Character = LocalPlayer.Character
    local v96 = Character and Character:FindFirstChild("HumanoidRootPart")
    if v96 then
        local Position = v96.Position
        local v97 = v96.CFrame.LookVector * Vector3.new(1, 0, 1)
        local Unit = v97.Magnitude > 0.01 and v97.Unit or Vector3.new(0, 0, 1)
        local v98 = {
            at = workspace:GetServerTimeNow(),
            origin = Position,
            direction = Unit,
            targets = {}
        }
        local AdminMatchMode = ChickenOrHero.Game.Session:GetAttribute("AdminMatchMode")
        local v99 = if AdminMatchMode == "CrossyRoad" or AdminMatchMode == "DonkeyKong" then true else AdminMatchMode == "FFACatchers"
        local v100 = params()
        for v101, v102 in Players:GetPlayers() do
            local Character = v102.Character
            local v103 = Character and Character:FindFirstChild("HumanoidRootPart")
            if v102 ~= LocalPlayer and v103 and v102:GetAttribute("RunState") == "Active" and (v99 or v102:GetAttribute("GameRole") == "Catcher") and v102:GetAttribute("FFAInvincible") ~= true and v1.contains(Position, Unit, v103.Position) and not workspace:Raycast(Position, v103.Position - Position, v100) then
                local targets = v98.targets
                local v104 = {}
                v104.userId = v102.UserId
                v104.position = v103.Position
                table.insert(targets, v104)
                if #v98.targets >= 32 then
                    break
                end
            end
        end
        return v98
    end
    return nil
end

local v105 = 0

function v3.request(v106, v107, v108) -- line 439 | captures: v105, HttpService, LocalPlayer, GearEvent, v3, v5, v8, v11, plan, build, airhornReport
    local v109 = workspace:GetServerTimeNow()
    if v109 < v105 then
        return nil
    end
    if v108 == "UseAbility" and v109 < (LocalPlayer:GetAttribute("AbilityReadyAt") or 0) then
        return nil
    end
    if v108 == "Use" and v109 < (LocalPlayer:GetAttribute("GearReadyAt") or 0) then
        return nil
    end
    v105 = v109 + 0.6
    local v110 = v106 == "EmergencyAirhorn" and airhornReport() or nil
    local v111 = HttpService:GenerateGUID(false)
    local v112 = {
        item = v106,
        character = LocalPlayer.Character,
        started = workspace:GetServerTimeNow(),
        emitted = {}
    }
    local v113 = 0
    for v114 in v5 do
        v113 += 1
    end
    if v113 >= 24 then
        local started, v115
        for v116, v117 in v5 do
            if started then
                if v117.started < started then
                    started = v117.started
                    v115 = v116
                end
            else
                started = v117.started
                v115 = v116
            end
        end
        if v115 then
            v5[v115] = nil
        end
    end
    v5[v111] = v112
    v8[v111] = v112
    local v118 = 0
    for v119 in v8 do
        v118 += 1
    end
    if v118 > 128 then
        local v120, started
        for v121, v122 in v8 do
            if started then
                if v122.started < started then
                    started = v122.started
                    v120 = v121
                end
            else
                started = v122.started
                v120 = v121
            end
        end
        if v120 then
            v8[v120] = nil
        end
    end
    local v123, v124 = pcall(function() -- line 479 | captures: v106, v107, v111, v112, LocalPlayer, v3, v11, plan, build
        local v125 = plan(v106, v107)
        local v126 = v112.character and v112.character:FindFirstChild("HumanoidRootPart")
        if not v126 then
            return
        end
        local origin
        if v125 then
            v125.id = v111
            v125.predicted = true
            v125.started = v112.started
            build(v125)
            origin = v125.origin or v126.Position
        else
            origin = v126.Position
        end
        local v127, v128
        if v106 == "BananaPeel" or v106 == "RescueKit" or v106 == "Adrenaline" then
            local v129 = { v11[v106] }
            if v129 then
                v127 = v129
                v128 = true
            else
                v128 = false
            end
        else
            v128 = false
        end
        if not v128 then
            v127 = {
                "Use",
                v11[v106]
            }
        end
        for v130, v131 in v127 do
            if v131 then
                v112.emitted[v131] = true
                local FX = v3.FX
                local v132 = {
                    kind = v131,
                    item = v106,
                    position = origin
                }
                local direction
                if v125 then
                    direction = v125.direction
                    if not direction then
                        local v133 = v126.CFrame.LookVector * Vector3.new(1, 0, 1)
                        direction = v133.Magnitude > 0.01 and v133.Unit or Vector3.new(0, 0, 1)
                    end
                else
                    local v134 = v126.CFrame.LookVector * Vector3.new(1, 0, 1)
                    direction = v134.Magnitude > 0.01 and v134.Unit or Vector3.new(0, 0, 1)
                end
                v132.direction = direction
                if v131 == "DecoyInflate" then
                    v132.character = nil
                else
                    v132.character = v112.character
                end
                v132.cf = v125 and v125.cf
                v132.requestId = v111
                v132.ownerId = LocalPlayer.UserId
                FX:Fire(v132)
            end
        end
    end)
    if not v123 then
        warn("Gear visual prediction skipped:", v124)
    end
    local v135, v136
    if v108 == "StudioUseItem" then
        if v106 then
            v135 = v106
            v136 = true
        else
            v136 = false
        end
    elseif v108 == "StudioUseAbility" and v106 then
        v135 = v106
        v136 = true
    else
        v136 = false
    end
    if not v136 then
        v135 = nil
    end
    GearEvent:FireServer(v108, v135, v107, v111, nil, v110)
    return v111
end

local v137 = { Use = true }
for v138, v139 in v11 do
    v137[v139] = true
end

function v3.consumeFX(v140) -- line 528 | captures: LocalPlayer, v137
    if type(v140) == "table" and v140.ownerId == LocalPlayer.UserId then
        local requestId = v140.requestId
        if type(requestId) == "string" then
            return v137[v140.kind] == true
        end
    end
    return false
end

local function bind(v141) -- line 537 | captures: Players, CollectionService, LocalPlayer, v4, v6, v7, v8, v9, v12, restore, hide, build
    local v142 = v6[v141]
    local v143
    if not v142 then
        local v144 = 0
        for v145 in v6 do
            v144 += 1
        end
        v143 = v144 >= 128
    end
    if v142 or v143 then
        return
    end
    v6[v141] = true
    task.spawn(function() -- line 542 | captures: v141, Players, CollectionService, LocalPlayer, v4, v6, v7, v8, v9, v12, restore, hide, build
        for v146 = 1, 120 do
            if CollectionService:HasTag(v141, "PredictedGearVisual") then
                if v141:IsDescendantOf(workspace) and v141:GetAttribute("GearRequestId") and v141:GetAttribute("GearOrigin") then
                    break
                end
            else
                v6[v141] = nil
                return
            end
            task.wait(0.05)
        end
        v6[v141] = nil
        if not v141:IsDescendantOf(workspace) then
            return
        end
        local GearRequestId = v141:GetAttribute("GearRequestId")
        local GearOrigin = v141:GetAttribute("GearOrigin")
        local GearVisualKind = v141:GetAttribute("GearVisualKind")
        if not (type(GearRequestId) == "string" and typeof(GearOrigin) == "Vector3" and v9[GearVisualKind]) then
            return
        end
        local v147 = if v141:GetAttribute("GearOwnerId") == LocalPlayer.UserId then v8[GearRequestId] else false
        local v148 = v4[GearRequestId]
        local v149, v150
        if v148 then
            if v148.item == GearVisualKind then
                v149 = v148
                v150 = true
            else
                if v148.proxy then
                    v148.proxy:Destroy()
                end
                v150 = false
            end
        else
            v149 = v148
            v150 = true
        end
        if not v150 then
            restore(v148)
            if v4[v148.id] == v148 then
                v4[v148.id] = nil
            end
            v149 = nil
        end
        if v149 and v149.server then
            return
        end
        if GearVisualKind == "RufusLeash" and v147 and not v149 then
            local v151 = workspace:GetServerTimeNow() - v147.started
            if v9.RufusLeash <= v151 then
                v141:Destroy()
                return
            end
        end
        local v152
        if v149 then
            v152 = v149
        else
            local v153 = {
                id = GearRequestId,
                item = GearVisualKind,
                origin = GearOrigin
            }
            local GearDirection = v141:GetAttribute("GearDirection")
            local v154 = Vector3.new(0, 0, 1)
            v153.direction = GearDirection or v154
            v153.started = v147 and v147.started or v141:GetAttribute("GearSpawnedAt")
            v153.predicted = v147 ~= nil
            v153.landing = v141:GetAttribute("GearLanding")
            v153.cf = v141:GetAttribute("GearTargetCFrame")
            v152 = build(v153, v141)
        end
        if v152 then
            v152.server = v141
            v152.origin = GearOrigin
            v152.direction = v141:GetAttribute("GearDirection") or v152.direction
            v152.landing = v141:GetAttribute("GearLanding") or v152.landing
            v152.cf = v141:GetAttribute("GearTargetCFrame") or v152.cf
            v152.duration = v141:GetAttribute("GearDuration") or v152.duration
            v152.speed = v141:GetAttribute("GearSpeed") or v152.speed
            v152.serverStarted = v141:GetAttribute("GearSpawnedAt") or v152.started
            if not v152.predicted then
                v152.started = v152.serverStarted
            end
            local v155 = Players:GetPlayerByUserId(v141:GetAttribute("GearOwnerId") or 0)
            local v156 = v155 and v155.Character
            if v12[v152.item] and v156 then
                v152.hand = v156:FindFirstChild("RightHand") or v156:FindFirstChild("Right Arm")
            end
            v152.serverLast = v141:IsA("Model") and v141:GetPivot() or v141.CFrame
            v152.serverChanged = workspace:GetServerTimeNow()
            if v152.item == "BowlingBall" and v7[GearRequestId] then
                v152.authoritativeCF = v7[GearRequestId].cf
                v152.authoritativeAt = v7[GearRequestId].received
                v152.authoritativeTime = v7[GearRequestId].serverTime
            end
            hide(v152, v141)
        end
    end)
end

CollectionService:GetInstanceAddedSignal("PredictedGearVisual"):Connect(bind)
for v157, v158 in CollectionService:GetTagged("PredictedGearVisual") do
    if not v6[v158] then
        local v159 = 0
        for v160 in v6 do
            v159 += 1
        end
        if not (v159 >= 128) then
            v6[v158] = true
            local spawn = task.spawn
            local v161 = v158
            spawn(function() -- line 542 | captures: Players, CollectionService, LocalPlayer, v4, v6, v7, v8, v9, v12, restore, hide, build, v161
                for v162 = 1, 120 do
                    if CollectionService:HasTag(v161, "PredictedGearVisual") then
                        if v161:IsDescendantOf(workspace) and v161:GetAttribute("GearRequestId") and v161:GetAttribute("GearOrigin") then
                            break
                        end
                    else
                        v6[v161] = nil
                        return
                    end
                    task.wait(0.05)
                end
                v6[v161] = nil
                if not v161:IsDescendantOf(workspace) then
                    return
                end
                local GearRequestId = v161:GetAttribute("GearRequestId")
                local GearOrigin = v161:GetAttribute("GearOrigin")
                local GearVisualKind = v161:GetAttribute("GearVisualKind")
                if not (type(GearRequestId) == "string" and typeof(GearOrigin) == "Vector3" and v9[GearVisualKind]) then
                    return
                end
                local v163 = if v161:GetAttribute("GearOwnerId") == LocalPlayer.UserId then v8[GearRequestId] else false
                local v164 = v4[GearRequestId]
                local v165, v166
                if v164 then
                    if v164.item == GearVisualKind then
                        v165 = v164
                        v166 = true
                    else
                        if v164.proxy then
                            v164.proxy:Destroy()
                        end
                        v166 = false
                    end
                else
                    v165 = v164
                    v166 = true
                end
                if not v166 then
                    restore(v164)
                    if v4[v164.id] == v164 then
                        v4[v164.id] = nil
                    end
                    v165 = nil
                end
                if v165 and v165.server then
                    return
                end
                if GearVisualKind == "RufusLeash" and v163 and not v165 then
                    local v167 = workspace:GetServerTimeNow() - v163.started
                    if v9.RufusLeash <= v167 then
                        v161:Destroy()
                        return
                    end
                end
                local v168
                if v165 then
                    v168 = v165
                else
                    local v169 = {
                        id = GearRequestId,
                        item = GearVisualKind,
                        origin = GearOrigin
                    }
                    local GearDirection = v161:GetAttribute("GearDirection")
                    local v170 = Vector3.new(0, 0, 1)
                    v169.direction = GearDirection or v170
                    v169.started = v163 and v163.started or v161:GetAttribute("GearSpawnedAt")
                    v169.predicted = v163 ~= nil
                    v169.landing = v161:GetAttribute("GearLanding")
                    v169.cf = v161:GetAttribute("GearTargetCFrame")
                    v168 = build(v169, v161)
                end
                if v168 then
                    v168.server = v161
                    v168.origin = GearOrigin
                    v168.direction = v161:GetAttribute("GearDirection") or v168.direction
                    v168.landing = v161:GetAttribute("GearLanding") or v168.landing
                    v168.cf = v161:GetAttribute("GearTargetCFrame") or v168.cf
                    v168.duration = v161:GetAttribute("GearDuration") or v168.duration
                    v168.speed = v161:GetAttribute("GearSpeed") or v168.speed
                    v168.serverStarted = v161:GetAttribute("GearSpawnedAt") or v168.started
                    if not v168.predicted then
                        v168.started = v168.serverStarted
                    end
                    local v171 = Players:GetPlayerByUserId(v161:GetAttribute("GearOwnerId") or 0)
                    local v172 = v171 and v171.Character
                    if v12[v168.item] and v172 then
                        v168.hand = v172:FindFirstChild("RightHand") or v172:FindFirstChild("Right Arm")
                    end
                    v168.serverLast = v161:IsA("Model") and v161:GetPivot() or v161.CFrame
                    v168.serverChanged = workspace:GetServerTimeNow()
                    if v168.item == "BowlingBall" and v7[GearRequestId] then
                        v168.authoritativeCF = v7[GearRequestId].cf
                        v168.authoritativeAt = v7[GearRequestId].received
                        v168.authoritativeTime = v7[GearRequestId].serverTime
                    end
                    hide(v168, v161)
                end
            end)
        end
    end
end
GearEvent.OnClientEvent:Connect(function(v173, v174) -- line 632 | captures: v77, LocalPlayer, v3, v4, v5, v7, v12, restore, startRocket
    if v173 == "BowlingPosition" then
        if type(v174) == "table" then
            local requestId = v174.requestId
            if type(requestId) == "string" then
                local cf = v174.cf
                if typeof(cf) == "CFrame" then
                    local v175 = workspace:GetServerTimeNow()
                    v7[v174.requestId] = {
                        cf = v174.cf,
                        received = v175,
                        serverTime = v174.serverTime
                    }
                    local v176 = v4[v174.requestId]
                    if v176 and v176.item == "BowlingBall" then
                        v176.authoritativeCF = v174.cf
                        v176.authoritativeAt = v175
                        v176.authoritativeTime = v174.serverTime
                    end
                end
            end
        end
    elseif v173 == "PredictionResult" and type(v174) == "table" then
        local v177 = v5[v174.requestId]
        if v177 then
            if v174.accepted == true then
                v177.accepted = true
                if v174.item == v177.item then
                    if v177.item == "RocketShoes" then
                        local direction = v174.direction
                        if typeof(direction) == "Vector3" then
                            startRocket(v174.requestId, v177.character, v174.direction)
                        end
                    end
                    local v178 = v4[v174.requestId]
                    if v178 then
                        local direction = v174.direction
                        if typeof(direction) == "Vector3" then
                            v178.direction = v174.direction
                        end
                        local landing = v174.landing
                        if typeof(landing) == "CFrame" then
                            v178.landing = v174.landing
                        end
                        local cf = v174.cf
                        if typeof(cf) == "CFrame" then
                            v178.cf = v174.cf
                        end
                        if not v12[v178.item] then
                            local position = v174.position
                            if typeof(position) == "Vector3" then
                                v178.origin = v174.position
                            end
                        end
                    end
                else
                    local requestId = v174.requestId
                    local v179 = v77
                    if v179 and (not requestId or v179.id == requestId) then
                        v77 = nil
                        v179.velocity:Destroy()
                        v179.attachment:Destroy()
                        v179.velocity = nil
                        v179.attachment = nil
                        if v179.root.Parent and v179.character == LocalPlayer.Character then
                            v179.root.AssemblyLinearVelocity = Vector3.new(0, 1, 0) * v179.root.AssemblyLinearVelocity.Y
                        end
                    end
                    local v180 = v4[v174.requestId]
                    if v180 and v180.item == v177.item then
                        if v180.proxy then
                            v180.proxy:Destroy()
                        end
                        restore(v180)
                        if v4[v180.id] == v180 then
                            v4[v180.id] = nil
                        end
                    end
                    v3.Cancel:Fire({
                        character = v177.character,
                        item = v177.item,
                        requestId = v174.requestId
                    })
                    v177.item = v174.item
                    v177.emitted = {}
                end
            else
                local requestId = v174.requestId
                local v181 = v77
                if v181 and (not requestId or v181.id == requestId) then
                    v77 = nil
                    v181.velocity:Destroy()
                    v181.attachment:Destroy()
                    v181.velocity = nil
                    v181.attachment = nil
                    if v181.root.Parent and v181.character == LocalPlayer.Character then
                        v181.root.AssemblyLinearVelocity = Vector3.new(0, 1, 0) * v181.root.AssemblyLinearVelocity.Y
                    end
                end
                local v182 = v4[v174.requestId]
                if v182 then
                    if v182.proxy then
                        v182.proxy:Destroy()
                    end
                    restore(v182)
                    if v4[v182.id] == v182 then
                        v4[v182.id] = nil
                    end
                end
                v3.Cancel:Fire({
                    character = v177.character,
                    item = v177.item,
                    requestId = v174.requestId
                })
                v5[v174.requestId] = nil
            end
        end
    end
end)

local function target(v183, v184, v185, v186) -- line 694 | captures: TweenService, v2, v12
    local v187 = v184 - v183.started
    if v183.trail then
        local trail = v183.trail
        local v188 = not v12[v183.item]
        if not v188 then
            if v187 >= 0.18 then
                v188 = v187 < 0.75
            else
                v188 = false
            end
        end
        trail.Enabled = v188
    end
    if v183.server and not (v12[v183.item] or v183.item == "PocketDoor") then
        local server = v183.server
        local v189 = server:IsA("Model") and server:GetPivot() or server.CFrame
        if (v189.Position - v183.serverLast.Position).Magnitude > 0.005 or v189.LookVector:Dot(v183.serverLast.LookVector) < 0.9999 then
            v183.serverLast = v189
            v183.serverChanged = v184
        end
        local serverChanged, v190
        if v183.item == "BowlingBall" then
            serverChanged = v183.serverChanged
            if v183.authoritativeCF and v184 - (v183.authoritativeAt or 0) < 0.25 then
                v190 = v183.authoritativeCF
                serverChanged = v183.authoritativeTime or v183.authoritativeAt
            else
                v190 = v189
            end
        else
            local v191, v192
            if v183.item == "RufusLeash" then
                local v193 = v184 - v183.serverChanged
                local v194 = math.min(0.08, v193) * v183.speed
                local v195 = (v189.Position - v183.origin):Dot(v183.direction)
                local ThrowRange = v2.Items.RufusLeash.ThrowRange
                local v196 = math.clamp(v195, 0, ThrowRange)
                v191 = v189 + (v183.origin + v183.direction * v196 - v189.Position)
                local v197 = v2.Items.RufusLeash.ThrowRange - v196
                v192 = math.min(v194, v197)
                if v192 > 0.001 then
                    local workspace_2 = workspace
                    local Position = v191.Position
                    local v198 = if v183.item == "BowlingBall" then 0.8 else 0.2
                    local v199 = workspace_2:Spherecast(Position, v198, v183.direction * v192, v186)
                    if v199 then
                        local v200 = v199.Distance - 0.03
                        v192 = math.max(0, v200)
                    end
                end
            else
                return v189
            end
            local v201 = v191 + v183.direction * v192
            if v183.item == "BowlingBall" then
                local v202 = workspace:Raycast(v201.Position + Vector3.new(0, 2, 0), Vector3.new(-0, -5, -0, -0), v186)
                if v202 then
                    v201 += Vector3.new(0, 1, 0) * (v202.Position.Y + 1.05 - v201.Position.Y)
                end
            end
            return v201
        end
        local v203 = v184 - serverChanged
        local v204 = math.clamp(v203, 0, 0.25) * v183.speed
        if v204 > 0.001 then
            local v205 = workspace:Spherecast(v190.Position, 0.8, v183.direction * v204, v186)
            if v205 then
                local v206 = v205.Distance - 0.03
                v204 = math.max(0, v206)
            end
        end
        local v207 = v190.Position + v183.direction * v204
        local v208 = workspace:Raycast(v207 + Vector3.new(0, 2, 0), Vector3.new(-0, -5, -0, -0), v186)
        if v208 then
            local X = v207.X
            local v209 = v208.Position.Y + 1.05
            local Z = v207.Z
            v207 = Vector3.new(X, v209, Z)
        end
        return CFrame.lookAt(v207, v207 + v183.direction) * CFrame.Angles(-(v207 - v183.origin):Dot(v183.direction), 0, 0)
    end
    if v12[v183.item] and v183.landing then
        if v183.server and v187 < 0.18 then
            local server = v183.server
            v183.origin = (server:IsA("Model") and server:GetPivot() or server.CFrame).Position
        end
        if v187 < 0.18 then
            if v183.hand and v183.hand.Parent then
                v183.origin = v183.hand.Position - v183.hand.CFrame.UpVector * v183.hand.Size.Y * 0.35
            end
        else
            local v210 = (v187 - 0.18) / 0.57
            local v211 = math.clamp(v210, 0, 1)
            local v212 = v183.origin:Lerp(v183.landing.Position, v211) + Vector3.new(0, 1, 0) * (v211 * 14 * (1 - v211))
            local v213 = CFrame.new(v212) * v183.landing.Rotation
            local Angles = CFrame.Angles
            local v214 = -12.566370614359172 * (1 - v211)
            local v215 = v211 * 3.141592653589793
            return v213 * Angles(v214, 0, math.sin(v215) * 0.4)
        end
        return CFrame.new(v183.origin)
    end
    if v183.item == "PocketDoor" and v183.cf then
        if not (v183.server and v187 >= 0.2) then
            local v216 = v187 / 0.2
            local v217 = TweenService:GetValue(math.clamp(v216, 0, 1), Enum.EasingStyle.Back, Enum.EasingDirection.Out)
            return (v183.cf * CFrame.new(-2.6, 0, 0) * CFrame.Angles(0, 1.3962634015954636, 0) * CFrame.new(2.6, 0, 0)):Lerp(v183.cf, v217)
        end
        if v183.predicted and v184 - (v183.serverStarted or v183.started) < 0.2 then
            return v183.cf
        end
        local server = v183.server
        return server:IsA("Model") and server:GetPivot() or server.CFrame
    end
    local v218 = v183.speed * v185
    if v183.item == "RufusLeash" then
        local v219 = (v183.position - v183.origin):Dot(v183.direction)
        local ThrowRange = v2.Items.RufusLeash.ThrowRange
        v183.distance = math.clamp(v219, 0, ThrowRange)
        v183.position = v183.origin + v183.direction * v183.distance
        local v220 = v2.Items.RufusLeash.ThrowRange - v183.distance
        local v221 = math.max(0, v220)
        v218 = math.min(v218, v221)
    end
    local v222 = v183.direction * v218
    if not (v218 > 0 and workspace:Raycast(v183.position, v222, v186)) then
        v183.position += v222
        v183.distance += v222.Magnitude
        if v183.item == "RufusLeash" then
            local distance = v183.distance
            local ThrowRange = v2.Items.RufusLeash.ThrowRange
            v183.distance = math.min(distance, ThrowRange)
            v183.position = v183.origin + v183.direction * v183.distance
        end
    end
    if v183.item == "BowlingBall" then
        local v223 = workspace:Raycast(v183.position + Vector3.new(0, 2, 0), Vector3.new(-0, -5, -0, -0), v186)
        if v223 then
            local X = v183.position.X
            local v224 = v223.Position.Y + 1.05
            local Z = v183.position.Z
            v183.position = Vector3.new(X, v224, Z)
        end
    end
    return CFrame.lookAt(v183.position, v183.position + v183.direction) * (v183.item == "BowlingBall" and CFrame.Angles(-v183.distance, 0, 0) or CFrame.identity)
end

RunService.RenderStepped:Connect(function(v225) -- line 810 | captures: v77, v78, LocalPlayer, GearEvent, v2, v3, v4, v5, v7, v8, params, restore, settleRocket, target
    local v226 = workspace:GetServerTimeNow()
    settleRocket(v226)
    local v227 = v77
    if v227 then
        if v227.character:GetAttribute("GearMotion") == true then
            v227.flag = v227.flag or "Set"
        elseif v227.flag == "Set" then
            v227.flag = "Cleared"
        end
        local v228 = v227.direction * (math.min(v225, 0.08) * 64 + 1.5)
        local v229 = workspace:Spherecast(v227.root.Position, 1.1, v228, (params()))
        v227.velocity.PlaneVelocity = v229 and Vector2.zero or Vector2.new(v227.direction.X, v227.direction.Z) * 64
    end
    local v230 = v78
    if v230 then
        if v230.carryEnds <= v226 or not (v230.character == LocalPlayer.Character) then
            v78 = nil
        elseif v230.character:GetAttribute("GearMotion") == true then
            v230.flag = v230.flag or "Set"
        elseif v230.flag == "Set" then
            v230.flag = "Cleared"
        end
    end
    local v231 = next(v4) and params() or nil
    for v232, v233 in v4 do
        if v233.proxy.Parent then
            if v233.server then
                if v233.server:IsDescendantOf(workspace) then
                    if v233.server then
                        local v234 = target(v233, v226, math.min(v225, 0.1), v231)
                        if v233.item == "BowlingBall" and v233.server then
                            local v235 = v233.display.Position - (v233.ballTarget or v234).Position
                            v233.ballTarget = v234
                            local v236
                            if v235.Magnitude > 6 then
                                v236 = Vector3.new(0, 0, 0)
                            else
                                local v237 = -18 * v225
                                v236 = v235 * math.exp(v237)
                            end
                            v233.display = v234 + v236
                        else
                            if v233.server then
                                local display = v233.display
                                local v238 = -30 * v225
                                v234 = display:Lerp(v234, 1 - math.exp(v238)) or v234
                            end
                            v233.display = v234
                        end
                        if v233.item == "RufusLeash" then
                            local v239 = (v233.display.Position - v233.origin):Dot(v233.direction)
                            local ThrowRange = v2.Items.RufusLeash.ThrowRange
                            local v240 = math.clamp(v239, 0, ThrowRange)
                            v233.display += v233.origin + v233.direction * v240 - v233.display.Position
                        end
                        local proxy = v233.proxy
                        local display = v233.display
                        if proxy:IsA("Model") then
                            proxy:PivotTo(display)
                        else
                            proxy.CFrame = display
                        end
                        if v233.item == "BowlingBall" and LocalPlayer:GetAttribute("InMatch") and LocalPlayer:GetAttribute("GameRole") == "Runner" then
                            local Character = LocalPlayer.Character
                            Character = Character and Character:FindFirstChild("HumanoidRootPart")
                            local Position = v233.authoritativeCF and v233.authoritativeCF.Position or v233.display.Position
                            if Character then
                                local v241 = Character.Position.Y - Position.Y
                                if math.abs(v241) <= 5.5 then
                                    local X = Character.Position.X
                                    local Z = Character.Position.Z
                                    local v242 = Vector3.new(X, 0, Z)
                                    local X_2 = Position.X
                                    local Z_2 = Position.Z
                                    if (v242 - Vector3.new(X_2, 0, Z_2)).Magnitude <= 3.4 and v226 - (v233.lastHitReport or (-1/0)) >= 0.16 then
                                        v233.lastHitReport = v226
                                        GearEvent:FireServer("BowlingHitReport", v233.id, Character.Position, nil, v233.authoritativeTime or v226)
                                    end
                                end
                            end
                        end
                    else
                        local v243 = v226 - v233.started
                        local duration = v233.duration
                        if math.min(duration, 3) < v243 then
                            if v233.proxy then
                                v233.proxy:Destroy()
                            end
                            restore(v233)
                            if v4[v233.id] == v233 then
                                v4[v233.id] = nil
                            end
                        else
                            local v244 = target(v233, v226, math.min(v225, 0.1), v231)
                            if v233.item == "BowlingBall" and v233.server then
                                local v245 = v233.display.Position - (v233.ballTarget or v244).Position
                                v233.ballTarget = v244
                                local v246
                                if v245.Magnitude > 6 then
                                    v246 = Vector3.new(0, 0, 0)
                                else
                                    local v247 = -18 * v225
                                    v246 = v245 * math.exp(v247)
                                end
                                v233.display = v244 + v246
                            else
                                if v233.server then
                                    local display = v233.display
                                    local v248 = -30 * v225
                                    v244 = display:Lerp(v244, 1 - math.exp(v248)) or v244
                                end
                                v233.display = v244
                            end
                            if v233.item == "RufusLeash" then
                                local v249 = (v233.display.Position - v233.origin):Dot(v233.direction)
                                local ThrowRange = v2.Items.RufusLeash.ThrowRange
                                local v250 = math.clamp(v249, 0, ThrowRange)
                                v233.display += v233.origin + v233.direction * v250 - v233.display.Position
                            end
                            local proxy = v233.proxy
                            local display = v233.display
                            if proxy:IsA("Model") then
                                proxy:PivotTo(display)
                            else
                                proxy.CFrame = display
                            end
                            if v233.item == "BowlingBall" and LocalPlayer:GetAttribute("InMatch") and LocalPlayer:GetAttribute("GameRole") == "Runner" then
                                local Character = LocalPlayer.Character
                                Character = Character and Character:FindFirstChild("HumanoidRootPart")
                                local Position = v233.authoritativeCF and v233.authoritativeCF.Position or v233.display.Position
                                if Character then
                                    local v251 = Character.Position.Y - Position.Y
                                    if math.abs(v251) <= 5.5 then
                                        local X = Character.Position.X
                                        local Z = Character.Position.Z
                                        local v252 = Vector3.new(X, 0, Z)
                                        local X_2 = Position.X
                                        local Z_2 = Position.Z
                                        if (v252 - Vector3.new(X_2, 0, Z_2)).Magnitude <= 3.4 and v226 - (v233.lastHitReport or (-1/0)) >= 0.16 then
                                            v233.lastHitReport = v226
                                            GearEvent:FireServer("BowlingHitReport", v233.id, Character.Position, nil, v233.authoritativeTime or v226)
                                        end
                                    end
                                end
                            end
                        end
                    end
                else
                    if v233.proxy then
                        v233.proxy:Destroy()
                    end
                    restore(v233)
                    if v4[v233.id] == v233 then
                        v4[v233.id] = nil
                    end
                end
            elseif v233.server then
                local v253 = target(v233, v226, math.min(v225, 0.1), v231)
                if v233.item == "BowlingBall" and v233.server then
                    local v254 = v233.display.Position - (v233.ballTarget or v253).Position
                    v233.ballTarget = v253
                    local v255
                    if v254.Magnitude > 6 then
                        v255 = Vector3.new(0, 0, 0)
                    else
                        local v256 = -18 * v225
                        v255 = v254 * math.exp(v256)
                    end
                    v233.display = v253 + v255
                else
                    if v233.server then
                        local display = v233.display
                        local v257 = -30 * v225
                        v253 = display:Lerp(v253, 1 - math.exp(v257)) or v253
                    end
                    v233.display = v253
                end
                if v233.item == "RufusLeash" then
                    local v258 = (v233.display.Position - v233.origin):Dot(v233.direction)
                    local ThrowRange = v2.Items.RufusLeash.ThrowRange
                    local v259 = math.clamp(v258, 0, ThrowRange)
                    v233.display += v233.origin + v233.direction * v259 - v233.display.Position
                end
                local proxy = v233.proxy
                local display = v233.display
                if proxy:IsA("Model") then
                    proxy:PivotTo(display)
                else
                    proxy.CFrame = display
                end
                if v233.item == "BowlingBall" and LocalPlayer:GetAttribute("InMatch") and LocalPlayer:GetAttribute("GameRole") == "Runner" then
                    local Character = LocalPlayer.Character
                    Character = Character and Character:FindFirstChild("HumanoidRootPart")
                    local Position = v233.authoritativeCF and v233.authoritativeCF.Position or v233.display.Position
                    if Character then
                        local v260 = Character.Position.Y - Position.Y
                        if math.abs(v260) <= 5.5 then
                            local X = Character.Position.X
                            local Z = Character.Position.Z
                            local v261 = Vector3.new(X, 0, Z)
                            local X_2 = Position.X
                            local Z_2 = Position.Z
                            if (v261 - Vector3.new(X_2, 0, Z_2)).Magnitude <= 3.4 and v226 - (v233.lastHitReport or (-1/0)) >= 0.16 then
                                v233.lastHitReport = v226
                                GearEvent:FireServer("BowlingHitReport", v233.id, Character.Position, nil, v233.authoritativeTime or v226)
                            end
                        end
                    end
                end
            else
                local v262 = v226 - v233.started
                local duration = v233.duration
                if math.min(duration, 3) < v262 then
                    if v233.proxy then
                        v233.proxy:Destroy()
                    end
                    restore(v233)
                    if v4[v233.id] == v233 then
                        v4[v233.id] = nil
                    end
                else
                    local v263 = target(v233, v226, math.min(v225, 0.1), v231)
                    if v233.item == "BowlingBall" and v233.server then
                        local v264 = v233.display.Position - (v233.ballTarget or v263).Position
                        v233.ballTarget = v263
                        local v265
                        if v264.Magnitude > 6 then
                            v265 = Vector3.new(0, 0, 0)
                        else
                            local v266 = -18 * v225
                            v265 = v264 * math.exp(v266)
                        end
                        v233.display = v263 + v265
                    else
                        if v233.server then
                            local display = v233.display
                            local v267 = -30 * v225
                            v263 = display:Lerp(v263, 1 - math.exp(v267)) or v263
                        end
                        v233.display = v263
                    end
                    if v233.item == "RufusLeash" then
                        local v268 = (v233.display.Position - v233.origin):Dot(v233.direction)
                        local ThrowRange = v2.Items.RufusLeash.ThrowRange
                        local v269 = math.clamp(v268, 0, ThrowRange)
                        v233.display += v233.origin + v233.direction * v269 - v233.display.Position
                    end
                    local proxy = v233.proxy
                    local display = v233.display
                    if proxy:IsA("Model") then
                        proxy:PivotTo(display)
                    else
                        proxy.CFrame = display
                    end
                    if v233.item == "BowlingBall" and LocalPlayer:GetAttribute("InMatch") and LocalPlayer:GetAttribute("GameRole") == "Runner" then
                        local Character = LocalPlayer.Character
                        Character = Character and Character:FindFirstChild("HumanoidRootPart")
                        local Position = v233.authoritativeCF and v233.authoritativeCF.Position or v233.display.Position
                        if Character then
                            local v270 = Character.Position.Y - Position.Y
                            if math.abs(v270) <= 5.5 then
                                local X = Character.Position.X
                                local Z = Character.Position.Z
                                local v271 = Vector3.new(X, 0, Z)
                                local X_2 = Position.X
                                local Z_2 = Position.Z
                                if (v271 - Vector3.new(X_2, 0, Z_2)).Magnitude <= 3.4 and v226 - (v233.lastHitReport or (-1/0)) >= 0.16 then
                                    v233.lastHitReport = v226
                                    GearEvent:FireServer("BowlingHitReport", v233.id, Character.Position, nil, v233.authoritativeTime or v226)
                                end
                            end
                        end
                    end
                end
            end
        else
            if v233.proxy then
                v233.proxy:Destroy()
            end
            restore(v233)
            if v4[v233.id] == v233 then
                v4[v233.id] = nil
            end
        end
    end
    for v272, v273 in v7 do
        if v226 - v273.received > 4 then
            v7[v272] = nil
        end
    end
    for v274, v275 in v8 do
        if v226 - v275.started > 90 then
            v8[v274] = nil
        end
    end
    for v276, v277 in v5 do
        if v277.accepted then
            if v226 - v277.started > 20 then
                v5[v276] = nil
            end
        elseif v226 - v277.started > 3 then
            v3.Cancel:Fire({
                character = v277.character,
                item = v277.item,
                requestId = v276
            })
            local v278 = v4[v276]
            if v278 and not v278.server then
                if v278.proxy then
                    v278.proxy:Destroy()
                end
                restore(v278)
                if v4[v278.id] == v278 then
                    v4[v278.id] = nil
                end
            end
            v5[v276] = nil
        elseif v226 - v277.started > 20 then
            v5[v276] = nil
        end
    end
end)
LocalPlayer.CharacterRemoving:Connect(function() -- line 899 | captures: v78, v3, v4, v5, restore
    v78 = nil
    for v279, v280 in v4 do
        if v5[v280.id] then
            if v280.proxy then
                v280.proxy:Destroy()
            end
            restore(v280)
            if v4[v280.id] == v280 then
                v4[v280.id] = nil
            end
        end
    end
    for v281, v282 in v5 do
        v3.Cancel:Fire({
            character = v282.character,
            item = v282.item,
            requestId = v281
        })
    end
    table.clear(v5)
end)
return v3
