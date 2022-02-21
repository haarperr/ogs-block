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
            TriggerClientEvent("DoLongHudText", src, "Arma encontrada")
        else
            TriggerClientEvent("DoLongHudText", src, "Arma não encontrada")
        end
    else
        TriggerClientEvent("DoLongHudText", pTarget, "Você esta sendo revistado")
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
        TriggerClientEvent("DoLongHudText", src, "Encontramos residuo de polvora")
    else
        TriggerClientEvent("DoLongHudText", src, "Não encontramos nenhum residuo de polvora")
    end
end)

RegisterNetEvent("police:checkBank")
AddEventHandler("police:checkBank", function(pTarget)
	local src = source
    local cid = exports["caue-base"]:getChar(pTarget, "id")
    local accountId = exports["caue-base"]:getChar(pTarget, "bankid")
    local bank = exports["caue-financials"]:getBalance(accountId)
    TriggerClientEvent("DoLongHudText", src, "Tem $ " .. bank .. " na conta " .. accountId)
end)

RegisterNetEvent("caue-jail:giveTicket", function(pTarget, pAmount, pComment)
    local src = source

    local cid = exports["caue-base"]:getChar(pTarget, "id")
    if not cid then
        TriggerClientEvent("DoLongHudText", src, "cid not found?", 2)
        return
    end

    local accountId = exports["caue-base"]:getChar(pTarget, "bankid")

    local success, message = exports["caue-financials"]:transaction(accountId, 1, pAmount, pComment, cid, 8)
    if not success then
        return false, TriggerClientEvent("DoLongHudText", src, message, 2)
    end

    TriggerClientEvent("DoLongHudText", src, "Multa enviada com sucesso!")
    TriggerClientEvent("caue-phone:notification", pTarget, "fas fa-university", "Bank", "Você recebeu uma multa de $" .. pAmount, 5000)
end)