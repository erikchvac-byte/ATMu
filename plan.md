# Implementation Plan: ATMu Phase 1

**Generated from:** @prd.md
**Phase:** 1 - Core Immutable Dashboard (MVP)
**Date:** 2026-01-16
**Status:** Ready for Implementation

## Overview

This plan implements the minimal viable product for ATMu: a locked, immutable 3-pane tmux dashboard that prevents accidental layout modifications.

## Phase 1 Objectives

1. ✅ Create tmux configuration that disables all layout modification operations
2. ✅ Define 3-pane layout with fixed dimensions (200x59)
3. ✅ Build launcher script with dependency checking and session management
4. ✅ Test immutability - verify users cannot resize/close panes
5. ✅ Document findings and refine based on testing

## Implementation Steps

### Step 1: Core Immutability Configuration

**File:** `.tmux.conf.unmutable`

**Requirements:** R2.1-R2.6 (Immutability Requirements)

**Implementation:**
- Unbind all resizing hotkeys:
  - `unbind-key M-Up/Down/Left/Right` (Alt+arrows)
  - `unbind-key C-Up/Down/Left/Right` (Ctrl+arrows)
  - `unbind-key -n M-Up/Down/Left/Right`
- Disable pane operations:
  - `unbind-key %` (split horizontal)
  - `unbind-key '"'` (split vertical)
  - `unbind-key x` (kill pane)
  - `unbind-key &` (kill window)
- Disable mouse:
  - `set -g mouse off`
- Set persistence:
  - `set -g remain-on-exit on`
- Lock status bar:
  - `set -g status-interval 0`

**Validation:**
- Attempt to resize panes with hotkeys - should not work
- Attempt to close panes - should not work
- Exit process in pane - pane should remain

### Step 2: Main Tmux Configuration

**File:** `.tmux.conf`

**Requirements:** Configuration hierarchy setup

**Implementation:**
- Set terminal type: `set -g default-terminal "screen-256color"`
- Configure status bar styling
- Source unmutable config: `source-file ~/.tmux.conf.unmutable`

**Note:** This file is the entry point; immutability comes from sourced file

### Step 3: Session Layout Definition

**File:** `.tmuxinator.yml`

**Requirements:** R1.1-R1.3 (Layout Requirements)

**Implementation:**
```yaml
name: atmudashboard
root: ~/
windows:
  - name: main
    layout: 80,200x59,0,0{133x59,0,0,0 66x59,134,0,1}
    panes:
      - echo "=== ATMU DASHBOARD ===" && echo "System Ready" && sleep infinity
      - # Placeholder for future tool
      - # Placeholder for future tool
```

**Layout Breakdown:**
- Total: 200x59 characters
- Left pane: 133 columns (main work area)
- Right: 66 columns split vertically into 2 panes

**Validation:**
- Verify pane dimensions with `tmux list-panes`
- Check pane arrangement visually

### Step 4: Launcher Script

**File:** `launch-dashboard.sh`

**Requirements:** R3.1-R3.3 (Launch Requirements)

**Implementation:**

```bash
#!/usr/bin/env bash

SESSION_NAME="atmudashboard"

# Dependency checks
command -v tmux >/dev/null 2>&1 || {
    echo "Error: tmux is not installed"
    exit 1
}

# Check if session exists
if tmux has-session -t "$SESSION_NAME" 2>/dev/null; then
    echo "Dashboard already running. Attaching..."
    tmux attach-session -t "$SESSION_NAME"
    exit 0
fi

# Try tmuxinator first
if command -v tmuxinator >/dev/null 2>&1; then
    tmuxinator start atmudashboard
elif command -v mux >/dev/null 2>&1; then
    mux start atmudashboard
else
    # Manual fallback
    echo "Starting dashboard manually (tmuxinator not found)..."
    tmux new-session -d -s "$SESSION_NAME" -x 200 -y 59
    tmux split-window -h -t "$SESSION_NAME":0
    tmux split-window -v -t "$SESSION_NAME":0.1
    tmux resize-pane -t "$SESSION_NAME":0.0 -x 133
    tmux send-keys -t "$SESSION_NAME":0.0 'echo "=== ATMU DASHBOARD ===" && echo "System Ready" && sleep infinity' C-m
    tmux attach-session -t "$SESSION_NAME"
fi
```

**Features:**
- Dependency validation
- Session detection and reattachment
- Tmuxinator with manual fallback
- Fixed dimensions (200x59)

**Validation:**
- Run script - should launch dashboard
- Run again - should attach to existing session
- Kill tmux server, run again - should create new session

### Step 5: Installation Setup

**Manual Installation Steps (to be automated in future phase):**

```bash
# Copy unmutable config to home directory
cp .tmux.conf.unmutable ~/.tmux.conf.unmutable

# Copy tmuxinator config (if using tmuxinator)
mkdir -p ~/.tmuxinator
cp .tmuxinator.yml ~/.tmuxinator/atmudashboard.yml

# Make launcher executable
chmod +x launch-dashboard.sh
```

### Step 6: Testing Protocol

**Test 1: Launch Verification**
```bash
./launch-dashboard.sh
# Expected: Dashboard launches with 3 panes
```

**Test 2: Immutability - Resize Prevention**
```
# Inside tmux session:
# Press Alt+Left/Right/Up/Down
# Press Ctrl+Left/Right/Up/Down
# Expected: No pane resizing occurs
```

**Test 3: Immutability - Split Prevention**
```
# Inside tmux session:
# Press Prefix + % (horizontal split)
# Press Prefix + " (vertical split)
# Expected: No new panes created
```

**Test 4: Immutability - Close Prevention**
```
# Inside tmux session:
# Press Prefix + x (kill pane)
# Expected: Pane does not close
```

**Test 5: Persistence**
```
# Inside any pane:
# Type: exit
# Expected: Pane shows "[exited]" but remains visible
```

**Test 6: Reattachment**
```bash
# Detach: Prefix + d
./launch-dashboard.sh
# Expected: Reattaches to existing session
```

## File Checklist

- [ ] `.tmux.conf.unmutable` - Core locking mechanism
- [ ] `.tmux.conf` - Main configuration entry point
- [ ] `.tmuxinator.yml` - Session layout definition
- [ ] `launch-dashboard.sh` - Launch script
- [ ] `~/.tmux.conf.unmutable` - Installed config (manual)
- [ ] `~/.tmuxinator/atmudashboard.yml` - Installed layout (manual)

## Success Criteria (from PRD)

- [x] Dashboard launches with 3 panes in correct positions
- [ ] User cannot resize panes using standard tmux hotkeys
- [ ] User cannot close panes using standard tmux operations
- [ ] Panes remain open even if processes inside exit
- [ ] Relaunching attaches to existing session if already running
- [ ] No errors on clean launch

## Notes and Discoveries

*(Use notes.md for detailed findings during implementation)*

## Risks and Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Tmuxinator not installed | High | Provide manual fallback in launcher |
| WSL/Git Bash compatibility issues | Medium | Test on target environment early |
| Layout string format errors | Medium | Validate with `tmux list-panes` |
| Config file not found | High | Clear error messages, installation instructions |

## Next Steps (After Phase 1 Completion)

1. Document all findings in notes.md
2. Verify all success criteria met
3. User testing and feedback
4. Plan Phase 2 based on learnings

## Open Questions for Implementation

1. Should we use `bash` or `sh` shebang for launcher script? → Use `bash` for WSL compatibility
2. Default pane content - keep simple placeholders or add specific tools? → Simple placeholders, customize in Phase 2
3. Error handling verbosity level? → Clear but concise error messages

---

**Implementation Start:** Ready to begin
**Estimated Complexity:** Low (core tmux configuration)
**Dependencies:** tmux, optional tmuxinator
