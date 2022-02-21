--[[

    Events

]]

RegisterNetEvent("caue-chat:local")
AddEventHandler("caue-chat:local", function(id, name, message, coords)
	local monid = PlayerId()
	local sonid = GetPlayerFromServerId(id)

    if sonid == monid then
		TriggerEvent("chatMessage", "", {205, 205, 205}, "(( [" .. id .. "] " .. name .. ": " .. message .. " ))")
	elseif #(GetEntityCoords(PlayerPedId()) - coords) < 20 then
		TriggerEvent("chatMessage", "", {205, 205, 205}, "(( [" .. id .. "] " .. name .. ": " .. message .. " ))")
	end
end)

RegisterNetEvent("caue-chat:me")
AddEventHandler("caue-chat:me", function(id, name, message, coords)
	local monid = PlayerId()
	local sonid = GetPlayerFromServerId(id)

	local hasFinalPoint = string.sub(message, string.len(message)) == "."
	if not hasFinalPoint then
		message = message .. "."
	end

	if sonid == monid then
		TriggerEvent("chatMessage", "", {170, 102, 204}, "*" .. name .." " .. message)
	elseif #(GetEntityCoords(PlayerPedId()) - coords) < 20 then
		TriggerEvent("chatMessage", "", {170, 102, 204}, "*" .. name .." " .. message)
	end
end)

RegisterNetEvent("caue-chat:do")
AddEventHandler("caue-chat:do", function(id, name, message, coords)
	local monid = PlayerId()
	local sonid = GetPlayerFromServerId(id)

	local message = (message:gsub("^%l", string.upper))

    if sonid == monid then
		TriggerEvent("chatMessage", "", {170, 102, 204}, "*" .. message .. " (( " .. name .. " ))")
	elseif #(GetEntityCoords(PlayerPedId()) - coords) < 20 then
		TriggerEvent("chatMessage", "", {170, 102, 204}, "*" .. message .. " (( " .. name .. " ))")
	end
end)