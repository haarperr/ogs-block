fx_version "cerulean"
games { "gta5" }

shared_script {
    "shared/*.*",
}

server_scripts {
    "server/*.*",
}

client_scripts {
    "@warmenu/warmenu.lua",
    "@caue-lib/client/cl_flags.lua",
    "@caue-lib/client/cl_state.lua",
    "client/*.*",
}