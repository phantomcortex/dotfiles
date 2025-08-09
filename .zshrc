# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Path to your Oh My Zsh installation.
export ZSH="$HOME/.dotfiles/.oh-my-zsh"

eval "$(zoxide init zsh)"

ZSH_THEME="powerlevel10k/powerlevel10k"

 zstyle ':omz:update' mode auto      # update automatically without asking

# Uncomment the following line to change how often to auto-update (in days).
 zstyle ':omz:update' frequency 14

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable auto-setting terminal title.
#DISABLE_AUTO_TITLE="false"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
COMPLETION_WAITING_DOTS="true"
# I think oh-my-zsh plugins:
plugins=(aliases alias-finder dnf copyfile copypath fzf dnf git gh rsync ssh sudo pip safe-paste systemadmin tldr zoxide z zsh-interactive-cd zsh-syntax-highlighting zsh-autosuggestions colored-man-pages)

#ALIAS
alias grep="grep --color=auto"
alias fgrep="fgrep --color=auto"
alias egrep="egrep --color=auto"
alias cat="bat -p"
alias lt="tree -uh --sort=size -L 1"
alias ltm="tree -uhp --filelimit 20 --sort=size -L 3"
alias cp="advcp -g"
alias mv="advmv -g"
alias ..="cd .."


source $ZSH/oh-my-zsh.sh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

#experimental
zmodload zsh/complist
autoload -U compinit && compinit
autoload -U colors && colors

# FROM: https://linuxshellaccount.blogspot.com/2008/12/color-completion-using-zsh-modules-on.html
zmodload -a colors

zstyle ':completion:*' menu select
#zstyle ':completion:*' 
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS} ma=0\;33


# From: https://unix.stackexchange.com/questions/214657/what-does-zstyle-do
zstyle ':completion:*:descriptions' format "$fg[yellow]%B--- %d%b"
zstyle ':completion:*:messages' format '%d'
zstyle ':completion:*:warnings' format "$fg[red]No matches for:$reset_color %d"
#zstyle ':completion:*:corrections' format '%B%d (errors: %e)%b'

setopt autocd 
setopt privileged
#setopt correct 
setopt menucomplete
setopt histignoredups # prevents duplicate history entrys
setopt histignorespace # 
setopt noclobber # prevents overwriteing already a file that \ 
#already exists. Override is: ">!" e.g. cat /dev/null >! ~/.zshrc 
setopt extendedglob

#From BreadOnPenguins
setopt globdots
setopt append_history inc_append_history share_history
setopt auto_menu menu_complete

#bat config
export BAT_THEME="Monokai Extended Origin"
export PATH=$PATH:~/.cargo/bin
export PATH="$HOME/.local/bin:$PATH"


#custom rm command from anthrophic's claude Sonnet 4:
rm() {
    if [[ -d "$1" ]]; then
        local file_count=$(find "$1" -type f | wc -l)
        echo "This is a directory containing $file_count files."
        echo -n "Are you quite certain you wish to delete it? [y/N] "
        read -q "REPLY?"
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            command rm -rf "$@"
        fi
    else
        command rm -i "$@"
    fi
}
#
mkcd() {
    mkdir -p "$1" && cd "$1"
}

fcd() {
    local dir
    dir=$(find ${1:-.} -path '*/\.*' -prune -o -type d -print 2>/dev/null | 
          fzf +m --preview 'ls {}' --preview-window=right:50%:wrap) && cd "$dir"
}


# Enhanced history search with execution
fh() {
    eval $( ([ -n "$ZSH_NAME" ] && fc -l 1 || history) | fzf +s --tac | sed -E 's/ *[0-9]*\*? *//' | sed -E 's/\\/\\\\/g')
}



# Enhanced cd with proper truncation and column alignment
cd() {
    builtin cd "$@" && {
        local item_count=$(ls -1 | wc -l)
        if [ $item_count -gt 20 ]; then
            echo "Directory contains $item_count items:"
            local col_width=$(($(tput cols) / 2 - 1))
            ls -1 --color=always -F | head -40 | awk -v width="$col_width" '
            {
                # Remove ANSI codes for length check
                plain = $0
                gsub(/\033\[[0-9;]*m/, "", plain)
                
                if (length(plain) > width - 3) {
                    printf "%-*s", width, substr($0, 1, width-3) "..."
                } else {
                    printf "%-*s", width, $0
                }
                
                if (NR % 2 == 0) print ""
            }
            END { if (NR % 2 == 1) print "" }'
            echo "... and $((item_count - 40)) more items (use 'ls' to see all)"
        else
            ls --color=auto -F
        fi
    }
}

# Enhanced nautilus launcher with error handling
naut() {
    local target_dir="${1:-.}"
    
    if [[ ! -d "$target_dir" ]]; then
        echo "Directory '$target_dir' does not exist."
        return 1
    fi
    
    nautilus "$target_dir" >/dev/null 2>&1 &
    disown
    echo "Nautilus opened for: $(realpath "$target_dir")"
}
