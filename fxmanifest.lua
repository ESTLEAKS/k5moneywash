fx_version 'cerulean'
game 'gta5'

author 'k5'
description 'k5 Advanced Money Washing Script'
version '1.0.0'

shared_scripts {
    '@es_extended/locale.lua',
    'locales/en.lua',
    'config.lua'
}

client_scripts {
    'client/main.lua'
}

server_scripts {
    'server/main.lua'
}

dependencies {
    'es_extended'
}

lua54 'yes'
