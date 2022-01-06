--[[

    Variables

]]

togglehud = true

currentValues = {
    ["health"] = 100,
	["armor"] = 0,
    ["hunger"] = 100,
    ["thirst"] = 100,
    ["oxy"] = 25.0,
    ["stress"] = 0,
    ["parachute"] = false,
    ["harness"] = 0,
}

local lastValues = {}
local lastDamageTrigger = 0
local HoldTime = 0
local LastStroke = 0
local HasNuiFocus = false
local IsFocusThreadRunning = false
local nitrousActive = false
local pauseActive = false

--[[

    Functions

]]





--[[

    Events

]]

RegisterNetEvent("hud:saveCurrentMeta")
AddEventHandler("hud:saveCurrentMeta", function()
    TriggerServerEvent("caue-hud:updateData", GetEntityHealth(PlayerPedId()), GetPedArmour(PlayerPedId()), currentValues["thirst"], currentValues["hunger"])
end)

RegisterNetEvent("caue-hud:toggle")
AddEventHandler("caue-hud:toggle", function(toggle)
    togglehud = toggle

    SendNUIMessage({
        showUi = toggle,
    })
end)

RegisterNetEvent("caue-hud:setData")
AddEventHandler("caue-hud:setData", function(data)
    currentValues["hunger"] = data["hunger"]
    currentValues["thirst"] = data["thirst"]

    SetPedMaxHealth(PlayerPedId(), 200)
    if data["health"] < 10.0 then
        SetEntityHealth(PlayerPedId(), 10.0)
    else
        SetEntityHealth(PlayerPedId(), data["health"])
    end

    SetPlayerMaxArmour(PlayerId(), 60)
    SetPedArmour(PlayerPedId(), data["armour"])
end)

RegisterNetEvent("np-voice:focus:set")
AddEventHandler("np-voice:focus:set", function(hasFocus, hasKeyboard, hasMouse)
	HasNuiFocus = hasFocus

	if HasNuiFocus and not IsFocusThreadRunning then
		Citizen.CreateThread(function()
            while HasNuiFocus do
                if hasKeyboard then
                    DisableAllControlActions(0)
                    EnableControlAction(0, 249, true)
                end

                if not hasKeyboard and hasMouse then
                    DisableControlAction(0, 1, true)
                    DisableControlAction(0, 2, true)
                elseif hasKeyboard and not hasMouse then
                    EnableControlAction(0, 1, true)
                    EnableControlAction(0, 2, true)
                end

                Citizen.Wait(0)
			end
        end)
    end
end)

AddEventHandler("harness", function(toggle, harness)
    if harness then
        currentValues["harness"] = harness
    else
        currentValues["harness"] = 0
    end

    SendNUIMessage({
        action = "harness",
        harness = currentValues["harness"],
    })
end)

AddEventHandler("noshud", function(_nitrous, active, _delay)
    if active then
        local level = 100
        nitrousActive = true

        while true do
            if level < 0 or not nitrousActive then return end

            SendNUIMessage({
                action = "nitrousactive",
                nitrous = level,
            })

            level = level - 1

            Citizen.Wait(100)
        end
    else
        nitrousActive = false

        Citizen.Wait(100)

        SendNUIMessage({
            action = "nitrous",
            nitrous = _nitrous,
            delay = _delay,
        })
    end
end)

AddEventHandler("caue:voice:proximity", function(proximity)
    SendNUIMessage({
        action = "voice",
        voice = proximity,
    })
end)

AddEventHandler("caue:voice:transmissionStarted", function(data)
    SendNUIMessage({
        action = "talking",
        talking = true,
        radio = data.radio,
    })
end)

AddEventHandler("caue:voice:transmissionFinished", function()
    SendNUIMessage({
        action = "talking",
        talking = false,
    })
end)

AddEventHandler("caue-admin:currentDevmode", function(devmode)
    SendNUIMessage({
        action = "dev",
        developer = devmode,
    })
end)

AddEventHandler("caue-admin:currentDebug", function(debugmode)
    SendNUIMessage({
        action = "debug",
        debug = debugmode,
    })
end)

--[[

    Threads

]]

Citizen.CreateThread(function()
    while true do
        --
        -- 1 : WANTED_STARS
        -- 2 : WEAPON_ICON
        -- 3 : CASH
        -- 4 : MP_CASH
        -- 5 : MP_MESSAGE
        -- 6 : VEHICLE_NAME
        -- 7 : AREA_NAME
        -- 8 : VEHICLE_CLASS
        -- 9 : STREET_NAME
        -- 10 : HELP_TEXT
        -- 11 : FLOATING_HELP_TEXT_1
        -- 12 : FLOATING_HELP_TEXT_2
        -- 13 : CASH_CHANGE
        -- 14 : RETICLE
        -- 15 : SUBTITLE_TEXT
        -- 16 : RADIO_STATIONS
        -- 17 : SAVING_GAME
        -- 18 : GAME_STREAM
        -- 19 : WEAPON_WHEEL
        -- 20 : WEAPON_WHEEL_STATS
        -- 21 : HUD_COMPONENTS
        -- 22 : HUD_WEAPONS
        --
        HideHudComponentThisFrame(1)
        HideHudComponentThisFrame(2)
        HideHudComponentThisFrame(3)
        HideHudComponentThisFrame(4)
        -- HideHudComponentThisFrame(5)
        HideHudComponentThisFrame(6)
        HideHudComponentThisFrame(7)
        HideHudComponentThisFrame(8)
        HideHudComponentThisFrame(9)
        HideHudComponentThisFrame(10)
        HideHudComponentThisFrame(11)
        HideHudComponentThisFrame(12)
        HideHudComponentThisFrame(13)
        HideHudComponentThisFrame(14)
        HideHudComponentThisFrame(15)
        -- HideHudComponentThisFrame(16)
        HideHudComponentThisFrame(17)
        HideHudComponentThisFrame(18)
        HideHudComponentThisFrame(19)
        HideHudComponentThisFrame(20)
        -- HideHudComponentThisFrame(21)
        -- HideHudComponentThisFrame(22)

        HudWeaponWheelIgnoreSelection()  -- CAN'T SELECT WEAPON FROM SCROLL WHEEL
        DisableControlAction(0, 37, true)

        HideMinimapInteriorMapThisFrame()
        SetRadarZoom(1000)

        DisableControlAction(0, 200, true) -- Disable ESC

        Citizen.Wait(0)
    end
end)

Citizen.CreateThread(function()
    while true do
        if not IsPauseMenuActive() and IsDisabledControlJustReleased(0, 200) then
            local time  = GetGameTimer()

            HoldTime = (LastStroke and time - LastStroke > 1500) and 1 or HoldTime + 1

            if HoldTime >= 2 and not HasNuiFocus then
                HoldTime = 0
                ActivateFrontendMenu(`FE_MENU_VERSION_MP_PAUSE`, 0, 42)
            end

            LastStroke = time
        end

        Citizen.Wait(0)
    end
end)

Citizen.CreateThread(function()
    while true do
        if currentValues["oxy"] > 0 and IsPedSwimmingUnderWater(PlayerPedId()) then
            if not hasChanged then
                SetAudioSubmixEffectParamInt(0, 0, `enabled`, 1)
                hasChanged = true
            end

            SetPedDiesInWater(PlayerPedId(), false)

            if currentValues["oxy"] > 25.0 then
                currentValues["oxy"] = currentValues["oxy"] - 0.003125
            else
                currentValues["oxy"] = currentValues["oxy"] - 1
            end
        else
            if IsPedSwimmingUnderWater(PlayerPedId()) then
                currentValues["oxy"] = currentValues["oxy"] - 0.01
                SetPedDiesInWater(PlayerPedId(), true)
            end
        end

        if not IsPedSwimmingUnderWater( PlayerPedId() ) and currentValues["oxy"] < 25.0 then
            if hasChanged then
                SetAudioSubmixEffectParamInt(0, 0, `enabled`, 0)
                hasChanged = false
            end

            if GetGameTimer() - lastDamageTrigger > 3000 then
                currentValues["oxy"] = currentValues["oxy"] + 1

                if currentValues["oxy"] > 25.0 then
                    currentValues["oxy"] = 25.0
                end
            else
                if currentValues["oxy"] <= 0 then
                    if exports["isPed"]:isPed("dead") then
                        lastDamageTrigger = -7000
                        currentValues["oxy"] = 25.0
                    else
                        SetEntityHealth(PlayerPedId(), GetEntityHealth(PlayerPedId()) - 20)
                    end
                end
            end
        end

        if currentValues["oxy"] > 25.0 and not oxyOn then
            oxyOn = true
            attachProp("p_s_scuba_tank_s", 24818, -0.25, -0.25, 0.0, 180.0, 90.0, 0.0)
            attachProp2("p_s_scuba_mask_s", 12844, 0.0, 0.0, 0.0, 180.0, 90.0, 0.0)
        elseif oxyOn and currentValues["oxy"] <= 25.0 then
            oxyOn = false
            removeAttachedProp()
            removeAttachedProp2()
        end

        if oxyOn then
            Citizen.Wait(1)
        else
            Citizen.Wait(1000)
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        local get_ped = PlayerPedId()
        local get_ped_veh = GetVehiclePedIsIn(get_ped, false)

        SetPedSuffersCriticalHits(get_ped, true)

        currentValues["health"] = (GetEntityHealth(get_ped) - 100)
        currentValues["armor"] = GetPedArmour(get_ped)
        currentValues["stress"] = math.ceil(stresslevel / 10)
        currentValues["parachute"] = HasPedGotWeapon(get_ped, `gadget_parachute`, false)

        local valueChanged = false

        for k, v in pairs(currentValues) do
            if lastValues[k] == nil or lastValues[k] ~= v then
                valueChanged = true
                lastValues[k] = v
            end
        end

        if valueChanged then
            SendNUIMessage({
                action = "hud",
                health = currentValues["health"],
                armor = currentValues["armor"],
                hunger = currentValues["hunger"],
                thirst = currentValues["thirst"],
                oxygen = currentValues["oxy"],
                oxygenShow = currentValues["oxy"] and math.ceil(currentValues["oxy"]) ~= 25,
                stress = currentValues["stress"],
                parachute = currentValues["parachute"],
            })
        end

        Citizen.Wait(100)
    end
end)

Citizen.CreateThread(function()
    while true do
        local isPMA = IsPauseMenuActive()

        if isPMA and not pauseActive then
            pauseActive = true

            SendNUIMessage({
                showUi = false,
            })
        elseif not isPMA and pauseActive then
            pauseActive = false

            SendNUIMessage({
                showUi = true,
            })
        end

        Citizen.Wait(250)
    end
end)