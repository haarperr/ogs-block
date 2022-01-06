--[[

    Variables

]]

local ped = PlayerPedId()
local playerCoords = GetEntityCoords(ped)
local inveh = IsPedInAnyVehicle(ped, false)

local Pooling = {}
local PoolingActive = false
local PoolCounter = 0

local Drops = {}
local currentInformation = 0

local scannedEvidence = {}

local currentWeather = "SUNNY"
local override = false

local cached = false
local scannedEvidenceCache = {}

local triggered = false
local counter = 0

--[[

    Functions

]]

function WaterTest()
    local fV, sV = TestVerticalProbeAgainstAllWater(playerCoords.x, playerCoords.y, playerCoords.z, 0, 1.0)
    return fV
end

function SendPooling()
    TriggerServerEvent("evidence:pooled", Drops)
    Drops = {}
end

local function CameraForwardVec()
    local rot = (math.pi / 180.0) * GetGameplayCamRot(2)
    return vector3(-math.sin(rot.z) * math.abs(math.cos(rot.x)), math.cos(rot.z) * math.abs(math.cos(rot.x)), math.sin(rot.x))
end

function Raycast(dist)
    local start = GetGameplayCamCoord()
    local target = start + (CameraForwardVec() * dist)

    local ray = StartShapeTestRay(start, target, -1, PlayerPedId(), 1)
    local a, b, c, d, ent = GetShapeTestResult(ray)

    return {
        a = a,
        b = b,
        HitPosition = c,
        HitCoords = d,
        HitEntity = ent
    }
end

function DrawText3Ds(x,y,z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    local px, py, pz = table.unpack(GetGameplayCamCoords())
    SetTextScale(0.28, 0.28)
    SetTextFont(4)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 245)
    SetTextOutline(true)
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x, _y)
end


function PickUpItem(id,eType,other,item)
    information = {
        ["identifier"] = id,
        ["eType"] = eType,
        ["other"] = other,
    }

    TriggerEvent("player:receiveItem", item, 1, true, information)
end


--[[

    Events

]]

RegisterNetEvent("PoolingEvidence")
AddEventHandler("PoolingEvidence", function()
    if PoolingActive then
        return
    else
        PoolingActive = true
        PoolCounter = 5
        while PoolCounter > 0 do
            PoolCounter = PoolCounter - 1
            Wait(1000)
        end
        PoolingActive = false
        SendPooling()
    end
end)

RegisterNetEvent("evidence:pooled")
AddEventHandler("evidence:pooled", function(PooledData)
    for k, v in pairs(PooledData) do
        scannedEvidence[k] = v
    end
end)

RegisterNetEvent("evidence:remove:done")
AddEventHandler("evidence:remove:done", function(Id)
    scannedEvidence[Id] = nil
end)

RegisterNetEvent("evidence:clear")
AddEventHandler("evidence:clear", function()
    local DeleteIds = {}

    for k, v in pairs(scannedEvidence) do
        local evidenceDistance = Vdist(v.x, v.y, v.z, playerCoords)
        if evidenceDistance < 10.0 then
            DeleteIds[#DeleteIds + 1] = k
        end
    end

    TriggerServerEvent("evidence:clear", DeleteIds)
end)

RegisterNetEvent("evidence:clear:done")
AddEventHandler("evidence:clear:done", function(DeleteIds)
    for i = 1, #DeleteIds do
        scannedEvidence[DeleteIds[i]] = nil
    end
end)

RegisterNetEvent("evidence:bulletInformation")
AddEventHandler("evidence:bulletInformation", function(information)
    currentInformation = information
end)

RegisterNetEvent("CacheEvidence")
AddEventHandler("CacheEvidence", function()
    scannedEvidenceCache = {}
    cached = true

    for k, v in pairs(scannedEvidence) do
        scandst = Vdist(v.x, v.y, v.z, playerCoords)
        if scandst < 80 then
            scannedEvidenceCache[k] = v
        end
    end

    Wait(5000)

    cached = false
end)

RegisterNetEvent("kWeatherSync")
AddEventHandler("kWeatherSync", function(sentInfo)
    currentWeather = sentInfo
end)

RegisterNetEvent("inside:weather")
AddEventHandler("inside:weather", function(sentInfo)
    override = sentInfo
end)

RegisterNetEvent("evidence:bleeding")
AddEventHandler("evidence:bleeding", function()
    if inveh then
        return
    end

    if not WaterTest() then
        local ped = PlayerPedId()
        local cid = exports["caue-base"]:getChar("id")
        local blood = "DNA-" .. cid

        local uniqueEvidenceId = playerCoords.x .. "-" .. playerCoords.y .. "-" .. playerCoords.x

        if Drops == nil then
            Drops = {}
        end

        TriggerEvent("PoolingEvidence")

        local raining = false
        if override or currentWeather == "RAIN" then
            raining = true
        end

        Drops[uniqueEvidenceId] = {
            ["x"] = playerCoords.x,
            ["y"] = playerCoords.y,
            ["z"] = playerCoords.z-0.7,
            ["deactivated"] = false,
            ["meta"] = {
                ["evidenceType"] = "blood",
                ["identifier"] = blood,
                ["other"] = "Partial Human DNA",
                ["raining"] = raining,
            },
        }
    end
end)

RegisterNetEvent("evidence:trigger")
AddEventHandler("evidence:trigger", function()
    if triggered then
        counter = 5
        return
    else
        counter = 5
        triggered = true

        while counter > 0 do
            Citizen.Wait(1000)

            if not IsPedUsingScenario(ped, "WORLD_HUMAN_PAPARAZZI") then
                counter = counter - 1
            end
        end

        triggered = false
    end
end)

--[[

    Threads

]]

Citizen.CreateThread(function()
    while true do
        ped = PlayerPedId()
        playerCoords = GetEntityCoords(ped)
        inveh = IsPedInAnyVehicle(ped, false)

        Citizen.Wait(500)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)

        if not IsPedArmed(ped, 7) then
            Citizen.Wait(1000)
        else
            if WaterTest() then
                Citizen.Wait(1000)
            else
                if IsPedShooting(ped) then
                    local x = math.random(20) / 10
                    local y = math.random(20) / 10

                    if (math.random(2) == 1) then
                        y = (0 - y)
                    end

                    x, y, z = table.unpack(GetOffsetFromEntityInWorldCoords(ped, x, y, -0.7))
                    if inveh then
                        z = z + 0.7
                    end

                    local uniqueEvidenceId = x .. "-" .. y .. "-" .. x

                    TriggerEvent("PoolingEvidence")

                    local a = Raycast(150.0)

                    if a.HitPosition then
                        if IsEntityAVehicle(a.HitEntity) and math.random(4) > 1 then
                            local r, g, b = GetVehicleColor(a.HitEntity)

                            if color1 ~= 0 then
                                Drops[uniqueEvidenceId .. "-p"] = {
                                    ["x"] = a.HitPosition.x,
                                    ["y"] = a.HitPosition.y,
                                    ["z"] = a.HitPosition.z,
                                    ["deactivated"] = false,
                                    ["meta"] = {
                                        ["evidenceType"] = "vehiclefragment",
                                        ["identifier"] = { ["r"] = r, ["g"] = g, ["b"] = b },
                                        ["other"] = "(r:" .. r .. ", g:" .. g .. ", b:" .. b .. ") Colored Vehicle Fragment"
                                    },
                                }
                            end
                        else
                            if a.HitPosition.x ~= 0.0 and a.HitPosition.y ~= 0.0 then
                                Drops[uniqueEvidenceId .. "-p"] = {
                                    ["x"] = a.HitPosition.x,
                                    ["y"] = a.HitPosition.y,
                                    ["z"] = a.HitPosition.z,
                                    ["deactivated"] = false,
                                    ["meta"] = {
                                        ["evidenceType"] = "projectile",
                                        ["identifier"] = currentInformation,
                                        ["other"] = GetSelectedPedWeapon(ped),
                                        ["casingClass"] = GetWeapontypeGroup(GetSelectedPedWeapon(ped))
                                    },
                                }
                            end
                        end
                    end

                    Drops[uniqueEvidenceId] = {
                        ["x"] = x,
                        ["y"] = y,
                        ["z"] = z,
                        ["deactivated"] = false,
                        ["meta"] = {
                            ["evidenceType"] = "casing",
                            ["identifier"] = currentInformation,
                            ["other"] = GetSelectedPedWeapon(ped),
                            ["casingClass"] = GetWeapontypeGroup(GetSelectedPedWeapon(ped))
                        },
                    }

                    Citizen.Wait(100)
                end
            end
        end
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)

        if GetHashKey("WEAPON_FLASHLIGHT") == GetSelectedPedWeapon(ped) or triggered then
            if not cached then
                TriggerEvent("CacheEvidence")
            end

            local minScan = 70

            local closestID = false
            local closestIDs = {}

            for k, v in pairs(scannedEvidenceCache) do
                scandst = Vdist(v.x, v.y, v.z, playerCoords)

                if scandst < 20 then
                    if scandst < minScan then
                        minScan = scandst
                        closestID = k
                    end
                    if scandst < 2 then
                        closestIDs[#closestIDs + 1] = k
                    end
                end
            end

            for k, v in pairs(scannedEvidenceCache) do
                local evidenceDistance = Vdist(v.x, v.y, v.z, playerCoords)

                if (IsPlayerFreeAiming(PlayerId()) or triggered) and (evidenceDistance < 20) then
                    if v["meta"]["evidenceType"] == "blood" then
                        DrawMarker(28, v.x, v.y, v.z, 0, 0, 0, 0, 0, 0, 0.1, 0.1, 0.1, 202, 22, 22, 141, 0, 0, 0, 0)
                        DrawText3Ds(v.x, v.y, v.z+0.5, v["meta"]["other"] .. " | " .. v["meta"]["identifier"])
                    elseif v["meta"]["evidenceType"] == "casing" then
                        DrawText3Ds(v.x, v.y, v.z+0.25, v["meta"]["other"] .. " | " .. v["meta"]["identifier"])
                        DrawMarker(25, v.x, v.y, v.z, 0, 0, 0, 0, 0, 0, 0.1, 0.1, 0.1, 252, 255, 1, 141, 0, 0, 0, 0)
                    elseif v["meta"]["evidenceType"] == "projectile" then
                        DrawText3Ds(v.x, v.y, v.z+0.5, v["meta"]["other"] .. " | " .. v["meta"]["identifier"])
                        DrawMarker(41, v.x, v.y, v.z+0.2, 0, 0, 0, 0, 0, 0, 0.1, 0.1, 0.1, 13, 245, 1, 231, 0, 0, 0, 0)
                    elseif v["meta"]["evidenceType"] == "glass" then
                        DrawText3Ds(v.x, v.y, v.z+0.5, v["meta"]["other"] .. " | " .. v["meta"]["identifier"])
                        DrawMarker(23, v.x, v.y, v.z+0.2, 0, 0, 0, 0, 0, 0, 0.1, 0.1, 0.1, 13, 10, 0, 191, 0, 0, 0, 0)
                    elseif v["meta"]["evidenceType"] == "vehiclefragment" then
                        DrawText3Ds(v.x, v.y, v.z+0.5, v["meta"]["other"])
                        DrawMarker(36, v.x, v.y, v.z+0.2, 0, 0, 0, 0, 0, 0, 0.1, 0.1, 0.1, v["meta"]["identifier"]["r"], v["meta"]["identifier"]["g"], v["meta"]["identifier"]["b"], 255, 0, 0, 0, 0)
                    else
                        DrawText3Ds(v.x, v.y, v.z+0.5, v["meta"]["other"] .. " | " .. v["meta"]["identifier"])
                        DrawMarker(21, v.x, v.y, v.z, 0, 0, 0, 0, 0, 0, 0.1, 0.1, 0.1, 222, 255, 51, 91, 0, 0, 0, 0)
                    end
                end
            end

            if IsControlJustReleased(0,38) and minScan < 2.0 then
                local finished = exports["caue-taskbar"]:taskBar(3000, "Picking Up Item", "What?", true)
                if finished == 100 then
                    if not exports["caue-jobs"]:getJob(false, "is_police") then
                        Citizen.Wait(3000)
                        -- TriggerServerEvent("evidence:removal",Zone,closestID)
                        -- PickUpItem(Zone,scannedEvidence[closestID]["meta"]["identifier"],scannedEvidence[closestID]["meta"]["evidenceType"],scannedEvidence[closestID]["meta"]["other"],"casing")
                    else
                        local pickedUp = {}
                        for _, id in pairs(closestIDs) do
                            local evItem = "np_evidence_marker_yellow"
                            local evType = scannedEvidence[id]["meta"]["evidenceType"]

                            if evType == "blood" then
                                evItem = "np_evidence_marker_red"
                            elseif evType == "casing" then
                                evItem = "np_evidence_marker_white"
                            elseif evType == "projectile" then
                                evItem = "np_evidence_marker_orange"
                            elseif evType == "glass" then
                                evItem = "np_evidence_marker_light_blue"
                            elseif evType == "vehiclefragment" then
                                evItem = "np_evidence_marker_purple"
                            end

                            local pickedUpKey = scannedEvidence[id]["meta"]["identifier"] .. "_" .. evType
                            if not pickedUp[pickedUpKey] then
                                pickedUp[pickedUpKey] = true
                                PickUpItem(scannedEvidence[id]["meta"]["identifier"],evType,scannedEvidence[id]["meta"]["other"], evItem)
                                Citizen.Wait(500)
                            end
                        end

                        TriggerServerEvent("evidence:removal", closestID, closestIDs)
                        Citizen.Wait(3000)
                    end
                end
            end

            if minScan == 70 then
                local Timer = math.ceil(minScan * 10)
                Citizen.Wait(Timer)
            end
        else
            Citizen.Wait(1000)
        end
    end
end)