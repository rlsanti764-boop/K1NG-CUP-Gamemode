-- K1NG CUP - Client completo com Modos, NPCs, Armas e Kit Médico

local MeuDados = {
    id = nil,
    nome = nil,
    time = nil,
    kills = 0,
    mortes = 0,
    vivo = true,
    skin = "a_m_m_business_1",
    roupa = "combat",
    genero = "homem",
    modo = "treino",
    saude = 100
}

local TimesData = {}
local PartidaEmAndamento = false
local NUIAberto = false
local SenhaCorreta = false

-- Pedir Senha ao Conectar
RegisterNetEvent('K1NG_CUP:PedirSenha')
AddEventHandler('K1NG_CUP:PedirSenha', function()
    TriggerEvent('chat:addMessage', {
        args = {"K1NG CUP", "Digite a senha do servidor com /senha [senha]"},
        color = {255, 215, 0}
    })
end)

-- Comando para digitar senha
RegisterCommand('senha', function(source, args, rawCommand)
    if not args[1] then
        TriggerEvent('chat:addMessage', {
            args = {"K1NG CUP", "Use: /senha [senha]"},
            color = {255, 0, 0}
        })
        return
    end
    
    local senhaDigitada = table.concat(args, " ")
    TriggerServerEvent('K1NG_CUP:VerificarSenha', senhaDigitada)
end)

-- Menu de Seleção de Modo
RegisterNetEvent('K1NG_CUP:MenuModos')
AddEventHandler('K1NG_CUP:MenuModos', function()
    TriggerEvent('chat:addMessage', {
        args = {"K1NG CUP", "=== SELECIONE SEU MODO ==="},
        color = {255, 215, 0}
    })
    
    TriggerEvent('chat:addMessage', {
        args = {"", "/modo treino - Treino sem limite de tempo"},
        color = {0, 255, 0}
    })
    
    TriggerEvent('chat:addMessage', {
        args = {"", "/modo competitivo - Modo competitivo com times"},
        color = {0, 255, 0}
    })
    
    TriggerEvent('chat:addMessage', {
        args = {"", "/modo camp - CAMP com objetivos"},
        color = {0, 255, 0}
    })
end)

-- Comando para escolher modo
RegisterCommand('modo', function(source, args, rawCommand)
    if not args[1] then
        TriggerEvent('chat:addMessage', {
            args = {"K1NG CUP", "Use: /modo [treino|competitivo|camp]"},
            color = {255, 0, 0}
        })
        return
    end
    
    local modoEscolhido = args[1]:lower()
    
    if modoEscolhido == "treino" or modoEscolhido == "competitivo" or modoEscolhido == "camp" then
        MeuDados.modo = modoEscolhido
        TriggerServerEvent('K1NG_CUP:EscolherModo', modoEscolhido)
    else
        TriggerEvent('chat:addMessage', {
            args = {"K1NG CUP", "Modo inválido! Use: treino, competitivo ou camp"},
            color = {255, 0, 0}
        })
    end
end)

-- Menu de Seleção de Time
RegisterNetEvent('K1NG_CUP:MenuSelecionarTime')
AddEventHandler('K1NG_CUP:MenuSelecionarTime', function()
    TriggerEvent('chat:addMessage', {
        args = {"K1NG CUP", "=== ESCOLHA SEU TIME ==="},
        color = {255, 215, 0}
    })
    
    for i = 1, 5 do
        TriggerEvent('chat:addMessage', {
            args = {"", "/escolhertime " .. i .. " - " .. Config.Times[i].name},
            color = {0, 255, 0}
        })
    end
end)

-- Comando para entrar em treino
RegisterNetEvent('K1NG_CUP:EntrarTreino')
AddEventHandler('K1NG_CUP:EntrarTreino', function()
    MeuDados.modo = "treino"
    
    TriggerEvent('chat:addMessage', {
        args = {"K1NG CUP", "🎮 Você está em MODO TREINO!"},
        color = {0, 255, 0}
    })
    
    TriggerEvent('chat:addMessage', {
        args = {"K1NG CUP", "Aproveite para treinar! Sem limites de tempo."},
        color = {255, 215, 0}
    })
    
    -- Mostrar NPCs de Armas e Carro
    MostrarNPCs()
end)

-- Comando para entrar em competitivo
RegisterNetEvent('K1NG_CUP:EntrarCompetitivo')
AddEventHandler('K1NG_CUP:EntrarCompetitivo', function()
    MeuDados.modo = "competitivo"
    
    TriggerEvent('chat:addMessage', {
        args = {"K1NG CUP", "⚔️ Você está em MODO COMPETITIVO!"},
        color = {0, 255, 0}
    })
    
    TriggerEvent('chat:addMessage', {
        args = {"K1NG CUP", "Escolha seu time com /escolhertime [1-5]"},
        color = {255, 215, 0}
    })
end)

-- ===== NPCs =====
function MostrarNPCs()
    TriggerEvent('chat:addMessage', {
        args = {"K1NG CUP", "🔫 Vendedor de Armas e 🚗 Vendedor de Carro aguardam!"},
        color = {255, 215, 0}
    })
    
    -- Spawnar NPC de Armas
    SpawnarNPC(Config.NPCArmas.modelo, Config.NPCArmas.coords, Config.NPCArmas.heading, "Vendedor de Armas")
    
    -- Spawnar NPC de Carro
    SpawnarNPC(Config.NPCCarro.modelo, Config.NPCCarro.coords, Config.NPCCarro.heading, "Vendedor de Veículos")
end

function SpawnarNPC(modelo, coords, heading, nome)
    RequestModel(GetHashKey(modelo))
    while not HasModelLoaded(GetHashKey(modelo)) do
        Wait(100)
    end
    
    local npc = CreatePed(4, GetHashKey(modelo), coords.x, coords.y, coords.z, heading, true, false)
    FreezeEntityPosition(npc, true)
    SetBlockingOfNonTemporaryEvents(npc, true)
    
    -- Adicionar blip
    local blip = AddBlipForEntity(npc)
    SetBlipAsNoMission(blip)
    
    ReleaseModel(GetHashKey(modelo))
end

-- ===== ARMAS =====
RegisterCommand('compragarma', function(source, args, rawCommand)
    if not args[1] then
        AbrirMenuArmas()
        return
    end
    
    local armaId = tonumber(args[1])
    if armaId and Config.Armas[armaId] then
        local arma = Config.Armas[armaId]
        GiveWeaponToPed(PlayerPedId(), GetHashKey(arma.hash), arma.municao, false, true)
        
        TriggerEvent('chat:addMessage', {
            args = {"K1NG CUP", "✅ Você recebeu " .. arma.nome .. "!"},
            color = {0, 255, 0}
        })
    end
end)

function AbrirMenuArmas()
    TriggerEvent('chat:addMessage', {
        args = {"K1NG CUP", "=== MENU DE ARMAS ==="},
        color = {255, 215, 0}
    })
    
    for i, arma in ipairs(Config.Armas) do
        TriggerEvent('chat:addMessage', {
            args = {"", i .. " - " .. arma.nome .. " (" .. arma.municao .. " mun)"},
            color = {0, 255, 0}
        })
    end
    
    TriggerEvent('chat:addMessage', {
        args = {"", "Use: /compragarma [número]"},
        color = {255, 215, 0}
    })
end

-- ===== KIT MÉDICO =====
RegisterCommand('kitmedico', function()
    local ped = PlayerPedId()
    local saude = GetEntityHealth(ped)
    
    if saude < 200 then
        TriggerEvent('chat:addMessage', {
            args = {"K1NG CUP", "🏥 Usando kit médico... Aguarde"},
            color = {0, 255, 0}
        })
        
        -- Animação de cura
        RequestAnimDict("amb@medic@standing@kneel@base")
        while not HasAnimDictLoaded("amb@medic@standing@kneel@base") do
            Wait(100)
        end
        
        TaskPlayAnim(ped, "amb@medic@standing@kneel@base", "base", 8.0, -8.0, Config.KitMedico.tempo_cura / 1000, 1, 0, false, false, false)
        
        Wait(Config.KitMedico.tempo_cura)
        
        -- Aumentar saúde gradualmente
        local novasSaude = math.min(saude + (Config.KitMedico.saude_por_uso * 4), 200)
        SetEntityHealth(ped, novasSaude)
        
        TriggerEvent('chat:addMessage', {
            args = {"K1NG CUP", "✅ Saúde recuperada!"},
            color = {0, 255, 0}
        })
        
        ClearPedTasks(ped)
    else
        TriggerEvent('chat:addMessage', {
            args = {"K1NG CUP", "Você não precisa de cura agora!"},
            color = {255, 0, 0}
        })
    end
end)

-- ===== TAB - MOSTRAR COMANDOS =====
Citizen.CreateThread(function()
    while true do
        Wait(0)
        
        if IsControlJustPressed(0, 23) then -- TAB
            AbrirMenuComandos()
        end
    end
end)

function AbrirMenuComandos()
    TriggerEvent('chat:addMessage', {
        args = {"K1NG CUP", "════════════════════════════════════"},
        color = {255, 215, 0}
    })
    
    TriggerEvent('chat:addMessage', {
        args = {"COMANDOS K1NG CUP", ""},
        color = {255, 0, 0}
    })
    
    TriggerEvent('chat:addMessage', {
        args = {"", "/modo [treino|competitivo|camp] - Escolher modo"},
        color = {0, 255, 0}
    })
    
    TriggerEvent('chat:addMessage', {
        args = {"", "/escolhertime [1-5] - Escolher time"},
        color = {0, 255, 0}
    })
    
    TriggerEvent('chat:addMessage', {
        args = {"", "/compragarma - Menu de armas"},
        color = {0, 255, 0}
    })
    
    TriggerEvent('chat:addMessage', {
        args = {"", "/carro - Pegar Coroma blindado"},
        color = {0, 255, 0}
    })
    
    TriggerEvent('chat:addMessage', {
        args = {"", "/kitmedico - Usar kit médico"},
        color = {0, 255, 0}
    })
    
    TriggerEvent('chat:addMessage', {
        args = {"", "/mulher - Mudar para mulher"},
        color = {0, 255, 0}
    })
    
    TriggerEvent('chat:addMessage', {
        args = {"", "/homem - Mudar para homem"},
        color = {0, 255, 0}
    })
    
    TriggerEvent('chat:addMessage', {
        args = {"", "/telagem - Ver stats dos times"},
        color = {0, 255, 0}
    })
    
    TriggerEvent('chat:addMessage', {
        args = {"", "/reviver [ID] - Reviver amigo"},
        color = {0, 255, 0}
    })
    
    if EhAdmin() then
        TriggerEvent('chat:addMessage', {
            args = {"", ""},
            color = {255, 0, 0}
        })
        
        TriggerEvent('chat:addMessage', {
            args = {"COMANDOS ADMIN", ""},
            color = {255, 0, 0}
        })
        
        TriggerEvent('chat:addMessage', {
            args = {"", "/iniciarcamp - Iniciar CAMP"},
            color = {255, 215, 0}
        })
        
        TriggerEvent('chat:addMessage', {
            args = {"", "/go - Iniciar GO com safe"},
            color = {255, 215, 0}
        })
        
        TriggerEvent('chat:addMessage', {
            args = {"", "/ban [ID] [motivo] - Banir jogador"},
            color = {255, 215, 0}
        })
    end
    
    TriggerEvent('chat:addMessage', {
        args = {"K1NG CUP", "════════════════════════════════════"},
        color = {255, 215, 0}
    })
end

-- Comando para pegar Carro Blindado
RegisterCommand('carro', function()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    
    local model = GetHashKey(Config.VeiculoPrincipal)
    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(100)
    end
    
    local veiculo = CreateVehicle(model, coords.x + 5, coords.y, coords.z, 0.0, true, false)
    SetVehicleAsNoLongerNeeded(veiculo)
    ReleaseModel(model)
    
    TriggerEvent('chat:addMessage', {
        args = {"K1NG CUP", "🚗 Coroma blindado foi spawado!"},
        color = {0, 255, 0}
    })
end)

-- Comando Mulher
RegisterCommand('mulher', function()
    MeuDados.genero = "mulher"
    MeuDados.skin = "a_f_m_business_1"
    AlterarSkin("a_f_m_business_1")
    
    TriggerEvent('chat:addMessage', {
        args = {"K1NG CUP", "👩 Você é agora uma mulher!"},
        color = {255, 0, 255}
    })
end)

-- Comando Homem
RegisterCommand('homem', function()
    MeuDados.genero = "homem"
    MeuDados.skin = "a_m_m_business_1"
    AlterarSkin("a_m_m_business_1")
    
    TriggerEvent('chat:addMessage', {
        args = {"K1NG CUP", "👨 Você é agora um homem!"},
        color = {0, 100, 255}
    })
end)

-- Alterar Skin
function AlterarSkin(nomeSkin)
    local ped = PlayerPedId()
    RequestModel(GetHashKey(nomeSkin))
    while not HasModelLoaded(GetHashKey(nomeSkin)) do
        Wait(100)
    end
    SetPlayerModel(PlayerId(), GetHashKey(nomeSkin))
    ReleaseModel(GetHashKey(nomeSkin))
end

-- Comando Telagem
RegisterCommand('telagem', function()
    TriggerServerEvent('K1NG_CUP:PedirTelagem')
end)

-- Atualizar Telagem
RegisterNetEvent('K1NG_CUP:AtualizarTelagem')
AddEventHandler('K1NG_CUP:AtualizarTelagem', function(times)
    TimesData = times
    
    TriggerEvent('chat:addMessage', {
        args = {"K1NG CUP", "=== TELAGEM DE TIMES ==="},
        color = {255, 215, 0}
    })
    
    for i, time in ipairs(times) do
        local kd = time.mortes > 0 and (time.kills / time.mortes) or time.kills
        TriggerEvent('chat:addMessage', {
            args = {Config.Times[i].name, "Kills: " .. time.kills .. " | Mortes: " .. time.mortes .. " | K/D: " .. string.format("%.2f", kd) .. " | Jogadores: " .. #time.jogadores},
            color = {0, 255, 0}
        })
    end
end)

-- Escolher Time
RegisterCommand('escolhertime', function(source, args, rawCommand)
    if not args[1] then
        TriggerEvent('chat:addMessage', {
            args = {"K1NG CUP", "Use: /escolhertime [1-5]"},
            color = {255, 0, 0}
        })
        return
    end
    
    local timeId = tonumber(args[1])
    if timeId and timeId >= 1 and timeId <= 5 then
        TriggerServerEvent('K1NG_CUP:EscolherTime', timeId)
    else
        TriggerEvent('chat:addMessage', {
            args = {"K1NG CUP", "Time deve ser entre 1 e 5!"},
            color = {255, 0, 0}
        })
    end
end)

-- Iniciar CAMP
RegisterCommand('iniciarcamp', function()
    TriggerServerEvent('K1NG_CUP:IniciarCamp')
end)

-- Reviver Amigo
RegisterCommand('reviver', function(source, args, rawCommand)
    if not args[1] then
        TriggerEvent('chat:addMessage', {
            args = {"K1NG CUP", "Use: /reviver [ID]"},
            color = {255, 0, 0}
        })
        return
    end
    
    TriggerServerEvent('K1NG_CUP:RevivarAmigo', tonumber(args[1]))
end)

-- Reviver Jogador
RegisterNetEvent('K1NG_CUP:RevivarJogador')
AddEventHandler('K1NG_CUP:RevivarJogador', function(tempo)
    TriggerEvent('chat:addMessage', {
        args = {"K1NG CUP", "💨 Você será revivido em 3 segundos..."},
        color = {255, 215, 0}
    })
    
    Wait(tempo)
    
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    NetworkResurrectLocalPlayer(coords.x, coords.y, coords.z, GetEntityHeading(ped), true, false)
    
    -- Smoke K1NG CUP
    RequestNamedPtfxAsset("scr_respawn_point")
    while not HasNamedPtfxAssetLoaded("scr_respawn_point") do
        Wait(100)
    end
    
    UseParticleFxAssetNextCall("scr_respawn_point")
    StartParticleFxNonLoopedAtCoord("scr_respawn_point_puff", coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 1.0, false, false, false)
    
    TriggerEvent('chat:addMessage', {
        args = {"K1NG CUP", "K1NG CUP - REVIVIDO!"},
        color = {0, 255, 0}
    })
end)