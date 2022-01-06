local EmergencyPlayers = {}

RegisterNetEvent("e-blips:updateBlips")
AddEventHandler("e-blips:updateBlips", function(pJob)
    local src = source

    if exports["caue-jobs"]:getJob(pJob, "is_emergency") then
        local callSign = exports["caue-jobs"]:getCallsign(src, pJob)

        if EmergencyPlayers[src] then
            for k, v in pairs(EmergencyPlayers) do
                if k == src then
                    TriggerClientEvent("e-blips:deleteHandlers", src)
                else
                    TriggerClientEvent("e-blips:removeHandler", k, src)
                end
            end
        end

        EmergencyPlayers[src] = {
            netId = src,
            job = pJob,
            callsign = callSign or "CALLSIGN NOT DEFINED"
        }

        for k, v in pairs(EmergencyPlayers) do
            if k == src then
                TriggerClientEvent("e-blips:setHandlers", src, EmergencyPlayers)
            else
                TriggerClientEvent("e-blips:addHandler", k, EmergencyPlayers[src])
            end
        end
    elseif EmergencyPlayers[src] then
        for k, v in pairs(EmergencyPlayers) do
            if k == src then
                TriggerClientEvent("e-blips:deleteHandlers", src)
            else
                TriggerClientEvent("e-blips:removeHandler", k, src)
            end
        end

        EmergencyPlayers[src] = nil
    end
end)