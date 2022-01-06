--[[

    Variables

]]

local compassEnabled = true
local compassRoadNamesEnabled = true
local compassWaitTime = 16
local speedometerWaitTime = 64
local showCompassFromWatch = false
local showCompassFromCar = false
local minimapEnabled = true
local wasMinimapEnabled = true

local inVehicle = false
local engineOn = false
local isDead = false
local area = ""
local street = ""
local runningRoadNames = false
local compassRunning = false
local fuel = 0
local speed = 0

local cmdsSet = {}

local beltShow = false
local harnessDurability = 0
local nos = 0
local nosEnabled = false
local speedoRunning = false

local startedHealthArmorUpdates = false
local pauseActive = false

--[[

    Functions

]]

local function toggleCompass()
    sendAppEvent("hud.compass", {
        showCompass = showCompassFromWatch or (compassEnabled and showCompassFromCar),
        showRoadNames = compassRoadNamesEnabled and inVehicle,
    })
end

function roundedRadar()
    if not minimapEnabled or not inVehicle then
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
        AddReplaceTexture("platform:/textures/graphics", "radarmasksm", "circlemap", "radarmasklg")
        AddReplaceTexture("platform:/textures/graphics", "radarmasklg", "circlemap", "radarmasklg")

        SetBlipAlpha(GetNorthRadarBlip(), 0.0)
        -- SetBlipScale(GetMainPlayerBlipId(), 0.7)
        -- for k,v in pairs(exports["np-base"]:getModule("Blips")) do
        --     SetBlipScale(v["blip"], 0.7)
        -- end

        local screenX, screenY = GetScreenResolution()
        local modifier = screenY / screenX

        local baseXOffset = 0.0046875
        local baseYOffset = 0.74

        local baseSize    = 0.20 -- 20% of screen

        local baseXWidth  = 0.1313 -- baseSize * modifier -- %
        local baseYHeight = baseSize -- %

        local baseXNumber = screenX * baseSize  -- 256
        local baseYNumber = screenY * baseSize  -- 144

        local radiusX     = baseXNumber / 2     -- 128
        local radiusY     = baseYNumber / 2     -- 72

        local innerSquareSideSizeX = math.sqrt(radiusX * radiusX * 2) -- 181.0193
        local innerSquareSideSizeY = math.sqrt(radiusY * radiusY * 2) -- 101.8233

        local innerSizeX = ((innerSquareSideSizeX / screenX) - 0.01) * modifier
        local innerSizeY = innerSquareSideSizeY / screenY

        local innerOffsetX = (baseXWidth - innerSizeX) / 2
        local innerOffsetY = (baseYHeight - innerSizeY) / 2

        local innerMaskOffsetPercentX = (innerSquareSideSizeX / baseXNumber) * modifier

        local function setPos(type, posX, posY, sizeX, sizeY)
            SetMinimapComponentPosition(type, "I", "I", posX, posY, sizeX, sizeY)
        end
        setPos("minimap",       baseXOffset - (0.025 * modifier), baseYOffset - 0.025, baseXWidth + (0.05 * modifier), baseYHeight + 0.05)
        setPos("minimap_blur",  baseXOffset, baseYOffset, baseXWidth + 0.001, baseYHeight)
        -- setPos("minimap_mask",  baseXOffset + innerOffsetX, baseYOffset + innerOffsetY, innerSizeX, innerSizeY)
        -- The next one is FUCKING WEIRD.
        -- posX is based off top left 0.0 coords of minimap - 0.00 -> 1.00
        -- posY seems to be based off of the top of the minimap, with 0.75 representing 0% and 1.75 representing 100%
        -- sizeX is based off the size of the minimap - 0.00 -> 0.10
        -- sizeY seems to be height based on minimap size, ranging from -0.25 to 0.25
        setPos("minimap_mask", 0.1, 0.95, 0.09, 0.15)
        -- setPos("minimap_mask", 0.0, 0.75, 1.0, 1.0)
        -- setPos("minimap_mask",  baseXOffset, baseYOffset, baseXWidth, baseYHeight)

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
            local heading = math.floor(-GetFinalRenderedCamRot(0).z % 360)

            sendAppEvent("hud.compass", {
                area = area,
                heading = heading,
                speed = speed,
                street = street,
            })

        end
        compassRunning = false
    end)
end

function getFuel()
    fuel = exports["np-vehicles"]:CurrentFuel() or 0
end

function generateSpeedo()
    makeHudDirty()
    if speedoRunning then return end
    speedoRunning = true
    local veh = GetVehiclePedIsIn(PlayerPedId(), false)
    local flyer = IsPedInAnyPlane(PlayerPedId()) or IsPedInAnyHeli(PlayerPedId())

    getFuel(veh)

    local altitude = false
    local engineDamageShow = false
    local gasDamageShow = false

    Citizen.CreateThread(function()
        while engineOn do
            if flyer then
                altitude = math.floor(GetEntityHeightAboveGround(veh) * 3.28084)
            end
            setHudValue("altitude", altitude)
            setHudValue("altitudeShow", altitude ~= false)
            setHudValue("beltShow", not beltShow)
            setHudValue("engineDamageShow", engineDamageShow)
            setHudValue("fuel", math.ceil(fuel))
            setHudValue("gasDamageShow", gasDamageShow)
            setHudValue("harnessDurability", harnessDurability)
            setHudValue("nos", nos)
            setHudValue("nosEnabled", nosEnabled)
            setHudValue("nosShow", nos > 0)

            if IsWaypointActive() then
              local dist = (#(GetEntityCoords(PlayerPedId()) - GetBlipCoords(GetFirstBlipInfoId(8))) / 1000) * 0.715 -- quick conversion maff
              setHudValue("waypointActive", true)
              setHudValue("waypointDistance", dist)
            else
              setHudValue("waypointActive", false)
            end

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
                harnessDurability = exports["np-vehicles"]:GetVehicleMetadata(veh, 'harness')
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

function startHealthArmorUpdates()
    makeHudDirty()

    if startedHealthArmorUpdates then return end

    local prevHealth = -1
    local prevArmor = -1

    Citizen.CreateThread(function()
        startedHealthArmorUpdates = true

        while true do
            local armor = lerp(0, 100, rangePercent(0, 60, GetPedArmour(PlayerPedId())))
            if armor < 0 then armor = 0 end
            if armor > 100 then armor = 100 end
            local health = GetEntityHealth(PlayerPedId()) - 100
            if health > 100 then health = 100 end
            if health < 0 or isDead then health = 0 end

            setHudValue("armor", armor)
            setHudValue("health", health)

            Citizen.Wait(500)
        end
    end)
end

function lerp(min, max, amt)
    return (1 - amt) * min + amt * max
end

function rangePercent(min, max, amt)
    return (((amt - min) * 100) / (max - min)) / 100
end

--[[

    Events

]]

AddEventHandler("np-ui:watch", function()
    showCompassFromWatch = not showCompassFromWatch
    if showCompassFromWatch then
        generateCompass()
    end
    toggleCompass()
end)

AddEventHandler("np:voice:proximity", function(proximity)
    sendAppEvent("hud", {
        voiceRange = proximity,
    })
end)

AddEventHandler("np:voice:transmissionStarted", function(data)
    sendAppEvent("hud", {
        voiceActive = not data.radio,
        voiceActiveRadio = data.radio,
    })
end)

AddEventHandler("np:voice:transmissionFinished", function()
    sendAppEvent("hud", {
        voiceActive = false,
        voiceActiveRadio = false,
    })
end)

AddEventHandler("pd:deathcheck", function()
    isDead = not isDead
    sendAppEvent("game", {
        isAlive = not isDead
    })
end)

RegisterNetEvent("np-admin:currentDevmode")
AddEventHandler("np-admin:currentDevmode", function(devmode)
    setGameValue("modeDev", devmode)
end)

RegisterNetEvent("np-admin:currentDebug")
AddEventHandler("np-admin:currentDebug", function(debugToggle)
    setGameValue("modeDebug", debugToggle)
end)

AddEventHandler("seatbelt", function(belt)
    beltShow = belt
end)

AddEventHandler("harness", function(belt, dur)
    beltShow = belt
    harnessDurability = dur
end)

RegisterNetEvent("noshud")
AddEventHandler("noshud", function(_nos, _nosEnabled)
    if _nos == nil then
        nos = 0
    else
        nos = _nos
    end
    nosEnabled = _nosEnabled
end)

--[[

    NUI

]]

RegisterNUICallback("np-ui:hudSetPreferences", function(data, cb)
    cb({ data = {}, meta = { ok = true, message = "done" } })

    compassEnabled = data["hud.compass.enabled"]
    compassWaitTime = data["hud.compass.fps"]
    compassRoadNamesEnabled = data["hud.compass.roadnames.enabled"]
    speedometerWaitTime = data["hud.vehicle.speedometer.fps"]
    minimapEnabled = data["hud.vehicle.minimap.enabled"]

    if data["hud.presets"] then
        local idx = 0

        for _, p in pairs(data["hud.presets"]) do
            idx = idx + 1
            if not cmdsSet[idx] then
                local eventOptions = {
                    changeHud = idx,
                }

                local s = tostring(idx)

                -- exports["caue-keybinds"]:registerKeyMapping("", "HUD", "Enable " .. s, "+hud_enable_" .. s, "-hud_enable_" .. s)

                RegisterCommand('+hud_enable_' .. s, function()
                    exports["caue-ui"]:sendAppEvent("preferences", eventOptions)
                end, false)

                RegisterCommand('-hud_enable_' .. s, function() end, false)

                cmdsSet[idx] = true
            end
        end
    end
end)

RegisterNUICallback("np-ui:getRTCSettings", function(data, cb)
    --local data = exports["np-fiber"]:getRTCSettings()
    local data = {}
    cb({ data = data, meta = { ok = true, message = "done" } })
end)


--[[

    Threads

]]

Citizen.CreateThread(function()
    while true do
        local veh = GetVehiclePedIsIn(PlayerPedId(), false)
        if veh ~= 0 and not inVehicle then
            inVehicle = true
            setGameValue("vehicle", { hash = GetEntityModel(veh) })
        elseif veh == 0 and inVehicle then
            inVehicle = false
            setGameValue("vehicle", -1)
            setHudValue("harnessDurability", 0)
            setHudValue("nos", 0)
            setHudValue("nosShow", false)
        end

        local eon = IsVehicleEngineOn(veh)
        if eon and not engineOn then
            engineOn = true
            showCompassFromCar = true

            generateSpeedo()
            generateCompass()
            generateRoadNames()
            toggleCompass()

            roundedRadar()

            sendAppEvent("hud", {
                display = true,
                radarShow = minimapEnabled,
            })

        elseif not eon and engineOn then
            engineOn = false
            showCompassFromCar = false

            toggleCompass()

            sendAppEvent("hud", {
                radarShow = false
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

Citizen.CreateThread(function()
    while true do
        -- DontTiltMinimapThisFrame()
        local isPMA = IsPauseMenuActive()
        if isPMA and not pauseActive then
            pauseActive = true
            sendAppEvent("hud", { display = false })
            -- SetBlipScale(GetFirstBlipInfoId(8), 1.0) -- WAYPOINT BLIP
        elseif not isPMA and pauseActive then
            pauseActive = false
            -- SetBlipScale(GetFirstBlipInfoId(8), 0.0)
            sendAppEvent("hud", { display = true })
        end
        Citizen.Wait(250)
    end
end)

Citizen.CreateThread(function()
    SetRadarBigmapEnabled(true, false)
    Citizen.Wait(0)
    SetRadarBigmapEnabled(false, false)

    while true do
        --
        -- 1 : WANTED_STARS
        -- 2 : WEAPON_ICON
        -- 3 : CASH
        -- 4 : MP_CASH
        -- 5 : MP_MESSAGE
        -- 6 : VEHICLE_NAME
        -- 7 : AREA_NAME
        -- 8 : VEHICLE_CLASS
        -- 9 : STREET_NAME
        -- 10 : HELP_TEXT
        -- 11 : FLOATING_HELP_TEXT_1
        -- 12 : FLOATING_HELP_TEXT_2
        -- 13 : CASH_CHANGE
        -- 14 : RETICLE
        -- 15 : SUBTITLE_TEXT
        -- 16 : RADIO_STATIONS
        -- 17 : SAVING_GAME
        -- 18 : GAME_STREAM
        -- 19 : WEAPON_WHEEL
        -- 20 : WEAPON_WHEEL_STATS
        -- 21 : HUD_COMPONENTS
        -- 22 : HUD_WEAPONS
        --
        HideHudComponentThisFrame(1)
        HideHudComponentThisFrame(2)
        HideHudComponentThisFrame(3)
        HideHudComponentThisFrame(4)
        -- HideHudComponentThisFrame(5)
        HideHudComponentThisFrame(6)
        HideHudComponentThisFrame(7)
        HideHudComponentThisFrame(8)
        HideHudComponentThisFrame(9)
        HideHudComponentThisFrame(10)
        HideHudComponentThisFrame(11)
        HideHudComponentThisFrame(12)
        HideHudComponentThisFrame(13)
        HideHudComponentThisFrame(14)
        HideHudComponentThisFrame(15)
        HideHudComponentThisFrame(16)
        HideHudComponentThisFrame(17)
        HideHudComponentThisFrame(18)
        HideHudComponentThisFrame(19)
        HideHudComponentThisFrame(20)
        -- HideHudComponentThisFrame(21)
        -- HideHudComponentThisFrame(22)

        HudWeaponWheelIgnoreSelection()  -- CAN'T SELECT WEAPON FROM SCROLL WHEEL
        DisableControlAction(0, 37, true)

        HideMinimapInteriorMapThisFrame()
        SetRadarZoom(1000)

        Citizen.Wait(0)
    end
end)