local charactersCoords = {}

RegisterNetEvent("caue-login:spawnCharacter")
AddEventHandler("caue-login:spawnCharacter", function()
    local src = source

    local cid = exports["caue-base"]:getChar(src, "id")
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
        ["crash"] = vector4(0.0, 0.0, 0.0, 0.0),
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

    if exports["caue-base"]:getChar(src, "jail") > -1 then
        spawnData["overwrites"] = "jail"
    end

    if exports["caue-base"]:getChar(src, "new") then
        exports.ghmattimysql:executeSync([[
            UPDATE characters
            SET new = 0
            WHERE id = ?
        ]],
        { cid })

        spawnData["overwrites"] = "new"
    end

    if charactersCoords[cid] then
        spawnData["crash"] = charactersCoords[cid]
    end

    TriggerClientEvent("spawn:clientSpawnData", src, spawnData)
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(2000)

        local users = exports["caue-base"]:getUsers()

        for user, vars in pairs(users) do
            if vars["char"] and vars["char"]["id"] then
                local ped = GetPlayerPed(user)
                local coords = GetEntityCoords(ped)
                local heading = GetEntityHeading(ped)

                charactersCoords[vars["char"]["id"]] = vector4(coords.x, coords.y, coords.z, heading)
            end
        end
	end
end)