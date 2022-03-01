--[[

    Variables

]]

local PlayersCoords = {}

--[[

    Functions

]]

function GetNerbyPlayers(pCoords, pRange)
    local players = {}

    for k, v in pairs(PlayersCoords) do
        if #(v - pCoords) <= pRange then
            table.insert(players, k)
        end
    end

    return players
end

--[[

    Exports

]]

exports("GetNerbyPlayers", GetNerbyPlayers)

--[[

    Events

]]

RegisterServerEvent("caue:infinity:player:ready")
AddEventHandler("caue:infinity:player:ready", function()
    local src = source

    local ped = GetPlayerPed(src)
    local coords = GetEntityCoords(ped)

    PlayersCoords[src] = coords
end)

RegisterServerEvent("caue:infinity:entity:coords")
AddEventHandler("caue:infinity:entity:coords", function(pNetId)
    local src = source

    local entity = NetworkGetEntityFromNetworkId(pNetId)
    local coords = GetEntityCoords(Gentity)

    TriggerClientEvent("caue:infinity:entity:coords", src, coords)
end)

RegisterServerEvent("caue:infinity:player:remove")
AddEventHandler("caue:infinity:player:remove", function(src)
    PlayersCoords[src] = nil
end)

--[[

    Threads

]]

Citizen.CreateThread(function()
    local updated = false

    while true do
        Citizen.Wait(500)

        updated = false

        for k, v in pairs(PlayersCoords) do
            local ped = GetPlayerPed(k)
            local coords = GetEntityCoords(ped)

            PlayersCoords[k] = coords

            if not updated then
                updated = true
            end
        end

        if updated then
            TriggerClientEvent("caue:infinity:player:coords", -1, PlayersCoords)
        end
    end
end)