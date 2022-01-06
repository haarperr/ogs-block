RegisterNetEvent("caue-vehicles:eject")
AddEventHandler("caue-vehicles:eject", function(target, velocity)
    local src = source

    TriggerClientEvent("caue-vehicles:eject", player, value)
end)