-- K1NG CUP - Server Bomba/Granada System

-- Evento de dano da bomba
RegisterServerEvent('K1NG_CUP:DanoBomba')
AddEventHandler('K1NG_CUP:DanoBomba', function(coords)
    local source = source
    
    -- Encontrar jogadores perto da explosão
    local players = GetPlayers()
    local raio = 50.0 -- 50 metros
    
    for _, playerId in ipairs(players) do
        local ped = GetPlayerPed(playerId)
        if ped ~= 0 then
            local playerCoords = GetEntityCoords(ped)
            local distancia = #(playerCoords - coords)
            
            if distancia < raio then
                local dano = 50 * (1 - (distancia / raio)) -- Dano diminui com distância
                
                TriggerClientEvent('K1NG_CUP:AplicarDano', playerId, dano)
                
                TriggerEvent('chat:addMessage', {
                    args = {"K1NG CUP", "💥 " .. GetPlayerName(playerId) .. " levou " .. math.floor(dano) .. " de dano!"},
                    color = {255, 0, 0}
                })
            end
        end
    end
end)

-- Receber dano no cliente
RegisterNetEvent('K1NG_CUP:AplicarDano')
AddEventHandler('K1NG_CUP:AplicarDano', function(dano)
    local ped = PlayerPedId()
    local saude = GetEntityHealth(ped)
    
    -- Aplicar dano
    SetEntityHealth(ped, math.max(saude - dano, 0))
    
    -- Efeito visual de sangue
    ShakeGameplayCam(2, 0.5)
    ApplyDamageToPed(ped, dano, false)
    
    TriggerEvent('chat:addMessage', {
        args = {"K1NG CUP", "💢 Você levou " .. math.floor(dano) .. " de dano!"},
        color = {255, 0, 0}
    })
end)