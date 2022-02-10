--[[

    Variables

]]

local isOpen = false

local currentJob = "unemployed"

local tablet = 0
local tabletDict = "amb@code_human_in_bus_passenger_idles@female@tablet@base"
local tabletAnim = "base"
local tabletProp = `prop_cs_tablet`
local tabletBone = 60309
local tabletOffset = vector3(0.03, 0.002, -0.0)
local tabletRot = vector3(10.0, 160.0, 0.0)

local classlist = {
    [0] = "Compact",
    [1] = "Sedan",
    [2] = "SUV",
    [3] = "Coupe",
    [4] = "Muscle",
    [5] = "Sport Classic",
    [6] = "Sport",
    [7] = "Super",
    [8] = "Motorbike",
    [9] = "Off-Road",
    [10] = "Industrial",
    [11] = "Utility",
    [12] = "Van",
    [13] = "Bike",
    [14] = "Boat",
    [15] = "Helicopter",
    [16] = "Plane",
    [17] = "Service",
    [18] = "Emergency",
    [19] = "Military",
    [20] = "Commercial",
    [21] = "Train"
}

local ColorNames = {
    [0] = "Metallic Black",
    [1] = "Metallic Graphite Black",
    [2] = "Metallic Black Steel",
    [3] = "Metallic Dark Silver",
    [4] = "Metallic Silver",
    [5] = "Metallic Blue Silver",
    [6] = "Metallic Steel Gray",
    [7] = "Metallic Shadow Silver",
    [8] = "Metallic Stone Silver",
    [9] = "Metallic Midnight Silver",
    [10] = "Metallic Gun Metal",
    [11] = "Metallic Anthracite Grey",
    [12] = "Matte Black",
    [13] = "Matte Gray",
    [14] = "Matte Light Grey",
    [15] = "Util Black",
    [16] = "Util Black Poly",
    [17] = "Util Dark silver",
    [18] = "Util Silver",
    [19] = "Util Gun Metal",
    [20] = "Util Shadow Silver",
    [21] = "Worn Black",
    [22] = "Worn Graphite",
    [23] = "Worn Silver Grey",
    [24] = "Worn Silver",
    [25] = "Worn Blue Silver",
    [26] = "Worn Shadow Silver",
    [27] = "Metallic Red",
    [28] = "Metallic Torino Red",
    [29] = "Metallic Formula Red",
    [30] = "Metallic Blaze Red",
    [31] = "Metallic Graceful Red",
    [32] = "Metallic Garnet Red",
    [33] = "Metallic Desert Red",
    [34] = "Metallic Cabernet Red",
    [35] = "Metallic Candy Red",
    [36] = "Metallic Sunrise Orange",
    [37] = "Metallic Classic Gold",
    [38] = "Metallic Orange",
    [39] = "Matte Red",
    [40] = "Matte Dark Red",
    [41] = "Matte Orange",
    [42] = "Matte Yellow",
    [43] = "Util Red",
    [44] = "Util Bright Red",
    [45] = "Util Garnet Red",
    [46] = "Worn Red",
    [47] = "Worn Golden Red",
    [48] = "Worn Dark Red",
    [49] = "Metallic Dark Green",
    [50] = "Metallic Racing Green",
    [51] = "Metallic Sea Green",
    [52] = "Metallic Olive Green",
    [53] = "Metallic Green",
    [54] = "Metallic Gasoline Blue Green",
    [55] = "Matte Lime Green",
    [56] = "Util Dark Green",
    [57] = "Util Green",
    [58] = "Worn Dark Green",
    [59] = "Worn Green",
    [60] = "Worn Sea Wash",
    [61] = "Metallic Midnight Blue",
    [62] = "Metallic Dark Blue",
    [63] = "Metallic Saxony Blue",
    [64] = "Metallic Blue",
    [65] = "Metallic Mariner Blue",
    [66] = "Metallic Harbor Blue",
    [67] = "Metallic Diamond Blue",
    [68] = "Metallic Surf Blue",
    [69] = "Metallic Nautical Blue",
    [70] = "Metallic Bright Blue",
    [71] = "Metallic Purple Blue",
    [72] = "Metallic Spinnaker Blue",
    [73] = "Metallic Ultra Blue",
    [74] = "Metallic Bright Blue",
    [75] = "Util Dark Blue",
    [76] = "Util Midnight Blue",
    [77] = "Util Blue",
    [78] = "Util Sea Foam Blue",
    [79] = "Uil Lightning blue",
    [80] = "Util Maui Blue Poly",
    [81] = "Util Bright Blue",
    [82] = "Matte Dark Blue",
    [83] = "Matte Blue",
    [84] = "Matte Midnight Blue",
    [85] = "Worn Dark blue",
    [86] = "Worn Blue",
    [87] = "Worn Light blue",
    [88] = "Metallic Taxi Yellow",
    [89] = "Metallic Race Yellow",
    [90] = "Metallic Bronze",
    [91] = "Metallic Yellow Bird",
    [92] = "Metallic Lime",
    [93] = "Metallic Champagne",
    [94] = "Metallic Pueblo Beige",
    [95] = "Metallic Dark Ivory",
    [96] = "Metallic Choco Brown",
    [97] = "Metallic Golden Brown",
    [98] = "Metallic Light Brown",
    [99] = "Metallic Straw Beige",
    [100] = "Metallic Moss Brown",
    [101] = "Metallic Biston Brown",
    [102] = "Metallic Beechwood",
    [103] = "Metallic Dark Beechwood",
    [104] = "Metallic Choco Orange",
    [105] = "Metallic Beach Sand",
    [106] = "Metallic Sun Bleeched Sand",
    [107] = "Metallic Cream",
    [108] = "Util Brown",
    [109] = "Util Medium Brown",
    [110] = "Util Light Brown",
    [111] = "Metallic White",
    [112] = "Metallic Frost White",
    [113] = "Worn Honey Beige",
    [114] = "Worn Brown",
    [115] = "Worn Dark Brown",
    [116] = "Worn straw beige",
    [117] = "Brushed Steel",
    [118] = "Brushed Black steel",
    [119] = "Brushed Aluminium",
    [120] = "Chrome",
    [121] = "Worn Off White",
    [122] = "Util Off White",
    [123] = "Worn Orange",
    [124] = "Worn Light Orange",
    [125] = "Metallic Securicor Green",
    [126] = "Worn Taxi Yellow",
    [127] = "police car blue",
    [128] = "Matte Green",
    [129] = "Matte Brown",
    [130] = "Worn Orange",
    [131] = "Matte White",
    [132] = "Worn White",
    [133] = "Worn Olive Army Green",
    [134] = "Pure White",
    [135] = "Hot Pink",
    [136] = "Salmon pink",
    [137] = "Metallic Vermillion Pink",
    [138] = "Orange",
    [139] = "Green",
    [140] = "Blue",
    [141] = "Mettalic Black Blue",
    [142] = "Metallic Black Purple",
    [143] = "Metallic Black Red",
    [144] = "hunter green",
    [145] = "Metallic Purple",
    [146] = "Metaillic V Dark Blue",
    [147] = "MODSHOP BLACK1",
    [148] = "Matte Purple",
    [149] = "Matte Dark Purple",
    [150] = "Metallic Lava Red",
    [151] = "Matte Forest Green",
    [152] = "Matte Olive Drab",
    [153] = "Matte Desert Brown",
    [154] = "Matte Desert Tan",
    [155] = "Matte Foilage Green",
    [156] = "DEFAULT ALLOY COLOR",
    [157] = "Epsilon Blue",
    [158] = "Unknown",
}

local ColorInformation = {
    [0] = "black",
    [1] = "black",
    [2] = "black",
    [3] = "darksilver",
    [4] = "silver",
    [5] = "bluesilver",
    [6] = "silver",
    [7] = "darksilver",
    [8] = "silver",
    [9] = "bluesilver",
    [10] = "darksilver",
    [11] = "darksilver",
    [12] = "matteblack",
    [13] = "gray",
    [14] = "lightgray",
    [15] = "black",
    [16] = "black",
    [17] = "darksilver",
    [18] = "silver",
    [19] = "utilgunmetal",
    [20] = "silver",
    [21] = "black",
    [22] = "black",
    [23] = "darksilver",
    [24] = "silver",
    [25] = "bluesilver",
    [26] = "darksilver",
    [27] = "red",
    [28] = "torinored",
    [29] = "formulared",
    [30] = "blazered",
    [31] = "gracefulred",
    [32] = "garnetred",
    [33] = "desertred",
    [34] = "cabernetred",
    [35] = "candyred",
    [36] = "orange",
    [37] = "gold",
    [38] = "orange",
    [39] = "red",
    [40] = "mattedarkred",
    [41] = "orange",
    [42] = "matteyellow",
    [43] = "red",
    [44] = "brightred",
    [45] = "garnetred",
    [46] = "red",
    [47] = "red",
    [48] = "darkred",
    [49] = "darkgreen",
    [50] = "racingreen",
    [51] = "seagreen",
    [52] = "olivegreen",
    [53] = "green",
    [54] = "gasolinebluegreen",
    [55] = "mattelimegreen",
    [56] = "darkgreen",
    [57] = "green",
    [58] = "darkgreen",
    [59] = "green",
    [60] = "seawash",
    [61] = "midnightblue",
    [62] = "darkblue",
    [63] = "saxonyblue",
    [64] = "blue",
    [65] = "blue",
    [66] = "blue",
    [67] = "diamondblue",
    [68] = "blue",
    [69] = "blue",
    [70] = "brightblue",
    [71] = "purpleblue",
    [72] = "blue",
    [73] = "ultrablue",
    [74] = "brightblue",
    [75] = "darkblue",
    [76] = "midnightblue",
    [77] = "blue",
    [78] = "blue",
    [79] = "lightningblue",
    [80] = "blue",
    [81] = "brightblue",
    [82] = "mattedarkblue",
    [83] = "matteblue",
    [84] = "matteblue",
    [85] = "darkblue",
    [86] = "blue",
    [87] = "lightningblue",
    [88] = "yellow",
    [89] = "yellow",
    [90] = "bronze",
    [91] = "yellow",
    [92] = "lime",
    [93] = "champagne",
    [94] = "beige",
    [95] = "darkivory",
    [96] = "brown",
    [97] = "brown",
    [98] = "lightbrown",
    [99] = "beige",
    [100] = "brown",
    [101] = "brown",
    [102] = "beechwood",
    [103] = "beechwood",
    [104] = "chocoorange",
    [105] = "yellow",
    [106] = "yellow",
    [107] = "cream",
    [108] = "brown",
    [109] = "brown",
    [110] = "brown",
    [111] = "white",
    [112] = "white",
    [113] = "beige",
    [114] = "brown",
    [115] = "brown",
    [116] = "beige",
    [117] = "steel",
    [118] = "blacksteel",
    [119] = "aluminium",
    [120] = "chrome",
    [121] = "wornwhite",
    [122] = "offwhite",
    [123] = "orange",
    [124] = "lightorange",
    [125] = "green",
    [126] = "yellow",
    [127] = "blue",
    [128] = "green",
    [129] = "brown",
    [130] = "orange",
    [131] = "white",
    [132] = "white",
    [133] = "darkgreen",
    [134] = "white",
    [135] = "pink",
    [136] = "pink",
    [137] = "pink",
    [138] = "orange",
    [139] = "green",
    [140] = "blue",
    [141] = "blackblue",
    [142] = "blackpurple",
    [143] = "blackred",
    [144] = "darkgreen",
    [145] = "purple",
    [146] = "darkblue",
    [147] = "black",
    [148] = "purple",
    [149] = "darkpurple",
    [150] = "red",
    [151] = "darkgreen",
    [152] = "olivedrab",
    [153] = "brown",
    [154] = "tan",
    [155] = "green",
    [156] = "silver",
    [157] = "blue",
    [158] = "black",
}

--[[

    Main

]]

function EnableGUI(enable)
    local jobRank = {}

    if enable then
        TriggerServerEvent("caue-mdt:opendashboard")

        if currentJob == "ems" then
            TriggerServerEvent("caue-mdt:getAllReports")
        end

        local job = exports["caue-base"]:getChar("job")
        if job == "judge" or job == "defender" or job == "district attorney" then
            job = "doj"
        end

        jobRank = RPC.execute("caue-groups:rankInfos", job, exports["caue-groups"]:GroupRank(job))
    end

    SetNuiFocus(enable, enable)
    SendNUIMessage({
        type = "show",
        enable = enable,
        job = currentJob,
        rank = jobRank
    })

    isOpen = enable
    TriggerEvent("caue-mdt:animation")
end

function RefreshGUI()
    SetNuiFocus(false, false)
    SendNUIMessage({
        type = "show",
        enable = false,
        job = currentJob
    })

    isOpen = false
end

RegisterNetEvent("caue-jobs:jobChanged")
AddEventHandler("caue-jobs:jobChanged", function(job)
    if exports["caue-jobs"]:getJob(job, "is_police") then
        currentJob = "police"
    elseif exports["caue-jobs"]:getJob(job, "is_medic") then
        currentJob = "ems"
    elseif exports["caue-jobs"]:getJob(job, "is_doj") then
        currentJob = "doj"
    elseif currentJob ~= "unemployed" then
        currentJob =  "unemployed"
    end
end)

RegisterNetEvent("caue-mdt:open")
AddEventHandler("caue-mdt:open", function()
    open = true
    EnableGUI(open)

    local x, y, z = table.unpack(GetEntityCoords(PlayerPedId()))

    local currentStreetHash, intersectStreetHash = GetStreetNameAtCoord(x, y, z)
    local currentStreetName = GetStreetNameFromHashKey(currentStreetHash)
    local intersectStreetName = GetStreetNameFromHashKey(intersectStreetHash)
    local zone = tostring(GetNameOfZone(x, y, z))
    local area = GetLabelText(zone)
    local playerStreetsLocation = area

    if not zone then zone = "UNKNOWN" end

    if intersectStreetName ~= nil and intersectStreetName ~= "" then
        playerStreetsLocation = currentStreetName .. ", " .. intersectStreetName .. ", " .. area
    elseif currentStreetName ~= nil and currentStreetName ~= "" then
        playerStreetsLocation = currentStreetName .. ", " .. area
    else
        playerStreetsLocation = area
    end

    local fullName = exports["caue-base"]:getChar("first_name") .. " " .. exports["caue-base"]:getChar("last_name")

    SendNUIMessage({
        type = "data",
        name = "Bem-vindo, " .. fullName, location = playerStreetsLocation, fullname = fullName
    })
end)

AddEventHandler("caue-mdt:animation", function()
    if not isOpen then return end

    -- Animation
    RequestAnimDict(tabletDict)
    while not HasAnimDictLoaded(tabletDict) do Citizen.Wait(100) end

    -- Model
    RequestModel(tabletProp)
    while not HasModelLoaded(tabletProp) do Citizen.Wait(100) end

    local plyPed = PlayerPedId()
    local tabletObj = CreateObject(tabletProp, 0.0, 0.0, 0.0, true, true, false)
    local tabletBoneIndex = GetPedBoneIndex(plyPed, tabletBone)

    TriggerEvent("actionbar:setEmptyHanded")
    AttachEntityToEntity(tabletObj, plyPed, tabletBoneIndex, tabletOffset.x, tabletOffset.y, tabletOffset.z, tabletRot.x, tabletRot.y, tabletRot.z, true, false, false, false, 2, true)
    SetModelAsNoLongerNeeded(tabletProp)

    CreateThread(function()
        while isOpen do
            Wait(0)
            if not IsEntityPlayingAnim(plyPed, tabletDict, tabletAnim, 3) then
                TaskPlayAnim(plyPed, tabletDict, tabletAnim, 3.0, 3.0, -1, 49, 0, 0, 0, 0)
            end
        end
        ClearPedSecondaryTask(plyPed)

        Citizen.Wait(250)

        DetachEntity(tabletObj, true, false)
        DeleteEntity(tabletObj)

        return
    end)
end)

RegisterNUICallback("escape", function(data, cb)
    open = false
    EnableGUI(open)
    cb(true)
end)

RegisterNetEvent("caue-mdt:exitMDT")
AddEventHandler("caue-mdt:exitMDT", function()
    open = false
    EnableGUI(open)
end)

--[[

    Bulletins

]]

RegisterNetEvent("caue-mdt:dashboardbulletin")
AddEventHandler("caue-mdt:dashboardbulletin", function(sentData)
    SendNUIMessage({
        type = "bulletin",
        data = sentData
    })
end)

RegisterNUICallback("newBulletin", function(data, cb)
    TriggerServerEvent("caue-mdt:newBulletin", data.title, data.info, data.time)
    cb(true)
end)

RegisterNetEvent("caue-mdt:newBulletin")
AddEventHandler("caue-mdt:newBulletin", function(ignoreId, sentData, job)
    if ignoreId == GetPlayerServerId(PlayerId()) then return end

    if job == currentJob then
        SendNUIMessage({
            type = "newBulletin",
            data = sentData
        })
    end
end)

RegisterNUICallback("deleteBulletin", function(data, cb)
    TriggerServerEvent("caue-mdt:deleteBulletin", data.id)
    cb(true)
end)

RegisterNetEvent("caue-mdt:deleteBulletin")
AddEventHandler("caue-mdt:deleteBulletin", function(ignoreId, sentData, job)
    if ignoreId == GetPlayerServerId(PlayerId()) then return end

    if job == currentJob then
        SendNUIMessage({
            type = "deleteBulletin",
            data = sentData
        })
    end
end)

--[[

    Messages

]]

RegisterNetEvent("caue-mdt:dashboardMessages")
AddEventHandler("caue-mdt:dashboardMessages", function(sentData)
    SendNUIMessage({
        type = "dispatchmessages",
        data = sentData
    })
end)

RegisterNUICallback("refreshDispatchMsgs", function(data, cb)
    TriggerServerEvent("caue-mdt:refreshDispatchMsgs")
    cb(true)
end)

RegisterNUICallback("dispatchMessage", function(data, cb)
    TriggerServerEvent("caue-mdt:sendMessage", data.message, data.time)
    cb(true)
end)

RegisterNetEvent("caue-mdt:dashboardMessage")
AddEventHandler("caue-mdt:dashboardMessage", function(sentData, job)
    if currentJob == job then
        SendNUIMessage({
            type = "dispatchmessage",
            data = sentData
        })
    end
end)


--[[

    Units

]]

RegisterNetEvent("caue-mdt:getActiveUnits")
AddEventHandler("caue-mdt:getActiveUnits", function(police, bcso, sahp, sasp, doc, sapr, pa, ems)
    SendNUIMessage({
        type = "getActiveUnits",
        police = police,
        bcso = bcso,
        sast = sahp,
        sasp = sasp,
        doc = doc,
        sapr = sapr,
        pa = pa,
        ems = ems
    })
end)

RegisterNUICallback("setWaypointU", function(data, cb)
    TriggerServerEvent("caue-mdt:setWaypoint:unit", data.cid)
    cb(true)
end)

RegisterNetEvent("caue-mdt:setWaypoint:unit")
AddEventHandler("caue-mdt:setWaypoint:unit", function(sentData)
    TriggerEvent("DoLongHudText", "GPS marked!")
    SetNewWaypoint(sentData.x, sentData.y)
end)

RegisterNUICallback("setRadio", function(data, cb)
    -- TriggerServerEvent("caue-mdt:setRadio", data.cid, data.newradio)
    cb(true)
end)

RegisterNetEvent("caue-mdt:setRadio")
AddEventHandler("caue-mdt:setRadio", function(radio, name)
    if radio then
        if (not exports["caue-inventory"]:hasEnoughOfItem("radio",1,false)) then
            TriggerEvent("DoLongHudText", "Missing radio, " .. name .. " tried to set your radio frequency.", 2)
            return
        end

        exports["caue-voice"]:setVoiceProperty("radioEnabled", true)
        exports["caue-voice"]:setRadioChannel(tonumber(radio))
        TriggerEvent("DoLongHudText", "A frequência do seu rádio foi setada para " .. radio .. " MHz, por " .. name)
    end
end)

RegisterNUICallback("setCallsign", function(data, cb)
    TriggerServerEvent("caue-mdt:setCallsign", data.cid, data.newcallsign)
    cb(true)
end)

RegisterNUICallback("toggleDuty", function(data, cb)
    -- TriggerServerEvent("caue-mdt:toggleDuty", data.cid, data.status)
    cb(true)
end)

--[[

    Calls

]]

RegisterNetEvent("dispatch:clNotify")
AddEventHandler("dispatch:clNotify", function(sNotificationData, sNotificationId)
    sNotificationData.callId = sNotificationId
    SendNUIMessage({
        type = "call",
        data = sNotificationData
    })
end)

RegisterNUICallback("setWaypoint", function(data, cb)
    local call = RPC.execute("caue-dispatch:getCall", data.callid)

    if call then
        TriggerEvent("DoLongHudText", "GPS marcado!")
        SetNewWaypoint(call.origin.x, call.origin.y)
    end

    cb(true)
end)

RegisterNUICallback("callAttach", function(data, cb)
    TriggerServerEvent("caue-mdt:callAttach", data.callid)

    cb(true)
end)

RegisterNetEvent("caue-mdt:callAttach")
AddEventHandler("caue-mdt:callAttach", function(callid, sentData)
    if currentJob == "police" or currentJob == "ems" then
        SendNUIMessage({
            type = "callAttach",
            callid = callid,
            data = tonumber(sentData)
        })
    end
end)

RegisterNUICallback("callDetach", function(data, cb)
    TriggerServerEvent("caue-mdt:callDetach", data.callid)

    cb(true)
end)

RegisterNetEvent("caue-mdt:callDetach")
AddEventHandler("caue-mdt:callDetach", function(callid, sentData)
    if currentJob == "police" or currentJob == "ems" then
        SendNUIMessage({
            type = "callDetach",
            callid = callid,
            data = tonumber(sentData)
        })
    end
end)

RegisterNUICallback("attachedUnits", function(data, cb)
    TriggerServerEvent("caue-mdt:attachedUnits", data.callid)

    cb(true)
end)

RegisterNetEvent("caue-mdt:attachedUnits")
AddEventHandler("caue-mdt:attachedUnits", function(sentData, callid)
    SendNUIMessage({
        type = "attachedUnits",
        data = sentData,
        callid = callid
    })
end)

RegisterNUICallback("callDragAttach", function(data, cb)
    TriggerServerEvent("caue-mdt:callDragAttach", data.callid, data.cid)

    cb(true)
end)

RegisterNUICallback("callDispatchDetach", function(data, cb)
    TriggerServerEvent("caue-mdt:callDispatchDetach", tonumber(data.callid), tonumber(data.cid))

    cb(true)
end)

RegisterNUICallback("setDispatchWaypoint", function(data, cb)
    TriggerServerEvent("caue-mdt:setDispatchWaypoint", tonumber(data.callid), tonumber(data.cid))

    cb(true)
end)

RegisterNUICallback("dispatchNotif", function(data, cb)
    cb(true)
end)

RegisterNUICallback("getCallResponses", function(data, cb)
    TriggerServerEvent("caue-mdt:getCallResponses", data.callid)

    cb(true)
end)

RegisterNetEvent("caue-mdt:getCallResponses")
AddEventHandler("caue-mdt:getCallResponses", function(sentData, sentCallId)
    SendNUIMessage({
        type = "getCallResponses",
        data = sentData,
        callid = sentCallId
    })
end)

RegisterNUICallback("sendCallResponse", function(data, cb)
    TriggerServerEvent("caue-mdt:sendCallResponse", data.message, data.time, data.callid)

    cb(true)
end)

RegisterNetEvent("caue-mdt:sendCallResponse")
AddEventHandler("caue-mdt:sendCallResponse", function(message, time, callid, name)
    SendNUIMessage({
        type = "sendCallResponse",
        message = message,
        time = time,
        callid = callid,
        name = name
    })
end)

--[[

    Warrants

]]

RegisterNetEvent("caue-mdt:dashboardWarrants")
AddEventHandler("caue-mdt:dashboardWarrants", function(sentData)
    SendNUIMessage({
        type = "warrants",
        data = sentData
    })
end)

--[[

    Profiles

]]

RegisterNUICallback("getAllProfiles", function(data, cb)
    TriggerServerEvent("caue-mdt:getAllProfiles", data.name)
    cb(true)
end)

RegisterNetEvent("caue-mdt:searchProfile")
AddEventHandler("caue-mdt:searchProfile", function(sentData, isLimited)
    SendNUIMessage({
        type = "profiles",
        data = sentData,
        isLimited = isLimited
    })
end)

RegisterNUICallback("searchProfiles", function(data, cb)
    TriggerServerEvent("caue-mdt:searchProfile", data.name)
    cb(true)
end)

RegisterNUICallback("getProfileData", function(data, cb)
    TriggerServerEvent("caue-mdt:getProfileData", data.id)
    cb(true)
end)

RegisterNetEvent("caue-mdt:getProfileData")
AddEventHandler("caue-mdt:getProfileData", function(sentData)
    local vehicles = sentData["vehicles"]

    for i = 1, #vehicles do
        sentData["vehicles"][i]["plate"] = string.upper(sentData["vehicles"][i]["plate"])

        local tempModel = vehicles[i]["model"]

        if tempModel and tempModel ~= "Unknown" then
            local DisplayNameModel = GetDisplayNameFromVehicleModel(tempModel)
            local LabelText = GetLabelText(DisplayNameModel)

            if LabelText == "NULL" then
                LabelText = DisplayNameModel
            end

            sentData["vehicles"][i]["model"] = LabelText
        end
    end

    SendNUIMessage({
        type = "profileData",
        data = sentData
    })
end)

RegisterNUICallback("saveProfile", function(data, cb)
    TriggerServerEvent("caue-mdt:saveProfile", data.pfp, data.description, data.id, data.fName, data.sName)
    cb(true)
end)

RegisterNUICallback("updateLicence", function(data, cb)
    TriggerServerEvent("caue-mdt:updateLicense", data.cid, data.type, data.status)
    cb(true)
end)

RegisterNUICallback("newTag", function(data, cb)
    TriggerServerEvent("caue-mdt:newTag", data.id, data.tag)
    cb(true)
end)

RegisterNUICallback("removeProfileTag", function(data, cb)
    TriggerServerEvent("caue-mdt:removeProfileTag", data.cid, data.text)
    cb(true)
end)

RegisterNUICallback("addGalleryImg", function(data, cb)
    TriggerServerEvent("caue-mdt:addGalleryImg", data.cid, data.URL)
    cb(true)
end)

RegisterNUICallback("removeGalleryImg", function(data, cb)
    TriggerServerEvent("caue-mdt:removeGalleryImg", data.cid, data.URL)
    cb(true)
end)

--[[

    Incidents

]]

RegisterNUICallback("getAllIncidents", function(data, cb)
    TriggerServerEvent("caue-mdt:getAllIncidents")
    cb(true)
end)

RegisterNetEvent("caue-mdt:getAllIncidents")
AddEventHandler("caue-mdt:getAllIncidents", function(sentData)
    SendNUIMessage({
        type = "incidents",
        data = sentData
    })
end)

RegisterNUICallback("searchIncidents", function(data, cb)
    TriggerServerEvent("caue-mdt:searchIncidents", data.incident)
    cb(true)
end)

RegisterNetEvent("caue-mdt:getIncidents")
AddEventHandler("caue-mdt:getIncidents", function(sentData)
    SendNUIMessage({
        type = "incidents",
        data = sentData
    })
end)

RegisterNUICallback("getIncidentData", function(data, cb)
    TriggerServerEvent("caue-mdt:getIncidentData", data.id)
    cb(true)
end)

RegisterNetEvent("caue-mdt:updateIncidentDbId")
AddEventHandler("caue-mdt:updateIncidentDbId", function(sentData)
    SendNUIMessage({
        type = "updateIncidentDbId",
        data = sentData
    })
end)

RegisterNetEvent("caue-mdt:getIncidentData")
AddEventHandler("caue-mdt:getIncidentData", function(sentData, sentConvictions)
    SendNUIMessage({
        type = "incidentData",
        data = sentData,
        convictions = sentConvictions
    })
end)

RegisterNUICallback("incidentSearchPerson", function(data, cb)
    TriggerServerEvent("caue-mdt:incidentSearchPerson", data.name)
    cb(true)
end)

RegisterNetEvent("caue-mdt:incidentSearchPerson")
AddEventHandler("caue-mdt:incidentSearchPerson", function(sentData)
    SendNUIMessage({
        type = "incidentSearchPerson",
        data = sentData
    })
end)

RegisterNUICallback("getPenalCode", function(data, cb)
    TriggerServerEvent("caue-mdt:getPenalCode")
    cb(true)
end)

RegisterNetEvent("caue-mdt:getPenalCode")
AddEventHandler("caue-mdt:getPenalCode", function(titles, penalcode)
    SendNUIMessage({
        type = "getPenalCode",
        titles = titles,
        penalcode = penalcode
    })
end)

RegisterNUICallback("saveIncident", function(data, cb)
    TriggerServerEvent("caue-mdt:saveIncident", data)
    cb(true)
end)

RegisterNUICallback("removeIncidentCriminal", function(data, cb)
    TriggerServerEvent("caue-mdt:removeIncidentCriminal", data.cid, data.incidentId)
    cb(true)
end)

--[[

    Reports

]]

RegisterNUICallback("getAllReports", function(data, cb)
    TriggerServerEvent("caue-mdt:getAllReports")
    cb(true)
end)

RegisterNetEvent("caue-mdt:getAllReports")
AddEventHandler("caue-mdt:getAllReports", function(sentData)
    SendNUIMessage({
        type = "reports",
        data = sentData
    })
end)

RegisterNUICallback("searchReports", function(data, cb)
    TriggerServerEvent("caue-mdt:searchReports", data.name)
    cb(true)
end)

RegisterNUICallback("getReportData", function(data, cb)
    TriggerServerEvent("caue-mdt:getReportData", data.id)
    cb(true)
end)

RegisterNetEvent("caue-mdt:getReportData")
AddEventHandler("caue-mdt:getReportData", function(sentData)
    SendNUIMessage({
        type = "reportData",
        data = sentData
    })
end)

RegisterNUICallback("newReport", function(data, cb)
    TriggerServerEvent("caue-mdt:newReport", data)
    cb(true)
end)

RegisterNetEvent("caue-mdt:reportComplete")
AddEventHandler("caue-mdt:reportComplete", function(sentData)
    SendNUIMessage({
        type = "reportComplete",
        data = sentData
    })
end)

--[[

    BOLOs

]]

RegisterNUICallback("getAllBolos", function(data, cb)
    TriggerServerEvent("caue-mdt:getAllBolos")
    cb(true)
end)

RegisterNetEvent("caue-mdt:getBolos")
AddEventHandler("caue-mdt:getBolos", function(sentData)
    SendNUIMessage({
        type = "bolos",
        data = sentData
    })
end)

RegisterNUICallback("searchBolos", function(data, cb)
    local searchVal = data.searchVal
    TriggerServerEvent("caue-mdt:searchBolos", searchVal)
    cb(true)
end)

RegisterNUICallback("getBoloData", function(data, cb)
    TriggerServerEvent("caue-mdt:getBoloData", data.id)
    cb(true)
end)

RegisterNetEvent("caue-mdt:getBoloData")
AddEventHandler("caue-mdt:getBoloData", function(sentData)
    SendNUIMessage({
        type = "boloData",
        data = sentData
    })
end)

RegisterNUICallback("newBolo", function(data, cb)
    TriggerServerEvent("caue-mdt:newBolo", data)
    cb(true)
end)

RegisterNetEvent("caue-mdt:boloComplete")
AddEventHandler("caue-mdt:boloComplete", function(sentData)
    SendNUIMessage({
        type = "boloComplete",
        data = sentData
    })
end)

RegisterNUICallback("deleteBolo", function(data, cb)
    TriggerServerEvent("caue-mdt:deleteBolo", data.id)
    cb(true)
end)

RegisterNUICallback("deleteICU", function(data, cb)
    TriggerServerEvent("caue-mdt:deleteICU", data.id)
    cb(true)
end)

--[[

    DMV

]]

RegisterNUICallback("getAllVehicles", function(data, cb)
    TriggerServerEvent("caue-mdt:getAllVehicles")
    cb(true)
end)

RegisterNUICallback("searchHouse", function(data, cb)
    local houseInfo = exports["caue-housing"]:getHouse(data.house_id)
    TriggerEvent("DoLongHudText", "GPS marcado!")
    SetNewWaypoint(houseInfo["pos"].x, houseInfo["pos"].y)
    cb(true)
end)

RegisterNetEvent("caue-mdt:searchVehicles")
AddEventHandler("caue-mdt:searchVehicles", function(sentData)
    for i, v in ipairs(sentData) do
        sentData[i].color = ColorInformation[v.color1]
        sentData[i].colorName = ColorNames[v.color1]
        sentData[i].model = GetLabelText(GetDisplayNameFromVehicleModel(v.model))
    end

    SendNUIMessage({
        type = "searchedVehicles",
        data = sentData
    })
end)

RegisterNUICallback("getVehicleData", function(data, cb)
    TriggerServerEvent("caue-mdt:getVehicleData", data.plate)
    cb(true)
end)

RegisterNetEvent("caue-mdt:updateVehicleDbId")
AddEventHandler("caue-mdt:updateVehicleDbId", function(sentData)
    SendNUIMessage({
        type = "updateVehicleDbId",
        data = sentData
    })
end)

RegisterNetEvent("caue-mdt:getVehicleData")
AddEventHandler("caue-mdt:getVehicleData", function(sentData)
    sentData["color"] = ColorInformation[sentData["color1"]]
    sentData["colorName"] = ColorNames[sentData["color1"]]
    sentData["model"] = GetLabelText(GetDisplayNameFromVehicleModel(sentData["model"]))
    sentData["class"] = classlist[GetVehicleClassFromName(sentData["model"])]

    SendNUIMessage({
        type = "getVehicleData",
        data = sentData
    })
end)

RegisterNUICallback("saveVehicleInfo", function(data, cb)
    TriggerServerEvent("caue-mdt:saveVehicleInfo", data.dbid, data.plate, data.imageurl, data.notes)
    cb(true)
end)

RegisterNUICallback("knownInformation", function(data, cb)
    TriggerServerEvent("caue-mdt:knownInformation", data.dbid, data.type, data.status, data.plate)
    cb(true)
end)

--[[

    Logs

]]

RegisterNUICallback("getAllLogs", function(data, cb)
    TriggerServerEvent("caue-mdt:getAllLogs")
    cb(true)
end)

RegisterNetEvent("caue-mdt:getAllLogs")
AddEventHandler("caue-mdt:getAllLogs", function(sentData)
    SendNUIMessage({
        type = "getAllLogs",
        data = sentData
    })
end)