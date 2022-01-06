--[[

    Functions

]]

function createPendingRace(id, options)
    if curRace then return end

    RPC.execute("caue-racing:createPendingRace", id, options)
end

function previewRace(id)
    if previewEnabled then
        previewEnabled = false
        return
    end

    local race = races[id]
    if race == nil then return end

    previewEnabled = false
    SetWaypointOff()
    race.start.pos = tableToVector3(race.start.pos)

    for i=1, #race.checkpoints do
        race.checkpoints[i].pos = tableToVector3(race.checkpoints[i].pos)
    end

    local checkpoints = race.checkpoints
    for i=1, #checkpoints do
        addCheckpointBlip(checkpoints, i)
    end

    if race.type == "Point" then
        addBlip(race.start.pos, 0, true)
    end

    previewEnabled = true

    -- Thread to continously render the route
    Citizen.CreateThread(function()
        while previewEnabled do
            -- If a race has been started, or waypoint has been placed, preview is disabled and cleared
            if IsWaypointActive() or curRace then
                previewEnabled = false
            end
            Citizen.Wait(0)
        end

        clearBlips()
    end)
end

function locateRace(id)
    local race = races[id]
    if race == nil then return end

    previewEnabled = false
    local start = race.start.pos
    SetNewWaypoint(start.x, start.y, start.z)
end

function startRace(countdown)
    local characterId = getCharacterId()
    for k, v in pairs(pendingRaces) do
        if v.owner == characterId then
            RPC.execute("caue-racing:startRace", v.id, countdown or v.countdown)
            return
        end
    end
end

function endRace()
    if curRace then
        RPC.execute("caue-racing:endRace")
    else
        RPC.execute("caue-racing:leaveRace")
    end
end

function joinRace(id, alias, characterId)
    RPC.execute("caue-racing:joinRace", id, alias, characterId)
end

function leaveRace()
    SendNUIMessage({
        showHUD = false
    })

    if curRace then
        RPC.execute("caue-racing:dnfRace", curRace.id)
        cleanupRace()
    else
        RPC.execute("caue-racing:leaveRace")
    end
end

function getAllRaces()
    if races then
        return {
            races = races,
            pendingRaces = pendingRaces,
            activeRaces = activeRaces,
            finishedRaces = finishedRaces,
        }
    end

    local res = RPC.execute("caue-racing:getAllRaces")
    races = res.races
    pendingRaces = res.pendingRaces
    activeRaces = res.activeRaces
    finishedRaces = res.finishedRaces

    return res
end

--[[

    Exports

]]

exports("createPendingRace", createPendingRace)
exports("previewRace", previewRace)
exports("locateRace", locateRace)
exports("startRace", startRace)
exports("endRace", endRace)
exports("joinRace", joinRace)
exports("leaveRace", leaveRace)
exports("getAllRaces", getAllRaces)