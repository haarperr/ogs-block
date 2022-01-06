--[[

    Functions

]]

function SetUIFocus(hasKeyboard, hasMouse)
    -- HasNuiFocus = hasKeyboard or hasMouse

    SetNuiFocus(hasKeyboard, hasMouse)

    -- TriggerEvent("np-voice:focus:set", HasNuiFocus, hasKeyboard, hasMouse)
    -- TriggerEvent("np-binds:should-execute", not HasNuiFocus)
end

local function restartUI()
    SendUIMessage({ source = "np-nui", app = "main", action = "restart" });
    Wait(5000)
    SendUIMessage({ app = "hud", data = { display = true }, source = "np-nui" })
end

--[[

    Exports

]]

exports("SetUIFocus", SetUIFocus)

--[[

    Events

]]

RegisterNetEvent("np-ui:server-restart")
AddEventHandler("np-ui:server-restart", restartUI)

RegisterNetEvent("np-ui:server-relay")
AddEventHandler("np-ui:server-relay", function(data)
    SendUIMessage(data)
end)

RegisterNetEvent("caue-jobs:jobChanged")
AddEventHandler("caue-jobs:jobChanged", function(job)
    sendAppEvent("character", { job = job })
end)

--[[

    Commands

]]

RegisterCommand("np-ui:force-close", function()
    SendUIMessage({source = "np-nui", app = "", show = false});
    SetUIFocus(false, false)
end, false)

RegisterCommand("np-ui:small-map", function()
    SetRadarBigmapEnabled(false, false)
end, false)

RegisterCommand("np-ui:restart", restartUI, false)

RegisterCommand("np-ui:debug:show", function()
    SendUIMessage({ source = "np-nui", app = "debuglogs", data = { display = true } });
end, false)

RegisterCommand("np-ui:debug:hide", function()
    SendUIMessage({ source = "np-nui", app = "debuglogs", data = { display = false } });
end, false)

--[[

    NUI

]]

RegisterNUICallback("np-ui:closeApp", function(data, cb)
    SetUIFocus(false, false)
    cb({data = {}, meta = {ok = true, message = "done"}})
end)

RegisterNUICallback("np-ui:applicationClosed", function(data, cb)
    TriggerEvent("np-ui:application-closed", data.name, data)
    cb({data = {}, meta = {ok = true, message = "done"}})
end)

RegisterNUICallback("np-ui:resetApp", function(data, cb)
    SetUIFocus(false, false)
    cb({data = {}, meta = {ok = true, message = "done"}})
    sendCharacterData()
end)