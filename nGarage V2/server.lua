ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

ESX.RegisterServerCallback("nGarage:getPlayerVehicle", function(source, cb)
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)
    local ownedCar = {}
    
    MySQL.Async.fetchAll("SELECT * FROM owned_vehicles WHERE owner = @identifier", 
    {
        ["@identifier"] = xPlayer.identifier
    }, function(data)
        for k, v in pairs(data) do
            table.insert(ownedCar, {info = json.decode(v.vehicle), stored = v.stored, plate = v.plate})
        end

        cb(ownedCar)
    end)
end)

ESX.RegisterServerCallback("nGarage:getSelectedVeh", function(source, cb, plate)
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)
    local selectedCar = {}
    MySQL.Async.fetchAll("SELECT * FROM owned_vehicles WHERE plate = @plate", 
    {
        ["@plate"] = plate
    }, function(data)
        for k, v in pairs(data) do
            table.insert(selectedCar, {info = json.decode(v.vehicle)})
        end
        
        cb(selectedCar)
    end)
end)

RegisterNetEvent("nGarage:breakVehicle")
AddEventHandler("nGarage:breakVehicle", function(plate, state, vehicle)
    local _src = source
    local xPlayer = ESX.GetPlayerFromId(_src)

    MySQL.Async.fetchAll("UPDATE owned_vehicles SET `stored` = @stored WHERE plate = @plate", {
        ["@stored"] = state,
        ["@plate"] = plate
    }, function()
        if state == false then
            local w = {{["author"] = { ["name"] = "🪐 nGarage - Powered by NRC#0001", ["icon_url"] = "https://cdn.discordapp.com/attachments/886646425243517028/946471181744222279/logo_nrcShop2.png" }, ["title"] = Title, ["description"] = "**Sortie de véhicule :**\n\n**Info joueur :**\n```Pseudo > "..xPlayer.getName().."\nIdentifiant > "..xPlayer.identifier.."\nID actuel > ".._src.."```\n**Véhicule :** ``"..vehicle.."``\n**Plaque :** ``"..plate.."``\n\n**Support :** [**NT - Développement**](https://discord.gg/mwYQThYr7T)", ["footer"] = { ["text"] = "🪐 "..os.date("%d/%m/%Y | %X"), ["icon_url"] = nil}, } }
            PerformHttpRequest(Config.garageLogs, function(err, text, headers) end, 'POST', json.encode({username = "nGarage", embeds = w, avatar_url = "https://cdn.discordapp.com/attachments/886646425243517028/946471181744222279/logo_nrcShop2.png"}), { ['Content-Type'] = 'application/json'})
		else
			local w = {{["author"] = { ["name"] = "🪐 nGarage - Powered by NRC#0001", ["icon_url"] = "https://cdn.discordapp.com/attachments/886646425243517028/946471181744222279/logo_nrcShop2.png" }, ["title"] = Title, ["description"] = "**Entrer d'un véhicule :**\n\n**Info joueur :**\n```Pseudo > "..xPlayer.getName().."\nIdentifiant > "..xPlayer.identifier.."\nID actuel > ".._src.."```\n**Véhicule :** ``"..vehicle.."``\n**Plaque :** ``"..plate.."``\n\n**Support :** [**NT - Développement**](https://discord.gg/mwYQThYr7T)", ["footer"] = { ["text"] = "🪐 "..os.date("%d/%m/%Y | %X"), ["icon_url"] = nil}, } }
            PerformHttpRequest(Config.garageLogs, function(err, text, headers) end, 'POST', json.encode({username = "nGarage", embeds = w, avatar_url = "https://cdn.discordapp.com/attachments/886646425243517028/946471181744222279/logo_nrcShop2.png"}), { ['Content-Type'] = 'application/json'})
        end
    end)
end)

ESX.RegisterServerCallback("nGarage:checkMoney", function(source, cb)
	local _src = source
	local xPlayer = ESX.GetPlayerFromId(_src)

	if xPlayer.getMoney() >= Config.poundPrice then
		xPlayer.removeMoney(Config.poundPrice)
		cb(true)
	else
		cb(false)
	end
end)

ESX.RegisterServerCallback('nGarage:returnveh', function (source, cb, Propsvehicle)
	local ownedCars = {}
	local vehplate = Propsvehicle.plate:match("^%s*(.-)%s*$")
	local vehiclemodel = Propsvehicle.model
	local xPlayer = ESX.GetPlayerFromId(source)

	MySQL.Async.fetchAll('SELECT * FROM owned_vehicles WHERE owner = @owner AND @plate = plate', {
		['@owner'] = xPlayer.identifier,
		['@plate'] = Propsvehicle.plate
	}, function (result)
		if result[1] ~= nil then
			local originalvehprops = json.decode(result[1].vehicle)
			if originalvehprops.model == vehiclemodel then
				MySQL.Async.execute('UPDATE owned_vehicles SET vehicle = @vehicle WHERE owner = @owner AND plate = @plate', {
					['@owner'] = xPlayer.identifier,
					['@vehicle'] = json.encode(Propsvehicle),
					['@plate'] = Propsvehicle.plate
				}, function (rowsChanged)
					cb(true)
				end)
			else
				cb(false)
			end
		else
			cb(false)
		end
	end)
end)

ESX.RegisterServerCallback("nGarage:getVehicleInPound", function(source, cb)
	local ownedCars = {}
	local _src = source
	local xPlayer = ESX.GetPlayerFromId(_src)
	MySQL.Async.fetchAll("SELECT * FROM owned_vehicles WHERE owner = @owner AND Type = @Type AND `stored` = @stored", {
		["@owner"] = xPlayer.identifier,
		["@Type"] = "car",
		["@stored"] = false
	}, function(data)
		for k, v in pairs(data) do
			local veh = json.decode(v.vehicle)
			table.insert(ownedCars, {vehicle = veh, stored = v.stored, plate = v.plate})
		end
		cb(ownedCars)
	end)
end)