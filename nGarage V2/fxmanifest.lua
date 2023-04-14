fx_version "bodacious"
game "gta5"

ui_page_preload "yes"
ui_page "ui/index.html"

shared_script "config.lua"

client_scripts {
    'src/RageUI/RMenu.lua',
    'src/RageUI/menu/RageUI.lua',
    'src/RageUI/menu/Menu.lua',
    'src/RageUI/menu/MenuController.lua',
    'src/RageUI/components/*.lua',
    'src/RageUI/menu/elements/*.lua',
    'src/RageUI/menu/items/*.lua',
    'src/RageUI/menu/panels/*.lua',
    'src/RageUI/menu/panels/*.lua',
    'src/RageUI/menu/windows/*.lua',
    
    "client.lua"
}

server_scripts {
    '@mysql-async/lib/MySQL.lua',
    "server.lua"
}

files {
    'ui/script.js',
    "ui/index.html",
    "ui/style.css",
    'ui/img/*',
    'ui/sound/*.*'
}