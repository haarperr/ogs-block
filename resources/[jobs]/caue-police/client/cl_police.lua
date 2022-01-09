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
    davispd_clothing_lockers = {
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
    davispd_armory = {
        promptText = "[E] Armory"
    },
    davispd_evidence = {
        promptText = "[E] Evidence"
    },
    davispd_trash = {
        promptText = "[E] Trash"
    },
    davispd_character_switcher = {
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
    end
end)

AddEventHandler("caue-polyzone:exit", function(pZoneName, pZoneData)
    if pZoneName == "caue-police:zone" then
        exports["caue-interaction"]:hideInteraction()
        listening = false
        currentPrompt = nil
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
    -- davispd Lockers
    exports["caue-polyzone"]:AddBoxZone("caue-police:zone", vector3(361.28, -1592.54, 25.45), 4.4, 1.0, {
        heading = 320,
        minZ = 24.45,
        maxZ = 26.45,
        data = {
            job = "police",
            action = "context",
            zone = "davispd_clothing_lockers",
        },
    })

    -- davispd Armory
    exports["caue-polyzone"]:AddBoxZone("caue-police:zone", vector3(364.94, -1603.51, 25.45), 0.8, 4.0, {
        heading = 50,
        minZ = 24.45,
        maxZ = 26.65,
        data = {
            job = "police",
            action = "armory",
            zone = "davispd_armory",
        },
    })

    -- davispd Evidence
    exports["caue-polyzone"]:AddBoxZone("caue-police:zone", vector3(380.61, -1608.74, 30.2), 4.0, 2.0, {
        heading = 320,
        minZ = 29.2,
        maxZ = 31.6,
        data = {
            job = "police",
            action = "evidence",
            zone = "davispd_evidence",
        },
    })

    -- davispd Trash
    exports["caue-polyzone"]:AddBoxZone("caue-police:zone", vector3(472.88, -996.28, 26.27), 1.2, 3.0, {
        heading = 90,
        minZ = 25.27,
        maxZ = 27.87,
        data = {
            job = "police",
            action = "trash",
            zone = "davispd_trash",
        },
    })

    -- davispd Character Switcher
    exports["caue-polyzone"]:AddBoxZone("caue-police:zone", vector3(358.28, -1598.11, 25.45), 1.0, 4.8, {
        heading = 320,
        minZ = 24.45,
        maxZ = 26.85,
        data = {
            job = "police",
            action = "context",
            zone = "davispd_character_switcher",
        },
    })

    exports["caue-polyzone"]:AddBoxZone("caue-police:zone", vector3(366.34, -1588.5, 25.45), 1.0, 4.8, {
        heading = 320,
        minZ = 24.45,
        maxZ = 26.85,
        data = {
            job = "police",
            action = "context",
            zone = "davispd_character_switcher",
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
end)