--[[

    Events

]]

RegisterNetEvent("caue-base:sessionStarted")
AddEventHandler("caue-base:sessionStarted", function()
    local src = source

    TriggerClientEvent("caue-doors:initial-lock-state", -1, DOORS)
end)

RegisterNetEvent("caue-doors:change-lock-state")
AddEventHandler("caue-doors:change-lock-state", function(pDoorId, pDoorLockState, pDoorForceUnlock)
    local src = source

    DOORS[pDoorId]["lock"] = pDoorLockState
    TriggerClientEvent("caue-doors:change-lock-state", -1, pDoorId, pDoorLockState, pDoorForceUnlock)

    if DOORS[pDoorId]["double"] then
        DOORS[DOORS[pDoorId]["double"]]["lock"] = pDoorLockState
        TriggerClientEvent("caue-doors:change-lock-state", -1, DOORS[pDoorId]["double"], pDoorLockState, pDoorForceUnlock)
    end
end)

RegisterNetEvent("caue-door:add")
AddEventHandler("caue-door:add", function(doorCoords, doorModel)
    local src = source
    local name = GetPlayerName(src)

    local output = '--Name: ' .. name .. ' | ' .. os.date('!%Y-%m-%dT%H:%M:%SZ\n')

    output = output .. '{\n'
    output = output .. '    ["active"] = true,\n'
    output = output .. '    ["model"] = ' .. doorModel .. ',\n'
    output = output .. '    ["coords"] = vector3(' .. string.format("%.2f", doorCoords["x"]) .. ', ' .. string.format("%.2f", doorCoords["y"]) .. ', ' .. string.format("%.2f", doorCoords ["z"]) .. '),\n'
    output = output .. '    ["lock"] = 1,\n'
    output = output .. '    ["automatic"] = {},\n'
    output = output .. '    ["access"] = {},\n'
    output = output .. '},\n\n'


    file = io.open('doors.txt', "a")
    io.output(file)
    io.write(output)
    io.close(file)

    TriggerClientEvent("DoLongHudText", src, "Door saved")
end)