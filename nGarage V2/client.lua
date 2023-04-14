ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

local poundList = {}

function OpenGarage(garageName)
    ESX.TriggerServerCallback("nGarage:getPlayerVehicle", function(result)
        if #result < 1 then
            return ESX.ShowNotification("Vous n'avez pas de véhicule dans ce garage")
        end
        for i = 1, #result do
            SendNUIMessage({
                action = "open",
                garageName = garageName,
                info = result[i].info.model,
                name = GetLabelText(GetDisplayNameFromVehicleModel(result[i].info.model)),
                plate = result[i].plate,
                bodyHealth = math.floor(result[i].info.bodyHealth)/10,
                engineHealth = math.floor(result[i].info.engineHealth)/10,
                fuelLevel = math.floor(result[i].info.fuelLevel),
                stored = result[i].stored,
                realBody = result[i].info.bodyHealth,
                realEngine = result[i].info.engineHealth,
                realFuel = result[i].info.fuelLevel,
            })
        end
        SetNuiFocus(true, true)
    end)

end


RegisterNUICallback("close", function(data)
    SetNuiFocus(false, false)
end)

RegisterNUICallback("takeOut", function(data)

    SpawnVehicle(tonumber(data.info), data.plate, tonumber(data.realBody)+0.0, tonumber(data.realEngine)+0.0, tonumber(data.realFuel)+0.0, false)
end)


function SpawnVehicle(vehicle, plate, body, engine, fuel, bool)
    ESX.TriggerServerCallback("nGarage:getSelectedVeh", function(result)
        for i = 1, #result do
            x,y,z = table.unpack(GetEntityCoords(PlayerPedId(),true))
            ESX.Game.SpawnVehicle(vehicle, {
                x = x,
                y = y,
                z = z 
            }, 90.0, function(callback_vehicle)
                ESX.Game.SetVehicleProperties(callback_vehicle, result[i].info)
                SetVehRadioStation(callback_vehicle, "OFF")
                SetVehicleUndriveable(callback_vehicle, false)
                SetVehicleEngineHealth(callback_vehicle, engine)
                SetVehicleEngineOn(callback_vehicle, true, true)
                SetVehicleBodyHealth(callback_vehicle, body)
                SetVehicleFuelLevel(callback_vehicle, fuel)
                TaskWarpPedIntoVehicle(PlayerPedId(), callback_vehicle, -1)
            end)
        end
    end, plate)
   
    TriggerServerEvent("nGarage:breakVehicle", plate, bool, GetLabelText(GetDisplayNameFromVehicleModel(vehicle)))
end

function ReturnVeh()
    local playerPed = GetPlayerPed(-1)
    if IsPedInAnyVehicle(playerPed, false) then 
        local playerPed = GetPlayerPed(-1)
        local pos = GetEntityCoords(playerPed)
        local vehicle = GetVehiclePedIsIn(playerPed, false)
        local Propsvehicle = ESX.Game.GetVehicleProperties(vehicle)
        local current = GetPlayersLastVehicle(GetPlayerPed(-1), true)
        local engineH = GetVehicleEngineHealth(current)
        local plate = Propsvehicle.plate

        ESX.TriggerServerCallback("nGarage:returnveh", function(valid)
            if valid then 
                BreakReturnVehicle(vehicle, Propsvehicle)
            else
                ESX.ShowNotification("Tu ne peut pas garer ce véhicule")
            end
        end, Propsvehicle)
    else 
        ESX.ShowNotification("Il n'y a pas de véhicule à ranger dans le garage")
    end
end

function BreakReturnVehicle(vehicle, Propsvehicle)
	ESX.Game.DeleteVehicle(vehicle)
	TriggerServerEvent('nGarage:breakVehicle', Propsvehicle.plate, true, GetLabelText(GetDisplayNameFromVehicleModel(Propsvehicle.model)))
	ESX.ShowNotification("Tu vien de ranger ton ~r~véhicule ~s~!")
end

-- Fourrière -- 

local isMenuOpen = false

local pound_menu = RageUI.CreateMenu("Fourrière", "Liste des véhicules")
pound_menu.Closed = function ()
    isMenuOpen = false
end

function PoundMenu()
    if not isMenuOpen then
        isMenuOpen = true
        RageUI.Visible(pound_menu, true)
        while isMenuOpen do
            RageUI.IsVisible(pound_menu, function()
                for i = 1, #poundList do
                    local hash = poundList[i].vehicle.model
                    local model = poundList[i].vehicle
                    local nomveh = GetDisplayNameFromVehicleModel(hash)
                    local nomvehtexte = GetLabelText(nomveh)
                    local plaque = poundList[i].plate

                    RageUI.Button("~o~→→~s~ "..nomvehtexte, "Prix : ~g~"..Config.poundPrice.."$", {RightLabel = "[~b~"..plaque.."~s~]"}, true, {
                        onSelected = function()
                            
                            ESX.TriggerServerCallback("nGarage:checkMoney", function(valid)
                                if valid then
                                    SpawnVehicle(hash, plaque, model.bodyHealth, model.engineHealth, model.fuelLevel, true)
                                else
                                    ESX.ShowNotification("Tu n'as pas assez d'argent")
                                end
                            end)
                        end
                    })
                end
            end)
            Wait(1)
        end
    end
end

CreateThread(function()
    while true do
        local InZone = false
        local playerPos = GetEntityCoords(PlayerPedId())
        for k, v in pairs(Config.garagePos) do
            local distance = GetDistanceBetweenCoords(playerPos, v.sortie.x, v.sortie.y, v.sortie.z, true)
            if distance < 10 then
                DrawMarker(36, v.sortie.x, v.sortie.y, v.sortie.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.5, 1.5, 1.5, 0, 255, 0, 200, 0, 1, 2, 0, nil, nil, 0)
                InZone = true
                if distance < 2 then
                    Visual.Subtitle("Appuyer sur ~g~E~s~ pour accéder à votre garage", 1)
                    if IsControlJustPressed(1, 38) then
                        OpenGarage(v.name)
                    end
                end
            end
        end
        for k, v in pairs(Config.garagePos) do
            local distance = GetDistanceBetweenCoords(playerPos, v.entrer.x, v.entrer.y, v.entrer.z, true)
            if distance < 10 then
                DrawMarker(36, v.entrer.x, v.entrer.y, v.entrer.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.5, 1.5, 1.5, 255, 0, 0, 200, 0, 1, 2, 0, nil, nil, 0)
                InZone = true
                if distance < 2 then
                    Visual.Subtitle("Appuyer sur ~r~E~s~ pour ranger votre véhicule", 1)
                    if IsControlJustPressed(1, 38) then
                        ReturnVeh()
                    end
                end
            end
        end
        for k, v in pairs(Config.poundPos) do
            local distance = GetDistanceBetweenCoords(playerPos, v.x, v.y, v.z, true)
            if distance < 10 then
                DrawMarker(39, v.x, v.y, v.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.5, 1.5, 1.5, 255, 138, 27, 200, 0, 1, 2, 0, nil, nil, 0)
                InZone = true
                if distance < 2 then
                    Visual.Subtitle("Appuyer sur ~o~E~s~ pour accéder à la fourrière", 1)
                    if IsControlJustPressed(1, 38) then
                        ESX.TriggerServerCallback("nGarage:getVehicleInPound", function(result)
                            poundList = result
                        end)
                        PoundMenu()
                    end
                end
            end
        end
        if not InZone then
            Wait(500)
        else
            Wait(1)
        end
    end
end)

CreateThread(function ()
    for k, v in pairs(Config.garagePos) do
        local blip = AddBlipForCoord(v.sortie)

        SetBlipSprite(blip, 357)
        SetBlipScale (blip, 0.9)
        SetBlipColour(blip, 3)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName('Garage | '..v.name)
        EndTextCommandSetBlipName(blip)
    end

    for k, v in pairs(Config.poundPos) do
        local blip = AddBlipForCoord(v)

        SetBlipSprite(blip, 67)
        SetBlipScale (blip, 0.9)
        SetBlipColour(blip, 47)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentSubstringPlayerName("Fourrière")
        EndTextCommandSetBlipName(blip)
    end
end)
