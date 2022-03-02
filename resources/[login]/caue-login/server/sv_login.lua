RegisterNetEvent("caue-base:sessionStarted")
AddEventHandler("caue-base:sessionStarted", function()
    local src = source

    local connect = exports["caue-base"]:getUser(src, "connected")
    if connect then return end

    exports["caue-base"]:setUser(src, "connected", os.time(os.date("!*t")))

    exports["caue-logs"]:AddLog("connect", src)
end)

AddEventHandler("playerDropped", function()
	local src = source
	local ids = GetIds(src)

	if exports["caue-base"]:getUser(src, "connected") then
        local timeplayed = os.time(os.date("!*t")) - exports["caue-base"]:getUser(src, "connected")

        MySQL.update([[
	    	UPDATE users
	    	SET timeplayed = timeplayed + ?
	    	WHERE hex = ?
	    ]],
	    { timeplayed, ids.hex })
    end

    exports["caue-base"]:setUser(src, "edit", nil)

    TriggerEvent("caue:infinity:player:remove", src)

    exports["caue-logs"]:AddLog("disconnect", src)
end)

RPC.register("caue-login:fetchData", function(src)
    local ids = GetIds(src)
    local name = GetPlayerName(src)

    if not ids.hex then
        return {
            err = "Seu hex não foi encontrado"
        }
    end

    local uid = MySQL.scalar.await([[
		SELECT id
		FROM users
		WHERE hex = ?
	]],
	{ ids.hex })

    if uid then
        MySQL.update.await([[
            UPDATE users
            SET name = ?, ip = ?
            WHERE hex = ?
        ]],
        { name, ids.ip, ids.hex })
    else
        for k,v in pairs({"steamid", "hex", "license", "ip", "discord"}) do
            if not ids[k] then
                ids[k] = "none"
            end
        end

        local insertId = MySQL.insert.await([[
            INSERT INTO users (name, hex, steamid, license, ip, discord)
            VALUES (?, ?, ?, ?, ?, ?)
        ]],
        { name, ids.hex, ids.steamid, ids.license, ids.ip, ids.discord })

        uid = insertId
    end

    exports["caue-base"]:setUser(src, "uid", uid)

    return {}
end)