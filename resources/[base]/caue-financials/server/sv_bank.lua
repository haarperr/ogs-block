--[[

    Variables

]]

local negativeTransactions = { "transfer", "purchase", "payslip", "financing", "ticket" }

--[[

    RPCs

]]

RPC.register("caue-financials:bankWithdraw", function(src, pAccountId, pAmount, pComment)
    if not src then
        return false, "ID do servidor incorreto"
    end

    pAccountId = tonumber(pAccountId)
    if not pAccountId or pAccountId < 1 then
        return false, "ID da conta incorreto: " .. pAccountId
    end

    pAmount = tonumber(pAmount)
    if not pAmount or pAmount < 1 then
        return false, "Valor incorreto: " .. pAmount
    end

    local accountExist = accountExist(pAccountId)
    if not accountExist then
        return false, "ID da conta " .. pAccountId .. " não existe?"
    end

    local cid = exports["caue-base"]:getChar(src, "id")
    if not cid then
        return false, "ID do sujeito não encontrada"
    end

    local cash = getCash(src)
    local bank = getBalance(pAccountId)

    if pAmount > bank then
        return false, "Essa conta não tem essa quantidade de dinheiro"
    end

    local uuid = uuid()

    local success = exports.ghmattimysql:transactionSync({
        {
            ["query"] = "UPDATE financials_accounts SET balance = balance - ? WHERE id = ?",
            ["values"] = { pAmount, pAccountId },
        },
        {
            ["query"] = "UPDATE characters SET cash = cash + ? WHERE id = ?",
            ["values"] = { pAmount, cid },
        },
        {
            ["query"] = "INSERT INTO financials_transactions (sender, receiver, amount, comment, user, type, uid) VALUES (?, ?, ?, ?, ?, ?, ?)",
            ["values"] = { pAccountId, pAccountId, pAmount, pComment, cid, 3, uuid },
        },
    })

    if not success then
        return false, "Falha ao sacar $" .. pAmount
    end

    exports["caue-logs"]:AddLog("withdraw", src, pAmount, cash, bank, pComment, uuid, pAccountId)

    TriggerClientEvent("caue-financials:ui", src, "cash", "+", pAmount, (cash + pAmount))

    return true, "Sucesso ao sacar $" .. pAmount
end)

RPC.register("caue-financials:bankDeposit", function(src, pAccountId, pAmount, pComment)
    if not src then
        return false, "ID do servidor incorreto"
    end

    pAccountId = tonumber(pAccountId)
    if not pAccountId or pAccountId < 1 then
        return false, "ID da conta incorreto: " .. pAccountId
    end

    pAmount = tonumber(pAmount)
    if not pAmount or pAmount < 1 then
        return false, "Valor incorreto: " .. pAmount
    end

    local accountExist = accountExist(pAccountId)
    if not accountExist then
        return false, "ID da conta " .. pAccountId .. " não existe?"
    end

    local cid = exports["caue-base"]:getChar(src, "id")
    if not cid then
        return false, "ID do sujeito não encontrado"
    end

    local cash = getCash(src)
    local bank = getBalance(pAccountId)

    if pAmount > cash then
        return false, "Você não tem essa quantidade"
    end

    local uuid = uuid()

    local success = exports.ghmattimysql:transactionSync({
        {
            ["query"] = "UPDATE characters SET cash = cash - ? WHERE id = ?",
            ["values"] = { pAmount, cid },
        },
        {
            ["query"] = "UPDATE financials_accounts SET balance = balance + ? WHERE id = ?",
            ["values"] = { pAmount, pAccountId },
        },
        {
            ["query"] = "INSERT INTO financials_transactions (sender, receiver, amount, comment, user, type, uid) VALUES (?, ?, ?, ?, ?, ?, ?)",
            ["values"] = { pAccountId, pAccountId, pAmount, pComment, cid, 2, uuid },
        },
    })

    if not success then
        return false, "Falha ao depositar $" .. pAmount
    end

    exports["caue-logs"]:AddLog("deposit", src, pAmount, cash, bank, pComment, uuid, pAccountId)

    TriggerClientEvent("caue-financials:ui", src, "cash", "-", pAmount, (cash - pAmount))

    return true, "Sucesso ao depositar $" .. pAmount
end)

RPC.register("caue-financials:bankTransfer", function(src, pSenderAccount, pReceiverAccount, pAmount, pComment)
    if not src then
        return false, "ID do servidor não fonte"
    end

    pSenderAccount = tonumber(pSenderAccount)
    if not pSenderAccount or pSenderAccount < 1 then
        return false, "ID da conta do remetende incorreto: " .. pSenderAccount
    end

    pReceiverAccount = tonumber(pReceiverAccount)
    if not pReceiverAccount or pReceiverAccount < 1 then
        return false, "ID da conta do receptor incorreto: " .. pReceiverAccount
    end

    pAmount = tonumber(pAmount)
    if not pAmount or pAmount < 1 then
        return false, "Quantidade incorreta: " .. pAmount
    end

    local accountSenderExist = accountExist(pSenderAccount)
    if not accountSenderExist then
        return false, "ID da conta do remetente " .. pSenderAccount .. " não existe"
    end

    local accountReceiverExist = accountExist(pReceiverAccount)
    if not accountReceiverExist then
        return false, "ID da conta do destinatário " .. pReceiverAccount .. " não existe"
    end

    local cid = exports["caue-base"]:getChar(src, "id")
    if not cid then
        return false, "ID do sujeito não encontrada"
    end

    local senderBank = getBalance(pSenderAccount)
    local receiverBank = getBalance(pReceiverAccount)

    if pAmount > senderBank then
        return false, "Essa conta não possui essa quantidade"
    end

    local uuid = uuid()

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
            ["values"] = { pSenderAccount, pReceiverAccount, pAmount, pComment, cid, 1, uuid },
        },
    })

    if not success then
        return false, "Falha ao transferir $" .. pAmount .. " para a conta de ID: " .. pReceiverAccount
    end

    exports["caue-logs"]:AddLog("transfer", src, pAmount, senderBank, receiverBank, pComment, uuid, pSenderAccount, pReceiverAccount)

    local userAccountId = exports["caue-base"]:getChar(src, "bankid")
    if pSenderAccount == userAccountId then
        TriggerClientEvent("caue-phone:notification", src, "fas fa-university", "Bank", "Você transferiu $" .. pAmount .. " para a conta de ID: " .. pReceiverAccount, 3000)
    end

    local receiverSid = exports["caue-base"]:getSidWithAccountId(pReceiverAccount)
    if receiverSid ~= 0 then
        TriggerClientEvent("caue-phone:notification", receiverSid, "fas fa-university", "Bank", "Vpcê recebeu uma transferência de $" .. pAmount .. " da conta de ID: " .. pSenderAccount, 3000)
    end

    return true, "Sucesso ao transferir $" .. pAmount .. " para a conta de ID:" .. pReceiverAccount
end)

RPC.register("caue-financials:bankTransactions", function(src, pAccountId)
    if not src then return {} end

    local transactions = exports.ghmattimysql:executeSync([[
        SELECT
	        t.type AS transcation_type,
            tr.amount AS transcation_amount,
            tr.comment AS transcation_comment,
            tr.uid AS transcation_uid,
            tr.date AS transcation_date,

            tr.sender AS transcation_sender,
            tr.receiver AS transcation_receiver,

            (CASE
	        	WHEN a1.type = 1 THEN "Personal Account"
	        	WHEN a1.type = 4 THEN g1.name
	        	ELSE n1.name
	        END) AS transcation_sender_name,
            (CASE
	        	WHEN a2.type = 1 THEN "Personal Account"
	        	WHEN a2.type = 4 THEN g2.name
	        	ELSE n2.name
	        END) AS transcation_receiver_name,

            (CASE
                WHEN a1.type = 4 AND (a1.id != ? OR tr.user = 0) THEN g1.name
                WHEN tr.user = 0 THEN n1.name
                WHEN tr.user IS NULL THEN ""
	        	ELSE CONCAT(c3.first_name," ",c3.last_name)
	        END) AS transcation_user_sender,
            (CASE
	        	WHEN a2.type = 1 AND a2.id != a1.id THEN CONCAT(c2.first_name," ",c2.last_name)
	        	ELSE ""
	        END) AS transcation_user_receiver

        FROM financials_transactions tr

        INNER JOIN financials_accounts a1 ON tr.sender = a1.id
        INNER JOIN financials_accounts a2 ON tr.receiver = a2.id

        INNER JOIN financials_transactions_types t ON tr.type = t.id

        LEFT JOIN financials_accounts_names n1 ON a1.id = n1.id
        LEFT JOIN characters c1 ON a1.owner = c1.id
        LEFT JOIN `ogs-block`.groups g1 ON a1.owner = g1.id

        LEFT JOIN financials_accounts_names n2 ON a2.id = n2.id
        LEFT JOIN characters c2 ON a2.owner = c2.id
        LEFT JOIN `ogs-block`.groups g2 ON a2.owner = g2.id

        LEFT JOIN characters c3 ON tr.user = c3.id

        WHERE (tr.sender = ?) OR (tr.receiver = ?)

        ORDER BY tr.id DESC
        LIMIT 50
    ]],
    { pAccountId, pAccountId, pAccountId })

    for i, v in ipairs(transactions) do
        if (v.transcation_type == "withdraw") or (has_value(negativeTransactions, v.transcation_type) and pAccountId ~= v.transcation_receiver) then
            v.transcation_amount = -v.transcation_amount
        end
    end

    return transactions
end)