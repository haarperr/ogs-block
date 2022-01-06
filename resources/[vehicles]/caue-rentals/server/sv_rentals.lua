RegisterNetEvent("caue-rentals:rentalVehicle")
AddEventHandler("caue-rentals:rentalVehicle", function(params)
    local src = source

    local cid = exports["caue-base"]:getChar(src, "id")
    if not cid then return end

    local accountId = exports["caue-base"]:getChar(src, "bankid")
    local bank = exports["caue-financials"]:getBalance(accountId)

    if params["price"] > bank then
        TriggerClientEvent("caue-phone:notification", src, "fas fa-exclamation-circle", "Error", "You dont $" .. params["price"] .. " in your bank account", 5000)
        return
    end

    local comment = "Rented " .. params["name"]
    local success, message = exports["caue-financials"]:transaction(accountId, 8, params["price"], comment, cid, 5)
    if not success then
        TriggerClientEvent("caue-phone:notification", src, "fas fa-exclamation-circle", "Error", message, 5000)
        return
    end

    exports["caue-financials"]:addTax("Vehicles", params.tax)

    TriggerClientEvent("caue-vehicles:spawnVehicle", src, params["model"], Config["Spawn"], false, false, 100, false, false, false, false, false, true)
end)