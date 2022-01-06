--[[

    Variables

]]



--[[

    Functions

]]



--[[

    Events

]]

RegisterNetEvent("police:remmask")
AddEventHandler("police:remmask", function(t)
	local t, distance = GetClosestPlayer()

    if distance ~= -1 and distance < 5 then
		if not IsPedInVehicle(t, GetVehiclePedIsIn(t, false), false) then
			TriggerServerEvent("police:remmaskGranted", GetPlayerServerId(t))

            local AnimSet = "mp_missheist_ornatebank"
			local AnimationOn = "stand_cash_in_bag_intro"
			local AnimationOff = "stand_cash_in_bag_intro"

            loadAnimDict(AnimSet)
			TaskPlayAnim(PlayerPedId(), AnimSet, AnimationOn, 8.0, -8, -1, 49, 0, 0, 0, 0)

            Citizen.Wait(500)

            ClearPedTasks(PlayerPedId())
		end
	else
		TriggerEvent("DoLongHudText", "No player near you (maybe get closer)!",2)
	end
end)

RegisterNetEvent("police:remmaskAccepted")
AddEventHandler("police:remmaskAccepted", function()
	TriggerEvent("facewear:adjust", {
		{
			id = 1,
			shouldRemove = true
		},
		{
			id = 2,
			shouldRemove = true
		},
		{
			id = 3,
			shouldRemove = true
		},
		{
			id = 4,
			shouldRemove = true
		}
	}, 0, true)
end)

RegisterNetEvent("police:checkInventory")
AddEventHandler("police:checkInventory", function(pArgs, pEntity)
	TriggerEvent("animation:PlayAnimation", "push")
    local finished = exports["caue-taskbar"]:taskBar(15000, pArgs and "Frisking" or "Searching", false, true, nil, false, nil, 5)
	TriggerEvent("animation:PlayAnimation", "c")

    if finished == 100 then
        TriggerServerEvent("police:targetCheckInventory", GetPlayerServerId(NetworkGetPlayerIndexFromPed(pEntity)), pArgs)
    end
end)

RegisterNetEvent("police:rob")
AddEventHandler("police:rob", function(pArgs, pEntity)
    RequestAnimDict("random@shop_robbery")
    while not HasAnimDictLoaded("random@shop_robbery") do
        Citizen.Wait(0)
    end

    ClearPedTasksImmediately(PlayerPedId())

    TaskPlayAnim(PlayerPedId(), "random@shop_robbery", "robbery_action_b", 8.0, -8, -1, 16, 0, 0, 0, 0)
    local finished = exports["caue-taskbar"]:taskBar(15000, "Robbing", false, true, nil, false, nil, 5)

    if finished == 100 then
        ClearPedTasksImmediately(PlayerPedId())
        TriggerServerEvent("police:rob", GetPlayerServerId(NetworkGetPlayerIndexFromPed(pEntity)))
        TriggerServerEvent("police:targetCheckInventory", GetPlayerServerId(NetworkGetPlayerIndexFromPed(pEntity)), false)
    end
end)

RegisterNetEvent("shoes:steal")
AddEventHandler("shoes:steal", function(pArgs, pEntity)
  	loadAnimDict("random@domestic")
  	TaskTurnPedToFaceEntity(PlayerPedId(), pEntity, -1)
  	TaskPlayAnim(PlayerPedId(),"random@domestic", "pickup_low",5.0, 1.0, 1.0, 48, 0.0, 0, 0, 0)
  	Citizen.Wait(1600)
  	ClearPedTasks(PlayerPedId())
  	TriggerServerEvent("facewear:adjust", GetPlayerServerId(NetworkGetPlayerIndexFromPed(pEntity)), 6, true)
  	-- TriggerEvent("player:receiveItem", "-828058162", 2)
end)

RegisterNetEvent("police:gsr")
AddEventHandler("police:gsr", function(pArgs, pEntity)
	TaskStartScenarioInPlace(PlayerPedId(), "WORLD_HUMAN_STAND_MOBILE", 0, 1)
	local finished = exports["caue-taskbar"]:taskBar(15000, "GSR Testing")
	if finished == 100 then
		TriggerServerEvent("police:gsr", GetPlayerServerId(NetworkGetPlayerIndexFromPed(pEntity)))
	end
end)

--[[

    RPCs

]]

