RPC.register("caue-death:illegal", function(src, pPrice)
    local cid = exports["caue-base"]:getChar(src, "id")
    if not cid then
        return false
    end

    local accountId = exports["caue-base"]:getChar(src, "bankid")
    local bank = exports["caue-financials"]:getBalance(accountId)

    if bank < pPrice then
        TriggerClientEvent("DoLongHudText", src, "Você não tem $" .. pPrice .. " na sua conta do banco")
        return false
    end

    local success, message = exports["caue-financials"]:transaction(accountId, 0, pPrice, "", cid, 1)
    if not success then
        TriggerClientEvent("DoLongHudText", src, message)
        return false
    end

    return true
end)