local Jomidar = exports[J0.Core]:GetCoreObject()
local lastHeistTime = 0 

--- Callback
Jomidar.Functions.CreateCallback('jomidar-bargheist:sv:checkTime', function(source, cb)
    local src = source
    local player = Jomidar.Functions.GetPlayer(src)
    
    local currentTime = os.time()
    local timeSinceLastHeist = currentTime - lastHeistTime
    
    if timeSinceLastHeist < J0.CoolDown and lastHeistTime ~= 0 then
        local secondsRemaining = J0.CoolDown - timeSinceLastHeist
        local minutesRemaining = math.floor(secondsRemaining / 60)
        local remainingSeconds = secondsRemaining % 60

        TriggerClientEvent('QBCore:Notify', src, "You must wait " .. minutesRemaining .. " min and " .. remainingSeconds .. " sec before starting another work.", "error")
        cb(false)
    else
        lastHeistTime = currentTime
        cb(true)
    end
end)

Jomidar.Functions.CreateCallback('jomidar-police:bargheist:getOnlinePoliceCount', function(source, cb)
    local policeCount = 0
    for _, playerId in pairs(Jomidar.Functions.GetPlayers()) do
        local Player = Jomidar.Functions.GetPlayer(playerId)
        if Player and Player.PlayerData.job.name == 'police' and Player.PlayerData.job.onduty then
            policeCount = policeCount + 1
        end
    end
    cb(policeCount)
end)

RegisterNetEvent('jomidar:bargheist:removeItem', function(item, ammount)
    local src = source
    local Player = Jomidar.Functions.GetPlayer(src)
    if Player then
    Player.Functions.RemoveItem(item, ammount)
    TriggerClientEvent('inventory:client:ItemBox', src, Jomidar.Shared.Items[item], "remove")
    end
end)

RegisterNetEvent('jomidar:bargheist:addItem', function(item, ammount)
    local src = source
    local Player = Jomidar.Functions.GetPlayer(src)
    if Player then
    Player.Functions.AddItem(item, ammount)
    TriggerClientEvent('inventory:client:ItemBox', src, Jomidar.Shared.Items[item], "add")
    end
end)

RegisterServerEvent('jomidar-bargheist:sv:containerSync')
AddEventHandler('jomidar-bargheist:sv:containerSync', function(coords, rotation, index)
    TriggerClientEvent('jomidar-bargheist:cl:containerSync', -1, coords, rotation, index)
end)

RegisterServerEvent('jomidar-bargheist:sv:lockSync')
AddEventHandler('jomidar-bargheist:sv:lockSync', function(index)
    TriggerClientEvent('jomidar-bargheist:cl:lockSync', -1, index)
end)

RegisterServerEvent('jomidar-bargheist:sv:objectSync')
AddEventHandler('jomidar-bargheist:sv:objectSync', function(e)
    TriggerClientEvent('jomidar-bargheist:cl:objectSync', -1, e)
end)

RegisterServerEvent('jomidar-bargheist:sv:ClearSync')
AddEventHandler('jomidar-bargheist:sv:ClearSync', function()
    TriggerClientEvent("jomidar-bargheist:cl:clear", -1)
end)