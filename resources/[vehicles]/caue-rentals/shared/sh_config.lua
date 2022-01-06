Config = {
    ["Spawn"] = vector4(117.84, -1079.95, 29.23, 355.92),

    ["Vehicles"] = {
        { name = "Boat Trailer", model = "boattrailer", price = 500, image = "https://i.imgur.com/pBPWt8w.png" },
        { name = "Coach", model = "coach", price = 1000, image = "https://i.imgur.com/UMyzsaG.png" },
        { name = "Shuttle Bus", model = "rentalbus", price = 1000, image = "https://i.imgur.com/S6rFV44.png" },
        { name = "Tour Bus", model = "tourbus", price = 1500, image = "https://i.imgur.com/NDVrJNt.png" },
        { name = "Limo", model = "stretch", price = 2500, image = "https://i.imgur.com/AVEHSeE.png" },
        { name = "Hearse", model = "romero", price = 2500, image = "https://i.imgur.com/thKNfEC.png" },
        { name = "Clown Car", model = "speedo2", price = 5000, image = "https://i.imgur.com/UAPXqTj.png" },
        { name = "Festival Bus", model = "pbus2", price = 10000, image = "https://i.imgur.com/ysdK5yJ.png" },
    },

    ["NPC"] = {
        id = "vehicle_rentals",
        name = "Vehicle Rentals",
        pedType = 4,
        model = "a_m_y_business_02",
        networked = false,
        distance = 150.0,
        position = {
            coords = vector3(108.77, -1088.88, 28.3),
            heading = 345.0,
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
            ["isCarRenter"] = true,
        },
        scenario = "WORLD_HUMAN_CLIPBOARD",
    },
}