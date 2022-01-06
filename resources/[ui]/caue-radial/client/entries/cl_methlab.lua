local GeneralEntries, SubMenu = MenuEntries['general'], {}

local canStartCornering = false
local showSellMethOption = false
local hasCarTarget = false

AddEventHandler("np:target:changed", function(pEntity, pEntityType)
  if not pEntity or pEntityType ~= 2 then
    hasCarTarget = false
    return
  end
  hasCarTarget = true
end)

AddEventHandler("np-meth:showSellDrugsMenuItem", function(type, b)
    if type == "cancorner" then
        canStartCornering = b
    end
end)

AddEventHandler("np-polyzone:enter", function(name)
    if name == "meth_corner" then
        showSellMethOption = true
    end
end)
AddEventHandler("np-polyzone:exit", function(name)
    if name == "meth_corner" then
        showSellMethOption = false
    end
end)

Citizen.CreateThread(function()
    GeneralEntries[#GeneralEntries+1] = {
        data = {
            id = "sellmeth",
            icon = "#walking",
            title = "Sell",
            event = "np-meth:cornerSellProduct",
        },
        isEnabled = function()
            return not exports["caue-base"]:getVar("dead") and showSellMethOption and not canStartCornering and hasCarTarget
        end,
    }
    GeneralEntries[#GeneralEntries+1] = {
        data = {
            id = "sellmethfromcorner",
            icon = "#walking",
            title = "Corner",
            event = "np-meth:cornerStartSelling",
        },
        isEnabled = function()
            return not exports["caue-base"]:getVar("dead") and canStartCornering
        end,
    }
    -- for index, data in ipairs(Options) do
    --     SubMenu[index] = data.data.id
    --     MenuItems[data.data.id] = {data = data.data, isEnabled = data.isEnabled}
    -- end
    -- GeneralEntries[#GeneralEntries+1] = {
    --     data = {
    --         id = "methlab",
    --         icon = "#walking",
    --         title = "Lab",
    --     },
    --     subMenus = SubMenu,
    --     isEnabled = function()
    --         return not exports["caue-base"]:getVar("dead") and inLab
    --     end,
    -- }
end)

-- local function checkObject(obj)
--     return function()
--         return not exports["caue-base"]:getVar("dead") and inLab and targetObject == obj
--     end
-- end

-- local Options = {
--     {
--         data = {
--             id = 'np-meth:startCooking',
--             title = "Start Cooking",
--             icon = "#police-check",
--             event = "np-meth:startCooking",
--         },
--         isEnabled = checkObject("computer"),
--     },
--     {
--         data = {
--             id = 'np-meth:adjustFridgeTemp',
--             title = "Adjust Temperature",
--             icon = "#police-check",
--             event = "np-meth:adjustFridgeTemp",
--         },
--         isEnabled = checkObject("fridge"),
--     },
--     {
--         data = {
--             id = 'np-meth:adjustSteamLevel',
--             title = "Adjust Levels",
--             icon = "#police-check",
--             event = "np-meth:adjustSteamLevel",
--         },
--         isEnabled = checkObject("distil"),
--     },
--     {
--         data = {
--             id = 'np-meth:adjustDistilSettings',
--             title = "Adjust Settings",
--             icon = "#police-check",
--             event = "np-meth:adjustDistilSettings",
--         },
--         isEnabled = checkObject("distil"),
--     },
--     {
--         data = {
--             id = 'np-meth:adjustMixerTemp',
--             title = "Adjust Temperature",
--             icon = "#police-check",
--             event = "np-meth:adjustMixerTemp",
--         },
--         isEnabled = checkObject("mixer_temperature"),
--     },
--     {
--         data = {
--             id = 'np-meth:addIngredient',
--             title = "Add Ingredient",
--             icon = "#police-check",
--             event = "np-meth:addIngredient",
--         },
--         isEnabled = checkObject("mixer_drop"),
--     },
--     {
--         data = {
--             id = 'np-meth:adjustMixerSettings',
--             title = "Adjust Settings",
--             icon = "#police-check",
--             event = "np-meth:adjustMixerSettings",
--         },
--         isEnabled = checkObject("mixer_settings"),
--     },
--     {
--         data = {
--             id = 'np-meth:pickupIngredient',
--             title = "Pickup",
--             icon = "#police-check",
--             event = "np-meth:pickupIngredient",
--         },
--         isEnabled = checkObject("ingredient"),
--     },
-- }


