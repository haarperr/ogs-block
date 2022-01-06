local PlayersCoords = {}

RegisterServerEvent("caue:infinity:player:ready")
AddEventHandler("caue:infinity:player:ready", function()
    local src = source

    local coords = GetEntityCoords(GetPlayerPed(src))
    PlayersCoords[src] = coords

    TriggerClientEvent("caue:infinity:player:coords", -1, PlayersCoords)
end)

RegisterServerEvent("caue:infinity:entity:coords")
AddEventHandler("caue:infinity:entity:coords", function(netId)
    local src = source

    local coords = GetEntityCoords(GetPlayerPed(netId))
    PlayersCoords[netId] = coords

    TriggerClientEvent("caue:infinity:player:coords", src, coords)
end)

RegisterServerEvent("caue:infinity:player:remove")
AddEventHandler("caue:infinity:player:remove", function(netId)
    PlayersCoords[netId] = nil

    TriggerClientEvent("caue:infinity:player:coords", -1, PlayersCoords)
end)