--[[

    Variables

]]

lockpicking = false

--[[

    Functions

]]

function DrawText3Ds(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
    DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 68)
end

--[[

    Events

]]

AddEventHandler("caue-inventory:lockpick", function(isForced, inventoryName, slot)
    TriggerEvent("robbery:scanLock", true)

    if lockpicking then return end
    lockpicking = true

    local targetVehicle = GetVehiclePedIsUsing(PlayerPedId())

    if targetVehicle == 0 then
        local coordA = GetEntityCoords(PlayerPedId(), 1)
        local coordB = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 100.0, 0.0)

        targetVehicle = getVehicleInDirection(coordA, coordB)

        if targetVehicle == 0 then
            lockpicking = false
            TriggerEvent("housing:attemptToLockPick")
            return
        end

        local driverPed = GetPedInVehicleSeat(targetVehicle, -1)
        if driverPed ~= 0 then
            lockpicking = false
            return
        end

        local d1,d2 = GetModelDimensions(GetEntityModel(targetVehicle))
        local leftfront = GetOffsetFromEntityInWorldCoords(targetVehicle, d1["x"]-0.25,0.25,0.0)

        local count = 5000
        local dist = #(vector3(leftfront["x"],leftfront["y"],leftfront["z"]) - GetEntityCoords(PlayerPedId()))
        while dist > 2.0 and count > 0 do
            dist = #(vector3(leftfront["x"],leftfront["y"],leftfront["z"]) - GetEntityCoords(PlayerPedId()))
            Citizen.Wait(1)
            count = count - 1
            DrawText3Ds(leftfront["x"],leftfront["y"],leftfront["z"],"Move here to lockpick.")
        end

        if dist > 2.0 then
            lockpicking = false
            return
        end

        TaskTurnPedToFaceEntity(PlayerPedId(), targetVehicle, 1.0)

        Citizen.Wait(1000)

        TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 3.0, "lockpick", 0.4)

        local triggerAlarm = GetVehicleDoorLockStatus(targetVehicle) > 1
        if triggerAlarm then
            SetVehicleAlarm(targetVehicle, true)
            StartVehicleAlarm(targetVehicle)
        end

        TriggerEvent("civilian:alertPolice", 20.0, "lockpick", targetVehicle)
        TriggerEvent("animation:lockpickinvtestoutside")
        TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 3.0, "lockpick", 0.4)

        local finished = exports["caue-taskbarskill"]:taskBarSkill(25000, 10)
        if finished ~= 100 then
            lockpicking = false
            return
        end

        local finished = exports["caue-taskbarskill"]:taskBarSkill(15000, 10)
        if finished ~= 100 then
            lockpicking = false
            return
        end

        local finished = exports["caue-taskbarskill"]:taskBarSkill(10000, math.random(5, 10))
        if finished ~= 100 then
            lockpicking = false
            return
        end

        local finished = exports["caue-taskbarskill"]:taskBarSkill(5000, math.random(5, 10))
        if finished ~= 100 then
            lockpicking = false
            return
        end

        if triggerAlarm then
            SetVehicleAlarm(targetVehicle, false)
        end

        if #(GetEntityCoords(targetVehicle) - GetEntityCoords(PlayerPedId())) < 10.0 and targetVehicle ~= 0 and GetEntitySpeed(targetVehicle) < 5.0 then
            SetVehicleDoorsLocked(targetVehicle, 1)
            TriggerEvent("DoLongHudText", "Veículo destrancado.")
            TriggerEvent("InteractSound_CL:PlayOnOne", "unlock", 0.1)
        end
    else
        if targetVehicle ~= 0 and not isForced then
            if exports["caue-vehicles"]:HasVehicleKey(targetVehicle) then
                lockpicking = false
                return
            end

            TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 3.0, "lockpick", 0.4)

            local triggerAlarm = GetVehicleDoorLockStatus(targetVehicle) > 1
            if triggerAlarm then
                SetVehicleAlarm(targetVehicle, true)
                StartVehicleAlarm(targetVehicle)
            end

            SetVehicleHasBeenOwnedByPlayer(targetVehicle, true)

            TriggerEvent("animation:lockpickinvtest")
            TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 3.0, "lockpick", 0.4)

            TriggerEvent("civilian:alertPolice", 12.0, "lockpick", targetVehicle)

            local p = promise:new()

            exports["caue-vehicles"]:HotwireVehicle(function(result)
                p:resolve(result)
            end)

            local result = Citizen.Await(p)

            if not result.success then
                if result.stage >= 2 then
                    TriggerEvent("DoLongHudText", "A lockpick está um pouco torta.", 2)
                    TriggerEvent("inventory:removeItem", "lockpick", 1)
                    lockpicking = false
                    return
                end
            end
        end
    end

    lockpicking = false
end)

AddEventHandler("animation:lockpickinvtestoutside", function()
    RequestAnimDict("veh@break_in@0h@p_m_one@")
    while not HasAnimDictLoaded("veh@break_in@0h@p_m_one@") do
        Citizen.Wait(0)
    end

    while lockpicking do
        TaskPlayAnim(PlayerPedId(), "veh@break_in@0h@p_m_one@", "low_force_entry_ds", 1.0, 1.0, 1.0, 16, 0.0, 0, 0, 0)
        Citizen.Wait(2500)
    end

    ClearPedTasks(PlayerPedId())
end)

AddEventHandler("animation:lockpickinvtest", function(disable)
    RequestAnimDict("mini@repair")
    while not HasAnimDictLoaded("mini@repair") do
        Citizen.Wait(0)
    end

    if disable ~= nil then
        if not disable then
            lockpicking = false
            return
        else
            lockpicking = true
        end
    end

    while lockpicking do
        if not IsEntityPlayingAnim(PlayerPedId(), "mini@repair", "fixing_a_player", 3) then
            ClearPedSecondaryTask(PlayerPedId())
            TaskPlayAnim(PlayerPedId(), "mini@repair", "fixing_a_player", 8.0, -8, -1, 16, 0, 0, 0, 0)
        end

        Citizen.Wait(1)
    end

    ClearPedTasks(PlayerPedId())
end)

AddEventHandler("caue-inventory:getBrick", function()
    loadAnimDict("random@domestic")
  	TaskTurnPedToFaceEntity(PlayerPedId(), pEntity, -1)
  	TaskPlayAnim(PlayerPedId(),"random@domestic", "pickup_low",5.0, 1.0, 1.0, 48, 0.0, 0, 0, 0)
  	Citizen.Wait(1600)
  	ClearPedTasks(PlayerPedId())
    TriggerEvent("player:receiveItem", "1064738331", 1)
end)











































local fixingvehicle = false








RegisterNetEvent("randPickupAnim")
AddEventHandler("randPickupAnim", function()
    loadAnimDict("pickup_object")
    TaskPlayAnim(PlayerPedId(),"pickup_object", "putdown_low",5.0, 1.5, 1.0, 48, 0.0, 0, 0, 0)
    Wait(1000)
    ClearPedSecondaryTask(PlayerPedId())
end)

RegisterNetEvent("SniffRequestCID")
AddEventHandler("SniffRequestCID", function(src)
    local cid = exports["caue-base"]:getChar("id")
    TriggerServerEvent("SniffCID",cid,src)
end)

-- item id, amount allowed, crafting.
function CreateCraftOption(id, add, craft)
    TriggerEvent("CreateCraftOption", id, add, craft)
end





-- DNA

RegisterNetEvent("evidence:addDnaSwab")
AddEventHandler("evidence:addDnaSwab", function(dna)
    TriggerEvent("DoLongHudText", "Resultado de DNA: " .. dna,1)
end)

RegisterNetEvent("CheckDNA")
AddEventHandler("CheckDNA", function()
    TriggerServerEvent("Evidence:checkDna")
end)

RegisterNetEvent("evidence:dnaSwab")
AddEventHandler("evidence:dnaSwab", function(pArgs, pEntity, pContext)
    TriggerServerEvent("police:dnaAsk", GetPlayerServerId(NetworkGetPlayerIndexFromPed(pEntity)))
end)

RegisterNetEvent("evidence:swabNotify")
AddEventHandler("evidence:swabNotify", function()
    TriggerEvent("DoLongHudText", "Cotonete de DNA utilizado.",1)
end)


function GetPlayers()
    local players = {}

    for i = 0, 255 do
        if NetworkIsPlayerActive(i) then
            players[#players+1]= i
        end
    end

    return players
end

function GetClosestPlayer()
    local players = GetPlayers()
    local closestDistance = -1
    local closestPlayer = -1
    local ply = PlayerPedId()
    local plyCoords = GetEntityCoords(ply, 0)

    for index,value in ipairs(players) do
        local target = GetPlayerPed(value)
        if(target ~= ply) then
            local targetCoords = GetEntityCoords(GetPlayerPed(value), 0)
            local distance = #(vector3(targetCoords["x"], targetCoords["y"], targetCoords["z"]) - vector3(plyCoords["x"], plyCoords["y"], plyCoords["z"]))
            if(closestDistance == -1 or closestDistance > distance) then
                closestPlayer = value
                closestDistance = distance
            end
        end
    end

    return closestPlayer, closestDistance
end

-- this is the upside down world, be careful.

function getVehicleInDirection(coordFrom, coordTo)
    local offset = 0
    local rayHandle
    local vehicle

    for i = 0, 100 do
        rayHandle = CastRayPointToPoint(coordFrom.x, coordFrom.y, coordFrom.z, coordTo.x, coordTo.y, coordTo.z + offset, 10, PlayerPedId(), 0)
        a, b, c, d, vehicle = GetRaycastResult(rayHandle)

        offset = offset - 1

        if vehicle ~= 0 then break end
    end

    local distance = Vdist2(coordFrom, GetEntityCoords(vehicle))

    if distance > 25 then vehicle = nil end

    return vehicle ~= nil and vehicle or 0
end










local function repairVehiclePart(pTargetVehicle, pData)
    for part, data in pairs(pData) do
        if part == "Engine" then
            SetVehicleEngineHealth(pTargetVehicle, data + 0.0)
        elseif part == "Body" then
            SetVehicleBodyHealth(pTargetVehicle, data + 0.0)
        elseif part == "PetrolTank" then
            SetVehiclePetrolTankHealth(pTargetVehicle, data + 0.0)
        elseif part == "Tyre" then
            for i = 0, 11 do
                SetVehicleTyreFixed(pTargetVehicle, i)
            end
        end
    end
end

RegisterNetEvent("repair:vehicle")
AddEventHandler("repair:vehicle", function(pTargetVehicle, pData)
    repairVehiclePart(NetToVeh(pTargetVehicle), pData)
end)

-- Animations
RegisterNetEvent("animation:load")
AddEventHandler("animation:load", function(dict)
    while ( not HasAnimDictLoaded( dict ) ) do
        RequestAnimDict( dict )
        Citizen.Wait( 5 )
    end
end)
