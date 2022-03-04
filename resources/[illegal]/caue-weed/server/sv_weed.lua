--[[

    Variables

]]

local WeedPlants = {}

--[[

    Functions

]]

function getPlantById(pPlantId)
    for _,plant in pairs(WeedPlants) do
        if plant.id == pPlantId then
            return plant
        end
    end
    return nil
end

--[[

    RPCs

]]

RPC.register("caue-weed:getPlants", function(src)
    TriggerClientEvent("caue-weed:trigger_zone", src, 1, WeedPlants)

    return true
end)

RPC.register("caue-weed:plantSeed", function(src, pCoords, pStrain)
    local pGender = 0
    local pTimestamp = os.time()

    local insertId = MySQL.insert.await([[
        INSERT INTO weed (gender, coords, strain, timestamp)
        VALUES (?, ?, ?, ?)
    ]],
    { pGender, json.encode(pCoords), json.encode(pStrain), pTimestamp })

    if not insertId or insertId < 1 then
        return false
    end

    local data = {
        id = insertId,
        gender = pGender,
        coords = pCoords,
        strain = pStrain,
        timestamp = pTimestamp,
        last_harvest = 0
    }

    table.insert(WeedPlants, data)

    TriggerClientEvent("caue-weed:trigger_zone", -1, 2, data)

    return true
end)

RPC.register("caue-weed:addWater", function(src, pPlantId)
    local plant = getPlantById(pPlantId)

    if plant == nil then
        return false
    end

    local strain = plant["strain"]
    strain["water"] = strain["water"] + PlantConfig.WaterAdd

    local affectedRows = MySQL.update.await([[
        UPDATE weed
        SET strain = ?
        WHERE id = ?
    ]],
    { json.encode(strain), pPlantId })

    if not affectedRows or affectedRows < 1 then
        return false
    end

    local data = {}
    for idx,plant in ipairs(WeedPlants) do
        if plant.id == pPlantId then
            WeedPlants[idx]["strain"] = strain
            data = WeedPlants[idx]
            break
        end
    end

    TriggerClientEvent("caue-weed:trigger_zone", -1, 3, data)

    return true
end)

RPC.register("caue-weed:addFertilizer", function(src, pPlantId, pType)
    local plant = getPlantById(pPlantId)

    if plant == nil then
        return false
    end

    local strain = plant["strain"]
    strain[pType] = strain[pType] + PlantConfig.FertilizerAdd

    local affectedRows = MySQL.update.await([[
        UPDATE weed
        SET strain = ?
        WHERE id = ?
    ]],
    { json.encode(strain), pPlantId })

    if not affectedRows or affectedRows < 1 then
        return false
    end

    local data = {}
    for idx,plant in ipairs(WeedPlants) do
        if plant.id == pPlantId then
            WeedPlants[idx]["strain"] = strain
            data = WeedPlants[idx]
            break
        end
    end

    TriggerClientEvent("caue-weed:trigger_zone", -1, 3, data)

    return true
end)

RPC.register("caue-weed:addMaleSeed", function(src, pPlantId)
    local plant = getPlantById(pPlantId)

    if plant == nil then
        return false
    end

    local affectedRows = MySQL.update.await([[
        UPDATE weed
        SET gender = 1
        WHERE id = ?
    ]],
    { pPlantId })

    if not affectedRows or affectedRows < 1 then
        return false
    end

    local data = {}
    for idx,plant in ipairs(WeedPlants) do
        if plant.id == pPlantId then
            WeedPlants[idx]["gender"] = 1
            data = WeedPlants[idx]
            break
        end
    end

    TriggerClientEvent("caue-weed:trigger_zone", -1, 3, data)

    return true
end)

RPC.register("caue-weed:removePlant", function(src, pPlantId, pFertilizer)
    local plant = getPlantById(pPlantId)

    if plant == nil then
        return false
    end

    local affectedRows = MySQL.update.await([[
        DELETE FROM weed
        WHERE id = ?
    ]],
    { pPlantId })

    if not affectedRows or affectedRows < 1 then
        return false
    end

    for idx,plant in ipairs(WeedPlants) do
        if plant.id == pPlantId then
            WeedPlants[idx] = nil
            break
        end
    end

    TriggerClientEvent("caue-weed:trigger_zone", -1, 4, { id = pPlantId })

    return true
end)

RPC.register("caue-weed:harvestPlant", function(src, pPlantId)
    local plant = getPlantById(pPlantId)

    if plant == nil then
        return false
    end

    local pTimestamp = os.time()

    local affectedRows = MySQL.update.await([[
        UPDATE weed
        SET last_harvest = ?
        WHERE id = ?
    ]],
    { pTimestamp, pPlantId })

    if not affectedRows or affectedRows < 1 then
        TriggerEvent("DoLongHudText", src, "ERROR: affectedRows == nil or affectedRows < 1", 2)
        return false
    end

    local data = {}
    for idx,plant in ipairs(WeedPlants) do
        if plant.id == pPlantId then
            WeedPlants[idx]["last_harvest"] = pTimestamp
            data = WeedPlants[idx]
            break
        end
    end

    TriggerClientEvent("caue-weed:trigger_zone", -1, 3, data)

    if data["gender"] == 0 then
        TriggerClientEvent("player:receiveItem", src, "weedq", 5)
    elseif data["gender"] == 1 then
        if PlantConfig.RemoveMaleOnHarvest then
            local affectedRows2 = MySQL.update.await([[
                DELETE FROM weed
                WHERE id = ?
            ]],
            { pPlantId })

            if not affectedRows2 or affectedRows2 < 1 then
                TriggerEvent("DoLongHudText", src, "ERROR: affectedRows2 == nil or affectedRows2 < 1", 2)
                return false
            end

            for idx,plant in ipairs(WeedPlants) do
                if plant.id == pPlantId then
                    WeedPlants[idx] = nil
                    break
                end
            end

            TriggerClientEvent("caue-weed:trigger_zone", -1, 4, { id = pPlantId })
        end

        local seedAmount = math.random(PlantConfig.SeedsFromMale[1], PlantConfig.SeedsFromMale[2])
        for i = 1, seedAmount do
            local chance = roundDecimals(math.random(), 2)
            if chance <= PlantConfig.MaleChance then
                TriggerClientEvent("player:receiveItem", src, "maleseed", 1)
            else
                TriggerClientEvent("player:receiveItem", src, "femaleseed", 1)
            end
        end
    end

    return true
end)

--[[

    Threads

]]

Citizen.CreateThread(function()
    local _plants = MySQL.query.await([[
        SELECT *
        FROM weed
    ]])

    local plants = {}
    for i, v in ipairs(_plants) do
        v["coords"] = json.decode(v.coords)
        v["strain"] = json.decode(v.strain)
        v["coords"] = vector3(v["coords"]["x"], v["coords"]["y"], v["coords"]["z"])
        table.insert(plants, v)
    end

    WeedPlants = plants

    while true do
        local plants = MySQL.query.await([[
            SELECT *
            FROM weed
        ]])

        local time = os.time()

        for i, v in ipairs(plants) do
            if (time - v.timestamp) >= (PlantConfig.LifeTime * 60) then
                local affectedRows = MySQL.update.await([[
                    DELETE FROM weed
                    WHERE id = ?
                ]],
                { v.id })

                if affectedRows and affectedRows > 0 then
                    for i2, v2 in ipairs(WeedPlants) do
                        if v2.id == v.id then
                            WeedPlants[i2] = nil
                        end
                    end

                    TriggerClientEvent("caue-weed:trigger_zone", -1, 4, v)
                end
            end
        end

        Citizen.Wait(PlantConfig.UpdateTimer)
    end
end)