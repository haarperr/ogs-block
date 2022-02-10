fx_version "cerulean"
games { "gta5" }

lua54 "yes"

resource_type "gametype" { name = "Caue" }

server_scripts {
    "server/sv_variables.lua",
    "server/sv_init.lua",
}

client_scripts {
    "client/cl_variables.lua",
    "client/cl_init.lua",
    "client/cl_gameplay.lua",
}