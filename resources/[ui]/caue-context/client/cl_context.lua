--[[

    Functions

]]

function showContext(data)
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "OPEN_MENU",
        data = data,
    })
end


--[[

    Exports

]]

exports("showContext", showContext)

--[[

    Events

]]

RegisterNetEvent("caue-context:showContext")
AddEventHandler("caue-context:showContext", showContext)

RegisterNetEvent("caue-context:preLoadImages")
AddEventHandler("caue-context:preLoadImages", function(images)
    SendNUIMessage({
        action = "LOAD_IMAGES",
        data = images,
    })
end)

--[[

    NUI

]]

RegisterNUICallback("dataPost", function(data, cb)
    SetNuiFocus(false)
    TriggerEvent(data.action, data.params)
    cb("ok")
end)

RegisterNUICallback("cancel", function()
    SetNuiFocus(false)
end)