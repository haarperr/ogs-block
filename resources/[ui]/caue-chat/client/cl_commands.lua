--[[

    Events

]]

RegisterNetEvent("caue-chat:local")
AddEventHandler("caue-chat:local", function(id, name, message)
	local monid = PlayerId()
	local sonid = GetPlayerFromServerId(id)

    if sonid == monid then
		TriggerEvent("chatMessage", "", {205, 205, 205}, "(( [" .. id .. "] " .. name .. ": " .. message .. " ))")
	elseif GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(monid)), GetEntityCoords(GetPlayerPed(sonid)), true) < 19.999 then
		TriggerEvent("chatMessage", "", {205, 205, 205}, "(( [" .. id .. "] " .. name .. ": " .. message .. " ))")
	end
end)

RegisterNetEvent("caue-chat:me")
AddEventHandler("caue-chat:me", function(id, name, message)
	local monid = PlayerId()
	local sonid = GetPlayerFromServerId(id)

	if sonid == monid then
		TriggerEvent("chatMessage", "", {170, 102, 204}, "*" .. name .." " .. message)
	elseif GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(monid)), GetEntityCoords(GetPlayerPed(sonid)), true) < 19.999 then
		TriggerEvent("chatMessage", "", {170, 102, 204}, "*" .. name .." " .. message)
	end
end)

RegisterNetEvent("caue-chat:do")
AddEventHandler("caue-chat:do", function(id, name, message)
	local monid = PlayerId()
	local sonid = GetPlayerFromServerId(id)

    if sonid == monid then
		TriggerEvent("chatMessage", "", {170, 102, 204}, "*" .. message .. " (( " .. name .. " ))")
	elseif GetDistanceBetweenCoords(GetEntityCoords(GetPlayerPed(monid)), GetEntityCoords(GetPlayerPed(sonid)), true) < 19.999 then
		TriggerEvent("chatMessage", "", {170, 102, 204}, "*" .. message .. " (( " .. name .. " ))")
	end
end)