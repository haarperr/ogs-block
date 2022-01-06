RegisterNetEvent("facewear:adjust")
AddEventHandler("facewear:adjust", function(pTarget, pWearType, pShouldRemove, pIsPolice)
  	TriggerClientEvent("facewear:adjust", pTarget, pWearType, pShouldRemove, pIsPolice)
end)