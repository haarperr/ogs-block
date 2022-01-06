--[[

    Events

]]

RegisterNetEvent("caue-jobs:changeJob")
AddEventHandler("caue-jobs:changeJob", function(job, _src)
    if not job or not JOBS[job] then return end

    local src = source
    if _src then src = _src end

    local cid = exports["caue-base"]:getChar(src, "id")
    if not cid then return end

    local currentjob = exports["caue-base"]:getChar(src, "job")
    if currentjob == job then return end

    exports.ghmattimysql:executeSync([[
        UPDATE characters
        SET job = ?
        WHERE id = ?
    ]],
    { job, cid })

    exports["caue-base"]:setChar(src, "job", job)
    TriggerClientEvent("caue-base:setChar", src, "job", job)

    TriggerClientEvent("caue-jobs:jobChanged", src, job)
    TriggerEvent("caue-chat:buildCommands", src)

    TriggerClientEvent("DoLongHudText", src, job ~= "unemployed" and "New Job: " .. jobName(job) or "You're now unemployed")
end)

RegisterNetEvent("caue-jobs:paycheck")
AddEventHandler("caue-jobs:paycheck", function(log, amount, _src)
    local src = source

    local src = source
    if _src then src = _src end

    local cid = exports["caue-base"]:getChar(src, "id")
    if not cid then return end

    local tax = exports["caue-financials"]:priceWithTax(amount, "Income")

    exports["caue-financials"]:updateBalance(2, "+", amount - tax["tax"])
    exports["caue-financials"]:addTax("Income", tax["tax"])

    exports.ghmattimysql:executeSync([[
        UPDATE characters
        SET paycheck = paycheck + ?
        WHERE id = ?
    ]],
    { amount - tax["tax"], cid })

    TriggerClientEvent("DoLongHudText", src, "A payslip of $" .. amount .. " with $" .. tax["tax"] .. " tax withheld on your last payment.")
end)

RegisterNetEvent("caue-jobs:paycheckPickup")
AddEventHandler("caue-jobs:paycheckPickup", function()
    local src = source

    local src = source
    if _src then src = _src end

    local cid = exports["caue-base"]:getChar(src, "id")
    if not cid then return end

    local paycheck = exports.ghmattimysql:scalarSync([[
        SELECT paycheck
        FROM characters
        WHERE id = ?
    ]],
    { cid })

    if paycheck and paycheck > 0 then
        local accountId = exports["caue-base"]:getChar(src, "bankid")
        local success, message = exports["caue-financials"]:transaction(2, accountId, paycheck, "Payslip", 0, 4)
        if not success then
            TriggerClientEvent("DoLongHudText", src, message)
            return
        end

        exports.ghmattimysql:executeSync([[
            UPDATE characters
            SET paycheck = 0
            WHERE id = ?
        ]],
        { cid })

        TriggerClientEvent("DoLongHudText", src, "Your payslip of $" .. paycheck .. " has been transferred to your bank account")
    else
        TriggerClientEvent("DoLongHudText", src, 'The cashier stares at you awkardly and says, "You have no payslip?"', 2)
    end
end)

RegisterNetEvent("SpawnEventsServer")
AddEventHandler("SpawnEventsServer", function()
    local src = source

    local job = exports["caue-base"]:getChar(src, "job")
    if not job then return end

    TriggerClientEvent("caue-jobs:jobChanged", src, job)
    TriggerEvent("caue-chat:buildCommands", src)
end)

--[[

    RPCs

]]

RPC.register("caue-jobs:getJobs", function(src)
    return JOBS
end)

RPC.register("caue-jobs:count", function(src, job)
    return exports["caue-base"]:JobCount(job)
end)

--[[

    Threads

]]

Citizen.CreateThread(function()
    local _jobs = exports.ghmattimysql:executeSync([[
        SELECT *
        FROM jobs
    ]])

    for i, v in ipairs(_jobs) do
        JOBS[v.job] = v
    end
end)