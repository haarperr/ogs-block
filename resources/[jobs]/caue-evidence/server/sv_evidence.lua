local Evidences = {}

RegisterNetEvent("evidence:pooled")
AddEventHandler("evidence:pooled", function(drops)
    for k, v in pairs(drops) do
        Evidences[k] = v
    end

    TriggerClientEvent("evidence:pooled", -1, drops)
end)

RegisterNetEvent("evidence:removal")
AddEventHandler("evidence:removal", function(eid)
    Evidences[eid] = nil

    TriggerClientEvent("evidence:remove:done", -1, eid)
end)

RegisterNetEvent("evidence:clear")
AddEventHandler("evidence:clear", function(eids)
    for i = 1, #eids do
        Evidences[eids[i]] = nil
    end

    TriggerClientEvent("evidence:clear:done", -1, eids)
end)