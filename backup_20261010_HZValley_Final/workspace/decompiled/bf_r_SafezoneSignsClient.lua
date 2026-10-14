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

local LocalPlayer = game:GetService("Players").LocalPlayer
local v7 = {
    SafezoneASide = true,
    SafezoneBSide = true
}
local v8 = {}
local v9 = { __mode = "k" }
local v10 = setmetatable(v8, v9)
local v11 = {}
local v12

local function isSign(v13) -- line 15 | captures: v7
    local Parent = v13.Parent
    local BillboardGui
    if v13.Name == "Sign" then
        BillboardGui = v13:IsA("BillboardGui")
        if BillboardGui then
            if Parent == nil then
                BillboardGui = false
            else
                BillboardGui = v7[Parent.Name] == true
            end
        end
    else
        BillboardGui = false
    end
    return BillboardGui
end

local function untrack() -- line 20 | captures: v12, v10
    if v12 then
        v12:Disconnect()
        v12 = nil
    end
    table.clear(v10)
end

local function stop() -- line 28 | captures: v12, v10, v11
    for v14 in v10 do
        v14.Enabled = false
    end
    if v12 then
        v12:Disconnect()
        v12 = nil
    end
    table.clear(v10)
    for v15, v16 in v11 do
        v16:Disconnect()
    end
    table.clear(v11)
end

local function refresh() -- line 39 | captures: LocalPlayer, v10, stop
    local Map3Signs = LocalPlayer:GetAttribute("Map3Signs")
    if Map3Signs == true then
        for v17 in v10 do
            v17.Enabled = true
        end
    elseif Map3Signs == false then
        stop()
    end
end

local function track(v18) -- line 50 | captures: v12, LocalPlayer, v7, v10, stop
    if v12 then
        v12:Disconnect()
        v12 = nil
    end
    table.clear(v10)
    local Field = v18:FindFirstChild("Field")
    if Field then
        for v19 in v7 do
            local v20 = Field:FindFirstChild(v19)
            local v21 = v20 and v20:FindFirstChild("Sign")
            if v21 then
                local Parent = v21.Parent
                local BillboardGui
                if v21.Name == "Sign" then
                    BillboardGui = v21:IsA("BillboardGui")
                    if BillboardGui then
                        if Parent == nil then
                            BillboardGui = false
                        else
                            BillboardGui = v7[Parent.Name] == true
                        end
                    end
                else
                    BillboardGui = false
                end
                if BillboardGui then
                    v10[v21] = true
                end
            end
        end
    end
    v12 = v18.DescendantAdded:Connect(function(v22) -- line 62 | captures: LocalPlayer, v7, v10, stop
        local Parent = v22.Parent
        local BillboardGui
        if v22.Name == "Sign" then
            BillboardGui = v22:IsA("BillboardGui")
            if BillboardGui then
                if Parent == nil then
                    BillboardGui = false
                else
                    BillboardGui = v7[Parent.Name] == true
                end
            end
        else
            BillboardGui = false
        end
        if not BillboardGui then
            return
        end
        v10[v22] = true
        local Map3Signs = LocalPlayer:GetAttribute("Map3Signs")
        if Map3Signs == true then
            for v23 in v10 do
                v23.Enabled = true
            end
        elseif Map3Signs == false then
            stop()
        end
    end)
    local Map3Signs = LocalPlayer:GetAttribute("Map3Signs")
    if Map3Signs == true then
        for v24 in v10 do
            v24.Enabled = true
        end
    elseif Map3Signs == false then
        stop()
    end
end

local ChildAdded = workspace.ChildAdded
v1(v11, ChildAdded:Connect(function(v25) -- line 71 | captures: track
    if v25.Name == "Map3" then
        track(v25)
    end
end))
local ChildRemoved = workspace.ChildRemoved
v3(v11, ChildRemoved:Connect(function(v26) -- line 76 | captures: v12, v10
    if v26.Name == "Map3" then
        if v12 then
            v12:Disconnect()
            v12 = nil
        end
        table.clear(v10)
    end
end))
v5(v11, LocalPlayer:GetAttributeChangedSignal("Map3Signs"):Connect(refresh))
local Map3 = workspace:FindFirstChild("Map3")

if Map3 then
    track(Map3)
else
    local Map3Signs = LocalPlayer:GetAttribute("Map3Signs")
    if Map3Signs == true then
        for v27 in v10 do
            v27.Enabled = true
        end
    elseif Map3Signs == false then
        stop()
    end
end
