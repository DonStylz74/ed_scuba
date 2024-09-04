fx_version 'cerulean'
use_experimental_fxv2_oal 'yes'
lua54 'yes'
game 'gta5'

name 'ed_scuba'
version '1.0.0'
description 'FiveM resource to handle scuba based on ped component variation set modification of esx_scuba by wobozkyng'
author 'edmondio'

dependencies {
    'es_extended',
    'ox_inventory',
    'ox_lib',
}

shared_script {
    '@es_extended/imports.lua',
    '@es_extended/locale.lua',
    'shared.lua',
    '@ox_lib/init.lua',
    'config.lua',
}

files {
    'locales/*.json'
}

client_script 'cl_function.lua'
client_script 'cl_main.lua'
server_script 'sv_*.lua'