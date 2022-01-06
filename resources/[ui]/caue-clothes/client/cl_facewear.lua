--[[

    Variables

]]

local removedHatManually = false
local removedMaskManually = false

local facialWear = {
    [1] = { ["Prop"] = -1, ["Texture"] = -1 },
    [2] = { ["Prop"] = -1, ["Texture"] = -1 },
    [3] = { ["Prop"] = -1, ["Texture"] = -1 },
    [4] = { ["Prop"] = -1, ["Palette"] = -1, ["Texture"] = -1 }, -- this is actually a pedtexture variations, not a prop
    [5] = { ["Prop"] = -1, ["Palette"] = -1, ["Texture"] = -1 }, -- this is actually a pedtexture variations, not a prop
    [6] = { ["Prop"] = -1, ["Palette"] = -1, ["Texture"] = -1 }, -- this is actually a pedtexture variations, not a prop
}

--[[

    Functions

]]

function toggleFaceWear(pWearType, pShouldRemove)
    local AnimSet = "none"
    local AnimationOn = "none"
    local AnimationOff = "none"
    local PropIndex = 0

    local AnimSet = "mp_masks@on_foot"
    local AnimationOn = "put_on_mask"
    local AnimationOff = "put_on_mask"

    facialWear[6]["Prop"] = GetPedDrawableVariation(PlayerPedId(), 0)
    facialWear[6]["Palette"] = GetPedPaletteVariation(PlayerPedId(), 0)
    facialWear[6]["Texture"] = GetPedTextureVariation(PlayerPedId(), 0)

    for i = 0, 3 do
        if GetPedPropIndex(PlayerPedId(), i) ~= -1 then
            facialWear[i+1]["Prop"] = GetPedPropIndex(PlayerPedId(), i)
        end
        if GetPedPropTextureIndex(PlayerPedId(), i) ~= -1 then
            facialWear[i+1]["Texture"] = GetPedPropTextureIndex(PlayerPedId(), i)
        end
    end

    if GetPedDrawableVariation(PlayerPedId(), 1) ~= -1 then
        facialWear[4]["Prop"] = GetPedDrawableVariation(PlayerPedId(), 1)
        facialWear[4]["Palette"] = GetPedPaletteVariation(PlayerPedId(), 1)
        facialWear[4]["Texture"] = GetPedTextureVariation(PlayerPedId(), 1)
    end

    if GetPedDrawableVariation(PlayerPedId(), 9) ~= -1 then
        facialWear[5]["Prop"] = GetPedDrawableVariation(PlayerPedId(), 9)
        facialWear[5]["Palette"] = GetPedPaletteVariation(PlayerPedId(), 9)
        facialWear[5]["Texture"] = GetPedTextureVariation(PlayerPedId(), 9)
    end

    if pWearType == 1 then
        PropIndex = 0
    elseif pWearType == 2 then
        PropIndex = 1

        AnimSet = "clothingspecs"
        AnimationOn = "take_off"
        AnimationOff = "take_off"
    elseif pWearType == 3 then
        PropIndex = 2
    elseif pWearType == 4 then
        PropIndex = 1

        if pShouldRemove then
            AnimSet = "missfbi4"
            AnimationOn = "takeoff_mask"
            AnimationOff = "takeoff_mask"
        end
    elseif pWearType == 5 then
        PropIndex = 9
        AnimSet = "clothingtie"
        AnimationOn = "try_tie_positive_a"
        AnimationOff = "try_tie_positive_a"
    elseif pWearType == 6 then
        PropIndex = 6
    end

    if pWearType == 6 then
        local gender = exports["caue-base"]:getChar("gender")
        local bareFootIndex = 34

        if not IsPedMale(PlayerPedId()) or gender ~= 0 or GetEntityModel(PlayerPedId()) == `mp_f_freemode_01` then
            bareFootIndex = 35
        end

        SetPedComponentVariation(PlayerPedId(), PropIndex, bareFootIndex, 0, -1)

        return
    end

    loadAnimDict(AnimSet)

    local currentDrawable = GetPedDrawableVariation(PlayerPedId(), tonumber(PropIndex))
    local currentProp = GetPedPropIndex(PlayerPedId(), tonumber(PropIndex))

    if pWearType == 1 and not pShouldRemove and removedHatManually then
        local hasHat = exports["caue-inventory"]:hasEnoughOfItem("hat", 1, false, true, {hat = facialWear[PropIndex+1]["Prop"]})
        if not hasHat then
            TriggerEvent("DoLongHudText", "You don't have your current hat with you.")
            return
        end
    end

    if pWearType == 4 and not pShouldRemove and removedMaskManually then
        local hasMask = exports["caue-inventory"]:hasEnoughOfItem("mask", 1, false, true, {mask = facialWear[pWearType]["Prop"]})
        if not hasMask then
            TriggerEvent("DoLongHudText", "You don't have your current mask with you.")
            return
        end
    end

    if pShouldRemove then
        TaskPlayAnim( PlayerPedId(), AnimSet, AnimationOff, 4.0, 3.0, -1, 49, 1.0, 0, 0, 0 )

        Citizen.Wait(500)

        if pWearType ~= 5 then
            if pWearType == 4 then
                local texture = GetPedTextureVariation(PlayerPedId(), PropIndex)
                local pal = GetPedPaletteVariation(PlayerPedId(), PropIndex)

                SetPedComponentVariation(PlayerPedId(), PropIndex, -1, -1, -1)

                if currentDrawable ~= -1 then
                    local itemMeta = { mask = currentDrawable, txd = texture, palette = pal }
                    local hasPropItem = exports["caue-inventory"]:hasEnoughOfItem("mask", 1, false, true, itemMeta)

                    if not hasPropItem then
                        TriggerEvent("player:receiveItem", "mask", 1, false, itemMeta)
                        TriggerEvent("raid_clothes:saveCharacterClothes")
                    end

                    removedMaskManually = true
                end
            else
                if pWearType ~= 2 then
                    local txdIndex = GetPedPropTextureIndex(PlayerPedId(), tonumber(PropIndex))

                    ClearPedProp(PlayerPedId(), tonumber(PropIndex))

                    if pWearType == 1 and currentProp ~= -1 then
                        local itemMeta = { hat = currentProp, txd = txdIndex }
                        local hasPropItem = exports["caue-inventory"]:hasEnoughOfItem("hat", 1, false, true, itemMeta)

                        if not hasPropItem then
                            TriggerEvent("player:receiveItem", "hat", 1, false, itemMeta)
                            TriggerEvent("raid_clothes:saveCharacterClothes")
                        end

                        removedHatManually = true
                    end
                end
            end
        end
    else
        TaskPlayAnim( PlayerPedId(), AnimSet, AnimationOn, 4.0, 3.0, -1, 49, 1.0, 0, 0, 0 )

        Citizen.Wait(500)

        if pWearType ~= 5 and pWearType ~= 2 then
            if pWearType == 4 then
                SetPedComponentVariation(PlayerPedId(), PropIndex, facialWear[pWearType]["Prop"], facialWear[pWearType]["Texture"], facialWear[pWearType]["Palette"])

                if (currentDrawable == -1 or currentDrawable ~= facialWear[pWearType]["Prop"]) and removedMaskManually then
                    TriggerEvent("inventory:removeItemByMetaKV", "mask", 1, "mask", facialWear[pWearType]["Prop"])
                    TriggerEvent("raid_clothes:saveCharacterClothes")
                    removedMaskManually = false
                end
            else
                SetPedPropIndex( PlayerPedId(), tonumber(PropIndex), tonumber(facialWear[PropIndex+1]["Prop"]), tonumber(facialWear[PropIndex+1]["Texture"]), false)

                if pWearType == 1 and currentProp == -1 and removedHatManually then
                    TriggerEvent("inventory:removeItemByMetaKV", "hat", 1, "hat", facialWear[PropIndex+1]["Prop"])
                    TriggerEvent("raid_clothes:saveCharacterClothes")
                    removedHatManually = false
                end
            end
        end
    end

    if pWearType == 5 then
        if not pShouldRemove then
            SetPedComponentVariation(PlayerPedId(), PropIndex, facialWear[pWearType]["Prop"], facialWear[pWearType]["Texture"], facialWear[pWearType]["Palette"])
        else
            SetPedComponentVariation(PlayerPedId(), PropIndex, -1, -1, -1)
        end

        Citizen.Wait(1800)
    end


    if pWearType == 2 then
        Citizen.Wait(600)

        if pShouldRemove then
            ClearPedProp(PlayerPedId(), tonumber(PropIndex))
        end

        if not pShouldRemove then
            Citizen.Wait(140)
            SetPedPropIndex(PlayerPedId(), tonumber(PropIndex), tonumber(facialWear[PropIndex+1]["Prop"]), tonumber(facialWear[PropIndex+1]["Texture"]), false)
        end
    end

    if pWearType == 4 and pShouldRemove then
        Citizen.Wait(1200)
    end

    ClearPedTasks(PlayerPedId())
end

--[[

    Events

]]

RegisterNetEvent("facewear:update")
AddEventHandler("facewear:update",function()
    for i = 0, 3 do
        if GetPedPropIndex(PlayerPedId(), i) ~= -1 then
            facialWear[i+1]["Prop"] = GetPedPropIndex(PlayerPedId(), i)
        end
        if GetPedPropTextureIndex(PlayerPedId(), i) ~= -1 then
            facialWear[i+1]["Texture"] = GetPedPropTextureIndex(PlayerPedId(), i)
        end
    end

    if GetPedDrawableVariation(PlayerPedId(), 1) ~= -1 then
        facialWear[4]["Prop"] = GetPedDrawableVariation(PlayerPedId(), 1)
        facialWear[4]["Palette"] = GetPedPaletteVariation(PlayerPedId(), 1)
        facialWear[4]["Texture"] = GetPedTextureVariation(PlayerPedId(), 1)
    end

    if GetPedDrawableVariation(PlayerPedId(), 11) ~= -1 then
        facialWear[5]["Prop"] = GetPedDrawableVariation(PlayerPedId(), 11)
        facialWear[5]["Palette"] = GetPedPaletteVariation(PlayerPedId(), 11)
        facialWear[5]["Texture"] = GetPedTextureVariation(PlayerPedId(), 11)
    end

    removedHatManually = false
    removedMaskManually = false
end)

RegisterNetEvent("facewear:adjust")
AddEventHandler("facewear:adjust",function(pWearType, pShouldRemove, pIsPolice)
    local isPolice = pIsPolice or false

    if not (isHandcuffed and isHandcuffedAndWalking) or isPolice then
        if type(pWearType) == "table" then
            for _, wearType in pairs(pWearType) do
                toggleFaceWear(wearType.id, wearType.shouldRemove)
            end
        else
            toggleFaceWear(pWearType, pShouldRemove)
        end
    end
end)

RegisterNetEvent("facewear:setWear")
AddEventHandler("facewear:setWear",function(pWearType, pComponent, pTexture, pPalette)
    if pWearType == 1 then
        facialWear[1]["Prop"] = pComponent
        facialWear[1]["Texture"] = pTexture
    end

    if pWearType == 4 then
        facialWear[4]["Prop"] = pComponent
        facialWear[4]["Palette"] = pPalette
        facialWear[4]["Texture"] = pTexture
    end
end)