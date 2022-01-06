--[[

    Variables

]]

local sceneStarted = false
local scenesEnabled = true
local activePos = nil
local activeScenes = {}
local drawnScenes = {}
local playerCoords = nil

--[[

    Functions

]]

function drawScene(scene)
    if drawnScenes[scene.id] then return end

    drawnScenes[scene.id] = true

    Citizen.CreateThread(function()
        while scenesEnabled and drawnScenes[scene.id] do
            DrawText3D(scene.coords.x, scene.coords.y, scene.coords.z, scene.text, scene.color)
            Citizen.Wait(0)
        end
    end)
end

--[[

    Events

]]

RegisterNetEvent("caue-scenes:refreshScenes")
AddEventHandler("caue-scenes:refreshScenes", function(data, removeId)
    activeScenes = data
    if removeId then
        drawnScenes[removeId] = nil
    end
end)

--[[

    Commands

]]

RegisterCommand("+startScene", function()
    if sceneStarted then
        sceneStarted = false

        local input = exports["caue-input"]:showInput({
            {
                icon = "pencil-alt",
                label = "Text (Max 255 characters)",
                name = "text",
            },
            {
                icon = "palette",
                label = "Color (white, red, green, yellow, blue, purple)",
                name = "color",
            },
            {
                icon = "people-arrows",
                label = "Distance (0.1 - 10)",
                name = "distance",
            },
        })

        if input["text"] and input["color"] and input["distance"] then
            local text = input["text"]
            local color = input["color"]
            local distance = tonumber(input["distance"])

            if text == "" or string.len(text) > 255 then
                TriggerEvent("DoLongHudText", "Not this text is not valid", 2)
                return
            end

            if not colors[color] then
                TriggerEvent("DoLongHudText", "Not this color is not valid", 2)
                return
            end

            if not distance or distance < 0.1 or distance > 10 then
                TriggerEvent("DoLongHudText", "Not this distance is not valid", 2)
                return
            end

            distance = distance + 0.00

            RPC.execute("caue-scenes:addScene", activePos, text, distance, color)
        end

        return
    end

    sceneStarted = true

    Citizen.CreateThread(function()
        while sceneStarted do
            local hit, pos, _, _ = RayCastGamePlayCamera(10.0)
            if hit then
                DrawSphere(pos, 0.2, 255, 0, 0, 255)
                activePos = pos
            end

            Citizen.Wait(0)
        end
    end)
end, false)

RegisterCommand("-startScene", function() end, false)

RegisterCommand("+enableScene", function() scenesEnabled = not scenesEnabled end, false)
RegisterCommand("-enableScene", function() end, false)

RegisterCommand("+deleteScene", function()
    RPC.execute("caue-scenes:deleteScene", GetEntityCoords(PlayerPedId()))
end, false)
RegisterCommand("-deleteScene", function() end, false)

--[[

    Threads

]]

Citizen.CreateThread(function()
    exports["caue-keybinds"]:registerKeyMapping("", "Scenes", "Start / Place Scene", "+startScene", "-startScene")
    exports["caue-keybinds"]:registerKeyMapping("", "Scenes", "Enable / Disable", "+enableScene", "-enableScene")
    exports["caue-keybinds"]:registerKeyMapping("", "Scenes", "Delete Closest Scene", "+deleteScene", "-deleteScene")

    Citizen.Wait(5000)

    activeScenes = RPC.execute("caue-scenes:getScenes")
end)

Citizen.CreateThread(function()
    while true do
        if scenesEnabled then
            playerCoords = GetEntityCoords(PlayerPedId())
            for _, scene in pairs(activeScenes) do
                if #(scene.coords - playerCoords) < scene.distance then
                    drawScene(scene)
                else
                    drawnScenes[scene.id] = nil
                end
            end
        end

        Citizen.Wait(1000)
    end
end)