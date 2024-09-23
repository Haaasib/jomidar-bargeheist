J0 = {}

J0.Core = "qb-core"

J0.CoolDown = 3600

J0.CopNeed = 0

J0.RequiredItem = 'sandwich'  --- this is needed to open the container

AlertCops = function()
    exports['ps-dispatch']:SuspiciousActivity()
end
   
J0.BargetLoc = vector3(-130.32041931152344, 3901.027099609375, 30.52471351623535)

J0.BargetRot = vector3(-0.81161403656005, 3.37219333648681, -1.03295457363128)

J0.StartPed = vector4(1347.22, 4391.0, 43.37, 158.61)

J0['containers'] = { --Dont change. Main and required things.
    {
        pos = vector3(245.83, 4008.6, 31.95), 
        heading = 0.0, 
        lock = {pos = vector3(245.84, 4008.53, 32.95), taken = false},
        box = vector4(245.85, 4009.35, 32.15, 182.85),
        containerModel = 'tr_prop_tr_container_01a',
        target = vector3(245.76, 4006.43, 32.95)
        
    },
}

ContainerAnimation = { --Dont change. Main and required things.
    ['objects'] = {
        'tr_prop_tr_grinder_01a',
        'ch_p_m_bag_var02_arm_s'
    },
    ['animations'] = {
        {'action', 'action_container', 'action_lock', 'action_angle_grinder', 'action_bag'}
    },
    ['scenes'] = {},
    ['sceneObjects'] = {}
}

J0.ContainerItem = 'sandwich'
J0.ContainerItemAmt = 1

J0.GuardPeds = { -- guard ped list (you can add new)
    { coords = vector3(250.79, 4013.13, 32.95), heading = 270.87, model = 's_m_y_blackops_01'},
    { coords = vector3(251.74, 4004.46, 32.95), heading = 177.93, model = 's_m_y_blackops_01'},
    { coords = vector3(244.17, 4004.11, 32.95), heading = 354.93, model = 's_m_y_blackops_01'},
    { coords = vector3(240.28, 4012.25, 32.95), heading = 177.88, model = 's_m_y_blackops_01'},
}
