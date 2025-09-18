#!/bin/bash

# Lockdown function - Makes files/directories read-only and immutable
# Usage: lockdown [OPTIONS] FILE/PATTERN...
#   -u, --unlock    Reverse the lockdown (make mutable and writable)
#   -c, --check     Check the lockdown status of files
#   -h, --help      Show help message
NC='\033[0m'
RED='\033[31m'
TEAL='\033[36m'
GREEN='\033[32m'
YELLOW='\033[33m'
lockdown() {
    local unlock_mode=false
    local check_mode=false
    local targets=()
    local recursive_flag=""
    
    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -u|--unlock)
                unlock_mode=true
                shift
                ;;
            -c|--check)
                check_mode=true
                shift
                ;;
            -h|--help)
                cat << EOF
Lockdown - Protect files and directories from modification

Usage: lockdown [OPTIONS] FILE/PATTERN...

Options:
  -u, --unlock    Reverse the lockdown (make mutable and writable)
  -c, --check     Check the lockdown status of files
  -h, --help      Show this help message

Examples:
  lockdown file.txt              # Lock a single file
  lockdown *.dll                 # Lock all .dll files
  lockdown Tools/                # Lock directory and contents
  lockdown -u file.txt           # Unlock a file
  lockdown --check *.dll         # Check status of .dll files
  lockdown file1.txt dir/ *.log  # Lock multiple targets

Note: Requires sudo privileges for chattr operations
EOF
                return 0
                ;;
            *)
                targets+=("$1")
                shift
                ;;
        esac
    done
    
    # Check if we have targets
    if [[ ${#targets[@]} -eq 0 ]]; then
        echo -e "${RED}Error${NC}: ${YELLOW}No files or directories specified${NC}"
        echo -e "Use '${YELLOW}lockdown -h${NC}' for help"
        return 1
    fi
    
    # Function to check status
    check_status() {
        local item="$1"
        local writable="Yes"
        local immutable="No"
        
        # Check write permissions
        if [[ ! -w "$item" ]]; then
            writable="No"
        fi
        
        # Check immutable attribute (requires lsattr)
        if command -v lsattr &>/dev/null; then
            if lsattr "$item" 2>/dev/null | grep -q '^\S*i'; then
                immutable="Yes"
            fi
        fi
        
        printf "%-40s  Writable: %-3s  Immutable: %-3s\n" "$item" "$writable" "$immutable"
    }
    
    # Function to process a single item
    process_item() {
        local item="$1"
        local is_dir=false
        
        if [[ -d "$item" ]]; then
            is_dir=true
            recursive_flag="-R"
        else
            recursive_flag=""
        fi
        
        if $check_mode; then
            # Check mode
            if $is_dir; then
                echo "Directory: $item"
                check_status "$item"
                # Check contents of directory
                find "$item" -maxdepth 3 2>/dev/null | head -20 | while read -r subitem; do
                    check_status "$subitem"
                done
                local count=$(find "$item" 2>/dev/null | wc -l)
                if [[ $count -gt 20 ]]; then
                    echo "  ... and $((count - 20)) more items"
                fi
            else
                check_status "$item"
            fi
        elif $unlock_mode; then
            # Unlock mode - Order: first make mutable, then make writable
            echo -e "${YELLOW} ${NC} Unlocking: ${TEAL}$item${NC}"
            
            # First, remove immutable attribute (needs to be done before chmod)
            if sudo chattr -i $recursive_flag "$item" 2>/dev/null; then
                echo -e "    $TEAL✓ ${GREEN}Removed immutable attribute $NC"
            else
                echo -e "    $RED⚠$NC ${YELLOW}Could not remove immutable attribute (may not have been set) $NC"
            fi
            
            # Then, restore write permissions
            if chmod a+w $recursive_flag "$item" 2>/dev/null; then
                echo -e "    $TEAL✓ ${GREEN}Restored write permissions $NC"
            else
                echo -e "    $RED✗$NC ${YELLOW}Failed to restore write permissions $NC"
                return 1
            fi
        else
            # Lock mode - Order: first remove write, then make immutable
            echo -e "${YELLOW} ${NC} Locking down: ${TEAL}$item${NC}"
            
            # First, remove write permissions
            if chmod a-w $recursive_flag "$item" 2>/dev/null; then
                echo -e "    $TEAL✓ ${GREEN}Removed write permissions $NC"
            else
                echo -e "    $RED✗$NC ${YELLOW}Failed to remove write permissions $NC"
                return 1
            fi
            
            # Then, set immutable attribute
            if sudo chattr +i $recursive_flag "$item" 2>/dev/null; then
                echo -e "    $TEAL✓$NC ${GREEN}Set immutable attribute $NC"
            else
                echo -e "    $RED⚠$NC ${YELLOW}Could not set immutable attribute (needs sudo) $NC"
            fi
        fi
    }
    
    # Process each target
    local has_errors=false
    for target in "${targets[@]}"; do
        # Expand globs and process each match
        local matches=()
        
        # Use nullglob to handle non-matching patterns gracefully
        #shopt -s nullglob
        #matches=($target)
        #shopt -u nullglob
        
        if [[ ${#matches[@]} -eq 0 ]]; then
            # No glob matches, check if it's a literal file/directory
            if [[ -e "$target" ]]; then
                process_item "$target"
                if [[ $? -ne 0 ]]; then
                    has_errors=true
                fi
            else
                echo -e "Warning: No matches found for: $target"
                has_errors=true
            fi
        else
            # Process all matches
            for item in "${matches[@]}"; do
                if [[ -e "$item" ]]; then
                    process_item "$item"
                    if [[ $? -ne 0 ]]; then
                        has_errors=true
                    fi
                fi
            done
        fi
        
        echo ""  # Empty line between targets for readability
    done
    
    # Return status
    if $has_errors; then
        return 1
    else
        return 0
    fi
}

# Optional: Create shorter aliases
alias ld='lockdown'
alias ldu='lockdown -u'
alias ldc='lockdown -c'
