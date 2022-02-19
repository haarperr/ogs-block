if Framework.STANDALONE then
    ShowNotification = function(source, text)
        TriggerClientEvent("DoLongHudText", source, text)
    end
end