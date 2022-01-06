--[[

    Events

]]

RegisterNetEvent("caue-base:sessionStarted")
AddEventHandler("caue-base:sessionStarted", function()
    ShutdownLoadingScreen()

    FreezeEntityPosition(PlayerPedId(), true)

    TransitionToBlurred(500)
    DoScreenFadeOut(500)

    local cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", 1)

    SetCamRot(cam, 0.0, 0.0, -45.0, 2)
    SetCamCoord(cam, -682.0, -1092.0, 226.0)
    SetCamActive(cam, true)
    RenderScriptCams(true, false, 0, true, true)

    local ped = PlayerPedId()

    SetEntityCoordsNoOffset(ped, -682.0, -1092.0, 200.0, false, false, false, true)

    SetEntityVisible(ped, false)

    DoScreenFadeIn(500)

    while IsScreenFadingIn() do
        Citizen.Wait(0)
    end

    TriggerEvent("caue-base:spawnInitialized")
    TriggerServerEvent("caue-base:spawnInitialized")
end)

--[[

    Threads

]]

Citizen.CreateThread(function()
    while true do
        if NetworkIsSessionStarted() then
            TriggerServerEvent("caue-base:sessionStarted")
            TriggerEvent("caue-base:sessionStarted")
            break
        end
    end
end)