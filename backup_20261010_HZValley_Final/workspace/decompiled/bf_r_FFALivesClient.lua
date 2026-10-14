-- https://sitetest1.lua.expert

local function v1(v2, ...)
    table.insert(v2, ...)
end

local function v3(v4, ...)
    table.insert(v4, ...)
end

local LocalPlayer = game:GetService("Players").LocalPlayer
local Session = game.ReplicatedStorage:WaitForChild("ChickenOrHero"):WaitForChild("Game"):WaitForChild("Session")
local ScreenGui = Instance.new("ScreenGui")

ScreenGui.Name = "FFALives"
ScreenGui.ResetOnSpawn = false
ScreenGui.DisplayOrder = 63
ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local TextLabel = Instance.new("TextLabel")

TextLabel.Name = "Lives"
TextLabel.AnchorPoint = Vector2.new(1, 0.5)
TextLabel.Position = UDim2.fromScale(0.98, 0.44)
TextLabel.Size = UDim2.fromScale(0.19, 0.09)
TextLabel.BackgroundTransparency = 1
TextLabel.TextColor3 = Color3.fromRGB(255, 218, 138)
TextLabel.TextStrokeTransparency = 0.25
TextLabel.Font = Enum.Font.GothamBold
TextLabel.TextScaled = true
TextLabel.TextWrapped = true
TextLabel.Parent = ScreenGui

local v5 = true
local v6 = {}
local v7, render

local function render_2() -- line 25 | captures: v5, v7, LocalPlayer, Session, TextLabel, render
    if v7 then
        task.cancel(v7)
        v7 = nil
    end
    local FFALives = LocalPlayer:GetAttribute("FFALives")
    local v8 = if Session:GetAttribute("AdminMatchMode") == "FFACatchers" and type(FFALives) == "number" then FFALives > 0 else false
    TextLabel.Visible = v8
    if not TextLabel.Visible then
        return
    end
    local v9 = workspace:GetServerTimeNow()
    local v10 = LocalPlayer:GetAttribute("FFADownUntil") or 0
    local v11 = LocalPlayer:GetAttribute("FFAImmuneUntil") or 0
    local v12, v13
    if v9 < v10 then
        local v14 = v10 - v9
        local v15 = "GET UP IN " .. math.ceil(v14)
        if v15 then
            v12 = v15
            v13 = true
        elseif v9 < v11 then
            local v16 = v11 - v9
            local v17 = "INVINCIBLE \194\183 " .. math.ceil(v16)
            if v17 then
                v12 = v17
                v13 = true
            else
                v13 = false
            end
        else
            v13 = false
        end
    elseif v9 < v11 then
        local v18 = v11 - v9
        local v19 = "INVINCIBLE \194\183 " .. math.ceil(v18)
        if v19 then
            v12 = v19
            v13 = true
        else
            v13 = false
        end
    else
        v13 = false
    end
    if not v13 then
        v12 = "LAST ONE STANDING"
    end
    TextLabel.Text = string.format("%d / 3 LIVES\n%s", FFALives, v12)
    local v20 = v9 < v11 and Color3.fromRGB(110, 220, 255) or Color3.fromRGB(255, 218, 138)
    TextLabel.TextColor3 = v20
    local v21, v22
    if v9 < v10 and v10 then
        v21 = v10
        v22 = true
    elseif v9 < v11 and v11 then
        v21 = v11
        v22 = true
    else
        v22 = false
    end
    if not v22 then
        v21 = nil
    end
    if not v21 then
        return
    end
    local v23 = v21 - v9
    local v24 = v23 - (math.ceil(v23) - 1) + 0.02
    v7 = task.delay(math.clamp(v24, 0.05, 1.02), function() -- line 47 | captures: v5, v7, render
        v7 = nil
        if v5 then
            render()
        end
    end)
end

render = render_2
for v25, v26 in { "FFALives", "FFADownUntil", "FFAImmuneUntil" } do
    v1(v6, LocalPlayer:GetAttributeChangedSignal(v26):Connect(render_2))
end
v3(v6, Session:GetAttributeChangedSignal("AdminMatchMode"):Connect(render_2))
script.Destroying:Connect(function() -- line 59 | captures: v5, v7, ScreenGui, v6
    v5 = false
    if v7 then
        task.cancel(v7)
        v7 = nil
    end
    for v27, v28 in v6 do
        v28:Disconnect()
    end
    ScreenGui:Destroy()
end)
render_2()
