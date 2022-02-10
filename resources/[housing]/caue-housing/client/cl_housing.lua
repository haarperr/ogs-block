--[[

    Variables

]]

Housing.currentOwned = {}
Housing.currentKeys = {}
Housing.currentlyEditing = false
Housing.currentHousingInteractions = nil
Housing.currentlyInsideBuilding = false

Housing.currentHousingLocks = {}
Housing.currentHousingLockdown = {}
Housing.currentAccess = nil

Housing.hasEditedOrigin = false

--[[

    Functions

]]

function gatherPlayerInfo()
    Housing.currentOwned = RPC.execute("getCurrentOwned")
    Housing.currentKeys = RPC.execute("currentKeys")
    Housing.currentHousingLockdown = RPC.execute("getCurrentLockdown")
    updateBuisnessLocations(RPC.execute("getBuisnessLocations"))
end

function updateBuisnessLocations(data)
    local assigned = {}

    for k, v in pairs(Housing.info) do
        if v.assigned then
            assigned[v.assigned] = k
        end
    end

    for k, v in pairs(data) do
        local c = v.coords
        Housing.info[assigned[v.buisness]]["pos"] = vector4(c.x, c.y, c.z, 0.0)
    end
end

function Housing.func.findClosestProperty()
    local playerCoords = GetEntityCoords(PlayerPedId())

    local zone = GetZoneAtCoords(playerCoords)
    local zoneName = GetNameOfZone(playerCoords)

    if Housing.zone[zoneName] == nil then
        return false, "Zona não encontrada", nil
    end

    local closest = nil
    local closestDist = 9999

    for k,v in pairs(Housing.zone[zoneName].locations) do
        local distance = #(playerCoords - v)
        if distance <= closestDist then
            closestDist = distance
            closest = k
        end
    end

    return true, closest, closestDist, zoneName
end

function getCurrentKeys()
    Housing.currentKeys = RPC.execute("currentKeys")
    return Housing.currentKeys
end

function Housing.func.enterBuilding(propertyID,enterOverride,counterPart)
    Housing.currentlyInsideBuilding = true
    DoScreenFadeOut(1)

    TriggerEvent("inhotel", true)

    local finished, housingInformation, currentHousingLocks, isResult, housingLockdown, housingRobbed, robTargets, robLocations, alarm, currentAccess = RPC.execute("getCurrentSelected", propertyID)

    if type(housingLockdown) == "table" then
        Housing.currentHousingLockdown = housingLockdown
    end

    if type(currentHousingLocks) == "table" then
        Housing.currentHousingLocks = currentHousingLocks
    end

    if type(housingRobbed) == "table" then
        Housing.housingBeingRobbedClient = housingRobbed
    end

    if type(robTargets) == "table" then
        Housing.housingRobTargets = robTargets
    end

    if type(robLocations) == "table" then
        Housing.robPosLocations = robLocations
    end

    if type(housingInformation) == "table" then
        Housing.currentHousingInteractions = housingInformation
        Housing.currentHousingInteractions.id = propertyID
    end

    if type(currentAccess) == "table" then
        Housing.currentAccess = currentAccess
    end

    if counterPart then
        Housing.alarm = alarm

        local finished, destroyedTable = RPC.execute("getDestroyedTable", propertyID)
        if type(destroyedTable) == "table" then
            Housing.destroyedObjects = destroyedTable
        end
    end

    local model = Housing.info[propertyID].model
    local oldModel = nil
    if counterPart then
        local info = Housing.typeInfo[model]
        if info.robberyCounterpart == nil then return end
        oldModel = model
        model = info.robberyCounterpart
    end

    local spawnBuildingLocation = vector3(Housing.info[propertyID]["pos"].x,Housing.info[propertyID]["pos"].y,Housing.info[propertyID]["pos"].z-60.0)
    if not counterPart then
        if Housing.currentHousingInteractions ~= nil and Housing.currentHousingInteractions.origin_offset ~= vector3(0.0,0.0,0.0) and type(Housing.currentHousingInteractions.origin_offset) == "vector3" then
            local off = Housing.currentHousingInteractions.origin_offset
            spawnBuildingLocation =  vector3(Housing.info[propertyID]["pos"].x+off.x,Housing.info[propertyID]["pos"].y+off.y,Housing.info[propertyID]["pos"].z-60.0)
        end
    end

    local isBuiltCoords, objects = exports["caue-build"]:getModule("func").buildRoom(model,spawnBuildingLocation,false,Housing.destroyedObjects,enterOverride,true)
    if counterPart and Housing.staticObjectRobPoints == nil then
        Housing.staticObjectRobPoints = exports["caue-build"]:getModule("func").getRobLocationsForObjects(model,spawnBuildingLocation,Housing.housingRobTargets.static)
        buildRobLocations(model,propertyID)
    end

    if isBuiltCoords then
        --DoScreenFadeIn(100)
        SetEntityInvincible(PlayerPedId(), false)
        FreezeEntityPosition(PlayerPedId(),false)

        TriggerEvent('InteractSound_CL:PlayOnOne', 'DoorClose', 0.7)
        DoScreenFadeIn(500)

        Housing.currentlyInsideBuilding = true

        if counterPart then
            model = oldModel

            if model == "v_int_16_low" then
                model = "v_int_49_empty"
            elseif model == "v_int_61" then
                model = "v_int_16_mid_empty"
            end
        end

        Housing.func.loadInteractions(model,counterPart,counterPart)

        TriggerServerEvent("caue-housing:enterHouse", propertyID)

        if not counterPart then
            TriggerEvent("caue-editor:buildName", propertyID, objects)
        end
    else
        Housing.currentHousingInteractions = nil
        Housing.currentlyInsideBuilding = false
        Housing.currentAccess = nil
    end
end

function Housing.func.getPropertyIdFromName(propertyName, isSpawn)
    local housingID = 0
    for k, v in pairs(Housing.info) do
        local street = v.street

        if isSpawn then
            street = street .. " House"
        end

        if propertyName == street then
            housingID = k
            break
        end
    end
    return housingID
end

function Housing.func.getPropertyZoneFromID(propertyID)
    local zoneName = GetNameOfZone(Housing.info[propertyID]["pos"])
    return zoneName
end

function unlock(propertyID)
    if not isPropertyActive(propertyID) then
        TriggerEvent("DoLongHudText", "propriedade inativa", 2)
        return
    end

    if not playerInRangeOfProperty(propertyID) then
        TriggerEvent("DoLongHudText", "Distante da sua propriedade", 2)
        return
    end

    if Housing.currentKeys == nil and Housing.currentOwned == nil then
        TriggerEvent("DoLongHudText", "Você não possui as chaves da propriedade" , 2)
        return
    end

    if Housing.currentKeys[propertyID] == nil and Housing.currentOwned[propertyID] == nil then
        TriggerEvent("DoLongHudText", "Você não possui as chaves da propriedade" , 2)
        return
    end

    if Housing.currentHousingLocks[propertyID] == nil then
        if not lockdownCheck(propertyID) then
            TriggerEvent("DoLongHudText","A propriedade está bloqueada, você não pode mudar as fechaduras.",2)
            return
        end

        -- if taxCheck(propertyID) then
        --     TriggerEvent(
        --         "caue-phone:addnotification",
        --         "State of San Andreas",
        --         "You have two or more asset fees outstanding for this property. Failure to pay these off could result in permanent forfeiture of property to the State of San Andreas. Once outstanding asset fees are paid off your new keys will be returned to you and your tennants."
        --     )
        --     return
        -- end

        local passed, currentHousingLocks = RPC.execute("unlockProperty", propertyID)

        if type(currentHousingLocks) == "table" then
            Housing.currentHousingLocks = currentHousingLocks
        end

        TriggerEvent("DoLongHudText","Propriedade destrancada.")
    else
        TriggerEvent("DoLongHudText", "A propriedade já está destrancada.", 2)
    end
end

function lock(propertyID)
    if not isPropertyActive(propertyID) then
        TriggerEvent("DoLongHudText", "propriedade inativa", 2)
        return
    end

    if not playerInRangeOfProperty(propertyID) then
        TriggerEvent("DoLongHudText", "Distante da sua propriedade", 2)
        return
    end

    if Housing.currentKeys == nil and Housing.currentOwned == nil then
        TriggerEvent("DoLongHudText", "Você não possui as chaves da propriedade" , 2)
        return
    end

    if Housing.currentKeys[propertyID] == nil and Housing.currentOwned[propertyID] == nil then
        TriggerEvent("DoLongHudText", "Você não possui as chaves da propriedade" , 2)
        return
    end

    if Housing.currentHousingLocks[propertyID] == false then
        if not lockdownCheck(propertyID) then
            TriggerEvent("DoLongHudText", "A propriedade está bloqueada, você não pode mudar as fechaduras.", 2)
            return
        end

        local passed, currentHousingLocks = RPC.execute("lockProperty", propertyID)

        if type(currentHousingLocks) == "table" then
            Housing.currentHousingLocks = currentHousingLocks
        end

        TriggerEvent("DoLongHudText", "Propriedade trancada.")
    else
        TriggerEvent("DoLongHudText", "A propriedade já está trancada.", 2)
    end
end

function taxCheck(propertyId)
    local taxCheck = RPC.execute("housing:isOverdueOnTaxes", propertyId)
    return taxCheck
end

--[[

    Events

]]

RegisterNetEvent("SpawnEventsClient")
AddEventHandler("SpawnEventsClient", function()
    gatherPlayerInfo()
end)

RegisterNetEvent("caue-housing:reset")
AddEventHandler("caue-housing:reset", function()
    -- cl_housing
    Housing.currentOwned = {}
    Housing.currentKeys = {}
    Housing.currentlyEditing = false
    Housing.currentHousingInteractions = nil
    Housing.currentlyInsideBuilding = false

    Housing.currentHousingLocks = {}
    Housing.currentHousingLockdown = {}
    Housing.currentAccess = nil

    Housing.hasEditedOrigin = false

    -- cL_houseRobberies
    Housing.housingBeingRobbedClient = {}
    Housing.housingRobTargets = {}
    Housing.currentlyRobInside = false

    Housing.staticObjectRobPoints = nil
    Housing.robPosLocations = nil

    Housing.currentClosestSelected = nil
    Housing.currentlyDisplayingPickup = false
    Housing.destroyedObjects = {}
    Housing.alarm = {}

    Housing.attackedTarget = nil
    Housing.lockpicking = false

    Housing.lockout = false

    -- cl_realtor
    Housing.positions = {}
    Housing.EditOptions = {}

    -- cl_util
    Housing.ClosestObject = {}
    Housing.plyCoords = nil
end)

RegisterNetEvent("caue-housing:refresh")
AddEventHandler("caue-housing:refresh", function()
    gatherPlayerInfo()
end)

RegisterNetEvent("housing:playerSpawned")
AddEventHandler("housing:playerSpawned", function(housingName)
    local propertyID = Housing.func.getPropertyIdFromName(housingName, true)
    if propertyID == 0 then return end

    Housing.currentHousingLockdown = RPC.execute("getCurrentLockdown")

    if not Housing.currentHousingLockdown[propertyID] then
        Housing.func.enterBuilding(propertyID)
    end
end)

RegisterNetEvent('housing:toggleClosestLock')
AddEventHandler('housing:toggleClosestLock', function()
    local isComplete, propertyID, dist, zone = Housing.func.findClosestProperty()

    if isComplete and dist <= 3.0 then
        if Housing.currentOwned[propertyID] == nil and Housing.currentKeys[propertyID] == nil then
            return
        end

        if isLocked(propertyID, true) then
            unlock(propertyID)
        else
            lock(propertyID)
        end
    end
end)