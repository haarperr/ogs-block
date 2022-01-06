Config = {
    ["Spawn"] = vector4(-877.73, -1362.89, 0.65, 195.89),

    ["Vehicles"] = {
        { name = "Jetski", model = "seashark", price = 15000, image = "https://i.imgur.com/oD5VoPt.png" },
        { name = "Suntrap", model = "suntrap", price = 25000, image = "https://i.imgur.com/oGISyr8.png" },
        { name = "Tropic", model = "tropic", price = 25000, image = "https://i.imgur.com/j6ZTvlD.png" },
        { name = "Speeder", model = "speeder", price = 40000, image = "https://i.imgur.com/6uMLyff.png" },
        { name = "Toro", model = "toro", price = 40000, image = "https://i.imgur.com/APVbsrP.png" },
        { name = "Squalo", model = "squalo", price = 40000, image = "https://i.imgur.com/HJoz1Fd.png" },
        { name = "Jetmax", model = "jetmax", price = 65000, image = "https://i.imgur.com/KMaSSRp.png" },
        { name = "Marquis", model = "marquis", price = 100000, image = "https://i.imgur.com/zu2l8I8.png" },
        { name = "Dinghy", model = "dinghy", price = 250000, image = "https://i.imgur.com/J75JEgi.png" },
        { name = "Tug", model = "tug", price = 350000, image = "https://i.imgur.com/FWECUvg.png" },
        { name = "Kraken", model = "submersible2", price = 500000, image = "https://i.imgur.com/wfOfqkp.png" },
    },

    ["NPC"] = {
        id = "boat_shop",
        name = "Boat Shop",
        pedType = 4,
        model = "mp_m_boatstaff_01",
        networked = false,
        distance = 150.0,
        position = {
            coords = vector3(-876.42, -1324.7, 0.61),
            heading = 110.0,
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
            ["isBoatShop"] = true,
        },
        scenario = "WORLD_HUMAN_SMOKING",
    },
}