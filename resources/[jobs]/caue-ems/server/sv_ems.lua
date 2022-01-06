RegisterNetEvent("ems:healplayer")
AddEventHandler("ems:healplayer", function(target)
    local src = source

    TriggerClientEvent("DoLongHudText", src, "Healing Player")
	TriggerClientEvent("DoLongHudText", target, "You are starting to feel better!")

    TriggerClientEvent("ems:healpassed", target)
end)