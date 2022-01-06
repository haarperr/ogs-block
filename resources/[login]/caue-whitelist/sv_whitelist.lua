function IsBanned(hex)
	local ban = exports.ghmattimysql:executeSync([[
		SELECT *
		FROM users_bans
		WHERE hex = ?
	]],
	{ hex })[1]

	if not ban then return false end

	return true, ban["time"], ban["reason"]
end

Queue.OnReady(function()

Queue.OnJoin(function(source, allow)
	local ids = GetIds(source)

	if not ids then
		allow("\xE2\x9D\x97[Fila] Erro: Não foi possível encontrar nenhum dos seus IDs, tente reiniciar o FiveM.")
		return
	end

	if not ids["hex"] then
		allow("\xE2\x9D\x97[Fila] Erro: Não foi possível encontrar seu HEX, tente reiniciar o FiveM.")
		return
	end

	exports.ghmattimysql:scalar([[
		SELECT priority
		FROM whitelist
		WHERE hex = ?
	]],
	{ ids["hex"] },
	function(whitelist)
		if whitelist then
			local banned, ban_time, ban_reason = IsBanned(ids["hex"])

			if banned then
				local time = os.time()

				if ban_time == 0 then
					allow("Você está banido permanentemente | Motivo: "..user.banreason)
					return
				elseif ban_time > time then
					allow("Você está banido | Motivo: " .. ban_reason .. " | Termina: " .. os.date("%d/%m/%Y - %X", ban_time))
					return
				elseif ban_time < time then
					exports.ghmattimysql:execute([[
						DELETE FROM users_bans
						WHERE hex = ?
					]],
					{ ids["hex"] })
				end
			end

			if whitelist > 0 and (not Queue.Exports:IsPriority({ids["hex"]})) then
				Queue.AddPriority(ids["hex"], whitelist)
			end

			Wait(1500)

			allow()
		else
			allow("\xE2\x9D\x97[Fila] Você deve estar na whitelist para entrar neste servidor")
		end
	end)
end)

end)
