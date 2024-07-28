fx_version 'adamant'
game 'gta5'
description "Notification System"
author "S1nScripts"
version '1.3.0'

lua54 'yes'

ui_page 'web/build/index.html'

files {
  'web/build/index.html',
  'web/build/**/*'
}

client_scripts {
  "config.lua",
  "client/**/*"
}

server_scripts {
  "config.lua",
  "server/**/*"
}

escrow_ignore {
  "**.*",
}
dependency '/assetpacks'