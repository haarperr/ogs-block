--[[

    Variables

]]

local whitelistTags = {
    "924862182187995156", -- Dev
    "925760894380703825", -- Staff
    -- "925237446986301450", -- Insider
}

--[[

    Functions

]]

function haveWhitelist(src)
    local ids = GetIds(src)

    if not ids.discord then
        return false, "discord id not found"
    end

    local discordid = string.sub(ids.discord, 9)

    local user = DiscordRequest("GET", "guilds/" .. Config["BOT_GUILDID"] .. "/members/" .. discordid, {})

    if not user.data then
        return false, "user data not found"
    end

    local userdata = json.decode(user.data)

    if not userdata.roles then
        return false, "user roles not found"
    end

    for i, v in pairs(userdata.roles) do
        if has_value(whitelistTags, v) then
            return true, "have whitelist"
        end
    end

    return false, "dont have whitelist"
end

--[[

    Exports

]]

exports("haveWhitelist", haveWhitelist)