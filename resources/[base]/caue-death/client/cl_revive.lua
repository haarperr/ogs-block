--[[

    Functions

]]

function attemptRevive()
    if imDead or IsDeadAnimPlaying() or IsDeadVehAnimPlaying() then
        imDead = false
        thecount = 240

        TriggerEvent("Heal")
        TriggerEvent("resurrect:relationships")
        TriggerEvent("Evidence:isAlive")

        SetEntityInvincible(PlayerPedId(), false)
        SetPedMaxHealth(PlayerPedId(), 200)
        SetPlayerMaxArmour(PlayerId(), 60)
        ClearPedBloodDamage(PlayerPedId())
        RemoveAllPedWeapons(PlayerPedId(), true)

        local plyPos = GetEntityCoords(PlayerPedId(),  true)
        local heading = GetEntityHeading(PlayerPedId())

        ClearPedTasksImmediately(PlayerPedId())

        -- TODO:
        -- local wasBeatdown = exports["police"]:getBeatmodeDebuff()
        -- if wasBeatdown then
        --     TriggerEvent("police:startBeatdownDebuff")
        -- end

        NetworkResurrectLocalPlayer(plyPos, heading, false, false, false)

        Citizen.Wait(500)

        getup()
    end
end

function getup()
    ClearPedSecondaryTask(PlayerPedId())
    loadAnimDict("random@crash_rescue@help_victim_up")
    TaskPlayAnim(PlayerPedId(), "random@crash_rescue@help_victim_up", "helping_victim_to_feet_victim", 8.0, 1.0, -1, 49, 0, 0, 0, 0)
    SetCurrentPedWeapon(PlayerPedId(),2725352035,true)
    Citizen.Wait(3000)
    ClearPedSecondaryTask(PlayerPedId())
end

--[[

    Events

]]

RegisterNetEvent("heal")
AddEventHandler("heal", function()
	local ped = PlayerPedId()
	if DoesEntityExist(ped) and not IsEntityDead(ped) then
		SetEntityHealth(ped, GetEntityMaxHealth(ped))
	end
end)

RegisterNetEvent("trycpr")
AddEventHandler("trycpr", function()
    local curDist = #(GetEntityCoords(PlayerPedId(), 0) - vector3(2438.32, 4960.30, 47.27))
    local curDist2 = #(GetEntityCoords(PlayerPedId(), 0) - vector3(-1001.18, 4850.52, 274.61))

    if curDist < 5 or curDist2 < 5 then
        local penis = 0
        while penis < 10 do
            penis = penis + 1
            local finished = exports["np-ui"]:taskBarSkill(math.random(2000, 6000),math.random(5, 15))
            if finished ~= 100 then
                return
            end
            Wait(100)
        end
        TriggerServerEvent("serverCPR")
    else
        TriggerEvent("DoLongHudText","You are not near the rest house",2)
    end
end)

RegisterNetEvent("reviveFunction")
AddEventHandler("reviveFunction", attemptRevive)