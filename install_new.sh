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
  echo "dotfiles already exists"
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
  else
    #curl 
    #my script
    #oh-my-zsh
    #p10k
    #zsh-syntax
    #autosuggestions

  
fi
