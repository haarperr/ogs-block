--[[

    Variables

]]

itemList = {}

--[[

    Functions

]]

function getItem(pClass, pInfo)
    local infoReturn = nil

    if itemList[pClass] then
        if pInfo then
            if itemList[pClass][pInfo] then
                infoReturn = itemList[pClass][pInfo]
            end
        else
            infoReturn = itemList[pClass]
        end
    end

    return infoReturn
end

function getInventory(pInventory)
    local inventory = exports.ghmattimysql:executeSync([[
        SELECT count(item_id) as amount, id, name, item_id, information, slot, dropped, creationDate
        FROM inventory
        WHERE name = ?
        GROUP BY slot
    ]],
    { pInventory })

    return inventory
end

function K9Sniff(pId)
    local inventory = getInventory("ply-" .. pId)

    for i, v in ipairs(inventory) do
        if itemList[v.item_id].contraband then
            return true
        end
    end

    return false
end

function K9SniffVehicle(pId)
    local inventoryGlovebox = getInventory("Glovebox-" .. pId)
    local inventoryTrunk = getInventory("Trunk-" .. pId)

    for i, v in ipairs(inventoryGlovebox) do
        if itemList[v.item_id].contraband then
            return true
        end
    end

    for i, v in ipairs(inventoryTrunk) do
        if itemList[v.item_id].contraband then
            return true
        end
    end

    return false
end

--[[

    Exports

]]

exports("getItem", getItem)
exports("getInventory", getInventory)
exports("K9Sniff", K9Sniff)
exports("K9SniffVehicle", K9SniffVehicle)

--[[

    Events

]]

AddEventHandler("caue-inventory:luaItemList", function(pItems)
    itemList = pItems
end)