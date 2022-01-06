--[[

    Functions

]]

local function addPlayer(src)
    if Caue._Admin.Players[src] then return end

    local ids = GetIds(src)
    local rank = exports["caue-base"]:getUser(src, "rank")

    if rank ~= "user" then
        Caue._Admin.CurAdmins[src] = true
    end

    local infos = {
        source = src,
        name = GetPlayerName(src),
        status = "Playing",
        rank = rank,
        steamid = ids.steamid,
        comid = exports["caue-base"]:getUser(src, "uid"),
        hexid = ids.hex,
        license = ids.license,
        ping = GetPlayerPing(src),
        ip = tostring(GetPlayerEndpoint(src))
    }

    Caue._Admin.Players[src] = infos

    for k, v in pairs(Caue._Admin.CurAdmins) do
        if k == src then
            TriggerClientEvent("caue-admin:sendPlayerInfo", src, Caue._Admin.Players, Caue._Admin.DiscPlayers)
        else
            TriggerClientEvent("caue-admin:AddPlayer", k, infos)
        end
    end
end

local function removePlayer(src)
    if not Caue._Admin.Players[src] then return end

    local data = Caue._Admin.Players[src]
    Caue._Admin.DiscPlayers[src] = data
    Caue._Admin.Players[src] = nil

    for k, v in pairs(Caue._Admin.CurAdmins) do
        TriggerClientEvent("caue-admin:RemovePlayer", k, src)
    end
end

local function updatePlayer(src, var, value)
    if not Caue._Admin.Players[src] then return end

    Caue._Admin.Players[src][var] = value

    for k, v in pairs(Caue._Admin.CurAdmins) do
        TriggerClientEvent("caue-admin:updateData", k, src, var, value)
    end
end

--[[

    Events

]]

RegisterNetEvent("caue-base:sessionStarted")
AddEventHandler("caue-base:sessionStarted", function()
    local src = source

    Citizen.Wait(3000)

    local ids = GetIds(src)
    if not ids["hex"] then
        exports["caue-base"]:setUser(src, "rank", "user")
        TriggerClientEvent("caue-base:setVar", src, "rank", "user")
        return
    end

    local rank = exports.ghmattimysql:scalarSync([[
        SELECT users.rank
        FROM users
        WHERE hex = ?
    ]],
    { ids["hex"] })

    if not rank then
        exports["caue-base"]:setUser(src, "rank", "user")
        TriggerClientEvent("caue-base:setVar", src, "rank", "user")
        return
    end

    exports["caue-base"]:setUser(src, "rank", rank)
    TriggerClientEvent("caue-base:setVar", src, "rank", rank)

    addPlayer(src)
end)

AddEventHandler("playerDropped", function()
	local src = source

    removePlayer(src)
end)

RegisterNetEvent("caue-admin:setStatus")
AddEventHandler("caue-admin:setStatus", function(status)
    local src = source

    if not Caue._Admin.Players[src] then return end

    Caue._Admin.Players[src].status = status

    for k, v in pairs(Caue._Admin.CurAdmins) do
        TriggerClientEvent("caue-admin:setStatus", src, status)
    end
end)

RegisterNetEvent("caue-admin:runCommand")
AddEventHandler("caue-admin:runCommand", function(args)
    local src = source
    local cmd = args["command"]

    local caller = Caue._Admin.Players[src]
    function caller.getVar(self, type)
        return self[type]
    end

    if args["target"] then
        function args.target.getVar(self, type)
            return self[type]
        end
    end

    Caue.Admin:GetCommandData(cmd).runcommand(caller,args)
    TriggerClientEvent("caue-admin:RunClCommand",src,cmd,args)
end)

--[[

    Threads

]]

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1200000)

        for k, v in pairs(Caue._Admin.Players) do
            updatePlayer(k, "ping", GetPlayerPing(k))
            updatePlayer(k, "ip", tostring(GetPlayerEndpoint(k)))
        end
    end
end)