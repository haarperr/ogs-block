--[[

    Variables

]]

local clientInventory = {}
local PreviousItemCheck = {}
local justUsed = false
local retardCounter = 0
local lastCounter = 0

local validWaterItem = {
    ["oxygentank"] = true,
    ["water"] = true,
    ["vodka"] = true,
    ["beer"] = true,
    ["whiskey"] = true,
    ["coffee"] = true,
    ["fishtaco"] = true,
    ["taco"] = true,
    ["burrito"] = true,
    ["churro"] = true,
    ["hotdog"] = true,
    ["greencow"] = true,
    ["donut"] = true,
    ["eggsbacon"] = true,
    ["icecream"] = true,
    ["mshake"] = true,
    ["sandwich"] = true,
    ["hamburger"] = true,
    ["cola"] = true,
    ["jailfood"] = true,
    ["bleederburger"] = true,
    ["heartstopper"] = true,
    ["torpedo"] = true,
    ["meatfree"] = true,
    ["moneyshot"] = true,
    ["fries"] = true,
    ["slushy"] = true,
    ["frappuccino"] = true,
    ["latte"] = true,
    ["cookie"] = true,
    ["muffin"] = true,
    ["chocolate"] = true,
}

local stolenItems = {
    ["stolentv"] = true,
}





--[[

    Functions

]]

function GetItemInfo(checkslot)
    for i,v in pairs(clientInventory) do
        if (tonumber(v.slot) == tonumber(checkslot)) then
            local info = {["information"] = v.information,["id"] = v.id, ["quality"] = v.quality }
            return info
        end
    end
    return "No information stored";
end

function getQuantity(itemid, checkQuality, metaInformation)
    local amount = 0
    for i,v in pairs(clientInventory) do
        local qCheck = not checkQuality or v.quality > 0
        if v.item_id == itemid and qCheck then
            if metaInformation then
                local totalMetaKeys = 0
                local metaFoundCount = 0
                local itemMeta = json.decode(v.information)
                for metaKey, metaValue in pairs(metaInformation) do
                    totalMetaKeys = totalMetaKeys + 1
                    if itemMeta[metaKey] and itemMeta[metaKey] == metaValue then
                        metaFoundCount = metaFoundCount + 1
                    end
                end
                if totalMetaKeys <= metaFoundCount then
                    amount = amount + v.amount
                end
            else
                amount = amount + v.amount
            end
        end
    end
    return amount
end

function hasEnoughOfItem(itemid, amount, shouldReturnText, checkQuality, metaInformation)
    if shouldReturnText == nil then shouldReturnText = true end
    if itemid == nil or itemid == 0 or amount == nil or amount == 0 then
        if shouldReturnText then
            TriggerEvent("DoLongHudText","I dont seem to have " .. itemid .. " in my pockets.",2)
        end
        return false
    end
    amount = tonumber(amount)
    local slot = 0
    local found = false

    if getQuantity(itemid, checkQuality, metaInformation) >= amount then
        return true
    end
    if (shouldReturnText) then
        TriggerEvent("DoLongHudText","I dont have enough of that item...",2)
    end
    return false
end

function isValidUseCase(itemID, isWeapon)
    local player = PlayerPedId()
    local playerVeh = GetVehiclePedIsIn(player, false)

    if playerVeh ~= 0 then
        local model = GetEntityModel(playerVeh)
        if IsThisModelACar(model) or IsThisModelABike(model) or IsThisModelAQuadbike(model) then
            if IsEntityInAir(playerVeh) then
                Wait(1000)
                if IsEntityInAir(playerVeh) then
                    TriggerEvent("DoLongHudText", "You appear to be flying through the air", 2)
                    return false
                end
            end
        end
    end

    if not validWaterItem[itemID] and not isWeapon then
        if IsPedSwimming(player) then
            local targetCoords = GetEntityCoords(player, 0)
            Wait(700)
            local plyCoords = GetEntityCoords(player, 0)
            if #(targetCoords - plyCoords) > 1.3 then
                TriggerEvent("DoLongHudText", "Cannot be moving while swimming to use this.", 2)
                return false
            end
        end

        if IsPedSwimmingUnderWater(player) then
            TriggerEvent("DoLongHudText", "Cannot be underwater to use this.", 2)
            return false
        end
    end

    return true
end

function checkForItems()
    local items = {
        "mobilephone",
        "radio",
        "civradio",
        "megaphone",
    }

    for _, item in ipairs(items) do
        local quantity = getQuantity(item)
        local hasItem = quantity >= 1

        if hasItem and not PreviousItemCheck[item] then
            PreviousItemCheck[item] = true
            TriggerEvent("caue-inventory:itemCheck", item, true, quantity)
        elseif not hasItem and PreviousItemCheck[item] then
            PreviousItemCheck[item] = false
            TriggerEvent("caue-inventory:itemCheck", item, false, quantity)
        end
    end
end

function checkForAttachItem()
    local AttatchItems = {
        "stolentv",
        "stolenmusic",
        "stolencoffee",
        "stolenmicrowave",
        "stolencomputer",
        "stolenart",
    }

    local RepairItems = {
        "sfixbrake","sfixaxle","sfixradiator","sfixclutch","sfixtransmission","sfixelectronics","sfixinjector","sfixtire","sfixbody","sfixengine",
        "afixbrake","afixaxle","afixradiator","afixclutch","afixtransmission","afixelectronics","afixinjector","afixtire","afixbody","afixengine",
        "bfixbrake","bfixaxle","bfixradiator","bfixclutch","bfixtransmission","bfixelectronics","bfixinjector","bfixtire","bfixbody","bfixengine",
        "cfixbrake","cfixaxle","cfixradiator","cfixclutch","cfixtransmission","cfixelectronics","cfixinjector","cfixtire","cfixbody","cfixengine",
        "dfixbrake","dfixaxle","dfixradiator","dfixclutch","dfixtransmission","dfixelectronics","dfixinjector","dfixtire","dfixbody","dfixengine",
    }

    local itemToAttach = "none"
    for k,v in pairs(AttatchItems) do
        if getQuantity(v) >= 1 then
            itemToAttach = v
            break
        end
    end

    if itemToAttach == "none" then
        for k,v in pairs(RepairItems) do
            if getQuantity(v) >= 1 then
                itemToAttach = "engine"
                break
            end
        end
    end

    TriggerEvent("animation:carry", itemToAttach, true)
end

function GetCurrentWeapons()
    local returnTable = {}
    for i,v in pairs(clientInventory) do
        if (tonumber(v.item_id)) then
            local t = { ["hash"] = v.item_id, ["id"] = v.id, ["information"] = v.information, ["name"] = v.item_id, ["slot"] = v.slot }
            returnTable[#returnTable+1]=t
        end
    end
    if returnTable == nil then
        return {}
    end
    return returnTable
end

function TaskItem(dictionary, animation, typeAnim, timer, message, func, remove, itemid, playerVeh, itemreturn, itemreturnid, quality)
    loadAnimDict(dictionary)
    TaskPlayAnim(PlayerPedId(), dictionary, animation, 8.0, 1.0, -1, typeAnim, 0, 0, 0, 0)

    local timer = tonumber(timer)
    if timer > 0 then
        local finished = exports["caue-taskbar"]:taskBar(timer, message, true, false, playerVeh)
        if finished == 100 or timer == 0 then
            TriggerEvent(func, quality)

            if remove then
                TriggerEvent("inventory:removeItem", itemid, 1)
            end

            if itemreturn then
                TriggerEvent("player:receiveItem", itemreturnid, 1)
            end
        end
    else
        TriggerEvent(func)
    end

    ClearPedSecondaryTask(PlayerPedId())
end

function AttachPropAndPlayAnimation(dictionary, animation, typeAnim, timer, message, func, remove, itemid, vehicle, prop)
    if prop then
        TriggerEvent("attachItem", prop)
    end

    TaskItem(dictionary, animation, typeAnim, timer, message, func, remove, itemid, vehicle)

    if prop then
        TriggerEvent("destroyProp")
    end
end

--[[

    Exports

]]

exports("GetItemInfo", GetItemInfo)
exports("getQuantity", getQuantity)
exports("hasEnoughOfItem", hasEnoughOfItem)
exports("GetCurrentWeapons", GetCurrentWeapons)
exports("TaskItem", TaskItem)
exports("AttachPropAndPlayAnimation", AttachPropAndPlayAnimation)

--[[

    Events

]]

RegisterNetEvent("current-items")
AddEventHandler("current-items", function(inv)
    clientInventory = inv
    checkForItems()
    checkForAttachItem()
end)

RegisterNetEvent("RunUseItem")
AddEventHandler("RunUseItem", function(itemid, slot, inventoryName, isWeapon, passedItemInfo)
    if itemid == nil then return end

    local ItemInfo = GetItemInfo(slot)
    if ItemInfo.quality == nil then return end
    if ItemInfo.quality < 1 then
        TriggerEvent("DoLongHudText","Item is too worn.",2)
        if isWeapon then
            TriggerEvent("brokenWeapon")
        end
        return
    end

    if justUsed then
        retardCounter = retardCounter + 1
        if retardCounter > 10 and retardCounter > lastCounter + 5 then
            lastCounter = retardCounter
            TriggerServerEvent("exploiter", "Tried using " .. retardCounter .. " items in < 500ms ")
        end
        return
    end

    justUsed = true

    if (not hasEnoughOfItem(itemid,1,false)) then
        TriggerEvent("DoLongHudText","You dont appear to have this item on you?",2)
        justUsed = false
        retardCounter = 0
        lastCounter = 0
        return
    end

    if itemid == "-72657034" then
        TriggerEvent("equipWeaponID", itemid, ItemInfo.information, ItemInfo.id)
        TriggerEvent("inventory:removeItem",itemid, 1)
        justUsed = false
        retardCounter = 0
        lastCounter = 0
        return
    end

    if not isValidUseCase(itemid, isWeapon) then
        justUsed = false
        retardCounter = 0
        lastCounter = 0
        return
    end

    if itemid == nil then
        justUsed = false
        retardCounter = 0
        lastCounter = 0
        return
    end

    if isWeapon then
        if tonumber(ItemInfo.quality) > 0 then
            TriggerEvent("equipWeaponID", itemid, ItemInfo.information, ItemInfo.id)
        end
        justUsed = false
        retardCounter = 0
        lastCounter = 0
        return
    end

    if stolenItems[itemid] and exports["np-npcs"]:isCloseToPawnPed() then
        return
    end

    TriggerEvent("hud-display-item", itemid, "Used")

    Wait(800)

    local player = PlayerPedId()
    local playerVeh = GetVehiclePedIsIn(player, false)

    if not IsPedInAnyVehicle(player) then
        if (itemid == "Suitcase") then
            TriggerEvent('attach:suitcase')
        end
        if (itemid == "Boombox") then
            TriggerEvent('attach:boombox')
        end
        if (itemid == "Box") then
            TriggerEvent('attach:box')
        end
        if (itemid == "DuffelBag") then
            TriggerEvent('attach:blackDuffelBag')
        end
        if (itemid == "MedicalBag") then
            TriggerEvent('attach:medicalBag')
        end
        if (itemid == "SecurityCase") then
            TriggerEvent('attach:securityCase')
        end
        if (itemid == "Toolbox") then
            TriggerEvent('attach:toolbox')
        end
    end

    local remove = false
    local itemreturn = false
    local drugitem = false
    local fooditem = false
    local drinkitem = false
    local healitem = false

    if (itemid == "pdbadge") then
        RPC.execute("np-gov:police:showBadge", json.decode(ItemInfo.information))
    end

    if (itemid == "joint" or itemid == "weed5oz" or itemid == "weedq" or itemid == "beer" or itemid == "vodka" or itemid == "whiskey" or itemid == "lsdtab") then
        drugitem = true
    end

    if (itemid == "burnerphone") then
        exports["np-ui"]:openApplication("burner", { source_number  = json.decode(ItemInfo.information).Number })
    end

    if (itemid == "tuner") then
        local finished = exports["caue-taskbar"]:taskBar(2000,"Connecting Tuner Laptop",false,false,playerVeh)
        if (finished == 100) then
            TriggerEvent("tuner:open")
        end
    end

    if (itemid == "electronickit" or itemid == "lockpick") then
        TriggerServerEvent("robbery:triggerItemUsedServer",itemid)
    end

    if (itemid == "locksystem") then
        TriggerServerEvent("robbery:triggerItemUsedServer",itemid)
    end

    if (itemid == "thermite") then
        TriggerServerEvent("robbery:triggerItemUsedServer",itemid)
    end

    if(itemid == "evidencebag") then
        TriggerEvent("evidence:startCollect", itemid, slot)
        local itemInfo = GetItemInfo(slot)
        local data = itemInfo.information
        if data == '{}' then
            TriggerEvent("DoLongHudText","Start collecting evidence!",1)
            TriggerEvent("inventory:updateItem", itemid, slot, '{"used": "true"}')
            --
        else
            local dataDecoded = json.decode(data)
            if(dataDecoded.used) then
                print('YOURE ALREADY COLLECTING EVIDENCE YOU STUPID FUCK')
            end
        end
    end

    if (itemid == "lsdtab" or itemid == "badlsdtab") then
        TriggerEvent("animation:PlayAnimation","pill")
        local finished = exports["caue-taskbar"]:taskBar(3000,"Placing LSD Strip on 👅",false,false,playerVeh)
        if (finished == 100) then
            TriggerEvent("Evidence:StateSet",2,1200)
            TriggerEvent("Evidence:StateSet",24,1200)
            TriggerEvent("fx:run", "lsd", 180, -1, (itemid == "badlsdtab" and true or false))
            remove = true
        end
    end

    if (itemid == "decryptersess" or itemid == "decrypterfv2" or itemid == "decrypterenzo") then
        if (#(GetEntityCoords(player) - vector3( 1275.49, -1710.39, 54.78)) < 3.0) then
            local finished = exports["caue-taskbar"]:taskBar(25000,"Decrypting Data",false,false,playerVeh)
            if (finished == 100) then
                TriggerEvent("phone:crypto:use", 1, 3, "robbery:decrypt", true)
            end
        end

        if #(GetEntityCoords(player) - vector3( 2328.94, 2571.4, 46.71)) < 3.0 then
            local finished = exports["caue-taskbar"]:taskBar(25000,"Decrypting Data",false,false,playerVeh)
            if finished == 100 then
                TriggerEvent("phone:crypto:use", 1, 3, "robbery:decrypt2", true)
            end
        end

        if #(GetEntityCoords(player) - vector3( 1208.73,-3115.29, 5.55)) < 3.0 then
            local finished = exports["caue-taskbar"]:taskBar(25000,"Decrypting Data",false,false,playerVeh)
            if finished == 100 then
                TriggerEvent("phone:crypto:use", 1, 3,"robbery:decrypt3", true)
            end
        end
    end

    if (itemid == "pix1") then
        if (#(GetEntityCoords(player) - vector3( 1275.49, -1710.39, 54.78)) < 3.0) then
            local finished = exports["caue-taskbar"]:taskBar(25000,"Decrypting Data",false,false,playerVeh)
            if (finished == 100) then
                TriggerEvent("phone:crypto:add", 1, math.random(1,2))
                remove = true
            end
        end
    end

    if (itemid == "pix2") then
        if (#(GetEntityCoords(player) - vector3(1275.49, -1710.39, 54.78)) < 3.0) then
            local finished = exports["caue-taskbar"]:taskBar(25000,"Decrypting Data",false,false,playerVeh)
            if (finished == 100) then
                TriggerEvent("phone:crypto:add", 1, math.random(5,12))
                remove = true
            end
        end
    end

    if (itemid == "femaleseed") then
        TriggerEvent("Evidence:StateSet",4,1600)
        TriggerEvent("weed:startcropInsideCheck","female")
    end

    if (itemid == "maleseed") then
        TriggerEvent("Evidence:StateSet",4,1600)
        TriggerEvent("weed:startcropInsideCheck","male")
    end

    if (itemid == "weedoz") then
        local finished = exports["caue-taskbar"]:taskBar(5000,"Packing Q Bags",false,false,playerVeh)
        if (finished == 100) then
            CreateCraftOption("weedq", 40, true)
        end
    end

    if (itemid == "smallbud" and hasEnoughOfItem("qualityscales",1,false)) then
        local finished = exports["caue-taskbar"]:taskBar(1000,"Packing Joint",false,false,playerVeh)
        if (finished == 100) then
            CreateCraftOption("joint2", 80, true)
        end
    end

    if (itemid == "weedq") then
        local finished = exports["caue-taskbar"]:taskBar(1000,"Rolling Joints",false,false,playerVeh)
        if (finished == 100) then
            CreateCraftOption("joint", 2, true)
        end
    end

    if (itemid == "codein") then
        CreateCraftOption("lean", 1, true)
    end

    if (itemid == "lighter") then
        TriggerEvent("animation:PlayAnimation","lighter")
        local finished = exports["caue-taskbar"]:taskBar(2000,"Starting Fire",false,false,playerVeh)
    end

    if (itemid == "joint" or itemid == "joint2") then
        local finished = exports["caue-taskbar"]:taskBar(2000,"Smoking Joint",false,false,playerVeh)
        if (finished == 100) then
            Wait(200)
            TriggerEvent("animation:PlayAnimation","weed")
            TriggerEvent("Evidence:StateSet",3,600)
            TriggerEvent("Evidence:StateSet",4,600)
            TriggerEvent("weed",1000,"WORLD_HUMAN_SMOKING_POT")
            remove = true
        end
    end

    if (itemid == "advlockpick") then
        local myJob = exports["isPed"]:isPed("myJob")
        if myJob ~= "news" then
            TriggerEvent('inv:advancedLockpick',inventoryName,slot)
        else
            TriggerEvent("DoLongHudText","Nice news reporting, you shit lord idiot.")
        end
    end

    if (itemid == "Gruppe6Card") then
        local coordA = GetEntityCoords(GetPlayerPed(-1), 1)
        local coordB = GetOffsetFromEntityInWorldCoords(GetPlayerPed(-1), 0.0, 100.0, 0.0)
        local countpolice = exports["isPed"]:isPed("countpolice")
        local targetVehicle = getVehicleInDirection(coordA, coordB)

        if targetVehicle ~= 0 and GetHashKey("stockade") == GetEntityModel(targetVehicle) and countpolice > 2 then
            local entityCreatePoint = GetOffsetFromEntityInWorldCoords(targetVehicle, 0.0, -4.0, 0.0)
            local coords = GetEntityCoords(GetPlayerPed(-1))
            local aDist = GetDistanceBetweenCoords(coords["x"], coords["y"],coords["z"], entityCreatePoint["x"], entityCreatePoint["y"],entityCreatePoint["z"])
            local cityCenter = vector3(-204.92, -1010.13, 29.55) -- alta street train station
            local timeToOpen = 45000
            local distToCityCenter = #(coords - cityCenter)
            if distToCityCenter > 1000 then
                local multi = math.floor(distToCityCenter / 1000)
                timeToOpen = timeToOpen + (30000 * multi)
            end
            if aDist < 2.0 then
                TriggerEvent("alert:noPedCheck", "banktruck")
                local finished = exports["caue-taskbar"]:taskBar(timeToOpen,"Unlocking Vehicle",false,false,playerVeh)
                if finished == 100 then
                    remove = true
                    TriggerEvent("sec:AttemptHeist", targetVehicle)
                else
                    TriggerEvent("evidence:bleeding")
                end

            else
                TriggerEvent("DoLongHudText","You need to do this from behind the vehicle.")
            end
        end
    end

    if (itemid == "usbdevice") then
        local finished = exports["caue-taskbar"]:taskBar(15000,"Scanning For Networks",false,false,playerVeh)
        if (finished == 100) then
            TriggerEvent("hacking:attemptHack")
        end
    end

    if (itemid == "heavyammo") then
        local finished = exports["caue-taskbar"]:taskBar(5000,"Reloading",false,true,playerVeh)
        if (finished == 100) then
            if actionBarAmmo(1788949567,50,true) then
                remove = true
            end
        end
    end

    if (itemid == "pistolammo") then
        local finished = exports["caue-taskbar"]:taskBar(2500,"Reloading",false,true,playerVeh)
        if (finished == 100) then
            if actionBarAmmo(1950175060,10,true) then
                remove = true
            end
        end
    end

    if (itemid == "pistolammoPD") then
        local finished = exports["caue-taskbar"]:taskBar(2500,"Reloading",false,true,playerVeh)
        if (finished == 100) then
            if actionBarAmmo(1950175060,10,true) then
                remove = true
            end
        end
    end

    if (itemid == "rifleammoPD") then
        local finished = exports["caue-taskbar"]:taskBar(5000,"Reloading",false,true,playerVeh)
        if (finished == 100) then
            if actionBarAmmo(218444191,30,true) then
                remove = true
            end
        end
    end

    if (itemid == "rifleammo") then
        local finished = exports["caue-taskbar"]:taskBar(5000,"Reloading",false,true,playerVeh)
        if (finished == 100) then
            if actionBarAmmo(218444191,30,true) then
                remove = true
            end
        end
    end

    if (itemid == "huntingammo") then
        local finished = exports["caue-taskbar"]:taskBar(10000,"Reloading",false,true,playerVeh)
        if (finished == 100) then
            if actionBarAmmo(1285032059,10,true) then
                remove = true
            end
        end
    end

    if (itemid == "shotgunammo") then
        local finished = exports["caue-taskbar"]:taskBar(5000,"Reloading",false,true,playerVeh)
        if (finished == 100) then
            if actionBarAmmo(-1878508229,5,true) then
                remove = true
            end
        end
    end

    if (itemid == "subammo") then
        local finished = exports["caue-taskbar"]:taskBar(5000,"Reloading",false,true,playerVeh)
        if (finished == 100) then
            if actionBarAmmo(1820140472,10,true) then
                remove = true
            end
        end
    end

    if (itemid == "nails") then
        local finished = exports["caue-taskbar"]:taskBar(5000,"Reloading",false,true,playerVeh)
        if (finished == 100) then
            if actionBarAmmo(965225813,5,true) then
                remove = true
            end
        end
    end

    if (itemid == "taserammo") then
        local finished = exports["caue-taskbar"]:taskBar(2000,"Reloading",false,true,playerVeh)
        if (finished == 100) then
            if actionBarAmmo(-1575030772,3,true) then
                remove = true
            end
        end
    end

    if (itemid == "armor") then
        local finished = exports["caue-taskbar"]:taskBar(10000,"Armor",true,false,playerVeh)
        if (finished == 100) then
            SetPlayerMaxArmour(PlayerId(), 60 )

            local wasBeatdown = exports["police"]:getBeatmodeDebuff()

            if not wasBeatdown then
                SetPedArmour( player, 60 )
                TriggerEvent("UseBodyArmor")
                remove = true
            else
                TriggerEvent("DoLongHudText","You cannot apply armor because you were beat down.")
            end
        end
    end

    if (itemid == "cbrownie" or itemid == "cgummies") then
        TriggerEvent("animation:PlayAnimation","pill")
        local finished = exports["caue-taskbar"]:taskBar(3000,"Consuming edibles 😉",false,false,playerVeh)
        if (finished == 100) then
            TriggerEvent("Evidence:StateSet",3,1200)
            TriggerEvent("Evidence:StateSet",7,1200)
            TriggerEvent("fx:run", "weed", 180, -1, false)
            remove = true
        end
    end

    if (itemid == "bodybag") then
        local finished = exports["caue-taskbar"]:taskBar(10000,"Opening bag",true,false,playerVeh)
        if (finished == 100) then
            remove = true
            TriggerEvent( "player:receiveItem", "humanhead", 1 )
            TriggerEvent( "player:receiveItem", "humantorso", 1 )
            TriggerEvent( "player:receiveItem", "humanarm", 2 )
            TriggerEvent( "player:receiveItem", "humanleg", 2 )
        end
    end

    if (itemid == "bodygarbagebag") then
        local finished = exports["caue-taskbar"]:taskBar(10000,"Opening trash bag",false,false,playerVeh)
        if (finished == 100) then
            remove = true
            TriggerServerEvent('loot:useItem', itemid)
        end
    end

    if (itemid == "newaccountbox") then
        local finished = exports["caue-taskbar"]:taskBar(5000,"Opening present",false,false,playerVeh)
        if (finished == 100) then
            remove = true
            TriggerServerEvent('loot:useItem', itemid)
        end
    end

    if (itemid == "foodsupplycrate") then
        TriggerEvent("DoLongHudText","Make sure you have a ton of space in your inventory! 100 or more.",2)
        local finished = exports["caue-taskbar"]:taskBar(20000, "Opening the crate (ESC to Cancel)", false, false, playerVeh)
        if (finished == 100) then
            remove = true
            TriggerEvent("player:receiveItem", "heartstopper", 10)
            TriggerEvent("player:receiveItem", "moneyshot", 10)
            TriggerEvent("player:receiveItem", "bleederburger", 10)
            TriggerEvent("player:receiveItem", "fries", 10)
            TriggerEvent("player:receiveItem", "cola", 10)
        end
    end

    if (itemid == "fishingtacklebox") then
        local finished = exports["caue-taskbar"]:taskBar(5000,"Opening",true,false,playerVeh)
        if (finished == 100) then
            remove = true
            TriggerServerEvent('loot:useItem', itemid)
        end
    end

    if (itemid == "fishingchest") then
        local finished = exports["caue-taskbar"]:taskBar(5000,"Opening",true,false,playerVeh)
        if (finished == 100) then
            remove = true
            TriggerEvent( "player:receiveItem", "goldbar", math.random(1,5) )
        end
    end

    if (itemid == "fishinglockbox") then
        local finished = exports["caue-taskbar"]:taskBar(5000,"Opening",true,false,playerVeh)
        if (finished == 100) then
            --remove = true
            --TriggerServerEvent('loot:useItem', itemid)
            TriggerEvent("DoLongHudText","Add your map thing here DW you fucking fuck fuck",2)
        end
    end

    if (itemid == "organcooler") then
        local finished = exports["caue-taskbar"]:taskBar(5000,"Opening cooler",true,false,playerVeh)
        if (finished == 100) then
            remove = true
            TriggerEvent( "player:receiveItem", "humanheart", 1 )
            TriggerEvent( "player:receiveItem", "organcooleropen", 1 )
        end
    end

    if (itemid == "Bankbox") then
        if (hasEnoughOfItem("locksystem",1,false)) then
            local finished = exports["caue-taskbar"]:taskBar(10000,"Opening bank box.",false,false,playerVeh)
            if (finished == 100) then
                remove = true
                TriggerEvent("inventory:removeItem","locksystem", 1)
                TriggerServerEvent('loot:useItem', itemid)
            end
        else
            TriggerEvent("DoLongHudText","You are missing something to open the box with",2)
        end
    end

    if (itemid == "Securebriefcase") then
        if (hasEnoughOfItem("Bankboxkey",1,false)) then
            local finished = exports["caue-taskbar"]:taskBar(5000,"Opening briefcase.",false,false,playerVeh)
            if (finished == 100) then
                remove = true
                TriggerEvent("inventory:removeItem","Bankboxkey", 1)
                TriggerServerEvent('loot:useItem', itemid)
            end
        else
            TriggerEvent("DoLongHudText","You are missing something to open the briefcase with",2)
        end
    end

    if (itemid == "Largesupplycrate") then
        if (hasEnoughOfItem("2227010557",1,false)) then
            local finished = exports["caue-taskbar"]:taskBar(15000,"Opening supply crate.",false,false,playerVeh)
            if (finished == 100) then
                remove = true
                TriggerEvent("inventory:removeItem","2227010557", 1)
                TriggerServerEvent('loot:useItem', itemid)
            end
        else
            TriggerEvent("DoLongHudText","You are missing something to open the crate with",2)
        end
    end

    if (itemid == "xmasgiftcoal") then
        local finished = exports["caue-taskbar"]:taskBar(15000, "Opening Gift", false, false, playerVeh)
        if (finished == 100) then
            remove = true
            TriggerServerEvent('loot:useItem', itemid)
        end
    end

    if (itemid == "Smallsupplycrate") then
        if (hasEnoughOfItem("2227010557",1,false)) then
            local finished = exports["caue-taskbar"]:taskBar(15000,"Opening supply crate.",false,false,playerVeh)
            if (finished == 100) then
                remove = true
                TriggerEvent("inventory:removeItem","2227010557", 1)
                TriggerServerEvent('loot:useItem', itemid)
            end
        else
            TriggerEvent("DoLongHudText","You are missing something to open the crate with",2)
        end
    end

    if (itemid == "Mediumsupplycrate") then
        if (hasEnoughOfItem("2227010557",1,false)) then
            local finished = exports["caue-taskbar"]:taskBar(15000,"Opening supply crate.",false,false,playerVeh)
            if (finished == 100) then
                remove = true
                TriggerEvent("inventory:removeItem","2227010557", 1)
                TriggerServerEvent('loot:useItem', itemid)
            end
        else
            TriggerEvent("DoLongHudText","You are missing something to open the crate with",2)
        end
    end

    if (itemid == "binoculars") then
        TriggerEvent("binoculars:Activate")
    end

    if (itemid == "camera") then
        TriggerEvent("camera:Activate")
    end

    if (itemid == "megaphone") then
        TriggerEvent("caue-usableprops:megaphone")
    end

    if (itemid == "nitrous") then
        local currentVehicle = GetVehiclePedIsIn(player, false)

        if currentVehicle == nil or currentVehicle == 0 then
            TriggerEvent("attachItem","nosbottle")
            TaskItem("amb@code_human_wander_idles@male@idle_a", "idle_b_rubnose", 49, 2800, "Sniff Sniff", "hadnitrous", false, itemid, playerVeh)
            TriggerEvent("destroyProp")
        elseif not IsToggleModOn(currentVehicle, 18) then
            TriggerEvent("DoLongHudText","You need a Turbo to use NOS!", 2)
        else
            local finished = 0
            local cancelNos = false
            Citizen.CreateThread(function()
                while finished ~= 100 and not cancelNos do
                    Citizen.Wait(100)
                    if GetEntitySpeed(GetVehiclePedIsIn(player, false)) > 11 then
                        exports["caue-taskbar"]:closeGuiFail()
                        cancelNos = true
                    end
                end
            end)
            finished = exports["caue-taskbar"]:taskBar(20000,"Nitrous")
            if (finished == 100 and not cancelNos) then
                TriggerEvent("vehicle:addNos", "large")
                TriggerEvent("noshud", 100, false)
                remove = true
            else
                TriggerEvent("DoLongHudText","You can't drive and hook up nos at the same time.",2)
            end
        end
    end

    if (itemid == "lockpick") then
        TriggerEvent("caue-inventory:lockpick", false, inventoryName, slot)
    end

    if (itemid == "umbrella") then
        TriggerEvent("animation:PlayAnimation","umbrella")
    end

    if (itemid == "securityblue" or itemid == "securityblack" or itemid == "securitygreen" or itemid == "securitygold" or itemid == "securityred")  then
        TriggerEvent("robbery:scanLock",false,itemid)
    end

    if (itemid == "Gruppe6Card2")  then
        TriggerServerEvent("robbery:triggerItemUsedServer",itemid)
    end

    if (itemid == "Gruppe6Card222")  then
        TriggerServerEvent("robbery:triggerItemUsedServer",itemid)
    end

    if (itemid == "ciggy") then
        local finished = exports["caue-taskbar"]:taskBar(1000,"Lighting Up",false,false,playerVeh)
        if (finished == 100) then
            Wait(300)
            TriggerEvent("animation:PlayAnimation","smoke")
        end
    end

    if (itemid == "cigar") then
        local finished = exports["caue-taskbar"]:taskBar(1000,"Lighting Up",false,false,playerVeh)
        if (finished == 100) then
            Wait(300)
            TriggerEvent("animation:PlayAnimation","cigar")
        end
    end

    if (itemid == "oxygentank") then
        local finished = exports["caue-taskbar"]:taskBar(30000,"Oxygen Tank",true,false,playerVeh)
        if (finished == 100) then
            TriggerEvent("UseOxygenTank")
            remove = true
        end
    end

    if (itemid == "bandage") then
        TaskItem("amb@world_human_clipboard@male@idle_a", "idle_c", 49,10000,"Healing","healed:minors",true,itemid,playerVeh)
    end

    if (itemid == "coke50g") then
        CreateCraftOption("coke5g", 80, true)
    end

    if (itemid == "bakingsoda") then
        CreateCraftOption("1gcrack", 80, true)
    end

    if (itemid == "glucose") then
        CreateCraftOption("1gcocaine", 80, true)
    end

    if (itemid == "drivingtest") then
        local ItemInfo = GetItemInfo(slot)
        if (ItemInfo.information ~= "No information stored") then
            local data = json.decode(ItemInfo.information)
            TriggerServerEvent("driving:getResults", data.ID)
        end
    end

    if (itemid == "1gcocaine") then
        TriggerEvent("attachItemObjectnoanim","drugpackage01")
        TriggerEvent("Evidence:StateSet",2,1200)
        TriggerEvent("Evidence:StateSet",6,1200)
        TaskItem("anim@amb@nightclub@peds@", "missfbi3_party_snort_coke_b_male3", 49, 5000, "Coke Gaming", "hadcocaine", true,itemid,playerVeh)
    end

    if (itemid == "1gcrack") then
        TriggerEvent("attachItemObjectnoanim","crackpipe01")
        TriggerEvent("Evidence:StateSet",2,1200)
        TriggerEvent("Evidence:StateSet",6,1200)
        TaskItem("switch@trevor@trev_smoking_meth", "trev_smoking_meth_loop", 49, 5000, "Smoking Quack", "hadcrack", true,itemid,playerVeh)
    end

    if (itemid == "treat") then
        local model = GetEntityModel(player)
        if model == GetHashKey("a_c_chop") then
            TaskItem("mp_player_inteat@burger", "mp_player_int_eat_burger", 49, 1200, "Treat Num's", "hadtreat", true,itemid,playerVeh)
        end
    end

    if (itemid == "IFAK") then
        TaskItem("amb@world_human_clipboard@male@idle_a", "idle_c", 49,2000,"Applying IFAK","healed:useOxy",true,itemid,playerVeh)
    end

    if (itemid == "oxy") then
        TriggerEvent("animation:PlayAnimation","pill")
        TriggerEvent("useOxy")
        TriggerEvent("healed:useOxy", true)
        remove = true
    end

    if (itemid == "methlabproduct") then
        local finished = exports["np-ui"]:taskBarSkill(1000, math.random(10, 15))
        if finished == 100 then
            TriggerEvent("attachItemObjectnoanim","crackpipe01")
            TriggerEvent("Evidence:StateSet",2,1200)
            TriggerEvent("Evidence:StateSet",6,1200)

            TaskItem("switch@trevor@trev_smoking_meth", "trev_smoking_meth_loop", 49, 1500, "Smoking Meth", "hadcocaine", true, itemid, playerVeh, nil, nil, json.decode(passedItemInfo).quality)
        end
    end

    if (itemid == "shitlockpick") then
        lockpicking = true
        TriggerEvent("animation:lockpickinvtestoutside")
        local finished = exports["np-ui"]:taskBarSkill(1000, math.random(5, 15))
        if (finished == 100) then
            TriggerEvent("caue-police:uncuffPlayer")
        end
        lockpicking = false
        remove = true
    end

    if (itemid == "watch") then
        TriggerEvent("np-ui:watch")
    end

    if (itemid == "godbook") then
        local ItemInfo = GetItemInfo(slot)
        if (ItemInfo == nil or ItemInfo.information == "No information stored" or  ItemInfo.information == nil) then return end
        local data = json.decode(ItemInfo.information)
        local cid = exports["isPed"]:isPed("cid")

        if data.cid == cid then
            remove = true
            TriggerServerEvent("inventory:gb",data)
        else
            TriggerEvent("DoLongHudText","Just looks blank to me.",2)
        end
    end

    if (itemid == "harness") then
        local currentVehicle = GetVehiclePedIsIn(player, false)

        local finished = 0
        local cancelHarness = false
        Citizen.CreateThread(function()
            while finished ~= 100 and not cancelHarness do
                Citizen.Wait(100)
                if GetEntitySpeed(GetVehiclePedIsIn(player, false)) > 11 then
                    exports["caue-taskbar"]:closeGuiFail()
                    cancelHarness = true
                end
            end
        end)
        finished = exports["caue-taskbar"]:taskBar(20000,"Harness")
        if (finished == 100 and not cancelHarness) then
            TriggerEvent("vehicle:addHarness", "large")
            TriggerEvent("harness", false, 100)
            remove = true
        else
            TriggerEvent("DoLongHudText","You can't drive and hook up nos at the same time.",2)
        end
    end

    TriggerEvent("caue-inventory:itemUsed", itemid, passedItemInfo, inventoryName, slot)
    TriggerServerEvent("caue-inventory:itemUsed", itemid, passedItemInfo, inventoryName, slot)

    if remove then
        TriggerEvent("inventory:removeItem", itemid, 1)
    end

    Wait(500)
    retardCounter = 0
    justUsed = false
end)

RegisterNetEvent('inventory:wepDropCheck')
AddEventHandler('inventory:wepDropCheck', function()
    if (not hasEnoughOfItem(GetSelectedPedWeapon(PlayerPedId()),1,false)) then
        SetCurrentPedWeapon(PlayerPedId(), `WEAPON_UNARMED`, true)
    end
end)