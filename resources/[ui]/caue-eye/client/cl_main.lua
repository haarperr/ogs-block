--[[

    Variables

]]

local PeekEntries = {
    ["model"] = {},
    ["flag"] = {},
    ["entity"] = {},
    ["polytarget"] = {},
}

local IsPeeking = false
local IsPeakActive = false
local EyeActive = false

CurrentZone = nil
CurrentZoneData = {}
CurrentTarget = nil
CurrentTargetType = 0
CurrentTargetOffset = nil

--[[

    Functions

]]

function StartPeekin()
    if IsPeeking then return end
    if IsPedArmed(PlayerPedId(), 6) then return end

    IsPeeking = true

    SendNUIMessage({response = "openTarget"})

    while IsPeeking do

            DisablePlayerFiring(PlayerPedId(), true)

            local plyCoords = GetEntityCoords(PlayerPedId())

            if CurrentTarget or CurrentZone then
                if CurrentTargetType ~= 0 then
                    local _CurrentTarget = CurrentTarget
                    local targetCoords = GetEntityCoords(CurrentTarget)
                    local context = GetEntityContext(CurrentTarget)

                    local _data = {}
                    local _options = {}

                    if PeekEntries["model"][context.model] then
                        for k, v in pairs(PeekEntries["model"][context.model]) do
                            if checkOption(v["options"], context, targetCoords) then
                                table.insert(_data, v["data"])
                                table.insert(_options, v["options"])
                            end
                        end
                    end

                    if PeekEntries["entity"][context.type] then
                        for k, v in pairs(PeekEntries["entity"][context.type]) do
                            if checkOption(v["options"], context, targetCoords) then
                                table.insert(_data, v["data"])
                                table.insert(_options, v["options"])
                            end
                        end
                    end

                    for k, v in pairs(context.flags) do
                        if PeekEntries["flag"][k] then
                            if v == true then
                                for k, v in pairs(PeekEntries["flag"][k]) do
                                    if checkOption(v["options"], context, targetCoords) then
                                        table.insert(_data, v["data"])
                                        table.insert(_options, v["options"])
                                    end
                                end
                            end
                        end
                    end

                    if _data[1] then
                        IsPeakActive = true

                        for i, v in ipairs(_data) do
                            _data[i]["entity"] = CurrentTarget
                            _data[i]["context"] = context
                            _data[i]["coords"] = targetCoords
                        end

                        SendNUIMessage({
                            response = "validTarget",
                            data = _data
                        })

                        while IsPeakActive do
                            local plyCoords = GetEntityCoords(PlayerPedId())

                            DisablePlayerFiring(PlayerPedId(), true)

                            if (IsControlJustReleased(0, 24) or IsDisabledControlJustReleased(0, 24)) then
                                EyeActive = true
                                SetNuiFocus(true, true)
                                SetCursorLocation(0.5, 0.5)
                            end

                            for i, v in ipairs(_options) do
                                if _CurrentTarget ~= CurrentTarget or (v["radius"] and #(plyCoords - targetCoords) > v["radius"]) then
                                    IsPeakActive = false
                                end
                            end

                            Citizen.Wait(1)
                        end

                        SendNUIMessage({
                            response = "leftTarget"
                        })
                    end
                end

                if CurrentZone then
                    local _CurrentZone = CurrentZone
                    local targetCoords = CurrentZoneData.zoneCenter
                    local context = GetEntityContext(CurrentTarget)

                    context.zones = {}
                    context.zones[CurrentZone] = CurrentZoneData.zoneData

                    local _data = {}
                    local _options = {}

                    for k, v in pairs(PeekEntries["polytarget"][CurrentZone]) do
                        if checkOption(v["options"], context, targetCoords) then
                            table.insert(_data, v["data"])
                            table.insert(_options, v["options"])
                        end
                    end

                    if _data[1] then
                        IsPeakActive = true

                        for i, v in ipairs(_data) do
                            _data[i]["entity"] = CurrentTarget
                            _data[i]["context"] = context
                            _data[i]["coords"] = targetCoords
                        end

                        SendNUIMessage({
                            response = "validTarget",
                            data = _data
                        })

                        while IsPeakActive do
                            local plyCoords = GetEntityCoords(PlayerPedId())

                            DisablePlayerFiring(PlayerPedId(), true)

                            if (IsControlJustReleased(0, 24) or IsDisabledControlJustReleased(0, 24)) then
                                EyeActive = true
                                SetNuiFocus(true, true)
                                SetCursorLocation(0.5, 0.5)
                            end

                            for i, v in ipairs(_options) do
                                if not CurrentZone or _CurrentZone ~= CurrentZone or (v["radius"] and #(plyCoords - targetCoords) > v["radius"]) then
                                    IsPeakActive = false
                                end
                            end

                            Citizen.Wait(1)
                        end

                        SendNUIMessage({
                            response = "leftTarget"
                        })
                    end
                end
            end

        Citizen.Wait(250)
    end
end

function StopPeekin()
    if not IsPeeking then return end
    if EyeActive then return end

    IsPeeking = false
    IsPeakActive = false
    EyeActive = false

    SendNUIMessage({response = "closeTarget"})
end

function AddPeekEntry(pType, pGroup, pData, pOptions)
    local entries = PeekEntries[pType]

    if not entries then
        print(pType .. " Não é um tipo valido")
        return
    end

    local addEntry = function(group, data, options)
        if not entries[group] then entries[group] = {} end

        local groupEntries = entries[group]

        for _, entry in ipairs(data) do
            if not entry.id then print("Faltando um ID para " .. group) end

            groupEntries[entry.id] = { data = entry, options = options }
        end
    end

    if type(pGroup) ~= "table" then
        addEntry(pGroup, pData, pOptions)
        return
    end

    for _, group in ipairs(pGroup) do
        addEntry(group, pData, pOptions)
    end
end

function AddPeekEntryByModel(pModel, pData, pOptions)
    AddPeekEntry("model", pModel, pData, pOptions)
end

function AddPeekEntryByFlag(pFlag, pData, pOptions)
    AddPeekEntry("flag", pFlag, pData, pOptions)
end

function AddPeekEntryByEntityType(pEntityType, pData, pOptions)
    AddPeekEntry("entity", pEntityType, pData, pOptions)
end

function AddPeekEntryByPolyTarget(pEvent, pData, pOptions)
    AddPeekEntry("polytarget", pEvent, pData, pOptions)
end

function checkOption(options, context, coords)
    local canShow = true

    if options["distance"] and canShow then
        local plyCoords = GetEntityCoords(PlayerPedId())

        if options["distance"]["radius"] and canShow then
            if #(plyCoords - coords) > options["distance"]["radius"] then
                canShow = false
            end
        end

        if options["distance"]["boneId"]then
            local bone = options["distance"]["boneId"]
            local boneIndex = type(bone) == "string" and GetEntityBoneIndexByName(CurrentTarget, bone) or GetPedBoneIndex(CurrentTarget, bone)
            local boneCoords = GetWorldPositionOfEntityBone(CurrentTarget, boneIndex)

            if #(plyCoords - boneCoords) > options["distance"]["radius"] then
                canShow = false
            elseif not canShow then
                canShow = true
            end
        end
    end

    if options["isEnabled"] and canShow then
        canShow = options["isEnabled"](CurrentTarget, context)
    end

    return canShow
end

--[[

    Exports

]]

exports("AddPeekEntry", AddPeekEntry)
exports("AddPeekEntryByModel", AddPeekEntryByModel)
exports("AddPeekEntryByFlag", AddPeekEntryByFlag)
exports("AddPeekEntryByEntityType", AddPeekEntryByEntityType)
exports("AddPeekEntryByPolyTarget", AddPeekEntryByPolyTarget)

--[[

    Events

]]

AddEventHandler("caue:target:changed", function(pTarget, pEntityType, pEntityOffset)
    CurrentTarget = pTarget
    CurrentTargetType = pEntityType
    CurrentTargetOffset = pEntityOffset
end)

AddEventHandler("caue-polyzone:enter", function(zoneName, zoneData, zoneCenter)
    if not PeekEntries["polytarget"][zoneName] then return end

    CurrentZone = zoneName
    CurrentZoneData = {
        ["zoneData"] = zoneData,
        ["zoneCenter"] = zoneCenter
    }
end)

AddEventHandler("caue-polyzone:exit", function(zoneName)
    if not PeekEntries["polytarget"][zoneName] then return end

    CurrentZone = nil
    CurrentZoneData = {}
end)

--[[

    NUI

]]

RegisterNUICallback("selectTarget", function(data, cb)
    if EyeActive then
        SetNuiFocus(false, false)
    end

    IsPeakActive = false
    IsPeeking = false
    EyeActive = false

    TriggerEvent(data.event, data.parameters, data.entity, data.context, data.coords)
end)

RegisterNUICallback("closeTarget", function(data, cb)
    if EyeActive then
        SetNuiFocus(false, false)
    end

    IsPeakActive = false
    IsPeeking = false
    EyeActive = false
end)

--[[

    Threads

]]

Citizen.CreateThread(function()
    RegisterCommand("+targetInteract", StartPeekin, false)
    RegisterCommand("-targetInteract", StopPeekin, false)
    exports["caue-keybinds"]:registerKeyMapping("", "Player", "Peek at Target", "+targetInteract", "-targetInteract", "LMENU")
end)

-- Citizen.CreateThread(function()
--     while true do
--         if IsPeeking then
--             DisablePlayerFiring(PlayerPedId(), true)

--             local plyCoords = GetEntityCoords(PlayerPedId())

--             if CurrentTarget then
--                 if CurrentTargetType ~= 0 then
--                     local _CurrentTarget = CurrentTarget
--                     local targetCoords = GetEntityCoords(CurrentTarget)
--                     local context = GetEntityContext(CurrentTarget)

--                     local _data = {}
--                     local _options = {}

--                     if PeekEntries["model"][context.model] then
--                         for k, v in pairs(PeekEntries["model"][context.model]) do
--                             if checkOption(v["options"], context, targetCoords) then
--                                 table.insert(_data, v["data"])
--                                 table.insert(_options, v["options"])
--                             end
--                         end
--                     end

--                     if PeekEntries["entity"][context.type] then
--                         for k, v in pairs(PeekEntries["entity"][context.type]) do
--                             if checkOption(v["options"], context, targetCoords) then
--                                 table.insert(_data, v["data"])
--                                 table.insert(_options, v["options"])
--                             end
--                         end
--                     end

--                     for k, v in pairs(context.flags) do
--                         if PeekEntries["flag"][k] then
--                             if v == true then
--                                 for k, v in pairs(PeekEntries["flag"][k]) do
--                                     if checkOption(v["options"], context, targetCoords) then
--                                         table.insert(_data, v["data"])
--                                         table.insert(_options, v["options"])
--                                     end
--                                 end
--                             end
--                         end
--                     end

--                     if _data[1] then
--                         IsPeakActive = true

--                         for i, v in ipairs(_data) do
--                             _data[i]["entity"] = CurrentTarget
--                             _data[i]["context"] = context
--                             _data[i]["coords"] = targetCoords
--                         end

--                         SendNUIMessage({
--                             response = "validTarget",
--                             data = _data
--                         })

--                         while IsPeakActive do
--                             local plyCoords = GetEntityCoords(PlayerPedId())

--                             DisablePlayerFiring(PlayerPedId(), true)

--                             if (IsControlJustReleased(0, 24) or IsDisabledControlJustReleased(0, 24)) then
--                                 EyeActive = true
--                                 SetNuiFocus(true, true)
--                                 SetCursorLocation(0.5, 0.5)
--                             end

--                             for i, v in ipairs(_options) do
--                                 if _CurrentTarget ~= CurrentTarget or (v["radius"] and #(plyCoords - targetCoords) > v["radius"]) then
--                                     IsPeakActive = false
--                                 end
--                             end

--                             Citizen.Wait(1)
--                         end

--                         SendNUIMessage({
--                             response = "leftTarget"
--                         })
--                     end
--                 end

--                 if CurrentZone then
--                     local _CurrentZone = CurrentZone
--                     local targetCoords = CurrentZoneData.zoneCenter
--                     local _data = PeekEntries["polytarget"][CurrentZone]["data"]
--                     local _options = PeekEntries["polytarget"][CurrentZone]["options"]
--                     local context = GetEntityContext(CurrentTarget)

--                     if _options then
--                         if checkOption(_options, context, targetCoords) then
--                             IsPeakActive = true

--                             SendNUIMessage({
--                                 response = "validTarget",
--                                 data = _data
--                             })

--                             while IsPeakActive do
--                                 local plyCoords = GetEntityCoords(PlayerPedId())

--                                 DisablePlayerFiring(PlayerPedId(), true)

--                                 if (IsControlJustReleased(0, 24) or IsDisabledControlJustReleased(0, 24)) then
--                                     EyeActive = true
--                                     SetNuiFocus(true, true)
--                                     SetCursorLocation(0.5, 0.5)
--                                 end

--                                 if not CurrentZone or _CurrentZone ~= CurrentZone or #(plyCoords - targetCoords) > _options["distance"]["radius"] then
--                                     IsPeakActive = false
--                                 end

--                                 Citizen.Wait(1)
--                             end

--                             SendNUIMessage({
--                                 response = "leftTarget"
--                             })
--                         end
--                     end
--                 end
--             end
--         end

--         Citizen.Wait(250)
--     end
-- end)