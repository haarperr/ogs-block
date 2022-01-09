--[[

    Garages

]]

local garagesConfig = {
    ["DavisPD"] = {
        ["type"] = "police",
        ["jobGarage"] = true,
        ["pos"] = vector4(400.72, -1618.84, 28.62, 49.54),
        ["distance"] = 150,
        ["spaces"] = {
            vector4(384.91, -1634.26, 28.62, 321.59),
            vector4(387.33, -1636.71, 28.62, 320.16),
            vector4(392.65, -1628.39, 28.62, 50.06),
            vector4(395.04, -1626.04, 28.62, 50.98),
            vector4(397.19, -1623.89, 28.62, 50.76),
            vector4(398.79, -1621.2, 28.62, 50.03),
            vector4(400.72, -1618.84, 28.62, 49.54),
            vector4(402.74, -1616.54, 28.62, 48.83),
            vector4(387.34, -1615.45, 28.62, 230.74),
            vector4(389.17, -1613.09, 28.62, 230.91),
            vector4(391.12, -1610.66, 28.62, 230.3),
            vector4(393.02, -1608.28, 28.62, 230.71),
        },
    },
    ["Hospital"] = {
        ["type"] = "ems",
        ["jobGarage"] = true,
        ["pos"] = vector4(316.52, -578.24, 28.4, 250.64),
        ["distance"] = 250,
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
    ["Canals"] = {
        ["type"] = "boat",
        ["pos"] = vector4(-857.58, -1327.78, -0.47, 107.76),
        ["distance"] = 150,
        ["spaces"] = {
            vector4(-857.58, -1327.78, -0.47, 107.76),
            vector4(-855.26, -1336.42, -0.47, 108.41),
            vector4(-851.03, -1344.45, 0.41, 109.07),
            vector4(-848.12, -1352.86, 0.41, 108.52),
            vector4(-845.14, -1361.77, 0.41, 107.34),
            vector4(-842.01, -1371.8, 0.41, 108.99),
            vector4(-839.15, -1380.12, 0.41, 108.83),
            vector4(-836.15, -1388.92, 0.41, 108.28),
            vector4(-833.57, -1397.34, 0.41, 107.18),
            vector4(-830.86, -1406.13, 0.41, 107.18),
        },
    },
    ["Motel"] = {
        ["type"] = "car",
        ["pos"] = vector4(370.36, -1814.68, 28.38, 355.37),
        ["distance"] = 150,
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