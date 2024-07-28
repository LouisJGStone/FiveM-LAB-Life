Inventory = Inventory or {}

-- Verify if the player has the item in the inventory
-- @param playerSource number The player server ID
-- @param itemName string The item name
-- @return boolean
function Inventory:HasItemInInventory(playerSource, itemName, itemCount)
    if Framework:GetCurrentFrameworkName() == "qbcore" then
        local qbPlayer = Framework.object.Functions.GetPlayer(playerSource)
        if not qbPlayer then return false end

        local item = qbPlayer.Functions.GetItemByName(itemName)
        if not item then return false end

        if itemCount then
            return item.amount >= itemCount
        end

        return item.amount > 0
    elseif Framework:GetCurrentFrameworkName() == "esx" then
        local xPlayer = Framework.object.GetPlayerFromId(playerSource)
        if not xPlayer then return false end

        local item = xPlayer.getInventoryItem(itemName)
        if not item then return false end

        if itemCount then
            return item.count >= itemCount
        end

        return item.count > 0
    end

    Utils:Debug("Inventory:HasItem - Framework not supported")

    return false
end
exports("hasItemInInventory", function(...)
    return Inventory:HasItemInInventory(...)
end)
EventManager:registerEvent("hasItemInInventory", function(source, callback, itemName)
    callback(Inventory:HasItemInInventory(source, itemName))
end)

-- Add an item to the player's inventory
-- @param dataObject table The data object
-- @param optionsObject table The options object
-- @return boolean Whether the item was added or not
function Inventory:AddInventoryItem(dataObject, optionsObject)
    if optionsObject then
        -- Check if the player already has the item
        if optionsObject.onlyIfNotAlreadyHave then
            if Inventory:HasItemInInventory(dataObject.playerSource, dataObject.itemName) then
                return false
            end
        end

        -- Check if the player can carry the item (add a config variable in configuration/ to enable this)
        if not optionsObject.disableCheckCanCarryItem and Config.Inventory.checkCanCarryItem then
            if not self:CanCarryItem(dataObject) then
                return false
            end
        end

        -- TODO: Handle metadata for oxInventory
    end

    if Framework:GetCurrentFrameworkName() == "qbcore" then
        local qbPlayer = Framework.object.Functions.GetPlayer(dataObject.playerSource)
        if not qbPlayer then return end

        qbPlayer.Functions.AddItem(dataObject.itemName, dataObject.amount)

        return true
    elseif Framework:GetCurrentFrameworkName() == "esx" then
        local xPlayer = Framework.object.GetPlayerFromId(dataObject.playerSource)
        if not xPlayer then return end

        xPlayer.addInventoryItem(dataObject.itemName, dataObject.amount)

        return true
    end

    Logger:error("Inventory:AddInventoryItem - Framework not supported")

    return false
end
exports("addInventoryItem", function(dataObject, optionsObject)
    return Inventory:AddInventoryItem(dataObject, optionsObject)
end)

-- Remove an item from the player's inventory
-- @param dataObject table The data object
-- @param optionsObject table The options object
-- @return boolean Whether the item was removed or not
function Inventory:RemoveInventoryItem(dataObject, optionsObject)
    if Framework:GetCurrentFrameworkName() == "qbcore" then
        local qbPlayer = Framework.object.Functions.GetPlayer(dataObject.playerSource)
        if not qbPlayer then return end

        qbPlayer.Functions.RemoveItem(dataObject.itemName, dataObject.amount)

        return true
    elseif Framework:GetCurrentFrameworkName() == "esx" then
        local xPlayer = Framework.object.GetPlayerFromId(dataObject.playerSource)
        if not xPlayer then return end

        xPlayer.removeInventoryItem(dataObject.itemName, dataObject.amount)

        return true
    end

    Logger:error("Inventory:RemoveInventoryItem - Framework not supported")

    return false
end
exports("removeInventoryItem", function(dataObject, optionsObject)
    return Inventory:RemoveInventoryItem(dataObject, optionsObject)
end)

-- Transfer an item from one player to another
-- @param dataObject table The data object
-- @param optionsObject table The options object
-- @return boolean Whether the item was transferred or not
function Inventory:TransferInventoryItem(dataObject, optionsObject)
    if not self:RemoveInventoryItem({ playerSource = dataObject.playerSource, itemName = dataObject.itemName, amount = dataObject.amount }, optionsObject) then
        return false
    end

    if not self:AddInventoryItem({ playerSource = dataObject.targetPlayerSource, itemName = dataObject.itemName, amount = dataObject.amount }, optionsObject) then
        return false
    end

    return true
end
exports("transferInventoryItem", function(...)
    return Inventory:TransferInventoryItem(...)
end)

-- Check if the player can carry the item
-- @param dataObject table The data object
-- @param optionsObject table The options object
-- @return boolean Whether the player can carry the item or not
function Inventory:CanCarryItem(dataObject, optionsObject)
    if Framework:GetCurrentFrameworkName() == "qbcore" then
        local qbPlayer = Framework.object.Functions.GetPlayer(dataObject.playerSource)
        if not qbPlayer then return end

        if Config.Dependencies.qbInventory then
            return exports[Config.ExportNames.qbInventory]:CanAddItem(dataObject.playerSource, dataObject.itemName, dataObject.amount)
        end

        return true
    elseif Framework:GetCurrentFrameworkName() == "esx" then
        local xPlayer = Framework.object.GetPlayerFromId(dataObject.playerSource)
        if not xPlayer then return end

        return xPlayer.canCarryItem(dataObject.itemName, dataObject.amount)
    end

    Logger:error("Inventory:CanCarryItem - Framework not supported")

    return false
end
exports("canCarryItem", function(dataObject, optionsObject)
    return Inventory:CanCarryItem(dataObject, optionsObject)
end)

-- Get the player's items
-- @param dataObject table The data object
-- @param optionsObject (optional) table The options object
-- @return table|boolean The player's items or false if the player is not found
function Inventory:GetPlayerItems(dataObject, optionsObject)
    local frameworkName = Framework:GetCurrentFrameworkName()
    local items

    if frameworkName == "qbcore" then
        local player = Framework.object.Functions.GetPlayer(dataObject.playerSource)
        if not player then return end

        items = player.PlayerData.items
    elseif frameworkName == "esx" then
        local xPlayer = Framework.object.GetPlayerFromId(dataObject.playerSource)
        if not xPlayer then return end

        items = xPlayer.inventory
    else
        Logger:error("Functions:GetPlayerItems - Framework not supported")

        return false
    end

    if not items then return false end

    -- Return the items as they are if no options are provided
    if not optionsObject then return items end

    -- Filter the items table based on the mapData
    if optionsObject.mapData then
        local filteredItems = {}
        local mapData = optionsObject.mapData

        for _, item in pairs(items) do
            local filteredItem = {}

            for key, _ in pairs(mapData) do
                local itemKey = key

                -- Handle the amount key
                local possibleAmountKeys = { "amount", "count", "quantity" }

                if itemKey == "amount" or itemKey == "count" then
                    local foundAmountKey = false

                    for _, amountKey in ipairs(possibleAmountKeys) do
                        if item[amountKey] ~= nil then
                            foundAmountKey = true
                            filteredItem[itemKey] = item[amountKey]
                            break
                        end
                    end

                    if not foundAmountKey then
                        Logger:warn(("Functions:GetPlayerItems - No amount key found in the item %s"):format(json.encode(item)))
                    end
                else
                    -- Handle the other keys
                    if item[itemKey] ~= nil then
                        filteredItem[key] = item[itemKey]
                    else
                        Logger:warn(("Functions:GetPlayerItems - Key %s not found in the item %s"):format(itemKey, json.encode(item)))
                    end
                end
            end

            table.insert(filteredItems, filteredItem)
        end

        return filteredItems
    end

    return items
end
exports("getPlayerItems", function(dataObject, optionsObject)
    return Inventory:GetPlayerItems(dataObject, optionsObject)
end)
EventManager:registerEvent("getPlayerItems", function(source, callback, dataObject, options)
    -- When sending from the client-side, the client shouldn't have to send its PlayerId, the server should handle that
    if not dataObject then
        dataObject = {}
    end

    if not dataObject.playerSource then
        dataObject.playerSource = source
    end

    callback(Inventory:GetPlayerItems(dataObject, options))
end)