Commands["tv"] = {
    ["function"] = function(source, args)
        TriggerClientEvent("caue-tvbox:tv", source, args)
    end,
    ["suggestion"] = {
        ["help"] = "",
        ["params"] = {},
    },
    ["condition"] = {
        ["type"] = "ALL",
        ["params"] = {},
    },
}

Commands["volume"] = {
    ["function"] = function(source, args)
        TriggerClientEvent("caue-tvbox:volume", source, args)
    end,
    ["suggestion"] = {
        ["help"] = "",
        ["params"] = {},
    },
    ["condition"] = {
        ["type"] = "ALL",
        ["params"] = {},
    },
}

Commands["desligar"] = {
    ["function"] = function(source, args)
        TriggerClientEvent("caue-tvbox:destroy", source, args)
    end,
    ["suggestion"] = {
        ["help"] = "",
        ["params"] = {},
    },
    ["condition"] = {
        ["type"] = "ALL",
        ["params"] = {},
    },
}