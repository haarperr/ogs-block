Config = {
    ["Spawn"] = vector4(337.15, -579.9, 28.8, 337.03),

    ["Vehicles"] = {
        { name = "Ambulance Speedo", model = "emsnspeedo", price = 5000, first_free = true },
        { name = "Ambulance", model = "ambulance", price = 5000, first_free = true, image = "https://i.imgur.com/huqyyKL.png" },
        { name = "Fire Truck", model = "firetruk", price = 15000, image = "https://i.imgur.com/jZ9Ol3e.png" },
        { name = "Lifeguard", model = "lguard", price = 10000, image = "https://i.imgur.com/BOFkRrj.png" },
    },

    ["NPC"] = {
        id = "ems_vehicles",
        name = "EMS Vehicles",
        pedType = 4,
        model = "s_m_m_paramedic_01",
        networked = false,
        distance = 50.0,
        position = {
            coords = vector3(341.23, -579.11, 27.8),
            heading = 124.3,
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
            ["isEmsVehicleSeller"] = true,
        },
        scenario = "WORLD_HUMAN_AA_COFFEE",
    },
}