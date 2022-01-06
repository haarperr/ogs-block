--[[

    Variables

]]

local vehiclesGarage = {}

local nearGarage = {
    ["garage"] = "",
    ["space"] = 0,
    ["coords"] = nil,
}

local Garages = {}

--[[

    Functions

]]

function IsOnParkingSpot(pEntity, pCheck, pRadius)
    local entityCoords = GetEntityCoords(pEntity)

    local garage = nil
    for k, v in pairs(Garages) do
        if #(entityCoords - v["pos"]["xyz"]) < v["distance"] then
            garage = k
            break
        end
    end

    if not garage then
        return false
    end

    local radius = 2.0
    if pRadius then
        radius = pRadius
    end

    local space = nil
    local nearest = 999.99
    for i, v in ipairs(Garages[garage]["spaces"]) do
        local distance = #(entityCoords - v["xyz"])
        if distance < radius and distance < nearest then
            if pCheck and not IsAnyVehicleNearPoint(v["x"], v["y"], v["z"], radius) then
                space = i
                nearest = distance
            else
                space = i
                nearest = distance
            end
        end
    end

    if not space then
        return false
    end

    nearGarage = {
        ["garage"] = garage,
        ["space"] = space,
        ["coords"] = Garages[garage]["spaces"][space],
    }

    return true
end

--[[

    Exports

]]

exports("IsOnParkingSpot", IsOnParkingSpot)

--[[

    Events

]]

AddEventHandler("caue-vehicles:garage", function(params)
    local job = exports["caue-base"]:getChar("job")
    local garage = Garages[nearGarage["garage"]]

    if garage["jobGarage"] and garage["type"] ~= job then
        TriggerEvent("DoLongHudText", "You can't use this garage", 2)
        return
    end

    local vehiclesGarage = RPC.execute("caue-vehicles:getGarage", nearGarage["garage"])

    local data = {}
    for i, v in ipairs(vehiclesGarage) do
        table.insert(data,{
            title = GetLabelText(GetDisplayNameFromVehicleModel(v["model"])),
            description = "Plate: " .. v["plate"],
            children = {
                { title = "Take Out Vehicle", action = "caue-vehicles:retriveVehicle", params = v["id"] },
                { title = "Vehicle Status", description = "Engine: " .. v["engine_damage"] / 10 .. "% | Body: " .. v["body_damage"] / 10 .. "% | Fuel: " .. v["fuel"] .. "%"},
            },
        })
    end

    exports["caue-context"]:showContext(data)
end)

AddEventHandler("caue-vehicles:retriveVehicle", function(vehID)
    local vehicle = RPC.execute("caue-vehicles:getVehicle", vehID)
    if vehicle then
        if not nearGarage["coords"] then return end

        TriggerEvent("caue-vehicles:spawnVehicle", vehicle.model, nearGarage["coords"], vehicle.id, vehicle.plate, vehicle.fuel, vehicle.modifications, vehicle.fakePlate, vehicle.harness, vehicle.body_damage, vehicle.engine_damage)
        RPC.execute("caue-vehicles:updateVehicle", vehicle.id, "garage", "state", "Out")
    end
end)

AddEventHandler("caue-vehicles:storeVehicle", function(params, vehicle)
    local vid = GetVehicleIdentifier(vehicle)
    if not vid then return end

    local garage = nearGarage["garage"]
    if garage == "" then return end

    local canStore = RPC.execute("caue-vehicles:canStoreVehicle", garage, vid)
    if not canStore then return end

    local store1 = RPC.execute("caue-vehicles:updateVehicle", vid, "garage", "garage", garage)
    if store1 then
        local store2 = RPC.execute("caue-vehicles:updateVehicle", vid, "garage", "state", "In")
        if store2 then
            Sync.DeleteVehicle(vehicle)
            Sync.DeleteEntity(vehicle)
        end
    end
end)

--[[

    Threads

]]

Citizen.CreateThread(function()
    Citizen.Wait(2000)

    Garages = RPC.execute("caue-vehicles:requestGarages")
end)