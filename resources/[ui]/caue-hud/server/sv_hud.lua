RegisterNetEvent("SpawnEventsServer")
AddEventHandler("SpawnEventsServer", function()
    local src = source

    TriggerEvent("caue-hud:getData", src)
end)

RegisterNetEvent("caue-hud:getData")
AddEventHandler("caue-hud:getData", function(_src)
    local src = source
    if _src then src = _src end

    local cid = exports["caue-base"]:getChar(src, "id")
    if not cid then return end

    exports.ghmattimysql:execute([[
        SELECT health, armour, hunger, thirst
        FROM characters
        WHERE id = ?
    ]],
    { cid },
    function(result)
        if result[1] then
            TriggerClientEvent("caue-hud:setData", src, result[1])
        end
    end)
end)

RegisterNetEvent("caue-hud:updateData")
AddEventHandler("caue-hud:updateData", function(health, armour, hunger, thirst, _src)
    local src = source
    if _src then src = _src end

    local cid = exports["caue-base"]:getChar(src, "id")
    if not cid then return end

    if health > 200 then
        health = 200
    end

    exports.ghmattimysql:execute([[
        UPDATE characters
        SET health = ?, armour = ?, hunger = ?, thirst = ?
        WHERE id = ?
    ]],
    { health, armour, hunger, thirst, cid })
end)