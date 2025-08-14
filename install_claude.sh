#!/usr/bin/env bash

set -euo pipefail

# =============================================================================
# Dotfiles Installation Script - Improved Version
# Installs Oh My Zsh, Powerlevel10k theme, and associated dotfiles
# =============================================================================

# Colour definitions for elegant output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly NC='\033[0m'

# Configuration constants
readonly DOTFILES_DIR="$HOME/.dotfiles"
readonly OH_MY_ZSH_DIR="$DOTFILES_DIR/.oh-my-zsh"
readonly P10K_THEME_DIR="$OH_MY_ZSH_DIR/custom/themes/powerlevel10k"
readonly DOTFILES_REPO="https://github.com/phantomcortex/dotfiles.git"

# Automation settings
readonly UNATTENDED_MODE="${UNATTENDED_MODE:-true}"    # Default to unattended
readonly AUTO_REMOVE_BACKUPS="${AUTO_REMOVE_BACKUPS:-true}"
readonly AUTO_CHANGE_SHELL="${AUTO_CHANGE_SHELL:-false}"

# Oh My Zsh configuration (preserving your original setup)
readonly ZSH_REPO="${REPO:-ohmyzsh/ohmyzsh}"
readonly ZSH_REMOTE="${REMOTE:-https://github.com/${ZSH_REPO}.git}"
readonly ZSH_BRANCH="${BRANCH:-master}"

# =============================================================================
# Utility Functions
# =============================================================================

log_info() { echo -e "${BLUE}[INFO]${NC} $*"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $*"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $*"; }
log_error() { echo -e "${RED}[ERROR]${NC} $*"; }
log_debug() { echo -e "${YELLOW}[DEBUG]${NC} $*"; }

# Improved user prompt with automation support
ask_user_confirmation() {
    local prompt="$1"
    local default_response="${2:-y}"  # Default to 'yes' if not specified
    local response
    
    # In unattended mode, use default response
    if [[ "$UNATTENDED_MODE" == "true" ]]; then
        log_info "$prompt (auto-answering: $default_response)"
        [ "$default_response" == "y" ] || return 0 
        [ "$default_response" == "n" ] || return 1
    else
    fi
    
    # Interactive mode (fallback)
    while true; do
        read -p "$prompt (y/n): " response
        case "${response,,}" in  # Convert to lowercase
            y|yes) return 0 ;;
            n|no) return 1 ;;
            *) echo "Please answer 'y' or 'n'." ;;
        esac
    done
}

# Create timestamped backup
create_timestamped_backup() {
    local source_path="$1"
    local backup_path="${source_path}_backup_$(date '+%Y-%m-%d_%H-%M-%S')"
    
    if [[ -e "$source_path" ]]; then
        log_info "Creating backup: $(basename "$backup_path")"
        mv "$source_path" "$backup_path"
        log_success "Backup created successfully"
    fi
}

# Check if required dependencies are available
check_dependencies() {
    local missing_deps=()
    local required_commands=("git" "zsh")
    
    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" &>/dev/null; then
            missing_deps+=("$cmd")
        fi
    done
    
    if [[ ${#missing_deps[@]} -gt 0 ]]; then
        log_error "Missing required dependencies: ${missing_deps[*]}"
        log_info "Please install with: sudo dnf5 install ${missing_deps[*]}"
        exit 1
    fi
}

# =============================================================================
# Installation Functions
# =============================================================================

handle_existing_dotfiles() {
    log_info "Existing .dotfiles directory detected"
    
    if [[ -d "$HOME/.dotfiles_bak" ]]; then
        log_warning "Previous backup (.dotfiles_bak) already exists"
        if ask_user_confirmation "Remove existing backup?" "$AUTO_REMOVE_BACKUPS"; then
            rm -rf "$HOME/.dotfiles_bak"
            log_success "Previous backup removed"
        else
            log_info "Keeping existing backup - creating timestamped backup instead"
            create_timestamped_backup "$DOTFILES_DIR"
            return 0
        fi
    fi
    
    # Create standard backup
    log_info "Creating backup of existing dotfiles"
    mv "$DOTFILES_DIR" "$HOME/.dotfiles_bak"
    log_success "Backup created: ~/.dotfiles_bak"
}

clone_dotfiles_repository() {
    log_info "Cloning dotfiles repository..."
    if git clone --quiet "$DOTFILES_REPO" "$DOTFILES_DIR"; then
        log_success "Dotfiles repository cloned successfully"
    else
        log_error "Failed to clone dotfiles repository"
        exit 1
    fi
}

handle_zshrc_configuration() {
    local zshrc_path="$HOME/.zshrc"
    
    if [[ -L "$zshrc_path" ]]; then
        log_debug ".zshrc is already a symbolic link"
        # Note: Removed the dangerous 'chattr +i' command as it's rarely needed
        # and can cause issues if the user needs to modify .zshrc later
        log_warning "Existing .zshrc symlink detected - please verify manually"
    elif [[ -f "$zshrc_path" ]]; then
        log_info "Backing up existing .zshrc file"
        create_timestamped_backup "$zshrc_path"
    fi
}

install_oh_my_zsh() {
    log_info "Installing Oh My Zsh..."
    
    # Set appropriate permissions
    umask g-w,o-w
    
    # Manual clone with git config options (preserving your original approach)
    if git init --quiet "$OH_MY_ZSH_DIR" && cd "$OH_MY_ZSH_DIR"; then
        git config core.eol lf
        git config core.autocrlf false
        git config fsck.zeroPaddedFilemode ignore
        git config fetch.fsck.zeroPaddedFilemode ignore
        git config receive.fsck.zeroPaddedFilemode ignore
        git config oh-my-zsh.remote origin
        git config oh-my-zsh.branch "$ZSH_BRANCH"
        git remote add origin "$ZSH_REMOTE"
        
        if git fetch --depth=1 origin && git checkout -b "$ZSH_BRANCH" "origin/$ZSH_BRANCH"; then
            log_success "Oh My Zsh installed successfully"
            cd - > /dev/null
        else
            log_error "Failed to fetch Oh My Zsh repository"
            [[ -d "$OH_MY_ZSH_DIR" ]] && rm -rf "$OH_MY_ZSH_DIR"
            cd - > /dev/null
            exit 1
        fi
    else
        log_error "Failed to initialize Oh My Zsh directory"
        exit 1
    fi
    
    # Verify installation
    if [[ -f "$OH_MY_ZSH_DIR/oh-my-zsh.sh" ]]; then
        log_success "Oh My Zsh installation verified"
    else
        log_error "Oh My Zsh installation appears incomplete"
        exit 1
    fi
}

install_powerlevel10k_theme() {
    log_info "Installing Powerlevel10k theme..."
    
    # Create themes directory if it doesn't exist
    mkdir -p "$(dirname "$P10K_THEME_DIR")"
    
    if git clone --depth=1 --quiet https://github.com/romkatv/powerlevel10k.git "$P10K_THEME_DIR"; then
        log_success "Powerlevel10k theme installed successfully"
    else
        log_error "Failed to install Powerlevel10k theme"
        exit 1
    fi
    
    # Verify theme installation
    if [[ -f "$P10K_THEME_DIR/powerlevel10k.zsh-theme" ]]; then
        log_success "Powerlevel10k theme installation verified"
    else
        log_error "Powerlevel10k theme installation appears incomplete"
        exit 1
    fi
}

check_and_install_zsh_plugins() {
    log_info "Checking Zsh plugin dependencies..."
    
    # Define possible installation paths for each plugin
    local syntax_highlighting_paths=(
        "/home/linuxbrew/.linuxbrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
        "/usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
        "/opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
    )
    
    local autosuggestions_paths=(
        "/home/linuxbrew/.linuxbrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
        "/usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
        "/opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
    )
    
    # Check for zsh-syntax-highlighting
    local syntax_highlighting_found=false
    for path in "${syntax_highlighting_paths[@]}"; do
        if [[ -f "$path" ]]; then
            syntax_highlighting_found=true
            log_success "Found zsh-syntax-highlighting: $path"
            break
        fi
    done
    
    if [[ "$syntax_highlighting_found" == false ]]; then
        log_warning "zsh-syntax-highlighting not found"
        if command -v brew &>/dev/null; then
            log_info "Installing zsh-syntax-highlighting via Homebrew..."
            brew install zsh-syntax-highlighting
        else
            log_warning "Homebrew not available - please install zsh-syntax-highlighting manually"
            log_info "Try: sudo dnf5 install zsh-syntax-highlighting"
        fi
    fi
    
    # Check for zsh-autosuggestions
    local autosuggestions_found=false
    for path in "${autosuggestions_paths[@]}"; do
        if [[ -f "$path" ]]; then
            autosuggestions_found=true
            log_success "Found zsh-autosuggestions: $path"
            break
        fi
    done
    
    if [[ "$autosuggestions_found" == false ]]; then
        log_warning "zsh-autosuggestions not found"
        if command -v brew &>/dev/null; then
            log_info "Installing zsh-autosuggestions via Homebrew..."
            brew install zsh-autosuggestions
        else
            log_warning "Homebrew not available - please install zsh-autosuggestions manually"
            log_info "Try: sudo dnf5 install zsh-autosuggestions"
        fi
    fi
}

# =============================================================================
# Main Installation Logic
# =============================================================================

main() {
    # Display banner only in interactive mode
    if [[ "$UNATTENDED_MODE" != "true" ]]; then
        echo -e "${BLUE}╔══════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║        Dotfiles Installation        ║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
    else
        log_info "Starting dotfiles installation (unattended mode)"
    fi
    
    # Preliminary checks
    check_dependencies
    
    # Handle existing dotfiles directory
    if [[ -d "$DOTFILES_DIR" ]]; then
        handle_existing_dotfiles
    fi
    
    # Clone dotfiles repository
    clone_dotfiles_repository
    
    # Handle .zshrc configuration
    handle_zshrc_configuration
    
    # Install Oh My Zsh
    install_oh_my_zsh
    
    # Install Powerlevel10k theme
    install_powerlevel10k_theme
    
    # Check and install Zsh plugins
    check_and_install_zsh_plugins
    
    # Installation complete
    if [[ "$UNATTENDED_MODE" != "true" ]]; then
        echo -e "\n${BLUE}╔══════════════════════════════════════╗${NC}"
        echo -e "${BLUE}║      Installation Complete!         ║${NC}"
        echo -e "${BLUE}╚══════════════════════════════════════╝${NC}"
    else
        log_success "Installation completed (unattended mode)"
    fi
    
    log_success "Dotfiles installation completed successfully!"
    
    if [[ "$UNATTENDED_MODE" == "true" ]]; then
        log_info "Running in unattended mode - skipping shell restart prompt"
    else
        log_info "Please restart your shell or run: source ~/.zshrc"
    fi
    
    # Optional: Offer to change default shell (only in interactive mode or if explicitly enabled)
    if [[ "$SHELL" != */zsh ]]; then
        log_info "Current shell: $SHELL"
        local should_change_shell=false
        
        if [[ "$UNATTENDED_MODE" == "true" ]]; then
            if [[ "$AUTO_CHANGE_SHELL" == "true" ]]; then
                should_change_shell=true
                log_info "Auto-changing default shell to zsh (unattended mode)"
            else
                log_info "Skipping shell change (unattended mode, AUTO_CHANGE_SHELL=false)"
            fi
        else
            if ask_user_confirmation "Would you like to change your default shell to zsh?"; then
                should_change_shell=true
            fi
        fi
        
        if [[ "$should_change_shell" == "true" ]]; then
            if command -v chsh &>/dev/null; then
                chsh -s "$(which zsh)"
                log_success "Default shell changed to zsh (takes effect on next login)"
            else
                log_warning "chsh command not available - please change shell manually"
            fi
        fi
    fi
}

# Execute main function
main "$@"
