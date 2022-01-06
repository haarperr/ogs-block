RegisterNetEvent("caue-npcs:set:ped")
AddEventHandler("caue-npcs:set:ped", function(pNPCs)
    if type(pNPCs) == "table" then
        for _, ped in ipairs(pNPCs) do
            RegisterNPC(ped)
            EnableNPC(ped.id)
        end
    else
        RegisterNPC(ped)
        EnableNPC(ped.id)
    end
end)

RegisterNetEvent("caue-npcs:ped:giveStolenItems")
AddEventHandler("caue-npcs:ped:giveStolenItems", function(pArgs, pEntity, pEntityFlags, pEntityCoords)
    local npcCoords = GetEntityCoords(pEntity)
    local finished = exports["caue-taskbar"]:taskBar(15000, "Preparing to receive goods, don't move.")
    if finished == 100 then
        if #(GetEntityCoords(PlayerPedId()) - npcCoords) < 2.0 then
            TriggerEvent("server-inventory-open", "1", "Stolen-Goods-1")
        else
            TriggerEvent("DoLongHudText", "You moved too far you idiot.", 105)
        end
    end
end)

RegisterNetEvent("caue-npcs:ped:exchangeRecycleMaterial")
AddEventHandler("caue-npcs:ped:exchangeRecycleMaterial", function(pArgs, pEntity, pEntityFlags, pEntityCoords)
    local npcCoords = GetEntityCoords(pEntity)
    local finished = exports["caue-taskbar"]:taskBar(3000, "Preparing to exchange material, don't move.")
    if finished == 100 then
        if #(GetEntityCoords(PlayerPedId()) - npcCoords) < 2.0 then
            TriggerEvent("server-inventory-open", "35", "Craft")
        else
            TriggerEvent("DoLongHudText", "You moved too far you idiot.", 105)
        end
    end
end)

RegisterNetEvent("caue-npcs:ped:signInJob")
AddEventHandler("caue-npcs:ped:signInJob", function(pArgs, pEntity, pEntityFlags, pEntityCoords)
    if #pArgs == 0 then
        local npcId = DecorGetInt(pEntity, 'NPC_ID')
        if npcId == `news_reporter` then
            TriggerServerEvent("jobssystem:jobs", "news")
        elseif npcId == `head_stripper` then
            TriggerServerEvent("jobssystem:jobs", "entertainer")
        end
    else
        TriggerServerEvent("jobssystem:jobs", "unemployed")
    end
end)

RegisterNetEvent("caue-npcs:ped:paycheckCollect")
AddEventHandler("caue-npcs:ped:paycheckCollect", function(pArgs, pEntity, pEntityFlags, pEntityCoords)
    TriggerServerEvent("caue-jobs:paycheckPickup")
end)

RegisterNetEvent("caue-npcs:ped:sellStolenItems")
AddEventHandler("caue-npcs:ped:sellStolenItems", function()
    RPC.execute("caue-inventory:sellStolenItems")
end)

RegisterNetEvent("caue-npcs:ped:keeper")
AddEventHandler("caue-npcs:ped:keeper", function(pArgs, pEntity, pEntityFlags, pEntityCoords)
    TriggerEvent("server-inventory-open", pArgs[1], "Shop")
end)

TriggerServerEvent("caue-npcs:location:fetch")