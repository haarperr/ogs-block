--[[

    Variables

]]

local currentWeather = "CLEAR"
local secondOfDay = 31800

--[[

    Events

]]

RegisterNetEvent("caue-base:sessionStarted")
AddEventHandler("caue-base:sessionStarted", function()
    local src = source

    Citizen.Wait(1000)

    TriggerClientEvent("kTimeSync", -1, secondOfDay)
	TriggerClientEvent("kWeatherSync", -1, currentWeather)
end)

RegisterNetEvent("weather:time")
AddEventHandler("weather:time", function(src, time)
    secondOfDay = tonumber(time) * 3600

	TriggerClientEvent("kTimeSync", -1, secondOfDay)
end)

RegisterNetEvent("weather:setWeather")
AddEventHandler("weather:setWeather", function(src, weather)
    currentWeather = tostring(weather)

    TriggerClientEvent("kWeatherSync", -1, currentWeather)
end)

--[[

    Threads

]]

Citizen.CreateThread( function()
	local timeBuffer = 0.0
    local gameSecond = 10

	while true do
		Citizen.Wait(1000)

		timeBuffer = timeBuffer + round( 100.0 / gameSecond, 0 )
		if timeBuffer >= 1.0 then
			local skipSeconds = math.floor(timeBuffer)

			timeBuffer = timeBuffer - skipSeconds
			secondOfDay = secondOfDay + skipSeconds

			if secondOfDay >= 86400 then
				secondOfDay = secondOfDay % 86400
			end
		end
	end
end)

Citizen.CreateThread(function()
	while true do
		Citizen.Wait(20 * 60000)

		if CurrentWeather == "CLEAR" or CurrentWeather == "EXTRASUNNY" then
			if math.random(100) > 70 then
				CurrentWeather = "CLOUDS"
			else
				CurrentWeather = "EXTRASUNNY"
			end
		elseif CurrentWeather == "CLOUDS" then
			local weathers = {"CLEARING", "OVERCAST"}
			CurrentWeather = weathers[math.random(#weathers)]
		elseif CurrentWeather == "CLEARING" then
			CurrentWeather = "FOGGY"
		elseif CurrentWeather == "OVERCAST" then
			local weathers = {"RAIN", "SMOG", "THUNDER"}
			CurrentWeather = weathers[math.random(#weathers)]
		elseif CurrentWeather == "FOGGY" or CurrentWeather == "SMOG" then
			CurrentWeather = "CLEAR"
		elseif CurrentWeather == "THUNDER" or CurrentWeather == "RAIN" then
			CurrentWeather = "CLEARING"
		end

		TriggerClientEvent("kWeatherSync", -1, CurrentWeather)
	end
end)