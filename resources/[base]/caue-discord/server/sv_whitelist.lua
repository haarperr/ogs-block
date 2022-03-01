--[[

    Variables

]]

local developers = {
    "228659194771800065",
    "578438412936151040",
    "380119446674604032",
}

local hexWhitelist = {
    "steam:1100001120b094c",
}

--[[

    Functions

]]

function haveWhitelist(src)
    local ids = GetIds(src)

    if not ids.discord then
        if GetConvar("sv_environment", "live") == "live" and has_value(hexWhitelist, ids.hex) then
            return true, ""
        end

        return false, "discord id not found"
    end

    local discordid = string.sub(ids.discord, 9)

    if has_value(developers, discordid) then
        return true, ""
    end

    if GetConvar("sv_environment", "live") == "debug" then
        return false, "devserver"
    end

    local user = DiscordRequest("GET", "guilds/" .. Config["BOT_GUILDID"] .. "/members/" .. discordid, {})

    if not user.data then
        return false, "user data not found"
    end

    local userdata = json.decode(user.data)

    if not userdata.roles then
        return false, "user roles not found"
    end

    local whitelistTags = exports.ghmattimysql:scalarSync([[
        SELECT value
        FROM variables
        WHERE name = "whitelist_tags"
    ]])

    for i, v in pairs(userdata.roles) do
        if has_value(json.decode(whitelistTags), v) then
            return true, ""
        end
    end

    return false, "dont have whitelist"
end

--[[

    Exports

]]

exports("haveWhitelist", haveWhitelist)