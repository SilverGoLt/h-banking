-- internal variables
local hasAlreadyEnteredMarker, isInATMMarker, menuIsShowed = false, false, false
ESX = nil

Citizen.CreateThread(function()
	while ESX == nil do
		TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
		Citizen.Wait(0)
	end
end)

RegisterNetEvent('esx_atm:closeATM')
AddEventHandler('esx_atm:closeATM', function()
	SetNuiFocus(false)
	SendNUIMessage({
		show = false;
	})
	menuIsShowed = false
end)

RegisterNUICallback('escape', function(data, cb)
	TriggerEvent('esx_atm:closeATM')
end)

RegisterNUICallback('deposit', function(data, cb)
	TriggerServerEvent('esx_atm:deposit', data.amount)
	ESX.TriggerServerCallback('h-banking:getAccounts', function(wallet, bank)
            SendNUIMessage({
				show = true,
				wallet = wallet.wallet,
				bank = wallet.bank
            })
    end)
end)

RegisterNUICallback('transfer', function(data)
	TriggerServerEvent('h-bank:transfer', data.bplayer, data.amount)
	print(json.encode(data))
end)


RegisterNUICallback('withdraw', function(data, cb)
	TriggerServerEvent('esx_atm:withdraw', data.amount)
	ESX.TriggerServerCallback('h-banking:getAccounts', function(wallet, bank)
		SendNUIMessage({
			show = true,
			wallet = wallet.wallet,
			bank = wallet.bank
		})
end)
end)

-- Create blips
Citizen.CreateThread(function()
	if not Config.EnableBlips then return end

	for _, ATMLocation in pairs(Config.ATMLocations) do
		ATMLocation.blip = AddBlipForCoord(ATMLocation.x, ATMLocation.y, ATMLocation.z - Config.ZDiff)
		SetBlipSprite(ATMLocation.blip, Config.BlipSprite)
		SetBlipDisplay(ATMLocation.blip, 4)
		SetBlipScale(ATMLocation.blip, 0.9)
		SetBlipColour(ATMLocation.blip, 2)
		SetBlipAsShortRange(ATMLocation.blip, true)
		BeginTextCommandSetBlipName("STRING")
		AddTextComponentString("ATM")
		EndTextCommandSetBlipName(ATMLocation.blip)
	end
end)

-- Activate menu when player is inside marker
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(10)
		local coords = GetEntityCoords(PlayerPedId())
		local canSleep = true
		isInATMMarker = false

		for k,v in pairs(Config.ATMLocations) do
			if GetDistanceBetweenCoords(coords, v.x, v.y, v.z, true) < 1.0 then
				isInATMMarker, canSleep = true, false
				break
			end
		end

		if isInATMMarker and not hasAlreadyEnteredMarker then
			hasAlreadyEnteredMarker = true
			canSleep = false
		end
	
		if not isInATMMarker and hasAlreadyEnteredMarker then
			hasAlreadyEnteredMarker = false
			SetNuiFocus(false)
			menuIsShowed = false
			canSleep = false
		end

		if canSleep then
			Citizen.Wait(500)
		end
	end
end)

-- Menu interactions
Citizen.CreateThread(function()
	while true do
		Citizen.Wait(10)

		if isInATMMarker and not menuIsShowed then

			ESX.ShowHelpNotification("Press ~b~E~b~ to open ATM"
			)

			if IsControlJustReleased(0, 38) and IsPedOnFoot(PlayerPedId()) then
				menuIsShowed = true
				ESX.TriggerServerCallback('h-banking:getAccounts', function(wallet, bank)
					SendNUIMessage({
						show = true,
						wallet = wallet.wallet,
						bank = wallet.bank
					})
			end)
				SetNuiFocus(true, true)
			end

		else
			Citizen.Wait(500)
		end
	end
end)

-- close the menu when script is stopping to avoid being stuck in NUI focus
AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		if menuIsShowed then
			TriggerEvent('esx_atm:closeATM')
		end
	end
end)
