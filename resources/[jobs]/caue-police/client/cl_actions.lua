--[[

	Functions

]]

function IsNearPlayer(player)
    local ply = PlayerPedId()
    local plyCoords = GetEntityCoords(ply, 0)
    local ply2 = GetPlayerPed(GetPlayerFromServerId(player))
    local ply2Coords = GetEntityCoords(ply2, 0)
    local distance = Vdist2(plyCoords, ply2Coords)
    if(distance <= 5) then
        return true
    end
end

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
		TriggerEvent("DoLongHudText", "Não tem ninguem próximo (Tente chegar mais perto).",2)
	end
end)

RegisterNetEvent("police:remmaskAccepted")
AddEventHandler("police:remmaskAccepted", function()
	TriggerEvent("facewear:adjust", {
		{
			id = "hat",
			shouldRemove = true
		},
		{
			id = "googles",
			shouldRemove = true
		},
		{
			id = "mask",
			shouldRemove = true
		},
	}, true, true)
end)

RegisterNetEvent("police:checkInventory")
AddEventHandler("police:checkInventory", function(pArgs, pEntity)
	TriggerEvent("animation:PlayAnimation", "push")
    local finished = exports["caue-taskbar"]:taskBar(15000, pArgs and "Revista Leve" or "Revistar", false, true, nil, false, nil, 5)
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
    local finished = exports["caue-taskbar"]:taskBar(60000, "Roubando", true, true, nil, false, nil, 5)

    ClearPedTasksImmediately(PlayerPedId())

	if finished == 100 then
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
  	TriggerServerEvent("facewear:adjust", GetPlayerServerId(NetworkGetPlayerIndexFromPed(pEntity)), "stolenshoes", true, true)
end)

RegisterNetEvent("police:gsr")
AddEventHandler("police:gsr", function(pArgs, pEntity)

	local finished = exports["caue-taskbar"]:taskBar(10000, "Teste de GSR")
	if finished == 100 then
		TriggerServerEvent("police:gsr", GetPlayerServerId(NetworkGetPlayerIndexFromPed(pEntity)))
	end
end)

RegisterNetEvent("police:fingerprint")
AddEventHandler("police:fingerprint", function(pArgs, pEntity)

	local finished = exports["caue-taskbar"]:taskBar(10000, "Examinando Digitais")
	if finished == 100 then
		TriggerServerEvent("police:fingerprint", GetPlayerServerId(NetworkGetPlayerIndexFromPed(pEntity)))
	end
end)

RegisterNetEvent("police:checkBank")
AddEventHandler("police:checkBank", function(pArgs, pEntity)
	local finished = exports["caue-taskbar"]:taskBar(10000, "Checando o Banco do Individuo")
	if finished == 100 then
		TriggerServerEvent("police:checkBank", GetPlayerServerId(NetworkGetPlayerIndexFromPed(pEntity)))
	end
end)

AddEventHandler("caue-police:giveTicket", function(pParams, pEntity, pContext)
	local input = exports["caue-input"]:showInput({
		{
            icon = "hand-holding-usd",
            label = "Valor",
            name = "amount",
        },
		{
            icon = "comment",
            label = "Comentário",
            name = "comment",
        },
	})

	if input["amount"] and input["comment"] then
		local amount = tonumber(input["amount"])
		if not amount or amount < 1 then
			TriggerEvent("DoLongHudText", "Valor inválido", 2)
			return
		end

        if not IsNearPlayer(pEntity) then
            TriggerEvent("DoLongHudText", "Você não está próximo do player!", 2)
            return
        end

        TriggerEvent("animation:PlayAnimation","id")
		TriggerServerEvent("caue-jail:giveTicket", GetPlayerServerId(NetworkGetPlayerIndexFromPed(pEntity)), amount, input["comment"])
	end
end)

AddEventHandler("caue-police:impound", function(pParams, pVehicle)
	TriggerEvent("animation:PlayAnimation", "phone")
    local finished = exports["caue-taskbar"]:taskBar(math.random(5000, 10000), "Chamando o reboque")
    TriggerEvent("animation:PlayAnimation", "cancel")

	local vid = exports["caue-vehicles"]:GetVehicleIdentifier(pVehicle)
    if vid then
		RPC.execute("caue-vehicles:updateVehicle", vid, "garage", "state", "In")
	end

	Sync.DeleteVehicle(pVehicle)
	Sync.DeleteEntity(pVehicle)

	exports["caue-phone"]:phoneNotification("fas fa-truck-pickup", "Reboque", "O veiculo foi rebocado!", 10000)
end)

--[[

    Threads

]]

Citizen.CreateThread(function()
    exports["caue-eye"]:AddPeekEntryByEntityType({ 1 }, {
        {
            id = "ticket",
            label = "Multar",
            icon = "clipboard-list",
            event = "caue-police:giveTicket",
            parameters = {},
        }
    }, {
        distance = { radius = 1.5 },
        isEnabled = function(pEntity, pContext)
            return pContext.flags["isPlayer"] and pContext.distance <= 1.2 and exports["caue-jobs"]:getJob(CurrentJob, "is_police")
        end
    })
end)