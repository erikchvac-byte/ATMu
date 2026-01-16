# ATMu Installation Guide

## Prerequisites

ATMu requires tmux, which runs best in a Unix-like environment. On Windows, use WSL (Windows Subsystem for Linux).

## Step 1: Install/Enable WSL

If you don't have WSL installed yet:

```powershell
# Run in PowerShell as Administrator
wsl --install
```

This installs WSL with Ubuntu by default. Restart your computer when prompted.

If WSL is already installed, open it:
```powershell
wsl
```

## Step 2: Install Dependencies in WSL

Once inside WSL, install tmux:

```bash
# Update package lists
sudo apt update

# Install tmux
sudo apt install -y tmux

# Verify installation
tmux -V
```

**Optional:** Install tmuxinator for enhanced session management:
```bash
# Install Ruby (required for tmuxinator)
sudo apt install -y ruby-full

# Install tmuxinator
sudo gem install tmuxinator
```

## Step 3: Copy ATMu to WSL

From your WSL terminal, copy the ATMu project:

```bash
# Create dev directory if it doesn't exist
mkdir -p ~/Dev

# Copy from Windows to WSL
# Option A: If you have the project in Windows
cp -r /mnt/c/Users/erikc/Dev/ATMu ~/Dev/

# Option B: Clone from git (if pushed to remote)
cd ~/Dev
git clone <your-repo-url> ATMu
```

## Step 4: Run the Automated Installer

Navigate to the ATMu directory and run the installer:

```bash
cd ~/Dev/ATMu
chmod +x install.sh
./install.sh
```

This will:
- Copy configuration files to your home directory
- Make scripts executable
- Verify all dependencies are installed
- Display next steps

## Step 5: Launch the Dashboard

```bash
cd ~/Dev/ATMu
./launch-dashboard.sh
```

Or from anywhere after installation:
```bash
~/Dev/ATMu/launch-dashboard.sh
```

## Troubleshooting

### "tmux: command not found"
- Ensure you ran `sudo apt install tmux` in WSL
- Verify with `which tmux`

### "Session already exists"
- The dashboard is already running
- Attach with: `tmux attach -t atmudashboard`
- Or kill it: `tmux kill-session -t atmudashboard`

### Terminal size issues
- The dashboard expects 200x59 terminal size
- Maximize your terminal window before launching
- Or manually resize: `stty rows 59 cols 200`

### Panes not locked
- Verify `~/.tmux.conf.unmutable` exists
- Check `.tmux.conf` sources it correctly
- Reload config: `tmux source-file ~/.tmux.conf`

## Testing Immutability

Once launched, test the lock features:

1. **Try resizing panes:** Press `Alt+Left/Right/Up/Down` - should not work
2. **Try splitting:** Press `Ctrl+b` then `%` or `"` - should not work
3. **Try closing:** Press `Ctrl+b` then `x` - should not work
4. **Try zooming:** Press `Ctrl+b` then `z` - should not work
5. **Exit a process:** Type `exit` in any pane - pane should remain with `[exited]`

All these operations should be blocked by the immutability layer.

## Uninstallation

```bash
cd ~/Dev/ATMu
./uninstall.sh
```

This removes all configuration files and the session.

## Next Steps

- Customize pane commands in `.tmuxinator.yml`
- Modify status bar styling in `.tmux.conf`
- Add your own tools to the dashboard panes
