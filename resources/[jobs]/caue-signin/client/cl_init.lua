--[[

    Variables

]]

MenuData = {
    ems_sign_in = {
        {
            title = "EMS",
            description = "Sign in or sign out",
            children = {
                { title = "Sign In", action = "caue-signin:handler", params = { sign_in = true, job = "ems" } },
                { title = "Sign Out", action = "caue-signin:handler", params = { sign_off = true } },
            }
        },
        {
            title = "Doctor",
            description = "Sign in or sign out",
            children = {
                { title = "Sign In", action = "caue-signin:handler", params = { sign_in = true, job = "doctor" } },
                { title = "Sign Out", action = "caue-signin:handler", params = { sign_off = true } },
            }
        },
    },
    lspd_sign_in = {
        {
            title = "Police Officer",
            description = "Sign in or sign out",
            children = {
                { title = "Sign In", action = "caue-signin:handler", params = { sign_in = true, job = "police" } },
                { title = "Sign Out", action = "caue-signin:handler", params = { sign_off = true } }
            }
        },
    },
    sasp_sign_in = {
        {
            title = "State Trooper",
            description = "Sign in or sign out",
            children = {
                { title = "Sign In", action = "caue-signin:handler", params = { sign_in = true, job = "state_police" } },
                { title = "Sign Out", action = "caue-signin:handler", params = { sign_off = true } }
            }
        },
    },
    sheriff_sign_in = {
        {
            title = "Sheriff Officer",
            description = "Sign in or sign out",
            children = {
                { title = "Sign In", action = "caue-signin:handler", params = { sign_in = true, job = "sheriff" } },
                { title = "Sign Out", action = "caue-signin:handler", params = { sign_off = true } }
            }
        },
    },
    park_rangers_sign_in = {
        {
            title = "Park Ranger",
            description = "Sign in or sign out",
            children = {
                { title = "Sign In", action = "caue-signin:handler", params = { sign_in = true, job = "park_ranger" } },
                { title = "Sign Out", action = "caue-signin:handler", params = { sign_off = true } }
            }
        },
    },
    doc_services_sign_in = {
        {
            title = "Department of Corrections Officer",
            description = "Sign in or sign out",
            children = {
                { title = "Sign In", action = "caue-signin:handler", params = { sign_in = true, job = "doc" } },
                { title = "Sign Out", action = "caue-signin:handler", params = { sign_off = true } }
            }
        },
    },
    public_services_sign_in = {
        {
            title = "Mayor",
            description = "Sign in or sign out",
            children = {
                { title = "Sign In", action = "caue-signin:handler", params = { sign_in = true, job = "mayor" } },
                { title = "Sign Out", action = "caue-signin:handler", params = { sign_off = true } }
            }
        },
        {
            title = "Judge",
            description = "Sign in or sign out",
            children = {
                { title = "Sign In", action = "caue-signin:handler", params = { sign_in = true, job = "judge" } },
                { title = "Sign Out", action = "caue-signin:handler", params = { sign_off = true } }
            }
        },
        {
            title = "District Attorney",
            description = "Sign in or sign out",
            children = {
                { title = "Sign In", action = "caue-signin:handler", params = { sign_in = true, job = "district attorney" } },
                { title = "Sign Out", action = "caue-signin:handler", params = { sign_off = true } }
            }
        },
        {
            title = "Public Defender",
            description = "Sign in or sign out",
            children = {
                { title = "Sign In", action = "caue-signin:handler", params = { sign_in = true, job = "defender" } },
                { title = "Sign Out", action = "caue-signin:handler", params = { sign_off = true } }
            }
        },
    },
}

--[[

    Threads

]]

Citizen.CreateThread(function()
    SetScenarioTypeEnabled("WORLD_VEHICLE_STREETRACE", false)
    SetScenarioTypeEnabled("WORLD_VEHICLE_SALTON_DIRT_BIKE", false)
    SetScenarioTypeEnabled("WORLD_VEHICLE_SALTON", false)
    SetScenarioTypeEnabled("WORLD_VEHICLE_POLICE_NEXT_TO_CAR", false)
    SetScenarioTypeEnabled("WORLD_VEHICLE_POLICE_CAR", false)
    SetScenarioTypeEnabled("WORLD_VEHICLE_POLICE_BIKE", false)
    SetScenarioTypeEnabled("WORLD_VEHICLE_MILITARY_PLANES_SMALL", false)
    SetScenarioTypeEnabled("WORLD_VEHICLE_MILITARY_PLANES_BIG", false)
    SetScenarioTypeEnabled("WORLD_VEHICLE_MECHANIC", false)
    SetScenarioTypeEnabled("WORLD_VEHICLE_EMPTY", false)
    SetScenarioTypeEnabled("WORLD_VEHICLE_BUSINESSMEN", false)
    SetScenarioTypeEnabled("WORLD_VEHICLE_BIKE_OFF_ROAD_RACE", false)

    -- MRPD
    exports["caue-polytarget"]:AddBoxZone("job_sign_in", vector3(441.83, -982.05, 30.69), 0.5, 0.35, {
        heading = 12,
        minZ = 30.79,
        maxZ = 30.84,
        data = {
            job = "lspd_sign_in",
        },
    })

    -- Sandy PD
    exports["caue-polytarget"]:AddBoxZone("job_sign_in", vector3(1852.45, 3687.28, 34.27), 0.8, 0.4, {
        heading = 300,
        minZ = 34.32,
        maxZ = 34.52,
        data = {
            job = "sasp_sign_in",
        },
    })

    -- Paleto PD
    exports["caue-polytarget"]:AddBoxZone("job_sign_in", vector3(-450.18, 6012.72, 31.72), 0.8, 0.4, {
        heading = 318,
        minZ = 31.52,
        maxZ = 31.72,
        data = {
            job = "sheriff_sign_in",
        },
    })

    -- Park Rangers PD
    exports["caue-polytarget"]:AddBoxZone("job_sign_in", vector3(384.54, 800.24, 187.68), 0.5, 1.2, {
        heading = 0,
        minZ = 187.53,
        maxZ = 187.63,
        data = {
            job = "park_rangers_sign_in",
        },
    })

    -- DOC
    exports["caue-polytarget"]:AddCircleZone("job_sign_in",vector3(1841.6, 2574.13, 45.81), 0.28, {
        useZ = true,
        data = {
            job = "doc_services_sign_in",
        },
    })

    -- EMS Pillbox
    exports["caue-polytarget"]:AddBoxZone("job_sign_in", vector3(310.24, -597.54, 43.28), 0.35, 0.25, {
        heading = 331,
        minZ = 43.28,
        maxZ = 43.33,
        data = {
            job = "ems_sign_in",
        },
    })

    -- City Hall
    exports["caue-polytarget"]:AddCircleZone("job_sign_in", vector3(-553.09, -192.81, 38.22), 0.3, {
        useZ = true,
        data = {
            job = "public_services_sign_in",
        },
    })
end)