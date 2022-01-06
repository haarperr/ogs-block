AddEventHandler("onResourceStart", function(resName) -- Initialises the script, sets up voice related convars
	if GetCurrentResourceName() ~= resName then
		return
	end

	-- Set voice related convars
	SetConvarReplicated("voice_useNativeAudio", true)
	-- SetConvarReplicated("voice_use2dAudio", false)
	SetConvarReplicated("voice_use3dAudio", true)
	SetConvarReplicated("voice_useSendingRangeOnly", true)

	Debug("[caue:voice] Initialised Script")
end)


RegisterNetEvent("caue:voice:connection:state")
AddEventHandler("caue:voice:connection:state", function(state)
	TriggerClientEvent("caue:voice:connection:state", -1, source, state)
end)


RegisterNetEvent("caue:voice:transmission:state")
AddEventHandler("caue:voice:transmission:state", function(group, context, transmitting, isMult)
	local _source = source

	if type(group) == "table" then
		for k, v in pairs(group) do
			TriggerClientEvent("caue:voice:transmission:state", v, _source, context, transmitting)
		end
	else
		TriggerClientEvent("caue:voice:transmission:state", group, _source, context, transmitting)
	end
end)


function Debug(msg, ...)
    if not Config.enableDebug then return end

    local params = {}

    for _, param in ipairs({ ... }) do
        if type(param) == "table" then
            param = json.encode(param)
        end

        table.insert(params, param)
    end

    print((msg):format(table.unpack(params)))
end

function DumpTable(table, nb)
	if nb == nil then
		nb = 0
	end

	if type(table) == "table" then
		local s = ""
		for i = 1, nb + 1, 1 do
			s = s .. "    "
		end

		s = "{\n"
		for k,v in pairs(table) do
			if type(k) ~= "number" then k = "'"..k.."'" end
			for i = 1, nb, 1 do
				s = s .. "    "
			end
			s = s .. "["..k.."] = " .. DumpTable(v, nb + 1) .. ",\n"
		end

		for i = 1, nb, 1 do
			s = s .. "    "
		end

		return s .. "}"
	else
		return tostring(table)
	end
end