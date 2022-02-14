fx_version "cerulean"
games { "gta5" }

shared_scripts {
    "shared/*",
}

server_scripts {
    "@caue-lib/server/sv_rpc.lua",
    "server/*",
}

client_scripts {
    "@caue-sync/client/cl_lib.lua",
    "@caue-lib/client/cl_rpc.lua",
    "client/*",
}