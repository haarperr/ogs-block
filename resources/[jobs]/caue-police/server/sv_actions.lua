RegisterNetEvent("police:remmaskGranted")
AddEventHandler("police:remmaskGranted", function(pTarget)
    TriggerClientEvent("police:remmaskAccepted", pTarget)
end)

RegisterNetEvent("police:targetCheckInventory")
AddEventHandler("police:targetCheckInventory", function(pTarget, pFrisk)
    local src = source

    local cid = exports["caue-base"]:getChar(pTarget, "id")
    if not cid then return end

    if pFrisk then
        local inv = exports["caue-inventory"]:getInventory("ply-" .. cid)

        local hasWeapons = false

        for i, v in ipairs(inv) do
            if tonumber(v.item_id) then
                hasWeapons = true
                break
            end
        end

        if hasWeapons then
            TriggerClientEvent("DoLongHudText", src, "Esse fudido ta armado")
        else
            TriggerClientEvent("DoLongHudText", src, "Esse fudido nao ta armado")
        end
    else
        TriggerClientEvent("DoLongHudText", pTarget, "You are being searched")
        TriggerClientEvent("server-inventory-open", src, "1", ("ply-" .. cid))
    end
end)

RegisterNetEvent("police:rob")
AddEventHandler("police:rob", function(pTarget)
    local src = source

    local cash = exports["caue-financials"]:getCash(pTarget)

    if cash > 0 then
        if exports["caue-financials"]:updateCash(pTarget, "-", cash) then
            exports["caue-financials"]:updateCash(src, "+", cash)
        end
    end
end)

RegisterNetEvent("police:gsr")
AddEventHandler("police:gsr", function(pTarget)
	local src = source

    local shotRecently = RPC.execute(pTarget, "police:gsr")

    if shotRecently then
        TriggerClientEvent("DoLongHudText", src, "GSR Positive")
    else
        TriggerClientEvent("DoLongHudText", src, "GSR Negative")
    end
end)