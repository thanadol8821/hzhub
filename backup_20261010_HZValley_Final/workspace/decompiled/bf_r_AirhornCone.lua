-- https://sitetest1.lua.expert

local v1 = {
    Range = 14,
    MaxHeight = 6
}

function v1.contains(v2, v3, v4, v5) -- line 3 | captures: v1
    local v6 = v4 - v2
    local X = v6.X
    local Z = v6.Z
    local v7 = Vector3.new(X, 0, Z)
    local Y = v6.Y
    if math.abs(Y) <= v1.MaxHeight then
        return v7.Magnitude <= v1.Range + (v5 or 0)
    end
    return false
end

return table.freeze(v1)
