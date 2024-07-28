fx_version "cerulean"

description "S1nScripts Spawn Selector"
author "S1nScripts, Project Error"
version '1.6.0'

use_experimental_fxv2_oal 'yes'
lua54 'yes'

game "gta5"

ui_page 'web/build/index.html'

shared_scripts {
    "shared/config.lua"
}

client_scripts {
    "languages/english.lua",

    "client/utils.lua",
    "client/main.lua"
}

server_scripts {
    "server/config.lua",
    "server/main.lua"
}

files {
	'web/build/index.html',
	'web/build/**/*',
    "web/assets/**/*",
}

dependencies {
    '/onesync',
}


escrow_ignore {
    "**.*",
}

dependency '/assetpacks'