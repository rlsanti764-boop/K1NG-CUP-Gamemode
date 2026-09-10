-- K1NG CUP - Client Side

local MeuDados = {}
local TimesData = {}
local PartidaIniciada = false

-- Menu Principal
RegisterNetEvent('K1NG_CUP:MenuPrincipal')
AddEventHandler('K1NG_CUP:MenuPrincipal', function()
    TriggerEvent('chat:addMessage', {
        args = {"K1NG CUP", "Bem-vindo ao K1NG CUP! Use /escolhertime [1-15] para escolher seu time"},
        color = {0, 255, 0}
    })
    
    TriggerEvent('chat:addMessage', {
        args = {"K1NG CUP", "Comandos: /mulher, /box, /telagem, /reviver [id], /iniciarpartida"},
        color = {0, 255, 0}
    })
end)

-- Iniciar Partida
RegisterNetEvent('K1NG_CUP:IniciarPartida')
AddEventHandler('K1NG_CUP:IniciarPartida', function()
    PartidaIniciada = true
    
    TriggerEvent('chat:addMessage', {
        args = {"K1NG CUP", "PARTIDA INICIADA! Boa Sorte!"},
        color = {255, 255, 0}
    })
    
    -- Dar armas
    GiveWeaponToPed(PlayerPedId(), GetHashKey("weapon_pistol"), 120, false, true)
    GiveWeaponToPed(PlayerPedId(), GetHashKey("weapon_smokegrenade"), 5, false, true)
end)

-- Menu Box (Skins e Armas)
RegisterNetEvent('K1NG_CUP:MenuBox')
AddEventHandler('K1NG_CUP:MenuBox', function()
    local menu = {
        titulo = "K1NG CUP - BOX",
        items = {
            {label = "Skins", value = "skins"},
            {label = "Armas", value = "armas"},
            {label = "Roupas", value = "roupas"}
        }
    }
    
    TriggerEvent('chat:addMessage', {
        args = {"K1NG CUP", "Menu Box aberto! Digite /box"},
        color = {255, 0, 255}
    })
end)

-- Alterar Skin
RegisterNetEvent('K1NG_CUP:AlterarSkin')
AddEventHandler('K1NG_CUP:AlterarSkin', function(nomeSkin)
    local ped = PlayerPedId()
    RequestModel(GetHashKey(nomeSkin))
    while not HasModelLoaded(GetHashKey(nomeSkin)) do
        Wait(100)
    end
    SetPlayerModel(PlayerId(), GetHashKey(nomeSkin))
    ReleaseModel(GetHashKey(nomeSkin))
end)

-- Mostrar Telagem (Tabela de Stats)
RegisterNetEvent('K1NG_CUP:MostrarTelagem')
AddEventHandler('K1NG_CUP:MostrarTelagem', function(times)
    TriggerEvent('chat:addMessage', {
        args = {"K1NG CUP", "=== TELAGEM DE TIMES ==="},
        color = {255, 255, 0}
    })
    
    for timeId, timeData in ipairs(times) do
        TriggerEvent('chat:addMessage', {
            args = {"Time " .. timeId, "Kills: " .. timeData.kills .. " | Mortes: " .. timeData.mortes},
            color = {0, 255, 0}
        })
    end
end)

-- Atualizar Telagem
RegisterNetEvent('K1NG_CUP:AtualizarTelagem')
AddEventHandler('K1NG_CUP:AtualizarTelagem', function(times)
    TimesData = times
end)

-- Reviver Amigo
RegisterNetEvent('K1NG_CUP:Reviver')
AddEventHandler('K1NG_CUP:Reviver', function(tempo)
    local ped = PlayerPedId()
    
    TriggerEvent('chat:addMessage', {
        args = {"K1NG CUP", "Você será revivido em 3 segundos..."},
        color = {255, 255, 0}
    })
    
    Wait(tempo)
    
    -- Reviver
    RevivePlayer(ped)
    
    TriggerEvent('chat:addMessage', {
        args = {"K1NG CUP", "K1NG CUP - Você foi revivido!"},
        color = {0, 255, 0}
    })
end)

-- Função para Reviver
function RevivePlayer(ped)
    local posX, posY, posZ = table.unpack(GetEntityCoords(ped))
    NetworkResurrectLocalPlayer(posX, posY, posZ, GetEntityHeading(ped), true, false)
end

-- Smoke com Efeito K1NG CUP
RegisterNetEvent('K1NG_CUP:FumaçaK1ng')
AddEventHandler('K1NG_CUP:FumaçaK1ng', function()
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    
    RequestNamedPtfxAsset("scr_respawn_point")
    while not HasNamedPtfxAssetLoaded("scr_respawn_point") do
        Wait(100)
    end
    
    UseParticleFxAssetNextCall("scr_respawn_point")
    StartParticleFxNonLoopedAtCoord("scr_respawn_point_puff", coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 1.0, false, false, false)
    
    TriggerEvent('chat:addMessage', {
        args = {"K1NG CUP", "K1NG CUP"},
        color = {255, 0, 0}
    })
end)