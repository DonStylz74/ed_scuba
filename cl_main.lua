local has_tank = false
local oxy_tank = false
local oxy_value = 0
local diving_swim = false
local current_scuba
lib.locale()

-- exports return current oxygen capacity (percentage)
exports("getoxy", function()
    return current_scuba and oxy_value/Config.fulltank*100 or 0
end)

RegisterNetEvent('ed_scuba:oxygenHandle', function(type, value) --event to handle tank refill
    local playerPed = PlayerPedId()
    local pedModel = GetEntityModel(playerPed)
    if not isWearingScuba(playerPed, pedModel) then
        lib.showContext('seapanda_menu')
        return sendnotification(locale('not_equipped'))
    end
    local itemcount = getScubaItemCount(Config.scubaItemName)
    if itemcount < 1 then
        return sendnotification(locale('no_tank'))
    end
    if type == 'refill' then
        oxy_value = value and value/100*Config.fulltank or Config.fulltank
        sendnotification(locale('tank_loaded', oxy_value/Config.fulltank*100, '%'))
        if Config.OxInventory then
            TriggerServerEvent("ed_scuba:updateMetadata", {
                slot = current_scuba,
                oxy = oxy_value/Config.fulltank*100
            })
        end
    end
    if type == 'check' then
        sendnotification(locale('tank_capacity', oxy_value/Config.fulltank*100, '%'))
    end
    if type == 'pay' then
        TriggerServerEvent('ed_scuba:oxygenRefillPay')
    end
end)

RegisterNetEvent('ed_scuba:wear', function(name)
    local playerPed = PlayerPedId()
    local pedModel = GetEntityModel(playerPed)
    local handle = applyScuba(name, playerPed, pedModel)
    if not handle.getScuba() then
        handle.setScuba()
    else
        if not Config.drop_to_reset then
            handle.resetScuba()
        end
    end
end)

ESX.RegisterInput('scubalight', 'Turn Scuba Light On/Off', 'keyboard', Config.scubalightKeybind, function()
    local playerPed = PlayerPedId()
    local pedModel = GetEntityModel(playerPed)
    local LightEnabled = IsScubaGearLightEnabled(playerPed)
    if isWearingScuba(playerPed, pedModel) then
        if LightEnabled then
            SetEnableScubaGearLight(playerPed, false)
        else
            SetEnableScubaGearLight(playerPed, true)
        end
    end
end, function()

end)

if Config.OxInventory then
    -- exports for ox_inventory
    exports('wear', function(data, slot)
        TriggerEvent('ed_scuba:wear', data.name)
        if data.name ~= "scuba_set" then
            return
        end
        current_scuba = current_scuba and nil or slot.slot
        oxy_value = slot.metadata?.oxy and slot.metadata.oxy/100*Config.fulltank or 0
        if current_scuba then
            TriggerServerEvent("ed_scuba:equip", {slot = slot.slot})
            TriggerServerEvent("ed_scuba:updateMetadata", {
                slot = current_scuba,
                oxy = oxy_value/Config.fulltank*100
            })
        end
    end)

    RegisterNetEvent("ed_scuba:updateCurrent", function(data)
        current_scuba = data.slot
        if current_scuba == nil then
            TriggerEvent('ed_scuba:wear', "scuba_set")
        end
    end)

    AddEventHandler('onResourceStop', function(resourceName)
        if resourceName ~= GetCurrentResourceName() then
            return
        end
        local playerPed = PlayerPedId()
        local pedModel = GetEntityModel(playerPed)
        if isWearingScuba(playerPed, pedModel) or isWearingScuba(playerPed, pedModel, true) then
            local equipment = {
                Config.scubaItemName,
                Config.finsItemName
            }
            for i = 1, #equipment do
                local name = equipment[i]
                applyScuba(name, playerPed, pedModel).resetScuba(true)
            end
        end
    end)
else
    -- usable item client event
    RegisterNetEvent('ed_scuba:useItem', function(name)
        TriggerEvent('ed_scuba:wear', name)
        if name ~= "scuba_set" then
            return
        end
        current_scuba = current_scuba and nil or 1
    end)

    -- esx inventory remove item check
    RegisterNetEvent('esx:removeInventoryItem')
	AddEventHandler('esx:removeInventoryItem', function(item, count, showNotification)
        local playerPed = PlayerPedId()
        local pedModel = GetEntityModel(playerPed)
        if isWearingScuba(playerPed, pedModel) or isWearingScuba(playerPed, pedModel, true) then
            local equipment = {
                Config.scubaItemName,
                Config.finsItemName
            }

            local items = ESX.SearchInventory(equipment, true)
            if items[item] and count < 1 then
                applyScuba(item, playerPed, pedModel).resetScuba()
            end
        end
    end)

    AddEventHandler('onResourceStop', function(resourceName)
        if resourceName ~= GetCurrentResourceName() then
            return
        end
        local playerPed = PlayerPedId()
        local pedModel = GetEntityModel(playerPed)
        if isWearingScuba(playerPed, pedModel) or isWearingScuba(playerPed, pedModel, true) then
            local equipment = {
                Config.scubaItemNsendNotificationame,
                Config.finsItemName
            }
            for i = 1, #equipment do
                local name = equipment[i]
                applyScuba(name, playerPed, pedModel).resetScuba(true)
            end
        end
    end)
end

CreateThread(function()
    if Config.EnableBlip then
        CreateBlips()
    end
    while true do
        local playerPed = PlayerPedId()
        local pcoords = GetEntityCoords(playerPed)
        if IsPedSwimmingUnderWater(playerPed) then
            if oxy_tank and oxy_value > 0.0 then
                oxy_value -= 1
                if tankAlert(oxy_value) then
                    sendnotification(locale('tank_remaining', oxy_value/Config.fulltank*100, '%'))
                end
            else
                SetPedConfigFlag(playerPed, 3, true)
            end
        end
        if current_scuba and Config.OxInventory then
            TriggerServerEvent("ed_scuba:updateMetadata", {
                slot = current_scuba,
                oxy = oxy_value/Config.fulltank*100
            })
        end
        Wait(1000) --each seconds
    end
end)

CreateThread(function()
    while true do
        local playerPed = PlayerPedId()
        local pedModel = GetEntityModel(playerPed)
        if isWearingScuba(playerPed, pedModel) then
            has_tank = true
            if not oxy_tank and oxy_value > 1 then
                oxy_tank = true
                SetPedConfigFlag(playerPed, 3, false)
                sendnotification(locale('tank_available', oxy_value/Config.fulltank*100, '%'))
            end
        else
            has_tank = false
            if IsScubaGearLightEnabled(playerPed) then
                SetEnableScubaGearLight(playerPed, false)
            end
            if oxy_tank then
                oxy_tank = false
                SetPedConfigFlag(playerPed, 3, true)
                sendnotification(locale('tank_not_available'))
            end
        end
        if isWearingScuba(playerPed, pedModel, true) then
            if not diving_swim then
                diving_swim = true
                SetEnableScuba(playerPed, true)
                sendnotification(locale('diving_fins_equip'))
            end
        else
            if diving_swim then
                diving_swim = false
                SetEnableScuba(playerPed, false)
                sendnotification(locale('diving_no_fins_equip'))
            end
        end
        Wait(500)
    end
end)