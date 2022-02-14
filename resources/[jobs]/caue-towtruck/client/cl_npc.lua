--[[

	Variables

]]

local lastCall = 0

local towTruck = 0
local towTruckDriver = 0
local towTruckBlip = 0
local enroute = false

local spawnRadius = 500
local drivingStyle = 786603

--[[

	Functions

]]

function DeleteTowTruck()
	SetEntityAsMissionEntity(towTruck, false, false)
	DeleteEntity(towTruck)
	SetEntityAsMissionEntity(towTruckDriver, false, false)
	DeleteEntity(towTruckDriver)
	RemoveBlip(towTruckBlip)
end

function SpawnTowTruck(x, y, z, truckhash, driverhash)
	local found, spawnPos, spawnHeading = GetClosestVehicleNodeWithHeading(x + math.random(-spawnRadius, spawnRadius), y + math.random(-spawnRadius, spawnRadius), z, 0, 3, 0)

	if found and HasModelLoaded(truckhash) and HasModelLoaded(truckhash) then
		towTruck = CreateVehicle(truckhash, spawnPos, spawnHeading, true, false)
		ClearAreaOfVehicles(GetEntityCoords(towTruck), 5000, false, false, false, false, false);
		SetVehicleOnGroundProperly(towTruck)
		SetVehicleColours(towTruck, 88, 88)

		towTruckDriver = CreatePedInsideVehicle(towTruck, 26, driverhash, -1, true, false)

		towTruckBlip = AddBlipForEntity(towTruck)
		SetBlipFlashes(towTruckBlip, true)
		SetBlipColour(towTruckBlip, 29)
	end
end

function GoToTarget(x, y, z, truck, driver, truckhash, car)
	TaskVehicleDriveToCoord(driver, truck, x, y, z, 17.0, 0, truckhash, drivingStyle, 1, true)

	exports["caue-phone"]:phoneNotification("fas fa-truck-pickup", "Reboque", "Um caminhão de reboque foi enviado.", 10000)

	enroute = true

	while enroute == true do
		Citizen.Wait(500)

		local truckCoords = GetEntityCoords(truck)
		local distanceToTarget = GetDistanceBetweenCoords(GetEntityCoords(car), truckCoords.x, truckCoords.y, truckCoords.z, false)

		if distanceToTarget < 15 then
			TaskVehicleTempAction(driver, truck, 27, -1)
			SetVehicleDoorOpen(truck, 2, false, false)
			SetVehicleDoorOpen(truck, 3, false, false)
		elseif distanceToTarget < 20 then
			Citizen.Wait(5000)
			PickupTarget(truck, driver, car)
		end
	end
end

function PickupTarget(truck, driver, car)
	enroute = false

	AttachEntityToEntity(car, truck, 20, -0.5, -5.0, 1.0, 0.0, 0.0, 0.0, false, false, false, false, 20, true)

	exports["caue-phone"]:phoneNotification("fas fa-truck-pickup", "Reboque", "O veiculo foi rebocado!", 10000)

	Citizen.Wait(5000)

	SetVehicleDoorsShut(truck, false)
	StartVehicleHorn(truck, 100, 0, false)
	TaskVehicleDriveWander(driver, truck, 17.0, drivingStyle)

	Citizen.Wait(60000)

	local vid = exports["caue-vehicles"]:GetVehicleIdentifier(car)
    if vid then
		RPC.execute("caue-vehicles:updateVehicle", vid, "garage", "state", "In")
	end

	Sync.DeleteVehicle(car)
	Sync.DeleteVehicle(truck)
    Sync.DeleteEntity(driver)

	RemoveBlip(towTruckBlip)
	towTruck = nil
	towTruckDriver = nil
	targetVeh = nil
end

--[[

	Events

]]

AddEventHandler("caue-towtruck:callNPC", function(pParams, pVehicle)
	if lastCall >= GetCloudTimeAsInt() or DoesEntityExist(towTruck) then
		exports["caue-phone"]:phoneNotification("fas fa-exclamation-circle", "Error", "Você já chamou um reboque recentemente.", 5000)
		return
	end

	lastCall = GetCloudTimeAsInt() + 90

	TriggerEvent("animation:PlayAnimation", "phone")
    local finished = exports["caue-taskbar"]:taskBar(math.random(2500, 4000), "Chamando o reboque")
    TriggerEvent("animation:PlayAnimation", "cancel")

	local player = PlayerPedId()
	local playerPos = GetEntityCoords(player)

	local driverhash = GetHashKey("S_M_M_TRUCKER_01")
	RequestModel(driverhash)
	local truckhash = GetHashKey("flatbed")
	RequestModel(truckhash)

	while not HasModelLoaded(driverhash) and RequestModel(driverhash) or not HasModelLoaded(truckhash) and RequestModel(truckhash) do
		RequestModel(driverhash)
		RequestModel(truckhash)
		Citizen.Wait(0)
	end

	if DoesEntityExist(pVehicle) then
		if DoesEntityExist(towTruck) then
			DeleteTowTruck(towTruck, towTruckDriver)
			SpawnTowTruck(playerPos.x, playerPos.y, playerPos.x, truckhash, driverhash)
		else
			SpawnTowTruck(playerPos.x, playerPos.y, playerPos.x, truckhash, driverhash)
		end

		local vehicleCoords = GetEntityCoords(pVehicle)

		GoToTarget(vehicleCoords.x, vehicleCoords.y, vehicleCoords.z, towTruck, towTruckDriver, truckhash, pVehicle)
	end
end)