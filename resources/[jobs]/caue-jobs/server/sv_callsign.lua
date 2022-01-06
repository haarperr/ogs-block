--[[

    Functions

]]

function getCallsign(pSrc, pJob)
    local cid = exports["caue-base"]:getChar(pSrc, "id")
    if not cid then return end

    local callSign = exports.ghmattimysql:scalarSync([[
        SELECT callsign
        FROM jobs_callsigns
        WHERE cid = ? AND job = ?
    ]],
    { cid, pJob })

    return callSign
end

--[[

    Exports

]]

exports("getCallsign", getCallsign)

--[[

    RPC

]]

RPC.register("caue-jobs:getCallsign", function(src, job)
    return getCallsign(src, job)
end)

RPC.register("caue-jobs:setCallsign", function(src, cid, job, callsign)
    local exist = exports.ghmattimysql:scalarSync([[
        SELECT id
        FROM jobs_callsigns
        WHERE cid = ? AND job = ?
    ]],
    { cid, job })

    if exist then
        local result = exports.ghmattimysql:executeSync([[
            UPDATE jobs_callsigns
            SET callsign = ?
            WHERE id = ?
        ]],
        { callsign, exist })

        if result["affectedRows"] ~= 1 then
            return false, "Database update eror"
        end

        return true, "Callsign updated"
    else
        local result = exports.ghmattimysql:executeSync([[
            INSERT INTO jobs_callsigns (cid, job, callsign)
            VALUES (?, ?, ?)
        ]],
        { cid, job, callsign })

        if result["insertId"] == 0 then
            return false, "Database insert eror"
        end

        return true, "Callsign updated"
    end
end)