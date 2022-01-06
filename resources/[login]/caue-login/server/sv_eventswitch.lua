RegisterNetEvent("caue-login:switchCharacter")
AddEventHandler("caue-login:switchCharacter", function()
    local src = source

    local cid = exports["caue-base"]:getChar(src, "id")

    TriggerClientEvent("caue-base:resetVars", src)
    TriggerClientEvent("caue-police:resetCuffs", src)
    TriggerClientEvent("caue-police:resetEscort", src)
    TriggerEvent("caue-apartments:deSpawn", cid)

    exports["caue-base"]:setUser(src, "char", nil)
    TriggerClientEvent("caue-base:setVar", src, "char", nil)
end)