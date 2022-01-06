RegisterNetEvent("SpawnEventsServer")
AddEventHandler("SpawnEventsServer", function()
    local src = source

    local cid = exports["caue-base"]:getChar(src, "id")
    if not cid then return end

    exports.ghmattimysql:execute([[
        SELECT expression, walk, emotes
        FROM characters_emotes
        WHERE cid = ?
    ]],
    { cid },
    function(result)
        if result[1] then
            Citizen.Wait(2000)

            TriggerClientEvent("emote:setAnimsFromDB", src, result[1]["expression"], result[1]["walk"])
            TriggerClientEvent("emote:setEmotesFromDB", src, json.decode(result[1]["emotes"]))
        else
            exports.ghmattimysql:execute([[
                INSERT INTO characters_emotes (cid, expression, walk, emotes)
                VALUES (?, ?, ?, ?)
            ]],
            { cid, "default", "default", "{}" })
        end
    end)
end)

RegisterNetEvent("caue-emotes:setExpData")
AddEventHandler("caue-emotes:setExpData", function(data)
    local src = source

    local cid = exports["caue-base"]:getChar(src, "id")
    if not cid then return end

    exports.ghmattimysql:execute([[
        UPDATE characters_emotes
        SET expression = ?
        WHERE cid = ?
    ]],
    { data, cid })
end)

RegisterNetEvent("caue-emotes:setAnimData")
AddEventHandler("caue-emotes:setAnimData", function(data)
    local src = source

    local cid = exports["caue-base"]:getChar(src, "id")
    if not cid then return end

    exports.ghmattimysql:execute([[
        UPDATE characters_emotes
        SET walk = ?
        WHERE cid = ?
    ]],
    { data, cid })
end)

RegisterNetEvent("caue-emotes:setEmoteData")
AddEventHandler("caue-emotes:setEmoteData", function(data)
    local src = source

    local cid = exports["caue-base"]:getChar(src, "id")
    if not cid then return end

    exports.ghmattimysql:execute([[
        UPDATE characters_emotes
        SET emotes = ?
        WHERE cid = ?
    ]],
    { json.encode(data), cid })
end)