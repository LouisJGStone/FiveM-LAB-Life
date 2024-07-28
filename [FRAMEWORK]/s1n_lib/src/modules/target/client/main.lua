Target = Target or {}

-- Check if a target dependency is being used
-- @return boolean Whether a target dependency is being used or not
function Target:IsUsingTargetDependency()
    return Config.Dependencies.qbTarget or Config.Dependencies.oxTarget
end
exports("isUsingTargetDependency", function(...)
    return Target:IsUsingTargetDependency(...)
end)

-- Add a zone which is a box to a target coords in order to be able to interact with it
-- @param dataObject table The data object containing the coords and debug mode
-- @return boolean Whether the box zone was added or not
function Target:AddBoxZone(dataObject)
    if Config.Dependencies.qbTarget then
        exports[Config.ExportNames.qbTarget]:AddBoxZone(dataObject.name, dataObject.coords, dataObject.length, dataObject.width, {
            name = dataObject.name,
            debugPoly = dataObject.debugMode
        }, {
            options = dataObject.options,
            distance = dataObject.distance or 1.5
        })
    elseif Config.Dependencies.oxTarget then
        exports[Config.ExportNames.oxTarget]:addBoxZone({
            coords = dataObject.coords,
            size = dataObject.size,
            debug = dataObject.debugMode,
            options = dataObject.options,
        })
    else
        Logger:error("Target:AddBoxZone - No target depencency found.")

        return false
    end

    Logger:info(("Target:AddBoxZone - Added box zone with name: %s"):format(dataObject.name))

    return true
end
exports("addBoxZone", function(...)
    return Target:AddBoxZone(...)
end)