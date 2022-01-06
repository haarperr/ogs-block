--[[

    Events

]]

AddEventHandler("caue-boats:showBoats", function()
    local data = {}

    for _, vehicle in ipairs(Config["Vehicles"]) do
        local tax = RPC.execute("caue-financials:priceWithTax", vehicle.price, "Vehicles")

        vehicle["tax"] = tax.tax
        vehicle["price"] = tax.total

        table.insert(data, {
            title = vehicle.name,
            description = "$" .. tax.total .. " Incl. " .. tax.porcentage .. "% tax",
            image = vehicle.image,
            children = {
                { title = "Confirm Purchase", action = "caue-boats:buyBoat", params = vehicle },
            },
        })
    end

    exports["caue-context"]:showContext(data)
end)

AddEventHandler("caue-boats:buyBoat", function(params)
    if IsAnyVehicleNearPoint(Config["Spawn"]["x"], Config["Spawn"]["y"], Config["Spawn"]["z"], 3.0) then
        TriggerEvent("DoLongHudText", "Vehicle in the way", 2)
        return
    end

    TriggerServerEvent("caue-boats:buyBoat", params)
end)