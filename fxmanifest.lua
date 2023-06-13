fx_version 'adamant'
game { 'gta5' }
author 'StarIsland'
version '1.0.0'
lua54 'yes'

shared_scripts {
    '@es_extended/imports.lua', -- only if your using ESX-Legacy !
    --'languages/english.lua',
    'languages/french.lua',
    'config.lua',
}

client_scripts {

    "rageui/RageUI.lua",
	"rageui/Menu.lua",
	"rageui/MenuController.lua",
	"rageui/components/Audio.lua",
	"rageui/components/Graphics.lua",
	"rageui/components/Keys.lua",
	"rageui/components/Util.lua",
	"rageui/components/Visual.lua",
	"rageui/elements/*.lua",
	"rageui/items/*.lua",
	"rageui/panels/*.lua",
	"rageui/windows/*.lua",

    'client/utils.lua',
    'client/functions.lua',
    'client/events.lua',
    'client/main.lua',

}

server_scripts {
    "@oxmysql/lib/MySQL.lua",
    'server/functions.lua',
    'server/main.lua'
}
