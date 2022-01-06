DOORS = DOORS or {}

-- Front Door
DOORS[6001] = {
    ["active"] = true,
    ["model"] = -1018783587,
    ["coords"] = vector3(387.61, 792.84, 187.83),
    ["lock"] = 1,
    ["automatic"] = {},
    ["access"] = {
        ["groups"] = {
            ["park_ranger"] = 1,
        },
    },
}

-- Back Door
DOORS[6002] = {
    ["active"] = true,
    ["model"] = -1018783587,
    ["coords"] = vector3(388.11, 799.01, 187.68),
    ["lock"] = 1,
    ["automatic"] = {},
    ["access"] = {
        ["groups"] = {
            ["park_ranger"] = 1,
        },
    },
}

-- Cells
DOORS[6003] = {
    ["active"] = true,
    ["model"] = -868087669,
    ["coords"] = vector3(383.42, 797.51, 187.83),
    ["lock"] = 1,
    ["automatic"] = {},
    ["access"] = {
        ["job"] = { "park_ranger" },
    },
}

-- Cell
DOORS[6004] = {
    ["active"] = true,
    ["model"] = -868087669,
    ["coords"] = vector3(381.06, 795.08, 187.68),
    ["lock"] = 1,
    ["automatic"] = {},
    ["access"] = {
        ["job"] = { "park_ranger" },
    },
}

-- Top Left
DOORS[6005] = {
    ["active"] = true,
    ["model"] = 1715748964,
    ["coords"] = vector3(377.88, 793.21, 190.5),
    ["lock"] = 1,
    ["automatic"] = {},
    ["access"] = {
        ["job"] = { "park_ranger" },
    },
    ["double"] = 6006,
}

-- Top Right
DOORS[6006] = {
    ["active"] = true,
    ["model"] = 1715748964,
    ["coords"] = vector3(380.04, 792.41, 190.42),
    ["lock"] = 1,
    ["automatic"] = {},
    ["access"] = {
        ["job"] = { "park_ranger" },
    },
    ["double"] = 6005,
}

-- Office
DOORS[6007] = {
    ["active"] = true,
    ["model"] = -1018783587,
    ["coords"] = vector3(384.71, 795.31, 190.64),
    ["lock"] = 1,
    ["automatic"] = {},
    ["access"] = {
        ["job"] = { "park_ranger" },
    },
}