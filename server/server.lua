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
