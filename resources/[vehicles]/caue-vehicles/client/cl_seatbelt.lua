--[[

    Variables

]]

DecorRegister("Vehicle-Harness", 3)

local currentVehicle = 0
local wearingSeatbelt = false
local wearingHarness = false
local isInsideVehicle = 0

local currentVehicleSpeed = 0
local lastCurrentVehicleBodyHealth = 0
local lastCurrentVehicleSpeed = 0
local velocity = GetEntityVelocity(GetVehiclePedIsIn(PlayerPedId()), false)

--[[

    Functions

]]

function isDriver()
    return GetPedInVehicleSeat(currentVehicle, -1) == PlayerPedId()
end

function toggleSeatbelt()
    isInsideVehicle = currentVehicle ~= 0

    if isInsideVehicle then
        local harnessLevel = GetVehicleMetadata(currentVehicle, "harness") or 0
        local hasHarness = harnessLevel > 0

        if wearingSeatbelt and not wearingHarness then -- Wearing seatbelt but no harness, taking off
            TriggerEvent("InteractSound_CL:PlayOnOne", "seatbeltoff", 0.7)
            wearingSeatbelt = false
            SetFlyThroughWindscreenParams(10.0, 1.0, 1.0, 1.0)
        elseif wearingSeatbelt and wearingHarness and isDriver() then -- Wearing seatbelt/harness, taking off
            toggleHarness(false)
        elseif not wearingSeatbelt and not wearingSeatbelt and isDriver() and hasHarness then -- Not wearing anything and have harness
            toggleHarness(true)
        elseif not wearingSeatbelt and not wearingHarness then
            TriggerEvent("InteractSound_CL:PlayOnOne", "seatbelt", 0.7) -- Not wearing anything and have no harness
            wearingSeatbelt = true
            SetFlyThroughWindscreenParams(45.0, 1.0, 1.0, 1.0)
        end

        TriggerEvent("harness", wearingHarness, GetVehicleMetadata(currentVehicle, "harness"))
        TriggerEvent("seatbelt", wearingSeatbelt)
    end
end

function toggleHarness(pState)
    local defaultSteering = GetVehicleHandlingFloat(currentVehicle, "CHandlingData", "fSteeringLock")
    toggleTurning(currentVehicle, false, defaultSteering)
    local harnessTimer = exports["caue-taskbar"]:taskBar(5000, (pState and "Putting on Harness" or "Taking off Harness"), true)

    if harnessTimer == 100 then
        wearingHarness = pState
        wearingSeatbelt = pState
        TriggerEvent("InteractSound_CL:PlayOnOne", (pState and "seatbelt" or "seatbeltoff"), 0.7)
    end

    toggleTurning(currentVehicle, true, defaultSteering)
end

function toggleTurning(pVehicle, pToggle, pDefaultHandlingValue)
    if pVehicle ~= 0 then
        SetVehicleHandlingFloat(pVehicle, "CHandlingData", "fSteeringLock", (pToggle and pDefaultHandlingValue or (pDefaultHandlingValue / 4)))
    end
end

local function sendServerEventForPassengers(velocity)
    local player = PlayerPedId()

    for i = -1, GetVehicleMaxNumberOfPassengers(currentVehicle) - 1 do
        local ped = GetPedInVehicleSeat(currentVehicle, i)
        if ped ~= player and ped ~= 0 then
            TriggerServerEvent("caue-vehicles:eject", GetPlayerServerId(v), velocity)
        end
    end
end

function eject(percent, speed, trigger)
    if math.random(math.ceil(speed)) > percent then
        ejection()

        if trigger then
            TriggerEvent("civilian:alertPolice", 50.0, "carcrash", 0)
        end
    end
end

function ejection()
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    local coords = GetOffsetFromEntityInWorldCoords(veh, 1.0, 0.0, 1.0)

    SetEntityCoords(PlayerPedId(), coords)

    Citizen.Wait(1)

    SetPedToRagdoll(PlayerPedId(), 5511, 5511, 0, 0, 0, 0)
    SetEntityVelocity(PlayerPedId(), velocity["x"] * 4, velocity["y"] * 4, velocity["z"] * 4)

    local ejectspeed = math.ceil(GetEntitySpeed(PlayerPedId()) * 8)
    if IsPedWearingHelmet(PlayerPedId()) and IsThisModelABicycle(GetEntityModel(veh)) then
        local damageAmount = GetEntityHealth(PlayerPedId()) - 1
        if damageAmount > ejectspeed then
            damageAmount = ejectspeed
        end

        SetEntityHealth(PlayerPedId(), GetEntityHealth(PlayerPedId()) - damageAmount)

        return
    end

    SetEntityHealth(PlayerPedId(), (GetEntityHealth(PlayerPedId()) - ejectspeed) )
end

function vehicleCrash(_vehicle, hard)
    if hard then
        stopNitrous(_vehicle)
        TriggerEvent("caue-vehicles:randomDegredation", _vehicle, 15, 10)
    end

    lastCurrentVehicleSpeed = 0.0
    lastCurrentVehicleBodyHealth = 0.0
end

--[[

    Events

]]

RegisterNetEvent("caue-vehicles:eject")
AddEventHandler("caue-vehicles:eject", function(_velocity)
    velocity = _velocity

    if wearingSeatbelt then
        if math.random(10) > 8 then
            ejection()
        end
    else
        if math.random(10) > 4 then
            ejection()
        end
    end
end)

AddEventHandler("vehicle:addHarness", function(type)
    local vehicle = GetVehiclePedIsUsing(PlayerPedId())
    if not vehicle or not DoesEntityExist(vehicle) then return end

    Sync.DecorSetInt(vehicle, "Vehicle-Harness", 100)

    local vid = GetVehicleIdentifier(vehicle)
    if not vid then return end

    RPC.execute("caue-vehicles:updateVehicle", vid, "metadata", "harness", 100)
end)

AddEventHandler("baseevents:enteredVehicle", function(pCurrentVehicle, currentSeat, vehicleDisplayName)
    currentVehicle = pCurrentVehicle

    TriggerEvent("harness", wearingHarness, GetVehicleMetadata(pCurrentVehicle, "harness"))
end)

AddEventHandler("baseevents:leftVehicle", function(pCurrentVehicle, pCurrentSeat, vehicleDisplayName)
    wearingHarness = false
    wearingSeatbelt = false
    currentVehicle = 0

    TriggerEvent("harness", false, 0)
    TriggerEvent("seatbelt", false)
end)

AddEventHandler("baseevents:vehicleChangedSeat", function(pCurrentVehicle, pCurrentSeat, previousSeat)
    wearingHarness = false
    wearingSeatbelt = false

    if pCurrentSeat == -1 then
        TriggerEvent("harness", wearingHarness, GetVehicleMetadata(pCurrentVehicle, "harness"))
    else
        TriggerEvent("harness", false, 0)
    end

    TriggerEvent("seatbelt", wearingSeatbelt)
end)

--[[

    Threads

]]

Citizen.CreateThread(function()
    exports["caue-keybinds"]:registerKeyMapping("", "Vehicle", "Seatbelt", "+toggleSeatbelt", "-toggleSeatbelt", "B")
    RegisterCommand("+toggleSeatbelt", toggleSeatbelt, false)
    RegisterCommand("-toggleSeatbelt", function() end, false)
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)

        if currentVehicle ~= 0 then
            if wearingHarness then
                DisableControlAction(0, 75, true)
                if IsDisabledControlJustPressed(1, 75) then
                    TriggerEvent("DoLongHudText", "You probably should undo your harness...", 101)
                end
            elseif IsUsingNitro() then
                if IsDisabledControlJustPressed(1, 75) then
                    stopNitrous(currentVehicle)
                end
            else
                Citizen.Wait(1000)
            end
        else
            Citizen.Wait(5000)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)

        if currentVehicle ~= nil and currentVehicle ~= false and currentVehicle ~= 0 then
            if isDriver() then
                local collision = HasEntityCollidedWithAnything(currentVehicle)
                local currentEngineHealth = GetVehicleEngineHealth(currentVehicle)

                if collision == false then
                    lastCurrentVehicleSpeed = GetEntitySpeed(currentVehicle)
                    lastCurrentVehicleBodyHealth = GetVehicleBodyHealth(currentVehicle)
                    velocity = GetEntityVelocity(currentVehicle)

                    if currentEngineHealth > 10.0 and (currentEngineHealth < 175.0 or lastCurrentVehicleBodyHealth < 50.0) then
                        vehicleCrash(currentVehicle)
                        -- Citizen.Wait(1000)
                    end
                else
                    Citizen.Wait(100)

                    local currentVehicleBodyHealth = GetVehicleBodyHealth(currentVehicle)
                    local currentVehicleSpeed = GetEntitySpeed(currentVehicle)

                    if currentEngineHealth > 0.0 and lastCurrentVehicleBodyHealth - currentVehicleBodyHealth > 15 then
                        if lastCurrentVehicleSpeed > 30.5 and currentVehicleSpeed < (lastCurrentVehicleSpeed * 0.75) then
                            if not IsThisModelABike(GetEntityModel(currentVehicle)) then
                                sendServerEventForPassengers(velocity)

                                local _vehicle = currentVehicle

                                if wearingHarness then
                                    local harnessLevel = GetVehicleMetadata(currentVehicle, "harness") or 0

                                    local newLevel = harnessLevel - 10
                                    if newLevel < 1 then
                                        newLevel = 0

                                        wearingHarness = false
                                        wearingSeatbelt = false

                                        TriggerEvent("seatbelt", wearingSeatbelt)

                                        TriggerEvent("DoLongHudText", "Harness Broken!", 2)
                                    end

                                    Sync.DecorSetInt(currentVehicle, "Vehicle-Harness", newLevel)
                                    TriggerEvent("harness", wearingHarness, GetVehicleMetadata(currentVehicle, "harness"))

                                    local vid = GetVehicleIdentifier(currentVehicle)
                                    if vid then
                                        RPC.execute("caue-vehicles:updateVehicle", vid, "metadata", "harness", newLevel)
                                    end
                                elseif not wearingSeatbelt then
                                    eject(30.5, lastCurrentVehicleSpeed, true)
                                elseif wearingSeatbelt and lastCurrentVehicleSpeed > 41.6 then
                                    eject(33.0, lastCurrentVehicleSpeed, false)
                                end

                                vehicleCrash(_vehicle, true)

                                Citizen.Wait(1000)

                                lastCurrentVehicleSpeed = 0.0
                                lastCurrentVehicleBodyHealth = currentVehicleBodyHealth
                            else
                                vehicleCrash(currentVehicle)

                                Citizen.Wait(1000)
                            end
                        end
                    else
                        if currentEngineHealth > 10.0 and (currentEngineHealth < 195.0 or currentVehicleBodyHealth < 50.0) then
                            vehicleCrash(currentVehicle)

                            Citizen.Wait(1000)
                        end

                        lastCurrentVehicleSpeed = currentVehicleSpeed
                        lastCurrentVehicleBodyHealth = currentVehicleBodyHealth
                    end
                end
            else
                Citizen.Wait(1000)
            end
        else
            currentVehicleSpeed = 0
            lastCurrentVehicleSpeed = 0
            lastCurrentVehicleBodyHealth = 0

            Citizen.Wait(4000)
        end
    end
end)