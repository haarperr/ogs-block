--[[

    Variables

]]

local texting = {}
local hidden = {}
local playerSource = 0

--[[

    Functions

]]

local function DrawText3D(x,y,z, text, textColor)
    local color = { r = 255, g = 255, b = 255, alpha = 255 }

    if textColor ~= nil then
        color = {r = textColor[1] or 255, g = textColor[2] or 255, b = textColor[3] or 255, alpha = textColor[4] or 255}
    end

    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    local dist = #(vector3(px,py,pz) - vector3(x,y,z))

    local scale = (1/dist)*2
    local fov = (1/GetGameplayCamFov())*100
    local scale = scale*fov

    if onScreen then
        SetTextScale(0.3,0.3)
        SetTextFont(0)
        SetTextProportional(1)
        SetTextColour(color.r, color.g, color.b, color.alpha)
        SetTextDropshadow(0, 0, 0, 0, 55)
        SetTextEdge(2, 0, 0, 0, 150)
        SetTextDropShadow()
        SetTextOutline()
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x,_y)
    end
end

--[[

    Events

]]

RegisterNetEvent("hud:HidePlayer")
AddEventHandler("hud:HidePlayer", function(player, toggle)
    if type(player) == "table" then
        for k,v in pairs(player) do
            if DoesPlayerExist(k) then
                local id = GetPlayerFromServerId(k)
                hidden[id] = k
            end
        end
        return
    end
    if DoesPlayerExist(player) then
        local id = GetPlayerFromServerId(player)
        if toggle == true then
            hidden[id] = player
        else
            for k,v in pairs(hidden) do
                if v == player then hidden[k] = nil end
            end
        end
    end
end)

RegisterNetEvent("caue-chat:texting")
AddEventHandler("caue-chat:texting", function(player, toggle)
    if type(player) == "table" then
        for k,v in pairs(player) do
            if DoesPlayerExist(k) then
                local id = GetPlayerFromServerId(k)
                texting[id] = k
            end
        end
        return
    end
    if DoesPlayerExist(player) then
        local id = GetPlayerFromServerId(player)
        if toggle == true then
            texting[id] = player
        else
            for k,v in pairs(texting) do
                if v == player then texting[k] = nil end
            end
        end
    end
end)

--[[

    Threads

]]

Citizen.CreateThread(function()
    while true do
        for i = 0, 255 do
            N_0x31698aa80e0223f8(i)
        end

        local playerped = PlayerPedId()
        local HeadBone = 0x796e

        for id = 0, 255 do
            if NetworkIsPlayerActive(id) then
                local ped = GetPlayerPed(id)

                local playerCoords = GetPedBoneCoords(playerped, HeadBone)

                if ped ~= playerped then
                    local pedCoords = GetPedBoneCoords(ped, HeadBone)

                    local distance = math.floor(#(playerCoords - pedCoords))

                    local isDucking = IsPedDucking(ped)
                    local cansee = HasEntityClearLosToEntity(playerped, ped, 17 )
                    local isReadyToShoot = IsPedWeaponReadyToShoot(ped)
                    local isStealth = GetPedStealthMovement(ped)
                    local isDriveBy = IsPedDoingDriveby(ped)
                    local isInCover = IsPedInCover(ped,true)

                    if isStealth == nil then
                        isStealth = 0
                    end

                    if isDucking or isStealth == 1 or isDriveBy or isInCover then
                        cansee = false
                    end

                    if hidden[id] then cansee = false end
                    if not texting[id] then cansee = false end

                    if distance < 20 then
                        if cansee then
                            DrawText3D(pedCoords.x, pedCoords.y, pedCoords.z + 0.5, "[...]", {243, 239, 5})
                        end
                    end
                end
            end
        end

        Citizen.Wait(1)
    end
end)