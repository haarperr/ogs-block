local activeChannels = {} --key is channel id, value is table with sub count and list of users in the channel
local channelSubscribers = {} --key is player server id, value is channel id

function removePlayerFromRadio(sId, channelId)
    if not activeChannels[channelId] then return end

    activeChannels[channelId].count = activeChannels[channelId].count - 1

    if activeChannels[channelId].count == 0 then
        activeChannels[channelId] = nil
    else
        activeChannels[channelId].subscribers[sId] = nil

        for k,v in pairs(activeChannels[channelId].subscribers) do
            TriggerClientEvent("caue:voice:radio:removed", k, channelId, sId)
        end
    end

    channelSubscribers[sId] = nil
end

function addPlayerToRadio(sId, channelId)
    if channelSubscribers[sId] then
        removePlayerFromRadio(sId, channelSubscribers[sId])
    end

    if activeChannels[channelId] == nil then
        activeChannels[channelId] = {}
        activeChannels[channelId].subscribers = {}
        activeChannels[channelId].count = 0
    end

    activeChannels[channelId].count = activeChannels[channelId].count + 1

    for k,v in pairs(activeChannels[channelId].subscribers) do
        TriggerClientEvent("caue:voice:radio:added", k, channelId, sId)
    end

    channelSubscribers[sId] = channelId
    activeChannels[channelId].subscribers[sId] = sId

    TriggerClientEvent("caue:voice:radio:connect", sId, channelId, activeChannels[channelId].subscribers)
end

RegisterNetEvent("AddPlayerToRadio")
AddEventHandler("AddPlayerToRadio", function(channelId, sId)
    addPlayerToRadio(sId, channelId)
end)

RegisterNetEvent("RemovePlayerFromRadio")
AddEventHandler("RemovePlayerFromRadio", function(sId)
    removePlayerFromRadio(sId, channelSubscribers[sId])
end)














AddEventHandler("playerDropped", function(source, reason)
    if channelSubscribers[source] then
        removePlayerFromRadio(source, channelSubscribers[source])
    end
end)

RegisterCommand("activeChannels", function(src, args, raw)
    print(DumpTable(activeChannels))
end, true)

RegisterCommand("channelSubscribers", function(src, args, raw)
    print(DumpTable(channelSubscribers))
end, true)