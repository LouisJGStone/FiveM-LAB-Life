-- Set config for the React part
local sentConfig = false

Citizen.CreateThread(function()
  while not sentConfig do
    SendReactMessage("setConfig", Config.notificationTypes)
    Citizen.Wait(1000)
  end
end)

RegisterNUICallback('dataSent', function()
  sentConfig = true
end)

local function Notify(type, title, message, duration, theme, position)
  SendReactMessage('myAction', {
    title = title,
    message = message,
    type = type,
    theme = theme,
    position = position,
    duration = duration
  })
end
exports("Notify", Notify)

RegisterNetEvent("s1n_notify:notify", function(object)
  Notify(object.type, object.title, object.message, object.duration, object.theme, object.position)
end)

-- Create automatic notifications with interval
for _, notification in pairs(Config.notifyIntervals) do
  Citizen.CreateThread(function()
    while true do
      Citizen.Wait(notification.interval)

      Notify(
        notification.notify.type,
        notification.notify.title,
        notification.notify.message,
        notification.notify.duration,
        notification.notify.theme,
        notification.notify.position
      )
    end
  end)
end