fx_version 'cerulean'
game 'gta5'
lua54 'yes'

name 'coords'
author 'Bert + ChatGPT'
description 'Lightweight, optimized /coords tool that shows and copies vector4 coords. ESC or Cancel closes the UI.'
version '2.0.0'

ui_page 'html/index.html'

files {
    'html/index.html',
    'html/style.css',
    'html/script.js'
}

client_scripts {
    'client/main.lua'
}

-- Standalone: no server scripts required.
-- No framework dependencies.
