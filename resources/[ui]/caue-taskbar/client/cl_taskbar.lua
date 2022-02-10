--[[

    Variables

]]

guiEnabled = false
local taskInProcessId = 0
local activeTasks = {}
local taskInProcess = false
local coffeetimer = 0

--[[

    Functions

]]

function openGui(sentLength, taskID, label, keepWeapon)
    if not keepWeapon then
        TriggerEvent("actionbar:setEmptyHanded")
    end

    guiEnabled = true

    SendNUIMessage({
        runProgress = true,
        Length = sentLength,
        Task = taskID,
        name = namesent
    })
end

function updateGui(sentLength,taskID,namesent)
    SendNUIMessage({
        runUpdate = true,
        Length = sentLength,
        Task = taskID,
        name = namesent
    })
end

function closeGui()
    guiEnabled = false

    -- maybe we let the task clear the anims etc.
    -- ClearPedTasks(PlayerPedId())

    SendNUIMessage({
        closeProgress = true
    })
end

function closeGuiFail()
    guiEnabled = false

    -- maybe we let the task clear the anims etc.
    -- ClearPedTasks(PlayerPedId())

    SendNUIMessage({
        closeProgress = true
    })
end

function closeNormalGui()
    guiEnabled = false
end

function taskCancel()
    closeGui()

    local taskIdentifier = taskInProcessId
    activeTasks[taskIdentifier] = 2
end

function taskBarFail(maxcount,curTime,length)
    local totaldone = math.ceil(100 - (((maxcount - curTime) / length) * 100))
    totaldone = math.min(100, totaldone)
    taskInProcess = false
    closeGuiFail()
    return totaldone
end

function taskBar(length, name, runCheck, keepWeapon, vehicle, vehCheck, cb, moveCheck)
    local playerPed = PlayerPedId()
    local firstPosition = GetEntityCoords(playerPed)

    if taskInProcess then
        if cb then cb(0) end
        return 0
    end

    if coffeetimer > 0 then
        length = math.ceil(length * 0.66)
    end

    taskInProcess = true
    local taskIdentifier = "taskid" .. math.random(1000000)
    taskInProcessId = taskIdentifier
    openGui(length,taskIdentifier,name,keepWeapon)
    activeTasks[taskIdentifier] = 1

    local maxcount = GetGameTimer() + length
    local curTime
    local playerPed = PlayerPedId()

    while activeTasks[taskIdentifier] == 1 do
        Citizen.Wait(0)

        curTime = GetGameTimer()

        if curTime > maxcount or not guiEnabled then
            activeTasks[taskIdentifier] = 2
        end

        local fuck = 100 - (((maxcount - curTime) / length) * 100)
        fuck = math.min(100, fuck)

        updateGui(fuck,taskIdentifier,name)

        if not keepWeapon and GetSelectedPedWeapon(PlayerPedId()) ~= GetHashKey("WEAPON_UNARMED") then
            local totaldone = taskBarFail(maxcount,curTime,length)
            if cb then cb(totaldone) end
            return totaldone
        end

        if runCheck then
            if IsPedClimbing(playerPed) or IsPedJumping(playerPed) or IsPedSwimming(playerPed) or IsPedRagdoll(playerPed) then
                SetPlayerControl(PlayerId(), 0, 0)
                local totaldone = taskBarFail(maxcount,curTime,length)
                Citizen.Wait(1000)
                SetPlayerControl(PlayerId(), 1, 1)
                if cb then cb(totaldone) end
                return totaldone
            end
        end

        if moveCheck then
          if #(firstPosition-GetEntityCoords(playerPed)) > moveCheck then
              local totaldone = taskBarFail(maxcount,curTime,length)
              if cb then cb(totaldone) end
              return totaldone
          end
        end

        if vehicle ~= nil and vehicle ~= 0 then
            local driverPed = GetPedInVehicleSeat(vehicle, -1)
            if driverPed ~= playerPed and vehCheck then
                local totaldone = taskBarFail(maxcount,curTime,length)
                if cb then cb(totaldone) end
                return totaldone
            end

            local model = GetEntityModel(vehicle)
            if IsThisModelACar(model) or IsThisModelABike(model) or IsThisModelAQuadbike(model) then
                if IsEntityInAir(vehicle) then
                    Wait(1000)
                    if IsEntityInAir(vehicle) then
                        local totaldone = taskBarFail(maxcount,curTime,length)
                        if cb then cb(totaldone) end
                        return totaldone
                    end
                end
            end
        end
    end

    local resultTask = activeTasks[taskIdentifier]
    if resultTask == 2 then
        local totaldone = taskBarFail(maxcount,curTime,length)
        if cb then cb(totaldone) end
        return totaldone

    else
        closeGui()
        taskInProcess = false

        if cb then cb(100) end
        return 100
    end
end

--[[

    Exports

]]

exports("taskBar", taskBar)
exports("taskCancel", taskCancel)
exports("closeGuiFail", closeGuiFail)

--[[

    NUI

]]

RegisterNUICallback("taskEnd", function(data, cb)
    closeNormalGui()

    local taskIdentifier = data.tasknum
    activeTasks[taskIdentifier] = 3
end)

RegisterNUICallback("taskCancel", function(data, cb)
    closeGui()

    local taskIdentifier = data.tasknum
    activeTasks[taskIdentifier] = 2
end)

--[[

    Events

]]

RegisterNetEvent("hud:taskBar")
AddEventHandler("hud:taskBar", function(length,name)
    taskBar(length,name)
end)

RegisterNetEvent("coffee:drink")
AddEventHandler("coffee:drink", function()
    if coffeetimer > 0 then
        coffeetimer = 6000
        TriggerEvent("Evidence:StateSet",27,6000)
        return
    else
        TriggerEvent("Evidence:StateSet",27,6000)
        coffeetimer = 6000
    end

    while coffeetimer > 0 do
        coffeetimer = coffeetimer - 1
        Wait(1000)
    end
end)