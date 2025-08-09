#!/bin/bash

# AURTHOR NOTE: Script produced by Anthopic's Claude Sonnet 4
# I'll modify it as needed but it already does way more than I initially expected
# also note: claude is tuned to talk to me like a posh british gentlemen \
# That's why certain dialogs are worded weirdly, and I like it too much to change it.
#
# Dotfiles Installation Script
# A refined approach to setting up your development environment

set -e  # Exit on any error

# Colour codes for rather pleasant output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Colour

# Configuration variables
DOTFILES_REPO="https://github.com/phantomcortex/dotfiles.git"
DOTFILES_DIR="$HOME/.dotfiles"
OH_MY_ZSH_DIR="$DOTFILES_DIR/.oh-my-zsh"
P10K_THEME_DIR="$OH_MY_ZSH_DIR/custom/themes/powerlevel10k"

# Function to print coloured messages
print_message() {
    local colour=$1
    local message=$2
    echo -e "${colour}${message}${NC}"
}

print_header() {
    echo
    print_message $BLUE "════════════════════════════════════════════════"
    print_message $BLUE "  $1"
    print_message $BLUE "════════════════════════════════════════════════"
    echo
}

print_step() {
    print_message $YELLOW "→ $1"
}

print_success() {
    print_message $GREEN "✓ $1"
}

print_error() {
    print_message $RED "✗ $1"
}

# Function to check if command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install packages on Fedora
install_packages() {
    local packages=("$@")
    print_step "Installing required packages: ${packages[*]}"
    
    if command_exists dnf5; then
        sudo dnf5 install -y "${packages[@]}"
    elif command_exists dnf; then
        sudo dnf install -y "${packages[@]}"
    else
        print_error "Neither dnf5 nor dnf found. Please install packages manually: ${packages[*]}"
        exit 1
    fi
    
    print_success "Packages installed successfully"
}

# Function to backup existing files
backup_file() {
    local file=$1
    if [[ -f "$file" || -L "$file" ]]; then
        local backup_name="${file}.backup.$(date +%Y%m%d_%H%M%S)"
        print_step "Backing up existing $file to $backup_name"
        mv "$file" "$backup_name"
        print_success "Backup created: $backup_name"
    fi
}

# Function to create symlink
create_symlink() {
    local source=$1
    local target=$2
    
    if [[ ! -f "$source" ]]; then
        print_error "Source file does not exist: $source"
        return 1
    fi
    
    # Backup existing file if it exists
    backup_file "$target"
    
    print_step "Creating symlink: $target → $source"
    ln -sf "$source" "$target"
    print_success "Symlink created successfully"
}

# Main installation process
main() {
    print_header "Dotfiles Installation Script"
    print_message $BLUE "This script shall establish your refined development environment"
    echo
    
    # Check if running on Fedora
    if [[ ! -f /etc/fedora-release ]]; then
        print_message $YELLOW "Warning: This script is optimised for Fedora Linux"
        read -p "Would you like to proceed anyway? (y/N): " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_message $BLUE "Installation cancelled. Quite understandable!"
            exit 0
        fi
    fi
    
    # Install prerequisites
    print_header "Installing Prerequisites"
    install_packages git zsh curl
    
    # Clone or update dotfiles repository
    print_header "Setting Up Dotfiles Repository"
    if [[ -d "$DOTFILES_DIR" ]]; then
        print_step "Dotfiles directory exists, updating repository"
        cd "$DOTFILES_DIR"
        git pull origin main || git pull origin master
        print_success "Repository updated"
    else
        print_step "Cloning dotfiles repository"
        git clone "$DOTFILES_REPO" "$DOTFILES_DIR"
        print_success "Repository cloned to $DOTFILES_DIR"
    fi
    
    # Install Oh My Zsh within dotfiles directory
    print_header "Installing Oh My Zsh"
    if [[ ! -d "$OH_MY_ZSH_DIR" ]]; then
        print_step "Installing Oh My Zsh to $OH_MY_ZSH_DIR"
        export ZSH="$OH_MY_ZSH_DIR"
        sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        print_success "Oh My Zsh installed successfully"
    else
        print_success "Oh My Zsh already present"
    fi
    
    # Install Powerlevel10k theme
    print_header "Installing Powerlevel10k Theme"
    if [[ ! -d "$P10K_THEME_DIR" ]]; then
        print_step "Installing Powerlevel10k theme"
        git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$P10K_THEME_DIR"
        print_success "Powerlevel10k installed successfully"
    else
        print_step "Updating Powerlevel10k theme"
        cd "$P10K_THEME_DIR"
        git pull
        print_success "Powerlevel10k updated"
    fi
    
    # Create symlink for .zshrc
    print_header "Creating Configuration Symlinks"
    create_symlink "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
    
    # Set Zsh as default shell if not already
    print_header "Configuring Default Shell"
    if [[ "$SHELL" != "$(which zsh)" ]]; then
        print_step "Setting Zsh as default shell"
        chsh -s "$(which zsh)"
        print_success "Default shell set to Zsh (will take effect on next login)"
    else
        print_success "Zsh is already your default shell"
    fi
    
    # Final message
    print_header "Installation Complete"
    print_success "Your dotfiles have been installed with considerable elegance!"
    echo
    print_message $BLUE "Next steps:"
    print_message $BLUE "  1. Please restart your terminal or run 'exec zsh'"
    print_message $BLUE "  2. Configure Powerlevel10k by running 'p10k configure'"
    print_message $BLUE "  3. Customise your .zshrc as desired"
    echo
    print_message $GREEN "Splendid! Your development environment awaits."
}

# Error handling
trap 'print_error "An error occurred during installation. Most unfortunate!"' ERR

# Run main function
main "$@"
