fx_version "cerulean"
game "gta5"
lua54 "yes"

name "Moneywash"
author "gigo"
version "1.0.0"
description "Moneywash for genesis"

shared_scripts {
    "config.lua",
    "@ox_lib/init.lua",
    '@qbx_core/modules/lib.lua'
}

client_scripts {
    "client.lua",
}

server_scripts {
    "server.lua",
}
