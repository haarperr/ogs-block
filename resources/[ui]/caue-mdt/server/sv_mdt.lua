--[[

    Variables

]]

local usersRadios = {}
local penalCode = {}
local penalCodeCategorys = {}

--[[

    Main

]]

function getJob(src)
    local job = exports["caue-base"]:getChar(src, "job")

    if exports["caue-jobs"]:getJob(job, "is_police") then
        return "police"
    elseif exports["caue-jobs"]:getJob(job, "is_medic") then
        return "ems"
    elseif exports["caue-jobs"]:getJob(job, "is_doj") then
        return "doj"
    end

    return "unemployed"
end

RegisterServerEvent("caue-mdt:opendashboard")
AddEventHandler("caue-mdt:opendashboard", function()
    local src = source
    UpdateWarrants(src)
    UpdateBulletins(src)
    UpdateMessages(src)
    UpdateUnits(src)
end)

--[[

    Bulletins

]]

function UpdateBulletins(src)
    local job = getJob(src)

    local result = exports.ghmattimysql:executeSync([[
        SELECT b.id, b.title, b.description, b.time, CONCAT(c.first_name," ",c.last_name) AS author
        FROM mdt_bulletins b
        LEFT JOIN characters c ON c.id = b.cid
        WHERE b.job = ?
    ]],
    { job })

    TriggerClientEvent("caue-mdt:dashboardbulletin", src, result)
end

RegisterServerEvent("caue-mdt:newBulletin")
AddEventHandler("caue-mdt:newBulletin", function(title, info, time)
    local src = source

    local cid = exports["caue-base"]:getChar(src, "id")
    local name = exports["caue-base"]:getChar(src, "first_name") .. " " .. exports["caue-base"]:getChar(src, "last_name")
    local job = getJob(src)

	local result = exports.ghmattimysql:executeSync([[
        INSERT INTO mdt_bulletins (cid, title, description, job, time)
        VALUES (?, ?, ?, ?, ?)
    ]],
    { cid, title, info, job, time })

    if not result["insertId"] or result["insertId"] < 1 then return end

    local bulletin = {
        id = result["insertId"],
        title = title,
        info = info,
        time = time,
        author = name
    }

    TriggerClientEvent("caue-mdt:newBulletin", -1, src, bulletin, job)
    TriggerEvent("caue-mdt:newLog", name .. " Opened a new Bulletin: Title " .. title .. ", Info " .. info, job, time)
end)

RegisterServerEvent("caue-mdt:deleteBulletin")
AddEventHandler("caue-mdt:deleteBulletin", function(id)
    local src = source

    local name = exports["caue-base"]:getChar(src, "first_name") .. " " .. exports["caue-base"]:getChar(src, "last_name")
    local job = getJob(src)

    local title = exports.ghmattimysql:scalarSync([[
        SELECT title
        FROM mdt_bulletins
        WHERE id = ?
    ]],
    { id })

    exports.ghmattimysql:executeSync([[
        DELETE FROM mdt_bulletins
        WHERE id = ?
    ]],
    { id })

    TriggerClientEvent("caue-mdt:deleteBulletin", -1, src, id, job)
    TriggerEvent("caue-mdt:newLog", "A bulletin was deleted by " .. name .. " with the title: " .. title .. "!", job)
end)

--[[

    Messages

]]

function UpdateMessages(src)
    local job = getJob(src)

    local result = exports.ghmattimysql:executeSync([[
        SELECT m.message, m.time, CONCAT(c.first_name," ",c.last_name) AS name, c.gender, p.image
        FROM mdt_messages m
        LEFT JOIN characters c ON c.id = m.cid
        LEFT JOIN mdt_profiles p ON p.cid = m.cid
        WHERE m.job = ?
        ORDER BY m.id DESC
        LIMIT 50
    ]],
    { job })

    for i, v in ipairs(result) do
        result[i].image = profilePic(v.gender, v.image)
    end

    TriggerClientEvent("caue-mdt:dashboardMessages", src, ReverseTable(result))
end

RegisterServerEvent("caue-mdt:refreshDispatchMsgs")
AddEventHandler("caue-mdt:refreshDispatchMsgs", function()
    local src = source

    local job = getJob(src)

    local result = exports.ghmattimysql:executeSync([[
        SELECT message, time, CONCAT(c.first_name," ",c.last_name) AS name, c.gender, p.image
        FROM mdt_messages m
        LEFT JOIN characters c ON c.id = m.cid
        LEFT JOIN mdt_profiles p ON p.cid = m.cid
        WHERE m.job = ?
        ORDER BY m.id DESC
        LIMIT 50
    ]],
    { job })

    for i, v in ipairs(result) do
        result[i].image = profilePic(v.gender, v.image)
    end

    TriggerClientEvent("caue-mdt:dashboardMessages", src, ReverseTable(result))
end)

RegisterServerEvent("caue-mdt:sendMessage")
AddEventHandler("caue-mdt:sendMessage", function(message, time)
    local src = source

    local cid = exports["caue-base"]:getChar(src, "id")
    local name = exports["caue-base"]:getChar(src, "first_name") .. " " .. exports["caue-base"]:getChar(src, "last_name")
    local job = getJob(src)

    exports.ghmattimysql:executeSync([[
        INSERT INTO mdt_messages (cid, message, job, time)
        VALUES (?, ?, ?, ?)
    ]],
    { cid, message, job, time })

    local image = exports.ghmattimysql:scalarSync([[
        SELECT image
        FROM mdt_profiles
        WHERE cid = ?
    ]],
    { cid })

    local lastMsg = {
        name = name,
        image = profilePic(exports["caue-base"]:getChar(src, "gender"), image),
        message = message,
        time = time,
    }

    TriggerClientEvent("caue-mdt:dashboardMessage", -1, lastMsg, job)
end)

--[[

    Units

]]

function UpdateUnits(src)
    local police, bcso, sahp, sasp, doc, sapr, pa, ems = {}, {}, {}, {}, {}, {}, {}, {}

    local users = exports["caue-base"]:getUsers()

    for user, vars in pairs(users) do
        local character = exports["caue-base"]:getChar(user)

        if character then
		    local job = character.job

            if exports["caue-jobs"]:getJob(job, "is_emergency") or exports["caue-jobs"]:getJob(job, "is_doj") then
                local name = character.first_name .. " " .. character.last_name
                local callSign = exports["caue-jobs"]:getCallsign(user, job)

                if exports["caue-jobs"]:getJob(job, "is_police") then
                    polices = #police + 1
                    police[polices] = {}
                    police[polices].duty = 1
                    police[polices].cid = character.id
                    police[polices].radio = usersRadios[character] or nil
                    police[polices].callsign = callSign
                    police[polices].name = name
                elseif exports["caue-jobs"]:getJob(job, "is_medic") then
                    emss = #ems + 1
                    ems[emss] = {}
                    ems[emss].duty = 1
                    ems[emss].cid = character.id
                    ems[emss].radio = usersRadios[character] or nil
                    ems[emss].callsign = callSign
                    ems[emss].name = name
                elseif exports["caue-jobs"]:getJob(job, "is_doj") then
                    pas = #pa + 1
                    pa[pas] = {}
                    pa[pas].duty = 1
                    pa[pas].cid = character.id
                    pa[pas].radio = usersRadios[character] or nil
                    pa[pas].callsign = (exports["caue-groups"]:rankInfos("doj", exports["caue-groups"]:getRank("doj", 0, character.id)))["name"]
                    pa[pas].name = name
                end
            end
        end
    end

    TriggerClientEvent("caue-mdt:getActiveUnits", src, police, bcso, sahp, sasp, doc, sapr, pa, ems)
end

RegisterServerEvent("caue-mdt:setWaypoint:unit")
AddEventHandler("caue-mdt:setWaypoint:unit", function(cid)
    local src = source

    local player = exports["caue-base"]:getSidWithCid(cid)
    if player == 0 then return end

    local coords = GetEntityCoords(GetPlayerPed(src))

    TriggerClientEvent("caue-mdt:setWaypoint:unit", src, coords)
end)

RegisterServerEvent("caue-mdt:setRadio")
AddEventHandler("caue-mdt:setRadio", function(radio)
    local src = source
    local cid = exports["caue-base"]:getChar(src, "id")

    usersRadios[cid] = radio
end)

RegisterServerEvent("caue-mdt:setRadioTo")
AddEventHandler("caue-mdt:setRadioTo", function(cid, radio)
    local src = source
    local target = exports["caue-base"]:getSidWithCid(cid)

    if target == 0 then return end

    local name = exports["caue-base"]:getChar(src, "first_name") .. " " .. exports["caue-base"]:getChar(src, "last_name")
    local nameTarget = exports["caue-base"]:getChar(target, "first_name") .. " " .. exports["caue-base"]:getChar(target, "last_name")

    TriggerClientEvent("DoLongHudText", src, "A frequência de " .. nameTarget .. " foi setada para " .. radio)
    TriggerClientEvent("caue-mdt:setRadio", target, tonumber(radio), name)
end)

RegisterServerEvent("caue-mdt:setCallsign")
AddEventHandler("caue-mdt:setCallsign", function(cid, callsign)
    local src = source

    local job = exports["caue-base"]:getChar(src, "job")

    exports["caue-jobs"]:setCallsign(cid, job, callsign)
end)

RegisterNetEvent("caue-mdt:toggleDuty")
AddEventHandler("caue-mdt:toggleDuty", function(cid, status)

end)

--[[

    Calls

]]

RegisterServerEvent("caue-mdt:callAttach")
AddEventHandler("caue-mdt:callAttach", function(callid)
    local src = source

    local units = exports["caue-dispatch"]:addUnit(src, callid)

    TriggerClientEvent("caue-mdt:callAttach", -1, callid, units)
end)

RegisterServerEvent("caue-mdt:callDetach")
AddEventHandler("caue-mdt:callDetach", function(callid)
    local src = source

    local units = exports["caue-dispatch"]:removeUnit(src, callid)

    TriggerClientEvent("caue-mdt:callDetach", -1, callid, units)
end)

RegisterServerEvent("caue-mdt:attachedUnits")
AddEventHandler("caue-mdt:attachedUnits", function(callid)
    local src = source

    local units = exports["caue-dispatch"]:getUnits(callid)

    TriggerClientEvent("caue-mdt:attachedUnits", src, units, callid)
end)

RegisterServerEvent("caue-mdt:callDragAttach")
AddEventHandler("caue-mdt:callDragAttach", function(callid, cid)
    local src = source

    local player = exports["caue-base"]:getSidWithCid(cid)
    if player == 0 then return end

    local units = exports["caue-dispatch"]:addUnit(player, callid)

    TriggerClientEvent("caue-mdt:callAttach", -1, callid, units)
end)

RegisterServerEvent("caue-mdt:callDispatchDetach")
AddEventHandler("caue-mdt:callDispatchDetach", function(callid, cid)
    local src = source

    local player = exports["caue-base"]:getSidWithCid(cid)
    if player == 0 then return end

    local units = exports["caue-dispatch"]:removeUnit(player, callid)

    TriggerClientEvent("caue-mdt:callDetach", -1, callid, units)
end)

RegisterServerEvent("caue-mdt:setDispatchWaypoint")
AddEventHandler("caue-mdt:setDispatchWaypoint", function(callid, cid)
    local src = source

    local player = exports["caue-base"]:getSidWithCid(cid)
    if player == 0 then return end

    local coords = GetEntityCoords(GetPlayerPed(src))

    TriggerClientEvent("caue-mdt:setWaypoint:unit", src, coords)
end)

RegisterServerEvent("caue-mdt:getCallResponses")
AddEventHandler("caue-mdt:getCallResponses", function(callid)
    local src = source

    local responses = exports["caue-dispatch"]:getCallReponses(callid)

    TriggerClientEvent("caue-mdt:getCallResponses", src, responses, callid)
end)

RegisterServerEvent("caue-mdt:sendCallResponse")
AddEventHandler("caue-mdt:sendCallResponse", function(message, time, callid, name)
    local src = source

    local name = exports["caue-base"]:getChar(src, "first_name") .. " " .. exports["caue-base"]:getChar(src, "last_name")
    local responded = exports["caue-dispatch"]:sendCallResponse(name, callid, message, time)

    if responded then
        TriggerClientEvent("caue-mdt:sendCallResponse", src, message, time, callid, name)
    end
end)

--[[

    Warrants

]]

function UpdateWarrants(src)
    local firsttime = true

    local result = exports.ghmattimysql:executeSync([[
        SELECT *
        FROM mdt_incidents
    ]])

    for i, v in ipairs(result) do
        for i2, v2 in ipairs(json.decode(v.associated)) do
            if v2.warrant == true then
                local name = exports.ghmattimysql:scalarSync([[
                    SELECT CONCAT(first_name," ",last_name)
                    FROM characters
                    WHERE id = ?
                ]],
                { v2.cid })

                TriggerClientEvent("caue-mdt:dashboardWarrants", src, {
                    firsttime = firsttime,
                    time = v.time,
                    linkedincident = v.id,
                    reporttitle = v.title,
                    name = name,
                    cid = v2.cid
                })

                if firsttime then
                    firsttime = false
                end
            end
        end
    end
end

--[[

    Profiles

]]

function profilePic(pGender, pImage)
	if pImage and pImage ~= "" then
        return pImage
    end

    if pGender == 1 then
        return "img/female.png"
    else
        return "img/male.png"
    end
end

RegisterServerEvent("caue-mdt:getAllProfiles")
AddEventHandler("caue-mdt:getAllProfiles", function()
    local src = source

    local result = exports.ghmattimysql:executeSync([[
        SELECT c.id, c.first_name, c.last_name, c.gender, c.licenses, p.image, p.description
        FROM characters c
        LEFT JOIN mdt_profiles p ON p.cid = c.id
        ORDER BY c.first_name DESC
    ]])

    for i, v in ipairs(result) do
        result[i].identifier  = v.id
        result[i].firstname = v.first_name
        result[i].lastname  = v.last_name
        result[i].policemdtinfo = v.description
        result[i].warrant = false
        result[i].convictions = 0
        result[i].cid = v.id

        result[i].pp = profilePic(result[i].gender, result[i].image)

        local licenses = json.decode(v.licenses)

        for k2, v2 in pairs(licenses) do
            if k2 == "weapon" and v2 == 1 then
                result[i].Weapon = true
            end
            if k2 == "driver" and v2 == 1 then
                result[i].Drivers = true
            end
            if k2 == "hunting" and v2 == 1 then
                result[i].Hunting = true
            end
            if k2 == "fishing" and v2 == 1 then
                result[i].Fishing = true
            end
            if k2 == "bar" and v2 == 1 then
                result[i].Bar = true
            end
            if k2 == "business" and v2 == 1 then
                result[i].Business = true
            end
            if k2 == "pilot" and v2 == 1 then
                result[i].Pilot = true
            end
        end
    end

	TriggerClientEvent("caue-mdt:searchProfile", src, result, true)
end)

RegisterServerEvent("caue-mdt:searchProfile")
AddEventHandler("caue-mdt:searchProfile", function(query)
    local src = source

    local queryData = string.lower("%" .. query .. "%")
    local result = exports.ghmattimysql:executeSync([[
        SELECT c.id, c.first_name, c.last_name, c.gender, c.licenses, p.image, p.description
        FROM characters c
        LEFT JOIN mdt_profiles p ON p.cid = c.id
        WHERE LOWER(c.first_name) LIKE ? OR LOWER(c.id) LIKE ? OR LOWER(c.last_name) LIKE ? OR CONCAT(LOWER(c.first_name), " ", LOWER(c.last_name), " ", LOWER(c.id)) LIKE ?
        ORDER BY c.first_name DESC
    ]],
    { queryData, queryData, queryData, queryData })

	for i, v in ipairs(result) do
        result[i].identifier  = v.id
        result[i].firstname = v.first_name
        result[i].lastname  = v.last_name
        result[i].policemdtinfo = v.description
        result[i].warrant = false
        result[i].convictions = 0
        result[i].cid = v.id

        result[i].pp = profilePic(result[i].gender, result[i].image)

        local licenses = json.decode(v.licenses)

        for k2, v2 in pairs(licenses) do
            if k2 == "weapon" and v2 == 1 then
                result[i].Weapon = true
            end
            if k2 == "driver" and v2 == 1 then
                result[i].Drivers = true
            end
            if k2 == "hunting" and v2 == 1 then
                result[i].Hunting = true
            end
            if k2 == "fishing" and v2 == 1 then
                result[i].Fishing = true
            end
            if k2 == "bar" and v2 == 1 then
                result[i].Bar = true
            end
            if k2 == "business" and v2 == 1 then
                result[i].Business = true
            end
            if k2 == "pilot" and v2 == 1 then
                result[i].Pilot = true
            end
        end
    end

	TriggerClientEvent("caue-mdt:searchProfile", src, result, true)
end)

function getProfile(cid)
    local result = exports.ghmattimysql:executeSync([[
        SELECT c.id, c.first_name, c.last_name, c.dob, c.gender, c.job, c.licenses, p.image, p.description, p.tags, p.gallery
        FROM characters c
        LEFT JOIN mdt_profiles p ON p.cid = c.id
        WHERE c.id = ?
    ]],
    { cid })

    local vehicles = exports.ghmattimysql:executeSync([[
        SELECT plate, model
        FROM vehicles
        WHERE cid = ?
    ]],
    { cid })

    local houses = exports.ghmattimysql:executeSync([[
        SELECT hid
        FROM housing
        WHERE cid = ?
    ]],
    { cid })

    for i, v in ipairs(houses) do
        local houseInfo = exports["caue-housing"]:getHouse(v.hid)

        houses[i] = {
            house_id = v.hid,
            house_name = houseInfo.street
        }
    end

    local incidents = exports.ghmattimysql:executeSync([[
        SELECT associated
        FROM mdt_incidents
    ]])

    local object = {
        cid = result[1].id,
        firstname = result[1].first_name,
        lastname = result[1].last_name,
        job = exports["caue-jobs"]:getJob(result[1].job, "name"),
        dateofbirth = result[1]["dob"],
        profilepic = profilePic(result[1].gender, result[1].image),
        policemdtinfo = "",
        Weapon = false,
        Drivers = false,
        Hunting = false,
        Fishing = false,
        Bar = false,
        Business = false,
        Pilot = false,
        tags = {},
        vehicles = vehicles,
        properties = houses,
        gallery = {},
        convictions = {}
    }

    if result[1].description ~= nil then
        object.policemdtinfo = result[1].description
    end

    if result[1].tags ~= nil then
        object.tags = json.decode(result[1].tags)
    end

    if result[1].gallery ~= nil then
        object.gallery = json.decode(result[1].gallery)
    end

    for i, v in ipairs(incidents) do
        for i2, v2 in ipairs(json.decode(v.associated)) do
            if v2.cid == result[1]["id"] then
                local _charges = {}

                for i3, v3 in ipairs(v2.charges) do
                    if _charges[v3] then
                        _charges[v3] = _charges[v3] + 1
                    else
                        _charges[v3] = 1
                    end
                end

                local charges = {}
                for charge, count in pairs(_charges) do
                    table.insert(charges, count .. "x " .. charge)
                end

                object.convictions = charges
            end
        end
    end

    local licenses = json.decode(result[1].licenses)
    for k, v in pairs(licenses) do
        if k == "weapon" and v == 1 then
            object.Weapon = true
        end
        if k == "driver" and v == 1 then
            object.Drivers = true
        end
        if k == "hunting" and v == 1 then
            object.Hunting = true
        end
        if k == "fishing" and v == 1 then
            object.Fishing = true
        end
        if k == "bar" and v == 1 then
            object.Bar = true
        end
        if k == "business" and v == 1 then
            object.Business = true
        end
        if k == "pilot" and v == 1 then
            object.Pilot = true
        end
    end

    return object
end

RegisterServerEvent("caue-mdt:getProfileData")
AddEventHandler("caue-mdt:getProfileData", function(identifier)
    local src = source
    local data = getProfile(identifier)
    TriggerClientEvent("caue-mdt:getProfileData", src, data, false)
end)

RegisterServerEvent("caue-mdt:saveProfile")
AddEventHandler("caue-mdt:saveProfile", function(image, description, cid, fname, lname)
    if not cid then return end

    local src = source

    if not image then image = "" end
    if not description then description = "" end

    local result = exports.ghmattimysql:scalarSync([[
        SELECT id
        FROM mdt_profiles
        WHERE cid = ?
    ]],
    { cid })

	if result then
        exports.ghmattimysql:executeSync([[
            UPDATE mdt_profiles
            SET image = ?, description = ?
            WHERE cid = ?
        ]],
        { image, description, cid })
	else
		exports.ghmattimysql:executeSync([[
            INSERT INTO mdt_profiles (cid, image, description, tags, gallery)
            VALUES (?, ?, ?, ?, ?)
        ]],
        { cid, image, description, "{}", "{}" })
	end
end)

RegisterServerEvent("caue-mdt:updateLicense")
AddEventHandler("caue-mdt:updateLicense", function(identifier, type, status)
    local src = source

    local name = exports["caue-base"]:getChar(src, "first_name") .. " " .. exports["caue-base"]:getChar(src, "last_name")
    local time = os.date()

    if status == "revoke" then
        action = "Revoked"
        status = 0
    else
        action = "Given"
        status = 1
    end

    TriggerEvent("caue-mdt:newLog", name .. " " .. action .. " licenses type: " .. (type:gsub("^%l", string.upper)) .. " Edited Citizen Id: " .. identifier, time)

    exports["caue-licenses"]:updateLicense(0, type, status, identifier)
end)

RegisterServerEvent("caue-mdt:newTag")
AddEventHandler("caue-mdt:newTag", function(cid, tag)
    local result = exports.ghmattimysql:scalarSync([[
        SELECT tags
        FROM mdt_profiles
        WHERE cid = ?
    ]],
    { cid })

    if result then
        local tags = json.decode(result)

        table.insert(tags, tag)

        exports.ghmattimysql:executeSync([[
            UPDATE mdt_profiles
            SET tags = ?
            WHERE cid = ?
        ]],
        { json.encode(tags), cid })
    else
        local tags = {}

        table.insert(tags, tag)

        exports.ghmattimysql:executeSync([[
            INSERT INTO mdt_profiles (cid, image, description, tags, gallery)
            VALUES (?, ?, ?, ?, ?)
        ]],
        { cid, "", "", json.encode(tags), "{}" })
    end
end)

RegisterServerEvent("caue-mdt:removeProfileTag")
AddEventHandler("caue-mdt:removeProfileTag", function(cid, tag)
    local result = exports.ghmattimysql:scalarSync([[
        SELECT tags
        FROM mdt_profiles
        WHERE cid = ?
    ]],
    { cid })

    if result then
        local tags = json.decode(result)

        for i, v in ipairs(tags) do
            if v == tag then
                table.remove(tags, i)
            end
        end

        exports.ghmattimysql:executeSync([[
            UPDATE mdt_profiles
            SET tags = ?
            WHERE cid = ?
        ]],
        { json.encode(tags), cid })
    end
end)

RegisterServerEvent("caue-mdt:addGalleryImg")
AddEventHandler("caue-mdt:addGalleryImg", function(cid, url)
    local result = exports.ghmattimysql:scalarSync([[
        SELECT gallery
        FROM mdt_profiles
        WHERE cid = ?
    ]],
    { cid })

    if result then
        local gallery = json.decode(result)

        table.insert(gallery, url)

        exports.ghmattimysql:executeSync([[
            UPDATE mdt_profiles
            SET gallery = ?
            WHERE cid = ?
        ]],
        { json.encode(gallery), cid })
    else
        local gallery = {}

        table.insert(gallery, url)

        exports.ghmattimysql:executeSync([[
            INSERT INTO mdt_profiles (cid, image, description, tags, gallery)
            VALUES (?, ?, ?, ?, ?)
        ]],
        { cid, "", "", "{}", json.encode(gallery) })
    end
end)

RegisterServerEvent("caue-mdt:removeGalleryImg")
AddEventHandler("caue-mdt:removeGalleryImg", function(cid, url)
    local result = exports.ghmattimysql:scalarSync([[
        SELECT gallery
        FROM mdt_profiles
        WHERE cid = ?
    ]],
    { cid })

    if result then
        local gallery = json.decode(result)

        for i, v in ipairs(gallery) do
            if v == url then
                table.remove(gallery, i)
            end
        end

        exports.ghmattimysql:executeSync([[
            UPDATE mdt_profiles
            SET gallery = ?
            WHERE cid = ?
        ]],
        { json.encode(gallery), cid })
    end
end)

--[[

    Incidents

]]

RegisterServerEvent("caue-mdt:getAllIncidents")
AddEventHandler("caue-mdt:getAllIncidents", function()
    local src = source

    local result = exports.ghmattimysql:executeSync([[
        SELECT i.id, i.title, i.time, CONCAT(c.first_name," ",c.last_name) AS author
        FROM mdt_incidents i
        LEFT JOIN characters c ON c.id = i.cid
    ]])

    TriggerClientEvent("caue-mdt:getAllIncidents", src, result)
end)

RegisterServerEvent("caue-mdt:searchIncidents")
AddEventHandler("caue-mdt:searchIncidents", function(query)
    local src = source

    local result = exports.ghmattimysql:executeSync([[
        SELECT i.id, i.title, i.time, CONCAT(c.first_name," ",c.last_name) AS author
        FROM mdt_incidents i
        LEFT JOIN characters c ON c.id = i.cid
        WHERE i.id = ?
    ]],
    { tonumber(query) })

    TriggerClientEvent("caue-mdt:getIncidents", src, result)
end)

RegisterServerEvent("caue-mdt:getIncidentData")
AddEventHandler("caue-mdt:getIncidentData", function(id)
    local src = source

    local result = exports.ghmattimysql:executeSync([[
        SELECT *
        FROM mdt_incidents
        WHERE id = ?
    ]],
    { id })

    result[1].tags = json.decode(result[1].tags)
    result[1].officersinvolved = json.decode(result[1].officers)
    result[1].civsinvolved = json.decode(result[1].civilians)
    result[1].evidence = json.decode(result[1].evidence)
    result[1].charges = json.decode(result[1].associated.charges)
    result[1].associated = json.decode(result[1].associated)

    for i, v in ipairs(result[1].associated) do
        local name = exports.ghmattimysql:scalarSync([[
            SELECT CONCAT(first_name," ",last_name)
            FROM characters
            WHERE id = ?
        ]],
        { v.cid })

        result[1].associated[i].name = name
    end

    TriggerClientEvent("caue-mdt:updateIncidentDbId", src, result[1].id)
    TriggerClientEvent("caue-mdt:getIncidentData", src, result[1], result[1].associated)
end)

RegisterServerEvent("caue-mdt:incidentSearchPerson")
AddEventHandler("caue-mdt:incidentSearchPerson", function(query)
    local src = source

    local queryData = string.lower("%" .. query .. "%")
    local result = exports.ghmattimysql:executeSync([[
        SELECT c.id, c.first_name, c.last_name, c.gender, p.image
        FROM characters c
        LEFT JOIN mdt_profiles p ON p.cid = c.id
        WHERE LOWER(c.first_name) LIKE ? OR LOWER(c.id) LIKE ? OR LOWER(c.last_name) LIKE ? OR CONCAT(LOWER(c.first_name), " ", LOWER(c.last_name), " ", LOWER(c.id)) LIKE ?
        ORDER BY c.first_name DESC
    ]],
    { queryData, queryData, queryData, queryData })

    for i, v in pairs(result) do
		result[i].image = profilePic(v.gender, v.image)
	end

    TriggerClientEvent("caue-mdt:incidentSearchPerson", src, result)
end)

RegisterServerEvent("caue-mdt:getPenalCode")
AddEventHandler("caue-mdt:getPenalCode", function()
    local src = source

    TriggerClientEvent("caue-mdt:getPenalCode", src, penalCodeCategorys, penalCode)
end)

RegisterServerEvent("caue-mdt:saveIncident")
AddEventHandler("caue-mdt:saveIncident", function(data)
    local src = source

    local cid = exports["caue-base"]:getChar(src, "id")

    if data.ID ~= 0 then
        exports.ghmattimysql:executeSync([[
            UPDATE mdt_incidents
            SET cid = ?, title = ?, details = ?, tags = ?, officers = ?, civilians = ?, evidence = ?, associated = ?, time = ?
            WHERE id = ?
        ]],
        { cid, data.title, data.information, json.encode(data.tags), json.encode(data.officers), json.encode(data.civilians), json.encode(data.evidence), json.encode(data.associated), data.time, data.ID })
    else
        exports.ghmattimysql:executeSync([[
            INSERT INTO mdt_incidents (cid, title, details, tags, officers, civilians, evidence, associated, time)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?)
        ]],
        { cid, data.title, data.information, json.encode(data.tags), json.encode(data.officers), json.encode(data.civilians), json.encode(data.evidence), json.encode(data.associated), data.time })
    end
end)

RegisterServerEvent("caue-mdt:removeIncidentCriminal")
AddEventHandler("caue-mdt:removeIncidentCriminal", function(cid, incident)
    local src = source

    local name = exports["caue-base"]:getChar(src, "first_name") .. " " .. exports["caue-base"]:getChar(src, "last_name")

    local result = exports.ghmattimysql:scalarSync([[
        SELECT associated
        FROM mdt_incidents
        WHERE id = ?
    ]],
    { incident })

    local criminal_name = ""
    local result = json.decode(result)

    for i, v in ipairs(result) do
        if v.cid == cid then
            criminal_name = exports.ghmattimysql:scalarSync([[
                SELECT CONCAT(first_name," ",last_name)
                FROM characters
                WHERE id = ?
            ]],
            { cid })

            table.remove(result, i)
        end
    end

    TriggerEvent("caue-mdt:newLog", name .. ", Removed a criminal from an incident, incident ID: " .. incident .. ", Criminal Citizen Id: " .. cid .. ", Name: " .. criminal_name, "police")
    TriggerEvent("caue-mdt:newLog", name .. ", Removed a criminal from an incident, incident ID: " .. incident .. ", Criminal Citizen Id: " .. cid .. ", Name: " .. criminal_name, "doj")

    exports.ghmattimysql:executeSync([[
        UPDATE mdt_incidents
        SET associated = ?
        WHERE id = ?
    ]],
    { json.encode(result), incident })
end)

--[[

    Reports

]]

RegisterServerEvent("caue-mdt:getAllReports")
AddEventHandler("caue-mdt:getAllReports", function()
    local src = source

    local job = getJob(src)

    local result = exports.ghmattimysql:executeSync([[
        SELECT r.id, r.title, r.type, r.time, CONCAT(c.first_name," ",c.last_name) AS author
        FROM mdt_reports r
        LEFT JOIN characters c ON c.id = r.cid
        WHERE r.job = ?
    ]],
    { job })

    TriggerClientEvent("caue-mdt:getAllReports", src, result)
end)

RegisterServerEvent("caue-mdt:searchReports")
AddEventHandler("caue-mdt:searchReports", function(querydata)
    local src = source

    local job = getJob(src)

    local string = string.lower("%" .. querydata .. "%")

    local result = exports.ghmattimysql:executeSync([[
        SELECT r.id, r.title, r.type, r.time, CONCAT(c.first_name," ",c.last_name) AS author
        FROM mdt_reports r
        LEFT JOIN characters c ON c.id = r.cid
        WHERE (LOWER(r.type) LIKE ? OR LOWER(r.title) LIKE ? OR LOWER(r.id) LIKE ? OR CONCAT(LOWER(r.type), " ", LOWER(r.title), " ", LOWER(r.id)) LIKE ?) AND r.job = ?
    ]],
    { string, string, string, string, job })

    TriggerClientEvent("caue-mdt:getAllReports", src, result)
end)

RegisterServerEvent("caue-mdt:getReportData")
AddEventHandler("caue-mdt:getReportData", function(id)
    local src = source

    local result = exports.ghmattimysql:executeSync([[
        SELECT *
        FROM mdt_reports
        WHERE id = ?
    ]],
    { id })

    result[1].tags = json.decode(result[1].tags)
    result[1].gallery = json.decode(result[1].gallery)
    result[1].officersinvolved = json.decode(result[1].officers)
    result[1].civsinvolved = json.decode(result[1].civilians)

    TriggerClientEvent("caue-mdt:getReportData", src, result[1])
end)

RegisterServerEvent("caue-mdt:newReport")
AddEventHandler("caue-mdt:newReport", function(data)
    local src = source

    if data.title == "" then return end

    local cid = exports["caue-base"]:getChar(src, "id")
    local name = exports["caue-base"]:getChar(src, "first_name") .. " " .. exports["caue-base"]:getChar(src, "last_name")
    local job = getJob(src)

    if data.id ~= nil and data.id ~= 0 then
        exports.ghmattimysql:executeSync([[
            UPDATE mdt_reports
            SET cid = ?, title = ?, type = ?, detail = ?, tags = ?, gallery = ?, officers = ?, civilians = ?, time = ?
            WHERE id = ?
        ]],
        { cid, data.title, data.type, data.detail, json.encode(data.tags), json.encode(data.gallery), json.encode(data.officers), json.encode(data.civilians), data.time, data.id })

        TriggerEvent("caue-mdt:newLog", "A report was updated by " .. name .. " with the title (" .. data.title .. ") and ID (" .. data.id .. ")", job, data.time)
    else
        local result = exports.ghmattimysql:executeSync([[
            INSERT INTO mdt_reports (cid, title, type, detail, tags, gallery, officers, civilians, job, time)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ]],
        { cid, data.title, data.type, data.detail, json.encode(data.tags), json.encode(data.gallery), json.encode(data.officers), json.encode(data.civilians), job, data.time })

        if result["insertId"] and result["insertId"] > 0 then
            TriggerClientEvent("caue-mdt:reportComplete", src, result["insertId"])
            TriggerEvent("caue-mdt:newLog", "A new report was created by " .. name .. " with the title (" .. data.title .. ") and ID (" .. result["insertId"] .. ")", job, data.time)
        end
    end
end)

--[[

    BOLOs

]]

RegisterServerEvent("caue-mdt:getAllBolos")
AddEventHandler("caue-mdt:getAllBolos", function()
    local src = source

    local job = getJob(src)

    local result = exports.ghmattimysql:executeSync([[
        SELECT b.id, b.title, b.time, CONCAT(c.first_name," ",c.last_name) AS author
        FROM mdt_bolos b
        LEFT JOIN characters c ON c.id = b.cid
        WHERE b.job = ?
    ]],
    { job })

    TriggerClientEvent("caue-mdt:getBolos", src, result)
end)

RegisterServerEvent("caue-mdt:searchBolos")
AddEventHandler("caue-mdt:searchBolos", function(query)
    local src = source

    local job = getJob(src)

    local result = exports.ghmattimysql:executeSync([[
        SELECT b.id, b.title, b.time, CONCAT(c.first_name," ",c.last_name) AS author
        FROM mdt_bolos b
        LEFT JOIN characters c ON c.id = b.cid
        WHERE (LOWER(b.plate) LIKE ? OR LOWER(b.title) LIKE ? OR CONCAT(LOWER(b.plate), " ", LOWER(b.title)) LIKE ?) AND b.job = ?
    ]],
    { query, query, query, job })

    TriggerClientEvent("caue-mdt:getBolos", src, result)
end)

RegisterServerEvent("caue-mdt:getBoloData")
AddEventHandler("caue-mdt:getBoloData", function(id)
    local src = source

    local result = exports.ghmattimysql:executeSync([[
        SELECT id, title, plate, owner, individual, detail, tags, gallery, officers
        FROM mdt_bolos
        WHERE id = ?
    ]],
    { id })

    result[1].tags = json.decode(result[1].tags)
    result[1].gallery = json.decode(result[1].gallery)
    result[1].officers = json.decode(result[1].officers)

    TriggerClientEvent("caue-mdt:getBoloData", src, result[1])
end)

RegisterServerEvent("caue-mdt:newBolo")
AddEventHandler("caue-mdt:newBolo", function(data)
    local src = source

    if data.title == "" then return end

    local cid = exports["caue-base"]:getChar(src, "id")
    local name = exports["caue-base"]:getChar(src, "first_name") .. " " .. exports["caue-base"]:getChar(src, "last_name")
    local job = getJob(src)

    if data.id ~= nil and data.id ~= 0 then
        exports.ghmattimysql:executeSync([[
            UPDATE mdt_bolos
            SET cid = ?, title = ?, plate = ?, owner = ?, individual = ?, detail = ?, tags = ?, gallery = ?, officers = ?, time = ?
            WHERE id = ?
        ]],
        { cid, data.title, data.plate, data.owner, data.individual, data.detail, json.encode(data.tags), json.encode(data.gallery), json.encode(data.officers), data.time, data.id })

        TriggerEvent("caue-mdt:newLog", "A BOLO was updated by " .. name .. " with the title (" .. data.title .. ") and ID (" .. data.id .. ")", job, data.time)
    else
        local result = exports.ghmattimysql:executeSync([[
            INSERT INTO mdt_bolos (cid, title, plate, owner, individual, detail, tags, gallery, officers, job, time)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ]],
        { cid, data.title, data.plate, data.owner, data.individual, data.detail, json.encode(data.tags), json.encode(data.gallery), json.encode(data.officers), job, data.time})

        if result["insertId"] and result["insertId"] > 0 then
            TriggerClientEvent("caue-mdt:boloComplete", src, result["insertId"])
            TriggerEvent("caue-mdt:newLog", "A new BOLO was created by " .. name .. " with the title (" .. data.title .. ") and ID (" .. result["insertId"] .. ")", job, data.time)
        end
    end
end)

RegisterServerEvent("caue-mdt:deleteBolo")
AddEventHandler("caue-mdt:deleteBolo", function(id)
    local src = source

    local name = exports["caue-base"]:getChar(src, "first_name") .. " " .. exports["caue-base"]:getChar(src, "last_name")
    local job = getJob(src)

    exports.ghmattimysql:executeSync([[
        DELETE FROM mdt_bolos
        WHERE id = ?
    ]],
    { id })

    TriggerEvent("caue-mdt:newLog", "A BOLO was deleted by " .. name .. " with the ID (" .. id .. ")", job)
end)

--[[

    DMV

]]

RegisterServerEvent("caue-mdt:getAllVehicles")
AddEventHandler("caue-mdt:getAllVehicles", function()
    local src = source

    local result = exports.ghmattimysql:executeSync([[
        SELECT v.id, v.cid, v.plate, v.model, g.state, d.modifications, m.image, m.code5, m.stolen, CONCAT(c.first_name," ",c.last_name) AS owner
        FROM vehicles v
        LEFT JOIN vehicles_garage g ON g.vid = v.id
        LEFT JOIN vehicles_metadata d ON d.vid = v.id
        LEFT JOIN mdt_vehicles m ON m.plate = v.plate
        LEFT JOIN characters c ON c.id = v.cid
    ]])

    local vehicles = {}

    for i, v in ipairs(result) do
        local _vehicle = {
            id = v.id,
            dbid = v.id,
            plate = v.plate,
            model = v.model,
            owner = v.owner,
            image = "img/not-found.jpg",
            color1 = 0,
            color2 = 0,
            code = false,
            stolen = false,
            bolo = false
        }

        if v.code5 ~= nil and v.code5 == 1 then _vehicle.code5 = true end
        if v.stolen ~= nil and v.stolen == 1 then _vehicle.stolen = true end

        if v.image and v.image ~= nil and v.image ~= "" then
            _vehicle.image = v.image
        end

        if v.modifications then
            local _modifications = json.decode(v.modifications)
            if _modifications["colors"] then
                _vehicle.color1 = _modifications["colors"][1]
                _vehicle.color2 = _modifications["colors"][2]
            end
        end

        local bolo = exports.ghmattimysql:scalarSync([[
            SELECT id
            FROM mdt_bolos
            WHERE plate = ?
            LIMIT 1
        ]],
        { v.plate })

        if bolo then
            _vehicle.bolo = true
        end

        table.insert(vehicles, _vehicle)
    end

    TriggerClientEvent("caue-mdt:searchVehicles", src, vehicles)
end)

RegisterServerEvent("caue-mdt:searchVehicles")
AddEventHandler("caue-mdt:searchVehicles", function(plate)
    local src = source

    local plate = string.lower("%" .. plate .. "%")

    local result = exports.ghmattimysql:executeSync([[
        SELECT v.id, v.cid, v.plate, v.model, g.state, d.modifications, m.image, m.code5, m.stolen, CONCAT(c.first_name," ",c.last_name) AS owner
        FROM vehicles v
        LEFT JOIN vehicles_garage g ON g.vid = v.id
        LEFT JOIN vehicles_metadata d ON d.vid = v.id
        LEFT JOIN mdt_vehicles m ON m.plate = v.plate
        LEFT JOIN characters c ON c.id = v.cid
        WHERE LOWER(v.plate) LIKE ?
    ]],
    { plate })

    local vehicles = {}

    for i, v in ipairs(result) do
        local _vehicle = {
            id = v.id,
            dbid = v.id,
            plate = v.plate,
            model = v.model,
            owner = v.owner,
            image = "img/not-found.jpg",
            color1 = 0,
            color2 = 0,
            code = false,
            stolen = false,
            bolo = false
        }

        if v.code5 ~= nil and v.code5 == 1 then _vehicle.code5 = true end
        if v.stolen ~= nil and v.stolen == 1 then _vehicle.stolen = true end

        if v.image and v.image ~= nil and v.image ~= "" then
            _vehicle.image = v.image
        end

        if v.modifications then
            local _modifications = json.decode(v.modifications)
            if _modifications["colors"] then
                _vehicle.color1 = _modifications["colors"][1]
                _vehicle.color2 = _modifications["colors"][2]
            end
        end

        local bolo = exports.ghmattimysql:scalarSync([[
            SELECT id
            FROM mdt_bolos
            WHERE plate = ?
            LIMIT 1
        ]],
        { v.plate })

        if bolo then
            _vehicle.bolo = true
        end

        table.insert(vehicles, _vehicle)
    end

    TriggerClientEvent("caue-mdt:searchVehicles", src, vehicles)
end)

RegisterServerEvent("caue-mdt:getVehicleData")
AddEventHandler("caue-mdt:getVehicleData", function(plate)
    local src = source

    local result = exports.ghmattimysql:executeSync([[
        SELECT v.id, v.cid, v.plate, v.model, g.state, d.modifications, m.notes, m.image, m.code5, m.stolen, CONCAT(c.first_name," ",c.last_name) AS owner
        FROM vehicles v
        LEFT JOIN vehicles_garage g ON g.vid = v.id
        LEFT JOIN vehicles_metadata d ON d.vid = v.id
        LEFT JOIN mdt_vehicles m ON m.plate = v.plate
        LEFT JOIN characters c ON c.id = v.cid
        WHERE v.plate = ?
    ]],
    { plate })

    local vehicle = {
        id = result[1].id,
        dbid = result[1].id,
        plate = result[1].plate,
        model = result[1].model,
        owner = result[1].owner,
        notes = result[1].notes,
        image = "img/not-found.jpg",
        color1 = 0,
        color2 = 0,
        code = false,
        stolen = false,
        bolo = false
    }

    if result[1].code5 and result[1].code5 == 1 then vehicle.code5 = true end
    if result[1].stolen and result[1].stolen == 1 then vehicle.stolen = true end

    if result[1].image and result[1].image ~= nil and result[1].image ~= "" then
        vehicle.image = result[1].image
    end

    if result[1].modifications then
        local _modifications = json.decode(result[1].modifications)
        if _modifications["colors"] then
            vehicle.color1 = _modifications["colors"][1]
            vehicle.color2 = _modifications["colors"][2]
        end
    end

    local bolo = exports.ghmattimysql:scalarSync([[
        SELECT id
        FROM mdt_bolos
        WHERE plate = ?
        LIMIT 1
    ]],
    { result[1].plate })

    if bolo then
        vehicle.bolo = true
    end

    TriggerClientEvent("caue-mdt:updateVehicleDbId", src, vehicle.id)
    TriggerClientEvent("caue-mdt:getVehicleData", src, vehicle)
end)

RegisterServerEvent("caue-mdt:saveVehicleInfo")
AddEventHandler("caue-mdt:saveVehicleInfo", function(dbid, plate, image, notes)
	local src = source

    if dbid == 0 or plate == "" then return end

    if not image or imagev == "" then imageurl = "" end
	if not notes or notes == "" then notes = "" end

    local result = exports.ghmattimysql:scalarSync([[
        SELECT id
        FROM mdt_vehicles
        WHERE plate = ?
    ]],
    { plate })

    if result then
		exports.ghmattimysql:executeSync([[
            UPDATE mdt_vehicles
            SET notes = ?, image = ?
            WHERE plate = ?
        ]],
        { notes, image, plate })
	else
		exports.ghmattimysql:executeSync([[
            INSERT INTO mdt_vehicles (plate, notes, image)
            VALUES (?, ?, ?, ?, ?)
        ]],
        { plate, notes, image })
	end
end)

RegisterServerEvent("caue-mdt:knownInformation")
AddEventHandler("caue-mdt:knownInformation", function(dbid, type, status, plate)
    local src = source

    local result = exports.ghmattimysql:scalarSync([[
        SELECT id
        FROM mdt_vehicles
        WHERE plate = ?
    ]],
    { plate })

    if result then
		exports.ghmattimysql:executeSync([[
            UPDATE mdt_vehicles
            SET ?? = ?
            WHERE plate = ?
        ]],
        { type, status, plate })
	else
        exports.ghmattimysql:executeSync([[
            INSERT INTO mdt_vehicles (plate, notes, image, ??)
            VALUES (?, ?, ?, ?)
        ]],
        { type, plate, "", "", status })
	end
end)

--[[

    Logs

]]

RegisterServerEvent("caue-mdt:newLog")
AddEventHandler("caue-mdt:newLog", function(text, job, time)
    if not time then
        time = os.time() * 1000
    end

    exports.ghmattimysql:executeSync([[
        INSERT INTO mdt_logs (text, job, time)
        VALUES (?, ?, ?)
    ]],
    { text, job, time })
end)

RegisterServerEvent("caue-mdt:getAllLogs")
AddEventHandler("caue-mdt:getAllLogs", function()
    local src = source

    local job = getJob(src)

    local result = exports.ghmattimysql:executeSync([[
        SELECT *
        FROM mdt_logs
        WHERE job = ? OR job IS NULL
        ORDER BY id DESC
        LIMIT 500
    ]],
    { job })

    TriggerClientEvent("caue-mdt:getAllLogs", src, result)
end)

--[[

    Threads

]]

Citizen.CreateThread(function()
    Citizen.Wait(3000)

    local _categorys = exports.ghmattimysql:executeSync([[
        SELECT *
        FROM mdt_penalcode_categorys
    ]])

    for i, v in ipairs(_categorys) do
        penalCode[v.cid] = {}
        penalCodeCategorys[v.cid] = v.category

        local _penalcode = exports.ghmattimysql:executeSync([[
            SELECT *
            FROM mdt_penalcode
            WHERE category = ?
            ORDER BY type ASC
        ]],
        { v.cid })

        for i2, v2 in ipairs(_penalcode) do
            local color = "green"
            local class = "Infração"

            if v2.type == 1 then
                color = "orange"
                class = "Contravenção"
            elseif v2.type == 2 then
                color = "red"
                class = "Crime"
            end

            table.insert(penalCode[v.cid], {
                id = v2.id,
                color = color,
                title = v2.label,
                class = class,
                months = v2.sentence,
                fine = v2.fine
            })
        end
    end
end)