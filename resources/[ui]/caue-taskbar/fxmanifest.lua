fx_version "cerulean"
games { "gta5" }

ui_page "html/index.html"

files {
    "html/*.html",
    "html/*.js",
    "html/*.css",
}

shared_scripts {
    "shared/sh_*.lua",
}

server_scripts {
    "server/sv_*.lua",
}

client_scripts {
    "client/cl_*.lua",
}
