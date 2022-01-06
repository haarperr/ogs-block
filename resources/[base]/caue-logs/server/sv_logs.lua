LOGS = {
    --[[

        Connect And Disconnect

    ]]

    ["connect"] = {
        ["DISCORD_WEBHOOK"] = "https://discord.com/api/webhooks/819685309893705788/ve9Fv1LPgGIBTmAIwY5RCc4MrcsmhHyj708UUlFpJcLV5X-M6BcUy-Ay-B54ULT5mvpk",
        ["DISCORD_NAME"] = "Connect And Disconnect Logs",
        ["DISCORD_IMAGE"] = "https://i.pinimg.com/736x/76/b5/9f/76b59f362b7f2d57bc6539b37cb54985.jpg",
        ["DISCORD_TITLE"] = "Connect",
        ["DISCORD_COLOR"] = 65280,

        ["FUNCTION"] = function(type, src)
            local ids = GetIds(src)

            local embed = {
                {
                    ["color"] = LOGS[type]["DISCORD_COLOR"],
                    ["title"] = "**" .. GetPlayerName(src) .. "** has joined the server",
                    ["description"] = "**Server ID:** " .. src .. "\n**Steam HEX:** " .. ids["hex"] .. "\n**Steam ID:** " .. ids["steamid"] .. "\n**Discord ID:** " .. ids["discord"] .. "\n**IP:** " .. ids["ip"],
                    ["footer"] = {
                        ["text"] = os.date('%d/%m/%Y %H:%M:%S', os.time())
                    },
                }
            }

            PerformHttpRequest(
                LOGS[type]["DISCORD_WEBHOOK"],
                function(err, text, headers) end,
                "POST",
                json.encode({
                    username = LOGS[type]["DISCORD_NAME"],
                    embeds = embed,
                    avatar_url = LOGS[type]["DISCORD_IMAGE"],
                }),
                {["Content-Type"] = "application/json"}
            )
        end,
    },
    ["disconnect"] = {
        ["DISCORD_WEBHOOK"] = "https://discord.com/api/webhooks/819685309893705788/ve9Fv1LPgGIBTmAIwY5RCc4MrcsmhHyj708UUlFpJcLV5X-M6BcUy-Ay-B54ULT5mvpk",
        ["DISCORD_NAME"] = "Connect And Disconnect Logs",
        ["DISCORD_IMAGE"] = "https://i.pinimg.com/736x/76/b5/9f/76b59f362b7f2d57bc6539b37cb54985.jpg",
        ["DISCORD_TITLE"] = "Disconnect",
        ["DISCORD_COLOR"] = 16711680,

        ["FUNCTION"] = function(type, src)
            local ids = GetIds(src)

            local embed = {
                {
                    ["color"] = LOGS[type]["DISCORD_COLOR"],
                    ["title"] = "**" .. GetPlayerName(src) .. "** has left the server",
                    ["description"] = "**Server ID:** " .. src .. "\n**Steam HEX:** " .. ids["hex"] .. "\n**Steam ID:** " .. ids["steamid"] .. "\n**Discord ID:** " .. ids["discord"] .. "\n**IP:** " .. ids["ip"],
                    ["footer"] = {
                        ["text"] = os.date('%d/%m/%Y %H:%M:%S', os.time())
                    },
                }
            }

            PerformHttpRequest(
                LOGS[type]["DISCORD_WEBHOOK"],
                function(err, text, headers) end,
                "POST",
                json.encode({
                    username = LOGS[type]["DISCORD_NAME"],
                    embeds = embed,
                    avatar_url = LOGS[type]["DISCORD_IMAGE"],
                }),
                {["Content-Type"] = "application/json"}
            )
        end,
    },

    --[[

        Characters

    ]]

    ["character-create"] = {
        ["DISCORD_WEBHOOK"] = "https://discord.com/api/webhooks/819732601392201739/o0amE0LBnrywmlSQC-drA5B9avkmcgpg4kEDc-0eA__4lD845vARlMm98IyiNTYZTjIq",
        ["DISCORD_NAME"] = "Characters Logs",
        ["DISCORD_IMAGE"] = "https://i.pinimg.com/736x/76/b5/9f/76b59f362b7f2d57bc6539b37cb54985.jpg",
        ["DISCORD_TITLE"] = "Created",
        ["DISCORD_COLOR"] = 65280,

        ["FUNCTION"] = function(type, src, dbid)
            local ids = GetIds(src)

            local char = exports.ghmattimysql:executeSync([[
                SELECT first_name, last_name, gender, dob, phone
                FROM characters
                WHERE id = ?
            ]],
            { dbid })[1]

            local gender = "Male"
            if char["gender"] == 1 then
                gender = "Female"
            end

            local embed = {
                {
                    ["color"] = LOGS[type]["DISCORD_COLOR"],
                    ["title"] = "**" .. char["first_name"] .. " " .. char["last_name"] .. "** has been created",
                    ["description"] = "**Steam HEX:** " .. ids["hex"] .. "\n**Steam ID:** " .. ids["steamid"] .. "\n**Discord ID:** " .. ids["discord"] .. "\n**Char ID:** " .. dbid .. "\n**Gender:** " .. gender .. "\n**DOB:** " .. char["dob"] .. "\n**Phone:** " .. char["phone"],
                    ["footer"] = {
                        ["text"] = os.date('%d/%m/%Y %H:%M:%S', os.time())
                    },
                }
            }

            PerformHttpRequest(
                LOGS[type]["DISCORD_WEBHOOK"],
                function(err, text, headers) end,
                "POST",
                json.encode({
                    username = LOGS[type]["DISCORD_NAME"],
                    embeds = embed,
                    avatar_url = LOGS[type]["DISCORD_IMAGE"],
                }),
                {["Content-Type"] = "application/json"}
            )
        end,
    },
    ["character-delete"] = {
        ["DISCORD_WEBHOOK"] = "https://discord.com/api/webhooks/819732601392201739/o0amE0LBnrywmlSQC-drA5B9avkmcgpg4kEDc-0eA__4lD845vARlMm98IyiNTYZTjIq",
        ["DISCORD_NAME"] = "Characters Logs",
        ["DISCORD_IMAGE"] = "https://i.pinimg.com/736x/76/b5/9f/76b59f362b7f2d57bc6539b37cb54985.jpg",
        ["DISCORD_TITLE"] = "Deleted",
        ["DISCORD_COLOR"] = 16711680,

        ["FUNCTION"] = function(type, src, dbid)
            local ids = GetIds(src)

            local char = exports.ghmattimysql:executeSync([[
                SELECT first_name, last_name
                FROM characters
                WHERE id = ?
            ]],
            { dbid })[1]

            local embed = {
                {
                    ["color"] = LOGS[type]["DISCORD_COLOR"],
                    ["title"] = "**" .. char["first_name"] .. " " .. char["last_name"] .. "** has been deleted",
                    ["description"] = "**Steam HEX:** " .. ids["hex"] .. "\n**Steam ID:** " .. ids["steamid"] .. "\n**Discord ID:** " .. ids["discord"] .. "\n**Char ID:** " .. dbid,
                    ["footer"] = {
                        ["text"] = os.date('%d/%m/%Y %H:%M:%S', os.time())
                    },
                }
            }

            PerformHttpRequest(
                LOGS[type]["DISCORD_WEBHOOK"],
                function(err, text, headers) end,
                "POST",
                json.encode({
                    username = LOGS[type]["DISCORD_NAME"],
                    embeds = embed,
                    avatar_url = LOGS[type]["DISCORD_IMAGE"],
                }),
                {["Content-Type"] = "application/json"}
            )
        end,
    },

    --[[

        Bank

    ]]

    ["deposit"] = {
        ["DISCORD_WEBHOOK"] = "https://discord.com/api/webhooks/819704587002708048/oWac3UoA1Dm7sYQYyNpaX5Vt7AHMmPTCQwiF_B5BlI_t1rjiDro-lOcJWznNuWSqtoyb",
        ["DISCORD_NAME"] = "Bank Logs",
        ["DISCORD_IMAGE"] = "https://i.pinimg.com/736x/76/b5/9f/76b59f362b7f2d57bc6539b37cb54985.jpg",
        ["DISCORD_TITLE"] = "Deposit",
        ["DISCORD_COLOR"] = 65280,

        ["FUNCTION"] = function(type, src, amount, cash, bank, comment, uid)
            local char = exports["caue-base"]:getChar(src)
            if not char then return end

            local ids = GetIds(src)

            local embed = {
                {
                    ["color"] = LOGS[type]["DISCORD_COLOR"],
                    ["title"] = "**" .. char["first_name"] .. " " .. char["last_name"] .. "** deposit **$" .. amount .. "**",
                    ["description"] = "**Transaction ID:** " .. uid .. "\n**Comment:** " .. comment .. "\n\n**Server ID:** " .. src .. "\n**Steam HEX:** " .. ids["hex"] .. "\n**Char ID:** " .. char["id"] .. "\n**Cash:** $" .. (cash - amount) .. "\n**Bank:** $" .. (bank + amount),
                    ["footer"] = {
                        ["text"] = os.date('%d/%m/%Y %H:%M:%S', os.time())
                    },
                }
            }

            PerformHttpRequest(
                LOGS[type]["DISCORD_WEBHOOK"],
                function(err, text, headers) end,
                "POST",
                json.encode({
                    username = LOGS[type]["DISCORD_NAME"],
                    embeds = embed,
                    avatar_url = LOGS[type]["DISCORD_IMAGE"],
                }),
                {["Content-Type"] = "application/json"}
            )
        end,
    },
    ["withdraw"] = {
        ["DISCORD_WEBHOOK"] = "https://discord.com/api/webhooks/819704587002708048/oWac3UoA1Dm7sYQYyNpaX5Vt7AHMmPTCQwiF_B5BlI_t1rjiDro-lOcJWznNuWSqtoyb",
        ["DISCORD_NAME"] = "Bank Logs",
        ["DISCORD_IMAGE"] = "https://i.pinimg.com/736x/76/b5/9f/76b59f362b7f2d57bc6539b37cb54985.jpg",
        ["DISCORD_TITLE"] = "Withdraw",
        ["DISCORD_COLOR"] = 16711680,

        ["FUNCTION"] = function(type, src, amount, cash, bank, comment, uid)
            local char = exports["caue-base"]:getChar(src)
            if not char then return end

            local ids = GetIds(src)

            local embed = {
                {
                    ["color"] = LOGS[type]["DISCORD_COLOR"],
                    ["title"] = "**" .. char["first_name"] .. " " .. char["last_name"] .. "** withdraw **$" .. amount .. "**",
                    ["description"] = "**Transaction ID:** " .. uid .. "\n**Comment:** " .. comment .. "\n\n**Server ID:** " .. src .. "\n**Steam HEX:** " .. ids["hex"] .. "\n**Char ID:** " .. char["id"] .. "\n**Cash:** $" .. (cash + amount) .. "\n**Bank:** $" .. (bank - amount),
                    ["footer"] = {
                        ["text"] = os.date('%d/%m/%Y %H:%M:%S', os.time())
                    },
                }
            }

            PerformHttpRequest(
                LOGS[type]["DISCORD_WEBHOOK"],
                function(err, text, headers) end,
                "POST",
                json.encode({
                    username = LOGS[type]["DISCORD_NAME"],
                    embeds = embed,
                    avatar_url = LOGS[type]["DISCORD_IMAGE"],
                }),
                {["Content-Type"] = "application/json"}
            )
        end,
    },
    ["transfer"] = {
        ["DISCORD_WEBHOOK"] = "https://discord.com/api/webhooks/819704587002708048/oWac3UoA1Dm7sYQYyNpaX5Vt7AHMmPTCQwiF_B5BlI_t1rjiDro-lOcJWznNuWSqtoyb",
        ["DISCORD_NAME"] = "Bank Logs",
        ["DISCORD_IMAGE"] = "https://i.pinimg.com/736x/76/b5/9f/76b59f362b7f2d57bc6539b37cb54985.jpg",
        ["DISCORD_TITLE"] = "Transfer",
        ["DISCORD_COLOR"] = 36095,

        ["FUNCTION"] = function(type, src, to, tosid, amount, bank, comment, uid)
            local char = exports["caue-base"]:getChar(src)
            if not char then return end

            local ids = GetIds(src)

            local tochar = exports.ghmattimysql:executeSync([[
                SELECT hex, first_name, last_name, bank
                FROM characters
                WHERE id = ?
            ]],
            { to })[1]

            local embed = {
                {
                    ["color"] = LOGS[type]["DISCORD_COLOR"],
                    ["title"] = "**" .. char["first_name"] .. " " .. char["last_name"] .. "** transfer **$" .. amount .. "** to **" .. tochar["first_name"] .. " " .. tochar["last_name"] .. "**",
                    ["description"] = "**Transaction ID:** " .. uid .. "\n**Comment:** " .. comment .. "\n\n**Server ID:** " .. src .. "\n**Steam HEX:** " .. ids["hex"] .. "\n**Char ID:** " .. char["id"] .. "\n**Bank:** $" .. (bank - amount) .. "\n\n**Server ID:** " .. tosid .. "\n**Steam HEX:** " .. tochar["hex"] .. "\n**Char ID:** " .. to .. "\n**Bank:** $" .. tochar["bank"],
                    ["footer"] = {
                        ["text"] = os.date('%d/%m/%Y %H:%M:%S', os.time())
                    },
                }
            }

            PerformHttpRequest(
                LOGS[type]["DISCORD_WEBHOOK"],
                function(err, text, headers) end,
                "POST",
                json.encode({
                    username = LOGS[type]["DISCORD_NAME"],
                    embeds = embed,
                    avatar_url = LOGS[type]["DISCORD_IMAGE"],
                }),
                {["Content-Type"] = "application/json"}
            )
        end,
    },

    --[[

        Groups

    ]]
    ["groupDeposit"] = {
        ["DISCORD_WEBHOOK"] = "https://discord.com/api/webhooks/822493189901647884/In1JdCMBi7__7JsjBK90Y4exvyfvKdy7-rL8E0ojfirSk00NeuwXU6OBwO1UCtRb22tP",
        ["DISCORD_NAME"] = "Groups Logs",
        ["DISCORD_IMAGE"] = "https://i.pinimg.com/736x/76/b5/9f/76b59f362b7f2d57bc6539b37cb54985.jpg",
        ["DISCORD_TITLE"] = "Group Deposit",
        ["DISCORD_COLOR"] = 65280,

        ["FUNCTION"] = function(type, src, group, amount, uid)
            local char = exports["caue-base"]:getChar(src)
            if not char then return end

            local ids = GetIds(src)
            local bank = exports["caue-financials"]:getBalance(char["id"])
            local groupName = exports["caue-groups"]:groupName(group)
            local groupBank = exports["caue-groups"]:groupBank(group)

            local embed = {
                {
                    ["color"] = LOGS[type]["DISCORD_COLOR"],
                    ["title"] = "**" .. char["first_name"] .. " " .. char["last_name"] .. "** deposit **$" .. amount .. "** to **" .. groupName .. "**",
                    ["description"] = "**Transaction ID:** " .. uid .. "\n**Group Bank:** $" .. groupBank .. "\n\n**Server ID:** " .. src .. "\n**Steam HEX:** " .. ids["hex"] .. "\n**Char ID:** " .. char["id"] .. "\n**Bank:** $" .. bank,
                    ["footer"] = {
                        ["text"] = os.date('%d/%m/%Y %H:%M:%S', os.time())
                    },
                }
            }

            PerformHttpRequest(
                LOGS[type]["DISCORD_WEBHOOK"],
                function(err, text, headers) end,
                "POST",
                json.encode({
                    username = LOGS[type]["DISCORD_NAME"],
                    embeds = embed,
                    avatar_url = LOGS[type]["DISCORD_IMAGE"],
                }),
                {["Content-Type"] = "application/json"}
            )
        end,
    },
    ["groupWithdraw"] = {
        ["DISCORD_WEBHOOK"] = "https://discord.com/api/webhooks/822493189901647884/In1JdCMBi7__7JsjBK90Y4exvyfvKdy7-rL8E0ojfirSk00NeuwXU6OBwO1UCtRb22tP",
        ["DISCORD_NAME"] = "Groups Logs",
        ["DISCORD_IMAGE"] = "https://i.pinimg.com/736x/76/b5/9f/76b59f362b7f2d57bc6539b37cb54985.jpg",
        ["DISCORD_TITLE"] = "Group Withdraw",
        ["DISCORD_COLOR"] = 16711680,

        ["FUNCTION"] = function(type, src, group, amount, uid)
            local char = exports["caue-base"]:getChar(src)
            if not char then return end

            local ids = GetIds(src)
            local accountId = exports["caue-base"]:getChar(src, "bankid")
            local bank = exports["caue-financials"]:getBalance(accountId)
            local groupName = exports["caue-groups"]:groupName(group)
            local groupBank = exports["caue-groups"]:groupBank(group)

            local embed = {
                {
                    ["color"] = LOGS[type]["DISCORD_COLOR"],
                    ["title"] = "**" .. char["first_name"] .. " " .. char["last_name"] .. "** withdraw **$" .. amount .. "** from **" .. groupName .. "**",
                    ["description"] = "**Transaction ID:** " .. uid .. "\n**Group Bank:** $" .. groupBank .. "\n\n**Server ID:** " .. src .. "\n**Steam HEX:** " .. ids["hex"] .. "\n**Char ID:** " .. char["id"] .. "\n**Bank:** $" .. bank,
                    ["footer"] = {
                        ["text"] = os.date('%d/%m/%Y %H:%M:%S', os.time())
                    },
                }
            }

            PerformHttpRequest(
                LOGS[type]["DISCORD_WEBHOOK"],
                function(err, text, headers) end,
                "POST",
                json.encode({
                    username = LOGS[type]["DISCORD_NAME"],
                    embeds = embed,
                    avatar_url = LOGS[type]["DISCORD_IMAGE"],
                }),
                {["Content-Type"] = "application/json"}
            )
        end,
    },
    ["groupRank"] = {
        ["DISCORD_WEBHOOK"] = "https://discord.com/api/webhooks/822493189901647884/In1JdCMBi7__7JsjBK90Y4exvyfvKdy7-rL8E0ojfirSk00NeuwXU6OBwO1UCtRb22tP",
        ["DISCORD_NAME"] = "Groups Logs",
        ["DISCORD_IMAGE"] = "https://i.pinimg.com/736x/76/b5/9f/76b59f362b7f2d57bc6539b37cb54985.jpg",
        ["DISCORD_TITLE"] = "Changed Rank",
        ["DISCORD_COLOR"] = 36095,

        ["FUNCTION"] = function(type, src, giverrank, to, tosid, currentrank, rank, group)
            local char = exports["caue-base"]:getChar(src)
            if not char then return end

            local ids = GetIds(src)

            local tochar = exports.ghmattimysql:executeSync([[
                SELECT hex, first_name, last_name
                FROM characters
                WHERE id = ?
            ]],
            { to })[1]

            local groupName = exports["caue-groups"]:groupName(group)

            local embed = {
                {
                    ["color"] = LOGS[type]["DISCORD_COLOR"],
                    ["title"] = "**" .. char["first_name"] .. " " .. char["last_name"] .. "** change **" .. tochar["first_name"] .. " " .. tochar["last_name"] .. "** rank to **" .. rank .. "**",
                    ["description"] = "**Group:** " .. groupName .. "\n**Giver Rank:** " .. giverrank .. "\n**Old Rank:** " .. currentrank .. "\n\n**Server ID:** " .. src .. "\n**Steam HEX:** " .. ids["hex"] .. "\n**Char ID:** " .. char["id"] .. "\n\n**Server ID:** " .. tosid .. "\n**Steam HEX:** " .. tochar["hex"] .. "\n**Char ID:** " .. to,
                    ["footer"] = {
                        ["text"] = os.date('%d/%m/%Y %H:%M:%S', os.time())
                    },
                }
            }

            PerformHttpRequest(
                LOGS[type]["DISCORD_WEBHOOK"],
                function(err, text, headers) end,
                "POST",
                json.encode({
                    username = LOGS[type]["DISCORD_NAME"],
                    embeds = embed,
                    avatar_url = LOGS[type]["DISCORD_IMAGE"],
                }),
                {["Content-Type"] = "application/json"}
            )
        end,
    },

    --[[

        Vehicle Shops

    ]]
    ["vehicleShop"] = {
        ["DISCORD_WEBHOOK"] = "https://discord.com/api/webhooks/829478015628869682/sDg3rvgXc3HVQOfvTIO8UHEoieW33YceoHyYLoSbZuKpU2uVzpsnoPDIvIf-osemWdDM",
        ["DISCORD_NAME"] = "Vehicle Shop Logs",
        ["DISCORD_IMAGE"] = "https://i.pinimg.com/736x/76/b5/9f/76b59f362b7f2d57bc6539b37cb54985.jpg",
        ["DISCORD_TITLE"] = "Vehicle Shop",
        ["DISCORD_COLOR"] = 65280,

        ["FUNCTION"] = function(type, vid, model, price, financed, commission, tax, shop, buyer, seller)
            local embed = {
                {
                    ["color"] = LOGS[type]["DISCORD_COLOR"],
                    ["title"] = "**" .. buyer .. "** buyed **" .. model .. "**",
                    ["description"] = "**Vehicle ID:** " .. vid .. "\n**Price:** $" .. price .. "\n**Financed:** " .. financed .. "\n**Shop:** " .. shop .. "\n**Tax:** $" .. tax .. "\n**Seller:** " .. seller .. "\n**Commission:** $" .. commission,
                    ["footer"] = {
                        ["text"] = os.date('%d/%m/%Y %H:%M:%S', os.time())
                    },
                }
            }

            PerformHttpRequest(
                LOGS[type]["DISCORD_WEBHOOK"],
                function(err, text, headers) end,
                "POST",
                json.encode({
                    username = LOGS[type]["DISCORD_NAME"],
                    embeds = embed,
                    avatar_url = LOGS[type]["DISCORD_IMAGE"],
                }),
                {["Content-Type"] = "application/json"}
            )
        end,
    },
}
