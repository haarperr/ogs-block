--[[

    Variables

]]

local listening = false
local currentPrompt = nil

local EVENTS = {
    LOCKERS = 1,
    CLOTHING = 2,
    SWITCHER = 3,
    EVIDENCE = 4,
    TRASH = 5,
    ARMORY = 6,
}

local zoneData = {
    mrpd_clothing_lockers = {
        promptText = "[E] Lockers & Clothes",
        menuData = {
            {
                title = "Lockers",
                description = "Access your personal locker",
                action = "caue-police:handler",
                params = EVENTS.LOCKERS
            },
            {
                title = "Clothing",
                description = "Gotta look Sharp",
                action = "caue-police:handler",
                params = EVENTS.CLOTHING
            }
        }
    },
    mrpd_armory = {
        promptText = "[E] Armory"
    },
    mrpd_evidence = {
        promptText = "[E] Evidence"
    },
    mrpd_trash = {
        promptText = "[E] Trash"
    },
    mrpd_character_switcher = {
        promptText = "[E] Switch Character",
        menuData = {
            {
                title = "Character switch",
                description = "Go bowling with your cousin",
                action = "caue-police:handler",
                params = EVENTS.SWITCHER
            }
        }
    },

    sandypd_lockers = {
        promptText = "[E] Lockers & Clothes",
        menuData = {
            {
                title = "Lockers",
                description = "Access your personal locker",
                action = "caue-police:handler",
                params = EVENTS.LOCKERS
            },
            {
                title = "Clothing",
                description = "Gotta look Sharp",
                action = "caue-police:handler",
                params = EVENTS.CLOTHING
            }
        }
    },
    sandypd_armory = {
        promptText = "[E] Armory"
    },
    sandypd_evidence = {
        promptText = "[E] Evidence & Trash",
        menuData = {
            {
                title = "Evidence",
                description = "Drop off some evidence",
                action = "caue-police:handler",
                params = EVENTS.EVIDENCE
            },
            {
                title = "Trash",
                description = "Where Spaghetti Code belongs",
                action = "caue-police:handler",
                params = EVENTS.TRASH
            },
        }
    },
    sandypd_character_switcher = {
        promptText = "[E] Switch Character",
        menuData = {
            {
                title = "Character switch",
                description = "Go bowling with your cousin",
                action = "caue-police:handler",
                params = EVENTS.SWITCHER
            }
        }
    },

    paletopd_lockers = {
        promptText = "[E] Lockers & Clothes",
        menuData = {
            {
                title = "Lockers",
                description = "Access your personal locker",
                action = "caue-police:handler",
                params = EVENTS.LOCKERS
            },
            {
                title = "Clothing",
                description = "Gotta look Sharp",
                action = "caue-police:handler",
                params = EVENTS.CLOTHING
            }
        }
    },
    paletopd_armory = {
        promptText = "[E] Armory"
    },
    paletopd_evidence = {
        promptText = "[E] Evidence & Trash",
        menuData = {
            {
                title = "Evidence",
                description = "Drop off some evidence",
                action = "caue-police:handler",
                params = EVENTS.EVIDENCE
            },
            {
                title = "Trash",
                description = "Where Spaghetti Code belongs",
                action = "caue-police:handler",
                params = EVENTS.TRASH
            },
        }
    },
    paletopd_character_switcher = {
        promptText = "[E] Switch Character",
        menuData = {
            {
                title = "Character switch",
                description = "Go bowling with your cousin",
                action = "caue-police:handler",
                params = EVENTS.SWITCHER
            }
        }
    },

    park_rangers_station = {
        promptText = "[E] Station Services",
        menuData = {
            {
                title = "Lockers",
                description = "Access your personal locker",
                action = "caue-police:handler",
                params = EVENTS.LOCKERS
            },
            {
                title = "Clothing",
                description = "Gotta look Sharp",
                action = "caue-police:handler",
                params = EVENTS.CLOTHING
            },
            {
                title = "Armory",
                description = "WEF - Weapons, Equipment, Fun!",
                action = "caue-police:handler",
                params = EVENTS.ARMORY
            },
            {
                title = "Evidence",
                description = "Drop off some evidence",
                action = "caue-police:handler",
                params = EVENTS.EVIDENCE
            },
            {
                title = "Trash",
                description = "Where Spaghetti Code belongs",
                action = "caue-police:handler",
                params = EVENTS.TRASH
            },
            {
                title = "Character switch",
                description = "Go bowling with your cousin",
                action = "caue-police:handler",
                params = EVENTS.SWITCHER
            },
        }
    },

    doc_lockers = {
        promptText = "[E] Lockers & Clothes",
        menuData = {
            {
                title = "Lockers",
                description = "Access your personal locker",
                action = "caue-police:handler",
                params = EVENTS.LOCKERS
            },
            {
                title = "Clothing",
                description = "Gotta look Sharp",
                action = "caue-police:handler",
                params = EVENTS.CLOTHING
            },
            {
                title = "Character switch",
                description = "Go bowling with your cousin",
                action = "caue-police:handler",
                params = EVENTS.SWITCHER
            },
        }
    },
    doc_armory = {
        promptText = "[E] Armory"
    },
    doc_trash = {
        promptText = "[E] Trash"
    },
}

--[[

    Functions

]]

local function listenForKeypress(pZone, pAction)
    listening = true

    Citizen.CreateThread(function()
        while listening do
            if IsControlJustReleased(0, 38) then
                if pAction == "context" then
                    exports["caue-context"]:showContext(zoneData[pZone].menuData)
                elseif pAction == "armory"  then
                    TriggerEvent("server-inventory-open", "10", "Shop")
                elseif pAction == "trash" then
                    TriggerEvent("server-inventory-open", "1", pZone)
                elseif pAction == "evidence" then
                    TriggerEvent("server-inventory-open", "1", pZone)
                    TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 3.0, "LockerOpen", 0.4)
                end
            end

            Citizen.Wait(1)
        end
    end)
end

--[[

    Events

]]

AddEventHandler("caue-polyzone:enter", function(pZoneName, pZoneData)
    if pZoneName == "caue-police:zone" then
        if exports["caue-base"]:getChar("job") == pZoneData.job then
            currentPrompt = pZoneData.zone
            exports["caue-interaction"]:showInteraction(zoneData[pZoneData.zone].promptText)
            listenForKeypress(pZoneData.zone, pZoneData.action)
        end
    elseif pZoneName == "mrpd_classroom" then
        AddReplaceTexture("prop_planning_b1", "prop_base_white_01b", "duiTxd", "duiTex")
    end
end)

AddEventHandler("caue-polyzone:exit", function(pZoneName, pZoneData)
    if pZoneName == "caue-police:zone" then
        exports["caue-interaction"]:hideInteraction()
        listening = false
        currentPrompt = nil
    elseif pZoneName == "mrpd_classroom" then
        RemoveReplaceTexture("prop_planning_b1", "prop_base_white_01b")
    end
end)

AddEventHandler("caue-police:handler", function(eventData)
    local location = currentPrompt ~= nil and string.match(currentPrompt, "(.-)_") or ""

    if eventData == EVENTS.LOCKERS and exports["caue-jobs"]:getJob(false, "is_police") then
        local cid = exports["caue-base"]:getChar("id")
        TriggerEvent("server-inventory-open", "1", ("personalStorage-%s-%s"):format(location, cid))
        TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 3.0, "LockerOpen", 0.4)
    elseif eventData == EVENTS.CLOTHING then
        exports["caue-interaction"]:hideInteraction()
        Wait(500)
        TriggerEvent("raid_clothes:openClothing", true, true)
    elseif eventData == EVENTS.SWITCHER then
        TriggerEvent("apartments:Logout")
    elseif eventData == EVENTS.EVIDENCE and exports["caue-jobs"]:getJob(false, "is_police") then
        TriggerEvent("server-inventory-open", "1", ("%s_evidence"):format(location))
    elseif eventData == EVENTS.TRASH and exports["caue-jobs"]:getJob(false, "is_police") then
        TriggerEvent("server-inventory-open", "1", ("%s_trash"):format(location))
    elseif eventData == EVENTS.ARMORY and exports["caue-jobs"]:getJob(false, "is_police") then
        TriggerEvent("server-inventory-open", "10", "Shop")
    end
end)

--[[

    Threads

]]

Citizen.CreateThread(function()
    -- MRPD Classroom
    exports["caue-polyzone"]:AddPolyZone("mrpd_classroom", {
        vector2(448.41372680664, -990.47613525391),
        vector2(439.50704956055, -990.55731201172),
        vector2(439.43478393555, -981.08758544922),
        vector2(448.419921875, -981.26306152344),
        vector2(450.23190307617, -983.00885009766),
        vector2(450.25042724609, -988.77667236328)
    }, {
        gridDivisions = 25,
        minZ = 34.04,
        maxZ = 37.69,
    })

    -- MRPD Lockers
    exports["caue-polyzone"]:AddBoxZone("caue-police:zone", vector3(461.81, -997.79, 30.69), 4.4, 4.8, {
        heading = 0,
        minZ = 29.64,
        maxZ = 32.84,
        data = {
            job = "police",
            action = "context",
            zone = "mrpd_clothing_lockers",
        },
    })

    -- MRPD Armory
    exports["caue-polyzone"]:AddBoxZone("caue-police:zone", vector3(481.59, -995.35, 30.69), 3.2, 0.8, {
        heading = 90,
        minZ = 29.69,
        maxZ = 32.49,
        data = {
            job = "police",
            action = "armory",
            zone = "mrpd_armory",
        },
    })

    -- MRPD Evidence
    exports["caue-polyzone"]:AddBoxZone("caue-police:zone", vector3(474.84, -996.26, 26.27), 1.2, 3.0, {
        heading = 90,
        minZ = 25.27,
        maxZ = 27.87,
        data = {
            job = "police",
            action = "evidence",
            zone = "mrpd_evidence",
        },
    })

    -- MRPD Trash
    exports["caue-polyzone"]:AddBoxZone("caue-police:zone", vector3(472.88, -996.28, 26.27), 1.2, 3.0, {
        heading = 90,
        minZ = 25.27,
        maxZ = 27.87,
        data = {
            job = "police",
            action = "trash",
            zone = "mrpd_trash",
        },
    })

    -- MRPD Character Switcher
    exports["caue-polyzone"]:AddBoxZone("caue-police:zone", vector3(478.88, -983.49, 30.69), 1.35, 1.3, {
        heading = 0,
        minZ = 29.74,
        maxZ = 32.74,
        data = {
            job = "police",
            action = "context",
            zone = "mrpd_character_switcher",
        },
    })

    -- SandyPD Lockers
    exports["caue-polyzone"]:AddBoxZone("caue-police:zone", vector3(1845.41, 3693.16, 34.27), 2.2, 4.0, {
        heading = 30,
        minZ = 33.27,
        maxZ = 35.67,
        data = {
            job = "state_police",
            action = "context",
            zone = "sandypd_lockers",
        },
    })

    -- SandyPD Armory
    exports["caue-polyzone"]:AddBoxZone("caue-police:zone", vector3(1862.43, 3689.6, 34.27), 1.4, 1.6, {
        heading = 31,
        minZ = 33.27,
        maxZ = 35.67,
        data = {
            job = "state_police",
            action = "armory",
            zone = "sandypd_armory",
        },
    })

    -- SandyPD Evidence
    exports["caue-polyzone"]:AddBoxZone("caue-police:zone", vector3(1849.79, 3694.44, 30.27), 4.2, 1.8, {
        heading = 31,
        minZ = 29.27,
        maxZ = 31.47,
        data = {
            job = "state_police",
            action = "context",
            zone = "sandypd_evidence",
        },
    })

    -- SandyPD Character Switcher
    exports["caue-polyzone"]:AddBoxZone("caue-police:zone", vector3(1840.86, 3691.58, 34.27), 1.0, 1.0, {
        heading = 30,
        minZ = 33.27,
        maxZ = 35.67,
        data = {
            job = "state_police",
            action = "context",
            zone = "sandypd_character_switcher",
        },
    })


    -- PaletoPD Lockers
    exports["caue-polyzone"]:AddBoxZone("caue-police:zone", vector3(-454.0, 6014.58, 31.72), 4.6, 3.2, {
        heading = 45,
        minZ = 30.72,
        maxZ = 32.92,
        data = {
            job = "sheriff",
            action = "context",
            zone = "paletopd_lockers",
        },
    })

    -- PaletoPD Armory
    exports["caue-polyzone"]:AddBoxZone("caue-police:zone", vector3(-437.23, 6001.11, 31.72), 1.0, 2.8, {
        heading = 45,
        minZ = 30.72,
        maxZ = 32.92,
        data = {
            job = "sheriff",
            action = "armory",
            zone = "paletopd_armory",
        },
    })

    -- PaletoPD Evidence
    exports["caue-polyzone"]:AddBoxZone("caue-police:zone", vector3(-439.05, 6010.63, 27.99), 1.6, 2.0, {
        heading = 45,
        minZ = 26.99,
        maxZ = 29.19,
        data = {
            job = "sheriff",
            action = "context",
            zone = "paletopd_evidence",
        },
    })

    -- PaletoPD Character Switcher
    exports["caue-polyzone"]:AddBoxZone("caue-police:zone", vector3(-450.28, 6021.0, 31.72), 1.6, 0.8, {
        heading = 45,
        minZ = 30.72,
        maxZ = 32.92,
        data = {
            job = "sheriff",
            action = "context",
            zone = "paletopd_character_switcher",
        },
    })

    -- Park Rangers Station
    exports["caue-polyzone"]:AddBoxZone("caue-police:zone", vector3(384.76, 794.23, 187.68), 2.0, 1.95, {
        heading = 0,
        minZ = 186.68,
        maxZ = 189.08,
        data = {
            job = "park_ranger",
            action = "context",
            zone = "park_rangers_station",
        },
    })

    -- DOC Lockers
    exports["caue-polyzone"]:AddBoxZone("caue-police:zone", vector3(1770.14, 2517.32, 45.83), 4.15, 0.75, {
        heading = 30,
        minZ = 44.83,
        maxZ = 47.43,
        data = {
            job = "doc",
            action = "context",
            zone = "doc_lockers",
        },
    })

    -- DOC Armory
    exports["caue-polyzone"]:AddBoxZone("caue-police:zone", vector3(1771.97, 2514.02, 45.83), 1.0, 0.65, {
        heading = 30,
        minZ = 44.83,
        maxZ = 47.43,
        data = {
            job = "doc",
            action = "armory",
            zone = "doc_armory",
        },
    })

    -- DOC Trash
    exports["caue-polyzone"]:AddCircleZone("caue-police:zone", vector3(1771.26, 2497.24, 50.43), 0.4, {
        useZ = true,
        data = {
            job = "doc",
            action = "trash",
            zone = "doc_trash",
        },
    })




    -- DUI STUFF HERE
    local duiObj = CreateDui("https://i.imgur.com/10TqWXk.jpg", 539, 569)
     _G.duiObj = duiObj
    local dui = GetDuiHandle(duiObj)
    local txd = CreateRuntimeTxd("duiTxd")
    local tx = CreateRuntimeTextureFromDuiHandle(txd, "duiTex", dui)
end)