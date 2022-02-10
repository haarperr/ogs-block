Citizen.CreateThread(function()
	while true do
		SetDiscordAppId(940695263415271484)

        local first_name = exports["caue-base"]:getChar("first_name")
        local last_name = exports["caue-base"]:getChar("last_name")

        if first_name then
            SetRichPresence("Jogando com " .. first_name .. " " .. last_name)
        end

        SetDiscordRichPresenceAsset("ogsblock")
        SetDiscordRichPresenceAssetText("https://ogsblock.com.br/")
        SetDiscordRichPresenceAssetSmall("ogsblock")
        SetDiscordRichPresenceAssetSmallText("https://ogsblock.com.br/")
        SetDiscordRichPresenceAction(0, "Discord", "https://discord.gg/AA8wpqMZER")
        SetDiscordRichPresenceAction(1, "Forum", "https://ogsblock.com.br/")

		Citizen.Wait(60000)
	end
end)