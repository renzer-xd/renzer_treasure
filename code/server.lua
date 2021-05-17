
ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


ESX.RegisterUsableItem(Config.itemuse, function(source) --แก้ตรงpickaxe เป็นไอเท็มของคุณ
	TriggerClientEvent('renzer_treasure:pickaxe', source)
	TriggerClientEvent('esx_inventoryhud:cl', source)
end)

RegisterServerEvent('renzer_treasure:pickedUp')
AddEventHandler('renzer_treasure:pickedUp', function()
	local xPlayer = ESX.GetPlayerFromId(source)
	local xItem = xPlayer.getInventoryItem(Config.ItemName)
	local xItemCount = math.random(Config.ItemCount[1], Config.ItemCount[2])
	--
	if xItem.limit ~= -1 and xItem.count >= xItem.limit then
		TriggerClientEvent("mythic_notify:client:SendAlert", source, {
			text = xItem.label..'ของคุณเต็ม',
			type = "success",
			timeout = 3000,
			layout = "bottomCenter",
			queue = "global"
		})
	else
		if xItem.limit ~= -1 and (xItem.count + xItemCount) > xItem.limit then
			xPlayer.setInventoryItem(xItem.name, xItem.limit)
		else
			xPlayer.addInventoryItem(xItem.name, xItemCount)
			local sendToDiscord = '**' .. xPlayer.name .. '** ได้รับ **' .. xItem.label .. '** จำนวน '..xItemCount..' ชิ้น'
			TriggerEvent('azael_discordlogs:sendToDiscord', 'RicePickedUp', sendToDiscord, source, '^2')
			ItemBonus()
		end
	end
end)

function ItemBonus()
	local xPlayer = ESX.GetPlayerFromId(source)
	local xItem = xPlayer.getInventoryItem(Config.ItemBonus.ItemName2)
	local xItemCount = Config.ItemBonus.ItemCount2
	if xItem.limit ~= -1 and xItem.count >= xItem.limit then
		TriggerClientEvent("mythic_notify:client:SendAlert", source, {
			text = xItem.label..'ของคุณเต็ม',
			type = "error",
			timeout = 3000,
			layout = "bottomCenter",
			queue = "global"
		})
	else
		if math.random(1, 100) <= Config.ItemBonus.Percent then
			xPlayer.addInventoryItem(xItem.name, xItemCount)
			local sendToDiscord = '**' .. xPlayer.name .. '** ได้รับโบนัท **' .. xItem.label .. '** จำนวน '..xItemCount..''
			TriggerEvent('azael_discordlogs:sendToDiscord', 'RicePickedUp', sendToDiscord, source, '^9')
			
		end
	end
end




