local Jomidar = exports[J0.Core]:GetCoreObject()
local CurrentCops = 0

function spawnDinghy3(x, y, z, heading)
    local modelName = GetHashKey("dinghy3")

    RequestModel(modelName)
    while not HasModelLoaded(modelName) do
        Citizen.Wait(0)
    end
    local vehicle = CreateVehicle(modelName, x, y, z, heading, true, false)
    SetEntityAsMissionEntity(vehicle, true, true)
    SetModelAsNoLongerNeeded(modelName)
    return vehicle
end

function SpawnBarge()
    local bargetLoc = vector3(245.98, 4008.54, -3.0)
    local propModel = GetHashKey("xm_prop_x17_barge_01")
    RequestModel(propModel)
    while not HasModelLoaded(propModel) do
        Wait(10)
    end
    local barge = CreateObject(propModel, bargetLoc.x, bargetLoc.y, bargetLoc.z,true, true, false)
    FreezeEntityPosition(barge, true)
    PlaceObjectOnGroundProperly(barge)
end

RegisterCommand('spawnbarge', function(source, args, rawCommand)
    TriggerEvent('Jomidar-bargheist:client:start')
end, false)

local guardPeds = {}

function SpawnGuards()
    for _, guard in ipairs(J0.GuardPeds) do
        local model = GetHashKey(guard.model)
        RequestModel(model)
        while not HasModelLoaded(model) do
            Wait(1)
        end

        local guardPed = CreatePed(4, model, guard.coords.x, guard.coords.y, guard.coords.z, guard.heading, true, true)


        GiveWeaponToPed(guardPed, GetHashKey("weapon_pistol"), 250, false, true)
        SetPedCombatAttributes(guardPed, 46, true) 
        SetPedFleeAttributes(guardPed, 0, false) 
        SetPedCombatAbility(guardPed, 2)
        SetPedCombatRange(guardPed, 2)
        SetPedCombatMovement(guardPed, 2)
        SetPedRelationshipGroupHash(guardPed, GetHashKey("HATES_PLAYER")) 
        TaskCombatPed(guardPed, PlayerPedId(), 0, 16)

     
        local blip = AddBlipForEntity(guardPed)
        SetBlipAsFriendly(blip, false)
        
       
        table.insert(guardPeds, { ped = guardPed, blip = blip })
    end
end

function startPed()

local pedCoords = J0.StartPed
local pedModel = `a_m_y_business_01`
RequestModel(pedModel)
while not HasModelLoaded(pedModel) do
    Wait(500)
end
local ped = CreatePed(4, pedModel, pedCoords.x, pedCoords.y, pedCoords.z, pedCoords.w, false, true)
SetEntityInvincible(ped, true)
FreezeEntityPosition(ped, true)
SetBlockingOfNonTemporaryEvents(ped, true)   
exports['qb-target']:AddTargetEntity(ped, {
    options = {
        {
            type = "client", 
            event = "Jomidar-bargheist:client:start", 
            label = "Start Heist",
            icon = "fas fa-comment", 
        },
    },
    distance = 2.5  
})

end

RegisterNetEvent('Jomidar-bargheist:client:start', function()
local minPoliceRequired = J0.CopNeed
Jomidar.Functions.TriggerCallback('jomidar-police:bargheist:getOnlinePoliceCount', function(policeCount)
    if policeCount >= minPoliceRequired then
        Jomidar.Functions.TriggerCallback('jomidar-bargheist:sv:checkTime', function(time)
            if time then
                local x, y, z, heading = 1333.92, 4268.28, 29.85, 278.51
                 spawnDinghy3(x, y, z, heading)
                TriggerEvent('jomidar-bargheist:cl:clear')
                exports['jomidar-ui']:Show('Waiting for job offer')
                Citizen.Wait(2000)
                exports['jomidar-ui']:Show('Barge Heist', 'Go To The Docs And Get The Boat')
                SpawnBarge()
                SetupContainers()
                Citizen.Wait(2000)
                SpawnGuards()
                exports['jomidar-ui']:Show('Barge Heist', 'Go To The Marked Location')
            end
        end)
    else
        Jomidar.Functions.Notify("Not enough police officers on duty.", "error")
    end
end)
end)

CreateThread(function() 
    startPed()
end)

local containers = {}
local collisions = {}
local locks = {}
local clientContainer = {}
local clientLock = {}
local rndContainer = nil


function loadModel(model)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(1)
    end
end

function loadAnimDict(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(1)
    end
end

function loadPtfxAsset(asset)
    RequestNamedPtfxAsset(asset)
    while not HasNamedPtfxAssetLoaded(asset) do
        Wait(1)
    end
end

RegisterNetEvent('jomidar-bargheist:cl:clear')
AddEventHandler('jomidar-bargheist:cl:clear', function()
    for i = 1, #J0['containers'] do
        DeleteEntity(containers[i])
        DeleteEntity(locks[i])
        DeleteEntity(collisions[i])
        exports['qb-target']:RemoveZone("opencontainers"..i)
        J0['containers'][i]['lock']['taken'] = false
        DeleteEntity(clientContainer[i])
        DeleteEntity(clientLock[i])
    end
    exports['qb-target']:RemoveTargetEntity(weaponBox, 'Open Crate')
    DeleteEntity(weaponBox)
    DeleteEntity(barge)
end)

function SetupContainers()
    containersBlip = AddBlipForCoord(249.23, 4005.94, 32.95)
    SetBlipSprite(containersBlip, 677)
    SetBlipColour(containersBlip, 1)
    SetBlipScale(containersBlip, 0.7)
    SetBlipRoute(containersBlip, true)
    SetBlipRouteColour(containersBlip, 1)
    BeginTextCommandSetBlipName("STRING")
	AddTextComponentString('Containers')
	EndTextCommandSetBlipName(containersBlip)

    loadModel('prop_ld_container')
    rndContainer = math.random(1,#J0['containers'])

    for k, v in pairs(J0['containers']) do
        loadModel(J0['containers'][k].containerModel)
        Wait(100)
        containers[k] = CreateObject(GetHashKey(J0['containers'][k].containerModel), v.pos, 1, 1, 0)
        SetEntityHeading(containers[k], v.heading)
        FreezeEntityPosition(containers[k], true)
        Wait(math.random(100, 500))
        collisions[k] = CreateObject(GetHashKey('prop_ld_container'), v.pos, 1, 1, 0)
        SetEntityHeading(collisions[k], v.heading)
        SetEntityVisible(collisions[k], false)
        FreezeEntityPosition(collisions[k], true)
        Wait(math.random(100, 500))
        locks[k] = CreateObject(GetHashKey('tr_prop_tr_lock_01a'), v.lock.pos, 1, 1, 0)
        SetEntityHeading(locks[k], v.heading)
        FreezeEntityPosition(locks[k], true)
        exports["qb-target"]:AddCircleZone("opencontainers"..k, v.target, 1.0, {
            name ="opencontainers"..k,
            useZ = true,
            debugPoly=false
            }, {
                options = {
                    {
                        action = function()
                             local result = Jomidar.Functions.HasItem(J0.RequiredItem, 1)
                             if result then
                            exports['jomidar-ui']:Show('Barge Heist', 'Loot The Container')
                                if not J0['containers'][k]['lock']['taken'] then
                                    OpenContainer(k)
                                    TriggerServerEvent('jomidar:bargheist:removeItem', J0.RequiredItem, 1)
                                else
                                    Jomidar.Functions.Notify("Already Open", "error")
                                end
                             else
                              Jomidar.Functions.Notify("no Item", "error")
                            end
                        end,
                        icon = "fas fa-user-secret",
                        label = "Open Container",
                    },
                 },
                job = {"all"},
                distance = 1.5,
        })



    end
    
    weaponBox = CreateObject(GetHashKey("ex_prop_crate_ammo_sc"), vector3(J0['containers'][rndContainer].box.x,J0['containers'][rndContainer].box.y,J0['containers'][rndContainer].box.z), 1, 1, 0)
    SetEntityHeading(weaponBox, J0['containers'][rndContainer].box.w)
    FreezeEntityPosition(weaponBox, true)
end


function OpenContainer(index)
            Jomidar.Functions.Progressbar("opencontainer", "Opening the container...", 11500, false, false, {
                disableMovement = true,
                disableCarMovement = false,
                disableMouse = false,
                disableCombat = true,
            }, {}, {}, {}, function()
            end)
          --  AlertCops()
            local ped = PlayerPedId()
            local pedCo = GetEntityCoords(ped)
            local pedRotation = GetEntityRotation(ped)
            local animDict = 'anim@scripted@player@mission@tunf_train_ig1_container_p1@male@'
            loadAnimDict(animDict)
            loadPtfxAsset('scr_tn_tr')
            TriggerServerEvent('jomidar-bargheist:sv:lockSync', index)
            
            for i = 1, #ContainerAnimation['objects'] do
                loadModel(ContainerAnimation['objects'][i])
                ContainerAnimation['sceneObjects'][i] = CreateObject(GetHashKey(ContainerAnimation['objects'][i]), pedCo, 1, 1, 0)
            end

            sceneObject = GetClosestObjectOfType(pedCo, 2.5, GetHashKey(J0['containers'][index].containerModel), 0, 0, 0)
            lockObject = GetClosestObjectOfType(pedCo, 2.5, GetHashKey('tr_prop_tr_lock_01a'), 0, 0, 0)
            NetworkRegisterEntityAsNetworked(sceneObject)
            NetworkRegisterEntityAsNetworked(lockObject)

            scene = NetworkCreateSynchronisedScene(GetEntityCoords(sceneObject), GetEntityRotation(sceneObject), 2, true, false, 1065353216, 0, 1065353216)

            NetworkAddPedToSynchronisedScene(ped, scene, animDict, ContainerAnimation['animations'][1][1], 4.0, -4.0, 1033, 0, 1000.0, 0)
            NetworkAddEntityToSynchronisedScene(sceneObject, scene, animDict, ContainerAnimation['animations'][1][2], 1.0, -1.0, 1148846080)
            NetworkAddEntityToSynchronisedScene(lockObject, scene, animDict, ContainerAnimation['animations'][1][3], 1.0, -1.0, 1148846080)
            NetworkAddEntityToSynchronisedScene(ContainerAnimation['sceneObjects'][1], scene, animDict, ContainerAnimation['animations'][1][4], 1.0, -1.0, 1148846080)
            NetworkAddEntityToSynchronisedScene(ContainerAnimation['sceneObjects'][2], scene, animDict, ContainerAnimation['animations'][1][5], 1.0, -1.0, 1148846080)

            SetEntityCoords(ped, GetEntityCoords(sceneObject))
            NetworkStartSynchronisedScene(scene)
            Wait(4000)
            UseParticleFxAssetNextCall('scr_tn_tr')
            sparks = StartParticleFxLoopedOnEntity("scr_tn_tr_angle_grinder_sparks", ContainerAnimation['sceneObjects'][1], 0.0, 0.25, 0.0, 0.0, 0.0, 0.0, 1.0, false, false, false, 1065353216, 1065353216, 1065353216, 1)
            Wait(1000)
            StopParticleFxLooped(sparks, 1)
            Wait(GetAnimDuration(animDict, 'action') * 1000 - 5000)
            TriggerServerEvent('jomidar-bargheist:sv:containerSync', GetEntityCoords(sceneObject), GetEntityRotation(sceneObject), index)
            TriggerServerEvent('jomidar-bargheist:sv:objectSync', NetworkGetNetworkIdFromEntity(sceneObject))
            TriggerServerEvent('jomidar-bargheist:sv:objectSync', NetworkGetNetworkIdFromEntity(lockObject))
            DeleteObject(ContainerAnimation['sceneObjects'][1])
            DeleteObject(ContainerAnimation['sceneObjects'][2])
            ClearPedTasks(ped)
            if rndContainer == index then
                RemoveBlip(containersBlip)
            end
            exports['qb-target']:AddTargetEntity(weaponBox, {
                options = {
                    { 
                        icon = "fas fa-user-secret",
                        label = "Open Crate",
                        action = function()
                            openCrate()
                        end,
                    },
                    
                },
                distance = 1.4
            })
end



Citizen.CreateThread(function()
    AddRelationshipGroup("GUARDS")
    AddRelationshipGroup("PLAYER")

    SetRelationshipBetweenGroups(5, GetHashKey("GUARDS"), GetHashKey("PLAYER"))
    SetRelationshipBetweenGroups(5, GetHashKey("PLAYER"), GetHashKey("GUARDS"))
end)


Citizen.CreateThread(function()
    while true do
        Wait(1000)
        for i, guard in ipairs(guardPeds) do
            if IsPedDeadOrDying(guard.ped, true) then
                RemoveBlip(guard.blip)
                table.remove(guardPeds, i)
            end
        end
    end
end)


RegisterNetEvent('jomidar-bargheist:cl:containerSync')
AddEventHandler('jomidar-bargheist:cl:containerSync', function(coords, rotation, index)
    animDict = 'anim@scripted@player@mission@tunf_train_ig1_container_p1@male@'
    loadAnimDict(animDict)

    clientContainer[index] = CreateObject(GetHashKey(J0['containers'][index].containerModel), coords, 0, 0, 0)
    clientLock[index] = CreateObject(GetHashKey('tr_prop_tr_lock_01a'), coords, 0, 0, 0)
        
    clientScene = CreateSynchronizedScene(coords, rotation, 2, true, false, 1065353216, 0, 1065353216)
    PlaySynchronizedEntityAnim(clientContainer[index], clientScene, ContainerAnimation['animations'][1][2], animDict, 1.0, -1.0, 0, 1148846080)
    ForceEntityAiAndAnimationUpdate(clientContainer[index])
    PlaySynchronizedEntityAnim(clientLock[index], clientScene, ContainerAnimation['animations'][1][3], animDict, 1.0, -1.0, 0, 1148846080)
    ForceEntityAiAndAnimationUpdate(clientLock[index])

    SetSynchronizedScenePhase(clientScene, 0.99)
    SetEntityCollision(clientContainer[index], false, true)
    FreezeEntityPosition(clientContainer[index], true)
    
end)

RegisterNetEvent('jomidar-bargheist:cl:lockSync')
AddEventHandler('jomidar-bargheist:cl:lockSync', function(index)
    J0['containers'][index]['lock']['taken'] = true
end)

RegisterNetEvent('jomidar-bargheist:cl:objectSync')
AddEventHandler('jomidar-bargheist:cl:objectSync', function(e)
    local entity = NetworkGetEntityFromNetworkId(e)
    DeleteEntity(entity)
    DeleteObject(entity)
end)

function openCrate()
    exports['skillchecks']:startUntangleGame(50000, 5, function(success)
        if success then
                Jomidar.Functions.Progressbar("opencontainer", "Opening the crate...", 7000, false, false, {
                    disableMovement = true,
                    disableCarMovement = false,
                    disableMouse = false,
                    disableCombat = true,
                }, {}, {}, {}, function()
                    exports['jomidar-ui']:Close()
                    exports['qb-target']:RemoveTargetEntity(weaponBox)
                    TriggerServerEvent('jomidar:bargheist:addItem', J0.ContainerItem, J0.ContainerItemAmt)
                end)
        else
            Jomidar.Functions.Notify("You Failed, Try again!", "error")
        end
    end)
end

AddEventHandler('onResourceStop', function (resource)
    if resource == GetCurrentResourceName() then
        for i = 1, #J0['containers'] do
            DeleteEntity(containers[i])
            DeleteEntity(locks[i])
            DeleteEntity(collisions[i])
            exports['qb-target']:RemoveZone("opencontainers"..i)
            J0['containers'][i]['lock']['taken'] = false
            DeleteEntity(clientContainer[i])
            DeleteEntity(clientLock[i])
        end
        exports['qb-target']:RemoveTargetEntity(weaponBox, 'Open Crate')
        DeleteEntity(weaponBox)
        DeleteEntity(barge)
    end
end)