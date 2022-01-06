--[[

    Variables

]]

local TimerEnabled = false

--[[

    Functions

]]

function plyTackel()
	if not exports["caue-base"]:getVar("handcuffed") and GetLastInputMethod(2) then
		local isInVeh = IsPedInAnyVehicle(PlayerPedId(), false)
		if not isInVeh and GetEntitySpeed(PlayerPedId()) > 2.5 then
			TryTackle()
		end
	end
end

function TryTackle()
    if not TimerEnabled then
        local t, distance = GetClosestPlayer()

        if distance ~= -1 and distance < 2 then
            local maxheading = GetEntityHeading(PlayerPedId()) + 15.0
            local minheading = GetEntityHeading(PlayerPedId()) - 15.0
            local theading = GetEntityHeading(t)

            TriggerServerEvent("CrashTackle", GetPlayerServerId(t))
            TriggerEvent("animation:tacklelol")

            TimerEnabled = true
            Citizen.Wait(6000)
            TimerEnabled = false
        else
            TimerEnabled = true
            Citizen.Wait(1000)
            TimerEnabled = false
        end
    end
end

--[[

    Events

]]

RegisterNetEvent("playerTackled")
AddEventHandler("playerTackled", function()
	SetPedToRagdoll(PlayerPedId(), math.random(3500, 5000), math.random(3500, 5000), 0, 0, 0, 0)
	TimerEnabled = true
	Citizen.Wait(6000)
	TimerEnabled = false
end)

RegisterNetEvent("animation:tacklelol")
AddEventHandler("animation:tacklelol", function()
	if not exports["caue-base"]:getVar("handcuffed") and not IsPedRagdoll(PlayerPedId()) then
		RequestAnimDict("swimming@first_person@diving")
		while not HasAnimDictLoaded("swimming@first_person@diving") do
			Citizen.Wait(1)
		end

		if IsEntityPlayingAnim(PlayerPedId(), "swimming@first_person@diving", "dive_run_fwd_-45_loop", 3) then
			ClearPedSecondaryTask(PlayerPedId())
		else
			TaskPlayAnim(PlayerPedId(), "swimming@first_person@diving", "dive_run_fwd_-45_loop", 8.0, -8, -1, 49, 0, 0, 0, 0)
			local seccount = 3
			while seccount > 0 do
				Citizen.Wait(100)
				seccount = seccount - 1
			end
			ClearPedSecondaryTask(PlayerPedId())
			SetPedToRagdoll(PlayerPedId(), 150, 150, 0, 0, 0, 0)
		end
	end
end)

--[[

    Threads

]]

Citizen.CreateThread(function()
    exports["caue-keybinds"]:registerKeyMapping("", "Player", "Tackle", "+plyTackel", "-plyTackel")
    RegisterCommand("+plyTackel", plyTackel, false)
    RegisterCommand("-plyTackel", function() end, false)
end)

Citizen.CreateThread(function()
    while true do
        if TimerEnabled then
			DisableControlAction(1, 140, true) --Disables Melee Actions
			DisableControlAction(1, 141, true) --Disables Melee Actions
			DisableControlAction(1, 142, true) --Disables Melee Actions
			DisableControlAction(1, 37, true) --Disables INPUT_SELECT_WEAPON (tab) Actions
			DisablePlayerFiring(PlayerPedId(), true) -- Disable weapon firing
		end

        Citizen.Wait(1)
    end
end)