local ActivityPed
local Washing = false
local models = {
    "g_m_importexport_01",
    "g_m_m_armgoon_01",
    "g_m_y_armgoon_02",
    "g_m_y_ballaorig_01",
    "g_m_y_ballaeast_01",
    "g_m_y_ballasout_01",
    "g_m_y_famca_01"
}

CreateThread(function()
    DealerPed()
end)

function DealerPed()
    local ped = Config.Dealer
    local spawn = ped.Spawn
    lib.requestModel(ped.Model, 5000)
    local hash = GetHashKey(ped.Model)
    Dealer = CreatePed("PED_TYPE_CIVMALE", hash, spawn.x, spawn.y, spawn.z - 0.98, spawn.w, false, false)
    TaskSetBlockingOfNonTemporaryEvents(Dealer, true)
    FreezeEntityPosition(Dealer, true)
    SetEntityInvincible(Dealer, true)

    exports.ox_target:addLocalEntity(Dealer, {
        {
            label = "I want to wash some money",
            icon = "fa-solid fa-person",
            canInteract = function()
                local item = exports.ox_inventory:Search('count', Config.BlackMoney)
                if not Washing then return true end
            end,
            onSelect = function()
                local item = exports.ox_inventory:Search('count', Config.BlackMoney)
                if item < 1000 then return lib.notify({ description =
                    "You must have atleast more than $1000 to exchange money!", type = "error" }) end
                lib.notify({ description = "Wait for the dealer to give you the location" })
                SetTimeout(5000, function()
                    lib.notify({ description = "Go to the dealer and exchange your money", duration = 5000 })
                    StartActivity()
                end)
            end
        }
    })
end

function StartActivity(type)
    local randped = math.random(1, #models)
    local actped = models[randped]
    lib.requestModel(actped, 5000)
    local hash = GetHashKey(actped)
    local randspawn = math.random(1, #Config.Locations)
    local spawn = Config.Locations[randspawn]

    ActivityPed = CreatePed("PED_TYPE_MISSION", hash, spawn.x, spawn.y, spawn.z - 0.98, spawn.w, false, false)
    TaskSetBlockingOfNonTemporaryEvents(ActivityPed, true)
    SetEntityInvincible(ActivityPed, true)
    ActivityPedBlip = CreateRoute(spawn, "Hawala Exchange")

    exports.ox_target:addLocalEntity(ActivityPed, {
        {
            label = "Exchange Money",
            icon = "fa-solid fa-money-bill",
            name = "MoneyWash:exchange",
            canInteract = function()
                local item = exports.ox_inventory:Search('count', Config.BlackMoney)
                if item > 0 then
                    return true
                end
            end,
            onSelect = function()
                WashMoney()
            end
        }
    })
end

function WashMoney()
    local item = exports.ox_inventory:Search('count', Config.BlackMoney)
    local deduction = math.floor(item * (Config.Percentage / 100))
    local washedmoney = math.floor(item - deduction)
    if lib.progressBar({
            label = "Exchanging money...",
            duration = Config.WashDuration * 1000,
            anim = {
                dict = "missheistdockssetup1ig_5@base",
                clip = "workers_talking_base_dockworker1",
            },
            disable = {
                combat = true,
                move = true,
                car = true,
            }
        }) then
        TriggerServerEvent("MoneyWash:server:removeItem", Config.BlackMoney, item)
        TriggerServerEvent("MoneyWash:server:additem", Config.Account, washedmoney)
        lib.notify({ description = "$" ..
        item ..
        " has been exchanged and $" ..
        deduction .. " has been deducted as commission and $" .. washedmoney .. " has been given after washing!", duration = 8000, icon =
        "fa-solid fa-money-bill" })
        exports.ox_target:removeLocalEntity(ActivityPed, "MoneyWash:exchange")
        SetTimeout(5000, function()
            if DoesEntityExist(ActivityPed) then
                DeleteEntity(ActivityPed)
            end
            if DoesBlipExist(ActivityPedBlip) then
                RemoveBlip(ActivityPedBlip)
            end
            Washing = false
        end)
    end
end

function CreateRoute(coords, label)
    local blip = AddBlipForCoord(coords.x, coords.y, coords.z)
    SetBlipSprite(blip, 1)
    SetBlipDisplay(blip, 2)
    SetBlipScale(blip, 0.8)
    SetBlipColour(blip, 66)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(label)
    EndTextCommandSetBlipName(blip)
    SetBlipRoute(blip, true)
    SetBlipRouteColour(blip, 66)
    return blip
end

AddEventHandler("onResourceStop", function(resourceName)
    if GetCurrentResourceName == resourceName then
        if DoesEntityExist(Ped) then
            DeleteEntity(Ped)
        end
        if DoesBlipExist(jobped) then
            RemoveBlip(jobped)
        end
    end
end)
