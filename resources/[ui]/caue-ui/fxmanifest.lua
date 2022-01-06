fx_version "cerulean"
games { "gta5" }

ui_page "build/index.html"

files {
    "build/index.html",
    "build/static/js/*.js",
    "build/static/css/*.css",
    "build/static/media/*.ttf",
    "build/static/media/*.png",
    "build/static/media/*.jpg",
    "build/static/media/*.gif",
    "build/static/media/*.ogg",
}

server_scripts {
    "@caue-lib/server/sv_rpc.lua",
    "server/sv_*.lua",
    "server/sv_*.js",
}

client_scripts {
    "@caue-lib/client/cl_rpc.lua",
    "client/cl_exports.lua",
    "client/cl_lib.lua",
    "client/model/cl_*.lua",
}