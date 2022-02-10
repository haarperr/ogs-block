--[[

    Events

]]

AddEventHandler("pawnshoptime", function(time)
    if time then
        TriggerServerEvent("caue-pawnshop:requestLocation")
    else
        TriggerEvent("caue-npcs:set:position", "pawnshop", vector3(0, 0, -100), 0)
    end
end)

AddEventHandler("caue-pawnshop:buy", function()
    TriggerEvent("server-inventory-open", "777", "Shop")
end)

AddEventHandler("caue-pawnshop:sell", function(pArgs, pEntity, pEntityFlags, pEntityCoords)
    local npcCoords = GetEntityCoords(pEntity)
    local finished = exports["caue-taskbar"]:taskBar(3000, "Vendendo, não se mova.")
    if finished == 100 then
        if #(GetEntityCoords(PlayerPedId()) - npcCoords) < 2.0 then
            TriggerServerEvent("caue-pawnshop:sell")
        else
            TriggerEvent("DoLongHudText", "Você se moveu para longe idiota.", 2)
        end
    end
end)