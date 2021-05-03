ESX = nil
TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

RegisterServerEvent('esx_atm:deposit')
AddEventHandler('esx_atm:deposit', function(amount)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	amount = tonumber(amount)

	if not tonumber(amount) then return end
	amount = ESX.Math.Round(amount)

	if amount == nil or amount <= 0 or amount > xPlayer.getMoney() then
		xPlayer.showNotification("Invalid Amount")
	else
		xPlayer.removeMoney(amount)
		xPlayer.addAccountMoney('bank', amount)
	end
end)

RegisterServerEvent('esx_atm:withdraw')
AddEventHandler('esx_atm:withdraw', function(amount)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	amount = tonumber(amount)
	local accountMoney = xPlayer.getAccount('bank').money

	if not tonumber(amount) then return end
	amount = ESX.Math.Round(amount)

	if amount == nil or amount <= 0 or amount > accountMoney then
		xPlayer.showNotification("Invalid Amount")
	else
		xPlayer.removeAccountMoney('bank', amount)
		xPlayer.addMoney(amount)
	end
end)

ESX.RegisterServerCallback('h-banking:getAccounts', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    cb({
		wallet = xPlayer.getMoney(),
		bank = xPlayer.getAccount('bank').money
	})
end)

RegisterServerEvent('h-bank:transfer')
AddEventHandler('h-bank:transfer', function(bplayer, amount)
	if tonumber(bplayer) < 1 or bplayer == nil then
		TriggerClientEvent('esx:showAdvancedNotification', source, 'H-Banking', 'Transfer Money', 'Uh oh ID not found?', 'CHAR_BANK_MAZE', 9)
		return
	else
		local aPlayer = ESX.GetPlayerFromId(source)
		local bPlayer = ESX.GetPlayerFromId(bplayer)
		local balance = 0
		print(abalance)
		abalance = aPlayer.getAccount('bank').money
		bbalance = bPlayer.getAccount('bank').money
			
		if abalance > amount then
				return
		end
		
		print(abalance)
		if tonumber(source) == tonumber(bplayer) then
			TriggerClientEvent('esx:showAdvancedNotification', source, 'H-Banking', 'Transfer Money', 'You tried to transfer the money to yourself?', 'CHAR_BANK_MAZE', 9)
		else
			aPlayer.removeAccountMoney('bank', amount)
			bPlayer.addAccountMoney('bank', amount)
			TriggerClientEvent('esx:showAdvancedNotification', source, 'H-Banking', 'Transfer Money', 'Successfully transfered $' ..amount, 'CHAR_BANK_MAZE', 9)
			TriggerClientEvent('esx:showAdvancedNotification', bplayer, 'H-Banking', 'Transfer Money', 'Successfully received $' ..amount .. 'From ' ..aPlayer.getName(), 'CHAR_BANK_MAZE', 9)
		end
	end
end)

