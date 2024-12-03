local Config = require('config')
local Washing = false
local Washer = "bkr_prop_prtmachine_dryer_spin"
CreateThread(function()
    lib.requestModel(Washer, 5000)
    if Config.Dealer.Type == "ox_target" then
        DealerPed()
    elseif Config.Dealer.Type == "rep-npctalk" then
    end
end)

function DealerPed()
    local ped = Config.Dealer
    local spawn = ped.Spawn
    lib.requestModel(ped.Model, 5000)
    local hash = GetHashKey(ped.Model)
    Dealer = CreatePed("PED_TYPE_CIVMALE", hash, spawn.x, spawn.y, spawn.z - 1, spawn.w, false, false)
    TaskSetBlockingOfNonTemporaryEvents(Dealer, true)
    FreezeEntityPosition(Dealer, true)
    SetEntityInvincible(Dealer, true)

    exports.ox_target:addLocalEntity(Dealer, {
        {
            label = "I want to wash some money",
            icon = "fa-solid fa-person",
            canInteract = function()
                if not Washing then return true end
            end,
            onSelect = function()
                local item = exports.ox_inventory:Search('count', Config.BlackMoney)
                if item < 1000 then
                    return lib.notify({
                        description =
                        "You must have atleast more than $1000 to exchange money!",
                        type = "error"
                    })
                end
                lib.notify({ description = "Wait for the dealer to give you the location" })
                SetTimeout(5000, function()
                    lib.notify({ description = "Go to the dealer and exchange your money", duration = 5000 })
                    StartActivity()
                end)
            end
        }
    })
end

function StartActivity()
    local randspawn = math.random(1, #Config.Locations)
    local spawn = Config.Locations[randspawn]
    Machine = CreateObject(GetHashKey(Washer), spawn.x, spawn.y, spawn.z, false, false, false)
    SetEntityHeading(Machine, spawn.w)
    blip = AddBlipForEntity(Machine)
    SetBlipSprite(blip, 1)
    SetBlipDisplay(blip, 2)
    SetBlipScale(blip, 0.8)
    SetBlipColour(blip, 66)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(label)
    EndTextCommandSetBlipName(blip)

    exports.ox_target:addLocalEntity(Machine, {
        {
            label = "Wash Money",
            icon = "fa-solid fa-money-bill",
            name = "MoneyWash:wash",
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
    local success = lib.skillcheck(Config.SkillCheck.Difficulty, Config.SkillCheck.Keys)
    if not success then return lib.notify({ description = "Failed to wash money!", type = "error" }) end
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
        if DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
        TriggerServerEvent("MoneyWash:server:removeItem", Config.BlackMoney, item)
        TriggerServerEvent("MoneyWash:server:additem", Config.Account, washedmoney)
        lib.notify({
            description = "$" ..
                item ..
                " has been exchanged and $" ..
                deduction .. " has been deducted as commission and $" .. washedmoney .. " has been given after washing!",
            duration = 8000,
            icon =
            "fa-solid fa-money-bill"
        })
        exports.ox_target:removeLocalEntity(Machine, "MoneyWash:wash")
        SetTimeout(5000, function()
            if DoesEntityExist(Machine) then
                DeleteEntity(Machine)
            end
            Washing = false
        end)
    end
end

AddEventHandler("onResourceStop", function(resourceName)
    if GetCurrentResourceName == resourceName then
        if DoesEntityExist(Dealer) then
            DeleteEntity(Dealer)
        end
        if DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
        if DoesEntityExist(Machine) then
            DeleteEntity(Machine)
        end
    end
end)
