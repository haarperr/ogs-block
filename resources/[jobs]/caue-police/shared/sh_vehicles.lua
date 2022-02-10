VehiclesConfig = {
    {
        ["Job"] = "police",
        ["Label"] = "Veiculos Policiais",
        ["Spawn"] = vector4(437.87, -986.39, 25.7, 80.48),
        ["Garage"] = "MRPD",

        ["Vehicles"] = {
            { name = "Crown Victoria", model = "npolvic", price = 1, first_free = true },
            { name = "Charger", model = "npolchar", price = 1, first_free = false },
            { name = "Explorer", model = "npolexp", price = 1, first_free = false },
        },

        ["NPC"] = {
            id = "police_vehicles",
            name = "Veiculos Policiais",
            model = "s_m_y_sheriff_01",
            networked = false,
            distance = 50.0,
            position = {
                coords = vector3(441.43, -974.95, 24.7),
                heading = 180.62,
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
                ["isPoliceVehicleSeller"] = true,
            },
            scenario = "WORLD_HUMAN_COP_IDLES",
        },
    },
}