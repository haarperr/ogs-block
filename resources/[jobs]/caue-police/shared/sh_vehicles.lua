VehiclesConfig = {
    {
        ["Job"] = "police",
        ["Label"] = "Veiculos Policiais",
        ["Spawn"] = vector4(435.76, -976.08, 25.52, 90.85),
        ["Garage"] = "MRPD",

        ["Vehicles"] = {
            { name = "Sheriff", model = "sheriff", price = 5000, first_free = true },
            { name = "Sheriff2", model = "sheriff2", price = 5000, first_free = true },
            { name = "Alamo", model = "sheriffalamo", price = 5000, first_free = true },
            { name = "Foss", model = "sheriffoss", price = 5000, first_free = true },
            { name = "Rumpo", model = "sheriffrumpo", price = 5000, first_free = true },
            { name = "Scout", model = "sheriffscout", price = 5000, first_free = true },
            { name = "Scout2", model = "sheriffscoutnew", price = 5000, first_free = true },
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