-- https://sitetest1.lua.expert

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local ChickenOrHero = game.ReplicatedStorage:WaitForChild("ChickenOrHero")
local Game = ChickenOrHero:WaitForChild("Game")
local v1 = require(Game:WaitForChild("RescueConfig"))
local RescueEvent = Game:WaitForChild("RescueEvent")
local Session = Game:WaitForChild("Session")
local v2 = require(ChickenOrHero.Presentation:WaitForChild("ParticipantDirectory"))
local v3 = require(ChickenOrHero.Presentation:WaitForChild("VerifiedName"))
local v4 = require(ChickenOrHero.Movement:WaitForChild("ControlGate"))
local ScreenGui = Instance.new("ScreenGui")

ScreenGui.Name = "RescueStatus"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 24
ScreenGui.IgnoreGuiInset = true
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local TextLabel = Instance.new("TextLabel")

TextLabel.Name = "Status"
TextLabel.AnchorPoint = Vector2.new(0.5, 1)
TextLabel.Position = UDim2.fromScale(0.5, 0.8)
TextLabel.Size = UDim2.fromScale(0.65, 0.065)
TextLabel.BackgroundTransparency = 1
TextLabel.TextColor3 = Color3.fromRGB(245, 243, 231)
TextLabel.Font = Enum.Font.GothamBold
TextLabel.TextScaled = true
TextLabel.TextStrokeTransparency = 0.5
TextLabel.Visible = false
TextLabel.Parent = ScreenGui

local UITextSizeConstraint = Instance.new("UITextSizeConstraint")

UITextSizeConstraint.MinTextSize = 12
UITextSizeConstraint.MaxTextSize = 20
UITextSizeConstraint.Parent = TextLabel

local Frame = Instance.new("Frame")

Frame.Name = "NearbyRescue"
Frame.BackgroundTransparency = 1
Frame.Size = UDim2.fromScale(0.22, 0.1)
Frame.AnchorPoint = Vector2.new(0.5, 1)
Frame.Position = UDim2.fromScale(0.5, 0.78)
Frame.Visible = false
Frame.Parent = ScreenGui

local UISizeConstraint = Instance.new("UISizeConstraint")

UISizeConstraint.MinSize = Vector2.new(180, 60)
UISizeConstraint.MaxSize = Vector2.new(240, 74)
UISizeConstraint.Parent = Frame

local TextButton = Instance.new("TextButton")

TextButton.Name = "Hold"
TextButton.Size = UDim2.fromScale(1, 1)
TextButton.BackgroundColor3 = Color3.fromRGB(12, 27, 30)
TextButton.BackgroundTransparency = 0.16
TextButton.BorderSizePixel = 0
TextButton.Text = ""
TextButton.AutoButtonColor = false
TextButton.Parent = Frame

local UICorner = Instance.new("UICorner")

UICorner.CornerRadius = UDim.new(0, 5)
UICorner.Parent = TextButton

local TextLabel_2 = Instance.new("TextLabel")

TextLabel_2.BackgroundTransparency = 1
TextLabel_2.Position = UDim2.fromScale(0.05, 0.08)
TextLabel_2.Size = UDim2.fromScale(0.9, 0.32)
TextLabel_2.Font = Enum.Font.Gotham
TextLabel_2.TextColor3 = Color3.fromRGB(187, 199, 194)
TextLabel_2.TextSize = 12
TextLabel_2.TextTruncate = Enum.TextTruncate.AtEnd
TextLabel_2.Parent = TextButton

local TextLabel_3 = Instance.new("TextLabel")

TextLabel_3.BackgroundTransparency = 1
TextLabel_3.Position = UDim2.fromScale(0.03, 0.39)
TextLabel_3.Size = UDim2.fromScale(0.94, 0.4)
TextLabel_3.Font = Enum.Font.GothamBold
TextLabel_3.TextSize = 14
TextLabel_3.TextColor3 = Color3.fromRGB(245, 238, 208)
TextLabel_3.Parent = TextButton

local Frame_2 = Instance.new("Frame")

Frame_2.BorderSizePixel = 0
Frame_2.BackgroundColor3 = Color3.fromRGB(85, 100, 96)
Frame_2.BackgroundTransparency = 0.4
Frame_2.Position = UDim2.fromScale(0.04, 0.89)
Frame_2.Size = UDim2.fromScale(0.92, 0.045)
Frame_2.Parent = TextButton

local Frame_3 = Instance.new("Frame")

Frame_3.BorderSizePixel = 0
Frame_3.BackgroundColor3 = Color3.fromRGB(225, 209, 148)
Frame_3.Size = UDim2.fromScale(0, 1)
Frame_3.Parent = Frame_2

local v5 = require(ChickenOrHero.Presentation:WaitForChild("ReviveMarkers")).new(LocalPlayer.PlayerGui)
local v6, v7, v8

local function cancel() -- line 41 | captures: v7, v8, RescueEvent, Frame_3
    if v7 and not v7.sent then
        RescueEvent:FireServer("Cancel", v7.id)
    end
    v7 = nil
    v8 = nil
    Frame_3.Size = UDim2.fromScale(0, 1)
end

local function begin(v9) -- line 45 | captures: v6, v7, v8, RescueEvent, Frame
    if v7 or not v6 or not Frame.Visible then
        return
    end
    v8 = v9
    v7 = {
        id = v6.UserId,
        character = v6.Character,
        started = os.clock()
    }
    RescueEvent:FireServer("Begin", v7.id)
end

TextButton.InputBegan:Connect(function(v10) -- line 50 | captures: begin
    if v10.UserInputType == Enum.UserInputType.Touch or v10.UserInputType == Enum.UserInputType.MouseButton1 then
        begin(v10)
    end
end)
UserInputService.InputBegan:Connect(function(v11, v12) -- line 53 | captures: UserInputService, begin
    if not (v12 or UserInputService:GetFocusedTextBox() or v11.KeyCode ~= Enum.KeyCode.F and v11.KeyCode ~= Enum.KeyCode.ButtonX) then
        begin(v11)
    end
end)
UserInputService.InputEnded:Connect(function(v13) -- line 56 | captures: v7, v8, RescueEvent, Frame_3
    if not v8 or v13 ~= v8 and (v13.KeyCode == Enum.KeyCode.None or v13.KeyCode ~= v8.KeyCode) then
        return
    end
    if v7 and not v7.sent then
        RescueEvent:FireServer("Cancel", v7.id)
    end
    v7 = nil
    v8 = nil
    Frame_3.Size = UDim2.fromScale(0, 1)
end)
RescueEvent.OnClientEvent:Connect(function(v14, v15) -- line 59 | captures: v7, v8, Frame_3
    if not (v14 == "Cancelled" and v7 and v7.id == v15) then
        return
    end
    v7 = nil
    v8 = nil
    Frame_3.Size = UDim2.fromScale(0, 1)
end)

local function characterAdded(v16) -- line 64
    local v17 = v16:WaitForChild("Humanoid", 10)
    if not v17 then
        return
    end
    local v18 = v17:GetStateEnabled(Enum.HumanoidStateType.GettingUp)
    local v19 = false

    local function update() -- line 68 | captures: v19, v16, v17, v18
        if v16:GetAttribute("Ragdolled") == true then
            v19 = true
            v17.EvaluateStateMachine = false
            v17:SetStateEnabled(Enum.HumanoidStateType.GettingUp, false)
            v17.PlatformStand = true
            v17:ChangeState(Enum.HumanoidStateType.Physics)
        elseif v19 then
            v19 = false
            v17.EvaluateStateMachine = true
            v17:SetStateEnabled(Enum.HumanoidStateType.GettingUp, v18)
            v17.PlatformStand = false
            if v17.Health > 0 then
                v17:ChangeState(Enum.HumanoidStateType.GettingUp)
            end
        end
    end

    local v20 = v16:GetAttributeChangedSignal("Ragdolled"):Connect(update)
    v16.Destroying:Once(function() -- line 80 | captures: v20
        v20:Disconnect()
    end)
    update()
end

LocalPlayer.CharacterAdded:Connect(characterAdded)

if LocalPlayer.Character then
    task.spawn(characterAdded, LocalPlayer.Character)
end
local v21 = 0
local v22 = RunService.Heartbeat:Connect(function(v23) -- line 85 | captures: v6, v7, v8, v21, UserInputService, LocalPlayer, v1, RescueEvent, Session, v2, v3, v4, TextLabel, Frame, TextLabel_2, TextLabel_3, Frame_3, v5
    v21 += v23
    if v21 >= 0.1 then
        v21 = 0
        local Character = LocalPlayer.Character
        local v24 = Character and Character:FindFirstChildOfClass("Humanoid")
        local v25 = Character and Character:FindFirstChild("HumanoidRootPart")
        local GlobalPaused = Session:GetAttribute("GlobalPaused")
        local v26 = LocalPlayer:GetAttribute("GameRole") == "Runner" and LocalPlayer:GetAttribute("RunState") == "Caught" and Character and Character:GetAttribute("Ragdolled") and not GlobalPaused or false
        TextLabel.Visible = v26
        if TextLabel.Visible then
            local v27
            if Character:GetAttribute("RescueAvailable") then
                if Character:GetAttribute("RescueHelperId") then
                    v27 = "GETTING YOU BACK UP\226\128\166"
                else
                    v27 = "DOWNED \194\183 A crossing runner can revive you"
                end
            else
                v27 = "CAUGHT \194\183 Joining the catchers next crossing"
            end
            TextLabel.Text = v27
        end
        local Enabled = v1.Enabled
        if Enabled then
            local v28 = not GlobalPaused
            if v28 then
                local v29 = not v4.reason(LocalPlayer)
                if v29 then
                    if LocalPlayer:GetAttribute("GameRole") == "Runner" and LocalPlayer:GetAttribute("RunState") == "Active" then
                        if v25 then
                            if v24 then
                                if v24.Health > 0 then
                                    v24 = not Character:GetAttribute("MovementLocked")
                                else
                                    v24 = false
                                end
                            end
                        else
                            v24 = v25
                        end
                    else
                        v24 = false
                    end
                else
                    v24 = v29
                end
            else
                v24 = v28
            end
        else
            v24 = Enabled
        end
        local v30 = v24 and v2.list() or {}
        v5:update(v30, LocalPlayer, v24)
        local v31 = v1.Range - 0.25
        local v32
        if v24 then
            local v33
            for v34, v35 in v30 do
                local Character_2 = v35.Character
                local v36 = Character_2 and Character_2:FindFirstChild("HumanoidRootPart")
                if v36 and Character_2 ~= Character and Character_2:GetAttribute("RescueAvailable") and Character_2:GetAttribute("Ragdolled") then
                    local RescueHelperId = Character_2:GetAttribute("RescueHelperId")
                    local Magnitude = (v25.Position - v36.Position).Magnitude
                    if Magnitude <= v31 then
                        if RescueHelperId then
                            if RescueHelperId == LocalPlayer.UserId then
                                local v37 = RaycastParams.new()
                                v37.FilterType = Enum.RaycastFilterType.Exclude
                                v37.FilterDescendantsInstances = { Character, Character_2 }
                                v37.RespectCanCollide = true
                                v37.CollisionGroup = "CoHRunner"
                                if not workspace:Raycast(v25.Position, v36.Position - v25.Position, v37) then
                                    v33 = v35
                                    v31 = Magnitude
                                end
                            end
                        else
                            local v38 = RaycastParams.new()
                            v38.FilterType = Enum.RaycastFilterType.Exclude
                            v38.FilterDescendantsInstances = { Character, Character_2 }
                            v38.RespectCanCollide = true
                            v38.CollisionGroup = "CoHRunner"
                            if not workspace:Raycast(v25.Position, v36.Position - v25.Position, v38) then
                                v33 = v35
                                v31 = Magnitude
                            end
                        end
                    end
                end
                v32 = v33
            end
        end
        if v7 and (not v32 or v32.UserId ~= v7.id or v32.Character ~= v7.character) then
            if v7 and not v7.sent then
                RescueEvent:FireServer("Cancel", v7.id)
            end
            v7 = nil
            v8 = nil
            Frame_3.Size = UDim2.fromScale(0, 1)
        end
        v6 = v32
        Frame.Visible = v6 ~= nil
        if v6 then
            TextLabel_2.RichText = true
            TextLabel_2.Text = v3.player(v6) .. (" \194\183 %.1fs"):format(v1.HoldSeconds)
            local PreferredInput = UserInputService.PreferredInput
            local v39
            if v7 then
                if v7.sent then
                    v39 = "HELPING\226\128\166"
                else
                    v39 = "HOLD\226\128\166"
                end
            elseif PreferredInput == Enum.PreferredInput.Touch then
                v39 = "HOLD TO REVIVE"
            elseif PreferredInput == Enum.PreferredInput.Gamepad then
                v39 = "HOLD X \194\183 REVIVE"
            else
                v39 = "HOLD F \194\183 REVIVE"
            end
            TextLabel_3.Text = v39
        end
    end
    if not v7 then
        return
    end
    local v40 = (os.clock() - v7.started) / v1.HoldSeconds
    local v41 = math.clamp(v40, 0, 1)
    Frame_3.Size = UDim2.fromScale(v41, 1)
    if v41 >= 1 and not v7.sent then
        v7.sent = true
        RescueEvent:FireServer("Finish", v7.id)
    end
    local v42
    if v7.sent then
        local v43 = os.clock() - v7.started
        if v1.HoldSeconds + v1.FinishGrace + 0.5 < v43 then
            if v7 and not v7.sent then
                RescueEvent:FireServer("Cancel", v7.id)
            end
            v42 = false
        else
            v42 = true
        end
    else
        v42 = true
    end
    if v42 then
        return
    end
    v7 = nil
    v8 = nil
    Frame_3.Size = UDim2.fromScale(0, 1)
end)
script.Destroying:Connect(function() -- line 132 | captures: v7, v8, RescueEvent, ScreenGui, Frame_3, v5, v22
    v22:Disconnect()
    if v7 and not v7.sent then
        RescueEvent:FireServer("Cancel", v7.id)
    end
    v7 = nil
    v8 = nil
    Frame_3.Size = UDim2.fromScale(0, 1)
    v5:destroy()
    ScreenGui:Destroy()
end)
