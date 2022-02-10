--[[

    Variables

]]

local vehiclesForSale = {}

--[[

    Functions

]]

function insertLog(vid, model, plate, price, financed, commission, tax, shop, buyer, seller)
    if not vid or not model or not plate or not price or not financed or not commission or not tax or not shop or not buyer or not seller then return end

    exports.ghmattimysql:execute([[
        INSERT INTO carshop_logs (vid, model, price, financed, commission, tax, shop, buyer, seller)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
    ]],
    { vid, model, price, financed, commission, tax, shop, buyer, seller })

    exports["caue-logs"]:AddLog("vehicleShop", vid, model, price, financed, commission, tax, shop, buyer, seller)
    exports["caue-groups"]:groupLog(shop, "Sell", seller .. " selled " .. model .. "(" .. plate .. ") to " .. buyer .. " for $" .. price .. " with " .. commission .. "% commission")
end

--[[

    Exports

]]

exports("insertLog", insertLog)

--[[

    Events

]]

RegisterNetEvent("caue-carshop:change")
AddEventHandler("caue-carshop:change", function(shop, index, model)
    if not shop or not index or not model then return end

    exports.ghmattimysql:executeSync([[
        UPDATE carshop_display
        SET ?? = ?
        WHERE ?? = ? AND ?? = ?
    ]],
    { "model", model, "shop", shop, "index", index })

    Config[shop]["Spawns"][index]["model"] = model

    TriggerClientEvent("caue-carshop:updateDisplay", -1, shop)
end)

RegisterNetEvent("caue-carshop:commission")
AddEventHandler("caue-carshop:commission", function(shop, index, commission)
    if not shop or not index or not commission then return end

    local src = source

    Config[shop]["Spawns"][index]["commission"] = commission

    TriggerClientEvent("DoLongHudText", src, "Commission changed to " .. commission .. "%")
end)

RegisterNetEvent("caue-carshop:sell")
AddEventHandler("caue-carshop:sell", function(plate, shop, index)
    if not plate or not shop or not index then return end

    local src = source

    local cid = exports["caue-base"]:getChar(src, "id")
    if not cid then return end

    local name = exports["caue-base"]:getChar(src, "first_name") .. " " .. exports["caue-base"]:getChar(src, "last_name")

    Config[shop]["Spawns"][index]["seller"]["sid"] = src
    Config[shop]["Spawns"][index]["seller"]["name"] = name

    vehiclesForSale[plate] = GetGameTimer() + 60000
end)

RegisterNetEvent("caue-carshop:buy")
AddEventHandler("caue-carshop:buy", function(pParams)
    if not pParams then return end

    local src = source

    local cid = exports["caue-base"]:getChar(src, "id")
    if not cid then return end

    local accountId = exports["caue-base"]:getChar(src, "bankid")
    local groupBank = exports["caue-groups"]:groupBank(pParams.shop)
    local sellerAccount = exports["caue-base"]:getChar(pParams.seller, "bankid")

    if not accountId or not groupBank or not sellerAccount then return end

    local bank = exports["caue-financials"]:getBalance(accountId)
    if bank < pParams.downpayment then
        TriggerClientEvent("DoLongHudText", src, "Você não tem $" .. pParams.downpayment .. "na sua conta do banco.", 2)
        return
    end

    local comment = "Brought " .. pParams.name
    local success, message = exports["caue-financials"]:transaction(accountId, groupBank, pParams.downpayment, comment, cid, 5)
    if not success then
        TriggerClientEvent("DoLongHudText", src, message)
        return
    end

    local comment2 = "Commission from " .. pParams.name
    local success2, message2 = exports["caue-financials"]:transaction(groupBank, sellerAccount, pParams.commission, comment2, 0, 1)
    if not success2 then
        TriggerClientEvent("DoLongHudText", src, message2)
        return
    end

    exports["caue-financials"]:addTax("Vehicles", pParams.tax)

    local vid = exports["caue-vehicles"]:insertVehicle(src, pParams.model, "car", pParams.financing, true, true)
    if not vid then
        TriggerClientEvent("DoLongHudText", src, "Error???", 2)
        return
    end

    local vehicle = exports["caue-vehicles"]:getVehicle(vid)

    TriggerClientEvent("caue-vehicles:spawnVehicle", src, pParams.model, Config[pParams.shop]["Buyed"], vehicle["id"], vehicle["plate"], 100, false, false, false, false, false, true)

    insertLog(vid, pParams.model, vehicle["plate"], pParams.finalprice, 1, pParams.commission, pParams.tax, pParams.shop, pParams.buyer, pParams.sellername)
end)

--[[

    RPCs

]]

RPC.register("caue-carshop:getVehicles", function(src, shop)
    local _vehicles = {}

    for i, v in ipairs(Config["Vehicles"]) do
        if v["shop"] == shop then
            table.insert(_vehicles, v)
        end
    end

    return _vehicles
end)

RPC.register("caue-carshop:getDisplay", function(src, shop)
    return Config[shop]["Spawns"]
end)

RPC.register("caue-carshop:getInformations", function(src, shop, index)
    if not shop or not index then return end

    local model = Config[shop]["Spawns"][index]["model"]
    if not model then return end

    local infos = nil
    for i, v in ipairs(Config["Vehicles"]) do
        if v["model"] == model and v["shop"] == shop then
            infos = v
            infos["seller"] = Config[shop]["Spawns"][index]["seller"]
            infos["commission"] = Config[shop]["Spawns"][index]["commission"]

            break
        end
    end

    return infos
end)

RPC.register("caue-carshop:forSale", function(src, plate)
    return vehiclesForSale[plate] and vehiclesForSale[plate] > GetGameTimer()
end)

--[[

    Threads

]]

Citizen.CreateThread(function()
    local _vehicles = exports.ghmattimysql:executeSync([[
        SELECT *
        FROM carshop_vehicles
        ORDER BY category, model
    ]])

    Config["Vehicles"] = _vehicles

    local _display = exports.ghmattimysql:executeSync([[
        SELECT *
        FROM carshop_display
    ]])

    for i, v in ipairs(_display) do
        Config[v.shop]["Spawns"][v.index]["model"] = v.model
        Config[v.shop]["Spawns"][v.index]["commission"] = 15
        Config[v.shop]["Spawns"][v.index]["seller"] = {
            ["sid"] = 0,
            ["name"] = exports["caue-groups"]:groupName(v.shop)
        }
    end
end)