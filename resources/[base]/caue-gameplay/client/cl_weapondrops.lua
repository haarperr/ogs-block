Citizen.CreateThread(function()
	local pedPool = GetGamePool("CPed")

    for k,v in pairs(pedPool) do
		SetPedDropsWeaponsWhenDead(v, false)

        if DecorGetInt(v, "NPC_ID") == 0 and not DecorExistOn(v, "ScriptedPed") and Config.BlacklistedPeds[GetEntityModel(v)] then
			Sync.DeleteEntity(v)
		end
	end

	Citizen.Wait(500)
end)