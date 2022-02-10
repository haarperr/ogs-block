--[[

    Variables

]]

local isRadioOpen = false

--[[

    Functions

]]

function toggleRadioAnimation(pState)
    local isInTrunk = exports["caue-base"]:getVar("trunk")
    local isDead = exports["caue-base"]:getVar("dead")

    if isInTrunk or isDead then return end

    LoadAnimationDic("cellphone@")

    if pState then
        TriggerEvent("attachItemRadio","radio01")
        TaskPlayAnim(PlayerPedId(), "cellphone@", "cellphone_text_read_base", 2.0, 3.0, -1, 49, 0, 0, 0, 0)
    else
        StopAnimTask(PlayerPedId(), "cellphone@", "cellphone_text_read_base", 1.0)
        TriggerEvent("destroyPropRadio")
    end
end

function LoadAnimationDic(dict)
    if not HasAnimDictLoaded(dict) then
        RequestAnimDict(dict)

        while not HasAnimDictLoaded(dict) do
            Citizen.Wait(0)
        end
    end
end

function hasRadio()
    return exports["caue-inventory"]:hasEnoughOfItem("radio", 1, false) or exports["caue-inventory"]:hasEnoughOfItem("civradio", 1, false)
end

function formattedChannelNumber(number)
    local power = 10 ^ 1
    return math.floor(number * power) / power
end

function handleConnectionEvent(pChannel)
    local newChannel = formattedChannelNumber(pChannel)

    if type(newChannel) ~= "number" then return end

    if newChannel < 1.0 then
        TriggerServerEvent("RemovePlayerFromRadio", GetPlayerServerId(PlayerId()))
    else
        exports["caue-voice"]:SetRadioFrequency(newChannel)
    end
end

function openRadio()
    local currentJob = exports["caue-base"]:getChar("job")

    if exports["caue-base"]:getVar("call") then
        TriggerEvent("DoShortHudText", "Você não pode fazer isso em chamada!", 2)
        return
    end

    if not hasRadio() then
        TriggerEvent("DoShortHudText", "Você precisa de um rádio.", 2)
        toggleRadioAnimation(false)
        return
    end

    if not isRadioOpen then
        SetNuiFocus(true, true)
        SendNUIMessage({
            open = true,
            jobType = exports["caue-jobs"]:getJob(currentJob, "is_emergency"),
        })

        toggleRadioAnimation(true)
    else
        SetNuiFocus(false, false)
        SendNUIMessage({
            open = false,
            jobType = exports["caue-jobs"]:getJob(currentJob, "is_emergency"),
        })

        closeRadio()
    end

    isRadioOpen = not isRadioOpen
end

function closeRadio()
    toggleRadioAnimation(false)
end

--[[

    Events

]]

RegisterNetEvent("caue-radio:setChannel")
AddEventHandler("caue-radio:setChannel", function(chan)
    handleConnectionEvent(chan)

    SendNUIMessage({
        set = true,
        setChannel = chan,
    })
end)

RegisterNetEvent("ChannelSet")
AddEventHandler("ChannelSet", function(chan)
    SendNUIMessage({
        set = true,
        setChannel = chan,
    })
end)

AddEventHandler("caue-inventory:itemUsed", function(item)
    if item ~= "radio" and item ~= "civradio" then return end

    openRadio()
end)

--[[

    NUI

]]

RegisterNUICallback("poweredOn", function(data, cb)
    PlaySound(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
    exports["caue-voice"]:SetRadioPowerState(true)
end)

RegisterNUICallback("poweredOff", function(data, cb)
    PlaySound(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
    exports["caue-voice"]:SetRadioPowerState(false)
end)

RegisterNUICallback("setRadioChannel", function(data, cb)
    TriggerEvent("InteractSound_CL:PlayOnOne", "radioclick", 0.6)
    handleConnectionEvent(data.channel)
end)

RegisterNUICallback("volumeUp", function(data, cb)
    PlaySound(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
    exports["caue-voice"]:IncreaseRadioVolume()
end)

RegisterNUICallback("volumeDown", function(data, cb)
    PlaySound(-1, "NAV_UP_DOWN", "HUD_FRONTEND_DEFAULT_SOUNDSET", 0, 0, 1)
    exports["caue-voice"]:DecreaseRadioVolume()
end)

RegisterNUICallback("close", function(data, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({
        open = false,
    })

    isRadioOpen = false
    closeRadio()
end)

--[[

    Threads

]]

Citizen.CreateThread(function()
    exports["caue-keybinds"]:registerKeyMapping("", "Radio", "Open", "+handheld", "-handheld", ";")
    RegisterCommand("+handheld", openRadio, false)
    RegisterCommand("-handheld", function() end, false)
end)