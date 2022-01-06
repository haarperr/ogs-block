Config = {
    ["Spawn"] = vector4(-1100.11, -1702.67, 4.38, 305.96),

    ["Vehicles"] = {
        { name = "BMX", model = "bmx", price = 500, image = "https://i.imgur.com/4CcWCfs.png" },
        { name = "Cruiser", model = "cruiser", price = 1000, image = "https://i.imgur.com/6kKuk4y.png" },
        { name = "Fixter", model = "fixter", price = 1500, image = "https://i.imgur.com/aMizdXR.png" },
        { name = "Scorcher", model = "scorcher", price = 2000, image = "https://i.imgur.com/a10AYXE.png" },
        { name = "Whippet Race Bike", model = "tribike", price = 2500, image = "https://i.imgur.com/ueFKIgx.png" },
        { name = "Endurex Race Bike", model = "tribike2", price = 3000, image = "https://i.imgur.com/C9EPcgL.png" },
        { name = "Tri-Cycles Race Bike", model = "tribike3", price = 3500, image = "https://i.imgur.com/C3vpxHC.png" },
    },

    ["NPC"] = {
        id = "bicycle_shop",
        name = "Bicycle Shop",
        pedType = 4,
        model = "a_f_y_beach_01",
        networked = false,
        distance = 100.0,
        position = {
            coords = vector3(-1109.56, -1694.07, 3.57),
            heading = 302.82,
            random = false,
        },
        appearance = nil,
        settings = {
            { mode = "invincible", active = true },
            { mode = "ignore", active = true },
            { mode = "freeze", active = true },
        },
        flags = {
            ["isNPC"] = true,
            ["isBicycleShop"] = true,
        },
    },
}