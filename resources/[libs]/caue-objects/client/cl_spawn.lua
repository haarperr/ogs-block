--[[

    Variables

]]

local isPlacing = false
local object = nil
local heading = 0.0
local currentCoords = nil
local canPlace = false

--[[

    Functions

]]



function spawn(coordinates)
    local location = exports["np-housing"]:getCurrentLocation()
    if location then
        local canPlace = canPlaceInHouse(location)
        if not canPlace then
            return TriggerEvent("DoLongHudText", _L("storage-cannot-place", "You cannot place the container here"), 2)
        end
        local x,y,z,w = GetEntityQuaternion(object)
        local data = {
            model = GetHashKey(Config.crates[isPlacing].model),
            coords = json.encode({ x = coordinates.x, y = coordinates.y, z = coordinates.z }),
            quat = json.encode({ x = x, y = y, z = z, w = w }),
            realName = Config.crates[isPlacing].model
        }
        TriggerServerEvent('objects:insertObject', location, data)
    end
    loadAnimDict(Config.anims.create.dict)
    TaskPlayAnim(PlayerPedId(), Config.anims.create.dict, Config.anims.create.name, 8.0, -8.0, 1000, 51, 1.0, false, false, false)
    local cid = exports["isPed"]:isPed("cid")
    TriggerServerEvent("np-storage:prepareStorage", isPlacing, cid, coordinates, heading)
    TriggerServerEvent('server-remove-item', cid, isPlacing, 1)
    StopPlacing()
end









function cameraToWorld (flags, ignore)
    local coord = GetGameplayCamCoord()
    local rot = GetGameplayCamRot(0)
    local rx = math.pi / 180 * rot.x
    local rz = math.pi / 180 * rot.z
    local cosRx = math.abs(math.cos(rx))
    local direction = {
        x = -math.sin(rz) * cosRx,
        y = math.cos(rz) * cosRx,
        z = math.sin(rx)
    }
    local sphereCast = StartShapeTestSweptSphere(
        coord.x + direction.x,
        coord.y + direction.y,
        coord.z + direction.z,
        coord.x + direction.x * 200,
        coord.y + direction.y * 200,
        coord.z + direction.z * 200,
        0.2,
        flags,
        ignore,
        7
    )
    return GetShapeTestResult(sphereCast)
end

function PlaceObject(pHash, pParams, pCheck)
    if isPlacing then return end
    isPlacing = true
    canPlace = false

    object = CreateObject(pHash, GetEntityCoords(PlayerPedId()), 0, 0, 0)
    SetEntityHeading(object, 0)
    SetEntityAlpha(object, 100)

    Citizen.CreateThread(function ()
        while isPlacing ~= nil do
            Citizen.Wait(1)

            DisablePlayerFiring(PlayerPedId(), true)
            DisableControlAction(0, 24, true) -- Attack
            DisableControlAction(0, 142, true) -- MeleeAttackAlternate
            DisableControlAction(1, 38, true) --Key: E
            DisableControlAction(0, 44, true) --Key: Q

            local retval, hit, endCoords, _, entityHit = cameraToWorld(1, object)
            if hit == 1 then
                currentCoords = endCoords

                if not canPlace then
                    canPlace = true
                end
            elseif canPlace then
                currentCoords = nil
                canPlace = false
            end

            if currentCoords then
                if pCheck then
                    local rayHandle = StartExpensiveSynchronousShapeTestLosProbe(currentCoords.x, currentCoords.y, currentCoords.z, currentCoords.x, currentCoords.y, currentCoords.z - 2, 1, 0, 4)
                    local retval, hit, endCoords, _, materialHash, _ = GetShapeTestResultIncludingMaterial(rayHandle)

                    local valid = pCheck(currentCoords, materialHash, object)

                    if not valid and canPlace then
                        canPlace = false
                    end
                end

                local z = currentCoords.z

                if pParams and pParams.zOffset then
                    z = z + pParams.zOffset
                end

                SetEntityCoords(object, currentCoords.x, currentCoords.y, z)
                SetEntityHeading(object, heading)

                if pParams and pParams.forceGroundSnap then
                    PlaceObjectOnGroundProperly_2(object)
                end

                -- if pParams and pParams.collision then
                --     SetEntityCollision(object, true, true)
                -- end
            end

            if canPlace then
                SetEntityAlpha(object, 100)
            else
                SetEntityAlpha(object, 0)
            end












            if IsControlJustPressed(0, 191) then
                placeContainer(currentCoords, heading)

                local data = {
                    coords = currentCoords,
                    rotation = heading,
                }

                return true, data
            end

            if IsControlJustPressed(0, 177) then
                StopPlacing()
                return false
            end

            if IsControlJustPressed(0, 14) then
                heading = heading + 5
                if heading > 360 then heading = 360.0 end
            end

            if IsControlJustPressed(0, 15) then
                heading = heading - 5
                if heading < 0 then heading = 0.0 end
            end
        end
    end)
end

function StopPlacing()
    if object then
        DeleteObject(object)
    end
    isPlacing = false
    object = nil
    heading = 0.0
    currentCoords = nil
    canPlace = false
end

function placeContainer(selection, heading)
    if not currentCoords then return StopPlacing() end

    local coordinates = vector3(selection.x, selection.y, selection.z)

    local dist = #(GetEntityCoords(PlayerPedId())-coordinates)
    if dist > 50 then
        return TriggerEvent("DoLongHudText", _L("storage-too-far", "You cannot place the container this far away"), 2)
    end

    if getClosestStash(5, coordinates) ~= nil then
        return TriggerEvent("DoLongHudText", _L("storage-too-close", "You are too close to another container, give it some room"), 2)
    end

    isPlacing = true

    if dist > 3 then
        TriggerEvent("DoLongHudText", _L("storage-placing-down", "Go to the location to place it down!"))
        CreateThread(function ()
            while #(GetEntityCoords(PlayerPedId())-coordinates) > 3 do
                Wait(100)
            end
            spawn(coordinates)
        end)
        return
    end

    spawn(coordinates)
end









--[[

    Events

]]

AddEventHandler("onResourceStop", function (resource)
    if resource ~= "caue-objects" then return end

    if object then
        DeleteObject(object)
    end
end)

Citizen.CreateThread(function()
    Citizen.Wait(1000)

    MaterialHashes = {
        [-461750719] = 1,
        [930824497] = 1,
        [581794674] = 2,
        [-2041329971] = 2,
        [-309121453] = 2,
        [-913351839] = 2,
        [-1885547121] = 2,
        [-1915425863] = 2,
        [-1833527165] = 2,
        [2128369009] = 2,
        [-124769592] = 2,
        [-840216541] = 2,
        [-2073312001] = 3,
        [627123000] = 3,
        [1333033863] = 4,
        [-1286696947] = 5,
        [-1942898710] = 5,
        [-1595148316] = 6,
        [435688960] = 7,
        [223086562] = 8,
        [1109728704] = 8
    }

    PlaceObject(`bkr_prop_weed_01_small_01b`, {
        collision = true,
        forceGroundSnap = true,
        zOffset = -0.5,
        distance = 2.0,
    }, function(coords, material, entity)
        if MaterialHashes[material] then
            lastMaterial = material
            return true
        end
        return false
    end)
end)