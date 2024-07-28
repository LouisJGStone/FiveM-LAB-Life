--
-- Initialize the script
--

local CURRENT_RESOURCE_NAME = GetCurrentResourceName()

exports[Config.exportNames.s1nLib]:checkVersion("s1n_spawnselector", CURRENT_RESOURCE_NAME)

function NotifyByWebhook(description)
    if not Config.discord.enable then return end

    PerformHttpRequest(
            Config.discord["webhookURL"],
            false,
            "POST",
            json.encode({ username = Config.discord["username"], embeds = {
                {
                    ["color"] = Config.discord["color"],
                    ["title"] = Config.discord["title"],
                    ["description"] = description
                }
            } }), { ["Content-Type"] = "application/json" }
    )
end

RegisterNetEvent(CURRENT_RESOURCE_NAME .. ":logDiscord", NotifyByWebhook)