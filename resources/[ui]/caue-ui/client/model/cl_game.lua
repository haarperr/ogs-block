--[[

    Variables

]]

local charSpawned = false

--[[

    Functions

]]

function getCharacterInfo()
    local characterId = exports["caue-base"]:getChar("id")
    local firstName = exports["caue-base"]:getChar("first_name")
    local lastName = exports["caue-base"]:getChar("last_name")
    local phoneNumber = exports["caue-base"]:getChar("phone")

    return characterId, firstName, lastName, phoneNumber
end

function sendCharacterData()
    Citizen.CreateThread(function()
        local characterId, firstName, lastName, phoneNumber = getCharacterInfo()

        if not characterId then return end

        -- local hasBankAccount, bankAccountId = RPC.execute("GetDefaultBankAccount", characterId, true)
        local character = {
            id = characterId,
            first_name = firstName,
            job = "",
            last_name = lastName,
            number = tostring(phoneNumber),
            bank_account_id = 1,
            server_id = GetPlayerServerId(PlayerId()) -- in game session id
        }
        SendUIMessage({ source = "np-nui", app = "character", data = character });

        Citizen.Wait(5000)

        TriggerEvent("np-ui:phoneReady")
        TriggerServerEvent("np-ui:phoneReady")
    end)
end

function getWeatherIcon(pWeather)
    if pWeather == "EXTRASUNNY" or pWeather == "CLEAR" then
        return "sun"
    elseif pWeather == "THUNDER" then
        return "poo-storm"
    elseif pWeather == "CLEARING" or pWeather == "OVERCAST" then
        return "cloud-sun-rain"
    elseif pWeather == "CLOUD" then
        return "cloud"
    elseif pWeather == "RAIN" then
        return "cloud-rain"
    elseif pWeather == "SMOG" or pWeather == "FOGGY" then
        return "smog"
    end
end

--[[

    Events

]]

RegisterNetEvent("SpawnEventsClient")
AddEventHandler("SpawnEventsClient", function()
    charSpawned = true

    Citizen.CreateThread(function()
        DisplayRadar(0)
        SetRadarBigmapEnabled(true, false)

        Citizen.Wait(0)

        SetRadarBigmapEnabled(false, false)
        DisplayRadar(0)

        Citizen.Wait(0)

        sendAppEvent("hud", { display = true })
        startHealthArmorUpdates()
    end)
end)

RegisterNetEvent("timeheader")
AddEventHandler("timeheader", function(pHour, pMinutes)
    setGameValue("time", ("%s:%s"):format(pHour > 9 and pHour or "0" .. pHour, pMinutes > 9 and pMinutes or "0" .. pMinutes))
end)

RegisterNetEvent("kWeatherSync")
AddEventHandler("kWeatherSync", function(pWeather)
    setGameValue("weather", pWeather)
    setGameValue("weatherIcon", getWeatherIcon(pWeather))
end)

--[[

    Threads

]]

Citizen.CreateThread(function()
    while not charSpawned do
        DisplayRadar(0)
        Citizen.Wait(0)
    end
end)