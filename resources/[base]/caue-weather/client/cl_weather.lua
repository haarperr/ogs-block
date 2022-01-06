--[[

    Variables

]]

local synctime = {}
local secondOfDay = 31800
local inhouse = false
local daytime = true
local primetime = false
local lunchtime = false
local cracktime = false
local cocainetime = false
local robbing = false
local enableSync = true
local insidebuilding = false
local insideSpawn = false
local inhotel = false
local oldweather = "none"
local weatherTimer = 0
local lastminute = 0
local curWeather = "CLEAR"

--[[

    Functions

]]

function SetWeather()
	local coordsply = GetEntityCoords(PlayerPedId())

	if robbing or insidebuilding or inhotel or inhouse then
		NetworkOverrideClockTime(23, 0, 0)
		TriggerEvent("inside:weather", true)
	end

	if insideSpawn then
		NetworkOverrideClockTime(12, 0, 0)
	end

	if (robbing or insidebuilding or inhouse or insideSpawn) then
        ClearOverrideWeather()
        ClearWeatherTypePersist()
        SetWeatherTypePersist("CLEAR")
        SetWeatherTypeNow("CLEAR")
        SetWeatherTypeNowPersist("CLEAR")
		weatherTimer = 22000
	end

	if (coordsply["z"] < -30 and not insidebuilding and not robbing) or inhotel or inhouse or insideSpawn then
		insidebuilding = true
        ClearOverrideWeather()
        ClearWeatherTypePersist()
        SetWeatherTypePersist("CLEAR")
        SetWeatherTypeNow("CLEAR")
        SetWeatherTypeNowPersist("CLEAR")
        weatherTimer = 22000
        waitSet = true
	else
		if curWeather ~= oldweather or (insidebuilding and coordsply["z"] > -29) then
			SetWeatherTypeOverTime(curWeather, 120.0)
			weatherTimer = 55000
			oldweather = curWeather
			insidebuilding = false
		end

		weatherTimer = weatherTimer - 1

		if weatherTimer < 0 and curWeather == oldweather then
			TriggerEvent("inside:weather",false)
			weatherTimer = 60000
      		ClearOverrideWeather()
      		ClearWeatherTypePersist()
      		SetWeatherTypePersist(curWeather)
      		SetWeatherTypeNow(curWeather)
      		SetWeatherTypeNowPersist(curWeather)
		elseif weatherTimer < 0 and (insidebuilding or robbing or inhouse or insideSpawn) then
			weatherTimer = 10000
      		ClearOverrideWeather()
      		ClearWeatherTypePersist()
      		SetWeatherTypePersist("CLEAR")
      		SetWeatherTypeNow("CLEAR")
      		SetWeatherTypeNowPersist("CLEAR")
		end
	end
end

function SetTimeSync()
	local coordsply = GetEntityCoords(PlayerPedId())

	synctime.h = math.floor(secondOfDay / 3600)
	synctime.m = math.floor((secondOfDay - (synctime.h * 3600)) / 60)
	synctime.s = secondOfDay - (synctime.h * 3600) - (synctime.m * 60)

	if (synctime.h > 19 or synctime.h < 7) and daytime then
		daytime = false
		TriggerEvent("daytime",daytime)
	elseif (synctime.h <= 19 and synctime.h >= 7) and not daytime then
		daytime = true
		TriggerEvent("daytime",daytime)
	end

	if (synctime.h > 9 or synctime.h < 17) and not lunchtime then
		lunchtime = true
		TriggerEvent("lunchtime",lunchtime)
	elseif (synctime.h <= 9 and synctime.h >= 17) and lunchtime then
		lunchtime = false
		TriggerEvent("lunchtime",lunchtime)
	end

	if (synctime.h > 21 or synctime.h < 23) and not cocainetime then
		cocainetime = true
		TriggerEvent("cocainetime",cocainetime)
	elseif (synctime.h <= 21 and synctime.h >= 23) and cocainetime then
		cocainetime = false
		TriggerEvent("cocainetime",cocainetime)
	end

	if (synctime.h > 6 or synctime.h < 10) and not cracktime then
		cracktime = true
		TriggerEvent("cracktime",cracktime)
	elseif (synctime.h <= 6 and synctime.h >= 10) and cracktime then
		cracktime = false
		TriggerEvent("cracktime",cracktime)
	end

	if (synctime.h > 15 or synctime.h < 23) and primetime then
		primetime = false
		TriggerEvent("primetime",primetime)
	elseif (synctime.h <= 15 and synctime.h >= 23) and not primetime then
		primetime = true
		TriggerEvent("primetime",primetime)
  	end

  	if synctime.m ~= lastminute then
    	lastminute = synctime.m
    	TriggerEvent("timeheader",synctime.h,synctime.m)
  	end
end

function SetEnableSync(enable)
	if enable == nil then
		enable = not noSync
	end

	enableSync = enable
end

--[[

    Exports

]]

exports("SetEnableSync", SetEnableSync)

--[[

    Events

]]

RegisterNetEvent("kTimeSync")
AddEventHandler("kTimeSync", function(data)
	if not enableSync then return end

	secondOfDay = data
	weatherTimer = 0
end)

RegisterNetEvent("kWeatherSync")
AddEventHandler("kWeatherSync", function(wfer)
	curWeather = wfer
end)

RegisterNetEvent("kWeatherSyncForce")
AddEventHandler("kWeatherSyncForce", function(wfer)
	curWeather = wfer
	weatherTimer = -99
	SetWeather()
end)

RegisterNetEvent("weather:blackout")
AddEventHandler("weather:blackout", function(blackout)
	SetBlackout(blackout)
end)

RegisterNetEvent("weather:setCycle")
AddEventHandler("weather:setCycle", function(cycle)
    SetTimecycleModifier(cycle)
end)

RegisterNetEvent("robbing")
AddEventHandler("robbing", function(status)
	robbing = status
end)

RegisterNetEvent("inhouse")
AddEventHandler("inhouse", function(status)
	inhouse = status
end)

RegisterNetEvent("inhotel")
AddEventHandler("inhotel", function(status)
	inhotel = status
end)

RegisterNetEvent("inSpawn")
AddEventHandler("inSpawn", function(status)
	insideSpawn = status
end)

--[[

    Threads

]]

Citizen.CreateThread(function()
    while true do
        if robbing then
        	SetPedDensityMultiplierThisFrame(0.0)
      	end

		Citizen.Wait(0)
    end
end)

Citizen.CreateThread( function()
	local timeBuffer = 0.0

	while true do
		Wait(1000)

		SetWeather()
		SetTimeSync()

		local gameSecond = 10

		timeBuffer = timeBuffer + round( 100.0 / gameSecond, 0 )
		if timeBuffer >= 1.0 then
			local skipSeconds = math.floor( timeBuffer )

			timeBuffer = timeBuffer - skipSeconds
			secondOfDay = secondOfDay + skipSeconds

			if secondOfDay >= 86400 then
				secondOfDay = secondOfDay % 86400
			end
		end

		synctime.h = math.floor( secondOfDay / 3600 )
		synctime.m = math.floor( (secondOfDay - (synctime.h * 3600)) / 60 )
		synctime.s = secondOfDay - (synctime.h * 3600) - (synctime.m * 60)

		if enableSync and not insidebuilding and not inhotel and not robbing and not inhouse and not insideSpawn then
			NetworkOverrideClockTime(synctime.h, synctime.m, synctime.s)
		end
	end
end)