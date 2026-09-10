-- K1NG CUP - Sistema de Bomba/Granada com Arma na Mão

local BombaAtiva = false
local BombaEmVoo = false
local BombaEntity = nil
local PosicaoBomba = vector3(0, 0, 0)
local VelocidadeBomba = 0.0

-- Pegar Bomba com G
RegisterCommand('bomba', function()
    local ped = PlayerPedId()
    
    -- Verificar se tem arma na mão
    local currentWeapon = GetSelectedPedWeapon(ped)
    
    if currentWeapon == GetHashKey("weapon_smokegrenade") or 
       currentWeapon == GetHashKey("weapon_grenade") then
        
        TriggerEvent('chat:addMessage', {
            args = {"K1NG CUP", "💣 Segure G para preparar a bomba"},
            color = {255, 215, 0}
        })
        
        BombaAtiva = true
    else
        TriggerEvent('chat:addMessage', {
            args = {"K1NG CUP", "Você precisa ter uma granada na mão!"},
            color = {255, 0, 0}
        })
    end
end)

-- Thread para carregar força ao segurar G
Citizen.CreateThread(function()
    while true do
        Wait(0)
        
        if BombaAtiva and IsControlPressed(0, 47) then -- G
            local ped = PlayerPedId()
            local currentWeapon = GetSelectedPedWeapon(ped)
            
            -- Aumentar velocidade enquanto segura G
            if currentWeapon == GetHashKey("weapon_smokegrenade") or 
               currentWeapon == GetHashKey("weapon_grenade") then
                
                VelocidadeBomba = math.min(VelocidadeBomba + 0.5, 100.0)
                
                -- Mostrar HUD com força
                DrawTxtAdvanced(0.5, 0.9, "~r~FORÇA: " .. math.floor(VelocidadeBomba) .. "%", 0.7, 4)
                
                -- Animação de carregamento
                if not IsEntityPlayingAnim(ped, "combat@damage@rb_writhe", "rb_writhe_loop", 3) then
                    RequestAnimDict("combat@damage@rb_writhe")
                    while not HasAnimDictLoaded("combat@damage@rb_writhe") do
                        Wait(100)
                    end
                    TaskPlayAnim(ped, "combat@damage@rb_writhe", "rb_writhe_loop", 8.0, -8.0, -1, 1, 0, false, false, false)
                end
            end
        elseif BombaAtiva and IsControlJustReleased(0, 47) then -- Soltar G
            if VelocidadeBomba > 0 then
                AtiraçãoBomba(VelocidadeBomba)
                BombaAtiva = false
                VelocidadeBomba = 0.0
            end
        end
    end
end)

-- Função para atirar a bomba
function AtiraçãoBomba(forca)
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    local forward = GetEntityForwardVector(ped)
    
    -- Criar objeto de bomba
    local bombaModel = GetHashKey("prop_bomb_03")
    RequestModel(bombaModel)
    while not HasModelLoaded(bombaModel) do
        Wait(100)
    end
    
    -- Spawnar bomba na frente do jogador
    local bombaX = coords.x + forward.x * 2
    local bombaY = coords.y + forward.y * 2
    local bombaZ = coords.z + 1
    
    BombaEntity = CreateObject(bombaModel, bombaX, bombaY, bombaZ, true, true, true)
    
    -- Dar velocidade à bomba baseado na força
    local velocidadeX = forward.x * (forca / 10)
    local velocidadeY = forward.y * (forca / 10)
    local velocidadeZ = 0.5 * (forca / 50)
    
    ApplyForceToEntity(BombaEntity, 1, velocidadeX, velocidadeY, velocidadeZ, 0.0, 0.0, 0.0, 0, false, true, true, false, true)
    
    BombaEmVoo = true
    ReleaseModel(bombaModel)
    
    TriggerEvent('chat:addMessage', {
        args = {"K1NG CUP", "💥 BOMBA LANÇADA COM FORÇA " .. math.floor(forca) .. "%!"},
        color = {255, 0, 0}
    })
    
    -- Timer para detonação (3 segundos)
    SetTimeout(3000, function()
        if DoesEntityExist(BombaEntity) then
            DetonarBomba()
        end
    end)
end

-- Função para detonar a bomba
function DetonarBomba()
    if not DoesEntityExist(BombaEntity) then return end
    
    local coords = GetEntityCoords(BombaEntity)
    
    -- Efeito de explosão
    SmashVehicleWindow(BombaEntity, 0)
    SmashVehicleWindow(BombaEntity, 1)
    
    -- Criar explosão visual
    AddExplosion(coords.x, coords.y, coords.z, 5, 1000.0, true, false, 1.0)
    
    -- Som de explosão
    PlaySoundFrontend(-1, "CONFIRM_BEEP", "HUD_MINI_GAME_SOUNDSET", true)
    
    -- Efeito de partícula
    RequestNamedPtfxAsset("scr_ornate_heist")
    while not HasNamedPtfxAssetLoaded("scr_ornate_heist") do
        Wait(100)
    end
    
    UseParticleFxAssetNextCall("scr_ornate_heist")
    StartParticleFxNonLoopedAtCoord("scr_heist_ornate_bomb_exp", coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 1.0, false, false, false)
    
    -- Remover bomba
    DeleteEntity(BombaEntity)
    BombaEmVoo = false
    BombaEntity = nil
    
    TriggerEvent('chat:addMessage', {
        args = {"K1NG CUP", "💥 EXPLOSÃO DETONADA!"},
        color = {255, 0, 0}
    })
    
    -- Trigger server para dano
    TriggerServerEvent('K1NG_CUP:DanoBomba', coords)
end

-- Função para desenhar texto (HUD)
function DrawTxtAdvanced(x, y, text, scale, font)
    BeginTextCommandDisplayText("STRING")
    AddTextComponentString(text)
    SetTextFont(font)
    SetTextScale(scale, scale)
    SetTextColour(255, 0, 0, 255)
    EndTextCommandDisplayText(x, y)
end

-- Atualizar posição da bomba em tempo real
Citizen.CreateThread(function()
    while true do
        Wait(100)
        
        if BombaEmVoo and DoesEntityExist(BombaEntity) then
            PosicaoBomba = GetEntityCoords(BombaEntity)
            
            -- Verificar colisão com objetos/jogadores
            if GetEntityVelocity(BombaEntity) ~= vector3(0, 0, 0) then
                -- Se parou de se mover, detonar
                local vel = GetEntitySpeed(BombaEntity)
                if vel < 0.5 then
                    Wait(500)
                    if DoesEntityExist(BombaEntity) then
                        DetonarBomba()
                    end
                end
            end
        end
    end
end)

-- Ricochete de superfícies (efeito físico)
Citizen.CreateThread(function()
    while true do
        Wait(50)
        
        if BombaEmVoo and DoesEntityExist(BombaEntity) then
            local coords = GetEntityCoords(BombaEntity)
            
            -- Verificar se está no chão
            local raycast = StartShapeTestRay(coords.x, coords.y, coords.z, coords.x, coords.y, coords.z - 1.0, 1, PlayerPedId(), 7)
            local hit, endCoords, surfaceNormal, entityHit = GetShapeTestResult(raycast)
            
            if hit ~= 0 then
                -- Fazer som de ricochetear
                PlaySoundFrontend(-1, "CONFIRM_BEEP", "HUD_MINI_GAME_SOUNDSET", true)
            end
        end
    end
end)