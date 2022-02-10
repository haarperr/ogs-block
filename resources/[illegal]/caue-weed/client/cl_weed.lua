--[[

    Variables

]]

local WeedPlants = {}
local ActivePlants = {}

local inZone = 0
local setDeleteAll = false

--[[

    Functions

]]

function createWeedStageAtCoords(pStage, pCoords)
    local model = PlantConfig.GrowthObjects[pStage].hash
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(0)
    end

    local plantObject = CreateObject(model, pCoords.x, pCoords.y, pCoords.z + PlantConfig.GrowthObjects[pStage].zOffset, 0, 0, 0)
    FreezeEntityPosition(plantObject, true)
    SetEntityHeading(plantObject, math.random(0, 360) + 0.0)
    return plantObject
end

function removeWeed(pPlantId)
    if ActivePlants[pPlantId] then
        DeleteObject(ActivePlants[pPlantId].object)
        ActivePlants[pPlantId] = nil
    end
end

function getStageFromPercent(pPercent)
    local growthObjects = #PlantConfig.GrowthObjects - 1
    local percentPerStage = 100 / growthObjects
    return math.floor((pPercent / percentPerStage) + 1.5)
end

function getPlantGrowthPercent(pPlant)
    local timeDiff = (GetCloudTimeAsInt() - pPlant.timestamp) / 60
    local genderFactor = (pPlant.gender == 1 and PlantConfig.MaleFactor or 1)
    local fertilizerFactor = pPlant.strain.n >= 0.9 and PlantConfig.FertilizerFactor or 1.0
    local growthFactors = (PlantConfig.GrowthTime * genderFactor * fertilizerFactor)
    return math.min((timeDiff / growthFactors) * 100, 100.0)
end

function getPlantId(pEntity)
    for plantId,plant in pairs(ActivePlants) do
        if plant.object == pEntity then
            return plantId
        end
    end
end

function getPlantById(pPlantId)
    for _,plant in pairs(WeedPlants) do
        if plant.id == pPlantId then
            return plant
        end
    end
end

function playPourAnimation()
    RequestAnimDict("weapon@w_sp_jerrycan")
    while (not HasAnimDictLoaded("weapon@w_sp_jerrycan")) do
        Wait(0)
    end
    TaskPlayAnim(PlayerPedId(),"weapon@w_sp_jerrycan","fire",2.0, -8, -1,49, 0, 0, 0, 0)
end

function showPlantMenu(pPlantId)
    local plant = getPlantById(pPlantId)
    local growth = getPlantGrowthPercent(plant)
    local water = plant.strain.water * 100.0
    local myjob = exports["caue-base"]:getChar("job")
    local context = {}

    context[#context+1] = {
        title = "Crescimento: " .. string.format("%.2f", growth) .. "%",
        description = "Sexo: " .. (plant.gender == 1 and "Macho" or "Femea"),
    }

    --Only allow adding water/fertilzier before harvest time
    if growth < PlantConfig.HarvestPercent then
        context[#context+1] = {
            title = "Adicionar Agua",
            description = "Agua: " .. string.format("%.2f", water) .. "%",
            action = "caue-weed:addWater",
            params = { id = pPlantId },
        }

        context[#context+1] = {
            title  = "Adicionar Fertilizante",
            children = {
                {
                    title = "Adicionar Fertilizante (N)",
                    action = "caue-weed:addFertilizer",
                    params = { id = pPlantId, type = "n" },
                },
                {
                    title = "Adicionar Fertilizante (P)",
                    action = "caue-weed:addFertilizer",
                    params = { id = pPlantId, type = "p" },
                },
                {
                    title = "Adicionar Fertilizante (K)",
                    action = "caue-weed:addFertilizer",
                    params = { id = pPlantId, type = "k" },
                }
            }
        }
    end

    --Only allow changing gender in the first 2~ stages
    if getStageFromPercent(growth) < 3 and plant.gender == 0 then
        context[#context+1] = {
            title = "Adicionar Semente Macho",
            description = "Engravidar a Planta",
            action = "caue-weed:addMaleSeed",
            params = { id = pPlantId },
        }
    end

    if growth >= 95 or myjob == "police" or myjob == "judge" then
        context[#context+1] = {
            title = "Destruir a Planta",
            action = "caue-weed:removePlant",
            params = { id = pPlantId },
        }
    end

    exports["caue-context"]:showContext(context);
end

--[[

    Events

]]

AddEventHandler("onResourceStop", function(resource)
    if resource ~= GetCurrentResourceName() then return end
    for idx,plant in pairs(ActivePlants) do
        DeleteObject(plant.object)
    end
end)

AddEventHandler("caue-polyzone:enter", function(zone, data)
    if zone == "caue-weed:area" then
        inZone = inZone + 1
        if inZone == 1 then
            RPC.execute("caue-weed:getPlants")
        end
    end
end)

AddEventHandler("caue-polyzone:exit", function(zone, data)
    if zone == "caue-weed:area" then
        inZone = inZone - 1
        if inZone < 0 then inZone = 0 end
        if inZone == 0 then
            setDeleteAll = true
        end
    end
end)

AddEventHandler("caue-inventory:itemUsed", function(item)
    if item == "femaleseed" then
        if inZone > 0 then
            local plyCoords = GetEntityCoords(PlayerPedId())
            local offsetCoords = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0, 0.7, 0)
            local rayHandle = StartExpensiveSynchronousShapeTestLosProbe(offsetCoords.x, offsetCoords.y, offsetCoords.z, offsetCoords.x, offsetCoords.y, offsetCoords.z - 2, 1, 0, 4)
            local retval, hit, endCoords, _, materialHash, _ = GetShapeTestResultIncludingMaterial(rayHandle)
            if hit then
                local foundHash = false
                for matHash,matType in pairs(MaterialHashes) do
                    if materialHash == matHash then
                        local typeMod = PlantConfig.TypeModifiers[matType]
                        foundHash = true
                        TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_GARDENER_PLANT", 0, true)
                        local finished = exports["caue-taskbar"]:taskBar(3000, "Planting Seed", false, true, false, false, nil, 5.0, PlayerPedId())
                        ClearPedTasks(PlayerPedId())
                        if finished == 100 then
                            RPC.execute("caue-weed:plantSeed", endCoords, typeMod)
                            TriggerEvent("inventory:removeItem", item, 1)
                        end
                    end
                end
                if not foundHash then
                    TriggerEvent("DoLongHudText", "Eu preciso achar um melhor solo para essa planta.", 2)
                end
            end
        else
            TriggerEvent("DoLongHudText", "Eu preciso achar uma melhorar area para plantar.", 2)
        end
    end
end)

RegisterNetEvent("caue-weed:trigger_zone")
AddEventHandler("caue-weed:trigger_zone", function (type, pData)
    --Update all plants
    if type == 1 then
        for _,plant in ipairs(WeedPlants) do
            local keep = false
            for _,newPlant in ipairs(pData) do
                if plant.id == newPlant.id then
                    keep = true
                    break
                end
            end

            if not keep then
                removeWeed(plant.id)
            end
        end
        WeedPlants = pData
    end

    --New plant being added
    if type == 2 then
        WeedPlants[#WeedPlants+1] = pData
    end

    --Plant being harvested/updated
    if type == 3 then
        for idx,plant in ipairs(WeedPlants) do
            if plant.id == pData.id then
                WeedPlants[idx] = pData
                break
            end
        end
    end

    --Plant being removed
    if type == 4 then
        for idx,plant in ipairs(WeedPlants) do
            if plant.id == pData.id then
                table.remove(WeedPlants, idx)
                removeWeed(plant.id)
                break
            end
        end
    end
end)

AddEventHandler("caue-weed:checkPlant", function(pContext, pEntity)
    local plantId = getPlantId(pEntity)
    if not plantId then return end
    showPlantMenu(plantId)
end)

AddEventHandler("caue-weed:addWater", function (pParams)
    if not exports["caue-inventory"]:hasEnoughOfItem("water", 1, true, true) then return end

    playPourAnimation()
    local finished = exports["caue-taskbar"]:taskBar(2000, "Adicionando Agua", false, true, false, false, nil, 5.0, PlayerPedId())
    ClearPedTasks(PlayerPedId())
    if finished == 100 then
        local success = RPC.execute("caue-weed:addWater", pParams.id)
        if not success then
            TriggerEvent("DoLongHudText", "[ERR]: Não pode adicionar agua.")
        else
            TriggerEvent("inventory:removeItem", "water", 1)
        end
    end
    showPlantMenu(pParams.id)
end)

AddEventHandler("caue-weed:addFertilizer", function (pParams)
    if not exports["caue-inventory"]:hasEnoughOfItem("fertilizer", 1, true, true) then return end

    playPourAnimation()
    local finished = exports["caue-taskbar"]:taskBar(2000, "Adicionando Fertilizante", false, true, false, false, nil, 5.0, PlayerPedId())
    ClearPedTasks(PlayerPedId())
    if finished == 100 then
        local success = RPC.execute("caue-weed:addFertilizer", pParams.id, pParams.type)
        if not success then
            TriggerEvent("DoLongHudText", "[ERR]: Não pode adicionar Fertilizante")
        else
            TriggerEvent("inventory:removeItem", "fertilizer", 1)
        end
    end
    showPlantMenu(pParams.id)
end)

AddEventHandler("caue-weed:addMaleSeed", function (pParams)
    if not exports["caue-inventory"]:hasEnoughOfItem("maleseed", 1, true, true) then return end

    TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_GARDENER_PLANT", 0, true)
    local finished = exports["caue-taskbar"]:taskBar(3000, "Adicionando Semente Macho", false, true, false, false, nil, 5.0, PlayerPedId())
    ClearPedTasks(PlayerPedId())
    if finished == 100 then
        RPC.execute("caue-weed:addMaleSeed", pParams.id)
        TriggerEvent("inventory:removeItem", "maleseed", 1)
    end
    showPlantMenu(pParams.id)
end)

AddEventHandler("caue-weed:removePlant", function (pParams)
    TriggerEvent("animation:PlayAnimation","layspike")
    local finished = exports["caue-taskbar"]:taskBar(3000, "Removendo", false, true, false, false, nil, 5.0, PlayerPedId())
    ClearPedTasks(PlayerPedId())
    if finished == 100 then
        local getFertilizer = getPlantGrowthPercent(getPlantById(pParams.id)) > 20.0
        local success = RPC.execute("caue-weed:removePlant", pParams.id, getFertilizer)
        if not success then
            print("[ERR]: Não consegue remover. pid:", pParams.id)
        end
    end
end)

AddEventHandler("caue-weed:pickPlant", function(pContext, pEntity)
    local plantId = getPlantId(pEntity)
    if not plantId then return end

    local plant = getPlantById(plantId)
    local timeSinceHarvest = GetCloudTimeAsInt() - plant.last_harvest
    if getPlantGrowthPercent(plant) < PlantConfig.HarvestPercent or timeSinceHarvest <= (PlantConfig.TimeBetweenHarvest * 60) then
        TriggerEvent("DoLongHudText", "Não esta pronto para colher", 2)
        return
    end

    local plyWeight = exports["caue-inventory"]:getCurrentWeight()
    if plyWeight + 35.0 > 250.0 and plant.gender == 0 then
        TriggerEvent("DoLongHudText", "Você não consegue carregar esse tanto de peso.", 2)
        return
    end

    TriggerEvent("animation:PlayAnimation","layspike")
    local finished = exports["caue-taskbar"]:taskBar(10000, "Colhendo", false, true, false, false, nil, 5.0, PlayerPedId())
    ClearPedTasks(PlayerPedId())
    if finished == 100 then
        RPC.execute("caue-weed:harvestPlant", plantId)
    end
end)

--[[

    Threads

]]

--Creates da weed
--TODO: cache close plants
Citizen.CreateThread(function()
    exports["caue-polyzone"]:AddPolyZone("caue-weed:area", {
        vector2(-342.00247192383, -1253.5378417969),
        vector2(84.262420654297, -1242.6663818359),
        vector2(520.96197509766, -1240.0241699219),
        vector2(1258.8310546875, -1228.4302978516),
        vector2(1407.0397949219, -1121.8983154297),
        vector2(1649.0086669922, -976.5205078125),
        vector2(1924.1279296875, -822.08416748047),
        vector2(2068.68359375, -1006.6109008789),
        vector2(2859.5693359375, -1742.0363769531),
        vector2(2648.7900390625, -2252.2673339844),
        vector2(1814.0902099609, -2787.0224609375),
        vector2(1344.9066162109, -2808.6821289062),
        vector2(1001.0428466797, -2734.3996582031),
        vector2(618.41564941406, -2574.2868652344),
        vector2(388.52581787109, -2406.0385742188),
        vector2(66.28978729248, -2305.4445800781),
        vector2(31.951961517334, -2045.0936279297),
        vector2(-192.29954528809, -1838.7125244141),
        vector2(-405.87139892578, -1651.3764648438)
    }, {
        --debugGrid = true,
        gridDivisions = 25,
        minZ = 10.0,
        maxZ = 500.0,
    })

    while true do
        local plyCoords = GetEntityCoords(PlayerPedId())

        if WeedPlants == nil then WeedPlants = {} end

        for idx,plant in ipairs(WeedPlants) do
            if idx % 100 == 0 then
                Wait(0) --Process 100 per frame
            end

            --convert timestamp -> growth percent
            local plantGrowth = getPlantGrowthPercent(plant)
            if #(plyCoords - plant.coords) < (50.0 + plantGrowth) and not setDeleteAll then
                local curStage = getStageFromPercent(plantGrowth)
                local isChanged = (ActivePlants[plant.id] and ActivePlants[plant.id].stage ~= curStage)

                if isChanged then
                    removeWeed(plant.id)
                end

                if not ActivePlants[plant.id] or isChanged then
                    local weedPlant = createWeedStageAtCoords(curStage, plant.coords)
                    ActivePlants[plant.id] = {
                        object = weedPlant,
                        stage = curStage
                    }
                end
            else
                removeWeed(plant.id)
            end
        end

        if setDeleteAll then
            WeedPlants = {}
            setDeleteAll = false
        end

        Wait(inZone > 0 and 5000 or 10000)
    end
end)