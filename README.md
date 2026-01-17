# ATMu - Unmutable Tmux Dashboard

A locked, immutable 3-pane tmux dashboard that prevents accidental layout modifications.

## What is ATMu?

ATMu creates a **fixed tmux session** where the layout cannot be accidentally changed:
- Alt+arrow keys won't resize panes
- Splitting/closing panes is disabled
- Mouse dragging is disabled
- Dead panes remain visible with `[exited]` status

This is a **TUI (Terminal User Interface)** for maintaining a stable, accident-proof workspace.

## Quick Start

### Windows (WSL)

```bash
# 1. Enable WSL and install Ubuntu
wsl --install

# 2. Inside WSL, install tmux
sudo apt update && sudo apt install -y tmux

# 3. Copy project to WSL
mkdir -p ~/Dev
cp -r /mnt/c/Users/YOUR_USERNAME/Dev/ATMu ~/Dev/

# 4. Run installer
cd ~/Dev/ATMu
chmod +x install.sh
./install.sh

# 5. Launch dashboard
./launch-dashboard.sh
```

### Linux/macOS

```bash
# 1. Install tmux
sudo apt install tmux  # Debian/Ubuntu
brew install tmux      # macOS

# 2. Clone/copy the repository
cd ~/Dev
git clone <your-repo> ATMu

# 3. Run installer
cd ATMu
chmod +x install.sh
./install.sh

# 4. Launch dashboard
./launch-dashboard.sh
```

## What You Get

```
┌─────────────────────────────┬──────────────┐
│                             │              │
│                             │  Pane 1      │
│        Main Pane            │  (top-right) │
│         (left)              │              │
│      133 x 59 cols          ├──────────────┤
│                             │              │
│                             │  Pane 2      │
│                             │ (bottom-rt)  │
│                             │              │
└─────────────────────────────┴──────────────┘
```

**3 panes in a locked layout:**
- Left: Main working area (~133 columns)
- Right top: Monitoring/logs (~66 columns)
- Right bottom: Secondary tools (~66 columns)

## Features

- **Accident-proof**: Cannot resize/close/split panes with hotkeys
- **Persistent panes**: Panes remain visible even after processes exit
- **Mouse disabled**: No accidental layout changes from clicking/dragging
- **Admin control**: Ctrl+b prefix commands still work for intentional changes
- **Auto-attach**: Relaunching attaches to existing session if running

## Usage

### Launch the Dashboard

```bash
cd ~/Dev/ATMu
./launch-dashboard.sh
```

From Windows, run in WSL:
```bash
wsl bash -l -c "cd ~/Dev/ATMu && ./launch-dashboard.sh"
```

### Attach to Running Session

```bash
tmux attach -t atmudashboard
```

### Detach (Exit Without Closing)

Press `Ctrl+b` then `d`

### Kill Session

```bash
tmux kill-session -t atmudashboard
```

## Testing Immutability

Once launched, verify the lock features:

| Action | Command | Expected Result |
|--------|---------|-----------------|
| Resize panes | `Alt+Arrow keys` | Nothing happens |
| Split panes | `Ctrl+b` then `%` or `"` | Disabled |
| Close pane | `Ctrl+b` then `x` | Disabled |
| Zoom pane | `Ctrl+b` then `z` | Disabled |
| Exit process | Type `exit` in pane | Pane shows `[exited]` but remains |

## Project Structure

```
ATMu/
├── README.md                    # This file
├── INSTALL.md                   # Detailed installation guide
├── ADR.md                       # Architecture Decision Record
├── CLAUDE.md                    # Project guidance for Claude Code
├── @prd.md                      # Product Requirements Document
├── .tmux.conf.unmutable         # Core immutability config
├── .tmuxinator.yml              # Session layout definition
├── launch-dashboard.sh          # Main launcher script
├── install.sh                   # Automated installer
├── test-dashboard.sh            # Test suite
└── .claude/
    └── pre-compact-checklist.md # ADR update checklist
```

## Configuration Files

After installation, these files are created in your home directory:

- `~/.tmux.conf.unmutable` - Immutability settings
- `~/.tmuxinator/atmudashboard.yml` - Session layout (if using tmuxinator)

## Customization

### Change Pane Commands

Edit `~/.tmuxinator/atmudashboard.yml`:
```yaml
panes:
  - htop              # Left pane
  - tail -f /var/log  # Top-right
  - watch date        # Bottom-right
```

### Modify Dimensions

Edit [.tmuxinator.yml](.tmuxinator.yml) and change the layout string.

### Aesthetic Options

Launch without borders:
```bash
./launch-dashboard.sh --no-borders
```

## Documentation

- [INSTALL.md](INSTALL.md) - Full installation guide with troubleshooting
- [ADR.md](ADR.md) - Architectural decisions and design rationale
- [CLAUDE.md](CLAUDE.md) - Development workflow and project context
- [@prd.md](@prd.md) - Product requirements and scope

## Known Issues

See [ADR.md](ADR.md) for detailed information:

1. **Configuration loading**: Immutability config must be sourced during launch
2. **Terminal size**: Pane dimensions depend on actual terminal size
3. **Test scripts**: Have bash variable expansion issues when run via `wsl bash -c`

## Requirements

**Required:**
- tmux (v3.0+)
- bash
- WSL (Windows only)

**Optional:**
- tmuxinator (Ruby gem for enhanced session management)

## Uninstallation

```bash
cd ~/Dev/ATMu
./uninstall.sh
```

## License

Personal project - use as needed.

## Contributing

This is a personal productivity tool. Feel free to fork and adapt for your needs.

## Support

For issues or questions:
1. Check [INSTALL.md](INSTALL.md) troubleshooting section
2. Review [ADR.md](ADR.md) known issues
3. Check tmux configuration: `tmux show-options -g`
