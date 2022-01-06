local Entries = {}

Entries[#Entries + 1] = {
    type = "entity",
    group = { 2 },
    data = {
        {
            id = "vehicle_flip",
            label = "Flip Vehicle",
            icon = "car-crash",
            event = "FlipVehicle",
            parameters = {}
        }
    },
    options = {
        distance = { radius = 3.0 },
        isEnabled = function(pEntity, pContext)
            return not IsVehicleOnAllWheels(pEntity)
        end
    }
}

Entries[#Entries + 1] = {
    type = "entity",
    group = { 2 },
    data = {
        {
            id = "vehicle_getintrunk",
            label = "Enter trunk",
            icon = "user-secret",
            event = "vehicle:getInTrunk",
            parameters = {}
        }
    },
    options = {
        distance = { radius = 3.0 },
        isEnabled = function(pEntity, pContext)
            return isVehicleDoorOpen(pEntity, getTrunkDoor(pEntity, pContext.model)) and isCloseToBoot(pEntity, PlayerPedId(), 1.8, pContext.model)
        end
    }
}

Entries[#Entries + 1] = {
    type = "entity",
    group = { 2 },
    data = {
        {
            id = "vehicle_runplate",
            label = "Run Plate",
            icon = "money-check",
            event = "clientcheckLicensePlate",
            parameters = {}
        }
    },
    options = {
        distance = { radius = 3.0 },
        isEnabled = function(pEntity, pContext)
            return exports["caue-jobs"]:getJob(false, "is_police") and isCloseToBoot(pEntity, PlayerPedId(), 1.8, pContext.model) and not IsPedInAnyVehicle(PlayerPedId(), false)
        end
    }
}

Entries[#Entries + 1] = {
    type = "entity",
    group = { 2 },
    data = {
        {
            id = "vehicle_inspectvin",
            label = "Check VIN",
            icon = "sim-card",
            event = "vehicle:checkVIN",
            parameters = {}
        }
    },
    options = {
        distance = { radius = 3.0 },
        isEnabled = function(pEntity, pContext)
            return isCloseToHood(pEntity, PlayerPedId()) and (exports["caue-jobs"]:getJob(false, "is_police") or exports["caue-jobs"]:getJob(false, "is_medic")) and not IsPedInAnyVehicle(PlayerPedId(), false)
        end
    }
}

Entries[#Entries + 1] = {
    type = "entity",
    group = { 2 },
    data = {
        {
            id = "vehicle_add_fakeplate",
            label = "Add Fakeplate",
            icon = "screwdriver",
            event = "vehicle:addFakePlate",
            parameters = {}
        }
    },
    options = {
        distance = { radius = 3.0 },
        isEnabled = function(pEntity, pContext)
            return isCloseToBoot(pEntity, PlayerPedId(), 1.8, pContext.model) and not IsPedInAnyVehicle(PlayerPedId(), false)
            and exports["caue-vehicles"]:HasVehicleKey(pEntity) and exports["caue-inventory"]:hasEnoughOfItem("fakeplate", 1, false)
            and not exports["caue-vehicles"]:GetVehicleMetadata(pEntity, "fakePlate")
        end
    }
}

Entries[#Entries + 1] = {
    type = "entity",
    group = { 2 },
    data = {
        {
            id = "vehicle_remove_fakeplate",
            label = "Remove Fakeplate",
            icon = "ban",
            event = "vehicle:removeFakePlate",
            parameters = {}
        }
    },
    options = {
        distance = { radius = 3.0 },
        isEnabled = function(pEntity, pContext)
            return isCloseToBoot(pEntity, PlayerPedId(), 1.8, pContext.model) and not IsPedInAnyVehicle(PlayerPedId(), false)
            and exports["caue-vehicles"]:HasVehicleKey(pEntity) and exports["caue-vehicles"]:GetVehicleMetadata(pEntity, "fakePlate")
        end
    }
}

Entries[#Entries + 1] = {
    type = "entity",
    group = { 2 },
    data = {
        {
            id = "vehicle_examine",
            label = "Examine Vehicle",
            icon = "wrench",
            event = "caue-vehicles:examineVehicle",
            parameters = {}
        }
    },
    options = {
        distance = { radius = 1.8, boneId = "engine" },
        isEnabled = function(pEntity, pContext)
            return isVehicleDoorOpen(pEntity, getEngineDoor(pEntity, pContext.model)) and isCloseToEngine(pEntity, PlayerPedId(), 1.8, pContext.model)
        end
    }
}

Entries[#Entries + 1] = {
    type = "entity",
    group = { 2 },
    data = {
        {
            id = "vehicle_refuel_station",
            label = "Refuel Vehicle",
            icon = "gas-pump",
            event = "caue-vehicles:refuel",
            parameters = {}
        }
    },
    options = {
        distance = { radius = 1.2, boneId = "wheel_lr" },
        isEnabled = function(pEntity, pContext)
            return polyChecks.gasStation.isInside and canRefuelHere(pEntity, polyChecks.gasStation.polyData)
        end
    }
}

Entries[#Entries + 1] = {
    type = "entity",
    group = { 2 },
    data = {
        {
            id = "vehicle_refuel_jerrycan",
            label = "Refuel Vehicle",
            icon = "gas-pump",
            event = "vehicle:refuel:jerryCan",
            parameters = {}
        }
    },
    options = {
        distance = { radius = 1.2, boneId = "wheel_lr" },
        isEnabled = function(pEntity, pContext)
            return HasWeaponEquipped(883325847) -- WEAPON_PetrolCan
        end
    }
}

Entries[#Entries + 1] = {
    type = "entity",
    group = { 2 },
    data = {
        {
            id = "vehicle_putinvehicle",
            label = "seat in vehicle",
            icon = "chevron-circle-left",
            event = "police:forceEnter",
            parameters = {}
        },
        {
            id = "vehicle_unseatnearest",
            label = "unseat from vehicle",
            icon = "chevron-circle-right",
            event = "unseatPlayer",
            parameters = {}
        }
    },
    options = {
        distance = { radius = 4.0 },
        isEnabled = function(pEntity, pContext)
            return (not (isCloseToHood(pEntity, PlayerPedId()) or isCloseToBoot(pEntity, PlayerPedId(), 1.8, pContext.model)) or pContext.model == GetHashKey("emsnspeedo")) and not IsPedInAnyVehicle(PlayerPedId(), false) and not pContext.flags["isCarShopVehicle"]
        end
    }
}

Entries[#Entries + 1] = {
    type = "entity",
    group = { 2 },
    data = {
        {
            id = "vehicle_keysgive",
            label = "give key",
            icon = "key",
            event = "vehicle:giveKey",
            parameters = {}
        }
    },
    options = {
        distance = { radius = 1.8 },
        isEnabled = function(pEntity, pContext)
            return hasKeys(pEntity)
        end
    }
}

Entries[#Entries + 1] = {
    type = "flag",
    group = { "isWheelchair" },
    data = {
        {
            id = "wheelchair",
            label = "toggle wheelchair",
            icon = "wheelchair",
            event = "np:vehicle:wheelchair:control",
            parameters = {}
        }
    },
    options = {
        distance = { radius = 0.9, boneId = "misc_a" }
    }
}


Entries[#Entries + 1] = {
    type = "flag",
    group = { "isTowTruck" },
    data = {
        {
            id = "towtruck_tow",
            label = "tow vehicle",
            icon = "trailer",
            event = "jobs:towVehicle",
            parameters = {}
        }
    },
    options = {
        job = { "towtruck" },
        distance = { radius = 2.5, boneId = "wheel_lr" },
        isEnabled = function (pEntity, pContext)
            return not pContext.flags["isTowingVehicle"]
        end
    }
}

Entries[#Entries + 1] = {
    type = "flag",
    group = { "isTowTruck" },
    data = {
        {
            id = "towtruck_untow",
            label = "untow vehicle",
            icon = "trailer",
            event = "jobs:untowVehicle",
            parameters = {}
        }
    },
    options = {
        job = { "towtruck" },
        distance = { radius = 2.5, boneId = "wheel_lr" },
        isEnabled = function (pEntity, pContext)
            return pContext.flags["isTowingVehicle"]
        end
    }
}

Entries[#Entries + 1] = {
    type = "model",
    group = { GetHashKey("trash2") },
    data = {
        {
            id = "sanitation_worker_throw_trash",
            label = "throw in trash",
            icon = "trash-restore-alt",
            event = "np-jobs:sanitationWorker:vehicleTrash",
            parameters = {}
        }
    },
    options = {
        job = { "sanitation_worker" },
        distance = { radius = 3.8, boneId = "wheel_lr" },
        isEnabled = function (pEntity, pContext)
            return isCloseToTrunk(pEntity, PlayerPedId(), 1.1, true)
        end
    }
}

Entries[#Entries + 1] = {
    type = "model",
    group = { GetHashKey("benson") },
    data = {
        {
            id = "247_deliveries_take_goods",
            label = "Grab goods",
            icon = "box",
            event = "np-jobs:247delivery:takeGoods",
            parameters = {}
        }
    },
    options = {
        job = { "247_deliveries" },
        distance = { radius = 2.0, boneId = "boot" },
        isEnabled = function (pEntity, pContext)
            return isCloseToTrunk(pEntity, PlayerPedId())
        end
    }
}


Entries[#Entries + 1] = {
    type = "entity",
    group = { 2 },
    data = {
        {
            id = "vehicle_repair_brake",
            label = "Repair Brake",
            icon = "wrench",
            event = "caue-vehicles:repairVehicle",
            parameters = "brake"
        }
    },
    options = {
        distance = { radius = 1.8, boneId = "engine" },
        isEnabled = function(pEntity, pContext)
            return isVehicleDoorOpen(pEntity, 4) and isCloseToEngine(pEntity, PlayerPedId(), 1.8, pContext.model) and hasRepairItems("brake")
        end
    }
}

Entries[#Entries + 1] = {
    type = "entity",
    group = { 2 },
    data = {
        {
            id = "vehicle_repair_axle",
            label = "Repair Axle",
            icon = "wrench",
            event = "caue-vehicles:repairVehicle",
            parameters = "axle"
        }
    },
    options = {
        distance = { radius = 1.8, boneId = "engine" },
        isEnabled = function(pEntity, pContext)
            return isVehicleDoorOpen(pEntity, 4) and isCloseToEngine(pEntity, PlayerPedId(), 1.8, pContext.model) and hasRepairItems("axle")
        end
    }
}

Entries[#Entries + 1] = {
    type = "entity",
    group = { 2 },
    data = {
        {
            id = "vehicle_repair_radiator",
            label = "Repair Radiator",
            icon = "wrench",
            event = "caue-vehicles:repairVehicle",
            parameters = "radiator"
        }
    },
    options = {
        distance = { radius = 1.8, boneId = "engine" },
        isEnabled = function(pEntity, pContext)
            return isVehicleDoorOpen(pEntity, 4) and isCloseToEngine(pEntity, PlayerPedId(), 1.8, pContext.model) and hasRepairItems("radiator")
        end
    }
}

Entries[#Entries + 1] = {
    type = "entity",
    group = { 2 },
    data = {
        {
            id = "vehicle_repair_clutch",
            label = "Repair Clutch",
            icon = "wrench",
            event = "caue-vehicles:repairVehicle",
            parameters = "clutch"
        }
    },
    options = {
        distance = { radius = 1.8, boneId = "engine" },
        isEnabled = function(pEntity, pContext)
            return isVehicleDoorOpen(pEntity, 4) and isCloseToEngine(pEntity, PlayerPedId(), 1.8, pContext.model) and hasRepairItems("clutch")
        end
    }
}

Entries[#Entries + 1] = {
    type = "entity",
    group = { 2 },
    data = {
        {
            id = "vehicle_repair_transmission",
            label = "Repair Transmission",
            icon = "wrench",
            event = "caue-vehicles:repairVehicle",
            parameters = "transmission"
        }
    },
    options = {
        distance = { radius = 1.8, boneId = "engine" },
        isEnabled = function(pEntity, pContext)
            return isVehicleDoorOpen(pEntity, 4) and isCloseToEngine(pEntity, PlayerPedId(), 1.8, pContext.model) and hasRepairItems("transmission")
        end
    }
}

Entries[#Entries + 1] = {
    type = "entity",
    group = { 2 },
    data = {
        {
            id = "vehicle_repair_electronics",
            label = "Repair Electronics",
            icon = "wrench",
            event = "caue-vehicles:repairVehicle",
            parameters = "electronics"
        }
    },
    options = {
        distance = { radius = 1.8, boneId = "engine" },
        isEnabled = function(pEntity, pContext)
            return isVehicleDoorOpen(pEntity, 4) and isCloseToEngine(pEntity, PlayerPedId(), 1.8, pContext.model) and hasRepairItems("electronics")
        end
    }
}

Entries[#Entries + 1] = {
    type = "entity",
    group = { 2 },
    data = {
        {
            id = "vehicle_repair_injector",
            label = "Repair Injector",
            icon = "wrench",
            event = "caue-vehicles:repairVehicle",
            parameters = "injector"
        }
    },
    options = {
        distance = { radius = 1.8, boneId = "engine" },
        isEnabled = function(pEntity, pContext)
            return isVehicleDoorOpen(pEntity, 4) and isCloseToEngine(pEntity, PlayerPedId(), 1.8, pContext.model) and hasRepairItems("injector")
        end
    }
}

Entries[#Entries + 1] = {
    type = "entity",
    group = { 2 },
    data = {
        {
            id = "vehicle_repair_tire",
            label = "Repair Tire",
            icon = "wrench",
            event = "caue-vehicles:repairVehicle",
            parameters = "tire"
        }
    },
    options = {
        distance = { radius = 1.8, boneId = "engine" },
        isEnabled = function(pEntity, pContext)
            return isVehicleDoorOpen(pEntity, 4) and isCloseToEngine(pEntity, PlayerPedId(), 1.8, pContext.model) and hasRepairItems("tire")
        end
    }
}

Entries[#Entries + 1] = {
    type = "entity",
    group = { 2 },
    data = {
        {
            id = "vehicle_repair_body",
            label = "Repair Body",
            icon = "wrench",
            event = "caue-vehicles:repairVehicle",
            parameters = "body"
        }
    },
    options = {
        distance = { radius = 1.8, boneId = "engine" },
        isEnabled = function(pEntity, pContext)
            return isVehicleDoorOpen(pEntity, 4) and isCloseToEngine(pEntity, PlayerPedId(), 1.8, pContext.model) and hasRepairItems("body")
        end
    }
}

Entries[#Entries + 1] = {
    type = "entity",
    group = { 2 },
    data = {
        {
            id = "vehicle_repair_engine",
            label = "Repair Engine",
            icon = "wrench",
            event = "caue-vehicles:repairVehicle",
            parameters = "engine"
        }
    },
    options = {
        distance = { radius = 1.8, boneId = "engine" },
        isEnabled = function(pEntity, pContext)
            return isVehicleDoorOpen(pEntity, 4) and isCloseToEngine(pEntity, PlayerPedId(), 1.8, pContext.model) and hasRepairItems("engine")
        end
    }
}



Citizen.CreateThread(function()
    for _, entry in ipairs(Entries) do
        if entry.type == "flag" then
            AddPeekEntryByFlag(entry.group, entry.data, entry.options)
        elseif entry.type == "model" then
            AddPeekEntryByModel(entry.group, entry.data, entry.options)
        elseif entry.type == "entity" then
            AddPeekEntryByEntityType(entry.group, entry.data, entry.options)
        elseif entry.type == "polytarget" then
            AddPeekEntryByPolyTarget(entry.group, entry.data, entry.options)
        end
    end
end)