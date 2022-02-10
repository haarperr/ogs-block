Commands["jail"] = {
    ["function"] = function(source, args)
        if args[1] ~= nil or args[2] ~= nil then
            if not exports["caue-base"]:getChar(tonumber(args[1]), "id") then return end

            local ped = GetPlayerPed(tonumber(args[1]))
            SetEntityCoords(ped, 1687.38, 2445.83, 45.61)

            exports["caue-base"]:setChar(tonumber(args[1]), "jail", tonumber(args[2]))
            TriggerClientEvent("caue-base:setChar", tonumber(args[1]), "jail", tonumber(args[2]))

            exports.ghmattimysql:execute([[
                UPDATE characters
                SET jail = ?
                WHERE id = ?
            ]],
            { tonumber(args[2]), exports["caue-base"]:getChar(tonumber(args[1]), "id") })

            TriggerEvent("caue-police:jail", tonumber(args[1]))
        else
            TriggerClientEvent("DoLongHudText", source, "Usado /jail [id] [tempo]", 2)
        end
    end,
    ["suggestion"] = {
        ["help"] = "",
        ["params"] = {},
    },
    ["condition"] = {
        ["type"] = "JOB",
        ["params"] = { ["jobs"] = {"police"} },
    },
}