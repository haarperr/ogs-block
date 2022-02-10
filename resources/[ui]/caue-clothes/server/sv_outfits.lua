RegisterServerEvent("raid_clothes:list_outfits")
AddEventHandler("raid_clothes:list_outfits",function()
    local src = source

    local cid = exports["caue-base"]:getChar(src, "id")
    if not cid then return end

    exports.ghmattimysql:execute([[
        SELECT name, slot
        FROM characters_outfits
        WHERE cid = ?
        ORDER BY slot
    ]],
    { cid },
    function(result)
    	TriggerClientEvent("raid_clothes:ListOutfits", src, result)
	end)
end)

RegisterServerEvent("raid_clothes:set_outfit")
AddEventHandler("raid_clothes:set_outfit", function(slot, name, data)
    local src = source

    local cid = exports["caue-base"]:getChar(src, "id")
    if not cid then return end

    for i, v in ipairs(databaseFormat) do
        if v == "model" then
            data[v] = tostring(data[v])
        elseif v == "fadeStyle" then
            data[v] = tonumber(data[v])
        else
            if data[v] then
                data[v] = json.encode(data[v])
            else
                data[v] = json.encode({})
            end
        end
    end

    exports.ghmattimysql:scalar([[
        SELECT slot
        FROM characters_outfits
        WHERE cid = ? AND slot = ?
    ]],
    { cid, slot },
    function(result)
        if not result then
            exports.ghmattimysql:execute([[
                INSERT INTO characters_outfits (cid, name, slot, model, drawables, props, drawtextures, proptextures, hairColor, fadeStyle, headBlend, headStructure, headOverlay)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            ]],
            { cid, name, slot, data.model, data.drawables, data.props, data.drawtextures, data.proptextures, data.hairColor, data.fadeStyle, data.headBlend, data.headStructure, data.headOverlay })
        else
            exports.ghmattimysql:execute([[
                UPDATE characters_outfits
                SET name = ?, model = ?, drawables = ?, props = ?, drawtextures = ?, proptextures = ?, hairColor = ?, fadeStyle = ?, headBlend = ?, headStructure = ?, headOverlay = ?
                WHERE cid = ? AND slot = ?
            ]],
            { name, data.model, data.drawables, data.props, data.drawtextures, data.proptextures, data.hairColor, data.fadeStyle, data.headBlend, data.headStructure, data.headOverlay, cid, slot })
        end

        TriggerClientEvent("DoLongHudText", src, name .. " stored in slot " .. slot)
	end)
end)

RegisterServerEvent("raid_clothes:remove_outfit")
AddEventHandler("raid_clothes:remove_outfit", function(slot)
    local src = source

    local cid = exports["caue-base"]:getChar(src, "id")
    if not cid then return end

    exports.ghmattimysql:execute([[
        DELETE FROM characters_outfits
        WHERE cid = ? AND slot = ?
    ]],
    { cid, slot })

    TriggerClientEvent("DoLongHudText", src, "Removed slot " .. slot)
end)

RegisterServerEvent("raid_clothes:get_outfit")
AddEventHandler("raid_clothes:get_outfit", function(slot)
    local src = source

    local cid = exports["caue-base"]:getChar(src, "id")
    if not cid then return end

    exports.ghmattimysql:execute([[
        SELECT *
        FROM characters_outfits
        WHERE cid = ? and slot = ?
    ]],
    { cid, slot },
    function(result)
        if result[1] then
            local data = {
                model = result[1].model,
                drawables = json.decode(result[1].drawables),
                props = json.decode(result[1].props),
                drawtextures = json.decode(result[1].drawtextures),
                proptextures = json.decode(result[1].proptextures),
                hairColor = json.decode(result[1].hairColor),
                fadeStyle = result[1].fadeStyle,
                headBlend = json.decode(result[1].headBlend),
                headStructure = json.decode(result[1].headStructure),
                headOverlay = json.decode(result[1].headOverlay),
            }

            TriggerClientEvent("caue-clothes:setClothes", src, data)

            exports.ghmattimysql:execute([[
                UPDATE characters_clothes
                SET model = ?, drawables = ?, props = ?, drawtextures = ?, proptextures = ?, hairColor = ?, headBlend = ?, headStructure = ?, headOverlay = ?
                WHERE cid = ?
            ]],
            { result[1].model, result[1].drawables, result[1].props, result[1].drawtextures, result[1].proptextures, result[1].hairColor, result[1].headBlend, result[1].headStructure, result[1].headOverlay, cid })
        else
            TriggerClientEvent("DoLongHudText", src, "No outfit on slot " .. slot, 2)
        end
	end)
end)