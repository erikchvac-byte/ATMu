#!/bin/bash
# Unmutable 3-Pane Tmux Dashboard Launcher
# Usage: ./launch-dashboard.sh [--no-borders]

# Configuration variables
SESSION_NAME="atmudashboard"
CONFIG_PATH="$HOME/.tmuxinator/atmudashboard.yml"
NO_BORDERS=false

# Parse arguments
for arg in "$@"; do
    case $arg in
        --no-borders)
            NO_BORDERS=true
            shift
            ;;
    esac
done

# Check for tmuxinator
if ! command -v mux &> /dev/null && ! command -v tmuxinator &> /dev/null; then
    echo "Error: tmuxinator not found. Install with: gem install tmuxinator"
    exit 1
fi

# Check for tmux
if ! command -v tmux &> /dev/null; then
    echo "Error: tmux not found. Install tmux first."
    exit 1
fi

# Apply no-border mode if requested
if [ "$NO_BORDERS" = true ]; then
    export TMUX_NO_BORDERS=1
fi

# Kill existing session if running
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "Session already running. Attaching..."
    tmux attach-session -t "$SESSION_NAME"
    exit 0
fi

# Launch via tmuxinator
echo "Launching Unmutable Dashboard..."
mux start atmudashboard 2>/dev/null || tmuxinator start atmudashboard

# If tmuxinator fails, manually create session
if [ $? -ne 0 ]; then
    echo "Falling back to manual tmux session creation..."
    
    # Create session with specific layout
    tmux new-session -d -s "$SESSION_NAME" -x 200 -y 59
    
    # Split for banner (3 lines top)
    tmux split-window -t "$SESSION_NAME" -v -p 5
    
    # Split bottom pane for 80/20 split
    tmux split-window -t "$SESSION_NAME:0.1" -h -p 80
    
    # Apply unmutable config
    tmux source-file "$HOME/.tmux.conf.unmutable"
    
    # Attach
    tmux attach-session -t "$SESSION_NAME"
fi
