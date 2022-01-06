fx_version "cerulean"
games { "gta5" }

dependency "connectqueue"
dependency "ghmattimysql"

server_scripts {
    "@connectqueue/connectqueue.lua",
    "@caue-lib/shared/sh_ids.lua",
    "sv_whitelist.lua"
}