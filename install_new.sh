#!/bin/env bash

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

ZSH=${ZSH:-~/.dotfiles/.oh-my-zsh}
readonly DOTFILES_DIR="${DOTFILES_DIR:-$HOME/.dotfiles}"
readonly OH_MY_ZSH_DIR="${OH_MY_ZSH_DIR:-$DOTFILES_DIR/.oh-my-zsh}"
readonly P10K_THEME_DIR="${P10K_THEME_DIR:-$OH_MY_ZSH_DIR/custom/themes/powerlevel10k}"

echo "OMZ:$OH_MY_ZSH_DIR"
echo "OMZ:$P10K_THEME_DIR_DIR"

echo "zsh:$ZSH"

if [[ -d ~/.dotfiles ]]; then
  echo ".dotfiles already exists..."
  if [[ -d ~/.dotfiles_bak ]]; then
    echo "dotfiles_bak already exists aswell"
    mv ~/.dotfiles_bak ~/.dotfiles_bak_$(date "+%Y-%m-%d-%h-%m")
  else
    mv ~/.dotfiles ~/.dotfiles_bak
    git clone https://github.com/phantomcortex/dotfiles.git ~/.dotfiles #future proof     
    if [[ -L "~/.zshrc" ]]; then
      echo "${RED}DEBUG${NC}:.zshrc is already symlinked"
      sudo chattr +i ~/.zshrc 
      #.zshrc probably isn't going to be linked to anything else
    else
      mv .zshrc .zshrc_bak_$(date "+%Y-%m-%d-%h-%m")
    fi
  fi
else
    #would it easier it was just git cloned? 
    #AUTHOR NOTE: No idea what all these git commands do, but it was in omz install script
    
    

    REPO=${REPO:-ohmyzsh/ohmyzsh}
    REMOTE=${REMOTE:-https://github.com/${REPO}.git}
    BRANCH=${BRANCH:-master}
    umask g-w,o-w
    
    # Manual clone with git config options to support git < v1.7.2
    git init --quiet "$OH_MY_ZSH_DIR" && cd "$OH_MY_ZSH_DIR" \
    && git config core.eol lf \
    && git config core.autocrlf false \
    && git config fsck.zeroPaddedFilemode ignore \
    && git config fetch.fsck.zeroPaddedFilemode ignore \
    && git config receive.fsck.zeroPaddedFilemode ignore \
    && git config oh-my-zsh.remote origin \
    && git config oh-my-zsh.branch "$BRANCH" \
    && git remote add origin "$REMOTE" \
    && git fetch --depth=1 origin \
    && git checkout -b "$BRANCH" "origin/$BRANCH" || {
      [ ! -d "$OH_MY_ZSH_DIR" ] || {
        cd -
        rm -rf "$OH_MY_ZSH_DIR" 2>/dev/null
      }
      echo  -e "${RED}git clone of oh-my-zsh repo failed${NC}"
      exit 1
    }
    
    [ -e ~/.dotfiles/.oh-my-zsh/oh-my-zsh.zsh ] || echo -e "${BLUE}oh-my-zsh is installed!${NC}"
    #p10k >>>>
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH/custom/themes/powerlevel10k"
    [ -e ~/.dotfiles/.oh-my-zsh/custom/themes/powerlevel10k/powerlevel10k.zsh-theme] || echo -e "${BLUE}powerlevek10k installed${NC}"
    #echo 'source ~/powerlevel10k/powerlevel10k.zsh-theme' >> ~/.zshrc 
    #might not need this if I already have a preconfigured zshrc
    #safety check
    if [ ! -f /home/linuxbrew/.linuxbrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && [ ! -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
    echo -e "$RED...zsh-syntax-highlighting is not installed$NC"
    brew install zsh-syntax-highlighting 
    fi

    if [ ! -f /home/linuxbrew/.linuxbrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ] && [ ! -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    echo -e "$RED...zsh-autosuggestions is not installed$NC"
    brew install zsh-autosuggestions 
    fi
    sleep 5
    echo "${GREEN}This concludes the script${NC}"
    sleep 5
  
fi


