--[[

    Functions

]]

local function SetWeaponDrops()
    local handle, ped = FindFirstPed()
    local finished = false

    repeat
        if not IsEntityDead(ped) then
            SetPedDropsWeaponsWhenDead(ped, false)
        end
        finished, ped = FindNextPed(handle)
    until not finished

    EndFindPed(handle)
end

--[[

    Threads

]]

Citizen.CreateThread(function()
    for i = 1, 15 do
        EnableDispatchService(i, false)
    end

    -- enable pvp
    for i = 0, 255 do
        if NetworkIsPlayerConnected(i) then
            if NetworkIsPlayerConnected(i) and GetPlayerPed(i) ~= nil then
                SetCanAttackFriendly(GetPlayerPed(i), true, true)
            end
        end
    end

    SetMaxWantedLevel(0)

    NetworkSetFriendlyFireOption(true)

    -- Disable vehicle rewards
    DisablePlayerVehicleRewards(PlayerId())

    while true do
        Citizen.Wait(1)

        local ped = PlayerPedId()
        local vehicle = GetVehiclePedIsIn(ped, false)
        local timer = 0

        if IsPedInAnyVehicle(ped, false) then
            if GetPedInVehicleSeat(GetVehiclePedIsIn(ped, false), 0) == ped then
                if GetIsTaskActive(ped, 165) then
                    SetPedIntoVehicle(ped, GetVehiclePedIsIn(ped, false), 0)
                end
            end

            local model = GetEntityModel(vehicle)
            local roll = GetEntityRoll(vehicle)

            if not IsThisModelABoat(model) and not IsThisModelAHeli(model) and not IsThisModelAPlane(model) and IsEntityInAir(vehicle) or (roll < -50 or roll > 50) then
                DisableControlAction(0, 59) -- leaning left/right
                DisableControlAction(0, 60) -- leaning up/down
            end

            timer = 0
        else
            if IsPedWearingHelmet(ped) then
                timer = timer + 1

                if timer >= 5000 and not IsPedInAnyVehicle(ped, true) then
                    RemovePedHelmet(ped, false)
                    timer = 0
                end
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500)

        SetWeaponDrops()
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(500)

        if not IsPedInAnyVehicle(PlayerPedId(), false) then
            if IsPedUsingActionMode(PlayerPedId()) then
                SetPedUsingActionMode(PlayerPedId(), -1, -1, 1)
            end
        else
            Citizen.Wait(3000)
        end
    end
end)

Citizen.CreateThread( function()
    local resetcounter = 0
    local jumpDisabled = false

    while true do
        Citizen.Wait(100)

        if jumpDisabled and resetcounter > 0 and IsPedJumping(PlayerPedId()) then
            SetPedToRagdoll(PlayerPedId(), 1000, 1000, 3, 0, 0, 0)
            resetcounter = 0
        end

        if not jumpDisabled and IsPedJumping(PlayerPedId()) then
            jumpDisabled = true
            resetcounter = 10
            Citizen.Wait(1200)
        end

        if resetcounter > 0 then
            resetcounter = resetcounter - 1
        else
            if jumpDisabled then
                resetcounter = 0
                jumpDisabled = false
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        if IsPedInCover(PlayerPedId(), 0) and not IsPedAimingFromCover(PlayerPedId()) then
            DisablePlayerFiring(PlayerPedId(), true)
        end

        Citizen.Wait(0)
    end
end)

Citizen.CreateThread(function()
    while true do
        SetPedMinGroundTimeForStungun(PlayerPedId(), 5000)
        SetEntityProofs(PlayerPedId(), false, false, false, false, false, true, false, false)
        SetPlayerHealthRechargeMultiplier(PlayerId(), 0.0)
        SetRadarBigmapEnabled(false, false)

        Wait(2000)
    end
end)

Citizen.CreateThread(function()
    while true do
        InvalidateIdleCam()
        N_0x9e4cfff989258472() -- Disable the vehicle idle camera
        Wait(10000) --The idle camera activates after 30 second so we don't need to call this per frame
    end
end)