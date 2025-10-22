ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)

-- Callback to check if player has laundry card
ESX.RegisterServerCallback('moneywash:hasLaundryCard', function(source, cb)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if xPlayer then
        local laundryCard = xPlayer.getInventoryItem(Config.LaundryCardItem)
        
        if laundryCard and laundryCard.count > 0 then
            cb(true)
        else
            cb(false)
        end
    else
        cb(false)
    end
end)

-- Start washing process
RegisterNetEvent('moneywash:startWash')
AddEventHandler('moneywash:startWash', function(amount)
    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
    
    if not xPlayer then return end
    
    -- Validate amount
    if amount == nil or amount < Config.MinWashAmount then
        TriggerClientEvent('esx:showNotification', _source, _U('not_enough_dirty', ESX.Math.GroupDigits(Config.MinWashAmount)))
        return
    end
    
    if amount > Config.MaxWashAmount then
        TriggerClientEvent('esx:showNotification', _source, _U('amount_too_high', ESX.Math.GroupDigits(Config.MaxWashAmount)))
        return
    end
    
    -- Check if player has enough dirty money
    local dirtyMoney = xPlayer.getAccount(Config.DirtyMoneyItem).money
    
    if dirtyMoney < amount then
        TriggerClientEvent('esx:showNotification', _source, _U('no_dirty_money'))
        return
    end
    
    -- Check and remove laundry card if required
    if Config.RequireLaundryCard then
        local laundryCard = xPlayer.getInventoryItem(Config.LaundryCardItem)
        
        if not laundryCard or laundryCard.count <= 0 then
            TriggerClientEvent('esx:showNotification', _source, _U('no_laundry_card'))
            return
        end
        
        xPlayer.removeInventoryItem(Config.LaundryCardItem, 1)
        TriggerClientEvent('esx:showNotification', _source, _U('card_consumed'))
    end
    
    -- Remove dirty money
    xPlayer.removeAccountMoney(Config.DirtyMoneyItem, amount)
    
    -- Start washing animation on client
    TriggerClientEvent('moneywash:startWashing', _source)
    
    -- Wait for wash time
    Citizen.Wait(Config.WashTime)
    
    -- Calculate clean money after tax
    local cleanAmount = amount
    local taxAmount = 0
    
    if Config.EnableTax then
        taxAmount = math.floor(amount * (Config.TaxPercentage / 100))
        cleanAmount = amount - taxAmount
    end
    
    -- Give clean money
    xPlayer.addMoney(cleanAmount)
    
    -- Send success notification
    if Config.EnableTax then
        TriggerClientEvent('esx:showNotification', _source, _U('wash_success', ESX.Math.GroupDigits(amount), ESX.Math.GroupDigits(cleanAmount)))
        TriggerClientEvent('esx:showNotification', _source, _U('tax_applied', Config.TaxPercentage, ESX.Math.GroupDigits(taxAmount)))
    else
        TriggerClientEvent('esx:showNotification', _source, _U('wash_success_no_tax', ESX.Math.GroupDigits(cleanAmount)))
    end
    
    -- Log the transaction (optional - for admin logs)
    print(('[MONEY WASH] Player: %s | Identifier: %s | Dirty: $%s | Clean: $%s | Tax: $%s'):format(
        xPlayer.getName(),
        xPlayer.identifier,
        amount,
        cleanAmount,
        taxAmount
    ))
end)
