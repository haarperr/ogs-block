fx_version 'cerulean'
games {'gta5'}

files {
  'audioconfig/npolchar_game.dat151.rel',
  'audioconfig/npolchar_sounds.dat54.rel',
  'sfx/dlc_npolchar/npolchar.awc',
  'sfx/dlc_npolchar/npolchar_npc.awc',
  'sfx/dlc_npolchar/npolchar2.awc',
  'sfx/dlc_npolchar/npolchar2_npc.awc'

}

data_file 'AUDIO_GAMEDATA' 'audioconfig/npolchar_game.dat'
data_file 'AUDIO_SOUNDDATA' 'audioconfig/npolchar_sounds.dat'
data_file 'AUDIO_WAVEPACK' 'sfx/dlc_npolchar'


client_script {
    'vehicle_names.lua'
}