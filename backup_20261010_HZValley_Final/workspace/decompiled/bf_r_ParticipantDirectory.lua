-- https://sitetest1.lua.expert

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local v1 = {}
local v2, v3

if RunService:IsClient() and require(game:GetService("ReplicatedFirst"):WaitForChild("FFlags")).ClientBots == true then
    local v4 = require(script.Parent.Parent:WaitForChild("Bots"):WaitForChild("BotDirectory"))
    if v4 then
        v2 = v4
        v3 = true
    else
        v3 = false
    end
else
    v3 = false
end

if not v3 then
    v2 = nil
end
local v5 = v2

function v1.list() -- line 9 | captures: Players, v5
    local v6 = Players:GetPlayers()
    if v5 then
        for v7, v8 in v5.list() do
            if v8.record:GetAttribute("IsBot") == true then
                table.insert(v6, v8)
            end
        end
    else
        local Bots = script.Parent.Parent:FindFirstChild("Bots")
        local v9 = Bots and Bots:FindFirstChild("Actors")
        if v9 then
            for v10, v11 in v9:GetChildren() do
                if v11:GetAttribute("IsBot") == true then
                    local Character = v11:FindFirstChild("Character")
                    local v12 = {
                        IsBot = true,
                        UserId = v11:GetAttribute("UserId"),
                        DisplayName = v11:GetAttribute("DisplayName"),
                        Name = v11.Name
                    }
                    v12.Character = Character and Character.Value
                    local v13 = v11

                    function v12.GetAttribute(v14, v15) -- line 23 | captures: v13
                        return v13:GetAttribute(v15)
                    end

                    table.insert(v6, v12)
                end
            end
        end
    end
    return v6
end

return v1
