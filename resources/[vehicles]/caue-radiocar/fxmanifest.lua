fx_version "cerulean"
games { "gta5" }

lua54 "yes"

escrow_ignore {
    "shared/*",
    "utils/*",
    "client/exports/*.lua",
    "client/effects/*.lua",
    "client/commands.lua",
    "client/events.lua",
    "client/main.lua",
}

ui_page "html/index.html"

files {
	"html/*.html",
	"html/scripts/*.js",
	"html/css/*.css",
	"html/css/img/*.png",
}

shared_scripts {
    "shared/*",
}

server_scripts {
    "utils/mysql.lua",
    "utils/server.lua",
    "server/*",
}

client_scripts {
    "utils/client.lua",
    "client/*",
    "client/exports/*",
    "client/effects/*",
}