fx_version "cerulean"
games { "gta5" }

this_is_a_map "yes"

files {
	"interiorproxies.meta",
	"timecycle_mods",
}

data_file "INTERIOR_PROXY_ORDER_FILE" "interiorproxies.meta"
data_file "TIMECYCLEMOD_FILE" "timecycle_mods"

data_file "DLC_ITYP_REQUEST" "stream/misc/nopixel_cards.ytyp"
data_file "DLC_ITYP_REQUEST" "stream/misc/TeddyBoe.ytyp"
data_file "DLC_ITYP_REQUEST" "stream/misc/np_boxing_props.ytyp"
data_file "DLC_ITYP_REQUEST" "stream/misc/np_beehives.ytyp"
data_file "DLC_ITYP_REQUEST" "stream/misc/np_misc.ytyp"

client_scripts {
	"scripts/*",
}