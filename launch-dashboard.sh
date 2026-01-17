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

    # Create session with 3-pane layout
    # Start with single pane
    tmux new-session -d -s "$SESSION_NAME" 'bash'

    # Split vertically (top 20% / bottom 80%)
    tmux split-window -v -t "$SESSION_NAME:0.0" -p 80

    # Split the bottom pane horizontally (large left / small right ~20%)
    tmux split-window -h -t "$SESSION_NAME:0.1" -p 20

    # Apply unmutable config
    tmux source-file "$HOME/.tmux.conf.unmutable"

    # Send commands to each pane
    # Pane 0 (top banner, 20% height): banner message
    tmux send-keys -t "$SESSION_NAME:0.0" "echo '=== ATMU DASHBOARD ===' && echo 'System Ready' && sleep infinity" Enter

    # Pane 1 (bottom-left, LARGE): main code editor area
    tmux send-keys -t "$SESSION_NAME:0.1" "echo '=== Main Panel: Code Editor Area ===' && bash" Enter

    # Pane 2 (bottom-right, small ~20% width): system monitor
    tmux send-keys -t "$SESSION_NAME:0.2" "htop" Enter

    # Attach to session
    tmux attach-session -t "$SESSION_NAME"
fi
