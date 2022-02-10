RegisterNetEvent("caue-login:spawnCharacter")
AddEventHandler("caue-login:spawnCharacter", function()
    local src = source

    local cid = exports["caue-base"]:getChar(src, "id")
    local new = exports["caue-base"]:getChar(src, "new")

    if not cid then return end

    local spawnData = {
        ["hospital"] = {
            ["illness"] = "alive",
        },
        ["motelRoom"] = {
            ["roomType"] = exports["caue-base"]:getChar(src, "hotel"),
            ["roomRoom"] = 1,
        },
        ["houses"] = {},
        ["keys"] = {},
        ["groups"] = {},
    }

    local groups = exports.ghmattimysql:executeSync([[
        SELECT g1.group, g2.name, g2.spawn
        FROM groups_members g1
        INNER JOIN ?? g2 ON g2.group = g1.group
        WHERE cid = ?
    ]],
    { "groups", cid })

    spawnData["houses"] = exports["caue-housing"]:getCurrentOwned(src)
    spawnData["keys"] = exports["caue-housing"]:currentKeys(src)

    for i, v in ipairs(groups) do
        if v.spawn then
            local spawn = json.decode(v.spawn)

            table.insert(spawnData.groups, {
                info = v.name .. " Group",
                pos = vector4(spawn.x, spawn.y, spawn.z, spawn.h),
            })
        end
    end

    if new then
        exports.ghmattimysql:executeSync([[
            UPDATE characters
            SET new = 0
            WHERE id = ?
        ]],
        { cid })

        spawnData["overwrites"] = "new"
    end

    TriggerClientEvent("spawn:clientSpawnData", src, spawnData)
end)