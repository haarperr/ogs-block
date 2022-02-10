RegisterNetEvent("police:remmaskGranted")
AddEventHandler("police:remmaskGranted", function(pTarget)
    TriggerClientEvent("police:remmaskAccepted", pTarget)
end)

RegisterNetEvent("police:targetCheckInventory")
AddEventHandler("police:targetCheckInventory", function(pTarget, pFrisk)
    local src = source

    local cid = exports["caue-base"]:getChar(pTarget, "id")
    if not cid then return end

    if pFrisk then
        local inv = exports["caue-inventory"]:getInventory("ply-" .. cid)

        local hasWeapons = false

        for i, v in ipairs(inv) do
            if tonumber(v.item_id) then
                hasWeapons = true
                break
            end
        end

        if hasWeapons then
            TriggerClientEvent("DoLongHudText", src, "Arma encontrada")
        else
            TriggerClientEvent("DoLongHudText", src, "Arma não encontrada")
        end
    else
        TriggerClientEvent("DoLongHudText", pTarget, "Você esta sendo revistado")
        TriggerClientEvent("server-inventory-open", src, "1", ("ply-" .. cid))
    end
end)

RegisterNetEvent("police:rob")
AddEventHandler("police:rob", function(pTarget)
    local src = source

    local cash = exports["caue-financials"]:getCash(pTarget)

    if cash > 0 then
        if exports["caue-financials"]:updateCash(pTarget, "-", cash) then
            exports["caue-financials"]:updateCash(src, "+", cash)
        end
    end
end)

RegisterNetEvent("police:gsr")
AddEventHandler("police:gsr", function(pTarget)
	local src = source

    local shotRecently = RPC.execute(pTarget, "police:gsr")

    if shotRecently then
        TriggerClientEvent("DoLongHudText", src, "Encontramos residuo de polvora")
    else
        TriggerClientEvent("DoLongHudText", src, "Não encontramos nenhum residuo de polvora")
    end
end)

RegisterNetEvent("police:fingerprint")
AddEventHandler("police:fingerprint", function(pTarget)
	local src = source

    local cid = exports["caue-base"]:getChar(pTarget, "id")

    TriggerClientEvent("DoLongHudText", src, "DNA-" .. cid)
end)

RegisterNetEvent("police:checkBank")
AddEventHandler("police:checkBank", function(pTarget)
	local src = source
    local cid = exports["caue-base"]:getChar(pTarget, "id")
    local accountId = exports["caue-base"]:getChar(pTarget, "bankid")
    local bank = exports["caue-financials"]:getBalance(accountId)
    TriggerClientEvent("DoLongHudText", src, "Tem $ " .. bank .. " na conta " .. accountId)
end)

local jailTimer = {}

RegisterNetEvent("caue-police:jail")
AddEventHandler("caue-police:jail", function(_src)
	local src = source
    if _src then src = _src end

    local cid = exports["caue-base"]:getChar(src, "id")

    jailTimer[cid] = true

    while true do
        Citizen.Wait(60000)

        local jail = exports["caue-base"]:getChar(src, "jail")

        if not jail or jailTimer[cid] == nil then return end

        local _jail = jail - 1

        exports["caue-base"]:setChar(src, "jail", _jail)
        TriggerClientEvent("caue-base:setChar", src, "jail", _jail)

        exports.ghmattimysql:execute([[
            UPDATE characters
            SET jail = ?
            WHERE id = ?
        ]],
        { _jail, cid })

        if _jail <= 0 then
            local ped = GetPlayerPed(src)
            SetEntityCoords(ped, 1847.14, 2586.28, 45.68)
            jailTimer[cid] = nil
            return
        end
    end
end)

AddEventHandler("caue-apartments:deSpawn", function(cid)
    if jailTimer[cid] then
        jailTimer[cid] = nil
    end
end)