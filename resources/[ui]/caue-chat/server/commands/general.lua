Commands["clear"] = {
    ["function"] = function(source, args)
        TriggerClientEvent("chat:clear", source)
    end,
    ["suggestion"] = {
        ["help"] = "Clear chat",
    },
    ["condition"] = {
        ["type"] = "ALL",
        ["params"] = {},
    },
}

Commands["hud"] = {
    ["function"] = function(source, args)
        TriggerClientEvent("caue-hud:toggle", source)
    end,
    ["suggestion"] = {
        ["help"] = "Toggles HUD",
    },
    ["condition"] = {
        ["type"] = "ALL",
        ["params"] = {},
    },
}

Commands["cash"] = {
    ["function"] = function(source, args)
        TriggerClientEvent("caue-financials:ui", source, "cash", "view", exports["caue-financials"]:getCash(source))
    end,
    ["suggestion"] = {
        ["help"] = "Check how much cash you have in wallet",
    },
    ["condition"] = {
        ["type"] = "ALL",
        ["params"] = {},
    },
}

-- Commands["bank"] = {
--     ["function"] = function(source, args)
--         local accountId = exports["caue-base"]:getChar(source, "bankid")
--         TriggerClientEvent("caue-financials:ui", source, "bank", "view", exports["caue-financials"]:getBalance(accountId))
--     end,
--     ["suggestion"] = {
--         ["help"] = "Check how much cash you have in bank",
--     },
--     ["condition"] = {
--         ["type"] = "ALL",
--         ["params"] = {},
--     },
-- }

Commands["emotes"] = {
    ["function"] = function(source, args)
        TriggerClientEvent("emotes:OpenMenu", source)
    end,
    ["suggestion"] = {
        ["help"] = "",
    },
    ["condition"] = {
        ["type"] = "ALL",
        ["params"] = {},
    },
}

Commands["e"] = {
    ["function"] = function(source, args)
        if args[1] ~= nil then
            TriggerClientEvent("animation:runtextanim2", source, tostring(args[1]))
        else
            TriggerClientEvent("DoLongHudText", source, "Use /e [emote]", 2)
        end
    end,
    ["suggestion"] = {
        ["help"] = "",
        ["params"] = {
            { name="emote", help="Use /emotes to see all emotes"},
        },
    },
    ["condition"] = {
        ["type"] = "ALL",
        ["params"] = {},
    },
}

Commands["ooc"] = {
    ["function"] = function(source, args)
        if args[1] ~= nil then
	        local name = exports["caue-base"]:getChar(source, "first_name") .. " " .. exports["caue-base"]:getChar(source, "last_name")
            TriggerClientEvent("chatMessage", -1, "OOC " .. name, 2, table.concat(args, " "))
        else
            TriggerClientEvent("DoLongHudText", source, "Use /ooc [message]", 2)
        end
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

Commands["me"] = {
    ["function"] = function(source, args)
        if args[1] ~= nil then
	        local name = exports["caue-base"]:getChar(source, "first_name") .. " " .. exports["caue-base"]:getChar(source, "last_name")

            TriggerClientEvent("caue-chat:me", -1, source, name, table.concat(args, " "))
        else
            TriggerClientEvent("DoLongHudText", source, "Use /me [message]", 2)
        end
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

Commands["do"] = {
    ["function"] = function(source, args)
        if args[1] ~= nil then
	        local name = exports["caue-base"]:getChar(source, "first_name") .. " " .. exports["caue-base"]:getChar(source, "last_name")

            TriggerClientEvent("caue-chat:do", -1, source, name, table.concat(args, " "))
        else
            TriggerClientEvent("DoLongHudText", source, "Use /do [message]", 2)
        end
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

Commands["drag"] = {
    ["function"] = function(source, args)
        TriggerClientEvent("caue-police:drag", source)
    end,
    ["suggestion"] = {
        ["help"] = "",
    },
    ["condition"] = {
        ["type"] = "ALL",
        ["params"] = {},
    },
}

Commands["h1"] = {
    ["function"] = function(source, args)
        TriggerClientEvent("facewear:adjust", source, 1, false)
    end,
    ["suggestion"] = {
        ["help"] = "",
    },
    ["condition"] = {
        ["type"] = "ALL",
        ["params"] = {},
    },
}

Commands["h0"] = {
    ["function"] = function(source, args)
        TriggerClientEvent("facewear:adjust", source, 1, true)
    end,
    ["suggestion"] = {
        ["help"] = "",
    },
    ["condition"] = {
        ["type"] = "ALL",
        ["params"] = {},
    },
}

Commands["g1"] = {
    ["function"] = function(source, args)
        TriggerClientEvent("facewear:adjust", source, 2, false)
    end,
    ["suggestion"] = {
        ["help"] = "",
    },
    ["condition"] = {
        ["type"] = "ALL",
        ["params"] = {},
    },
}

Commands["g0"] = {
    ["function"] = function(source, args)
        TriggerClientEvent("facewear:adjust", source, 2, true)
    end,
    ["suggestion"] = {
        ["help"] = "",
    },
    ["condition"] = {
        ["type"] = "ALL",
        ["params"] = {},
    },
}

Commands["m1"] = {
    ["function"] = function(source, args)
        TriggerClientEvent("facewear:adjust", source, 4, false)
    end,
    ["suggestion"] = {
        ["help"] = "",
    },
    ["condition"] = {
        ["type"] = "ALL",
        ["params"] = {},
    },
}

Commands["m0"] = {
    ["function"] = function(source, args)
        TriggerClientEvent("facewear:adjust", source, 4, true)
    end,
    ["suggestion"] = {
        ["help"] = "",
    },
    ["condition"] = {
        ["type"] = "ALL",
        ["params"] = {},
    },
}