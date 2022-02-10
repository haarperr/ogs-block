local Keys = {
    ["num4"] = 108,
    ["num5"] = 110,
    ["num6"] = 109,
    ["num7"] = 117,
    ["num8"] = 111,
    ["num9"] = 118,
}

local KeysEmotes = {
    ["num4"] = "",
    ["num5"] = "",
    ["num6"] = "",
    ["num7"] = "",
    ["num8"] = "",
    ["num9"] = "",
}

-----------------------------------------------------------------------------------------------------
-- Commands / Events --------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------

Citizen.CreateThread(function()
    while true do
        if not IsPedSittingInAnyVehicle(PlayerPedId()) then
            for k, v in pairs(Keys) do
                if IsControlJustReleased(0, v) then
                    if KeysEmotes[k] ~= "" then
                        EmoteCommandStart(nil,{KeysEmotes[k], 0})
                    end

                    Citizen.Wait(1000)
                end
            end
        end

        Citizen.Wait(1)
    end
end)

RegisterNetEvent("emote:setEmotesFromDB")
AddEventHandler("emote:setEmotesFromDB", function(pEmotes)
    if pEmotes and pEmotes[1] then
        for k, v in pairs(pEmotes) do
            KeysEmotes[k] = v
        end
    end
end)

-----------------------------------------------------------------------------------------------------
------ Functions and stuff --------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------

function EmoteBindsStart()
    TriggerEvent("chatMessage", "EMOTES: ", {0, 255, 204}, "Currently bound emotes:".."\n"
        ..firstToUpper("num4").." = '^2"..KeysEmotes["num4"].."^7'\n"
        ..firstToUpper("num5").." = '^2"..KeysEmotes["num5"].."^7'\n"
        ..firstToUpper("num6").." = '^2"..KeysEmotes["num6"].."^7'\n"
        ..firstToUpper("num7").." = '^2"..KeysEmotes["num7"].."^7'\n"
        ..firstToUpper("num8").." = '^2"..KeysEmotes["num8"].."^7'\n"
        ..firstToUpper("num9").." = '^2"..KeysEmotes["num9"].."^7'\n")
end

function EmoteBindStart(source, args, raw)
    if #args > 0 then
        local key = string.lower(args[1])
        local emote = string.lower(args[2])

        if Keys[key] ~= nil then
        	if DP.Emotes[emote] ~= nil or DP.Dances[emote] ~= nil or DP.PropEmotes[emote] ~= nil then
                KeysEmotes[key] = emote
                TriggerServerEvent("caue-emotes:setEmoteData", KeysEmotes)
                TriggerEvent("DoLongHudText", "Bound " .. emote .. " to " .. firstToUpper(key))
        	else
                TriggerEvent("DoLongHudText", emote .. " is not a valid emote.", 2)
        	end
        else
            TriggerEvent("DoLongHudText", key .. " is not a valid key.", 2)
        end
    end
end