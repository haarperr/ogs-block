--[[

    Variables

]]

stresslevel = 0

local stressDisabled = false
local isBlocked = false


--[[

    Functions

]]

function RevertToStressMultiplier()
    local factor = (stresslevel / 2) / 10000
    local factor = 1.0 - factor

    if factor > 0.1 then
        SetSwimMultiplierForPlayer(PlayerId(), factor)
        SetRunSprintMultiplierForPlayer(PlayerId(), factor)
    else
        SetRunSprintMultiplierForPlayer(PlayerId(), 1.0)
    end
end

--[[

    Exports

]]

exports("revertToStress", RevertToStressMultiplier)
exports("getStressLevel", function() return stresslevel end)

--[[

    Events

]]

RegisterNetEvent("client:newStress")
AddEventHandler("client:newStress",function(positive, alteredValue)
    if stressDisabled then return end

    if positive then
        TriggerEvent("DoShortHudText", "Stress Gained", 6)
    else
        TriggerEvent("DoShortHudText", "Stress Relieved", 6)
    end

    TriggerServerEvent("caue-hud:alterStress", positive, alteredValue)
end)

RegisterNetEvent("client:updateStress")
AddEventHandler("client:updateStress",function(newStress)
    stresslevel = newStress

    if dstamina == 0 then
        RevertToStressMultiplier()
    end
end)

RegisterNetEvent("client:blockShake")
AddEventHandler("client:blockShake",function(isBlockedInfo)
    isBlocked = isBlockedInfo
end)

RegisterNetEvent("caue-admin:currentDevmode")
AddEventHandler("caue-admin:currentDevmode", function(devmode)
    isBlocked = devmode
end)

--[[

    Threads

]]

Citizen.CreateThread(function()
    while true do
        if not isBlocked then
            if stresslevel > 7500 then
                ShakeGameplayCam("SMALL_EXPLOSION_SHAKE", 0.1)
            elseif stresslevel > 4500 then
                ShakeGameplayCam("SMALL_EXPLOSION_SHAKE", 0.07)
            elseif stresslevel > 2000 then
                ShakeGameplayCam("SMALL_EXPLOSION_SHAKE", 0.02)
            end
        end

        Citizen.Wait(2000)
    end
end)