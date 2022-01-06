RegisterNetEvent("reviveGranted")
AddEventHandler("reviveGranted", function(_src)
    local src = source
    if _src then src = _src end

    TriggerClientEvent("reviveFunction", src)
end)