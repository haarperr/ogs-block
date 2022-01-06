--[[

    Events

]]

AddEventHandler("caue-ems:showVehicles", function()
    local data = {}
    local ownedVehicles = RPC.execute("caue-vehicles:ownedVehiclesModels")

    for _, vehicle in ipairs(Config["Vehicles"]) do
        if vehicle.first_free and not has_value(ownedVehicles, vehicle.model) then
            vehicle.price = 1
        end

        table.insert(data, {
            title = vehicle.name,
            description = "$" .. vehicle.price,
            image = vehicle.image,
            children = {
                { title = "Confirm Purchase", action = "caue-ems:purchaseVehicle", params = vehicle },
            },
        })
    end

    exports["caue-context"]:showContext(data)
end)

AddEventHandler("caue-ems:purchaseVehicle", function(params)
    if IsAnyVehicleNearPoint(Config["Spawn"]["x"], Config["Spawn"]["y"], Config["Spawn"]["z"], 3.0) then
        TriggerEvent("DoLongHudText", "Vehicle in the way", 2)
        return
    end

    TriggerServerEvent("caue-ems:purchaseVehicle", params)
end)

--[[

    Threads

]]

Citizen.CreateThread(function()
    Citizen.Wait(1000)

    exports["caue-npcs"]:RegisterNPC(Config["NPC"])

    local group = { "isEmsVehicleSeller" }

    local data = {
        {
            id = "ems_vehicles",
            label = "EMS Vehicles",
            icon = "ambulance",
            event = "caue-ems:showVehicles",
            parameters = {},
        }
    }

    local options = {
        distance = { radius = 2.5 },
        isEnabled = function()
            return exports["caue-jobs"]:getJob(false, "is_medic")
        end
    }

    exports["caue-eye"]:AddPeekEntryByFlag(group, data, options)

    local images = {}
    for _, vehicle in ipairs(Config["Vehicles"]) do
        table.insert(images, vehicle.image)
    end

    TriggerEvent("caue-context:preLoadImages", images)
end)