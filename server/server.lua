RegisterNetEvent("MoneyWash:server:additem", function (account, amount)
    local src = source
    exports.ox_inventory:AddItem(src, account, amount)
end)

RegisterNetEvent("MoneyWash:server:removeItem", function (item, amount)
    local src = source
    exports.ox_inventory:RemoveItem(src, item, amount)
end)