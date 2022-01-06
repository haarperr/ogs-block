--[[

    Variables

]]

local listening = false

local cellcoords = {
    vector3(1763.75, 2499.44, 50.43),
    vector3(1761.18, 2497.56, 50.43),
    vector3(1758.35, 2495.69, 50.43),
    vector3(1755.23, 2494.20, 50.43),
    vector3(1752.35, 2492.39, 50.43),
    vector3(1749.21, 2490.48, 50.43),
    vector3(1745.86, 2488.94, 50.43),
    vector3(1743.28, 2486.98, 50.43),
    vector3(1743.20, 2486.85, 45.82),
    vector3(1745.87, 2489.08, 45.82),
    vector3(1748.99, 2490.77, 45.82),
    vector3(1752.14, 2492.47, 45.82),
    vector3(1755.08, 2494.00, 45.82),
    vector3(1761.12, 2497.27, 45.83),
    vector3(1763.93, 2499.34, 45.83),
    vector3(1772.74, 2482.72, 50.43),
    vector3(1769.67, 2480.90, 50.43),
    vector3(1766.94, 2479.04, 50.43),
    vector3(1763.79, 2477.64, 50.42),
    vector3(1760.55, 2476.16, 50.42),
    vector3(1757.82, 2473.99, 50.42),
    vector3(1754.61, 2472.72, 50.42),
    vector3(1751.35, 2470.67, 50.42),
    vector3(1772.55, 2483.08, 45.82),
    vector3(1769.41, 2481.15, 45.82),
    vector3(1766.78, 2478.99, 45.82),
    vector3(1763.71, 2477.66, 45.82),
    vector3(1760.70, 2475.73, 45.82),
    vector3(1757.74, 2473.94, 45.82),
    vector3(1754.95, 2471.86, 45.82),
    vector3(1751.72, 2470.46, 45.82),
}

local Shops = {
    -- Smelter
    {
        text = "[E] Smelter",
        action = function()
            TriggerEvent("server-inventory-open", "17", "Craft");
        end,

        center = vector3(1109.65, -2007.94, 31.05),
        radius = 1.0,

        isEnabled = function()
            return true
        end,
    },

    {
        text = "[E] Craft",
        action = function()
            TriggerEvent("server-inventory-open", "9", "Craft");
        end,

        center = vector3(105.2, 3600.14, 40.73),
        radius = 1.0,

        isEnabled = function()
            return true
        end,
    },
    {
        text = "[E] Craft",
        action = function()
            TriggerEvent("server-inventory-open", "31", "Craft");
        end,

        center = vector3(884.69, -3199.77, -98.19),
        radius = 1.0,

        isEnabled = function()
            return true
        end,
    },
    {
        text = "[E] Look at food",
        action = function()
            TriggerEvent("server-inventory-open", "22", "Shop");
        end,

        center = vector3(1783.32, 2557.62, 45.68),
        radius = 1.0,

        isEnabled = function()
            return true
        end,
    },
    {
        text = "[E] what dis?",
        action = function()
            local finished = exports["caue-taskbar"]:taskBar(60000, "Searching...")
            if finished == 100 then
                TriggerEvent("server-inventory-open", "25", "Shop")
            end
        end,

        center = cellcoords[math.random(#cellcoords)],
        radius = 1.0,

        isEnabled = function()
            return true
        end,
    },
    {
        text = "[E] what dis?",
        action = function()
            local finished = exports["caue-taskbar"]:taskBar(60000, "Searching...")
            if finished == 100 then
                TriggerEvent("server-inventory-open", "26", "Shop")
            end
        end,

        center = vector3(1663.36, 2512.99, 46.87),
        radius = 0.7,

        isEnabled = function()
            return true
        end,
    },
    {
        text = "[E] what dis?",
        action = function()
            local finished = exports["caue-taskbar"]:taskBar(60000, "Making a god slushy...")
            if finished == 100 then
                TriggerEvent("server-inventory-open", "27", "Shop")
            end
        end,

        center = vector3(1779.01, 2557.62, 45.68),
        radius = 1.0,

        isEnabled = function()
            return true
        end,
    },
    {
        text = "[E] what dis?",
        action = function()
            local finished = exports["caue-taskbar"]:taskBar(60000, "Searching...")
            if finished == 100 then
                TriggerEvent("server-inventory-open", "23", "Craft")
            end
        end,

        center = vector3(1777.58, 2565.15, 45.68),
        radius = 0.7,

        isEnabled = function()
            return true
        end,
    },
}

--[[

    Functions

]]

local function listenForKeypress(shopId)
    listening = true

    Citizen.CreateThread(function()
        while listening do
            if IsControlJustReleased(0, 38) then
                listening = false
                exports["caue-interaction"]:hideInteraction()

                Shops[shopId].action()
            end

            Citizen.Wait(1)
        end
    end)
end

--[[

    Events

]]

AddEventHandler("caue-polyzone:enter", function(zone, data)
    if zone ~= "caue-inventory:shops" then return end

    local shopId = data.shopId

    if Shops[shopId].isEnabled() then
        exports["caue-interaction"]:showInteraction(Shops[shopId].text)
	    listenForKeypress(shopId)
    end
end)

AddEventHandler("caue-polyzone:exit", function(zone, data)
    if zone ~= "caue-inventory:shops" then return end

	exports["caue-interaction"]:hideInteraction()
    exports["caue-taskbar"]:taskCancel();
	listening = false
end)


--[[

    Threads

]]

Citizen.CreateThread(function()
	for shopId, shop in ipairs(Shops) do
        local options = {
            useZ = true,
            data = {
                shopId = shopId
            }
        }

        exports["caue-polyzone"]:AddCircleZone("caue-inventory:shops", shop.center, shop.radius, options)
    end
end)