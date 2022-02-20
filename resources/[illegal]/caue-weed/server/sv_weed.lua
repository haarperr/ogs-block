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

    local result = exports.ghmattimysql:executeSync([[
        INSERT INTO weed (gender, coords, strain, timestamp)
        VALUES (?, ?, ?, ?)
    ]],
    { pGender, json.encode(pCoords), json.encode(pStrain), pTimestamp })

    if result["insertId"] == 0 then
        return false
    end

    local data = {
        id = result["insertId"],
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

    local result = exports.ghmattimysql:executeSync([[
        UPDATE weed
        SET strain = ?
        WHERE id = ?
    ]],
    { json.encode(strain), pPlantId })

    if result["affectedRows"] ~= 1 then
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

    local result = exports.ghmattimysql:executeSync([[
        UPDATE weed
        SET strain = ?
        WHERE id = ?
    ]],
    { json.encode(strain), pPlantId })

    if result["affectedRows"] ~= 1 then
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

    local result = exports.ghmattimysql:executeSync([[
        UPDATE weed
        SET gender = 1
        WHERE id = ?
    ]],
    { pPlantId })

    if result["affectedRows"] ~= 1 then
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

    local result = exports.ghmattimysql:executeSync([[
        DELETE FROM weed
        WHERE id = ?
    ]],
    { pPlantId })

    if result["affectedRows"] ~= 1 then
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

    local result = exports.ghmattimysql:executeSync([[
        UPDATE weed
        SET last_harvest = ?
        WHERE id = ?
    ]],
    { pTimestamp, pPlantId })

    if result["affectedRows"] ~= 1 then
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
        TriggerClientEvent("player:receiveItem", src, "weedq", 1)
    elseif data["gender"] == 1 then
        if PlantConfig.RemoveMaleOnHarvest then
            local result = exports.ghmattimysql:executeSync([[
                DELETE FROM weed
                WHERE id = ?
            ]],
            { pPlantId })

            if result["affectedRows"] ~= 1 then
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
            local chance = math.random()
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
    local _plants = exports.ghmattimysql:executeSync([[
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
        local plants = exports.ghmattimysql:executeSync([[
            SELECT *
            FROM weed
        ]])

        local time = os.time()

        for i, v in ipairs(plants) do
            if (time - v.timestamp) >= (PlantConfig.LifeTime * 60) then
                local result = exports.ghmattimysql:executeSync([[
                    DELETE FROM weed
                    WHERE id = ?
                ]],
                { v.id })

                if result["affectedRows"] == 1 then
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