--[[

    Variables

]]

local foodsContext = {}
local drinksContext = {}
local activePurchases = {}

local foodConfig = {
    foods = {
        {itemid = "taco", displayName = "Taco", description = "1 Cheese, 1 Lettuce, 1 Meat", craftTime = 10, recipe = {"cheese", "lettuce", "freshmeat"}},
        {itemid = "burrito", displayName = "Burrito", description = "1 Cheese, 1 Lettuce, 1 Meat", craftTime = 10, recipe = {"cheese", "lettuce", "freshmeat"}},
        {itemid = "churro", displayName = "Churro", description = "1 Ingredients 1 Chocolate Bar", craftTime = 10, recipe = {"foodingredient", "chocobar"}},
        {itemid = "donut", displayName = "Donut", description =  "1 Ingredients", craftTime = 15, recipe = {"foodingredient"}},
    },
    drinks = {
        {itemid = "softdrink", displayName =  "Soft Drink", description = "1 High-Fructose Syrup", craftTime = 5, recipe = {"hfcs"}},
        {itemid = "fruitslushy", displayName =  "Fruit Slushy", description =  "1 Apple, 1 Banana, 1 Cherry, 1 Orange, 1 Peach, 1 Strawberry", craftTime = 15, recipe = {"apple", "banana", "cherry", "orange", "peach", "strawberry",}},
    },
}


--[[

    Functions

]]

function isChargeActive(pEntity, pContext)
    return exports["caue-base"]:getChar("job") == "taco_shop"
end

--[[

    Events

]]

AddEventHandler("caue-tacoshop:stationPrompt", function(pParameters, pEntity, pContext)
    if pParameters.stationId == 0 then
        TriggerEvent("server-inventory-open", "1", "tacoshop_fridge")
    elseif pParameters.stationId == 1 then
        exports["caue-context"]:showContext(foodsContext)
    elseif pParameters.stationId == 2 then
        exports["caue-context"]:showContext(drinksContext)
    elseif pParameters.stationId == 3 then
        local input = exports["caue-input"]:showInput({
            {
                icon = "dollar-sign",
                label = "Cost",
                name = "cost",
            },
            {
                icon = "pencil-alt",
                label = "Comment",
                name = "comment",
            },
        })

        if input["cost"] and input["comment"] then
            local cost = tonumber(input["cost"])
            local comment = input["comment"]

            if cost == nil or not cost or comment == nil or comment == "" then return end

            TriggerServerEvent("caue-tacoshop:orderFood", {cost = cost, comment = comment, registerId = pParameters.registerId})
        end
    elseif pParameters.stationId == 4 then
        local activeRegisterId = pParameters.registerId
        local activeRegister = activePurchases[activeRegisterId]

        if not activeRegister or activeRegister == nil then
            TriggerEvent("DoLongHudText", "No purchase active.")
            return
        end

        local priceWithTax = RPC.execute("caue-financials:priceWithTax", activeRegister.cost, "Goods")
        local acceptContext = {{
            title = "Accept Purchase",
            description = "$" .. priceWithTax.total .. " Incl. " .. priceWithTax.porcentage .. "% tax | " .. activeRegister.comment,
            action = "caue-tacoshop:finishPurchasePrompt",
            params = {cost = activeRegister.cost, comment = activeRegister.comment, registerId = pParameters.registerId, charger = activeRegister.charger, tax = priceWithTax.tax}
        }}
        exports['caue-context']:showContext(acceptContext)
    elseif pParameters.stationId == 5 then
        TriggerEvent("server-inventory-open", "1", "trays-Taco Libre-" .. pParameters.registerId)
    end
end)

AddEventHandler("caue-tacoshop:orderFood", function(data)
    local startPos = GetEntityCoords(PlayerPedId())

    local tempContext, tempAction, tempAnimDict, tempAnim, animLoop = {}, "", "", "", false
    if data.context == "foods" then
        tempContext = foodsContext
        tempAction = "Preparing" .. " "
        tempAnimDict = "anim@amb@business@coc@coc_unpack_cut@"
        tempAnim = "fullcut_cycle_v6_cokecutter"
        animLoop = true
    elseif data.context == "drinks" then
        tempContext = drinksContext
        tempAction = "Dispensing" .. " "
        tempAnimDict = "mp_ped_interaction"
        tempAnim = "handshake_guy_a"
        animLoop = false
    end

    --Ingredient check
    for _,itemid in pairs(data.recipe) do
        local hasItem = exports['caue-inventory']:hasEnoughOfItem(itemid, 1, false, true)
        if not hasItem then
            TriggerEvent("DoLongHudText", "You're missing" .. " " .. tostring(itemid))
            return
        end
    end

    if IsPedArmed(PlayerPedId(), 7) then
        SetCurrentPedWeapon(PlayerPedId(), 0xA2719263, true)
    end

    RequestAnimDict(tempAnimDict)

    while not HasAnimDictLoaded(tempAnimDict) do
        Citizen.Wait(0)
    end

    if IsEntityPlayingAnim(PlayerPedId(), tempAnimDict, tempAnim, 3) then
        ClearPedSecondaryTask(PlayerPedId())
    else
        local animLength = animLoop and -1 or GetAnimDuration(tempAnimDict, tempAnim)
        TaskPlayAnim(PlayerPedId(), tempAnimDict, tempAnim, 1.0, 4.0, animLength, 18, 0, 0, 0, 0)
    end

    local finished = exports["caue-taskbar"]:taskBar(data.craftTime * 1000, tempAction .. data.displayName)
    if finished == 100 then
        local pos = GetEntityCoords(PlayerPedId(), false)
        if(#(startPos - pos) < 2.0) then
            for _,itemid in pairs(data.recipe) do
                TriggerEvent("inventory:removeItem", itemid, 1)
            end
            TriggerEvent("player:receiveItem", data.itemid, 1, false, {})
            exports['caue-context']:showContext(tempContext)
        end
    end

    StopAnimTask(PlayerPedId(), tempAnimDict, tempAnim, 3.0)
end)

RegisterNetEvent("caue-tacoshop:activePurchase")
AddEventHandler("caue-tacoshop:activePurchase", function(data, rusticopaunocu)
    if rusticopaunocu then
        activePurchases[data.registerId] = nil
    else
        activePurchases[data.registerId] = data
    end
end)

AddEventHandler("caue-tacoshop:finishPurchasePrompt", function(pParams)
    TriggerServerEvent("caue-tacoshop:completePurchase", pParams)
end)

--[[

    Threads

]]

Citizen.CreateThread(function()
    exports["caue-polytarget"]:AddBoxZone("caue-tacoshop:fridge", vector3(423.85, -1921.52, 25.47), 1.4, 0.2, {
        heading=135,
        minZ=24.47,
        maxZ=26.67
    })

    exports["caue-eye"]:AddPeekEntryByPolyTarget("caue-tacoshop:fridge", {{
        event = "caue-tacoshop:stationPrompt",
        id = "tacoshop_fridge",
        icon = "box-open",
        label = "Abrir",
        parameters = { stationId = 0 }
    }}, { distance = { radius = 3.5 } , isEnabled = isChargeActive })

    exports["caue-polytarget"]:AddBoxZone("caue-tacoshop:foods1", vector3(417.71, -1918.98, 25.47), 0.8, 1.6, {
        heading=44,
        minZ=25.27,
        maxZ=25.67
    })

    exports["caue-eye"]:AddPeekEntryByPolyTarget("caue-tacoshop:foods1", {{
        event = "caue-tacoshop:stationPrompt",
        id = "caue-tacoshop:foods1",
        icon = "hamburger",
        label = "Cozinhar",
        parameters = { stationId = 1 }
    }}, { distance = { radius = 3.5 } , isEnabled = isChargeActive })

    exports["caue-polytarget"]:AddBoxZone("caue-tacoshop:drinks1", vector3(418.85, -1917.76, 25.47), 0.45, 0.7, {
        heading=44,
        minZ=25.27,
        maxZ=25.77
    })

    exports["caue-eye"]:AddPeekEntryByPolyTarget("caue-tacoshop:drinks1", {{
        event = "caue-tacoshop:stationPrompt",
        id = "caue-tacoshop:drinks1",
        icon = "mug-hot",
        label = "Bebidas",
        parameters = { stationId = 2 }
    }}, { distance = { radius = 3.5 } , isEnabled = isChargeActive })

    exports["caue-polytarget"]:AddBoxZone("caue-tacoshop:register1", vector3(416.97, -1916.45, 25.47), 0.6, 0.5, {
        heading=43,
        minZ=25.67,
        maxZ=26.02
    })

    exports["caue-eye"]:AddPeekEntryByPolyTarget("caue-tacoshop:register1", {{
        event = "caue-tacoshop:stationPrompt",
        id = "caue-tacoshop:register1_worker",
        icon = "credit-card",
        label = "Charge Customer",
        parameters = { stationId = 3, registerId = 1 }
    }}, { distance = { radius = 3.5 } , isEnabled = isChargeActive })

    exports["caue-eye"]:AddPeekEntryByPolyTarget("caue-tacoshop:register1", {{
        event = "caue-tacoshop:stationPrompt",
        id = "caue-tacoshop:register1_customer",
        icon = "credit-card",
        label = "Make Payment",
        parameters = { stationId = 4, registerId = 1 }
    }}, { distance = { radius = 3.5 } , isEnabled = function() return not isChargeActive() end })



    exports["caue-polytarget"]:AddBoxZone("caue-tacoshop:trays1", vector3(416.28, -1916.7, 25.47), 0.4, 0.6, {
        heading=1,
        minZ=25.67,
        maxZ=25.87
    })

    exports["caue-eye"]:AddPeekEntryByPolyTarget("caue-tacoshop:trays1", {{
        event = "caue-tacoshop:stationPrompt",
        id = "caue-tacoshop:trays1",
        icon = "hand-holding",
        label = "Abrir",
        parameters = { stationId = 5, registerId = 1 }
    }}, { distance = { radius = 3.5 } })

    for foodContext, data in pairs(foodConfig) do
        local temp = {}
        for k, item in pairs(data) do
            if not item.cid or item.cid == cid then
                temp[#temp+1] = {
                    title = item.displayName,
                    description = item.description .. " | " .. item.craftTime .. "s",
                    action = "caue-tacoshop:orderFood",
                    params = {
                        itemid = item.itemid,
                        displayName = item.displayName,
                        craftTime = item.craftTime,
                        recipe = item.recipe,
                        context = foodContext
                    },
                }
            end
        end

        if foodContext == "foods" then
            foodsContext = temp
        elseif foodContext == "drinks" then
            drinksContext = temp
        end
    end
end)