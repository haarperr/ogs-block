--[[

    Variables

]]

local inPackOpening = true

--[[

    Functions

]]

function LoadAnimationDic(dict)
    if not HasAnimDictLoaded(dict) then
        RequestAnimDict(dict)

        while not HasAnimDictLoaded(dict) do
            Citizen.Wait(0)
        end
    end
end

local function playPackOpeningAnimation()
    inPackOpening = true
    Citizen.Wait(500)
    ClearPedTasksImmediately()
    Citizen.Wait(500)
    LoadAnimationDic("amb@world_human_tourist_map@male@idle_a")
    TaskPlayAnim(PlayerPedId(), "amb@world_human_tourist_map@male@idle_a", "idle_b", 3.0, 3.0, -1, 49, 0, 0, 0, 0)
    TriggerEvent("attachItemPhone", "tcg_card_inspect")
end

local function stopPackOpeningAnimation()
    Citizen.Wait(1000)
    StopAnimTask(PlayerPedId(), "amb@world_human_tourist_map@male@idle_a", "idle_b", 1.0)
    TriggerEvent("destroyPropPhone")
    inPackOpening = false
end

--[[

    Events

]]

AddEventHandler("caue-inventory:itemUsed", function(item, info, inventory, slot, dbid)
    local itemInfo = json.decode(info)

    if item == "tcgcard" then
        TriggerEvent("caue-tcg:previewCard", itemInfo)
    elseif TCG.Packs[item] then
        playPackOpeningAnimation()
        TriggerEvent("inventory:removeItem", item, 1)
        TriggerEvent("caue-tcg:openPack", item)
    end
end)

AddEventHandler("caue-tcg:openPack", function(type)
    local packCards = TCG.Packs[type]

    local cards = {}
    local _cards = {}
    local count = 0
    for i=1, 1000 do
        local randomCard = packCards[math.random(#packCards)]
        if not _cards[randomCard] then
            _cards[randomCard] = true
            count = count + 1

            if count == 5 then
                break
            end
        end
    end

    for k, v in pairs(_cards) do
        table.insert(cards, {
            card = k,
            image = TCG.Cards[k]["image"],
            hollow = math.random(100) > 95,
        })
    end

	SetNuiFocus(true, true)
    SendNUIMessage({
		open = true,
		cards = cards
	})
end)

AddEventHandler("caue-tcg:previewCard", function(pInfo)
	SetNuiFocus(true, true)
    SendNUIMessage({
		open = true,
		card = pInfo._image_url,
		hollow = pInfo._hollow
	})
end)


--[[

    NUI

]]

RegisterNUICallback("giveCard", function(data, cb)
	local name = TCG.Cards[data.card]["name"]
	local description = TCG.Cards[data.card]["description"]
    local image = TCG.Cards[data.card]["image"]
    local hollow = data.hollow

    if hollow then
        name = name .. " Brilhante"
    end

    local metaInfo = {
        _name = name,
        _description = description,
        _image_url = image,
        _hollow = data.hollow,
        _remove_id = math.random(1000000, 9999999),

        _hideKeys = {
            "_name",
            "_description",
            "_image_url",
            "_hollow",
            "_remove_id",
        },
    }

    TriggerEvent("player:receiveItem", "tcgcard", 1, true, metaInfo)

    cb(true)
end)

RegisterNUICallback("close", function(data, cb)
	SetNuiFocus(false, false)

    stopPackOpeningAnimation()

	cb(true)
end)


--[[

    Threads

]]

Citizen.CreateThread(function()
    Citizen.Wait(1000)

    -- TriggerEvent("caue-tcg:openPack")

    -- local metaInfo = {
    --     _name = TCG.Cards["asaprocky"]["name"] .. " Brilhante",
    --     _description = TCG.Cards["asaprocky"]["description"],
    --     _image_url = TCG.Cards["asaprocky"]["image"],
    --     _hollow = true,
    --     _remove_id = math.random(1000000, 9999999),

    --     _hideKeys = {
    --         "_name",
    --         "_description",
    --         "_image_url",
    --         "_hollow",
    --         "_remove_id",
    --     },
    -- }

    -- TriggerEvent("player:receiveItem", "tcgcard", 1, true, metaInfo)

end)




