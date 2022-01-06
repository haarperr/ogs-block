--[[

    Variables

]]

local gameDirty = false
local gameValues = {}
local hudDirty = false
local hudValues = {}

--[[

    Functions

]]

function makeHudDirty()
    hudDirty = true
end

function setHudValue(k, v)
    if hudValues[k] == nil or hudValues[k] ~= v then
        hudDirty = true
    end
    hudValues[k] = v
end

function setGameValue(k, v)
    if gameValues[k] == nil or gameValues[k] ~= v then
        gameDirty = true
    end
    gameValues[k] = v
end

--[[

    Commands

]]

-- RegisterCommand("np-ui:hud-preset", function(source, args)
--     sendAppEvent("preferences", {
--         changeHud = tonumber(args[1])
--     })
-- end)

-- RegisterCommand("np-ui:preferences", function(source, args)
--     openApplication("preferences")
-- end)

--[[

    Threads

]]

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(256)
        if hudDirty then
            hudDirty = false
            sendAppEvent("hud", hudValues)
        end
        Citizen.Wait(256)
        if gameDirty then
            gameDirty = false
            sendAppEvent("game", gameValues)
        end
    end
end)