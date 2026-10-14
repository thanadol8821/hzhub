-- https://sitetest1.lua.expert

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ChickenOrHero = game.ReplicatedStorage:WaitForChild("ChickenOrHero")
local Animation = ChickenOrHero:WaitForChild("Animation")
local AnimationConfig = require(Animation.AnimationConfig)
local AnimationPolicy = require(Animation.AnimationPolicy)
local StopAnimationPolicy = require(Animation.StopAnimationPolicy)
local DashAnimation = require(Animation.DashAnimation)
local DashAnimationPolicy = require(Animation.DashAnimationPolicy)
local LocomotionTracks = require(Animation.LocomotionTracks)
local AnimationLibrary = require(Animation.AnimationLibrary)
local MovementProfiles = require(ChickenOrHero.Movement.MovementProfiles)
local v1 = require(game.ReplicatedFirst:WaitForChild("FFlags"))
local v2 = {}
local v3

if v1.LocalLocomotion == true and AnimationConfig.Enabled == true then
    v3 = RunService:IsClient()
else
    v3 = false
end
v2.enabled = v3

local v4 = { "HumanoidRootPart", "Torso", "Head", "Left Arm", "Right Arm", "Left Leg", "Right Leg" }
local v5 = {
    Stop = true,
    Land = true
}
local v6 = {}
local v7 = 0
local v8 = -1
local v9
local LocalPlayer = Players.LocalPlayer
local v10 = {}
for v11, v12 in {
        "Idle",
        "Walk",
        "Run",
        "Left",
        "Right",
        "Back",
        "Fall",
        "Stop",
        "Land",
        "CaughtIdle"
    } do
    local v13 = AnimationConfig.PublishedIds[v12]
    if v13 then
        v10[v13] = true
    end
end

local function isAction(v14) -- line 41 | captures: v10
    if v14.Priority == Enum.AnimationPriority.Core or v14.Priority == Enum.AnimationPriority.Idle then
        return false
    end
    return not (v14.Animation and v10[v14.Animation.AnimationId])
end

local function rigFolder() -- line 47 | captures: v9
    if not (v9 and v9.Parent) then
        v9 = Instance.new("Folder")
        v9.Name = "LocalLocomotionRigs"
        v9.Parent = workspace
    end
    return v9
end

local function buildProxy(v15) -- line 57 | captures: v9, v4
    local v16 = {}
    local Model = Instance.new("Model")
    Model.Name = "Proxy"
    for v17, v18 in v4 do
        local v19 = v15:FindFirstChild(v18)
        if v19 and v19:IsA("BasePart") then
            local Part = Instance.new("Part")
            Part.Name = v18
            Part.Size = v19.Size
            Part.Transparency = 1
            Part.CanCollide = false
            Part.CanQuery = false
            Part.CanTouch = false
            Part.CastShadow = false
            Part.Massless = true
            Part.Anchored = v18 == "HumanoidRootPart"
            Part.CFrame = v19.CFrame
            Part.Parent = Model
            v16[v18] = Part
        else
            Model:Destroy()
            return nil
        end
    end
    local v20 = {}
    for v21, v22 in {
            v15.HumanoidRootPart,
            v15.Torso
        } do
        for v23, v24 in v22:GetChildren() do
            if v24:IsA("Motor6D") and v24.Part0 and v24.Part1 and v16[v24.Part0.Name] and v16[v24.Part1.Name] then
                local Motor6D = Instance.new("Motor6D")
                Motor6D.Name = v24.Name
                Motor6D.C0 = v24.C0
                Motor6D.C1 = v24.C1
                Motor6D.Part0 = v16[v24.Part0.Name]
                Motor6D.Part1 = v16[v24.Part1.Name]
                Motor6D.Parent = v16[v24.Part0.Name]
                local v25 = {
                    real = v24,
                    fake = Motor6D
                }
                table.insert(v20, v25)
            end
        end
    end
    local AnimationController = Instance.new("AnimationController")
    AnimationController.Parent = Model
    local Animator = Instance.new("Animator")
    Animator.Parent = AnimationController
    Model.PrimaryPart = v16.HumanoidRootPart
    if v9 then
        if not v9.Parent then
            v9 = Instance.new("Folder")
            v9.Name = "LocalLocomotionRigs"
            v9.Parent = workspace
        end
    else
        v9 = Instance.new("Folder")
        v9.Name = "LocalLocomotionRigs"
        v9.Parent = workspace
    end
    Model.Parent = v9
    return Model, Animator, v20, v16.HumanoidRootPart
end

local function remove(v26) -- line 105 | captures: DashAnimation, v6
    local v27 = v6[v26]
    if not v27 then
        return
    end
    v6[v26] = nil
    if v27.played then
        v27.played:Disconnect()
    end
    table.clear(v27.actions)
    DashAnimation.release(v26)
    v27.loader:destroy()
    v27.proxy:Destroy()
    if not (v27.own and v26.Parent) then
        return
    end
    v26:SetAttribute("AnimationPackActive", nil)
    v26:SetAttribute("AnimationPackLoading", nil)
    v26:SetAttribute("AnimationAction", nil)
end

local function add(v28, v29) -- line 125 | captures: StopAnimationPolicy, LocomotionTracks, AnimationLibrary, v6, LocalPlayer, buildProxy
    local Humanoid = v29:FindFirstChildOfClass("Humanoid")
    local HumanoidRootPart = v29:FindFirstChild("HumanoidRootPart")
    local Torso = v29:FindFirstChild("Torso")
    if not Humanoid or not (Humanoid.RigType == Enum.HumanoidRigType.R6) or Humanoid.Health <= 0 or not HumanoidRootPart or not Torso then
        return
    end
    for v30, v31 in { "Neck", "Left Shoulder", "Right Shoulder", "Left Hip", "Right Hip" } do
        if not Torso:FindFirstChild(v31) then
            return
        end
    end
    if HumanoidRootPart:FindFirstChild("RootJoint") then
        local v32, v33, v34, v35 = buildProxy(v29)
        if v32 then
            local v36 = RaycastParams.new()
            v36.FilterType = Enum.RaycastFilterType.Exclude
            v36.FilterDescendantsInstances = { v29 }
            v36.RespectCanCollide = true
            local v37 = {
                cyclePhase = 0,
                airTime = 0,
                wasGrounded = true,
                actionEnd = 0,
                player = v28,
                character = v29,
                humanoid = Humanoid,
                root = HumanoidRootPart
            }
            v37.own = v28 == LocalPlayer
            v37.proxy = v32
            v37.proxyRoot = v35
            v37.animator = v33
            v37.joints = v34
            v37.loader = LocomotionTracks.new(v33, AnimationLibrary.prepare())
            v37.sent = {}
            v37.actions = {}
            v37.params = v36
            v37.stopState = StopAnimationPolicy.new()
            v37.version = v29:GetAttribute("MovementReset")
            if v37.own then
                v37.dashSignal = v29:GetAttribute("DashAnimationSequence") or 0
            else
                v37.dashSignal = v29:GetAttribute("BoostEffectAt")
            end
            v6[v29] = v37
            v37.loader:refresh(os.clock())
        end
    end
end

local function watchActions(v38) -- line 176 | captures: v10
    local Animator = v38.humanoid:FindFirstChildOfClass("Animator")
    if not Animator then
        return
    end
    v38.realAnimator = Animator
    local AnimationPlayed = Animator.AnimationPlayed
    v38.played = AnimationPlayed:Connect(function(v39) -- line 182 | captures: v38, v10
        if not (v39.Priority == Enum.AnimationPriority.Core or v39.Priority == Enum.AnimationPriority.Idle) and not (v39.Animation and v10[v39.Animation.AnimationId]) then
            v38.actions[v39] = true
        end
    end)
    for v40, v41 in Animator:GetPlayingAnimationTracks() do
        if not (v41.Priority == Enum.AnimationPriority.Core or v41.Priority == Enum.AnimationPriority.Idle) and not (v41.Animation and v10[v41.Animation.AnimationId]) then
            v38.actions[v41] = true
        end
    end
end

local function endAction(v42) -- line 194 | captures: AnimationConfig
    local actionName = v42.actionName
    local v43 = actionName and v42.loader.tracks[actionName]
    if v43 then
        v43:Stop(actionName == "Stop" and AnimationConfig.Stop.FadeOut or 0.08)
    end
    v42.actionName = nil
    if v42.own then
        v42.character:SetAttribute("AnimationAction", nil)
    end
end

local function startAction(v44, v45, v46, v47, v48) -- line 205 | captures: AnimationConfig, LocomotionTracks
    local v49 = v44.loader.tracks[v45]
    if not LocomotionTracks.ready(v49) then
        return
    end
    local actionName = v44.actionName
    local v50 = actionName and v44.loader.tracks[actionName]
    if v50 then
        v50:Stop(actionName == "Stop" and AnimationConfig.Stop.FadeOut or 0.08)
    end
    v44.actionName = nil
    if v44.own then
        v44.character:SetAttribute("AnimationAction", nil)
    end
    v44.actionName = v45
    v44.actionEnd = os.clock() + v46
    if v44.own then
        v44.character:SetAttribute("AnimationAction", v45)
    end
    v49:Play(v45 == "Stop" and AnimationConfig.Stop.FadeIn or 0.07, v48 or 1, (v47 or v49.Length) / math.max(v46, 0.05))
    v49.TimePosition = 0
end

local function remoteMode(v51, v52, v53, v54) -- line 221
    local v55 = v51.smoothSpeed or v52
    local v56 = v52 - v55
    local v57 = -15 * v53
    local v58 = v55 + v56 * (1 - math.exp(v57))
    local v59 = (v58 - v55) / math.max(v53, 0.001)
    v51.smoothSpeed = v58
    if v58 < 0.5 then
        v51.brakeFrames = 0
        v51.mode = "Idle"
    elseif v59 < -(v54.Deceleration or 60) * 0.4 then
        v51.brakeFrames = (v51.brakeFrames or 0) + 1
        if v51.brakeFrames >= 3 and v51.mode ~= "Braking" then
            v51.entrySpeed = v51.peakSpeed or v58
            v51.mode = "Braking"
        end
    else
        v51.brakeFrames = 0
        local v60, v61
        if v51.mode == "Braking" then
            if v59 > -1 then
                if v54.MaxSpeed * 0.97 <= v58 then
                    v60 = "Running"
                else
                    v60 = "Accelerating"
                end
                v61 = false
            else
                v61 = true
            end
        else
            if v54.MaxSpeed * 0.97 <= v58 then
                v60 = "Running"
            else
                v60 = "Accelerating"
            end
            v61 = false
        end
        if not v61 then
            v51.mode = v60
        end
    end
    if v51.mode ~= "Braking" then
        v51.peakSpeed = v58
    end
    return v51.mode
end

local function remoteVelocity(v62, v63) -- line 250
    local Position = v62.root.Position
    local lastPosition = v62.lastPosition
    v62.lastPosition = Position
    if not lastPosition or v63 <= 0 then
        local velocity = v62.velocity
        local v64 = Vector3.new(0, 0, 0)
        return velocity or v64
    end
    local v65 = (Position - lastPosition) / v63
    if v65.Magnitude > 150 then
        v62.velocity = Vector3.new(0, 0, 0)
    else
        local v66 = v62.velocity or v65
        local v67 = -20 * v63
        v62.velocity = v66:Lerp(v65, 1 - math.exp(v67))
    end
    return v62.velocity
end

local function remoteGrounded(v68) -- line 267
    local v69 = workspace:Raycast(v68.root.Position, Vector3.new(0, -5, 0), v68.params)
    if v69 == nil then
        return false
    end
    return v68.root.Position.Y - v69.Position.Y <= 4
end

local function step(v70, v71, v72) -- line 273 | captures: AnimationConfig, AnimationPolicy, StopAnimationPolicy, DashAnimation, DashAnimationPolicy, LocomotionTracks, MovementProfiles, v5, startAction, remoteMode, remoteVelocity
    local character = v70.character
    local humanoid = v70.humanoid
    local root = v70.root
    local player = v70.player
    local loader = v70.loader
    local tracks = loader.tracks
    loader:refresh(v72)
    local v73 = loader:coreReady()
    if v70.own then
        if character:GetAttribute("AnimationPackActive") ~= v73 then
            character:SetAttribute("AnimationPackActive", v73)
        end
        if character:GetAttribute("AnimationPackLoading") == v73 then
            character:SetAttribute("AnimationPackLoading", not v73)
        end
    end
    v70.proxyRoot.CFrame = root.CFrame
    local v74 = MovementProfiles.get(player:GetAttribute("GameRole"), player)
    local v75
    if v70.own then
        v75 = root.AssemblyLinearVelocity
    else
        v75 = remoteVelocity(v70, v71)
    end
    local v76 = v75 * Vector3.new(1, 0, 1)
    local Magnitude = v76.Magnitude
    local v77
    if v70.own then
        v77 = humanoid.FloorMaterial ~= Enum.Material.Air
    else
        local v78 = workspace:Raycast(v70.root.Position, Vector3.new(0, -5, 0), v70.params)
        if v78 == nil then
            v77 = false
        else
            v77 = v70.root.Position.Y - v78.Position.Y <= 4
        end
    end
    local v79 = root.Anchored or character:GetAttribute("MovementLocked") == true
    local v80 = character:GetAttribute("TackleActive") == true
    local v81 = if player:GetAttribute("GameRole") == "Runner" then player:GetAttribute("RunState") == "Caught" else false
    local v82
    if v70.own then
        v82 = character:GetAttribute("MovementState") or "Idle"
    else
        v82 = remoteMode(v70, Magnitude, v71, v74)
    end
    local MovementReset = character:GetAttribute("MovementReset")
    if MovementReset ~= v70.version then
        v70.version = MovementReset
        local actionName = v70.actionName
        local v83 = actionName and v70.loader.tracks[actionName]
        if v83 then
            v83:Stop(actionName == "Stop" and AnimationConfig.Stop.FadeOut or 0.08)
        end
        v70.actionName = nil
        if v70.own then
            v70.character:SetAttribute("AnimationAction", nil)
        end
        DashAnimation.stop(character)
        v70.stopState = StopAnimationPolicy.new()
        v70.airTime = 0
        v70.wasGrounded = v77
    end
    local v84 = v77 and not v79 and not v80 and not v81 and not humanoid.Sit and not humanoid.PlatformStand and v74.Dash.Enabled
    if not v84 then
        DashAnimation.stop(character)
    end
    local v85
    if v70.own then
        v85 = character:GetAttribute("DashAnimationSequence") or 0
    else
        v85 = character:GetAttribute("BoostEffectAt")
    end
    if v85 ~= v70.dashSignal then
        v70.dashSignal = v85
        if v84 and (not v70.own or v82 == "Boosting" or v82 == "Dashing") then
            local actionName = v70.actionName
            local v86 = actionName and v70.loader.tracks[actionName]
            if v86 then
                v86:Stop(actionName == "Stop" and AnimationConfig.Stop.FadeOut or 0.08)
            end
            v70.actionName = nil
            if v70.own then
                v70.character:SetAttribute("AnimationAction", nil)
            end
            if v70.own then
                DashAnimation.play(character, character:GetAttribute("DashFromDirection"), character:GetAttribute("DashToDirection"), v74.Dash, v70.animator)
            else
                local BoostDashName = character:GetAttribute("BoostDashName")
                if DashAnimationPolicy.isName(BoostDashName) then
                    DashAnimation.playNamed(character, BoostDashName, character:GetAttribute("DashVisualFacing"), v74.Dash, v70.animator)
                end
            end
        end
    end
    local v87 = DashAnimation.isActive(character)
    if v87 and not v70.own then
        v82 = "Dashing"
    end
    local v88 = AnimationPolicy.angle(v76, root.CFrame.LookVector * Vector3.new(1, 0, 1))
    local step = StopAnimationPolicy.step
    local stopState = v70.stopState
    local v89 = {
        mode = v82,
        speed = Magnitude
    }
    if v70.own then
        v89.entrySpeed = character:GetAttribute("MovementStopEntrySpeed")
    else
        v89.entrySpeed = v70.entrySpeed
    end
    v89.angle = v88
    v89.allowed = v73 and not v87 and v77 and not v79 and not v80 and not v81 and not humanoid.Sit and not humanoid.PlatformStand
    v89.clipLength = tracks.Stop and tracks.Stop.Length or 0
    v89.now = v72
    local v90 = step(stopState, v89, v71, AnimationConfig.Stop, v74)
    local v91, actionName, v92, v93
    if character:GetAttribute("Ragdolled") then
        v91 = {}
        actionName = v70.actionName
        v92 = actionName and v70.loader.tracks[actionName]
        v93 = false
    elseif v73 then
        v93 = true
    else
        v91 = {}
        actionName = v70.actionName
        v92 = actionName and v70.loader.tracks[actionName]
        v93 = false
    end
    local v94
    if v93 then
        if not v80 and not v79 and not humanoid.Sit and not humanoid.PlatformStand then
            if v81 then
                v94 = tracks.CaughtIdle and tracks.CaughtIdle.Length > 0 and { CaughtIdle = 1 } or { Idle = 1 }
                local actionName = v70.actionName
                local v95 = actionName and v70.loader.tracks[actionName]
                if v95 then
                    v95:Stop(actionName == "Stop" and AnimationConfig.Stop.FadeOut or 0.08)
                end
                v70.actionName = nil
                if v70.own then
                    v70.character:SetAttribute("AnimationAction", nil)
                end
                v70.airTime = 0
            elseif v77 then
                v94 = AnimationPolicy.weights(Magnitude, v88, v74.MaxSpeed, AnimationConfig)
                if v87 then
                    local actionName = v70.actionName
                    local v96 = actionName and v70.loader.tracks[actionName]
                    if v96 then
                        v96:Stop(actionName == "Stop" and AnimationConfig.Stop.FadeOut or 0.08)
                    end
                    v70.actionName = nil
                    if v70.own then
                        v70.character:SetAttribute("AnimationAction", nil)
                    end
                elseif not v70.wasGrounded and v70.airTime > 0.15 and not v80 then
                    startAction(v70, "Land", 0.25)
                elseif v90 then
                    startAction(v70, "Stop", v90.duration, v90.clipEnd, v90.weight)
                end
                v70.airTime = 0
            else
                v70.airTime += v71
                v94 = { Fall = 1 }
                local actionName = v70.actionName
                local v97 = actionName and v70.loader.tracks[actionName]
                if v97 then
                    v97:Stop(actionName == "Stop" and AnimationConfig.Stop.FadeOut or 0.08)
                end
                v70.actionName = nil
                if v70.own then
                    v70.character:SetAttribute("AnimationAction", nil)
                end
            end
        else
            v94 = { Idle = 1 }
            local actionName = v70.actionName
            local v98 = actionName and v70.loader.tracks[actionName]
            if v98 then
                v98:Stop(actionName == "Stop" and AnimationConfig.Stop.FadeOut or 0.08)
            end
            v70.actionName = nil
            if v70.own then
                v70.character:SetAttribute("AnimationAction", nil)
            end
        end
    else
        if v92 then
            v92:Stop(actionName == "Stop" and AnimationConfig.Stop.FadeOut or 0.08)
        end
        v70.actionName = nil
        if v70.own then
            v70.character:SetAttribute("AnimationAction", nil)
        end
        v94 = v91
    end
    local actionName_2 = v70.actionName
    if actionName_2 and not (not (v70.actionEnd <= v72) and not v80 and (actionName_2 ~= "Stop" or v82 == "Braking" or v82 == "Idle")) then
        local actionName = v70.actionName
        local v99 = actionName and v70.loader.tracks[actionName]
        if v99 then
            v99:Stop(actionName == "Stop" and AnimationConfig.Stop.FadeOut or 0.08)
        end
        v70.actionName = nil
        if v70.own then
            v70.character:SetAttribute("AnimationAction", nil)
        end
    end
    local v100 = loader:weights(v94)
    local v101 = (Magnitude / v74.MaxSpeed - AnimationConfig.RunBlendStart) / (AnimationConfig.RunBlendEnd - AnimationConfig.RunBlendStart)
    local v102 = math.clamp(v101, 0, 1)
    local assets = loader.assets
    local v103 = AnimationConfig.WalkReferenceSpeed * (1 - v102) + AnimationConfig.RunReferenceSpeed * assets.Run.length * v102
    local v104 = Magnitude / math.max(v103, 1)
    local v105 = math.clamp(v104, 0.25, 3)
    v70.cyclePhase = (v70.cyclePhase + v105 * v71) % 1
    for v106, v107 in tracks do
        if not v5[v106] and LocomotionTracks.ready(v107) then
            local v108 = v100[v106] or 0
            local FadeTime = v106 == "CaughtIdle" and AnimationConfig.CaughtIdle.FadeTime or AnimationConfig.FadeTime
            local v109
            if v106 == "CaughtIdle" then
                v109 = AnimationConfig.CaughtIdle.PlaybackRate
            elseif v106 == "Idle" or v106 == "Fall" then
                v109 = 1
            elseif v106 == "Walk" or v106 == "Run" then
                local Length = v107.Length
                v109 = v105 * math.max(Length, 0.1)
            else
                local v110 = Magnitude / AnimationConfig.DirectionalReferenceSpeed
                v109 = math.clamp(v110, 0.5, 2.2)
            end
            local v111 = v70.sent[v106]
            if v108 > 0.001 then
                if v107.IsPlaying then
                    if v111 then
                        if v111.weight <= 0.001 then
                            v107:Play(FadeTime, v108, v109)
                            if v106 ~= "Idle" and v106 ~= "Fall" and v106 ~= "CaughtIdle" then
                                v107.TimePosition = v70.cyclePhase * v107.Length
                            end
                            v111.weight = v108
                            v111.rate = v109
                        else
                            local v112 = v111.weight - v108
                            if math.abs(v112) > 0.02 then
                                v107:AdjustWeight(v108, FadeTime)
                                v111.weight = v108
                            end
                            local v113 = v111.rate - v109
                            local v114 = math.abs(v113)
                            if v109 * 0.02 < v114 then
                                v107:AdjustSpeed(v109)
                                v111.rate = v109
                            end
                        end
                    else
                        v107:Play(FadeTime, v108, v109)
                        if v106 ~= "Idle" and v106 ~= "Fall" and v106 ~= "CaughtIdle" then
                            v107.TimePosition = v70.cyclePhase * v107.Length
                        end
                        v70.sent[v106] = {
                            weight = v108,
                            rate = v109
                        }
                    end
                else
                    v107:Play(FadeTime, v108, v109)
                    if v106 ~= "Idle" and v106 ~= "Fall" and v106 ~= "CaughtIdle" then
                        v107.TimePosition = v70.cyclePhase * v107.Length
                    end
                    if v111 then
                        v111.weight = v108
                        v111.rate = v109
                    else
                        v70.sent[v106] = {
                            weight = v108,
                            rate = v109
                        }
                    end
                end
            elseif v111 and v111.weight > 0.001 then
                v107:Stop(FadeTime)
                v111.weight = 0
            end
        end
    end
    v70.wasGrounded = v77
end

function v2.step(v115) -- line 448 | captures: v7, v2, v6, remove, watchActions, step
    v7 += 1
    local v116 = math.min(v115, 0.1)
    local v117 = os.clock()
    for v118, v119 in v6 do
        if v118:IsDescendantOf(workspace) and v119.root.Parent == v118 then
            if v119.humanoid.Health <= 0 then
                remove(v118)
            else
                if not v119.realAnimator then
                    watchActions(v119)
                end
                local v120, v121 = pcall(step, v119, v116, v117)
                if not v120 then
                    local v122 = os.clock()
                    if (v2.warnAt or 0) <= v122 then
                        v2.warnAt = os.clock() + 10
                        warn("LocalLocomotion:", v121)
                    end
                end
            end
        else
            remove(v118)
        end
    end
end

local function isRest(v123) -- line 468
    if v123.Position.Magnitude > 0.0001 then
        return false
    end
    local v124, v125 = v123:ToAxisAngle()
    return math.abs(v125) < 0.001
end

function v2.copy() -- line 477 | captures: v7, v8, v6
    if v8 ~= v7 then
        v8 = v7
        for v126, v127 in v6 do
            local v128 = 0
            for v129 in v127.actions do
                if v129.IsPlaying then
                    local WeightCurrent = v129.WeightCurrent
                    v128 = math.max(v128, WeightCurrent)
                else
                    v127.actions[v129] = nil
                end
            end
            local v130 = math.min(v128, 1)
            for v131, v132 in v127.joints do
                local real = v132.real
                if real.Parent then
                    local Transform = v132.fake.Transform
                    if v130 < 0.02 then
                        real.Transform = Transform
                    else
                        local Transform_2 = real.Transform
                        local v133
                        if Transform_2.Position.Magnitude > 0.0001 then
                            v133 = false
                        else
                            local v134, v135 = Transform_2:ToAxisAngle()
                            v133 = math.abs(v135) < 0.001
                        end
                        if v133 then
                            real.Transform = Transform
                        elseif v130 < 0.98 then
                            real.Transform = Transform:Lerp(CFrame.identity:Lerp(Transform_2, 1 / v130), v130)
                        end
                    end
                end
            end
        end
    end
end

function v2.animatorFor(v136) -- line 514 | captures: v6
    local v137 = v6[v136]
    return v137 and v137.animator
end

function v2.velocityFor(v138) -- line 521 | captures: v6
    local v139 = v6[v138]
    local velocity, v140
    if v139 then
        if v139.own then
            v140 = false
        else
            local velocity_2 = v139.velocity
            if velocity_2 then
                velocity = velocity_2
                v140 = true
            else
                v140 = false
            end
        end
    else
        v140 = false
    end
    if not v140 then
        velocity = nil
    end
    return velocity
end

function v2.start() -- line 526 | captures: Players, RunService, v2, v6, remove, add
    if not v2.enabled or v2.started then
        return
    end
    v2.started = true
    local v141 = 1
    RunService.PreAnimation:Connect(function(v142) -- line 532 | captures: v141, Players, v2, v6, add
        v141 += v142
        if v141 >= 0.5 then
            v141 = 0
            for v143, v144 in Players:GetPlayers() do
                local Character = v144.Character
                if Character and not v6[Character] and Character:IsDescendantOf(workspace) then
                    add(v144, Character)
                end
            end
        end
        v2.step(v142)
    end)
    RunService.PreSimulation:Connect(v2.copy)
    Players.PlayerRemoving:Connect(function(v145) -- line 547 | captures: v6, remove
        for v146, v147 in v6 do
            if v147.player == v145 then
                remove(v146)
            end
        end
    end)
end

return v2
