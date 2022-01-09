VehiclesConfig = {
    {
        ["Job"] = "police",
        ["Label"] = "Police Vehicles",
        ["Spawn"] = vector4(380.48, -1626.24, 28.59, 320.41),
        ["Garage"] = "DavisPD",

        ["Vehicles"] = {
            { name = "Crown Victoria", model = "npolvic", price = 5000, first_free = true },
        },

        ["NPC"] = {
            id = "police_vehicles",
            name = "Police Vehicles",
            pedType = 4,
            model = "s_f_y_cop_01",
            networked = false,
            distance = 50.0,
            position = {
                coords = vector3(376.8, -1622.71, 28.25),
                heading = 142.47,
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
            scenario = "WORLD_HUMAN_AA_COFFEE",
        },
    }
}