RegisterNetEvent("caue:peds:rogue")
AddEventHandler("caue:peds:rogue", function(toDelete)
    if toDelete == nil then return end

    TriggerClientEvent("caue:peds:rogue:delete", -1, toDelete)
end)