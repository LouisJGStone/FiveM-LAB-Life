Utils = Utils or {}

-- Check if the specified dependency is being used in the configuration
-- @param dependency string The dependency to check
-- @return boolean Whether the dependency is being used
function Utils:IsUsingDependency(dependency)
    return Config.Dependencies[dependency]
end
exports("isUsingDependency", function(...)
    return Utils:IsUsingDependency(...)
end)