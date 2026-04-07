#!/bin/bash

cd $HOME
git clone https://github.com/galoistom/nvim-config.git
ln -s $HOME/nvim-config $HOME/.config/nvim
git clone https://github.com/galoistom/emacs-config.git
ln -s $HOME/emacs-config $HOME/.emacs.d
