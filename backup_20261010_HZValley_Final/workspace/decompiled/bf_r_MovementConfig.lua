-- https://sitetest1.lua.expert

return table.freeze({
    SpeedScale = 1.2,
    CatcherSpeedMultiplier = 1.1,
    RunnerSpeedMultiplier = 1.06,
    RunnerAccelerationMultiplier = 1.42,
    RunnerTurnRetention90 = 0.72,
    CatcherTurnRate = 300,
    CatcherSlowTurnRate = 720,
    MaxSpeed = 33.6,
    Acceleration = 36,
    Deceleration = 66,
    InputDeadzone = 0.05,
    TurnRetention90 = 0.65,
    StopThreshold = 0.18,
    StallGrace = 0.2,
    StallSpeed = 1.2,
    StallSpeedCap = 7.199999999999999,
    JumpEnabled = false,
    CrossingBalance = table.freeze({
        Enabled = true,
        RunnerMaxBonus = 0.12,
        CatcherMaxReduction = 0.08,
        PressureExponent = 1.25,
        RunnerMaxAccelerationBonus = 0.55,
        RunnerMaxTurnRetention = 0.88,
        RunnerMaxBrakingBonus = 0.2
    }),
    Dash = table.freeze({
        Enabled = true,
        Mode = "RunBoost",
        ScaleDistanceWithSpeed = true,
        Distance = 10.799999999999999,
        Duration = 0.28,
        Cooldown = 1.1,
        MinTurnAngle = 90,
        TurnInputGrace = 0.38,
        InputBuffer = 0.18,
        MinIntentAngle = 35,
        TouchTurnInputGrace = 0.55,
        TouchInputBuffer = 0.32,
        TouchMinIntentAngle = 25,
        RecoveryDuration = 0.2,
        RecoverySpeedRatio = 0.8,
        BoostExitSpeedRatio = 0.85
    }),
    Camera = table.freeze({
        ShoulderOffset = Vector3.new(1.75, 0, 0),
        MinZoom = 6,
        MaxZoom = 18
    })
})
