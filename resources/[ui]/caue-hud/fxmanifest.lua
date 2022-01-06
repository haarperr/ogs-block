fx_version "cerulean"
games { "gta5" }

ui_page "html/index.html"

files {
	"html/*.html",
	"html/*.js",
	"html/*.css",
	"html/*.ttf",
	"html/*.png",
}

shared_scripts {
	"@caue-lib/shared/sh_util.lua",
	"shared/*",
}

server_scripts {
    "server/*",
}

client_scripts {
	"client/*",
}