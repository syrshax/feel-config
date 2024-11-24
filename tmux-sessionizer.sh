#!/usr/bin/env bash

# If a session name is provided, try to switch to it directly
if [[ $# -eq 1 ]]; then
    session_name=$1
    if tmux has-session -t="$session_name" 2> /dev/null; then
        tmux switch-client -t "$session_name"
        exit 0
    else
        echo "Error: Session '$session_name' does not exist"
        exit 1
    fi
fi

# Handle directory selection
selected=$(find ~/personal ~/code/selectra-dev/ ~/code -mindepth 1 -maxdepth 2 -type d 2>/dev/null | fzf)

# Exit if no directory selected
if [[ -z $selected ]]; then
    exit 0
fi

# Create shorter session name - stop at first special character
selected_name=$(basename "$selected" | sed 's/[^[:alnum:]].*//g')

# If name ends up empty (rare case), use full basename with substitution
if [[ -z $selected_name ]]; then
    selected_name=$(basename "$selected" | tr -c '[:alnum:]' '_')
fi

# Check if tmux is running
tmux_running=$(pgrep tmux)

# If tmux is not running, start new session
if [[ -z $TMUX ]] && [[ -z $tmux_running ]]; then
    if ! tmux new-session -s "$selected_name" -c "$selected"; then
        echo "Error: Failed to create new tmux session"
        exit 1
    fi
    exit 0
fi

# Create or switch to session
if ! tmux has-session -t="$selected_name" 2> /dev/null; then
    if ! tmux new-session -ds "$selected_name" -c "$selected"; then
        echo "Error: Failed to create new tmux session"
        exit 1
    fi
fi

if ! tmux switch-client -t "$selected_name"; then
    echo "Error: Failed to switch to tmux session"
    exit 1
fi
