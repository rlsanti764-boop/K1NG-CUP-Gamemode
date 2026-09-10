-- K1NG CUP - Client Admin Commands (Teleporte e Freeze)

-- Evento para teleportar jogador
RegisterNetEvent('K1NG_CUP:TeleportarPara')
AddEventHandler('K1NG_CUP:TeleportarPara', function(coords)
    local ped = PlayerPedId()
    
    -- Teleportar
    SetEntityCoords(ped, coords.x, coords.y, coords.z, false, false, false, false)
    
    -- Efeito visual
    RequestNamedPtfxAsset("scr_respawn_point")
    while not HasNamedPtfxAssetLoaded("scr_respawn_point") do
        Wait(100)
    end
    
    UseParticleFxAssetNextCall("scr_respawn_point")
    StartParticleFxNonLoopedAtCoord("scr_respawn_point_puff", coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 1.0, false, false, false)
    
    TriggerEvent('chat:addMessage', {
        args = {"K1NG CUP", "🚀 Você foi teleportado!"},
        color = {0, 255, 0}
    })
end)

-- Evento para congelar/descongelar jogador
RegisterNetEvent('K1NG_CUP:CongelarJogador')
AddEventHandler('K1NG_CUP:CongelarJogador', function(congelar)
    local ped = PlayerPedId()
    
    if congelar then
        FreezeEntityPosition(ped, true)
        
        TriggerEvent('chat:addMessage', {
            args = {"K1NG CUP", "❄️ Você foi congelado!"},
            color = {0, 255, 255}
        })
    else
        FreezeEntityPosition(ped, false)
        
        TriggerEvent('chat:addMessage', {
            args = {"K1NG CUP", "🔥 Você foi descongelado!"},
            color = {0, 255, 0}
        })
    end
end)