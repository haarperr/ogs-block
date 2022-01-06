Commands["playercount"] = {
    ["DISCORD_IDS"] = { "228659194771800065" },
    ["FUNCTION"] = function(params, author)
        sendToDiscord("Player Counts", "Current players in server : " .. GetNumPlayerIndices(), 4620980)
    end,
}