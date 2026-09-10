-- K1NG CUP - Client Side para Sistema de GO

-- Teleportar para Spawner
RegisterNetEvent('K1NG_CUP:TeleportarSpawner')
AddEventHandler('K1NG_CUP:TeleportarSpawner', function(spawner)
    local ped = PlayerPedId()
    
    -- Congelar jogador por um momento
    FreezeEntityPosition(ped, true)
    
    SetEntityCoords(ped, spawner.x, spawner.y, spawner.z, false, false, false, false)
    SetEntityHeading(ped, spawner.heading)
    
    Wait(1000)
    FreezeEntityPosition(ped, false)
    
    TriggerEvent('chat:addMessage', {
        args = {"K1NG CUP", "📍 Você foi spawado em um dos 15 spawners!"},
        color = {0, 255, 0}
    })
end)

-- Dar Armas
RegisterNetEvent('K1NG_CUP:DarArmas')
AddEventHandler('K1NG_CUP:DarArmas', function()
    local ped = PlayerPedId()
    
    GiveWeaponToPed(ped, GetHashKey("weapon_pistol"), 120, false, true)
    GiveWeaponToPed(ped, GetHashKey("weapon_smokegrenade"), 5, false, true)
    GiveWeaponToPed(ped, GetHashKey("weapon_grenade"), 3, false, true)
    
    TriggerEvent('chat:addMessage', {
        args = {"K1NG CUP", "🔫 Armas foram entregues! Boa sorte!"},
        color = {0, 255, 0}
    })
end)

-- Interface para entrar na safe
local SafeAberta = false

function AbrirInterfaceSafe()
    local input = ""
    SafeAberta = true
    
    TriggerEvent('chat:addMessage', {
        args = {"K1NG CUP", "🔐 Você está perto da SAFE! Digite a senha..."},
        color = {255, 215, 0}
    })
    
    -- Simular entrada de senha (usar chat ou NUI)
    -- Para simplificar, usar comando /safe [senha]
end

-- Detectar proximidade da safe (thread)
Citizen.CreateThread(function()
    while true do
        Wait(100)
        
        local ped = PlayerPedId()
        local coords = GetEntityCoords(ped)
        
        -- Coordenadas da safe
        local safeX, safeY, safeZ = 425.5, -982.5, 29.4
        local distancia = #(coords - vector3(safeX, safeY, safeZ))
        
        if distancia < 10.0 then
            -- Desenhar area da safe em vermelho
            DrawMarker(1, safeX, safeY, safeZ, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 5.0, 5.0, 5.0, 255, 0, 0, 100, false, true, 2, false, nil, nil, false)
            
            if distancia < 3.0 then
                TriggerEvent('chat:addMessage', {
                    args = {"K1NG CUP", "💬 Pressione E para entrar na SAFE"},
                    color = {255, 215, 0}
                })
                
                -- Quando pressionar E
                if IsControlJustPressed(0, 38) then -- E
                    TriggerEvent('chat:addMessage', {
                        args = {"K1NG CUP", "Digite a senha com: /safe [senha]"},
                        color = {255, 215, 0}
                    })
                end
            end
        end
    end
end)

-- Desenhar os 15 spawners (para visualização)
Citizen.CreateThread(function()
    while true do
        Wait(500)
        
        local ped = PlayerPedId()
        local playerCoords = GetEntityCoords(ped)
        
        -- Lista de spawners
        local spawners = {
            {x = 400.0, y = -1000.0, z = 29.0},
            {x = 450.0, y = -1000.0, z = 29.0},
            {x = 500.0, y = -1000.0, z = 29.0},
            {x = 550.0, y = -1000.0, z = 29.0},
            {x = 600.0, y = -1000.0, z = 29.0},
            {x = 650.0, y = -1000.0, z = 29.0},
            {x = 700.0, y = -1000.0, z = 29.0},
            {x = 750.0, y = -1000.0, z = 29.0},
            {x = 800.0, y = -1000.0, z = 29.0},
            {x = 850.0, y = -1000.0, z = 29.0},
            {x = 900.0, y = -1000.0, z = 29.0},
            {x = 950.0, y = -1000.0, z = 29.0},
            {x = 1000.0, y = -1000.0, z = 29.0},
            {x = 1050.0, y = -1000.0, z = 29.0},
            {x = 1100.0, y = -1000.0, z = 29.0},
        }
        
        -- Desenhar spawners em amarelo
        for _, spawner in ipairs(spawners) do
            local dist = #(playerCoords - vector3(spawner.x, spawner.y, spawner.z))
            
            if dist < 150.0 then
                DrawMarker(1, spawner.x, spawner.y, spawner.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 2.0, 2.0, 2.0, 255, 255, 0, 100, false, true, 2, false, nil, nil, false)
            end
        end
    end
end)