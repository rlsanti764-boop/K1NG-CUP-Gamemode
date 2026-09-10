-- K1NG CUP - Sistema de GO com Safe e Spawners

local GoAtivo = false
local TimerGO = 0
local JogadoresNaSafe = {}
local SpawnersLocations = {}
local PartidaEmAndamento = false

-- Definir 15 spawners
function DefinirSpawners()
    SpawnersLocations = {
        {x = 400.0, y = -1000.0, z = 29.0, heading = 0.0},
        {x = 450.0, y = -1000.0, z = 29.0, heading = 0.0},
        {x = 500.0, y = -1000.0, z = 29.0, heading = 0.0},
        {x = 550.0, y = -1000.0, z = 29.0, heading = 0.0},
        {x = 600.0, y = -1000.0, z = 29.0, heading = 0.0},
        {x = 650.0, y = -1000.0, z = 29.0, heading = 0.0},
        {x = 700.0, y = -1000.0, z = 29.0, heading = 0.0},
        {x = 750.0, y = -1000.0, z = 29.0, heading = 0.0},
        {x = 800.0, y = -1000.0, z = 29.0, heading = 0.0},
        {x = 850.0, y = -1000.0, z = 29.0, heading = 0.0},
        {x = 900.0, y = -1000.0, z = 29.0, heading = 0.0},
        {x = 950.0, y = -1000.0, z = 29.0, heading = 0.0},
        {x = 1000.0, y = -1000.0, z = 29.0, heading = 0.0},
        {x = 1050.0, y = -1000.0, z = 29.0, heading = 0.0},
        {x = 1100.0, y = -1000.0, z = 29.0, heading = 0.0},
    }
    print("^2[K1NG CUP] 15 Spawners definidos!^7")
end

-- Safe com Senha (Vermelho)
local SafeLocation = {
    x = 425.5,
    y = -982.5,
    z = 29.4,
    heading = 0.0,
    senha = "1234"
}

-- Verificar se jogador está perto da safe
function EstaProximoDaSafe(source)
    if not Jogadores[source] then return false end
    
    local ped = GetPlayerPed(source)
    if ped == 0 then return false end
    
    local coords = GetEntityCoords(ped)
    local distancia = #(coords - vector3(SafeLocation.x, SafeLocation.y, SafeLocation.z))
    
    return distancia < 10.0
end

-- Verificar se está preso no spawner (não saiu da área)
function EstaPreso(source)
    if not Jogadores[source] then return false end
    
    local ped = GetPlayerPed(source)
    if ped == 0 then return false end
    
    local coords = GetEntityCoords(ped)
    
    for _, spawner in ipairs(SpawnersLocations) do
        local dist = #(coords - vector3(spawner.x, spawner.y, spawner.z))
        if dist < 5.0 then
            return true, spawner
        end
    end
    
    return false, nil
end

-- Evento ao entrar na safe
RegisterServerEvent('K1NG_CUP:EntrarNaSafe')
AddEventHandler('K1NG_CUP:EntrarNaSafe', function(senhaDigitada)
    local source = source
    
    if not EstaProximoDaSafe(source) then
        TriggerClientEvent('chat:addMessage', source, {
            args = {"K1NG CUP", "Você não está perto da safe!"},
            color = {255, 0, 0}
        })
        return
    end
    
    if senhaDigitada ~= SafeLocation.senha then
        TriggerClientEvent('chat:addMessage', source, {
            args = {"K1NG CUP", "❌ Senha incorreta!"},
            color = {255, 0, 0}
        })
        return
    end
    
    JogadoresNaSafe[source] = true
    
    TriggerClientEvent('chat:addMessage', source, {
        args = {"K1NG CUP", "✅ Você entrou na SAFE! Aguarde o GO..."},
        color = {0, 255, 0}
    })
    
    -- Broadcast para todos
    TriggerClientEvent('chat:addMessage', -1, {
        args = {"K1NG CUP", "🔓 " .. GetPlayerName(source) .. " entrou na SAFE!"},
        color = {255, 215, 0}
    })
end)

-- Comando GO (Apenas Admin)
RegisterCommand('go', function(source, args, rawCommand)
    if not EhAdmin(source) then
        TriggerClientEvent('chat:addMessage', source, {
            args = {"K1NG CUP", "❌ Você não tem permissão!"},
            color = {255, 0, 0}
        })
        return
    end
    
    if GoAtivo then
        TriggerClientEvent('chat:addMessage', source, {
            args = {"K1NG CUP", "❌ Já há um GO em andamento!"},
            color = {255, 0, 0}
        })
        return
    end
    
    if not PartidaEmAndamento then
        TriggerClientEvent('chat:addMessage', source, {
            args = {"K1NG CUP", "❌ Partida não iniciada! Use /iniciarpartida primeiro"},
            color = {255, 0, 0}
        })
        return
    end
    
    GoAtivo = true
    TimerGO = 30 -- 30 segundos
    JogadoresNaSafe = {}
    
    TriggerClientEvent('chat:addMessage', -1, {
        args = {"K1NG CUP", "🚨 GO INICIADO! Você tem 30 segundos para entrar na SAFE 🚨"},
        color = {255, 0, 0}
    })
    
    TriggerClientEvent('chat:addMessage', -1, {
        args = {"K1NG CUP", "Senha: " .. SafeLocation.senha},
        color = {255, 215, 0}
    })
    
    print("^2[K1NG CUP] GO iniciado por " .. GetPlayerName(source) .. "^7")
end)

-- Thread para gerenciar o timer do GO
Citizen.CreateThread(function()
    while true do
        Wait(1000) -- A cada 1 segundo
        
        if GoAtivo and TimerGO > 0 then
            TimerGO = TimerGO - 1
            
            -- Avisar cada 10 segundos
            if TimerGO == 20 or TimerGO == 10 or TimerGO == 5 then
                TriggerClientEvent('chat:addMessage', -1, {
                    args = {"K1NG CUP", "⏱️ " .. TimerGO .. " segundos restantes!"},
                    color = {255, 255, 0}
                })
            end
            
            -- Avisar os últimos 3 segundos
            if TimerGO <= 3 and TimerGO > 0 then
                TriggerClientEvent('chat:addMessage', -1, {
                    args = {"K1NG CUP", "⏰ " .. TimerGO .. "..."},
                    color = {255, 0, 0}
                })
            end
        elseif GoAtivo and TimerGO == 0 then
            -- Terminou o tempo do GO
            GoAtivo = false
            FinalizarGO()
        end
    end
end)

-- Finalizar GO
function FinalizarGO()
    TriggerClientEvent('chat:addMessage', -1, {
        args = {"K1NG CUP", "🎯 GO FINALIZADO! Contando jogadores que conseguiram..."},
        color = {255, 215, 0}
    })
    
    local jogadoresQueEntraram = 0
    local jogadoresAlvos = {}
    
    for source, _ in pairs(JogadoresNaSafe) do
        jogadoresQueEntraram = jogadoresQueEntraram + 1
        table.insert(jogadoresAlvos, source)
    end
    
    -- Verificar quem ficou preso no spawner
    for source, dados in pairs(Jogadores) do
        if dados then
            local preso, spawner = EstaPreso(source)
            
            if preso and not JogadoresNaSafe[source] then
                TriggerClientEvent('chat:addMessage', -1, {
                    args = {"K1NG CUP", "🚫 " .. GetPlayerName(source) .. " ficou preso no spawner!"},
                    color = {255, 0, 0}
                })
                
                -- Teleportar para outro spawner aleatório
                local spawnerAleatorio = SpawnersLocations[math.random(1, #SpawnersLocations)]
                TriggerClientEvent('K1NG_CUP:TeleportarSpawner', source, spawnerAleatorio)
            end
        end
    end
    
    TriggerClientEvent('chat:addMessage', -1, {
        args = {"K1NG CUP", "✅ " .. jogadoresQueEntraram .. " jogador(es) conseguiram entrar na SAFE!"},
        color = {0, 255, 0}
    })
end

-- Evento ao iniciar a partida (para ativar GO)
RegisterServerEvent('K1NG_CUP:IniciarPartida')
AddEventHandler('K1NG_CUP:IniciarPartida', function()
    local source = source
    
    if not EhAdmin(source) then
        TriggerClientEvent('chat:addMessage', source, {
            args = {"K1NG CUP", "❌ Você não tem permissão!"},
            color = {255, 0, 0}
        })
        return
    end
    
    PartidaEmAndamento = true
    
    -- Spawnar todos os jogadores
    for source, dados in pairs(Jogadores) do
        if dados then
            local spawnerAleatorio = SpawnersLocations[math.random(1, #SpawnersLocations)]
            TriggerClientEvent('K1NG_CUP:TeleportarSpawner', source, spawnerAleatorio)
            
            -- Dar armas
            TriggerClientEvent('K1NG_CUP:DarArmas', source)
        end
    end
    
    TriggerClientEvent('chat:addMessage', -1, {
        args = {"K1NG CUP", "🎮 PARTIDA INICIADA! Você está em um dos 15 spawners"},
        color = {0, 255, 0}
    })
    
    TriggerClientEvent('chat:addMessage', -1, {
        args = {"K1NG CUP", "Use /go (Admin) para iniciar o GO!"},
        color = {255, 215, 0}
    })
end)

-- Comando para entrar na safe
RegisterCommand('safe', function(source, args, rawCommand)
    if not args[1] then
        TriggerClientEvent('chat:addMessage', source, {
            args = {"K1NG CUP", "Use: /safe [senha]"},
            color = {255, 0, 0}
        })
        return
    end
    
    TriggerServerEvent('K1NG_CUP:EntrarNaSafe', args[1])
end)

-- Inicializar
InicializarTimes()
DefinirSpawners()