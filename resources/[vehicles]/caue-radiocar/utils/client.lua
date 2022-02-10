ESX = nil
QBCore = nil

CreateThread(function()
    if Config.FrameWork == 1 then
        local breakMe = 0
        while ESX == nil do
            Wait(100)
            breakMe = breakMe + 1
            TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
            if breakMe > 10 then
                break
            end
        end
    end

    if Config.FrameWork == 2 then
        QBCore = Config.GetQBCoreObject()

        ESX = {}
        ESX.Game = {}
        ESX.Game.GetVehicleProperties = function(vehicle)
            return QBCore.Functions.GetVehicleProperties(vehicle)
        end
    end
end)

-- this will send information to server.
function CheckPlayerCar(vehicle)
    if ESX then
        local veh = ESX.Game.GetVehicleProperties(vehicle)
        TriggerServerEvent("caue-radiocar:openUI", veh.plate)
    else
        TriggerServerEvent("caue-radiocar:openUI", GetVehicleNumberPlateText(vehicle))
    end
end

-- if you want this script for... lets say like only vip, edit this function.
function YourSpecialPermission()
    return true
end

function GetVehiclePlate()
    if ESX then
        local spz = ESX.Game.GetVehicleProperties(GetVehiclePedIsIn(PlayerPedId())).plate
        return spz
    else
        return GetVehicleNumberPlateText(GetVehiclePedIsIn(PlayerPedId()))
    end
    return "none"
end

AddEventHandler("caue-radiocar:updateMusicInfo", function(data)
    if ESX then
        local spz = ESX.Game.GetVehicleProperties(GetVehiclePedIsIn(PlayerPedId())).plate
        TriggerServerEvent("caue-radiocar:updateMusicInfo", data.label, data.url, spz, data.index)
    else
        TriggerServerEvent("caue-radiocar:updateMusicInfo", data.label, data.url, GetVehicleNumberPlateText(GetVehiclePedIsIn(PlayerPedId())), data.index)
    end
end)