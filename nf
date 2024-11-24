#!/bin/bash

# Function to check if commands exist
check_dependencies() {
    if ! command -v nvim &> /dev/null; then
        echo "Error: nvim is not installed"
        exit 1
    fi
    if ! command -v fzf &> /dev/null; then
        echo "Error: fzf is not installed"
        exit 1
    fi
}

# Check for required commands
check_dependencies

# Use find to search only current directory and subdirectories
# Then pipe to fzf for fuzzy finding
selected_file=$(find . -type f -not -path '*/\.*' | \
    sed 's|^./||' | \
    fzf --preview 'cat {}' \
        --preview-window=right:60%:wrap \
        --bind 'ctrl-/:toggle-preview')

# Only open neovim if a file was selected
if [ -n "$selected_file" ]; then
    nvim "$selected_file"
fi
