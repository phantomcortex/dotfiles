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
# oh-my-zsh plugins (depending on platform):

# See Plugins list: https://github.com/ohmyzsh/ohmyzsh/tree/master/plugins
case "$(uname -s)" in
  Darwin)
    plugins=(aliases alias-finder brew colored-man-pages copyfile copypath command-not-found fzf gh git git-auto-fetch macos lol pj safe-paste ssh sudo tldr zoxide z zsh-interactive-cd)
    zstyle :omz:plugins:iterm2 shell-integration yes
    [ -f /opt/homebrew/bin/fzf ] && FZF_BASE=/opt/home/bin/fzf
    export PATH="/opt/Homebrew/sbin:$PATH"
    MACHINE="darwin"
    ;;
  Linux)
    plugins=(aliases alias-finder brew colored-man-pages dnf fzf gh git git-auto-fetch lol pj procs rsync safe-paste sudo systemd tldr zoxide z zsh-interactive-cd)
    [ -f /usr/bin/fzf ] && FZF_BASE=/usr/bin/fzf
    MACHINE="linux"
    ;;
  *)
    plugins=(zsh-syntax-highlighting) # fallback
    echo "ERROR: unknown OS"
    ;;
esac

source $ZSH/oh-my-zsh.sh
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# part sanity check, part function check
if [ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
  source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh # system level package
elif [ -f /home/linuxbrew/.linuxbrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
  source /home/linuxbrew/.linuxbrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh #linuxbrew
elif [ -f /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
  source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh # Apple Silicon homebrew
fi

if [ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
  source /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh # system level package
elif [ -f /home/linuxbrew/.linuxbrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
  source /home/linuxbrew/.linuxbrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh #linuxbrew
elif [ -f /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
  source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh # Apple Silicon homebrew

fi


# FROM: https://linuxshellaccount.blogspot.com/2008/12/color-completion-using-zsh-modules-on.html
zmodload -a colors

zstyle ':completion:*' menu select
#zstyle ':completion:*' 
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS} ma=0\;33

zstyle ':completion::complete:*' use-cache on
zstyle ':completion::complete:*' cache-path "${XDG_CACHE_HOME:-$HOME/.cache}/prezto/zcompcache"

# From: https://unix.stackexchange.com/questions/214657/what-does-zstyle-do
zstyle ':completion:*:descriptions' format "$fg[yellow]%B--- %d%b"
zstyle ':completion:*:messages' format '%d'
zstyle ':completion:*:warnings' format "$fg[red]No matches for:$reset_color %d"
zstyle ':completion:*:default' list-prompt '%S%M matches%s'
zstyle ':completion:*:matches' group 'yes'
zstyle ':completion:*:options' description 'yes'
zstyle ':completion:*:options' auto-description '%d'
zstyle ':completion:*:corrections' format ' %F{green}-- %d (errors: %e) --%f'
zstyle ':completion:*:descriptions' format ' %F{cyan}-- %d --%f'
# Use caching to make completion for commands such as dpkg and apt usable.
# ===========================================================
# most of the zstyle below is from ublues bluefin zshrc config
# ===========================================================

zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose yes

# Fuzzy match mistyped completions.
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:match:*' original only

# Directories
zstyle ':completion:*:*:cd:*' tag-order local-directories directory-stack path-directories
zstyle ':completion:*:*:cd:*:directory-stack' menu yes select
zstyle ':completion:*:-tilde-:*' group-order 'named-directories' 'path-directories' 'users' 'expand'
zstyle ':completion:*' squeeze-slashes true

# Kill
zstyle ':completion:*:*:*:*:processes' command 'ps -u $LOGNAME -o pid,user,command -w'
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#) ([0-9a-z-]#)*=01;36=0=01'
zstyle ':completion:*:*:kill:*' menu yes select
zstyle ':completion:*:*:kill:*' force-list always
zstyle ':completion:*:*:kill:*' insert-ids single

# SSH/SCP/RSYNC
zstyle ':completion:*:(ssh|scp|rsync):*' tag-order 'hosts:-host:host hosts:-domain:domain hosts:-ipaddr:ip\ address *'
zstyle ':completion:*:(scp|rsync):*' group-order users files all-files hosts-domain hosts-host hosts-ipaddr
zstyle ':completion:*:ssh:*' group-order users hosts-domain hosts-host users hosts-ipaddr
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-host' ignored-patterns '*(.|:)*' loopback ip6-loopback localhost ip6-localhost broadcasthost
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-domain' ignored-patterns '<->.<->.<->.<->' '^[-[:alnum:]]##(.[-[:alnum:]]##)##' '*@*'
zstyle ':completion:*:(ssh|scp|rsync):*:hosts-ipaddr' ignored-patterns '^(<->.<->.<->.<->|(|::)([[:xdigit:].]##:(#c,2))##(|%*))' '127.0.0.<->' '255.255.255.255' '::1' 'fe80::*'

# Man
zstyle ':completion:*:manuals' separate-sections true
zstyle ':completion:*:manuals.(^1*)' insert-sections true

# Media Players
zstyle ':completion:*:*:mpg123:*' file-patterns '*.(mp3|MP3):mp3\ files *(-/):directories'
zstyle ':completion:*:*:mpg321:*' file-patterns '*.(mp3|MP3):mp3\ files *(-/):directories'
zstyle ':completion:*:*:ogg123:*' file-patterns '*.(ogg|OGG|flac):ogg\ files *(-/):directories'
zstyle ':completion:*:*:mocp:*' file-patterns '*.(wav|WAV|mp3|MP3|ogg|OGG|flac):ogg\ files *(-/):directories'
# NOTE:No idea what this does but I assume it's useful.
# most of the above is from bluefin

#alias-finder
zstyle ':omz:plugins:alias-finder' autoload yes # disabled by default
zstyle ':omz:plugins:alias-finder' longer yes # disabled by default
zstyle ':omz:plugins:alias-finder' exact yes # disabled by default
zstyle ':omz:plugins:alias-finder' cheaper yes # disabled by default

#experimental
zmodload zsh/complist
autoload -Uz compinit && compinit
autoload -U colors && colors


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
setopt auto_menu auto_list

# correction often corrected commands that would otherwise run perfectly fine and correct unrelated commands
unsetopt correct_all
unsetopt correct

#bat config
export BAT_THEME="Monokai Extended Origin"
export PATH=$PATH:~/.cargo/bin
export PATH="$HOME/.local/bin:$PATH"

#from bluefin zsh:

# load brew autocomplete
if [ -d "/home/linuxbrew/.linuxbrew/share/zsh/site-functions" ]; then
    fpath+=(/home/linuxbrew/.linuxbrew/share/zsh/site-functions)
elif [ -d "/opt/homebrew/share/zsh/site-functions" ]; then
    fpath+=(/opt/homebrew/share/zsh/site-functions)
fi


# Standard style used by default for 'list-colors'
LS_COLORS=${LS_COLORS:-'di=34:ln=35:so=32:pi=33:ex=31:bd=36;01:cd=33;01:su=31;40;07:sg=36;40;07:tw=32;40;07:ow=33;40;07:'}


# Brew 
if [[ -o interactive ]] && [[ -d /home/linuxbrew/.linuxbrew ]]; then
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  if type brew &>/dev/null; then
    if [[ -w /home/linuxbrew/.linuxbrew ]]; then
      if [[ ! -L "$(brew --prefix)/share/zsh/site-functions/_brew" ]]; then
        brew completions link
      fi
    fi
  fi
fi


#ALIAS 
#alias xiso="~/Documents/bin/extract-xiso/build/extract-xiso"
alias grep="grep --color=auto"
alias fgrep="fgrep --color=auto"
alias egrep="egrep --color=auto"
alias apltop="sudo asitop"
alias coffee="caffeinate"
alias python="python3"
alias py="python3"
#alias pip="pip3"
alias vi="nvim"
alias vim="nvim"
alias brew-old="brew outdated"
#alias cd="z"
alias lt="eza --tree --no-user --long --sort=size --level=1 --git"
alias ltm="eza --tree --long --sort=size --level=3 --git"
alias cat="bat -p"
alias less="bat"
unalias tldr 
unalias ls
alias ls="eza --icons=always --classify=always --mounts"
alias lf="eza --icons=always --classify=always --long --almost-all --sort=size --git"
alias lfe="eza --icons=always --classify=always --long --almost-all --sort=size --git --total-size --show-symlinks"
alias ip="ifconfig enp6s0f3u3 | grep inet | awk ' { print $1, $2}'"
alias sftp="with-readline sftp"
source ~/.dotfiles/lockdown_function.sh
