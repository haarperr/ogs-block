--[[

    RPCs

]]

RPC.register("caue-vehicles:addFakePlate", function(src, vid)
    local plate = randomPlate()

    exports.ghmattimysql:executeSync([[
        UPDATE vehicles_metadata
        SET fakePlate = ?
        WHERE vid = ?
    ]],
    { plate, vid })

    TriggerClientEvent("inventory:removeItem", src, "fakeplate", 1)

    return plate
end)

RPC.register("caue-vehicles:removeFakePlate", function(src, vid)
    exports.ghmattimysql:executeSync([[
        UPDATE vehicles_metadata
        SET fakePlate = NULL
        WHERE vid = ?
    ]],
    { vid })

    local plate = exports.ghmattimysql:scalarSync([[
        SELECT plate
        FROM vehicles
        WHERE id = ?
    ]],
    { vid })

    TriggerClientEvent("player:receiveItem", src, "fakeplate", 1)

    return plate
end)