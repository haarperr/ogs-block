VehiclesConfig = {
    {
        ["Job"] = "police",
        ["Label"] = "Police Vehicles",
        ["Spawn"] = vector4(435.76, -976.08, 25.52, 90.85),
        ["Garage"] = "MRPD",

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
            scenario = "WORLD_HUMAN_AA_COFFEE",
        },
    },
    {
        ["Job"] = "state_police",
        ["Label"] = "State Police Vehicles",
        ["Spawn"] = vector4(1860.93, 3706.47, 33.39, 205.49),
        ["Garage"] = "SandyPD",

        ["Vehicles"] = {
            { name = "Crown Victoria", model = "npolvic", price = 5000, first_free = true },
        },

        ["NPC"] = {
            id = "state_police_vehicles",
            name = "State Police Vehicles",
            pedType = 4,
            model = "s_m_y_hwaycop_01",
            networked = false,
            distance = 50.0,
            position = {
                coords = vector3(1856.79, 3700.84, 33.28),
                heading = 129.24,
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
    },
    {
        ["Job"] = "sheriff",
        ["Label"] = "Sheriff Department Vehicles",
        ["Spawn"] = vector4(-462.14, 6019.07, 31.16, 314.68),
        ["Garage"] = "PaletoPD",

        ["Vehicles"] = {
            { name = "Crown Victoria", model = "npolvic", price = 5000, first_free = true },
        },

        ["NPC"] = {
            id = "sheriff_vehicles",
            name = "Sheriff Vehicles",
            pedType = 4,
            model = "s_f_y_sheriff_01",
            networked = false,
            distance = 100.0,
            position = {
                coords = vector3(-458.74, 6012.19, 30.5),
                heading = 138.09,
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
    },
    {
        ["Job"] = "park_ranger",
        ["Label"] = "Park Rangers Vehicles",
        ["Spawn"] = vector4(372.95, 787.52, 186.69, 167.57),
        ["Garage"] = "ParkRangersPD",

        ["Vehicles"] = {
            { name = "Crown Victoria", model = "npolvic", price = 5000, first_free = true },
        },

        ["NPC"] = {
            id = "park_ranger_vehicles",
            name = "Park Rangers Vehicles",
            pedType = 4,
            model = "s_f_y_ranger_01",
            networked = false,
            distance = 100.0,
            position = {
                coords = vector3(376.33, 793.42, 186.55),
                heading = 92.26,
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
    },
}