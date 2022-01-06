fx_version "cerulean"
games { "gta5" }

ui_page "html/ui.html"

files {
    "html/ui.html",
    "html/js/*.js",
    "html/css/*.css",
    "html/webfonts/*.eot",
    "html/webfonts/*.svg",
    "html/webfonts/*.ttf",
    "html/webfonts/*.woff",
    "html/webfonts/*.woff2",
}

shared_scripts {
    "@caue-lib/shared/sh_models.lua",
    "@caue-lib/shared/sh_util.lua",
    "shared/*",
}

server_scripts {
    "server/*",
}

client_scripts {
    "@caue-lib/client/cl_state.lua",
    "client/*",
    "client/entries/*",
}