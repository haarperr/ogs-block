--[[

    Variables

]]

Objects = {}
activeZones = {}

--[[

    Functions

]]

function addObject(object)
    if not Config.Objects[object.type] then return end

    local vector = vector3(object.coordinates.x, object.coordinates.y, object.coordinates.z)
    exports["caue-polyzone"]:AddCircleZone(
        "caue-objects",
        vector,
        Config.crates[object.size].distance * 10,
        { data = { id = object.id } }
    )

    local object = nil
    if #(GetEntityCoords(PlayerPedId()) - vector) < 25 then
        local heading = object.coordinates.h
        if heading == nil then heading = 0 end
        object = createObject(object.size, vector.x, vector.y, vector.z, heading)
        activeZones[object.id] = vector
    end

    Objects[object.id] = {
        id = object.id,
        size = object.size,
        coordinates = object.coordinates,
        placed_by = object.placed_by,
        placed_at = object.placed_at,
        despawn_at = object.despawn_at,
        is_locked = object.is_locked,
        key_code = object.key_code,
        object = object
    }
end

function getClosestStash(range, coords)
    local closestStash, closestStashDist = nil, 9999
    if coords == nil then
        coords = GetEntityCoords(PlayerPedId())
    end
    for id, crateCoords in pairs(activeZones) do
        local dist = #(coords-crateCoords)
        if dist < closestStashDist then
            closestStashDist = dist
            closestStash = id
        end
    end
    if closestStashDist > range then
        return nil
    end
    return closestStash, closestStashDist
end

function createObject(size, x,y,z, heading)
    local obj = CreateObject(Config.crates[size].model, x, y, z, 0, 0, 0)
    if not heading then heading = 0 end
    SetEntityHeading(obj, heading + 0.0)
    FreezeEntityPosition(obj, true)
    return obj
end





--[[

    Events

]]

AddEventHandler("caue-polyzone:enter", function (name, data)
    if name ~= "caue-objects" then return end
    if not Objects[data.id] then return end
    if Objects[data.id].object then return end

    local coords = Objects[data.id].coordinates
    Objects[data.id].object = createObject(Objects[data.id].size, coords.x, coords.y, coords.z, coords.h)
    activeZones[data.id] = vector3(coords.x, coords.y, coords.z)
end)

AddEventHandler("caue-polyzone:exit", function (name, data)
    if name ~= "caue-objects" then return end
    if not Objects[data.id] then return end
    if not Objects[data.id].object then return end

    DeleteObject(Objects[data.id].object)
    Objects[data.id].object = nil
    activeZones[data.id] = nil
end)

AddEventHandler("onResourceStop", function (resource)
    if resource ~= "caue-storage" then return end
    for id, storage in pairs(Objects) do
        if storage.object then
            DeleteObject(storage.object)
        end
    end
end)

RegisterNetEvent("np-storage:loadObjects", function (_storages)
    for id, storage in pairs(_storages) do
        addObject(storage)
    end
end)












--[[

    Threads

]]

-- Citizen.CreateThread(function ()
--     for crate, data in pairs(Config.Objects) do
--         exports["np-interact"]:AddPeekEntryByModel({ GetHashKey(data.model) }, {{
--             id = "storage_lifetime",
--             event = "np-storage:checkLifetime",
--             icon = "heart",
--             label = _L("storage-check-wear", "Check wear")
--         }, {
--             id = "storage_destroy",
--             event = "np-storage:destroyStash",
--             icon = "trash-alt",
--             label = _L("storage-destroy", "Destroy container"),
--         }}, {
--             distance = { radius = data.distance },
--             isEnabled = function(entity, context)
--                 local stash, dist = getClosestStash(data.distance)
--                 return stash ~= nil
--             end
--         })
--         if not data.vendor then
--             exports["np-interact"]:AddPeekEntryByModel({ GetHashKey(data.model) }, {{
--                 id = "storage_open",
--                 event = "np-storage:openStash",
--                 icon = "box-open",
--                 label = _L("storage-open", "Open stash"),
--             }}, {
--                 distance = { radius = data.distance },
--                 isEnabled = function(entity, context)
--                     local stash, dist = getClosestStash(data.distance)
--                     return stash ~= nil
--                 end
--             })
--             exports["np-interact"]:AddPeekEntryByModel({ GetHashKey(data.model) }, {{
--                 id = "storage_breakin",
--                 event = "np-storage:breakinStash",
--                 icon = "exclamation-triangle",
--                 label = _L("storage-breakin", "Break in container"),
--             }}, {
--                 distance = { radius = data.distance },
--                 isEnabled = function(entity, context)
--                     local stash, dist = getClosestStash(data.distance)
--                     return stash ~= nil and Objects[stash].is_locked and not Objects[stash].key_code and exports["np-inventory"]:hasEnoughOfItem("2227010557", 1, false)
--                 end
--             })
--         end
--     end
--     Wait(5000)
--     if #Objects == 0 then
--         TriggerServerEvent("np-storage:requestObjects")
--     end
-- end)











































RegisterNetEvent("np:storage:prepareNewStorage")
AddEventHandler("np:storage:prepareNewStorage", function (storage)
    addObject(storage)
end)









AddEventHandler("np-storage:breakinStash", function ()
    local closestStash, closestStashDist = getClosestStash(10)
    if closestStash == nil then return end
    local stash = Objects[closestStash]
    if closestStashDist > Config.crates[stash.size].distance then return end
    if not stash.is_locked then
        return TriggerEvent("DoLongHudText", _L("storage-not-locked", "This crate is not locked"))
    end
    if stash.key_code then
        return TriggerEvent("DoLongHudText", _L("storage-cant-be-broken-open", "You can not break into this lock for some reason"))
    end

    loadAnimDict(Config.anims.unlock.dict)
    TaskPlayAnim(PlayerPedId(), Config.anims.unlock.dict, Config.anims.unlock.name, 8.0, -8.0, -1, 1, 1.0, false, false, false)

    local progress = exports["np-taskbar"]:taskBar(Config.crates[stash.size].openLength, _L("storage-breaking-open", "Breaking open..."))
    ClearPedTasks(PlayerPedId())
    if progress ~= 100 then return end

    TriggerServerEvent("np-storage:breakInStorage", stash.id)
    TriggerEvent("DoLongHudText", _L("storage-broken-open", "You have opened the container"))
    TriggerEvent("inventory:removeItem", "2227010557", 1)
end)

RegisterNetEvent("np-storage:clearObjects")
AddEventHandler("np-storage:clearObjects", function (deletedObjects)
    for _, id in pairs(deletedObjects) do
        if activeZones[id] then
            activeZones[id] = nil
        end
        if Objects[id] then
            if Objects[id].object then
                DeleteObject(Objects[id].object)
            end
            Objects[id] = nil
        end
    end
end)

AddEventHandler("np-storage:destroyStash", function ()
    local closestStash, closestStashDist = getClosestStash(10)
    if closestStash == nil then return end
    local stash = Objects[closestStash]
    if closestStashDist > Config.crates[stash.size].distance then return end

    loadAnimDict(Config.anims.destroy.dict)
    TaskPlayAnim(PlayerPedId(), Config.anims.destroy.dict, Config.anims.destroy.name, 8.0, -8.0, -1, 1, 1.0, false, false, false)

    local finished = exports["np-taskbar"]:taskBar(Config.crates[stash.size].destroyLength, _L("storage-destroying", "Destroying..."))

    ClearPedTasksImmediately(PlayerPedId())

    if finished == 100 then
        TriggerServerEvent("np-storage:destroyStash", closestStash)
        if not Config.crates[stash.size].vendor then return end
        local employmentState = exports["np-business"]:IsEmployedAt("statecontracting")
        local isCrateYoung = RPC.execute("np-storage:canBeDeplaced", stash.id)
        if isCrateYoung and employmentState then
            TriggerEvent("player:receiveItem", stash.size, 1)
        end
    end
end)

AddEventHandler("np-storage:checkLifetime", function ()
    local closestStash, closestStashDist = getClosestStash(10)
    if closestStash == nil then return end
    local stash = Objects[closestStash]
    if closestStashDist > Config.crates[stash.size].distance then return end

    TriggerServerEvent("np-storage:getRemainingLife", closestStash)
end)

AddEventHandler("np-inventory:itemUsed", function (name, info)
    if name ~= "mobilecratelock" and name ~= "mobilecratekeylock" then return end

    local closestStash, closestStashDist = getClosestStash(10)
    if closestStash == nil then return end
    local stash = Objects[closestStash]
    if closestStashDist > Config.crates[stash.size].distance then return end

    if stash.is_locked then
        return TriggerEvent("DoLongHudText", _L("storage-already-locked", "This container is already locked"))
    end

    if not Config.crates[stash.size].lockLength then
        return TriggerEvent("DoLongHudText", _L("storage-no-lock-length", "This container can not be locked"))
    end

    loadAnimDict(Config.anims.lock.dict)
    TaskPlayAnim(PlayerPedId(), Config.anims.lock.dict, Config.anims.lock.name, 8.0, -8.0, -1, 1, 1.0, false, false, false)

    local progress = exports["np-taskbar"]:taskBar(Config.crates[stash.size].lockLength, _L("storage-locking", "Locking..."))
    ClearPedTasks(PlayerPedId())
    if progress ~= 100 then return end

    local element = {
        icon = "circle",
        label = _L("storage-key-name", "Key Name"),
        name = "name",
    }
    if name == "mobilecratekeylock" then
        element = {
            icon = "circle",
            label = _L("storage-key-code", "Key Code"),
            name = "keycode",
        }
    end

    exports['np-ui']:openApplication('textbox', {
        callbackUrl = 'np-storage:lockStorage',
        key = { crateId = stash.id, item = name },
        items = {element},
        show = true,
    })
end)

RegisterNetEvent("np-storage:updateLockState")
AddEventHandler("np-storage:updateLockState", function (id, state, keyCode)
    if not Objects[id] then return end

    Objects[id].is_locked = state
    Objects[id].key_code = keyCode
end)