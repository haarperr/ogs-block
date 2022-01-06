RegisterNetEvent("SpawnEventsServer")
AddEventHandler("SpawnEventsServer", function()
    local src = source

    TriggerEvent("caue-hud:getData", src)
    TriggerClientEvent("client:updateStress", src, getStress(src))
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

    exports.ghmattimysql:execute([[
        UPDATE characters
        SET health = ?, armour = ?, hunger = ?, thirst = ?
        WHERE id = ?
    ]],
    { health, armour, hunger, thirst, cid })
end)

function getStress(src)
    local cid = exports["caue-base"]:getChar(src, "id")
    if not cid then return 0 end

    local stress = exports.ghmattimysql:scalarSync([[
        SELECT stress
        FROM characters
        WHERE id = ?
    ]],
    { cid })

    return stress or 0
end

RegisterNetEvent("caue-hud:alterStress")
AddEventHandler("caue-hud:alterStress", function(positive, value)
    local src = source

    local cid = exports["caue-base"]:getChar(src, "id")
    if not cid then return end

    local stress = getStress(src)

    if positive then
        stress = stress + value
        if stress > 10000 then stress = 10000 end
    else
        stress = stress - value
        if stress < 0 then stress = 0 end
    end

    exports.ghmattimysql:execute([[
        UPDATE characters
        SET stress = ?
        WHERE id = ?
    ]],
    { stress, cid },
    function()
        TriggerClientEvent("client:updateStress", src, stress)
    end)
end)