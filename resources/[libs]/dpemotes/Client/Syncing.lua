local isRequestAnim = false
local requestedemote = ""

-- Some of the work here was done by Super.Cool.Ninja / rubbertoe98
-- https://forum.fivem.net/t/release-nanimstarget/876709

-----------------------------------------------------------------------------------------------------
-- Commands / Events --------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------

RegisterNetEvent("SyncPlayEmote")
AddEventHandler("SyncPlayEmote", function(emote, player)
    EmoteCancel()

    Wait(300)

    if DP.Shared[emote] ~= nil then
        OnEmotePlay(DP.Shared[emote])
    elseif DP.Dances[emote] ~= nil then
        OnEmotePlay(DP.Dances[emote])
    end
end)

RegisterNetEvent("SyncPlayEmoteSource")
AddEventHandler("SyncPlayEmoteSource", function(emote, player)
    local pedInFront = GetPlayerPed(GetClosestPlayer())
    local heading = GetEntityHeading(pedInFront)
    local coords = GetOffsetFromEntityInWorldCoords(pedInFront, 0.0, 1.0, 0.0)

    if DP.Shared[emote] and DP.Shared[emote].AnimationOptions then
        local SyncOffsetFront = DP.Shared[emote].AnimationOptions.SyncOffsetFront
        if SyncOffsetFront then
            coords = GetOffsetFromEntityInWorldCoords(pedInFront, 0.0, SyncOffsetFront, 0.0)
        end
    end

    SetEntityHeading(PlayerPedId(), heading - 180.1)
    SetEntityCoordsNoOffset(PlayerPedId(), coords.x, coords.y, coords.z, 0)
    EmoteCancel()

    Wait(300)

    if DP.Shared[emote] ~= nil then
        OnEmotePlay(DP.Shared[emote])
    elseif DP.Dances[emote] ~= nil then
        OnEmotePlay(DP.Dances[emote])
    end
end)

RegisterNetEvent("ClientEmoteRequestReceive")
AddEventHandler("ClientEmoteRequestReceive", function(emotename, etype)
    isRequestAnim = true
    requestedemote = emotename

    if etype == "Dances" then
        _,_,remote = table.unpack(DP.Dances[requestedemote])
    else
        _,_,remote = table.unpack(DP.Shared[requestedemote])
    end

    PlaySound(-1, "NAV", "HUD_AMMO_SHOP_SOUNDSET", 0, 0, 1)

    exports["caue-interaction"]:showInteraction("[Y] to accept [L] to refuse (" .. remote .. ")")
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5)

        if IsControlJustPressed(1, 246) and isRequestAnim then
            target, distance = GetClosestPlayer()

            if distance ~= -1 and distance < 3 then
                if DP.Shared[requestedemote] ~= nil then
                    _,_,_,otheremote = table.unpack(DP.Shared[requestedemote])
                elseif DP.Dances[requestedemote] ~= nil then
                    _,_,_,otheremote = table.unpack(DP.Dances[requestedemote])
                end

                if otheremote == nil then
                    otheremote = requestedemote
                end

                TriggerServerEvent("ServerValidEmote", GetPlayerServerId(target), requestedemote, otheremote)

                exports["caue-interaction"]:hideInteraction()

                isRequestAnim = false
            else
                TriggerEvent("DoLongHudText", "Nobody close enough.", 2)
            end
        elseif IsControlJustPressed(1, 182) and isRequestAnim then
            TriggerEvent("DoLongHudText", "Emote refused.", 2)

            exports["caue-interaction"]:hideInteraction()

            isRequestAnim = false
        end
    end
end)

-----------------------------------------------------------------------------------------------------
------ Functions and stuff --------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------

function GetClosestPlayer()
    local players = GetPlayers()
    local closestDistance = -1
    local closestPlayer = -1
    local ply = PlayerPedId()
    local plyCoords = GetEntityCoords(ply, 0)

    for index,value in ipairs(players) do
        local target = GetPlayerPed(value)
        if(target ~= ply) then
            local targetCoords = GetEntityCoords(GetPlayerPed(value), 0)
            local distance = GetDistanceBetweenCoords(targetCoords["x"], targetCoords["y"], targetCoords["z"], plyCoords["x"], plyCoords["y"], plyCoords["z"], true)
            if(closestDistance == -1 or closestDistance > distance) then
                closestPlayer = value
                closestDistance = distance
            end
        end
    end
    return closestPlayer, closestDistance
end

function GetPlayers()
    local players = {}

    for i = 0, 255 do
        if NetworkIsPlayerActive(i) then
            table.insert(players, i)
        end
    end

    return players
end