--[[

    Functions

]]

function getBalance(pAccountId)
    if not pAccountId or pAccountId == 0 then
        return 0
    end

    local balance = exports.ghmattimysql:scalarSync([[
        SELECT balance
        FROM financials_accounts
        WHERE id = ?
    ]],
    { pAccountId })

    if not balance then
        return 0
    end

    return balance
end

function updateBalance(pAccountId, pType, pAmount)
    if not pAccountId or not pType or not pAmount then
        return false
    end

    local result = exports.ghmattimysql:executeSync([[
        UPDATE financials_accounts
        SET balance = balance ]] .. pType .. [[ ?
        WHERE id = ?
    ]],
    { pAmount, pAccountId })

    if result["changedRows"] ~= 1 then return false end

    return true
end

function transaction(pSenderAccount, pReceiverAccount, pAmount, pComment, pUser, pTransactionType)
    if not pSenderAccount or not pReceiverAccount or not pAmount or not pComment or not pUser or not pTransactionType then
        return false, "Faltam informações"
    end

    local success = exports.ghmattimysql:transactionSync({
        {
            ["query"] = "UPDATE financials_accounts SET balance = balance - ? WHERE id = ?",
            ["values"] = { pAmount, pSenderAccount },
        },
        {
            ["query"] = "UPDATE financials_accounts SET balance = balance + ? WHERE id = ?",
            ["values"] = { pAmount, pReceiverAccount },
        },
        {
            ["query"] = "INSERT INTO financials_transactions (sender, receiver, amount, comment, user, type, uid) VALUES (?, ?, ?, ?, ?, ?, ?)",
            ["values"] = { pSenderAccount, pReceiverAccount, pAmount, pComment, pUser, pTransactionType, uuid() },
        },
    })

    if not success then
        return false, "Falha ao transferir $" .. pAmount
    end

    return true, "Sucesso ao transferir $" .. pAmount
end

function transactionLog(pSenderAccount, pReceiverAccount, pAmount, pComment, pUser, pTransactionType)
    local uid = uuid()

    exports.ghmattimysql:executeSync([[
        INSERT INTO financials_transactions (sender, receiver, amount, comment, user, type, uid)
        VALUES (?, ?, ?, ?, ?, ?, ?)
    ]],
    { pSenderAccount, pReceiverAccount, pAmount, pComment, pUser, pTransactionType, uid })

    return uid
end

--[[

    Exports

]]

exports("getBalance", getBalance)
exports("updateBalance", updateBalance)
exports("transaction", transaction)
exports("transactionLog", transactionLog)

--[[

    RPCs

]]

RPC.register("caue-financials:getBalance", function(src, pAccountId)
    return getBalance(pAccountId)
end)