--[[

    Variables

]]

local cuffstate = false
local tryingcuff = false
local cuffAttemptCount = 0
local lastCuffAttemptTime = 0
local handCuffed = false
local handCuffedWalking = false

--[[

    Functions

]]

function policeCuff()
	local job = exports["caue-base"]:getChar("job")

    if not inmenus and (exports["caue-jobs"]:getJob(job, "is_police") or job == "doc") then
		if IsPedInAnyVehicle(PlayerPedId(), false) then
			TriggerEvent("platecheck:frontradar")
		else
			if not IsControlPressed(0, 19) then
				TriggerEvent("caue-police:cuffPlayer")
			end
		end
	end
end

function policeUnCuff()
	local job = exports["caue-base"]:getChar("job")

    if not inmenus and (exports["caue-jobs"]:getJob(job, "is_police") or job == "doc") then
		if IsPedInAnyVehicle(PlayerPedId(), false) then
			TriggerEvent("platecheck:rearradar")
		else
			TriggerEvent("caue-police:uncuffPlayer")
		end
	end
end

function CuffAnimation(cuffer)
	loadAnimDict("mp_arrest_paired")

    local cuffer = GetPlayerPed(GetPlayerFromServerId(tonumber(cuffer)))
	local dir = GetEntityHeading(cuffer)

    SetEntityCoords(PlayerPedId(), GetOffsetFromEntityInWorldCoords(cuffer, 0.0, 0.45, 0.0))

    Citizen.Wait(100)

    SetEntityHeading(PlayerPedId(), dir)
	TaskPlayAnim(PlayerPedId(), "mp_arrest_paired", "crook_p2_back_right", 8.0, -8, -1, 32, 0, 0, 0, 0)
end

--[[

    Events

]]

RegisterNetEvent("caue-police:cuffPlayer")
AddEventHandler("caue-police:cuffPlayer", function()
	if not cuffstate and not exports["caue-base"]:getVar("handcuffed") and not IsPedRagdoll(PlayerPedId()) and not IsPlayerFreeAiming(PlayerId()) and not IsPedInAnyVehicle(PlayerPedId(), false) then
		cuffstate = true

		local t, distance = GetClosestPlayer()
		if distance ~= -1 and distance < 2 and not IsPedRagdoll(PlayerPedId()) then
			TriggerEvent("DoLongHudText", "Você algemou alguém!")
			TriggerEvent("caue-police:cuff", GetPlayerServerId(t))
		end

		cuffstate = false
	end
end)

RegisterNetEvent("caue-police:cuff")
AddEventHandler("caue-police:cuff", function(t, softcuff)
	if not tryingcuff then
		tryingcuff = true

        local t, distance, ped = GetClosestPlayer()

        Citizen.Wait(1500)

        if distance ~= -1 and #(GetEntityCoords(ped) - GetEntityCoords(PlayerPedId())) < 2.5 and GetEntitySpeed(ped) < 1.0 then
			TriggerServerEvent("caue-police:cuff", GetPlayerServerId(t))
		else
			ClearPedSecondaryTask(PlayerPedId())
			TriggerEvent("DoLongHudText", "Não há ninguem próximo (Chegue mais perto)!", 2)
		end

		tryingcuff = false
	end
end)

RegisterNetEvent("caue-police:getArrested")
AddEventHandler("caue-police:getArrested", function(cuffer)
	if lastCuffAttemptTime + 5000 > GetGameTimer() and (not handCuffed or not handCuffedWalking) then
		ClearPedTasksImmediately(PlayerPedId())
		return
	end

	ClearPedTasksImmediately(PlayerPedId())
	CuffAnimation(cuffer)

	local cuffPed = GetPlayerPed(GetPlayerFromServerId(tonumber(cuffer)))
	local finished = 0

	if lastCuffAttemptTime + 60000 < GetGameTimer() then
		cuffAttemptCount = 0
		lastCuffAttemptTime = 0
	end

    if not exports["caue-base"]:getVar("dead") and cuffAttemptCount < 2 then
		cuffAttemptCount = cuffAttemptCount + 1
		lastCuffAttemptTime = GetGameTimer()
        exports["caue-base"]:setVar("recentcuff", GetGameTimer())
		finished = exports["caue-taskbarskill"]:taskBarSkill(1000, 15)
	end

	if #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(cuffPed)) < 2.5 and finished ~= 100 then
        handCuffed = true
		handCuffedWalking = false

        exports["caue-base"]:setVar("handcuffed", handCuffed or handCuffedWalking)
        exports["caue-flags"]:SetPedFlag(PlayerPedId(), "isCuffed", handCuffed or handCuffedWalking)
        TriggerEvent("police:currentHandCuffedState", handCuffed or handCuffedWalking)

        TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 3.0, "handcuff", 0.4)
        TriggerEvent("DoLongHudText", "Algemado!")
	end
end)

RegisterNetEvent("caue-police:cuffTransition")
AddEventHandler("caue-police:cuffTransition", function()
	loadAnimDict("mp_arrest_paired")
	Citizen.Wait(100)
	TaskPlayAnim(PlayerPedId(), "mp_arrest_paired", "cop_p2_back_right", 8.0, -8, -1, 48, 0, 0, 0, 0)
	Citizen.Wait(3500)
	ClearPedTasksImmediately(PlayerPedId())
end)

RegisterNetEvent("caue-police:uncuffPlayer")
AddEventHandler("caue-police:uncuffPlayer", function()
	local t, distance = GetClosestPlayer()

    if distance ~= -1 and distance < 2 then
		TriggerEvent("animation:PlayAnimation", "uncuff")
		Wait(3000)
		TriggerServerEvent("caue-police:uncuff", GetPlayerServerId(t))
		TriggerEvent("DoLongHudText", "Você desalgemou alguém!")
	else
		TriggerEvent("DoLongHudText", "Não há ninguem próximo (Chegue mais perto)!", 2)
	end
end)

RegisterNetEvent("caue-police:uncuff")
AddEventHandler("caue-police:uncuff", function()
	ClearPedTasksImmediately(PlayerPedId())

	handCuffed = false
	handCuffedWalking = false

    exports["caue-base"]:setVar("handcuffed", handCuffed or handCuffedWalking)
    exports["caue-flags"]:SetPedFlag(PlayerPedId(), "isCuffed", handCuffed or handCuffedWalking)
    TriggerEvent("police:currentHandCuffedState", handCuffed or handCuffedWalking)

    exports["caue-police"]:setIsInBeatmode(false)
end)

RegisterNetEvent("caue-police:softcuffPlayer")
AddEventHandler("caue-police:softcuffPlayer", function()
	local t, distance = GetClosestPlayer()

    if distance ~= -1 and distance < 2 then
		TriggerEvent("animation:PlayAnimation", "uncuff")
		Wait(3000)
		TriggerServerEvent("caue-police:softcuff", GetPlayerServerId(t))
	else
		TriggerEvent("DoLongHudText", "Não há ninguem próximo (Chegue mais perto)!", 2)
	end
end)

RegisterNetEvent("caue-police:handCuffedWalking")
AddEventHandler("caue-police:handCuffedWalking", function()
	if handCuffedWalking then
		handCuffedWalking = false
		handCuffed = true
	else
		handCuffedWalking = true
		handCuffed = false
	end

	exports["caue-base"]:setVar("handcuffed", handCuffed or handCuffedWalking)
    exports["caue-flags"]:SetPedFlag(PlayerPedId(), "isCuffed", handCuffed or handCuffedWalking)
    TriggerEvent("police:currentHandCuffedState", handCuffed or handCuffedWalking)

	TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 3.0, "handcuff", 0.4)

	ClearPedTasksImmediately(PlayerPedId())
end)

RegisterNetEvent("caue-police:resetCuffs")
AddEventHandler("caue-police:resetCuffs", function()
	ClearPedTasksImmediately(PlayerPedId())

    handCuffed = false
	handCuffedWalking = false

    exports["caue-base"]:setVar("handcuffed", handCuffed or handCuffedWalking)
    exports["caue-flags"]:SetPedFlag(PlayerPedId(), "isCuffed", handCuffed or handCuffedWalking)
    TriggerEvent("police:currentHandCuffedState", handCuffed or handCuffedWalking)
end)

--[[

	RPCs

]]

RPC.register("isPlyCuffed", function()
	local isCuffed = exports["caue-base"]:getVar("handcuffed")
	return isCuffed
end)

--[[

    Threads

]]

Citizen.CreateThread(function()
    RegisterCommand("+policeCuff", policeCuff, false)
	RegisterCommand("-policeCuff", function() end, false)
	exports["caue-keybinds"]:registerKeyMapping("", "Police", "Cuff / Radar Front", "+policeCuff", "-policeCuff", "UP")

    RegisterCommand("+policeUnCuff", policeUnCuff, false)
	RegisterCommand("-policeUnCuff", function() end, false)
	exports["caue-keybinds"]:registerKeyMapping("", "Police", "UnCuff / Radar Rear", "+policeUnCuff", "-policeUnCuff", "DOWN")
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(0)

		if handCuffed or handCuffedWalking then
			if handCuffedWalking and IsPedClimbing(PlayerPedId()) then
				Wait(500)
				SetPedToRagdoll(PlayerPedId(), 3000, 1000, 0, 0, 0, 0)
			end

            if handCuffed and CanPedRagdoll(PlayerPedId()) then
				SetPedCanRagdoll(PlayerPedId(), false)
			end

			local number = handCuffed and 17 or 49

			-- disable actions
			-- Disable Actions
			-- DisableControlAction(0, 1, true) -- Disable pan
			DisableControlAction(0, 2, true) -- Disable tilt
			DisableControlAction(0, 24, true) -- Attack
			DisableControlAction(0, 257, true) -- Attack 2
			DisableControlAction(0, 25, true) -- Aim
			DisableControlAction(0, 263, true) -- Melee Attack 1
			-- DisableControlAction(0, 32, true) -- W
			-- DisableControlAction(0, 34, true) -- A
			-- DisableControlAction(0, 31, true) -- S
			-- DisableControlAction(0, 30, true) -- D

			DisableControlAction(0, 45, true) -- Reload
			DisableControlAction(0, 22, true) -- Jump
			DisableControlAction(0, 44, true) -- Cover
			DisableControlAction(0, 37, true) -- Select Weapon
			DisableControlAction(0, 23, true) -- Also 'enter'?

			DisableControlAction(0, 288,  true) -- Disable phone
			DisableControlAction(0, 289, true) -- Inventory
			DisableControlAction(0, 170, true) -- Animations
			DisableControlAction(0, 167, true) -- Job

			DisableControlAction(0, 0, true) -- Disable changing view
			DisableControlAction(0, 26, true) -- Disable looking behind
			DisableControlAction(0, 73, true) -- Disable clearing animation
			DisableControlAction(2, 199, true) -- Disable pause screen

			DisableControlAction(0, 59, true) -- Disable steering in vehicle
			DisableControlAction(0, 71, true) -- Disable driving forward in vehicle
			DisableControlAction(0, 72, true) -- Disable reversing in vehicle

			DisableControlAction(2, 36, true) -- Disable going stealth

			DisableControlAction(0, 47, true)  -- Disable weapon
			DisableControlAction(0, 264, true) -- Disable melee
			DisableControlAction(0, 257, true) -- Disable melee
			DisableControlAction(0, 140, true) -- Disable melee
			DisableControlAction(0, 141, true) -- Disable melee
			DisableControlAction(0, 142, true) -- Disable melee
			DisableControlAction(0, 143, true) -- Disable melee
			DisableControlAction(0, 75, true)  -- Disable exit vehicle
			DisableControlAction(27, 75, true) -- Disable exit vehicle

			DisablePlayerFiring(PlayerPedId(), true) -- Disable weapon firing

			local dead = exports["caue-base"]:getVar("dead")
			local intrunk = exports["caue-base"]:getVar("trunk")
			local isInBeatMode = exports["caue-police"]:getIsInBeatmode()

			if (not IsEntityPlayingAnim(PlayerPedId(), "mp_arresting", "idle", 3) and not dead and not intrunk and not isInBeatMode) or (IsPedRagdoll(PlayerPedId()) and not dead and not intrunk and not isInBeatMode) then
				RequestAnimDict("mp_arresting")
				while not HasAnimDictLoaded("mp_arresting") do
					Citizen.Wait(1)
				end
				TaskPlayAnim(PlayerPedId(), "mp_arresting", "idle", 8.0, 8.0, -1, number, 0.0, 0, 0, 0)
			end

			if dead or intrunk or isInBeatMode then
				Citizen.Wait(1000)
			end
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(4000)

		if not handCuffed and not CanPedRagdoll(PlayerPedId()) then
			SetPedCanRagdoll(PlayerPedId(), true)
		end
	end
end)