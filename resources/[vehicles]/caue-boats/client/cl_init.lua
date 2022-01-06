Citizen.CreateThread(function()
    Citizen.Wait(1000)

    exports["caue-npcs"]:RegisterNPC(Config["NPC"])

    local group = { "isBoatShop" }

    local data = {
        {
            id = "boat_shop",
            label = "Boat Shop",
            icon = "ship",
            event = "caue-boats:showBoats",
            parameters = {},
        }
    }

    local options = {
        distance = { radius = 2.5 }
    }

    exports["caue-eye"]:AddPeekEntryByFlag(group, data, options)

    local images = {}
    for _, vehicle in ipairs(Config["Vehicles"]) do
        table.insert(images, vehicle.image)
    end

    TriggerEvent("caue-context:preLoadImages", images)
end)