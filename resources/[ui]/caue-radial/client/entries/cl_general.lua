local GeneralEntries = MenuEntries["general"]

GeneralEntries[#GeneralEntries+1] = {
    data = {
        id = "vehicles",
        title = "Vehicle",
        icon = "#vehicle-options-vehicle",
        event = "veh:options"
    },
    isEnabled = function(pEntity, pContext)
        return not isDisabled() and IsPedInAnyVehicle(PlayerPedId(), false)
    end
}

GeneralEntries[#GeneralEntries+1] = {
    data = {
        id = "vehicles-keysgive",
        title = "Give Keys",
        icon = "#general-keys-give",
        event = "vehicle:giveKey"
    },
    isEnabled = function(pEntity, pContext)
        return not isDisabled() and IsPedInAnyVehicle(PlayerPedId(), false) and exports["caue-vehicles"]:HasVehicleKey(GetVehiclePedIsIn(PlayerPedId(), false))
    end
}

GeneralEntries[#GeneralEntries+1] = {
    data = {
        id = "peds-escort",
        title = "Stop escorting",
        icon = "#general-escort",
        event = "caue-police:escort"
    },
    isEnabled = function(pEntity, pContext)
        return not isDisabled() and DecorGetInt(PlayerPedId(), "escorting") ~= 0
    end
}

GeneralEntries[#GeneralEntries+1] = {
    data = {
        id = "poledance:toggle",
        title = "Poledance",
        icon = "#poledance-toggle",
        event = "poledance:toggle"
    },
    isEnabled = function(pEntity, pContext)
        return not isDisabled() and polyChecks.vanillaUnicorn.isInside and not exports["caue-flags"]:HasPedFlag(PlayerPedId(), "isPoledancing")
    end
}

GeneralEntries[#GeneralEntries+1] = {
    data = {
        id = "poledance:toggle",
        title = "Stop poledancing",
        icon = "#poledance-toggle",
        event = "poledance:toggle"
    },
    isEnabled = function(pEntity, pContext)
        return not isDisabled() and polyChecks.vanillaUnicorn.isInside and exports["caue-flags"]:HasPedFlag(PlayerPedId(), "isPoledancing")
    end
}

GeneralEntries[#GeneralEntries+1] = {
    data = {
        id = "oxygentank",
        title = "Remove Oxygen Tank",
        icon = "#oxygen-mask",
        event = "RemoveOxyTank"
    },
    isEnabled = function(pEntity, pContext)
        return not isDisabled() and hasOxygenTankOn
    end
}


GeneralEntries[#GeneralEntries+1] = {
    data = {
        id = "policeDeadA",
        title = "10-13A",
        icon = "#police-dead",
        event = "police:tenThirteenA",
    },
    isEnabled = function(pEntity, pContext)
        return exports["caue-base"]:getVar("dead") and (exports["caue-jobs"]:getJob(CurrentJob, "is_police") or CurrentJob == "doc")
    end
}


GeneralEntries[#GeneralEntries+1] = {
    data = {
        id = "policeDeadB",
        title = "10-13B",
        icon = "#police-dead",
        event = "police:tenThirteenB",
    },
    isEnabled = function(pEntity, pContext)
        return exports["caue-base"]:getVar("dead") and (exports["caue-jobs"]:getJob(CurrentJob, "is_police") or CurrentJob == "doc")
    end
}

GeneralEntries[#GeneralEntries+1] = {
    data = {
        id = "emsDeadA",
        title = "10-14A",
        icon = "#ems-dead",
        event = "police:tenForteenA",
    },
    isEnabled = function(pEntity, pContext)
        return exports["caue-base"]:getVar("dead") and exports["caue-jobs"]:getJob(false, "is_medic")
    end
}

GeneralEntries[#GeneralEntries+1] = {
    data = {
        id = "emsDeadB",
        title = "10-14B",
        icon = "#ems-dead",
        event = "police:tenForteenB",
    },
    isEnabled = function(pEntity, pContext)
        return exports["caue-base"]:getVar("dead") and exports["caue-jobs"]:getJob(false, "is_medic")
    end
}


GeneralEntries[#GeneralEntries+1] = {
    data = {
        id = "unseat",
        title = "Get up",
        icon = "#obj-chair",
        event = "caue-emotes:sitOnChair"
    },
    isEnabled = function(pEntity, pContext)
        return not exports["caue-base"]:getVar("dead") and exports["caue-flags"]:HasPedFlag(PlayerPedId(), "isSittingOnChair")
    end
}

GeneralEntries[#GeneralEntries+1] = {
    data = {
        id = "property-enter",
        title = "Enter Property",
        icon = "#property-enter",
        event = "housing:interactionTriggered"
    },
    isEnabled = function(pEntity, pContext)
        return not exports["caue-base"]:getVar("dead") and exports["caue-housing"]:isNearProperty()
    end
}

GeneralEntries[#GeneralEntries+1] = {
    data = {
        id = "property-lock",
        title = "Unlock/Lock Property",
        icon = "#property-lock",
        event = "housing:toggleClosestLock"
    },
    isEnabled = function(pEntity, pContext)
        return not exports["caue-base"]:getVar("dead") and exports["caue-housing"]:isNearProperty(true)
    end
}

GeneralEntries[#GeneralEntries+1] = {
    data = {
        id = "vehicle-vehicleList",
        title = "Vehicle List",
        icon = "#vehicle-vehicleList",
        event = "caue-vehicles:garage",
        parameters = { nearby = true, radius = 4.0 }
    },
    isEnabled = function(pEntity, pContext)
        return not isDisabled() and not IsPedInAnyVehicle(PlayerPedId()) and (pEntity and pContext.flags["isVehicleSpawner"] or not pEntity and exports["caue-vehicles"]:IsOnParkingSpot(PlayerPedId(), true, 4.0))
    end
}

GeneralEntries[#GeneralEntries+1] = {
    data = {
        id = "fishing-borrowBoat",
        title = "Borrow Fishing Boat",
        icon = "#vehicle-vehicleList",
        event = "np-fishing:rentBoat",
        parameters = { nearby = true, radius = 4.0 }
    },
    isEnabled = function(pEntity, pContext)
        return not isDisabled() and not IsPedInAnyVehicle(PlayerPedId()) and (pEntity and pContext.flags["isBoatRenter"])
    end
}

local canDropGoods = false
local canDropGoodsTimer = nil
AddEventHandler("np-jobs:247delivery:takeGoods", function()
    canDropGoods = true
    canDropGoodsTimer = GetGameTimer()
end)
AddEventHandler("np-jobs:247delivery:dropGoods", function()
    canDropGoods = false
    canDropGoodsTimer = nil
end)

GeneralEntries[#GeneralEntries+1] = {
    data = {
        id = "job-drop-goods",
        title = "Drop Goods",
        icon = "#property-lock",
        event = "np-jobs:247delivery:dropGoods"
    },
    isEnabled = function(pEntity, pContext)
        return canDropGoods and canDropGoodsTimer + 15000 < GetGameTimer()
    end
}

GeneralEntries[#GeneralEntries+1] = {
    data = {
        id = "dispatch:openDispatch",
        title = "Dispatch",
        icon = "#general-check-over-target",
        event = "np-dispatch:openFull"
    },
    isEnabled = function()
        return (exports["caue-jobs"]:getJob(CurrentJob, "is_police") or exports["caue-jobs"]:getJob(CurrentJob, "is_medic")) and not exports["caue-base"]:getVar("dead")
    end
}

GeneralEntries[#GeneralEntries+1] = {
    data = {
        id = "emotes:openmenu",
        title = "Emotes",
        icon = "#general-emotes",
        event = "emotes:OpenMenu"
    },
    isEnabled = function(pEntity, pContext)
        return not exports["caue-base"]:getVar("dead")
    end
}

GeneralEntries[#GeneralEntries+1] = {
    data = {
        id = "drivingInstructor:testToggle",
        title = "Driving Test",
        icon = "#drivinginstructor-drivingtest",
        event = "drivingInstructor:testToggle"
    },
    isEnabled = function(pEntity, pContext)
        return not exports["caue-base"]:getVar("dead") and isInstructorMode
    end
}

GeneralEntries[#GeneralEntries+1] = {
    data = {
        id = "drivingInstructor:submitTest",
        title = "Submit Test",
        icon = "#drivinginstructor-submittest",
        event = "drivingInstructor:submitTest"
    },
    isEnabled = function(pEntity, pContext)
        return not exports["caue-base"]:getVar("dead") and isInstructorMode
    end
}

GeneralEntries[#GeneralEntries+1] = {
    data = {
        id = "general:checkoverself",
        title = "Examine Self",
        icon = "#general-check-over-self",
        event = "Evidence:CurrentDamageList"
    },
    isEnabled = function(pEntity, pContext)
        return not exports["caue-base"]:getVar("dead")
    end
}

-- GeneralEntries[#GeneralEntries+1] = {
--     data = {
--         id = "bennys:enter",
--         title = "Enter Bennys",
--         icon = "#general-check-vehicle",
--         event = "bennys:enter"
--     },
--     isEnabled = function(pEntity, pContext)
--         return not isDisabled() and polyChecks.bennys.isInside and IsPedInAnyVehicle(PlayerPedId(), false) and GetPedInVehicleSeat(GetVehiclePedIsIn(PlayerPedId(), false), -1) == PlayerPedId()
--     end
-- }

GeneralEntries[#GeneralEntries+1] = {
    data = {
      id = "toggle-anchor",
      title = "Toggle Anchor",
      icon = "#vehicle-anchor",
      event = "client:anchor"
    },
    isEnabled = function(pEntity, pContext)
        local currentVehicle = GetVehiclePedIsIn(PlayerPedId(), false)
        local boatModel = GetEntityModel(currentVehicle)
        return not isDisabled() and currentVehicle ~= 0 and (IsThisModelABoat(boatModel) or IsThisModelAJetski(boatModel) or IsThisModelAnAmphibiousCar(boatModel) or IsThisModelAnAmphibiousQuadbike(boatModel))
    end
}

GeneralEntries[#GeneralEntries+1] = {
    data = {
      id = "mdw",
      title = "MDW",
      icon = "#mdt",
      event = "np-ui:openMDW"
    },
    isEnabled = function()
        return not exports["caue-base"]:getVar("dead") and exports["caue-jobs"]:getJob(CurrentJob, "is_police")
    end
}

GeneralEntries[#GeneralEntries+1] = {
    data = {
        id = "prepare-boat-mount",
        title = "Mount on Trailer",
        icon = "#vehicle-plate-remove",
        event = "vehicle:mountBoatOnTrailer"
    },
    isEnabled = function()
        local ped = PlayerPedId()
        local veh = GetVehiclePedIsIn(ped)
        if veh == 0 then
            return false
        end
        local seat = GetPedInVehicleSeat(veh, -1)
        if seat ~= ped then
            return false
        end
        local model = GetEntityModel(veh)
        if isDisabled() or not (IsThisModelABoat(model) or IsThisModelAJetski(model) or IsThisModelAnAmphibiousCar(model)) then
            return false
        end
        local left, right = GetModelDimensions(model)
        return #(vector3(0, left.y, 0) - vector3(0, right.y, 0)) < 15
    end
}

local currentJob = nil
local policeModels = {
    [`npolvic`] = true,
}

GeneralEntries[#GeneralEntries+1] = {
    data = {
        id = "open-rifle-rack",
        title = "Rifle Rack",
        icon = "#vehicle-plate-remove",
        event = "vehicle:openRifleRack"
    },
    isEnabled = function(pEntity)
        if not exports["caue-jobs"]:getJob(CurrentJob, "is_police") then return false end
        local veh = GetVehiclePedIsIn(PlayerPedId())
        if veh == 0 then return false end
        local model = GetEntityModel(veh)
        if policeModels[model] == nil then return false end
        return true
    end
}

AddEventHandler("vehicle:openRifleRack", function()
    local finished = exports["caue-taskbar"]:taskBar(2500, "Unlocking...")
    if finished ~= 100 then return end
    local veh = GetVehiclePedIsIn(PlayerPedId())
    if veh == 0 then return end
    local vehId = exports["caue-vehicles"]:GetVehicleIdentifier(veh)
    TriggerEvent("server-inventory-open", "1", "rifle-rack-" .. vehId)
end)

GeneralEntries[#GeneralEntries+1] = {
    data = {
        id = "open-documents",
        title = "Documents",
        icon = "#general-documents",
        event = "caue-documents:openDocuments"
    },
    isEnabled = function()
        return not exports["caue-base"]:getVar("dead")
    end
}