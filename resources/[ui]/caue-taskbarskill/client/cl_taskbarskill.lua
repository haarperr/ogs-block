--[[

    Variables

]]

local listening = false
local success = false

--[[

    Functions

]]

function taskBarSkillCheck(_duration, _difficulty, cb)
    TriggerEvent("menu:menuexit")

    Wait(100)

    if listening then
        cb(0)
        return
    end

    listening = true

    SetNuiFocus(true, false)
    SendNUIMessage({
        display = true,
        duration = _duration,
        difficulty = _difficulty,
    })

    while listening do
        if IsPedRagdoll(PlayerPedId()) then
            SetNuiFocus(false, false)
            SendNUIMessage({
                display = false,
            })
            listening = false
            success = false
        end

        Wait(100)
    end

    local result = success == true and 100 or 0
    if not success then
        TriggerEvent("DoLongHudText", "Tentativa Fracassada!", 2)
    end

    if cb then cb(result) end

    return result
end

--[[

    Exports

]]

exports("taskBarSkill", taskBarSkillCheck)

--[[

    NUI

]]

RegisterNUICallback("taskBarSkillResult", function(data, cb)
    SetNuiFocus(false, false)
    SendNUIMessage({
        display = false,
    })

    listening = false

    success = data.success
end)