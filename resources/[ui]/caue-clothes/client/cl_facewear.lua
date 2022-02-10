--[[

    Variables

]]

local antispam = GetGameTimer()

local items = {
    "hat",
    "mask",
    "googles",
    "chain",
    "vest",
    "jacket",
    "backpack",
    "pants",
    "shoes"
}

--[[

    Functions

]]

function toggleFaceWear(pType, pRemove, pInfo, pSteal)
    local AnimSet = "clothingtie"
    local Animation = "try_tie_neutral_c"
    local PropIndex = 0
    local Wait = 1000
    local ItemHandler = false
    local ItemMeta = {}
    local IsMale = GetSkin().name == "skin_male"

    if not pRemove then
        if pInfo.gender == "male" and not IsMale then
            TriggerEvent("DoLongHudText", "Esta roupa só serve no sexo oposto. ", 2)
            return
        end
    end

    if pType == "hat" then
        PropIndex = 0
        AnimSet = "mp_masks@on_foot"
        Animation = "put_on_mask"
    elseif pType == "googles" then
        PropIndex = 1
        AnimSet = "clothingspecs"
        Animation = "take_off"
        Wait = 1200
    elseif pType == "chain" then
        PropIndex = 7
        AnimSet = "clothingspecs"
        Animation = "take_off"
        Wait = 1200
    elseif pType == "mask" then
        PropIndex = 1
        AnimSet = "mp_masks@on_foot"
        Animation = "put_on_mask"
    elseif pType == "vest" then
        PropIndex = 9
    elseif pType == "jacket" then
        PropIndex = 11
    elseif pType == "backpack" then
        PropIndex = 5
    elseif pType == "pants" then
        PropIndex = 4
    elseif pType == "shoes" then
        PropIndex = 6
        AnimSet = "random@domestic"
        Animation = "pickup_low"
    elseif pType == "stolenshoes" then
        PropIndex = 6
    end

    if pSteal == false then
        loadAnimDict(AnimSet)
        TaskPlayAnim(PlayerPedId(), AnimSet, Animation, 4.0, 3.0, -1, 49, 1.0, 0, 0, 0)
    else
        Wait = 500
    end

    local currentDrawable = GetPedDrawableVariation(PlayerPedId(), PropIndex) or -1
    local currentProp = GetPedPropIndex(PlayerPedId(), PropIndex) or -1

    Citizen.Wait(Wait)

    if pType == "hat" or pType == "googles" then
        local texture = GetPedPropTextureIndex(PlayerPedId(), PropIndex) or 0

        if pRemove then
            if currentProp ~= -1 then
                ClearPedProp(PlayerPedId(), PropIndex)

                ItemHandler = true
                ItemMeta = { prop = currentProp, txd = texture }
            end
        else
            if currentProp ~= -1 then
                local _itemMeta = { prop = currentProp, txd = texture }
                TriggerEvent("player:receiveItem", pType, 1, false, _itemMeta)
            end

            SetPedPropIndex(PlayerPedId(), PropIndex, pInfo.prop, pInfo.txd, true)

            ItemHandler = true
        end
    elseif pType == "mask" or pType == "vest" or pType == "backpack" or pType == "chain" then
        local texture = GetPedTextureVariation(PlayerPedId(), PropIndex) or 0
        local pal = GetPedPaletteVariation(PlayerPedId(), PropIndex) or -1

        if pRemove then
            if currentDrawable ~= -1 then
                SetPedComponentVariation(PlayerPedId(), PropIndex, -1, -1, -1)

                ItemHandler = true
                ItemMeta = { prop = currentDrawable, txd = texture, palette = pal }
            end
        else
            if currentDrawable ~= -1 then
                local _itemMeta = { prop = currentDrawable, txd = texture, palette = pal }
                TriggerEvent("player:receiveItem", pType, 1, false, _itemMeta)
            end

            SetPedComponentVariation(PlayerPedId(), PropIndex, pInfo.prop,  pInfo.txd,  pInfo.pallete)

            ItemHandler = true
        end
    elseif pType == "jacket" then
        local texture = GetPedTextureVariation(PlayerPedId(), PropIndex) or 0
        local pal = GetPedPaletteVariation(PlayerPedId(), PropIndex) or -1
        local arm = GetPedDrawableVariation(PlayerPedId(), 3) or 0

        local bareTorsoIndex = 15
        local bareArmsIndex = 15

        if not IsMale then
            bareTorsoIndex = 18
        end

        if pRemove then
            if currentDrawable ~= -1 and currentDrawable ~= bareTorsoIndex then
                SetPedComponentVariation(PlayerPedId(), PropIndex, bareTorsoIndex, 0, -1)
                SetPedComponentVariation(PlayerPedId(), 3, bareArmsIndex, 0, -1)

                ItemHandler = true
                ItemMeta = { prop = currentDrawable, txd = texture, palette = pal, arms = arm }
            end
        else
            if currentDrawable ~= -1 and currentDrawable ~= bareTorsoIndex then
                local _itemMeta = { prop = currentDrawable, txd = texture, palette = pal, arms = arm }
                TriggerEvent("player:receiveItem", pType, 1, false, _itemMeta)
            end

            SetPedComponentVariation(PlayerPedId(), PropIndex, pInfo.prop, pInfo.txd, pInfo.palette)
            SetPedComponentVariation(PlayerPedId(), 3, pInfo.arms, 0, -1)

            ItemHandler = true
        end
    elseif pType == "pants" then
        local texture = GetPedTextureVariation(PlayerPedId(), PropIndex) or 0
        local pal = GetPedPaletteVariation(PlayerPedId(), PropIndex) or -1

        local bareLegsIndex = 61

        if not IsMale then
            bareLegsIndex = 17
        end

        if pRemove then
            if currentDrawable ~= -1 and currentDrawable ~= bareLegsIndex then
                SetPedComponentVariation(PlayerPedId(), PropIndex, bareLegsIndex, 0, -1)

                ItemHandler = true
                ItemMeta = { prop = currentDrawable, txd = texture, palette = pal }
            end
        else
            if currentDrawable ~= -1 and currentDrawable ~= bareLegsIndex then
                local _itemMeta = { prop = currentDrawable, txd = texture, palette = pal }
                TriggerEvent("player:receiveItem", pType, 1, false, _itemMeta)
            end

            SetPedComponentVariation(PlayerPedId(), PropIndex, pInfo.prop, pInfo.txd, pInfo.palette)

            ItemHandler = true
        end
    elseif pType == "shoes" then
        local texture = GetPedTextureVariation(PlayerPedId(), PropIndex) or 0
        local pal = GetPedPaletteVariation(PlayerPedId(), PropIndex) or -1

        local bareFootIndex = 34

        if not IsMale then
            bareFootIndex = 35
        end

        if pRemove then
            if currentDrawable ~= -1 and currentDrawable ~= bareFootIndex then
                SetPedComponentVariation(PlayerPedId(), PropIndex, bareFootIndex, 0, -1)

                ItemHandler = true
                ItemMeta = { prop = currentDrawable, txd = texture, palette = pal }
            end
        else
            if currentDrawable ~= -1 and currentDrawable ~= bareFootIndex then
                local _itemMeta = { prop = currentDrawable, txd = texture, palette = pal }
                TriggerEvent("player:receiveItem", pType, 1, false, _itemMeta)
            end

            SetPedComponentVariation(PlayerPedId(), PropIndex, pInfo.prop, pInfo.txd, pInfo.palette)

            ItemHandler = true
        end
    elseif pType == "stolenshoes" then
        local bareFootIndex = 34

        if not IsMale then
            bareFootIndex = 35
        end

        if currentDrawable ~= -1 and currentDrawable ~= bareFootIndex then
            SetPedComponentVariation(PlayerPedId(), PropIndex, bareFootIndex, 0, -1)
            TriggerServerEvent("caue-clothes:facewearSendItem", pSteal, pType, ItemMeta)
        end
    end

    if ItemHandler then
        ItemMeta.gender = IsMale and "male" or "female"

        if pSteal ~= false then
            TriggerServerEvent("caue-clothes:facewearSendItem", pSteal, pType, ItemMeta)
        else
            if pRemove then
                TriggerEvent("player:receiveItem", pType, 1, false, ItemMeta)
            else
                TriggerEvent("inventory:removeItemByMetaKV", pType, 1, "prop", pInfo.prop)
            end
        end
    end

    if pSteal == false then
        ClearPedTasks(PlayerPedId())
    end

    TriggerEvent("caue-clothes:saveCurrentClothes")
end

--[[

    Events

]]

AddEventHandler("caue-inventory:itemUsed", function(item, info)
    if has_value(items, item) == -1 then return end

    if antispam >= GetGameTimer() then
        TriggerEvent("DoLongHudText", "Mais devagar ok?", 2)
        return
    end

    antispam = GetGameTimer() + 1000

    local info = json.decode(info)

    toggleFaceWear(item, false, info, false)
end)

RegisterNetEvent("facewear:adjust")
AddEventHandler("facewear:adjust",function(pType, pRemove, pIsSteal)
    if type(pType) == "table" then
        for _, wearType in pairs(pType) do
            toggleFaceWear(wearType.id, wearType.shouldRemove, wearType.info, wearType.isSteal)
        end
    else
        toggleFaceWear(pType, pRemove, {}, pIsSteal)
    end
end)

AddEventHandler("caue-facewear:steal", function(pArgs, pEntity)
    loadAnimDict("random@domestic")
  	TaskTurnPedToFaceEntity(PlayerPedId(), pEntity, -1)
  	TaskPlayAnim(PlayerPedId(),"random@domestic", "pickup_low",5.0, 1.0, 1.0, 48, 0.0, 0, 0, 0)
  	Citizen.Wait(1600)
  	ClearPedTasks(PlayerPedId())
  	TriggerServerEvent("facewear:adjust", GetPlayerServerId(NetworkGetPlayerIndexFromPed(pEntity)), pArgs, true, true)
end)

AddEventHandler("caue-facewear:radial", function(pArgs)
    if antispam >= GetGameTimer() then
        TriggerEvent("DoLongHudText", "Mais devagar ok?", 2)
        return
    end

    antispam = GetGameTimer() + 1000

    toggleFaceWear(pArgs, true, {}, false)
end)

--[[

    Threads

]]

Citizen.CreateThread(function()
    local group = { 1 }

    local data = {
        {
            id = "steal_shoes",
            label = "Steal Shoes",
            icon = "hand-paper",
            event = "caue-facewear:steal",
            parameters = "shoes",
        },
        {
            id = "steal_pants",
            label = "Steal Pants",
            icon = "hand-paper",
            event = "caue-facewear:steal",
            parameters = "pants",
        },
        {
            id = "steal_backpack",
            label = "Steal Backpack",
            icon = "hand-paper",
            event = "caue-facewear:steal",
            parameters = "backpack",
        },
        {
            id = "steal_vest",
            label = "Steal Vest",
            icon = "hand-paper",
            event = "caue-facewear:steal",
            parameters = "vest",
        },
        {
            id = "steal_jacket",
            label = "Steal Jacket",
            icon = "hand-paper",
            event = "caue-facewear:steal",
            parameters = "jacket",
        },
        {
            id = "steal_mask",
            label = "Steal Mask",
            icon = "hand-paper",
            event = "caue-facewear:steal",
            parameters = "mask",
        },
        {
            id = "steal_googles",
            label = "Steal Googles",
            icon = "hand-paper",
            event = "caue-facewear:steal",
            parameters = "googles",
        },
        {
            id = "steal_hat",
            label = "Steal Hat",
            icon = "hand-paper",
            event = "caue-facewear:steal",
            parameters = "hat",
        },
        {
            id = "steal_chain",
            label = "Steal Chain",
            icon = "hand-paper",
            event = "caue-facewear:steal",
            parameters = "chain",
        },
    }

    local options = {
        distance = { radius = 1.5 },
        isEnabled = function(pEntity, pContext)
            return not isDisabled() and pContext.flags["isPlayer"] and (pContext.flags["isCuffed"] or pContext.flags["isDead"] or isPersonBeingHeldUp(pEntity))
        end
    }

    exports["caue-eye"]:AddPeekEntryByEntityType(group, data, options)
end)