VehiclesConfig = {
    {
        ["Job"] = "police",
        ["Label"] = "Veiculos Policiais",
        ["Spawn"] = vector4(437.87, -986.39, 25.7, 80.48),
        ["Garage"] = "MRPD",

        ["Vehicles"] = {
            { name = "Viatura Merda 1", model = "sheriff", price = 1, first_free = true },
            { name = "Viatura Merda 2", model = "sheriff2", price = 1, first_free = true },
            { name = "Viatura Merda 3", model = "sheriffalamo", price = 1, first_free = true },
            { name = "Viatura Merda 4", model = "sheriffcq4", price = 1, first_free = true },
            { name = "Viatura Merda 5", model = "sherifffug", price = 1, first_free = true },
            { name = "Viatura Merda 6", model = "sheriffinsurgent", price = 1, first_free = true },
            { name = "Viatura Merda 7", model = "sheriffoss", price = 1, first_free = true },
            { name = "Viatura Merda 8", model = "sheriffroamer", price = 1, first_free = true },
            { name = "Viatura Merda 9", model = "sheriffrumpo", price = 1, first_free = true },
            { name = "Viatura Merda 10", model = "sheriffscout", price = 1, first_free = true },
            { name = "Viatura Merda 11", model = "sheriffscoutnew", price = 1, first_free = true },
            { name = "Viatura Merda 12", model = "sheriffstalker", price = 1, first_free = true },
            { name = "Viatura Merda 13", model = "sheriffthrust", price = 1, first_free = true },
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