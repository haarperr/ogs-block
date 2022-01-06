local PlayerCoords = {}

RegisterNetEvent("caue:infinity:player:coords")
AddEventHandler("caue:infinity:player:coords", function(coords)
    if type(coords) == "table" then
        PlayerCoords = coords
    end
end)

function GetPlayerCoords(serverID)
    local playerID = GetPlayerFromServerId(serverID)

    if playerID ~= -1 then
        return GetEntityCoords(GetPlayerPed(playerID))
    else
        return PlayerCoords[serverID] or vector3(0.0, 0.0, 0.0)
    end
end