Config = Config or {}

-- Here you can set the dependencies that you are using
Config.Dependencies = {
    --TODO (NOT READY YET): If set to true, the script will try to detect all the dependencies automatically and check export names
    --automaticDetection = true,

    -- If you're not using the latest version of qb-banking or not using it at all, set this to false
    qbBanking = true,

    -- If you're using qb-inventory, set this to true otherwise set it to false
    qbInventory = false,
    -- If you're using ox-inventory, set this to true otherwise set it to false
    oxInventory = true,
    -- If you're using qs-inventory, set this to true otherwise set it to false
    qsInventory = false,

    -- If you're using qb-target, set this to true otherwise set it to false
    qbTarget = false,
    -- If you're using ox_target, set this to true otherwise set it to false
    oxTarget = true,
}

-- You need to verify that the following scripts are exactly named like this or change the names here
Config.ExportNames = {
    -- QBCore scripts
    qbBanking = "qb-banking",
    qbManagement = "qb-management",

    -- Inventory scripts
    qbInventory = "qb-inventory",
    oxInventory = "ox_inventory",

    -- Target scripts
    qbTarget = "qb-target",
    oxTarget = "ox_target",
}