-- https://sitetest1.lua.expert

return table.freeze({
    Enabled = true,
    Skin = "CloneDagger",
    Count = 2,
    Duration = 12,
    Cooldown = 45,
    ServerCloneLimit = 24,
    ThinkLevel = 0.35,
    SplitDuration = 0.32,
    SwapDistance = 4,
    RunnerRoute = table.freeze({
        ChangeMin = 0.65,
        ChangeMax = 1.45,
        SideStrength = 0.7,
        TurnResponse = 5,
        LookAhead = 18,
        FinishFocusDistance = 24,
        ObstacleInterval = 0.14,
        JukeChance = 0.65,
        JukeMin = 0.16,
        JukeMax = 0.28
    })
})
