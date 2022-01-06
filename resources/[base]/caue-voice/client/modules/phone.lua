IsOnPhoneCall, CurrentCall = false

function StartPhoneCall(serverId, callId)
    if IsOnPhoneCall then return end

    IsOnPhoneCall = true

    CurrentCall = { callId = callId, targetId = serverId }

    AddPlayerToTargetList(serverId, "phone", true)

    Citizen.CreateThread(function()
        local existingTarget = not Targets:targetHasAnyActiveContext(serverId)
        local existingChannel = not IsPlayerInTargetChannel(serverId)
        while IsOnPhoneCall do
            local currentTarget = not Targets:targetHasAnyActiveContext(serverId)
            local currentChannel = not IsPlayerInTargetChannel(serverId)
            if existingTarget ~= currentTarget or existingChannel ~= currentChannel then
                existingTarget = currentTarget
                existingChannel = currentChannel
                RefreshTargets()
            end

            Citizen.Wait(1000)
        end
    end)

    Debug("[Phone] Call Started | Call ID %s | Player %s", callId, serverId)
end

function StopPhoneCall(serverId, callId)
    if not IsOnPhoneCall or CurrentCall.callId ~= callId then return end

    IsOnPhoneCall = false

    CurrentCall = nil

    RemovePlayerFromTargetList(serverId, "phone", true, true)

    Debug("[Phone] Call Ended | Call ID %s | Player %s", callId, serverId)
end

function LoadPhoneModule()
    RegisterModuleContext("phone", 1)
    UpdateContextVolume("phone", Config.settings.phoneVolume)

    RegisterNetEvent("caue:voice:phone:call:start")
    AddEventHandler("caue:voice:phone:call:start", StartPhoneCall)

    RegisterNetEvent("caue:voice:phone:call:end")
    AddEventHandler("caue:voice:phone:call:end", StopPhoneCall)

    if Config.enableSubmixes and Config.enableFilters.phone then
        RegisterContextSubmix("phone")

        local filters = {
            { name = "freq_low", value = 100.0 },
            { name = "freq_hi", value = 10000.0 },
            { name = "rm_mod_freq", value = 0.0 },
            { name = "rm_mix", value = 0.10 },
            { name = "fudge", value = 1.0 },
            { name = "o_freq_lo", value = 100.0 },
            { name = "o_freq_hi", value = 10000.0 },
        }

        SetFilterParameters("phone", filters)
    end

    TriggerEvent("caue:voice:phone:ready")

    Debug("[Phone] Module Loaded")
end