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

    # Create session with specific layout (200x59 terminal)
    tmux new-session -d -s "$SESSION_NAME" -x 200 -y 59

    # Split right side: create 66-column pane on the right
    # -p 33 means keep left at 67%, right pane becomes 33% (~66 cols)
    tmux split-window -t "$SESSION_NAME:0" -h -p 33

    # Split the right pane (pane 1) vertically into 2 panes
    # -p 50 splits it 50/50 vertically
    tmux split-window -t "$SESSION_NAME:0.1" -v -p 50

    # Apply unmutable config
    tmux source-file "$HOME/.tmux.conf.unmutable"

    # Send commands to each pane
    # Pane 0 (left): banner message
    tmux send-keys -t "$SESSION_NAME:0.0" "echo '=== ATMU DASHBOARD ===' && echo 'System Ready' && sleep infinity" Enter

    # Pane 1 (top right): code editor
    tmux send-keys -t "$SESSION_NAME:0.1" "code" Enter

    # Pane 2 (bottom right): system monitor
    tmux send-keys -t "$SESSION_NAME:0.2" "htop" Enter

    # Attach to session
    tmux attach-session -t "$SESSION_NAME"
fi
