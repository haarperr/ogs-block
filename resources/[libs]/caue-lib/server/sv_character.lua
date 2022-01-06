function characterExist(cid)
    if not cid then return false end

    local exist = exports.ghmattimysql:scalarSync([[
        SELECT id
        FROM characters
        WHERE id = ?
    ]],
    { cid })

    if not exist then return false end

    return true
end

function getCharacter(cid, info)
    if not cid then return 0 end

    local info = exports.ghmattimysql:scalarSync([[
        SELECT ??
        FROM characters
        WHERE id = ?
    ]],
    { info, cid })

    if not info then return 0 end

    return info
end