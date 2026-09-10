-- K1NG CUP - Server Side com Sistema de Ban e Admin

local Times = {}
local Jogadores = {}
local PartidaIniciada = false

-- Arquivo de Bans (simulado em memória)
local BanList = {
    -- ["steam:1234567890"] = {motivo = "Hack", data = "2026-09-10"},
}

-- Arquivo de Admins (você define quem é admin)
local Admins = {
    -- "steam:seusteamid" = true,
}

-- Inicializar Times
function InicializarTimes()
    for i = 1, 15 do
        Times[i] = {
            id = i,
            nome = "Time " .. i,
            jogadores = {},
            kills = 0,
            mortes = 0,
            cor = {255, 0, 0}
        }
    end
    print("^2[K1NG CUP] Times inicializados!^7")
end

-- Verificar se jogador está banido
function Estabanido(source)
    local identifiers = GetPlayerIdentifiers(source)
    
    for _, id in ipairs(identifiers) do
        if BanList[id] then
            return true, BanList[id]
        end
    end
    
    return false, nil
end

-- Verificar se é admin
function EhAdmin(source)
    local identifiers = GetPlayerIdentifiers(source)
    
    for _, id in ipairs(identifiers) do
        if Admins[id] then
            return true
        end
    end
    
    return false
end

-- Evento de Join do Jogador
AddEventHandler('playerConnecting', function(name, setKickReason, deferrals)
    deferrals.defer()
    
    local source = source
    local ehBanido, infoBan = Estabanido(source)
    
    if ehBanido then
        deferrals.done("❌ Você foi banido do servidor K1NG CUP!\n\nMotivo: " .. infoBan.motivo .. "\nData: " .. infoBan.data)
        return
    end
    
    deferrals.done()
end)

AddEventHandler('playerSpawned', function()
    local source = source
    
    Jogadores[source] = {
        id = source,
        nome = GetPlayerName(source),
        time = nil,
        kills = 0,
        mortes = 0,
        vivo = true,
        skin = "a_m_m_business_1",
        roupa = "combat",
        genero = "homem",
        suspeitas = 0
    }
    
    print("^3[K1NG CUP] Jogador " .. Jogadores[source].nome .. " entrou! (ID: " .. source .. ")^7")
end)

AddEventHandler('playerDropped', function()
    local source = source
    
    if Jogadores[source] and Jogadores[source].time then
        local timeId = Jogadores[source].time
        
        -- Remover de Times
        for i, jogadorId in ipairs(Times[timeId].jogadores) do
            if jogadorId == source then
                table.remove(Times[timeId].jogadores, i)
                break
            end
        end
    end
    
    Jogadores[source] = nil
    print("^1[K1NG CUP] Jogador desconectado (ID: " .. source .. ")^7")
end)

-- Comando Escolher Time
RegisterServerEvent('K1NG_CUP:EscolherTime')
AddEventHandler('K1NG_CUP:EscolherTime', function(timeId)
    local source = source
    
    if not timeId or timeId < 1 or timeId > 15 then
        TriggerClientEvent('chat:addMessage', source, {
            args = {"K1NG CUP", "Time inválido! Use /escolhertime [1-15]"},
            color = {255, 0, 0}
        })
        return
    end
    
    Jogadores[source].time = timeId
    table.insert(Times[timeId].jogadores, source)
    
    TriggerClientEvent('chat:addMessage', source, {
        args = {"K1NG CUP", "✅ Você entrou no TIME " .. timeId},
        color = {0, 255, 0}
    })
    
    TriggerClientEvent('K1NG_CUP:AtualizarTelagem', -1, Times)
end)

-- Comando Iniciar Partida
RegisterCommand('iniciarpartida', function(source, args, rawCommand)
    if not EhAdmin(source) then
        TriggerClientEvent('chat:addMessage', source, {
            args = {"K1NG CUP", "❌ Você não tem permissão!"},
            color = {255, 0, 0}
        })
        return
    end
    
    if PartidaIniciada then
        TriggerClientEvent('chat:addMessage', source, {
            args = {"K1NG CUP", "Partida já foi iniciada!"},
            color = {255, 0, 0}
        })
        return
    end
    
    PartidaIniciada = true
    TriggerClientEvent('K1NG_CUP:IniciarPartida', -1)
    print("^2[K1NG CUP] Partida iniciada por " .. GetPlayerName(source) .. "^7")
end)

-- Comando de Ban (Apenas Admin)
RegisterCommand('ban', function(source, args, rawCommand)
    if not EhAdmin(source) then
        TriggerClientEvent('chat:addMessage', source, {
            args = {"K1NG CUP", "❌ Você não tem permissão!"},
            color = {255, 0, 0}
        })
        return
    end
    
    local playerId = tonumber(args[1])
    local motivo = args[2] or "Sem motivo especificado"
    
    if not playerId then
        TriggerClientEvent('chat:addMessage', source, {
            args = {"K1NG CUP", "Use: /ban [ID] [motivo]"},
            color = {255, 0, 0}
        })
        return
    end
    
    if not GetPlayerName(playerId) then
        TriggerClientEvent('chat:addMessage', source, {
            args = {"K1NG CUP", "Jogador não encontrado!"},
            color = {255, 0, 0}
        })
        return
    end
    
    -- Adicionar à lista de bans
    local identifiers = GetPlayerIdentifiers(playerId)
    for _, id in ipairs(identifiers) do
        BanList[id] = {
            motivo = motivo,
            data = os.date("%Y-%m-%d %H:%M:%S"),
            banidoPor = GetPlayerName(source)
        }
    end
    
    -- Avisar e kickar jogador
    TriggerClientEvent('chat:addMessage', -1, {
        args = {"K1NG CUP", "🚫 " .. GetPlayerName(playerId) .. " foi banido! Motivo: " .. motivo},
        color = {255, 0, 0}
    })
    
    DropPlayer(playerId, "Você foi banido: " .. motivo)
    print("^1[K1NG CUP] Ban executado: " .. GetPlayerName(playerId) .. " - Motivo: " .. motivo .. "^7")
end)

-- Comando de Unban (Apenas Admin)
RegisterCommand('unban', function(source, args, rawCommand)
    if not EhAdmin(source) then
        TriggerClientEvent('chat:addMessage', source, {
            args = {"K1NG CUP", "❌ Você não tem permissão!"},
            color = {255, 0, 0}
        })
        return
    end
    
    local steamId = args[1]
    
    if not steamId then
        TriggerClientEvent('chat:addMessage', source, {
            args = {"K1NG CUP", "Use: /unban [steam:id]"},
            color = {255, 0, 0}
        })
        return
    end
    
    if BanList[steamId] then
        BanList[steamId] = nil
        TriggerClientEvent('chat:addMessage', -1, {
            args = {"K1NG CUP", "✅ " .. steamId .. " foi desbanido!"},
            color = {0, 255, 0}
        })
        print("^2[K1NG CUP] Unban executado: " .. steamId .. "^7")
    else
        TriggerClientEvent('chat:addMessage', source, {
            args = {"K1NG CUP", "❌ Este jogador não está banido!"},
            color = {255, 0, 0}
        })
    end
end)

-- Comando de Listar Bans
RegisterCommand('banlist', function(source, args, rawCommand)
    if not EhAdmin(source) then
        TriggerClientEvent('chat:addMessage', source, {
            args = {"K1NG CUP", "❌ Você não tem permissão!"},
            color = {255, 0, 0}
        })
        return
    end
    
    TriggerClientEvent('chat:addMessage', source, {
        args = {"K1NG CUP", "=== LISTA DE BANS ==="},
        color = {255, 215, 0}
    })
    
    local count = 0
    for steamId, info in pairs(BanList) do
        TriggerClientEvent('chat:addMessage', source, {
            args = {steamId, "Motivo: " .. info.motivo .. " | Data: " .. info.data},
            color = {255, 0, 0}
        })
        count = count + 1
    end
    
    if count == 0 then
        TriggerClientEvent('chat:addMessage', source, {
            args = {"K1NG CUP", "Nenhum jogador banido."},
            color = {0, 255, 0}
        })
    end
end)

-- Evento de Morte
RegisterServerEvent('K1NG_CUP:RegistrarMorte')
AddEventHandler('K1NG_CUP:RegistrarMorte', function()
    local source = source
    if Jogadores[source] then
        Jogadores[source].mortes = Jogadores[source].mortes + 1
    end
end)

-- Telagem
RegisterServerEvent('K1NG_CUP:PedirTelagem')
AddEventHandler('K1NG_CUP:PedirTelagem', function()
    local source = source
    TriggerClientEvent('K1NG_CUP:AtualizarTelagem', source, Times)
end)

-- Reviver Amigo
RegisterServerEvent('K1NG_CUP:RevivarAmigo')
AddEventHandler('K1NG_CUP:RevivarAmigo', function(alvoId)
    local source = source
    
    if not Jogadores[source] or not Jogadores[alvoId] then
        TriggerClientEvent('chat:addMessage', source, {
            args = {"K1NG CUP", "Jogador não encontrado!"},
            color = {255, 0, 0}
        })
        return
    end
    
    if Jogadores[source].time ~= Jogadores[alvoId].time then
        TriggerClientEvent('chat:addMessage', source, {
            args = {"K1NG CUP", "Você só pode reviver amigos do mesmo time!"},
            color = {255, 0, 0}
        })
        return
    end
    
    TriggerClientEvent('K1NG_CUP:RevivarJogador', alvoId, 3000)
end)

-- Alterar Roupa
RegisterServerEvent('K1NG_CUP:AlterarRoupa')
AddEventHandler('K1NG_CUP:AlterarRoupa', function(roupa)
    local source = source
    if Jogadores[source] then
        Jogadores[source].roupa = roupa
    end
end)

-- Anti-Cheat - Registrar suspeitas
RegisterServerEvent('K1NG_CUP:SuspeitaSpeedhack')
AddEventHandler('K1NG_CUP:SuspeitaSpeedhack', function(velocidade)
    local source = source
    
    if Jogadores[source] then
        Jogadores[source].suspeitas = Jogadores[source].suspeitas + 1
        
        print("^3[K1NG CUP] ⚠️ Suspeita de Speedhack: " .. GetPlayerName(source) .. " (Velocidade: " .. velocidade .. ") - Suspeitas: " .. Jogadores[source].suspeitas .. "^7")
        
        if Jogadores[source].suspeitas >= 5 then
            print("^1[K1NG CUP] Ban automático por muitas suspeitas: " .. GetPlayerName(source) .. "^7")
            DropPlayer(source, "Você foi banido por violação do anti-cheat")
        end
    end
end)

RegisterServerEvent('K1NG_CUP:SuspeitaWallhack')
AddEventHandler('K1NG_CUP:SuspeitaWallhack', function(altura)
    local source = source
    
    if Jogadores[source] then
        Jogadores[source].suspeitas = Jogadores[source].suspeitas + 2
        print("^3[K1NG CUP] ⚠️ Suspeita de Wallhack/God Mode: " .. GetPlayerName(source) .. " (Altura: " .. altura .. ")^7")
    end
end)

-- Inicializar
InicializarTimes()