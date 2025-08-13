#!/bin/env bash

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

DOTFILES_DIR="$HOME/.dotfiles"
OH_MY_ZSH_DIR="$DOTFILES_DIR/.oh-my-zsh"
P10K_THEME_DIR="$OH_MY_ZSH_DIR/custom/themes/powerlevel10k"

# PLAN: 
# run this script Directly from web 
# either clone or setup manually
# 1.OMZ 2. mv to dotfiles 3. p10k clone to OMZ custom 
# 4. zsh-syntax & autosuggestions to custom/plugins

if [[ -d ~/.dotfiles ]]; then
  echo ".dotfiles already exists..."
  if [[ -d ~/.dotfiles_bak ]]; then
    echo "dotfiles_bak already exists aswell"
    read -p "remove dotfiles_bak? (y/n)" yn
    case $yn in 
      [Yy]* ) rm -rf ~/.dotfiles_bak; echo "~/.dotfiles_bak removed";;
      [Nn]* ) echo "";;
      * ) exit;;
    esac
  else
    mv ~/.dotfiles ~/.dotfiles_bak
  fi
else
    #curl
    #sh -c "$(curl -fsSL https://raw.githubusercontent.com/phantomcortex/dotfiles/main/install_new.sh)"
    git clone https://github.com/phantomcortex/dotfiles.git ~/.dotfiles #future proof     
    if [[ -L "~/.zshrc" ]]; then
      echo "DEBUG:.zshrc is already symlinked"
      #Don't need to do anything because .zshrc probably isn't going to be linked to anything else
    else
      read -p "1:remove .zshrc or 2:move to .zshrc_bak (1/2)" 12
    case $yn in 
      [1]* ) rm -rf ~/.zshrc; echo "~/.zshrc removed.\nsymlink back .zshrc in .dotfiles"; ln -s ~/.dotfiles/.zshrc ~/.zshrc;;
      [2]* ) mv ~/.zshrc ~/.zshrc_bak;echo "DEBUG: mv ~/.zshrc ~/.zshrc_bak";;
      * ) echo "need a number...exiting >>>>";exit;;
    esac
    fi
    #my script
    #oh-my-zsh
    ZSH=~/.dotfiles/.oh-my-zsh
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" 
    #p10k
    #zsh-syntax
    #autosuggestions

  
fi
