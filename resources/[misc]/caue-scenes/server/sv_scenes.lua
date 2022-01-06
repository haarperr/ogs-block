--[[

    Variables

]]

local activeScenes = {}

--[[

    RPCs

]]

RPC.register("caue-scenes:getScenes", function(src)
    return activeScenes
end)

RPC.register("caue-scenes:addScene", function(src, coords, text, distance, color)
    local result = exports.ghmattimysql:executeSync([[
        INSERT INTO scenes (text, color, distance, coords, date)
        VALUES (?, ?, ?, ?, UNIX_TIMESTAMP())
    ]],
    { text, color, distance, json.encode(coords) })

    local data = {
        id = result["insertId"],
        coords = coords,
        text = text,
        distance = distance,
        color = color,
    }

    table.insert(activeScenes, data)
    TriggerClientEvent("caue-scenes:refreshScenes", -1, activeScenes)

    return
end)

RPC.register("caue-scenes:deleteScene", function(src, coords)
    local toRemove = 0
    local toRemoveId = 0
    local nearest = 100

    for i, v in ipairs(activeScenes) do
        local distance = #(coords - v.coords)
        if distance < 2.0 and distance < nearest then
            nearest = distance
            toRemove = i
            toRemoveId = v.id
        end
    end

    if toRemove ~= 0 then
        table.remove(activeScenes, toRemove)
        TriggerClientEvent("caue-scenes:refreshScenes", -1, activeScenes, toRemoveId)

        exports.ghmattimysql:executeSync([[
            DELETE FROM scenes
            WHERE id = ?
        ]],
        { toRemoveId })
    end

    return
end)

--[[

    Threads

]]

Citizen.CreateThread(function()
    exports.ghmattimysql:executeSync([[
        DELETE FROM scenes
        WHERE DATEDIFF(FROM_UNIXTIME(UNIX_TIMESTAMP()), FROM_UNIXTIME(date)) > 3
    ]],
    { toRemoveId })

    local result = exports.ghmattimysql:executeSync([[
        SELECT id, text, color, distance, coords
        FROM scenes
    ]])

    for i, v in ipairs(result) do
        local _coords = json.decode(v["coords"])

        table.insert(activeScenes, {
            id = v["id"],
            coords = vector3(_coords.x, _coords.y, _coords.z),
            text = v["text"],
            distance = v["distance"],
            color = v["color"],
        })
    end
end)