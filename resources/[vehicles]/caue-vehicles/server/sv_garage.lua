--[[

    Garages

]]

local garagesConfig = {
    ["MRPD"] = {
        ["type"] = "police",
        ["jobGarage"] = true,
        ["pos"] = vector4(437.31, -996.93, 25.3, 90.1),
        ["distance"] = 150,
        ["spaces"] = {
            vector4(445.74, -996.94, 25.3, 269.16),
            vector4(445.57, -994.23, 25.3, 269.26),
            vector4(445.8, -991.49, 25.3, 268.82),
            vector4(445.73, -988.86, 25.3, 269.45),
            vector4(445.73, -986.11, 25.3, 269.32),
            vector4(437.27, -986.16, 25.3, 89.2),
            vector4(437.28, -988.87, 25.3, 91.25),
            vector4(437.41, -991.59, 25.3, 89.96),
            vector4(437.3, -994.28, 25.3, 90.01),
            vector4(437.31, -996.93, 25.3, 90.1),
            vector4(425.71, -997.08, 25.3, 270.01),
            vector4(425.74, -994.41, 25.3, 269.55),
            vector4(425.76, -991.65, 25.3, 270.83),
            vector4(425.82, -988.97, 25.3, 269.8),
            vector4(425.75, -984.27, 25.3, 270.67),
            vector4(425.78, -981.54, 25.3, 269.55),
            vector4(425.88, -978.81, 25.3, 270.18),
            vector4(425.77, -976.13, 25.3, 270.51),
        },
    },
    ["Hospital"] = {
        ["type"] = "ems",
        ["jobGarage"] = true,
        ["pos"] = vector4(316.52, -578.24, 28.4, 250.64),
        ["distance"] = 100,
        ["spaces"] = {
            vector4(332.97, -590.6, 28.4, 339.91),
            vector4(329.62, -589.53, 28.4, 341.87),
            vector4(326.34, -588.32, 28.4, 340.95),
            vector4(323.04, -587.06, 28.4, 341.23),
            vector4(319.58, -585.71, 28.4, 340.55),
            vector4(316.52, -578.24, 28.4, 250.64),
            vector4(318.12, -573.93, 28.4, 248.37),
            vector4(319.71, -569.74, 28.4, 249.57),
            vector4(321.05, -565.23, 28.4, 248.56),
        },
    },
    ["Motel"] = {
        ["type"] = "car",
        ["pos"] = vector4(370.36, -1814.68, 28.38, 355.37),
        ["distance"] = 100,
        ["spaces"] = {
            vector4(364.75, -1810.0, 28.37, 354.07),
            vector4(367.55, -1812.43, 28.37, 353.71),
            vector4(370.36, -1814.68, 28.38, 355.37),
            vector4(373.36, -1816.71, 28.41, 354.6),
            vector4(376.23, -1819.04, 28.46, 355.98),
            vector4(379.05, -1822.3, 28.38, 353.87),
        },
    },
}

--[[

    Exports

]]

exports("setGarage", function(pGarage, pVar, pValue, pEdit)
    if not garagesConfig[pGarage] then
        garagesConfig[pGarage] = {}
    end

    if pEdit then
        garagesConfig[pGarage][pVar] = pValue
    else
        garagesConfig[pGarage] = pVar
    end

    TriggerClientEvent("caue-vehicles:setGarage", -1, pGarage, pVar, pValue, pEdit)
end)

exports("getGarage", function(pGarage, pVar)
    return garagesConfig[pGarage][pVar]
end)

--[[

    RPCs

]]

RPC.register("caue-vehicles:requestGarages", function(src)
    return garagesConfig
end)

RPC.register("caue-vehicles:getGarage", function(src, garage)
    local cid = exports["caue-base"]:getChar(src, "id")
    if not cid then return {} end

    local type = garagesConfig[garage]["type"]

    local vehicles = exports.ghmattimysql:executeSync([[
        SELECT v2.id, v2.plate, v2.model, v3.body_damage, v3.engine_damage, v3.fuel
        FROM vehicles_garage v1
        INNER JOIN vehicles v2 ON v2.id = v1.vid AND v2.cid = ? AND v2.type = ?
        INNER JOIN vehicles_metadata v3 ON v3.vid = v1.vid
        WHERE garage = ? AND state = "In"
    ]],
    { cid, type, garage })

    return vehicles
end)

RPC.register("caue-vehicles:canStoreVehicle", function(src, garage, vid)
    local typeGarage = garagesConfig[garage]["type"]

    local typeVehicle = exports.ghmattimysql:scalarSync([[
        SELECT type
        FROM vehicles
        WHERE id = ?
    ]],
    { vid })

    if not typeVehicle then
        TriggerClientEvent("DoLongHudText", src, "Error?", 2)
        return false
    end

    if typeVehicle ~= typeGarage then
        TriggerClientEvent("DoLongHudText", src, "You cant store this vehicle here", 2)
        return false
    end

    return true
end)

--[[

    Threads

]]

Citizen.CreateThread(function()
    exports.ghmattimysql:execute([[
        UPDATE vehicles_garage
        SET state = "In"
        WHERE state = "Out"
    ]])
end)