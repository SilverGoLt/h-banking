-- internal variables
local State = {
	uiOpen = false,
	inMarker = false,
}

local function openUI()
	if State.uiOpen then
		State.uiOpen = false
		
		SetNuiFocus(false, false)
		SendNUIMessage({
			show = false
		})
	else
		State.uiOpen = true
		SetNuiFocus(true, true)

		ESX.TriggerServerCallback('h-banking:getAccounts', function(wallet, bank)
			SendNUIMessage({
				show = true,
				wallet = wallet.wallet,
				bank = wallet.bank
			})
		end)
	end
end

function NearbyATM()
	local coords = GetEntityCoords(PlayerPedId())

	for i = 1, #Config.ATMLocations do
		local atmCoords = vector3(Config.ATMLocations[i].x, Config.ATMLocations[i].y, Config.ATMLocations[i].z)
		if #(coords - atmCoords) < 1.0 then
			return true
		end
	end

	return false
end

RegisterCommand('openatm', function()
    local playerPed = PlayerPedId()

    if not State.uiOpen and IsPedOnFoot(playerPed) and NearbyATM() then
		openUI()
    end
end, false)

RegisterKeyMapping('openatm', 'Open ATM', 'keyboard', 'e')

-- UI Stuff
RegisterNUICallback('escape', function(data, cb)
	openUI()
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

-- -- Activate menu when player is inside marker
if Config.Prompt then
	local PromptSleep = 500

	CreateThread(function()
		while true do
			if NearbyATM() then
				PromptSleep = 5
				ESX.ShowHelpNotification("Press ~b~E~b~ to open ATM")
			else
				PromptSleep = 500
			end

			Wait(PromptSleep)
		end
	end)
end