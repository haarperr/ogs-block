--[[

    Variables

]]

imDead = false

thecount = 0
gamerTimer = 0
EHeld = 500

disablingloop = false

--[[

    Functions

]]

function deathTimer()
    thecount = 300
    gamerTimer = GetGameTimer()
    EHeld = 500

    TriggerEvent("civilian:alertPolice", 100.0, "death", 0)
    TriggerEvent("doTimer")
    TriggerEvent("disableAllActions")

    while imDead do
        Citizen.Wait(5)

        if GetGameTimer() - gamerTimer > 1000 then
            gamerTimer = GetGameTimer()
            thecount = thecount - 1

            if thecount == 60 or thecount == 120 or thecount == 180 or thecount == 240 then
                TriggerEvent("civilian:alertPolice", 100.0, "death", 0)
            end

            while thecount < 0 do
                Citizen.Wait(1)

                if IsControlPressed(1, 38) then
                    local hspDist = #(vector3(307.93017578125, -594.99530029297, 43.291835784912) - GetEntityCoords(PlayerPedId()))
                    EHeld = EHeld - 1
                    if hspDist > 5 and EHeld < 1 then
                        thecount = 99999999
                        releaseBody()
                    end
                else
                    EHeld = 500
                end
            end
        end
    end
end

function drawTxt(x, y, width, height, scale, text, r, g, b, a, outline)
    SetTextFont(4)
    SetTextProportional(0)
    SetTextScale(scale, scale)
    SetTextColour(r, g, b, a)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextEdge(2, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x - width/2, y - height/2 + 0.005)
end

function InVeh()
    local intrunk = exports["caue-base"]:getVar("trunk")

    if IsPedSittingInAnyVehicle(PlayerPedId()) or intrunk then
        return true
    else
        return false
    end
end

function DoDeathAnim(ped)
    ClearPedTasksImmediately(ped)
    loadAnimDict("dead")
    TaskPlayAnim(ped, "dead", "dead_d", 8.0, -8, -1, 1, 0, 0, 0, 0)
end

function DoVehDeathAnim(ped)
    loadAnimDict("random@crash_rescue@car_death@std_car")
    TaskPlayAnim(ped, "random@crash_rescue@car_death@std_car", "loop", 8.0, -8, -1, 1, 0, 0, 0, 0)
end

function IsDeadAnimPlaying()
    if IsEntityPlayingAnim(PlayerPedId(), "dead", "dead_d", 1) then
        return true
    else
        return false
    end
end

function IsDeadVehAnimPlaying()
    if IsEntityPlayingAnim(PlayerPedId(), "random@crash_rescue@car_death@std_car", "loop", 1) then
        return true
    else
        return false
    end
end

function ResetRelationShipGroups()
    Citizen.Wait(1000)

    if exports["caue-jobs"]:getJob(false, "is_emergency") then
        SetPedRelationshipGroupDefaultHash(PlayerPedId(), `MISSION2`)
        SetPedRelationshipGroupHash(PlayerPedId(), `MISSION2`)
    else
        SetPedRelationshipGroupDefaultHash(PlayerPedId(), `PLAYER`)
        SetPedRelationshipGroupHash(PlayerPedId(), `PLAYER`)
    end

    TriggerEvent("caue-ai:setDefaultRelations")
end

function releaseBody()
    thecount = 240
    imDead = false

    TriggerEvent("DoLongHudText", "You have been revived by medical staff")
    TriggerServerEvent("Evidence:ClearDamageStates")
    TriggerServerEvent("caue-inventory:clear")
    TriggerServerEvent("police:SeizeCash", GetPlayerServerId(PlayerId()))
    TriggerEvent("resurrect:relationships")
    TriggerEvent("Evidence:isAlive")

    ClearPedTasksImmediately(PlayerPedId())
    FreezeEntityPosition(PlayerPedId(), false)
    RemoveAllPedWeapons(PlayerPedId())
    SetEntityCoords(PlayerPedId(), 357.43, -593.36, 28.79)
    SetEntityInvincible(PlayerPedId(), false)
    ClearPedBloodDamage(PlayerPedId())
    SetCurrentPedWeapon(PlayerPedId(), 2725352035, true)

    -- TODO:
    -- local wasBeatdown = exports["police"]:getBeatmodeDebuff()

    -- if wasBeatdown then
    --     TriggerEvent("police:startBeatdownDebuff")
    -- end

    Citizen.CreateThread(function()
        Citizen.Wait(4000)

        TriggerEvent("unEscortPlayer")
        TriggerEvent("resetCuffs")
    end)
end

--[[

    Events

]]

RegisterNetEvent("doTimer")
AddEventHandler("doTimer", function()
    exports["caue-base"]:setVar("dead", true)
    exports["caue-flags"]:SetPedFlag(PlayerPedId(), "isDead", true)
    TriggerEvent("caue-death:dead", true)

    while imDead do
        Citizen.Wait(0)

        if thecount > 0 then
            drawTxt(0.89, 1.42, 1.0,1.0,0.6, "Respawn: ~r~" .. math.ceil(thecount) .. "~w~ seconds remaining", 255, 255, 255, 255)
        else
            drawTxt(0.89, 1.42, 1.0,1.0,0.6, "~w~HOLD ~r~E ~w~(" .. math.ceil(EHeld/100) .. ") ~w~TO ~r~RESPAWN ~w~OR WAIT FOR ~r~EMS", 255, 255, 255, 255)
        end
    end

    exports["caue-base"]:setVar("dead", false)
    exports["caue-flags"]:SetPedFlag(PlayerPedId(), "isDead", false)
    TriggerEvent("caue-death:dead", false)
end)

RegisterNetEvent("disableAllActions")
AddEventHandler("disableAllActions", function()
    if not disablingloop then
        disablingloop = true

        while GetEntitySpeed(PlayerPedId()) > 0.5 do
            Citizen.Wait(1)
        end

        local seat = 0
        local veh = GetVehiclePedIsUsing(PlayerPedId())
        if veh then
            local vehmodel = GetEntityModel(veh)
            for i = -1, GetVehicleModelNumberOfSeats(vehmodel) do
                if GetPedInVehicleSeat(veh, i) == PlayerPedId() then
                    seat = i
                end
            end
        end

        TriggerEvent("resurrect:relationships")

        if veh then
            TaskWarpPedIntoVehicle(PlayerPedId(), veh, seat)
        end

        TriggerEvent("disableVehicleActions")
        TriggerEvent("disableAllActions2")

        SetEntityInvincible(PlayerPedId(), true)

        while imDead do
            Citizen.Wait(200)

            if InVeh() and (not IsDeadVehAnimPlaying() or IsPedRagdoll(PlayerPedId())) then
                DoVehDeathAnim(PlayerPedId())
            elseif not InVeh() and (not IsDeadAnimPlaying() or IsPedRagdoll(PlayerPedId())) then
                DoDeathAnim(PlayerPedId())
            end

            Citizen.Wait(800)
        end

        SetEntityInvincible(PlayerPedId(), false)
        ClearPedTasksImmediately(PlayerPedId())

        disablingloop = false
    end
end)

RegisterNetEvent("disableVehicleActions")
AddEventHandler("disableVehicleActions", function()
    while imDead do
        local currentVehicle = GetVehiclePedIsIn(PlayerPedId(), false)

        Wait(300)

        if PlayerPedId() ==  GetPedInVehicleSeat(currentVehicle, -1) then
            SetVehicleUndriveable(currentVehicle, true)
        end
    end
end)

RegisterNetEvent("disableAllActions2")
AddEventHandler("disableAllActions2", function()
    while imDead do
        Citizen.Wait(0)

        DisableInputGroup(0)
        DisableInputGroup(1)
        DisableInputGroup(2)
        DisableControlAction(1, 19, true)
        DisableControlAction(0, 34, true)
        DisableControlAction(0, 9, true)
        DisableControlAction(0, 32, true)
        DisableControlAction(0, 8, true)
        DisableControlAction(2, 31, true)
        DisableControlAction(2, 32, true)
        DisableControlAction(1, 33, true)
        DisableControlAction(1, 34, true)
        DisableControlAction(1, 35, true)
        DisableControlAction(1, 21, true)  -- space
        DisableControlAction(1, 22, true)  -- space
        DisableControlAction(1, 23, true)  -- F
        DisableControlAction(1, 24, true)  -- F
        DisableControlAction(1, 25, true)  -- F
        DisableControlAction(1, 106, true) -- VehicleMouseControlOverride
        DisableControlAction(1, 140, true) --Disables Melee Actions
        DisableControlAction(1, 141, true) --Disables Melee Actions
        DisableControlAction(1, 142, true) --Disables Melee Actions
        DisableControlAction(1, 37, true) --Disables INPUT_SELECT_WEAPON (tab) Actions
        DisablePlayerFiring(PlayerPedId(), true) -- Disable weapon firing

        if IsControlJustPressed(1, 29) then
            SetPedToRagdoll(PlayerPedId(), 26000, 26000, 3, 0, 0, 0)
            Citizen.Wait(22000)
            TriggerEvent("deathAnim")
        end
    end

    SetPedCanRagdoll(PlayerPedId(), false)
end)

RegisterNetEvent("resurrect:relationships")
AddEventHandler("resurrect:relationships", function()
    NetworkResurrectLocalPlayer(GetEntityCoords(PlayerPedId(), true), true, true, false)
    ResetRelationShipGroups()
end)

RegisterNetEvent("ressurection:relationships:norevive")
AddEventHandler("ressurection:relationships:norevive", function()
    ResetRelationShipGroups()
end)

dragged = false
RegisterNetEvent("deathdrop")
AddEventHandler("deathdrop", function(beingDragged)
    dragged = beingDragged
    if not beingDragged and imDead then
        SetEntityHealth(PlayerPedId(), 200.0)
        SetEntityCoords(PlayerPedId(), GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 1.0, 1.0))
    end
end)

--[[

    Threads

]]

Citizen.CreateThread(function()
    local ped = PlayerPedId()
    SetPedConfigFlag(ped, 184, true)

    while true do
        Wait(5000)

        if PlayerPedId() ~= ped then
            ped = PlayerPedId()
            SetPedConfigFlag(ped, 184, true)
        end
    end
end)

Citizen.CreateThread(function()
    SetEntityInvincible(PlayerPedId(), false)

    imDead = false

    while true do
        Wait(100)

        if IsEntityDead(PlayerPedId()) then
            TriggerEvent("actionbar:setEmptyHanded")
            SetEntityInvincible(PlayerPedId(), true)
            SetEntityHealth(PlayerPedId(), GetEntityMaxHealth(PlayerPedId()))
            TriggerServerEvent("police:isDead", GetPedCauseOfDeath(PlayerPedId()))
            TriggerEvent("Evidence:isDead")

            -- TODO:
            -- local isFromBeatdown = exports["police"]:getIsInBeatmode()

            -- if isFromBeatdown then
            --     exports["police"]:setIsInBeatmode(false)
            --     exports["police"]:setBeatmodeDebuff(true)
            -- end

            if not imDead then
                imDead = true
                deathTimer()
            end
        end
    end
end)