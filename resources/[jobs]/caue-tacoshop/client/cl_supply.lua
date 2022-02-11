--[[

    Variables

]]

local rusticosotemideiasmerdasesseserverezap = 0
local deliveryBlip = 0

local deliveryLocations = {
    -- I.B --
	{ ["pos"] = vector4(26.21, -1338.9, 29.5, 159.69), ["name"] = "Innocence Boulevard Loja de Convêniencia" },
    { ["pos"] = vector4(-40.96, -1751.23, 29.43, 356.24), ["name"] = "Grove Street Loja de Convêniencia" },
    { ["pos"] = vector4(289.44, -1266.91, 29.45, 267.94), ["name"] = "Crusade Road Loja de Convêniencia" },
    { ["pos"] = vector4(1211.3, -1389.02, 35.38, 359.86), ["name"] = "El Burro Loja de Convêniencia" },
    { ["pos"] = vector4(1163.31, -314.24, 69.21, 14.01), ["name"] = "Mirror Park Loja de Convêniencia" },
    { ["pos"] = vector4(-531.54, -1221.2, 18.46, 163.39), ["name"] = "Little Seoul Loja de Convêniencia" },
    { ["pos"] = vector4(-811.58, -736.9, 23.78, 355.61), ["name"] = "Out Dat Ghetto Studios (Little Seoul)" },



}

--[[

    Functions

]]

function DeleteBlip()
	if DoesBlipExist(deliveryBlip) then
		RemoveBlip(deliveryBlip)
	end
end

function CreateBlip(pLocation)
	DeleteBlip()
	deliveryBlip = AddBlipForCoord(pLocation["pos"]["xyz"])
    SetBlipSprite(deliveryBlip, 514)
    SetBlipScale(deliveryBlip, 1.0)
    SetBlipAsShortRange(deliveryBlip, false)
    SetBlipRoute(deliveryBlip, true)
    SetBlipRouteColour(deliveryBlip, 46)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Ponto de entrega")
    EndTextCommandSetBlipName(deliveryBlip)
end

function DrawText3D(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    SetTextScale(0.35, 0.35)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
    local factor = (string.len(text)) / 370
    DrawRect(_x,_y+0.0125, 0.015+ factor, 0.03, 41, 11, 41, 68)
end

--[[

    Events

]]

AddEventHandler("caue-tacoshop:supplyStation", function(pParameters)
    if pParameters.stationId == 1 then
        if rusticosotemideiasmerdasesseserverezap > 0 then return end
        rusticosotemideiasmerdasesseserverezap = 1

        TriggerEvent("player:receiveItem", "delivery_supply", rusticosotemideiasmerdasesseserverezap)
        TriggerEvent("caue-tacoshop:supplyStart")
    elseif pParameters.stationId == 2 then
        TriggerEvent("caue-tacoshop:supplyEnd")
    end
end)

AddEventHandler("caue-tacoshop:supplyStart", function()
	local location = deliveryLocations[math.random(#deliveryLocations)]

    CreateBlip(location)

    TriggerEvent("DoLongHudText", "Entregue essa caixa de suprimentos em " .. location.name .. ", não se atrase!!")

    while true do
		Citizen.Wait(1)

        local plyCoords = GetEntityCoords(PlayerPedId())
		local distance = #(plyCoords - location["pos"]["xyz"])

		if distance < 25.0 then
			DrawText3D(location["pos"]["x"], location["pos"]["y"], location["pos"]["z"], "[~g~E~s~] Ponto de entrega")

			if IsControlJustReleased(0, 38) and distance < 2.0 then
				break
			end
		end

        if rusticosotemideiasmerdasesseserverezap == 0 then
            Citizen.Wait(1000)
            break
        end
	end

    DeleteBlip()

    local hasItem = exports["caue-inventory"]:hasEnoughOfItem("delivery_supply", 1, false, true)
    if hasItem then
        TriggerEvent("animation:PlayAnimation", "clipboard")

        Citizen.Wait(4000)

        TriggerEvent("animation:PlayAnimation", "c")

        TriggerEvent("inventory:removeItem", "delivery_supply", 1)
        TriggerServerEvent("caue-heists:complete", math.random(5, 15))

        rusticosotemideiasmerdasesseserverezap = rusticosotemideiasmerdasesseserverezap - 10

        if rusticosotemideiasmerdasesseserverezap > 0 then
            TriggerEvent("caue-tacoshop:supplyStart")
        else
            TriggerEvent("caue-tacoshop:supplyEnd")
        end
    elseif not hasItem and rusticosotemideiasmerdasesseserverezap > 0 then
        TriggerEvent("caue-tacoshop:supplyEnd")
    end
end)

AddEventHandler("caue-tacoshop:supplyEnd", function()
    rusticosotemideiasmerdasesseserverezap = 0

    local deliveryItens = exports["caue-inventory"]:getQuantity("delivery_supply")
    if deliveryItens > 0 then
        TriggerEvent("inventory:removeItem", "delivery_supply", deliveryItens)
    end

    DeleteBlip()

    TriggerEvent("DoLongHudText", "Volte e pegue mais suprimentos para a loja")
end)

--[[

    Threads

]]

Citizen.CreateThread(function()
    exports["caue-polytarget"]:AddBoxZone("caue-tacoshop:supply", vector3(-71.48, -1821.41, 26.94), 0.9, 0.9, {
        heading=0,
        minZ=24.65,
        maxZ=26.65
    })

    exports["caue-eye"]:AddPeekEntryByPolyTarget("caue-tacoshop:supply", {{
        event = "caue-tacoshop:supplyStation",
        id = "tacoshop_supplyStart",
        icon = "box",
        label = "Iniciar Reabastecimento",
        parameters = { stationId = 1 }
    }}, { distance = { radius = 3.5 }, isEnabled = function() return rusticosotemideiasmerdasesseserverezap == 0 end })

    exports["caue-eye"]:AddPeekEntryByPolyTarget("caue-tacoshop:supply", {{
        event = "caue-tacoshop:supplyStation",
        id = "tacoshop_supplyStop",
        icon = "box",
        label = "Cancelar Reabastecimento",
        parameters = { stationId = 2 }
    }}, { distance = { radius = 3.5 }, isEnabled = function() return rusticosotemideiasmerdasesseserverezap > 0 end })



end)