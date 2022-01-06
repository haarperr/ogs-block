--[[

    Functions

]]

local function loadYellowPages()
    local yellowPages = RPC.execute("caue-phone:getYellowPages")

    SendNUIMessage({
        openSection = "notificationsYP",
        list = yellowPages,
    })
end

--[[

    NUIs

]]

RegisterNUICallback("notificationsYP", function()
    loadYellowPages()
end)

RegisterNUICallback("newPostSubmit", function(data, cb)
    local message = data["advert"]

    if not message then return end

    local update = RPC.execute("caue-phone:addYellowPages", message)
    if update then
        loadYellowPages()
    end
end)

RegisterNUICallback("deleteYP", function()
    local update = RPC.execute("caue-phone:removeYellowPages")
    if update then
        loadYellowPages()
    end
end)