--[[

    Variables

]]

databaseFormat = {
    "model",
    "drawables",
    "props",
    "drawtextures",
    "proptextures",
    "hairColor",
    "headBlend",
    "headStructure",
    "headOverlay",
}

--[[

    Functions

]]

local function checkExistenceClothes(cid, cb)
    exports.ghmattimysql:execute("SELECT cid FROM character_clothes WHERE cid = @cid LIMIT 1;", {["cid"] = cid}, function(result)
        local exists = result and result[1] and true or false
        cb(exists)
    end)
end

--[[

    Events

]]

RegisterServerEvent("SpawnEventsServer")
AddEventHandler("SpawnEventsServer", function()
    local src = source

    TriggerEvent("caue-clothes:getClothes", src)
end)

RegisterServerEvent("caue-clothes:getClothes")
AddEventHandler("caue-clothes:getClothes", function(_src)
    local src = (not _src and source or _src)

    local cid = exports["caue-base"]:getChar(src, "id")
    if not cid then return end

    exports.ghmattimysql:execute([[
        SELECT *
        FROM characters_clothes
        WHERE cid = ?
    ]],
    { cid },
    function(result)
        if result[1] then
            local data = {
                model = result[1].model,
                drawables = json.decode(result[1].drawables),
                props = json.decode(result[1].props),
                drawtextures = json.decode(result[1].drawtextures),
                proptextures = json.decode(result[1].proptextures),
                hairColor = json.decode(result[1].hairColor),
                headBlend = json.decode(result[1].headBlend),
                headStructure = json.decode(result[1].headStructure),
                headOverlay = json.decode(result[1].headOverlay),
                tattoos = json.decode(result[1].tattoos),
            }

            TriggerClientEvent("caue-clothes:setClothes", src, data)
        end
	end)
end)

RegisterServerEvent("caue-clothes:updateClothes")
AddEventHandler("caue-clothes:updateClothes",function(data, tats)
    if not data then return end
    local src = source

    local cid = exports["caue-base"]:getChar(src, "id")
    if not cid then return end

    for i, v in ipairs(databaseFormat) do
        if v == "model" then
            data[v] = tostring(data[v])
        else
            if data[v] then
                data[v] = json.encode(data[v])
            else
                data[v] = json.encode({})
            end
        end
    end

    if type(tats) ~= "table" then tats = {} end
    local tattoos = json.encode(tats)

    exports.ghmattimysql:scalar([[
        SELECT cid
        FROM characters_clothes
        WHERE cid = ?
    ]],
    { cid },
    function(result)
        if not result then
            exports.ghmattimysql:execute([[
                INSERT INTO characters_clothes (cid, model, drawables, props, drawtextures, proptextures, hairColor, headBlend, headStructure, headOverlay, tattoos)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ]],
            { cid, data.model, data.drawables, data.props, data.drawtextures, data.proptextures, data.hairColor, data.headBlend, data.headStructure, data.headOverlay, tattoos })
        else
            exports.ghmattimysql:execute([[
                UPDATE characters_clothes
                SET model = ?, drawables = ?, props = ?, drawtextures = ?, proptextures = ?, hairColor = ?, headBlend = ?, headStructure = ?, headOverlay = ?, tattoos = ?
                WHERE cid = ?
            ]],
            { data.model, data.drawables, data.props, data.drawtextures, data.proptextures, data.hairColor, data.headBlend, data.headStructure, data.headOverlay, tattoos, cid })
        end
    end)
end)

RegisterServerEvent("caue-clothes:getTattoos")
AddEventHandler("caue-clothes:getTattoos", function(_src)
    local src = (not _src and source or _src)

    local cid = exports["caue-base"]:getChar(src, "id")

    exports.ghmattimysql:scalar([[
        SELECT tattoos
        FROM characters_clothes
        WHERE cid = ?
    ]],
    { cid },
    function(result)
        if result then
            TriggerClientEvent("raid_clothes:settattoos", src, json.decode(result))
        else
            TriggerClientEvent("raid_clothes:settattoos", src, {})
        end
    end)
end)

--[[

    RPCs

]]

RPC.register("caue-clothes:purchase", function(src, price, tax)
    local cid = exports["caue-base"]:getChar(src, "id")
    if not cid then return false end

    local cash = exports["caue-financials"]:getCash(src)

    if price > cash then
        return false
    end

    if not exports["caue-financials"]:updateCash(src, "-", price) then
        return false
    end

    exports["caue-financials"]:updateBalance(13, "+", price)
    exports["caue-financials"]:transactionLog(13, 13, price, "", cid, 7)
    exports["caue-financials"]:addTax("Services", tax)

    return true
end)