--[[

    Variables

]]

local isTriageEnabled = true
local currentPrompt = nil

local EVENTS = {
    LOCKERS = 1,
    CLOTHING = 2,
    SWITCHER = 3,
}

local zoneData = {
	pillbox_checkin = {
		promptText = "[E] Consultar ($200)"
	},
	pillbox_armory = {
		promptText = "[E] Arsenal"
	},
	pillbox_clothing_lockers_staff = {
		promptText = "[E] Lockers & Clothes",
		menuData = {
			{
				title = "Lockers",
				description = "Access your personal locker",
				action = "caue-healthcare:handler",
				params = EVENTS.LOCKERS
			},
			{
				title = "Clothing",
				description = "Gotta look Sharp",
				action = "caue-healthcare:handler",
				params = EVENTS.CLOTHING
			}
		}
	},
	pillbox_character_switcher_staff = {
		promptText = "[E] Switch Character",
		menuData = {
			{
				title = "Character switch",
				description = "Go bowling with your cousin",
				action = "caue-police:handler",
				params = EVENTS.SWITCHER
			}
		}
	},
	pillbox_character_switcher_backroom = {
		promptText = "[E] Switch Character",
		menuData = {
			{
				title = "Character switch",
				description = "Go bowling with your cousin",
				action = "caue-police:handler",
				key = EVENTS.SWITCHER
			}
		}
	},
	morgue_character_switcher_backroom = {
		promptText = "[E] Switch Character",
		menuData = {
			{
				title = "Character switch",
				description = "Go bowling with your cousin",
				action = "caue-police:handler",
				key = EVENTS.SWITCHER
			}
		}
	},
	parsons_character_switcher_backroom = {
		promptText = "[E] Switch Character",
		menuData = {
			{
				title = "Character switch",
				description = "Go bowling with your cousin",
				action = "caue-police:handler",
				key = EVENTS.SWITCHER
			}
		}
	}
}

--[[

    Functions

]]

local function listenForKeypress(pZone, pDoctors)
	listening = true

    Citizen.CreateThread(function()
		while listening do
			if IsControlJustReleased(0, 38) then
				if pZone == "pillbox_clothing_lockers_staff" then
					exports["caue-context"]:showContext(zoneData[pZone].menuData)
				elseif pZone == "pillbox_checkin" then
					loadAnimDict("anim@narcotics@trash")
					TaskPlayAnim(PlayerPedId(),"anim@narcotics@trash", "drop_front",1.0, 1.0, -1, 1, 0, 0, 0, 0)
					local finished = exports["caue-taskbar"]:taskBar(1700, (pDoctors > 0 and not isTriageEnabled) and "Paging a doctor" or "Checking Credentials")
					ClearPedSecondaryTask(PlayerPedId())
					if finished == 100 then
						if pDoctors > 0 and not isTriageEnabled then
							TriggerEvent("DoLongHudText","A doctor has been paged. Please take a seat and wait.",2)
							TriggerServerEvent("phone:triggerPager")
						else
							TriggerEvent("bed:checkin")
						end
					end
				elseif pZone == "pillbox_character_switcher_staff" or pZone == "pillbox_character_switcher_backroom" or pZone == "morgue_character_switcher_backroom" or pZone == "parsons_character_switcher_backroom" then
					exports["caue-context"]:showContext(zoneData[pZone].menuData)
				elseif pZone == "pillbox_armory" then
					local job = exports["caue-base"]:getChar("job")
					if exports["caue-jobs"]:getJob(false, "is_medic") then
						TriggerEvent("server-inventory-open", "15", "Shop")
					else
						TriggerEvent("server-inventory-open", "29", "Shop")
					end
				end
			end

			Citizen.Wait(1)
		end
	end)
end

local function getDoctorsOnline()
	local doctors = RPC.execute("caue-jobs:count", "doctor")
	return doctors
end

function GetPlayers()
    local players = {}

    for i = 0, 255 do
        if NetworkIsPlayerActive(i) then
            players[#players+1]= i
        end
    end

    return players
end

function emsRevive()
	if not exports["caue-jobs"]:getJob(false, "is_medic") then return end

	TriggerEvent("revive")
end

function emsHeal()
	if not exports["caue-jobs"]:getJob(false, "is_medic") then return end

	TriggerEvent("ems:heal")
end

function GetClosestPlayer()
	local players = GetPlayers()
	local closestDistance = -1
	local closestPlayer = -1
	local closestPed = -1
	local ply = PlayerPedId()
	local plyCoords = GetEntityCoords(ply, 0)

	if not IsPedInAnyVehicle(PlayerPedId(), false) then
		for index, value in ipairs(players) do
			local target = GetPlayerPed(value)
			if target ~= ply then
				local targetCoords = GetEntityCoords(GetPlayerPed(value), 0)
				local distance = #(vector3(targetCoords["x"], targetCoords["y"], targetCoords["z"]) - vector3(plyCoords["x"], plyCoords["y"], plyCoords["z"]))

				if (closestDistance == -1 or closestDistance > distance) and not IsPedInAnyVehicle(target, false) then
					closestPlayer = value
					closestPed = target
					closestDistance = distance
				end
			end
		end

		return closestPlayer, closestDistance, closestPed

	else
		TriggerEvent("DoLongHudText", "Inside Vehicle.", 2)
	end
end

function KneelMedic()
	loadAnimDict("amb@medic@standing@tendtodead@enter")
	loadAnimDict("amb@medic@standing@timeofdeath@enter")
	loadAnimDict("amb@medic@standing@tendtodead@idle_a")
	loadAnimDict("random@crash_rescue@help_victim_up")

	TaskPlayAnim(PlayerPedId(), "amb@medic@standing@tendtodead@enter", "enter", 8.0, 1.0, -1, 2, 0, 0, 0, 0)
	Citizen.Wait (1000)
	TaskPlayAnim(PlayerPedId(), "amb@medic@standing@tendtodead@idle_a", "idle_b", 8.0, 1.0, -1, 9, 0, 0, 0, 0)
	Citizen.Wait (3000)
	TaskPlayAnim(PlayerPedId(), "amb@medic@standing@tendtodead@exit", "exit_flee", 8.0, 1.0, -1, 2, 0, 0, 0, 0)
	Citizen.Wait (1000)
	TaskPlayAnim(PlayerPedId(), "amb@medic@standing@timeofdeath@enter", "enter", 8.0, 1.0, -1, 128, 0, 0, 0, 0)
	Citizen.Wait (500)
	TaskPlayAnim(PlayerPedId(), "amb@medic@standing@timeofdeath@enter", "helping_victim_to_feet_player", 8.0, 1.0, -1, 128, 0, 0, 0, 0)
end

--[[

    Events

]]

AddEventHandler("caue-polyzone:enter", function(zone)
	local currentZone = zoneData[zone]

    if currentZone then
		currentPrompt = zone
		local prompt = currentZone.promptText
		local doctors = 0

		if zone == "pillbox_checkin" then
			doctors = getDoctorsOnline()
			prompt = (doctors > 0 and not isTriageEnabled) and "[E] Page a doctor" or prompt
		end

		exports["caue-interaction"]:showInteraction(prompt)
		listenForKeypress(zone, doctors)
	end
end)

AddEventHandler("caue-polyzone:exit", function(zone)
	if zoneData[zone] then
		exports["caue-interaction"]:hideInteraction()
		listening = false
		currentPrompt = nil
	end
end)

AddEventHandler("caue-healthcare:handler", function(params)
	local eventData = params
    local location = string.match(currentPrompt, "(.-)_")

    if eventData == EVENTS.LOCKERS then
		local cid = exports["caue-base"]:getChar("id")
		TriggerEvent("server-inventory-open", "1", ("personalStorage-%s-%s"):format(location, cid))
		TriggerServerEvent("InteractSound_SV:PlayWithinDistance", 3.0, "LockerOpen", 0.4)
	elseif eventData == EVENTS.CLOTHING then
		TriggerEvent("raid_clothes:openClothing", true, true)
	elseif eventData == EVENTS.SWITCHER then
		TriggerEvent("apartments:Logout")
	end
end)

RegisterNetEvent("revive")
AddEventHandler("revive", function(t)
	local target, distance = GetClosestPlayer()

	if target and (distance ~= -1 and distance < 5) then
		KneelMedic()
		TriggerServerEvent("reviveGranted", GetPlayerServerId(target))
	else
		TriggerEvent("DoLongHudText", "No player near you (maybe get closer)!", 2)
	end
end)

RegisterNetEvent("ems:heal")
AddEventHandler("ems:heal", function()
	local target, distance = GetClosestPlayer()

	if target and (distance ~= -1 and distance < 5) then
		if not exports["caue-jobs"]:getJob(false, "is_medic") then
			local bandages = exports["caue-inventory"]:getQuantity("bandage")

			if bandages == 0 then
				return
			else
				TriggerEvent("inventory:removeItem", "bandage", 1)
			end
		end

		TriggerEvent("animation:PlayAnimation","layspike")
		TriggerServerEvent("ems:healplayer", GetPlayerServerId(target))
	end
end)

RegisterNetEvent("ems:stomachpump")
AddEventHandler("ems:stomachpump", function()
	local target, distance = GetClosestPlayer()

	if target and (distance ~= -1 and distance < 5) then
		local finished = exports["caue-taskbar"]:taskBar(10000, "Inserting stomach pump 🤢", false, true)
		TriggerEvent("animation:PlayAnimation", "cpr")
		if finished == 100 then
			TriggerServerEvent("fx:puke", GetPlayerServerId(target))
		end
		TriggerEvent("animation:cancel")
	end
end)

--[[

    Threads

]]

Citizen.CreateThread(function()
	-- Checkin, pillbox
	exports["caue-polyzone"]:AddCircleZone("pillbox_checkin", vector3(306.9, -595.03, 43.28), 0.4, {
		useZ=true,
	})

	-- Armory, pillbox
	exports["caue-polyzone"]:AddCircleZone("pillbox_armory", vector3(306.28, -601.58, 43.28), 0.4, {
		useZ=true,
	})

	-- Clothing / Personal Lockers, Staff room, pillbox
	exports["caue-polyzone"]:AddBoxZone("pillbox_clothing_lockers_staff", vector3(300.28, -598.83, 43.28), 3.2, 4.2, {
		heading=340,
		minZ=42.28,
		maxZ=45.68
	})

	-- Character Switcher, Staff room, pillbox
	exports["caue-polyzone"]:AddBoxZone("pillbox_character_switcher_staff", vector3(296.16, -598.31, 43.28), 2.4, 1.2, {
		heading=250,
		minZ=42.28,
		maxZ=45.68
	})

	-- Character Switcher, Backroom pillbox
	exports["caue-polyzone"]:AddBoxZone("pillbox_character_switcher_backroom", vector3(340.82, -596.46, 43.28), 2.4, 1.2, {
		heading=160,
		minZ=42.28,
		maxZ=45.68
	})

	-- Character Switcher, Morgue
	exports["caue-polyzone"]:AddBoxZone("morgue_character_switcher_backroom", vector3(296.61, -1352.36, 24.53), 1.8, 2.0, {
		heading=50,
		minZ=23.53,
		maxZ=26.53
	})

	-- Character Switcher, Parsons
	exports["caue-polyzone"]:AddBoxZone("parsons_character_switcher_backroom", vector3(-1501.62, 857.45, 181.59), 1.8, 2.0, {
		heading=25,
		minZ=180.59,
		maxZ=184.59
	})
end)

Citizen.CreateThread(function()
	RegisterCommand("+emsRevive", emsRevive, false)
	RegisterCommand("-emsRevive", function() end, false)
	exports["caue-keybinds"]:registerKeyMapping("", "EMS", "Revive", "+emsRevive", "-emsRevive")

	RegisterCommand("+emsHeal", emsHeal, false)
	RegisterCommand("-emsHeal", function() end, false)
	exports["caue-keybinds"]:registerKeyMapping("", "EMS", "Heal", "+emsHeal", "-emsHeal")

	RegisterCommand("+examineTarget", function()
		TriggerEvent("requestWounds")
	end, false)
	RegisterCommand("-examineTarget", function() end, false)
	exports["caue-keybinds"]:registerKeyMapping("", "EMS", "Examine Target", "+examineTarget", "-examineTarget")
end)