lib.callback.register('mosleys:server:SpawnJobVeh', function(source, model, coords)
    local ped = GetPlayerPed(source)
    local id, vehicle = qbx.spawnVehicle({
        model = tonumber(model) or joaat(model),
        spawnSource = coords,
        warp = false,

        props = {
            fuelLevel = 100.00,
        }

    })
    exports.qbx_vehiclekeys:GiveKeys(source, vehicle)
    return id
end)

RegisterNetEvent("MoneyWash:server:additem", function (account, amount)
    local src = source
    exports.ox_inventory:AddItem(src, account, amount)
end)

RegisterNetEvent("MoneyWash:server:removeItem", function (item, amount)
    local src = source
    exports.ox_inventory:RemoveItem(src, item, amount)
end)