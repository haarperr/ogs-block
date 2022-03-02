--[[

    Functions

]]

function getDocuments(type, data)
    if not type or not data then return {} end

    local documents = MySQL.query.await([[
        SELECT *
        FROM documents
        WHERE ?? = ?
    ]],
    { type, data })

    for i, v in ipairs(documents) do
        v["data"] = json.decode(v["data"])
    end

    return documents
end

function submitDocument(data, cid, group)
    if not data or (not cid and not group) then return end

    MySQL.insert.await([[
        INSERT INTO documents (cid, data)
        VALUES (?, ?)
    ]],
    { cid, json.encode(data) })

    if group then
        MySQL.insert.await([[
            INSERT INTO documents (documents.group, data)
            VALUES (?, ?)
        ]],
        { group, json.encode(data) })
    end

    return true
end

function deleteDocument(id)
    if not id then return end

    MySQL.update.await([[
        DELETE FROM documents
        WHERE id = ?
    ]],
    { id })

    return true
end

--[[

    Events

]]

RegisterNetEvent("caue-documents:showDocument")
AddEventHandler("caue-documents:showDocument", function(player, document)
    local src = source

    TriggerClientEvent("caue-documents:ViewDocument", player, document)
end)

RegisterNetEvent("caue-documents:copyDocument")
AddEventHandler("caue-documents:copyDocument", function(player, document)
    local src = source

    local cid = exports["caue-base"]:getChar(player, "id")
    if not cid then return end

    submitDocument(document, cid)

    TriggerClientEvent("DoLongHudText", player, "You received a form copy")
end)


--[[

    RPCs

]]

RPC.register("caue-documents:getDocuments", function(src, type, data)
    return getDocuments(type, data)
end)

RPC.register("caue-documents:submitDocument", function(src, data, cid, group)
    return submitDocument(data, cid, group)
end)

RPC.register("caue-documents:deleteDocument", function(src, id)
    return deleteDocument(id)
end)