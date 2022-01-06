fx_version "cerulean"
games { "gta5" }

ui_page "nui/ui.html"

files {
    "nui/sounds/*.*",
    "nui/sounds/clicks/*.*",
    "nui/*.html",
    "nui/css/*.css",
    "nui/js/*.js",
}

shared_scripts {
    "shared/*",
}

server_scripts {
    "server/classes/*",
    "server/modules/*",
    "server/*",
}

client_scripts {
    "client/tools/*",
    "client/classes/*",
    "client/modules/*",
    "client/*",
}