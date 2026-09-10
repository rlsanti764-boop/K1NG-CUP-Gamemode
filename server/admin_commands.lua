-- K1NG CUP - Comandos Admin Avançados (NC = Night Commander)

-- Comando /nc tpto [id] - Teleportar jogador específico
RegisterCommand('nc', function(source, args, rawCommand)
    if not EhAdmin(source) then
        TriggerClientEvent('chat:addMessage', source, {
            args = {"K1NG CUP", "❌ Você não tem permissão!"},
            color = {255, 0, 0}
        })
        return
    end
    
    local subcomando = args[1]
    
    if subcomando == "tpto" then
        if not args[2] then
            TriggerClientEvent('chat:addMessage', source, {
                args = {"K1NG CUP", "Use: /nc tpto [ID]"},
                color = {255, 0, 0}
            })
            return
        end
        
        local playerId = tonumber(args[2])
        
        if not GetPlayerName(playerId) then
            TriggerClientEvent('chat:addMessage', source, {
                args = {"K1NG CUP", "Jogador não encontrado!"},
                color = {255, 0, 0}
            })
            return
        end
        
        -- Pegar coordenadas do admin
        local adminPed = GetPlayerPed(source)
        if adminPed == 0 then return end
        
        local coords = GetEntityCoords(adminPed)
        
        -- Teleportar jogador para o admin
        TriggerClientEvent('K1NG_CUP:TeleportarPara', playerId, coords)
        
        TriggerClientEvent('chat:addMessage', -1, {
            args = {"K1NG CUP", "🚀 " .. GetPlayerName(playerId) .. " foi teleportado para " .. GetPlayerName(source)},
            color = {0, 255, 0}
        })
        
        print("^2[K1NG CUP] " .. GetPlayerName(source) .. " teleportou " .. GetPlayerName(playerId) .. "^7")
    
    elseif subcomando == "tptodos" then
        -- Pegar coordenadas do admin
        local adminPed = GetPlayerPed(source)
        if adminPed == 0 then return end
        
        local coords = GetEntityCoords(adminPed)
        local adminName = GetPlayerName(source)
        
        -- Teleportar TODOS os jogadores
        local players = GetPlayers()
        
        for _, playerId in ipairs(players) do
            if playerId ~= source then -- Não teleporta o admin
                TriggerClientEvent('K1NG_CUP:TeleportarPara', playerId, coords)
            end
        end
        
        TriggerClientEvent('chat:addMessage', -1, {
            args = {"K1NG CUP", "🚀 TODOS OS JOGADORES FORAM TELEPORTADOS PARA " .. adminName:upper() .. "!"},
            color = {255, 215, 0}
        })
        
        print("^2[K1NG CUP] " .. adminName .. " teleportou TODOS os jogadores!^7")
    
    elseif subcomando == "help" then
        TriggerClientEvent('chat:addMessage', source, {
            args = {"K1NG CUP NC HELP", ""},
            color = {255, 215, 0}
        })
        
        TriggerClientEvent('chat:addMessage', source, {
            args = {"", "/nc tpto [ID] - Teleportar jogador para você"},
            color = {0, 255, 0}
        })
        
        TriggerClientEvent('chat:addMessage', source, {
            args = {"", "/nc tptodos - Teleportar TODOS para você"},
            color = {0, 255, 0}
        })
        
        TriggerClientEvent('chat:addMessage', source, {
            args = {"", "/nc kick [ID] [motivo] - Kickar jogador"},
            color = {0, 255, 0}
        })
        
        TriggerClientEvent('chat:addMessage', source, {
            args = {"", "/nc freeze [ID] - Congelar jogador"},
            color = {0, 255, 0}
        })
        
        TriggerClientEvent('chat:addMessage', source, {
            args = {"", "/nc unfreeze [ID] - Descongelar jogador"},
            color = {0, 255, 0}
        })
    
    elseif subcomando == "kick" then
        if not args[2] then
            TriggerClientEvent('chat:addMessage', source, {
                args = {"K1NG CUP", "Use: /nc kick [ID] [motivo]"},
                color = {255, 0, 0}
            })
            return
        end
        
        local playerId = tonumber(args[2])
        local motivo = args[3] or "Sem motivo"
        
        if not GetPlayerName(playerId) then
            TriggerClientEvent('chat:addMessage', source, {
                args = {"K1NG CUP", "Jogador não encontrado!"},
                color = {255, 0, 0}
            })
            return
        end
        
        DropPlayer(playerId, "Você foi kickado: " .. motivo)
        
        TriggerClientEvent('chat:addMessage', -1, {
            args = {"K1NG CUP", "🚫 " .. GetPlayerName(playerId) .. " foi kickado! Motivo: " .. motivo},
            color = {255, 0, 0}
        })
    
    elseif subcomando == "freeze" then
        if not args[2] then
            TriggerClientEvent('chat:addMessage', source, {
                args = {"K1NG CUP", "Use: /nc freeze [ID]"},
                color = {255, 0, 0}
            })
            return
        end
        
        local playerId = tonumber(args[2])
        
        if not GetPlayerName(playerId) then
            TriggerClientEvent('chat:addMessage', source, {
                args = {"K1NG CUP", "Jogador não encontrado!"},
                color = {255, 0, 0}
            })
            return
        end
        
        TriggerClientEvent('K1NG_CUP:CongelarJogador', playerId, true)
        
        TriggerClientEvent('chat:addMessage', -1, {
            args = {"K1NG CUP", "❄️ " .. GetPlayerName(playerId) .. " foi congelado!"},
            color = {0, 255, 255}
        })
    
    elseif subcomando == "unfreeze" then
        if not args[2] then
            TriggerClientEvent('chat:addMessage', source, {
                args = {"K1NG CUP", "Use: /nc unfreeze [ID]"},
                color = {255, 0, 0}
            })
            return
        end
        
        local playerId = tonumber(args[2])
        
        if not GetPlayerName(playerId) then
            TriggerClientEvent('chat:addMessage', source, {
                args = {"K1NG CUP", "Jogador não encontrado!"},
                color = {255, 0, 0}
            })
            return
        end
        
        TriggerClientEvent('K1NG_CUP:CongelarJogador', playerId, false)
        
        TriggerClientEvent('chat:addMessage', -1, {
            args = {"K1NG CUP", "🔥 " .. GetPlayerName(playerId) .. " foi descongelado!"},
            color = {0, 255, 0}
        })
    
    else
        TriggerClientEvent('chat:addMessage', source, {
            args = {"K1NG CUP", "Use: /nc help para ver todos os comandos"},
            color = {255, 0, 0}
        })
    end
end)