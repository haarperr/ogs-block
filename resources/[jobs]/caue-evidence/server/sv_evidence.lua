local DroppedEvidences = {}

RPC.register("caue-evidence:fetchEvidence", function(src)
    return true, DroppedEvidences
end)

RPC.register("caue-evidence:addEvidence", function(src, pDropped)
    for k, v in pairs(pDropped) do
        DroppedEvidences[k] = v
    end

    return true
end)

RPC.register("caue-evidence:clearEvidence", function(src, pCoords, pEvidence)
    for i, v in ipairs(pEvidence) do
        if DroppedEvidences[v] then
            DroppedEvidences[v] = nil
        end
    end

    local players = GetPlayers()
    for i, v in ipairs(players) do
        local coords = GetEntityCoords(GetPlayerPed(v))

        if #(pCoords - coords) < 50.0 then
            TriggerClientEvent("caue-evidence:clearCache", v)
        end
    end

    return true
end)