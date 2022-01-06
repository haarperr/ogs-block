--[[

    Variables

]]

local inVehicle = false
local engineOn = false
local minimapEnabled = true
local wasMinimapEnabled = true
local showCompassFromCar = false
local compassRoadNamesEnabled = true
local runningRoadNames = false
local area = ""
local street = ""
local fuel = 0
local speed = 0
local compassRunning = false
local showCompassFromWatch = false
local compassEnabled = true
local compassWaitTime = 32
local speedometerWaitTime = 64
local speedoRunning = false
local seatbelt = false

local imageWidth = 100 -- leave this variable, related to pixel size of the directions
local width =  0
local south = (-imageWidth) + width
local west = (-imageWidth * 2) + width
local north = (-imageWidth * 3) + width
local east = (-imageWidth * 4) + width
local south2 = (-imageWidth * 5) + width

--[[

    Functions

]]

function getFuel(veh)
    fuel = exports["caue-vehicles"]:GetVehicleFuel(veh) or 0
end

function calcHeading(direction)
    if (direction < 90) then
        return lerp(north, east, direction / 90)
    elseif (direction < 180) then
        return lerp(east, south2, rangePercent(90, 180, direction))
    elseif (direction < 270) then
        return lerp(south, west, rangePercent(180, 270, direction))
    elseif (direction <= 360) then
        return lerp(west, north, rangePercent(270, 360, direction))
    end
end

function rangePercent(min, max, amt)
    return (((amt - min) * 100) / (max - min)) / 100
end

function lerp(min, max, amt)
    return (1 - amt) * min + amt * max
end

function roundedRadar()
    if not inVehicle then
        DisplayRadar(0)
        SetRadarBigmapEnabled(true, false)
        Citizen.Wait(0)
        SetRadarBigmapEnabled(false, false)
        return
    end

    Citizen.CreateThread(function()
        RequestStreamedTextureDict("circlemap", false)
        while not HasStreamedTextureDictLoaded("circlemap") do
            Citizen.Wait(0)
        end
        AddReplaceTexture("platform:/textures/graphics", "radarmasksm", "circlemap", "radarmasksm")

        SetBlipAlpha(GetNorthRadarBlip(), 0.0)
        SetBlipScale(GetMainPlayerBlipId(), 0.7)

        SetMinimapComponentPosition("minimap", "L", "B", -0.01, -0.050, 0.12, 0.19)
        SetMinimapComponentPosition("minimap_mask", "L", "B", -0.017, 0.014, 1.203, 0.305)
        SetMinimapComponentPosition("minimap_blur", "L", "B", -0.015, 0.020, 0.200, 0.295)

        SetMinimapClipType(1)
        DisplayRadar(0)
        SetRadarBigmapEnabled(true, false)
        Citizen.Wait(0)
        SetRadarBigmapEnabled(false, false)
        DisplayRadar(1)
    end)
end

function generateRoadNames()
    if not compassRoadNamesEnabled or runningRoadNames then return end

    Citizen.CreateThread(function()
        runningRoadNames = true

        while compassRoadNamesEnabled and inVehicle do
            Citizen.Wait(500)

            local playerCoords = GetEntityCoords(PlayerPedId(), true)
            local currentStreetHash, intersectStreetHash = GetStreetNameAtCoord(playerCoords.x, playerCoords.y, playerCoords.z, currentStreetHash, intersectStreetHash)
            currentStreetName = GetStreetNameFromHashKey(currentStreetHash)
            intersectStreetName = GetStreetNameFromHashKey(intersectStreetHash)
            zone = tostring(GetNameOfZone(playerCoords))
            area = GetLabelText(zone)

            if area == "Fort Zancudo" then
                area = "Williamsburg"
            end

            if intersectStreetName ~= nil and intersectStreetName ~= "" then
                playerStreetsLocation = currentStreetName .. " [" .. intersectStreetName .. "]"
            elseif currentStreetName ~= nil and currentStreetName ~= "" then
                playerStreetsLocation = currentStreetName
            else
                playerStreetsLocation = ""
            end

            street = playerStreetsLocation
        end

        runningRoadNames = false
    end)
end

function generateCompass()
    if compassRunning then return end

    compassRunning = true

    Citizen.CreateThread(function()
        local function shouldShowCompass()
            return showCompassFromWatch or (compassEnabled and showCompassFromCar)
        end

        local function shouldShowSpeed()
            return inVehicle and minimapEnabled
        end

        while shouldShowCompass() or shouldShowSpeed() do
            local cWait = shouldShowCompass() and compassWaitTime or 1000
            local sWait = shouldShowSpeed() and speedometerWaitTime or 1000
            Citizen.Wait(math.min(cWait, sWait))
            local s = GetGameTimer()
            local direction = math.floor(calcHeading(-GetGameplayCamRot().z % 360))

            SendNUIMessage({
                action = "vehicle",
                street = street,
                direction = direction,
                district = area,
                speed = speed,
            })
        end

        compassRunning = false
    end)
end

function generateSpeedo()
    if speedoRunning then return end
    speedoRunning = true

    local veh = GetVehiclePedIsIn(PlayerPedId(), false)

    getFuel(veh)

    local altitude = false
    local engineDamageShow = false
    local gasDamageShow = false

    Citizen.CreateThread(function()
        while engineOn do
            SendNUIMessage({
                action = "vehiclemisc",
                fuel = fuel,
                seatbelt = seatbelt,
            })

            Citizen.Wait(500)
        end

        speedoRunning = false
    end)

    Citizen.CreateThread(function()
        while engineOn do
            if GetVehicleEngineHealth(veh) < 400.0 then
                engineDamageShow = true
            end

            if GetVehiclePetrolTankHealth(veh) < 3002.0 then
                gasDamageShow = true
            end

            if GetPedInVehicleSeat(veh, -1) == PlayerPedId() then
                harnessDurability = exports["caue-vehicles"]:GetVehicleMetadata(veh, "harness")
            end

            getFuel(veh)

            Citizen.Wait(10000)
        end
    end)

    Citizen.CreateThread(function()
        while engineOn do
            speed = math.ceil(GetEntitySpeed(veh) * 2.236936)
            Citizen.Wait(speedometerWaitTime)
        end
    end)
end

--[[

    Events

]]

AddEventHandler("seatbelt", function(toggle)
	seatbelt = toggle
end)

--[[

    Threads

]]

Citizen.CreateThread(function()
    roundedRadar()

    while true do
        local veh = GetVehiclePedIsIn(PlayerPedId(), false)

        if veh ~= 0 and not inVehicle then
            inVehicle = true
        elseif veh == 0 and inVehicle then
            inVehicle = false
        end

        local eon = IsVehicleEngineOn(veh)
        if eon and not engineOn then
            engineOn = true
            showCompassFromCar = true

            generateSpeedo()
            generateCompass()
            generateRoadNames()

            roundedRadar()

            SendNUIMessage({
                vehicleUi = true,
            })
        elseif not eon and engineOn then
            engineOn = false
            showCompassFromCar = false

            SendNUIMessage({
                vehicleUi = false,
            })

            Citizen.Wait(32)
            DisplayRadar(0)
        elseif wasMinimapEnabled ~= minimapEnabled then
            wasMinimapEnabled = minimapEnabled
            roundedRadar()
        end

        Citizen.Wait(250)
    end
end)