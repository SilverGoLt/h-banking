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
	ESX.TriggerServerCallback('h-banking:getAccounts', function(wallet, bank)
            SendNUIMessage({
				show = true,
				wallet = wallet.wallet,
				bank = wallet.bank
            })
    end)
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
if Config.Prompt then
	Citizen.CreateThread(function()
		while true do
			Citizen.Wait(50)
			local letSleep = true

			if IsNearbyATM() then
				letSleep = false
				ESX.ShowHelpNotification("Press ~b~E~b~ to open ATM")
			end

			if letSleep then 
				Citizen.Wait(500)
			end
		end
	end)
end

RegisterCommand('openatm', function()
    local playerPed = PlayerPedId()

    if not menuIsShowed and IsPedOnFoot(playerPed) and IsNearbyATM() then
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
end, false)
RegisterKeyMapping('openatm', 'Open ATM', 'keyboard', 'e')

function IsNearbyATM()
	local coords = GetEntityCoords(PlayerPedId())

	for i = 1, #Config.ATMLocations do
		local atmCoords = vector3(Config.ATMLocations[i].x, Config.ATMLocations[i].y, Config.ATMLocations[i].z)
		if #(coords - atmCoords) < 1.0 then
			return true
		end
	end
	return false
end

-- close the menu when script is stopping to avoid being stuck in NUI focus
AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		if menuIsShowed then
			TriggerEvent('esx_atm:closeATM')
		end
	end
end)
