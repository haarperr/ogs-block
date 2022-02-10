ESX = nil
CachedOwners = {}

if Config.FrameWork == 1 then
    TriggerEvent("esx:getSharedObject", function(esx) ESX = esx end)
end

if Config.FrameWork == 2 then
	QBCore = Config.GetQBCoreObject()
	ESX = {}

	ESX.GetPlayerFromId = function(source)
		local xPlayer = {}
		local qbPlayer = QBCore.Functions.GetPlayer(source)
		---------
		xPlayer.identifier = qbPlayer.PlayerData.citizenid
		---------
		return xPlayer
	end
end

function IsVehiclePlayer(source, licensePlate, cb)
    if Config.FrameWork == 0 then
        cb(true)
        return true
    end

    local sql = "SELECT * FROM player_vehicles WHERE plate = @spz"

    if Config.FrameWork == 1 then
        sql = "SELECT * FROM owned_vehicles WHERE plate = @spz"
    end

    MySQLAsyncfetchAll(sql, {
        ['@spz'] = licensePlate,
    }, function(result)
        if #result == 0 then
            cb(false)
        else
            cb(true)
        end
    end)
end

-- check vehicle SPZ, does it have radio ? yes -> lets open UI
-- or is vehicle stolen ? or bought -> open UI
RegisterNetEvent("caue-radiocar:openUI")
AddEventHandler("caue-radiocar:openUI", function(spz)
    local player = source
    local xPlayer

    if ESX then
        xPlayer = ESX.GetPlayerFromId(player)
    end

    if Config.OnlyCarWhoHaveRadio then
        if exports.caue-radiocar:HasCarRadio(spz) then
            TriggerClientEvent("caue-radiocar:openUI", player)
        end
        return
    end
    if Config.OnlyOwnerOfTheCar then
        if ESX then
            if not CachedOwners[spz] then
				local sql = "SELECT * FROM owned_vehicles WHERE plate = @plate AND owner = @identifier"
				if Config.FrameWork == 2 then
					sql = "SELECT * FROM player_vehicles WHERE plate = @plate AND citizenid = @identifier"
				end

                local result = MySQLSyncfetchAll(sql, { ['@plate'] = spz, ['@identifier'] = xPlayer.identifier })
                if #result ~= 0 then
                    TriggerClientEvent("caue-radiocar:openUI", player)
                end
                CachedOwners[spz] = result[1] or result
            else
                if CachedOwners[spz].plate == spz and CachedOwners[spz].owner == xPlayer.identifier then
                    TriggerClientEvent("caue-radiocar:openUI", player)
                end
            end
        else
            TriggerClientEvent("caue-radiocar:openUI", player)
        end
    else
        if ESX then
            if not CachedOwners[spz] then
				local sql = "SELECT * FROM owned_vehicles WHERE plate = @plate"
				if Config.FrameWork == 2 then
					sql = "SELECT * FROM player_vehicles WHERE plate = @plate"
				end

				local result = MySQLSyncfetchAll("SELECT * FROM owned_vehicles WHERE plate = @plate", { ['@plate'] = spz })
                if #result ~= 0 then
                    TriggerClientEvent("caue-radiocar:openUI", player)
                end
                CachedOwners[spz] = result[1] or result
            else
                if CachedOwners[spz].plate == spz then
                    TriggerClientEvent("caue-radiocar:openUI", player)
                end
            end
        else
            TriggerClientEvent("caue-radiocar:openUI", player)
        end
    end
end)