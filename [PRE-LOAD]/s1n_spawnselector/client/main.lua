--
-- Initialize the script
--

local CURRENT_RESOURCE_NAME = GetCurrentResourceName()

--
-- Frameworks
--

local FRAMEWORK_NAME = Config.framework.name

local esxPlayerData
local newCharacter

local TriggerCallback

if FRAMEWORK_NAME == "qb-core" then
    QBCore = exports[Config.framework.resourceNames.qbCore]:GetCoreObject()

    if not QBCore then
        return Debug("QBCore not found, please make sure that qb-core resource is exactly named 'qb-core' and is started before this resource.")
    end

    TriggerCallback = QBCore.Functions.TriggerCallback
elseif FRAMEWORK_NAME == "esx-old" then
    ESX = nil

    TriggerEvent(Config.framework.triggers.esxSharedObject, function(obj) ESX = obj end)

    if not ESX then
        return Debug("ESX (Old version with TriggerEvent) not found, please make sure that es_extended resource is exactly named 'es_extended' and is started before this resource.")
    end

    TriggerCallback = ESX.TriggerServerCallback
elseif FRAMEWORK_NAME == "esx-legacy" then
    ESX = exports[Config.framework.resourceNames.esx]:getSharedObject()

    if not ESX then
        return Debug("ESX Legacy not found, please make sure that es_extended resource is exactly named 'es_extended' and is started before this resource.")
    end

    TriggerCallback = ESX.TriggerServerCallback
else
    return Debug("Unknown framework, please use 'qbcore', 'esx-old' or 'esx-legacy' as framework name in the config file.")
end

--
-- Business logic
--

local function toggleNuiFrame(shouldShow)
    SetNuiFocus(shouldShow, shouldShow)
    SendReactMessage('setVisible', shouldShow)
end

RegisterNetEvent('s1n_spawnselector:openUI')
AddEventHandler('s1n_spawnselector:openUI', function()
    if ESX then
        if not esxPlayerData then
            esxPlayerData = ESX.GetPlayerData()
        end
    end

    SendReactMessage('setSpawns', Config)
    toggleNuiFrame(true)
end)



RegisterNetEvent('qb-spawn:client:setupSpawns', function(cData, new, apps)
    if new then newCharacter = true end
end)

-- Show the camera animation and spawn the player
local function startAnimation(spawnPosition, spawnHeading)
    local cam = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", spawnPosition.x, spawnPosition.y, spawnPosition.z + 800.0, -85.00, 0.00, 0.00, 100.00, false, 0)

    SetEntityCoords(PlayerPedId(), spawnPosition.x, spawnPosition.y, spawnPosition.z - 0.98)
    SetEntityHeading(PlayerPedId(), spawnHeading)

    DoScreenFadeIn(500)
    SetCamActive(cam, true)
    RenderScriptCams(true, false, 1, true, true)

    FreezeEntityPosition(PlayerPedId(), true)

    Wait(500)

    SetCamParams(cam, spawnPosition.x, spawnPosition.y, spawnPosition.z + 4.2, -85.00, 0.00, 0.00, 50.00, 2000, 0, 0, 2)

    Wait(2000)

    SetFocusPosAndVel(spawnPosition.x, spawnPosition.y, spawnPosition.z)
    RequestCollisionAtCoord(spawnPosition.x, spawnPosition.y, spawnPosition.z)
    SetEntityCoords(PlayerPedId(), spawnPosition.x, spawnPosition.y, spawnPosition.z - 0.9)
    SetEntityHeading(PlayerPedId(), spawnHeading)
    SetFocusEntity(PlayerPedId())
    SetCamParams(cam, spawnPosition.x + 0.5, spawnPosition.y - 7, spawnPosition.z, 0.00, 0.00, 0.00, 20.00, 1000, 0, 0, 2)

    Wait(2000)

    RenderScriptCams(false, true, 3000, true, true)

    while not HasCollisionLoadedAroundEntity(PlayerPedId()) do
        Wait(1)
    end

    FreezeEntityPosition(PlayerPedId(), false)

    Wait(3000)

    if DoesCamExist(cam) then
        SetCamActive(cam, false)
    end
end


-- Handle the player's spawn to his last location
local function spawnLastLocation()
    if FRAMEWORK_NAME == "qb-core" then
        local playerData = QBCore.Functions.GetPlayerData()
        local insideMeta = playerData.metadata["inside"]

        startAnimation(playerData.position, playerData.position.a)

        if insideMeta.house ~= nil then
            local houseId = insideMeta.house
            TriggerEvent('qb-houses:client:LastLocationHouse', houseId)
        elseif insideMeta.apartment.apartmentType ~= nil or insideMeta.apartment.apartmentId ~= nil then
            local apartmentType = insideMeta.apartment.apartmentType
            local apartmentId = insideMeta.apartment.apartmentId
            TriggerEvent('qb-apartments:client:LastLocationHouse', apartmentType, apartmentId)
        end

        TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
        TriggerEvent('QBCore:Client:OnPlayerLoaded')
        SetEntityVisible(PlayerPedId(), true)
        TriggerServerEvent(CURRENT_RESOURCE_NAME .. ":logDiscord", "Player " .. playerData.name and playerData.name .. " spawned at last location")

    elseif FRAMEWORK_NAME == "esx-old" or FRAMEWORK_NAME == "esx-legacy" then
        startAnimation(esxPlayerData.coords, esxPlayerData.coords.w or 180)

        TriggerServerEvent('esx:onPlayerSpawn')
        TriggerEvent('esx:onPlayerSpawn')
        TriggerEvent('playerSpawned')
        TriggerEvent('esx:restoreLoadout')
        TriggerServerEvent(CURRENT_RESOURCE_NAME .. ":logDiscord", "Player " .. esxPlayerData.firstName .. " " .. esxPlayerData.lastName .. " spawned at last location")
    end

end

-- Handle setting the player's skin (model / clothes)
local function setPlayerAppearance(playerCitizenID)
    local illeniumAppearanceScriptName = Config.supportedScripts.illeniumAppearance
    local fivemAppearanceScriptName = Config.supportedScripts.fivemAppearance

    if FRAMEWORK_NAME == "qb-core" then
        QBCore.Functions.TriggerCallback('qb-multicharacter:server:getSkin', function(model, data)
            model = model ~= nil and tonumber(model) or false
            if not model then return Debug("ERROR: Couldn't find player's model") end

            -- Check if the script is loaded and if it has the function setPlayerAppearance(ped, skinData)
            if GetResourceState(illeniumAppearanceScriptName):find('start') then
                data = json.decode(data)

                exports[illeniumAppearanceScriptName]:setPlayerAppearance(data)
            elseif GetResourceState(fivemAppearanceScriptName):find('start') then
                data = json.decode(data)

                exports[fivemAppearanceScriptName]:setPlayerAppearance(data)
            else
                TriggerEvent("qb-clothes:loadSkin", false, model, data)
            end
        end, playerCitizenID)
    elseif FRAMEWORK_NAME == "esx-old" or FRAMEWORK_NAME == "esx-legacy" then
        TriggerEvent("skinchanger:getSkin", function(data)
            -- Check if the script is loaded and if it has the function setPlayerAppearance(ped, skinData)
            if GetResourceState(illeniumAppearanceScriptName):find('start') then
                exports[illeniumAppearanceScriptName]:setPlayerAppearance(data)
            elseif GetResourceState(fivemAppearanceScriptName):find('start') then
                exports[fivemAppearanceScriptName]:setPlayerAppearance(data)
            else
                TriggerEvent("skinchanger:loadSkin", data)
            end
        end)
    end
end

local playerSpawned

-- Handle NUI spawnPlayer callback
local function handleSpawnPlayer(data, cb)
    local location = data.location
    local playerData

    if Config.showSpawnSelectorOnce and playerSpawned then return end


    if Config.showSpawnSelectorOnce and not playerSpawned then
        playerSpawned = true
    end

    if newCharacter then
        TriggerServerEvent("apartments:server:CreateApartment", "apartment1", "South Rockford Drive")
        TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
        TriggerEvent('QBCore:Client:OnPlayerLoaded')

        DestroyAllCams(true)
        FreezeEntityPosition(PlayerPedId(), false)
        SetGameplayCamRelativeHeading(0)
        RenderScriptCams(false, true, 1000, true, true)
        cb('ok')
        return
    end

    if FRAMEWORK_NAME == "qb-core" then
        playerData = QBCore.Functions.GetPlayerData()

        setPlayerAppearance(playerData.citizenid)
    elseif FRAMEWORK_NAME == "esx-old" or FRAMEWORK_NAME == "esx-legacy" then
        setPlayerAppearance()
    end



    if location == -1 then
        cb('ok')
        spawnLastLocation()
    else
        cb('ok')

        startAnimation(Config.spawns[location].location, Config.spawns[location].heading)

        if FRAMEWORK_NAME == "qb-core" then
            TriggerServerEvent('qb-houses:server:SetInsideMeta', 0, false)
            TriggerServerEvent('qb-apartments:server:SetInsideMeta', 0, 0, false)
            TriggerServerEvent('QBCore:Server:OnPlayerLoaded')
            TriggerEvent('QBCore:Client:OnPlayerLoaded')
            TriggerServerEvent(CURRENT_RESOURCE_NAME .. ":logDiscord", "Player "  .. playerData.name .. " spawned at location " .. Config.spawns[location].locationName)
        elseif FRAMEWORK_NAME == "esx-old" or FRAMEWORK_NAME == "esx-legacy" then
            TriggerServerEvent('esx:onPlayerSpawn')
            TriggerEvent('esx:onPlayerSpawn')
            TriggerEvent('playerSpawned')
            TriggerEvent('esx:restoreLoadout')
            TriggerServerEvent(CURRENT_RESOURCE_NAME .. ":logDiscord", "Player "  .. esxPlayerData.firstName .. " " .. esxPlayerData.lastName .. " spawned at location " .. Config.spawns[location].locationName)
        end

    end
end

RegisterNUICallback('spawnPlayer', handleSpawnPlayer)

RegisterNUICallback('hideFrame', function(_, cb)
    toggleNuiFrame(false)
    debugPrint('Hide NUI frame')
    cb({})
end)

if FRAMEWORK_NAME == "esx-legacy" or FRAMEWORK_NAME == "esx-old" then
    RegisterNetEvent(Config.framework.triggers.esxPlayerLoaded)
    AddEventHandler(Config.framework.triggers.esxPlayerLoaded, function(playerData, isNew, skin)
        esxPlayerData = playerData
        TriggerEvent('s1n_spawnselector:openUI')
    end)
end
