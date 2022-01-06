--[[

    Functions

]]

function getCash(src)
    if not src then return 0 end

    local cid = exports["caue-base"]:getChar(src, "id")
    if not cid then return 0 end

    local cash = exports.ghmattimysql:scalarSync([[
        SELECT cash
        FROM characters
        WHERE id = ?
    ]],
    { cid })

    if not cash then return 0 end

    return cash
end

function updateCash(src, type, amount)
    if not src or not type or not amount then return false end

    local cid = exports["caue-base"]:getChar(src, "id")
    if not cid then return false end

    local result = exports.ghmattimysql:executeSync([[
        UPDATE characters
        SET cash = cash ]] .. type .. [[ ?
        WHERE id = ?
    ]],
    { amount, cid })

    if result["changedRows"] ~= 1 then return false end

    TriggerClientEvent("caue-financials:ui", src, "cash", type, amount, getCash(src))

    return true
end

--[[

    Exports

]]

exports("getCash", getCash)
exports("updateCash", updateCash)

--[[

    Events

]]

RegisterNetEvent("caue-financials:giveCash")
AddEventHandler("caue-financials:giveCash", function(pPlayer, pAmount)
    local src = source

    if pPlayer == -1 or pPlayer == 0 then return end

    updateCash(src, "-", pAmount)
    updateCash(pPlayer, "+", pAmount)
end)

--[[

    RPCs

]]

RPC.register("caue-financials:getCash", function(src)
    return getCash(src)
end)