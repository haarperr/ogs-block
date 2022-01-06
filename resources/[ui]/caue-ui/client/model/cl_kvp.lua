--[[

    Variables

]]

local firstCall = true

--[[

    NUI

]]

RegisterNUICallback("np-ui:setKVPValue", function(data, cb)
    SetResourceKvp(data.key, json.encode(data.value))

    if firstCall then
        firstCall = false
        Wait(30000)
    end

    TriggerEvent("np-hud:settings", data.key, data.value)

    cb({ data = {}, meta = { ok = true, message = 'done' } })
end)

RegisterNUICallback("np-ui:getKVPValue", function(data, cb)
    local result = GetResourceKvpString(data.key)
    local value = json.decode(result or "{}")

    cb({ data = { value = value }, meta = { ok = true, message = 'done' } })
end)

--[[

    Threads

]]

Citizen.CreateThread(function()
    local preferences_data = {
        ["hud.presetSelected"] = 1,
        ["hud.presets"] = {
            [1] = {
                ["hud.status.health.enabled"] = true,
                ["hud.status.armor.enabled"] = true,
                ["hud.status.food.enabled"] = true,
                ["hud.status.water.enabled"] = true,
                ["hud.status.stress.enabled"] = true,
                ["hud.status.oxygen.enabled"] = true,
                ["hud.status.health.hide"] = 100,
                ["hud.status.armor.hide"] = 100,
                ["hud.status.food.hide"] = 100,
                ["hud.status.water.hide"] = 100,
                ["hud.vehicle.minimap.enabled"] = true,
                ["hud.vehicle.harness.enabled"] = true,
                ["hud.vehicle.nitrous.enabled"] = true,
                ["hud.vehicle.speedometer.fps"] = 64,
                ["hud.vehicle.nitrous.arcadetrail"] = false,
                ["hud.compass.enabled"] = true,
                ["hud.compass.time.enabled"] = false,
                ["hud.compass.roadnames.enabled"] = true,
                ["hud.compass.fps"] = 16,
                ["hud.blackbars.enabled"] = false,
                ["hud.blackbars.size"] = 10,
                ["hud.crosshair.enabled"] = true,
            },
        },
        ["hud.status.health.enabled"] = true,
        ["hud.status.armor.enabled"] = true,
        ["hud.status.food.enabled"] = true,
        ["hud.status.water.enabled"] = true,
        ["hud.status.stress.enabled"] = true,
        ["hud.status.oxygen.enabled"] = true,
        ["hud.status.health.hide"] = 100,
        ["hud.status.armor.hide"] = 100,
        ["hud.status.food.hide"] = 100,
        ["hud.status.water.hide"] = 100,
        ["hud.vehicle.minimap.enabled"] = true,
        ["hud.vehicle.harness.enabled"] = true,
        ["hud.vehicle.nitrous.enabled"] = true,
        ["hud.vehicle.speedometer.fps"] = 64,
        ["hud.vehicle.nitrous.arcadetrail"] = false,
        ["hud.compass.enabled"] = true,
        ["hud.compass.time.enabled"] = false,
        ["hud.compass.roadnames.enabled"] = true,
        ["hud.compass.fps"] = 16,
        ["hud.blackbars.enabled"] = false,
        ["hud.blackbars.size"] = 10,
        ["hud.crosshair.enabled"] = true,
        ["phone.shell"] = "android",
        ["phone.wallpaper"] = "https://i.imfur.com/3KTfLIV.jpg",
        ["phone.notifications.sms"] = true,
        ["phone.notifications.twatter"] = true,
        ["phone.notifications.email"] = true,
        ["phone.images.enabled"] = true,
        ["phone.volume"] = 0.8,
        ["radio.stereo.enabled"] = true,
        ["radio.volume"] = 0.8,
        ["radio.clicks.outgoing.enabled"] = true,
        ["radio.clicks.incoming.enabled"] = true,
        ["radio.clicks.volume"] = 0.8,
        ["rtc.settings.device"] = nil,
        ["rtc.system"] = {
            ["character"] = {},
        },
        ["rtc.settings.phone.filter.enabled"] = true,
        ["rtc.settings.phone.filter.waveShaper"] = 5,
        ["rtc.settings.phone.filter.gainNode"] = 1,
        ["rtc.settings.phone.filter.pannerNode"] = 0.4,
        ["rtc.settings.phone.filter.highpassBiquad"] = 500,
        ["rtc.settings.phone.filter.lowpassBiquad"] = 8000,
        ["rtc.settings.radio.filter.enabled"] = true,
        ["rtc.settings.radio.filter.waveShaper"] = 9,
        ["rtc.settings.radio.filter.gainNode"] = 1.5,
        ["rtc.settings.radio.filter.pannerNode"] = -0.40,
        ["rtc.settings.radio.filter.highpassBiquad"] = 1000,
        ["rtc.settings.radio.filter.lowpassBiquad"] = 2000,
        ["date.timezone"] = "America/New_York",
        ["date.format"] = "YYYY-MM-DD hh:mm:ss A",
    }

    SetResourceKvp("np-preferences", json.encode(preferences_data))
end)