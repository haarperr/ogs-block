--[[

    Variables

]]

Caue.Admin.DB = Caue.Admin.DB or {}

--[[

    Functions

]]

function Caue.Admin.DB.giveCar(self, src, model, cid)
    if not characterExist(cid) then
        TriggerClientEvent("DoLongHudText", src, "This CID dont exist", 2)
        return
    end

    local gived = exports["caue-vehicles"]:insertVehicle(0, model, "car", 0, false, false, cid)
    if gived then
        TriggerClientEvent("DoLongHudText", src, "Vehicle " .. model .. " gived to CID " .. cid)
    else
        TriggerClientEvent("DoLongHudText", src, "Error?", 2)
    end
end

function Caue.Admin.SetRank(self, target, rank)
    local src = target:getVar("source")
    local hex = target:getVar("hexid")

    exports.ghmattimysql:execute([[
        UPDATE users
        SET users.rank = ?
        WHERE hex = ?
    ]],
    { rank, hex },
    function()
        exports["caue-base"]:setUser(src, "rank", rank)
        TriggerClientEvent("caue-base:setVar", src, "rank", rank)

        Caue._Admin.Players[src]["rank"] = rank

        if Caue._Admin.CurAdmins[src] and rank == "user" then
            Caue._Admin.CurAdmins[src] = nil
            TriggerClientEvent("caue-admin:noLongerAdmin", src)
        end

        for k, v in pairs(Caue._Admin.CurAdmins) do
            TriggerClientEvent("caue-admin:updateData", k, src, "rank", rank)
        end
    end)
end

function Caue.Admin.IsBanned(self, hex)
    local banned = exports.ghmattimysql:scalarSync([[
        SELECT time
        FROM users_bans
        WHERE hex = ?
    ]],
    { hex })

    return banned and true or false
end

function Caue.Admin.Ban(self, hex, time, reason)
    if not time then time = 0 end

    if Caue.Admin:IsBanned(hex) then
        exports.ghmattimysql:execute([[
            UPDATE users_bans
            SET time = ?, reason = ?
            WHERE hex = ?
        ]],
        { time, reason, hex })
    else
        exports.ghmattimysql:execute([[
            INSERT INTO users_bans (hex, time, reason)
            VALUES (?, ?, ?)
        ]],
        { hex, time, reason })
    end
end

function Caue.Admin.DB.Unban(self, hex)
    exports.ghmattimysql:execute([[
        DELETE FROM users_bans
        WHERE hex = ?
    ]],
    { hex })
end

--[[

    Events

]]

RegisterServerEvent("caue-admin:searchRequest")
AddEventHandler("caue-admin:searchRequest", function()

end)