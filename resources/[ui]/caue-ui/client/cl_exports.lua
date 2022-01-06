--[[

    Variables

]]

local Events = {}
local currSoundId = 0

--[[

    Functions

]]

function SendUIMessage(data)
    SendNUIMessage(data)
end

function RegisterUIEvent(eventName)
    if not Events[eventName] then
        Events[eventName] = true

        RegisterNUICallback(eventName, function (...)
            TriggerEvent(("_npx_uiReq:%s"):format(eventName), ...)
        end)
    end
end

function SetUIFocusCustom(hasKeyboard, hasMouse)
    HasNuiFocus = hasKeyboard or hasMouse

    SetNuiFocus(hasKeyboard, hasMouse)
    SetNuiFocusKeepInput(HasNuiFocus)
end

function GetUIFocus()
    return HasFocus, HasCursor
end

function cashFlash(pCash, pChange)
    SendUIMessage({
        app = "cash",
        data = {
            cash = pCash,
            amountAdjustment = pChange
            -- duration = 5 // optional duration for fade, default 4 seconds
        },
        source = "np-nui",
    })
end

function openApplication(app, data, stealFocus)
    stealFocus = stealFocus == nil and true or false

    SendUIMessage({
        source = "np-nui",
        app = app,
        show = true,
        data = data or {},
    })

    if stealFocus then
        SetUIFocus(true, true)
    end
end

function closeApplication(app, data)
    SendUIMessage({
        source = "np-nui",
        app = app,
        show = false,
        data = data or {},
    })

    SetUIFocus(false, false)
    TriggerEvent("np-ui:application-closed", app, { fromEscape = false })
end

function sendAppEvent(app, data)
    SendUIMessage({
        app = app,
        data = data or {},
        source = "np-nui",
    })
end

local function getSoundId()
    currSoundId = currSoundId + 1
    return currSoundId
end

function soundPlay(name, volume, loop)
    local id = getSoundId()
    SendUIMessage({
        source = "np-nui",
        app = "sounds",
        data = {
            action = "play",
            id = id,
            name = name,
            loop = loop or false,
            volume = volume or 1.0,
        },
    })

    return id
end

function soundVolume(id, volume)
    SendUIMessage({
        source = "np-nui",
        app = "sounds",
        data = {
            action = "volume",
            id = id,
            volume = volume,
        },
    });
end

function soundStop(id)
    SendUIMessage({
        source = "np-nui",
        app = "sounds",
        data = {
            action = "stop",
            id = id,
        },
    })
end

--[[

    Exports

]]

exports("SendUIMessage", SendUIMessage)
exports("RegisterUIEvent", RegisterUIEvent)
exports("SetUIFocusCustom", SetUIFocusCustom)
exports("GetUIFocus", GetUIFocus)
exports("cashFlash", cashFlash)
exports("openApplication", openApplication)
exports("closeApplication", closeApplication)
exports("sendAppEvent", sendAppEvent)
exports("soundPlay", soundPlay)
exports("soundVolume", soundVolume)
exports("soundStop", soundStop)

--[[

    Events

]]

RegisterNetEvent("np-ui:open-application")
AddEventHandler("np-ui:open-application", openApplication)

RegisterNetEvent("np-ui:soundPlay")
AddEventHandler("np-ui:soundPlay", soundPlay)

--[[

    Threads

]]

Citizen.CreateThread(function()
    TriggerEvent("_npx_uiReady")
end)