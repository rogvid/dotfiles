#!/usr/bin/env bash
git clone https://github.com/AstroNvim/AstroNvim ~/.config/nvim
nvim  --headless -c 'autocmd User PackerComplete quitall'


