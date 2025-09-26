#!/bin/bash

# Created: September 25th, 2025

#custom rm command from anthrophic's claude Sonnet 4:
rm() {
    if [[ -d "$1" ]]; then
        local file_count=$(find "$1" -type f | wc -l)
        local CYAN="\033[031m"
        local NC="\033[0m"
        echo -e "This is a directory containing $CYAN$file_count$NC files."
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
    local CYAN="\033[036m"
    local NC="\033[0m"
    mkdir -p "$1" && cd "$1"
    echo -e "$CYAN$NC Entered: $CYAN$1$NC"
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
            eza --icons=always --classify=always --color=always| head -40 | awk -v width="$col_width" '
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
            eza --icons=always --classify=always --color=always
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
    local CYAN="\033[031m"
    local NC="\033[0m"
    nautilus "$target_dir" >/dev/null 2>&1 &
    disown
    echo "Nautilus opened for: $CYAN$(realpath "$target_dir")$NC"
}