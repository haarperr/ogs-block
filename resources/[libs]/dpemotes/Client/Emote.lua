-- You probably shouldnt touch these.
local AnimationDuration = -1
local ChosenAnimation = ""
local ChosenDict = ""
local IsInAnimation = false
local MostRecentChosenAnimation = ""
local MostRecentChosenDict = ""
local MovementType = 0
local PlayerGender = "male"
local PlayerHasProp = false
local PlayerProps = {}
local PlayerParticles = {}
local SecondPropEmote = false
local PtfxNotif = false
local PtfxPrompt = false
local PtfxWait = 500
local PtfxNoProp = false

Citizen.CreateThread(function()
    while true do
        if IsPedShooting(PlayerPedId()) and IsInAnimation then
            EmoteCancel()
        end

        if PtfxPrompt then
            if not PtfxNotif then
                exports["caue-interaction"]:showInteraction(PtfxInfo)
                PtfxNotif = true
            end

            if IsControlPressed(0, 47) then
                PtfxStart()
                Wait(PtfxWait)
                PtfxStop()
            end
        end

        Citizen.Wait(1)
    end
end)

-----------------------------------------------------------------------------------------------------
-- Commands / Events --------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------

RegisterNetEvent("dpemotes:emotes")
AddEventHandler("dpemotes:emotes", function()
    OpenEmoteMenu()
end)

RegisterNetEvent("dpemotes:e")
AddEventHandler("dpemotes:e", function(pArgs)
    EmoteCommandStart(0, pArgs)
end)

RegisterNetEvent("dpemotes:binds")
AddEventHandler("dpemotes:binds", function()
    EmoteBindsStart()
end)

RegisterNetEvent("dpemotes:bind")
AddEventHandler("dpemotes:bind", function(pArgs)
    EmoteBindStart(0, pArgs)
end)

-----------------------------------------------------------------------------------------------------
------ Functions and stuff --------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------

function EmoteCancel()
    if ChosenDict == "MaleScenario" and IsInAnimation then
        ClearPedTasksImmediately(PlayerPedId())
        IsInAnimation = false
    elseif ChosenDict == "Scenario" and IsInAnimation then
        ClearPedTasksImmediately(PlayerPedId())
        IsInAnimation = false
    end

    if PtfxNotif then
        exports["caue-interaction"]:hideInteraction()
    end

    PtfxNotif = false
    PtfxPrompt = false

    if IsInAnimation then
        PtfxStop()
        ClearPedTasks(PlayerPedId())
        DestroyAllProps()
        IsInAnimation = false
    end

    TriggerEvent("animation:cancel")
end

function PtfxStart()
    if PtfxNoProp then
        PtfxAt = PlayerPedId()
    else
        PtfxAt = prop
    end
    UseParticleFxAssetNextCall(PtfxAsset)
    Ptfx = StartNetworkedParticleFxLoopedOnEntityBone(PtfxName, PtfxAt, Ptfx1, Ptfx2, Ptfx3, Ptfx4, Ptfx5, Ptfx6, GetEntityBoneIndexByName(PtfxName, "VFX"), 1065353216, 0, 0, 0, 1065353216, 1065353216, 1065353216, 0)
    SetParticleFxLoopedColour(Ptfx, 1.0, 1.0, 1.0)
    table.insert(PlayerParticles, Ptfx)
end

function PtfxStop()
    for a,b in pairs(PlayerParticles) do
        StopParticleFxLooped(b, false)
        table.remove(PlayerParticles, a)
    end
end

function pairsByKeys(t, f)
    local a = {}
    for n in pairs(t) do
        table.insert(a, n)
    end
    table.sort(a, f)
    local i = 0      -- iterator variable
    local iter = function ()   -- iterator function
        i = i + 1
        if a[i] == nil then
            return nil
        else
            return a[i], t[a[i]]
        end
    end
    return iter
end

function EmoteMenuStart(args, hard)
    local name = args
    local etype = hard

    if etype == "dances" then
        if DP.Dances[name] ~= nil then
            OnEmotePlay(DP.Dances[name])
        end
    elseif etype == "props" then
        if DP.PropEmotes[name] ~= nil then
            OnEmotePlay(DP.PropEmotes[name])
        end
    elseif etype == "emotes" then
        if DP.Emotes[name] ~= nil then
            OnEmotePlay(DP.Emotes[name])
        else
            if name ~= "🕺 Dance Emotes" then end
        end
    elseif etype == "expression" then
        if DP.Expressions[name] ~= nil then
            OnEmotePlay(DP.Expressions[name])
        end
    end
end

function EmoteCommandStart(source, args, raw)
    if #args > 0 then
        local name = string.lower(args[1])

        if name == "c" then
            EmoteCancel()
            return
        end

        if DP.Emotes[name] ~= nil then
            OnEmotePlay(DP.Emotes[name])
        elseif DP.Dances[name] ~= nil then
            OnEmotePlay(DP.Dances[name])
        elseif DP.PropEmotes[name] ~= nil then
            OnEmotePlay(DP.PropEmotes[name])
        else
            TriggerEvent("DoLongHudText", name .. " is not a valid emote.", 2)
        end
    end
end

function LoadAnim(dict)
    while not HasAnimDictLoaded(dict) do
        RequestAnimDict(dict)
        Wait(10)
    end
end

function LoadPropDict(model)
    while not HasModelLoaded(GetHashKey(model)) do
        RequestModel(GetHashKey(model))
        Wait(10)
    end
end

function PtfxThis(asset)
    while not HasNamedPtfxAssetLoaded(asset) do
        RequestNamedPtfxAsset(asset)
        Wait(10)
    end
    UseParticleFxAssetNextCall(asset)
end

function DestroyAllProps()
    for _,v in pairs(PlayerProps) do
        DeleteEntity(v)
    end
    PlayerHasProp = false
end

function AddPropToPlayer(prop1, bone, off1, off2, off3, rot1, rot2, rot3)
    local Player = PlayerPedId()
    local x,y,z = table.unpack(GetEntityCoords(Player))

    if not HasModelLoaded(prop1) then
        LoadPropDict(prop1)
    end

    prop = CreateObject(GetHashKey(prop1), x, y, z+0.2,  true,  true, true)
    AttachEntityToEntity(prop, Player, GetPedBoneIndex(Player, bone), off1, off2, off3, rot1, rot2, rot3, true, true, false, true, 1, true)
    table.insert(PlayerProps, prop)
    PlayerHasProp = true
    SetModelAsNoLongerNeeded(prop1)
end

-----------------------------------------------------------------------------------------------------
-- V -- This could be a whole lot better, i tried messing around with "IsPedMale(ped)"
-- V -- But i never really figured it out, if anyone has a better way of gender checking let me know.
-- V -- Since this way doesnt work for ped models.
-- V -- in most cases its better to replace the scenario with an animation bundled with prop instead.
-----------------------------------------------------------------------------------------------------

function CheckGender()
    local hashSkinMale = GetHashKey("mp_m_freemode_01")
    local hashSkinFemale = GetHashKey("mp_f_freemode_01")

    if GetEntityModel(PlayerPedId()) == hashSkinMale then
        PlayerGender = "male"
    elseif GetEntityModel(PlayerPedId()) == hashSkinFemale then
        PlayerGender = "female"
    end
end

-----------------------------------------------------------------------------------------------------
------ This is the major function for playing emotes! -----------------------------------------------
-----------------------------------------------------------------------------------------------------

function OnEmotePlay(EmoteName)
    -- InVehicle = IsPedInAnyVehicle(PlayerPedId(), true)
    -- if InVehicle == 1 then
    --     return
    -- end

    if not DoesEntityExist(PlayerPedId()) then
        return false
    end

    if isDisabled() then
        return false
    end

    ChosenDict,ChosenAnimation,ename = table.unpack(EmoteName)
    AnimationDuration = -1

    if PlayerHasProp then
        DestroyAllProps()
    end

    if ChosenDict == "Expression" then
        TriggerEvent("expressions", {ChosenAnimation})
        return
    end

    if ChosenDict == "MaleScenario" or "Scenario" then
        CheckGender()

        if ChosenDict == "MaleScenario" then if InVehicle then return end
            if PlayerGender == "male" then
                ClearPedTasks(PlayerPedId())
                TaskStartScenarioInPlace(PlayerPedId(), ChosenAnimation, 0, true)
                IsInAnimation = true
            else
                TriggerEvent("DoLongHudText", "This emote is male only, sorry!", 2)
            end

            return
        elseif ChosenDict == "ScenarioObject" then if InVehicle then return end
            BehindPlayer = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 0 - 0.5, -0.5);
            ClearPedTasks(PlayerPedId())
            TaskStartScenarioAtPosition(PlayerPedId(), ChosenAnimation, BehindPlayer["x"], BehindPlayer["y"], BehindPlayer["z"], GetEntityHeading(PlayerPedId()), 0, 1, false)
            IsInAnimation = true

            return
        elseif ChosenDict == "Scenario" then if InVehicle then return end
            ClearPedTasks(PlayerPedId())
            TaskStartScenarioInPlace(PlayerPedId(), ChosenAnimation, 0, true)
            IsInAnimation = true
            return
        end
    end

    LoadAnim(ChosenDict)

    if EmoteName.AnimationOptions then
        if EmoteName.AnimationOptions.EmoteLoop then
            MovementType = 1

            if EmoteName.AnimationOptions.EmoteMoving then
                MovementType = 51
            end
        elseif EmoteName.AnimationOptions.EmoteMoving then
            MovementType = 51
        elseif EmoteName.AnimationOptions.EmoteMoving == false then
            MovementType = 0
        elseif EmoteName.AnimationOptions.EmoteStuck then
            MovementType = 50
        end
    else
        MovementType = 0
    end

    if InVehicle == 1 then
        MovementType = 51
    end

    if EmoteName.AnimationOptions then
        if EmoteName.AnimationOptions.EmoteDuration == nil then
            EmoteName.AnimationOptions.EmoteDuration = -1
            AttachWait = 0
        else
            AnimationDuration = EmoteName.AnimationOptions.EmoteDuration
            AttachWait = EmoteName.AnimationOptions.EmoteDuration
        end

        if EmoteName.AnimationOptions.PtfxAsset then
            PtfxAsset = EmoteName.AnimationOptions.PtfxAsset
            PtfxName = EmoteName.AnimationOptions.PtfxName

            if EmoteName.AnimationOptions.PtfxNoProp then
                PtfxNoProp = EmoteName.AnimationOptions.PtfxNoProp
            else
                PtfxNoProp = false
            end

            Ptfx1, Ptfx2, Ptfx3, Ptfx4, Ptfx5, Ptfx6, PtfxScale = table.unpack(EmoteName.AnimationOptions.PtfxPlacement)
            PtfxInfo = EmoteName.AnimationOptions.PtfxInfo
            PtfxWait = EmoteName.AnimationOptions.PtfxWait

            if PtfxNotif then
                exports["caue-interaction"]:hideInteraction()
            end

            PtfxNotif = false
            PtfxPrompt = true

            PtfxThis(PtfxAsset)
        else
            PtfxPrompt = false
        end
    end

    TaskPlayAnim(PlayerPedId(), ChosenDict, ChosenAnimation, 2.0, 2.0, AnimationDuration, MovementType, 0, false, false, false)
    RemoveAnimDict(ChosenDict)

    IsInAnimation = true
    MostRecentDict = ChosenDict
    MostRecentAnimation = ChosenAnimation

    if EmoteName.AnimationOptions then
        if EmoteName.AnimationOptions.Prop then
            PropName = EmoteName.AnimationOptions.Prop
            PropBone = EmoteName.AnimationOptions.PropBone
            PropPl1, PropPl2, PropPl3, PropPl4, PropPl5, PropPl6 = table.unpack(EmoteName.AnimationOptions.PropPlacement)

            if EmoteName.AnimationOptions.SecondProp then
                SecondPropName = EmoteName.AnimationOptions.SecondProp
                SecondPropBone = EmoteName.AnimationOptions.SecondPropBone
                SecondPropPl1, SecondPropPl2, SecondPropPl3, SecondPropPl4, SecondPropPl5, SecondPropPl6 = table.unpack(EmoteName.AnimationOptions.SecondPropPlacement)
                SecondPropEmote = true
            else
                SecondPropEmote = false
            end

            Wait(AttachWait)

            AddPropToPlayer(PropName, PropBone, PropPl1, PropPl2, PropPl3, PropPl4, PropPl5, PropPl6)
            if SecondPropEmote then
                AddPropToPlayer(SecondPropName, SecondPropBone, SecondPropPl1, SecondPropPl2, SecondPropPl3, SecondPropPl4, SecondPropPl5, SecondPropPl6)
            end
        end
    end

    return true
end