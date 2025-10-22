ESX = nil
local PlayerData = {}
local isWashing = false

Citizen.CreateThread(function()
    while ESX == nil do
        TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
        Citizen.Wait(0)
    end
    
    while ESX.GetPlayerData().job == nil do
        Citizen.Wait(10)
    end
    
    PlayerData = ESX.GetPlayerData()
end)

RegisterNetEvent('esx:playerLoaded')
AddEventHandler('esx:playerLoaded', function(xPlayer)
    PlayerData = xPlayer
end)

RegisterNetEvent('esx:setJob')
AddEventHandler('esx:setJob', function(job)
    PlayerData.job = job
end)

-- Create Blips
Citizen.CreateThread(function()
    if Config.EnableBlips then
        for k, v in pairs(Config.WashLocations) do
            if v.blip then
                local blip = AddBlipForCoord(v.coords.x, v.coords.y, v.coords.z)
                SetBlipSprite(blip, Config.BlipSprite)
                SetBlipDisplay(blip, 4)
                SetBlipScale(blip, Config.BlipScale)
                SetBlipColour(blip, Config.BlipColor)
                SetBlipAsShortRange(blip, true)
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString(v.label or _U('blip_name'))
                EndTextCommandSetBlipName(blip)
            end
        end
    end
end)

-- Check if player has access
function HasAccess()
    if Config.AccessType == 'none' then
        return true
    else
        if PlayerData.job and PlayerData.job.name == Config.JobName then
            if PlayerData.job.grade >= Config.MinimumGrade then
                return true
            else
                return false, 'wrong_grade'
            end
        else
            return false, 'wrong_job'
        end
    end
end

-- Wash Money Function
function WashMoney(location)
    if isWashing then return end
    
    -- Check access
    local hasAccess, reason = HasAccess()
    if not hasAccess then
        if reason == 'wrong_job' then
            ESX.ShowNotification(_U('wrong_job', Config.JobName, Config.MinimumGrade))
        elseif reason == 'wrong_grade' then
            ESX.ShowNotification(_U('wrong_job', Config.JobName, Config.MinimumGrade))
        else
            ESX.ShowNotification(_U('no_access'))
        end
        return
    end
    
    -- Check for laundry card
    if Config.RequireLaundryCard then
        ESX.TriggerServerCallback('moneywash:hasLaundryCard', function(hasCard)
            if not hasCard then
                ESX.ShowNotification(_U('no_laundry_card'))
                return
            else
                PromptWashAmount()
            end
        end)
    else
        PromptWashAmount()
    end
end

function PromptWashAmount()
    ESX.UI.Menu.Open('dialog', GetCurrentResourceName(), 'wash_amount', {
        title = _U('enter_amount', ESX.Math.GroupDigits(Config.MinWashAmount), ESX.Math.GroupDigits(Config.MaxWashAmount))
    }, function(data, menu)
        local amount = tonumber(data.value)
        
        if amount == nil then
            ESX.ShowNotification(_U('invalid_amount'))
        else
            menu.close()
            TriggerServerEvent('moneywash:startWash', amount)
        end
    end, function(data, menu)
        menu.close()
    end)
end

RegisterNetEvent('moneywash:startWashing')
AddEventHandler('moneywash:startWashing', function()
    isWashing = true
    
    ESX.ShowNotification(_U('washing_money'))
    
    -- Progress bar / animation
    local playerPed = PlayerPedId()
    TaskStartScenarioInPlace(playerPed, 'PROP_HUMAN_BUM_BIN', 0, true)
    
    Citizen.Wait(Config.WashTime)
    
    ClearPedTasksImmediately(playerPed)
    isWashing = false
end)

RegisterNetEvent('moneywash:washCancelled')
AddEventHandler('moneywash:washCancelled', function()
    isWashing = false
    local playerPed = PlayerPedId()
    ClearPedTasksImmediately(playerPed)
    ESX.ShowNotification(_U('cancelled'))
end)

-- Main Thread for Markers and Interaction
Citizen.CreateThread(function()
    while true do
        local sleep = 1000
        local playerPed = PlayerPedId()
        local playerCoords = GetEntityCoords(playerPed)
        
        for k, v in pairs(Config.WashLocations) do
            local distance = #(playerCoords - v.coords)
            
            if distance < Config.DrawDistance then
                sleep = 0
                
                if not Config.Use3DText then
                    DrawMarker(
                        Config.MarkerType,
                        v.coords.x, v.coords.y, v.coords.z,
                        0.0, 0.0, 0.0,
                        0.0, 0.0, 0.0,
                        Config.MarkerSize.x, Config.MarkerSize.y, Config.MarkerSize.z,
                        Config.MarkerColor.r, Config.MarkerColor.g, Config.MarkerColor.b, Config.MarkerOpacity,
                        false, true, 2, false, nil, nil, false
                    )
                end
                
                if distance < 1.5 then
                    if Config.Use3DText then
                        ESX.Game.Utils.DrawText3D(v.coords, _U('press_to_wash'), 0.4)
                    else
                        ESX.ShowHelpNotification(_U('press_to_wash'))
                    end
                    
                    if IsControlJustReleased(0, 38) and not isWashing then
                        WashMoney(v)
                    end
                end
            end
        end
        
        Citizen.Wait(sleep)
    end
end)
