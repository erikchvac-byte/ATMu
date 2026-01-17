# Architecture Decision Record (ADR)

**Project**: ATMu (Unmutable Tmux Dashboard)
**Last Updated**: 2026-01-16
**Status**: Active Development

---

## Overview

ATMu is an immutable 3-pane tmux dashboard system designed to prevent accidental layout modifications while maintaining administrative control. The system creates a locked tmux session where common hotkeys for resizing, splitting, and closing panes are disabled.

---

## Architecture Decisions

### ADR-001: Layered Configuration Approach

**Status**: Accepted
**Date**: 2026-01-16
**Context**: Need to separate immutability concerns from base tmux configuration.

**Decision**: Use a layered configuration system:
1. Base `.tmux.conf` (optional, user's personal config)
2. `.tmux.conf.unmutable` - Immutability layer loaded separately
3. `.tmuxinator.yml` - Session layout definition

**Rationale**:
- Separation of concerns
- Allows users to maintain their own tmux config
- Immutability can be toggled by sourcing or not sourcing the unmutable config
- Easier to debug and maintain

**Consequences**:
- Configuration must be explicitly sourced during session creation
- Multiple files to manage
- Clear separation makes troubleshooting easier

---

### ADR-002: Unbind Non-Prefix Keys Only

**Status**: Accepted
**Date**: 2026-01-16
**Context**: Balance between preventing accidents and allowing intentional admin changes.

**Decision**: Only unbind "root table" keys (no prefix, `-n` flag), preserve Ctrl+b prefix bindings.

**Rationale**:
- Users can accidentally hit Alt+arrow keys or other direct hotkeys
- Ctrl+b prefix commands require intentional multi-step action
- Admins need ability to make intentional layout changes for debugging/recovery
- Prevents accidental modifications while preserving escape hatch

**Keys Unbound** (no prefix):
- `M-Left`, `M-Right`, `M-Up`, `M-Down` (Alt+arrows for resize)
- `%`, `"` (split horizontal/vertical)
- `x`, `c`, `&`, `q` (close/kill operations)
- `z` (zoom pane)
- `{`, `}`, `Space` (swap/layout operations)
- `n`, `p`, `w`, `f` (window management)
- `s`, `d` (session operations)

**Keys Preserved** (Ctrl+b prefix):
- All prefix bindings remain functional
- Allows admins to split, close, resize via prefix commands

**Consequences**:
- Not truly "immutable" - admins can still modify
- Better described as "accident-proof" rather than "locked"
- Provides good balance between protection and flexibility

---

### ADR-003: remain-on-exit for Pane Persistence

**Status**: Accepted
**Date**: 2026-01-16
**Context**: Panes should remain visible even after processes exit.

**Decision**: Set `remain-on-exit on` globally in the immutability config.

**Rationale**:
- Dashboard should maintain visual structure even if processes crash/exit
- Allows viewing exit status and last output
- Prevents layout from collapsing when processes terminate
- Users can manually respawn panes if needed

**Consequences**:
- Dead panes show `[exited]` or `(dead)` status
- Requires manual cleanup with `tmux respawn-pane` or `tmux kill-pane`
- Preserves dashboard integrity

**Testing**: Verified in TEST 4 - Pane 1 marked as DEAD after exit command, remains visible.

---

### ADR-004: Manual Fallback in Launcher

**Status**: Accepted
**Date**: 2026-01-16
**Context**: tmuxinator is optional dependency, not always installed.

**Decision**: Implement manual tmux session creation fallback in `launch-dashboard.sh`.

**Rationale**:
- tmuxinator requires Ruby, adds dependency burden
- Manual tmux commands are portable and dependency-free
- Provides robustness if tmuxinator unavailable
- Same layout achievable with native tmux commands

**Implementation**:
```bash
tmux new-session -d -s "$SESSION_NAME" -x 200 -y 59
tmux split-window -t "$SESSION_NAME:0" -h -p 33
tmux split-window -t "$SESSION_NAME:0.1" -v -p 50
tmux source-file "$HOME/.tmux.conf.unmutable"
```

**Consequences**:
- Launcher script more complex with dual code paths
- No dependency on tmuxinator for basic functionality
- Better portability across systems

---

### ADR-005: Fixed Terminal Size (200x59)

**Status**: Accepted (with caveats)
**Date**: 2026-01-16
**Context**: Need consistent layout across sessions.

**Decision**: Target 200x59 terminal size for optimal layout:
- Left pane: 133 columns (67%)
- Right panes: 66 columns each (33% split vertically)

**Rationale**:
- Provides enough space for code editor (left) and monitoring tools (right)
- Wide enough for side-by-side viewing
- Matches common ultrawide monitor dimensions

**Caveats**:
- Actual terminal size may constrain layout
- Current implementation achieves ~40x24, 39x12, 39x11 on smaller terminals
- tmux will adapt to available terminal size

**Consequences**:
- Layout may not match target dimensions on smaller terminals
- User documentation should mention terminal size requirements
- Consider making dimensions configurable in future

**Status**: Working but dimensions vary based on actual terminal size.

---

### ADR-006: Mouse Disabled

**Status**: Accepted
**Date**: 2026-01-16
**Context**: Prevent accidental mouse-based layout changes.

**Decision**: Set `mouse off` in immutability configuration.

**Rationale**:
- Mouse dragging pane borders can accidentally resize
- Right-click context menus expose split/kill operations
- Disabling mouse prevents these accidental interactions
- Keyboard navigation still available via prefix commands

**Consequences**:
- Cannot use mouse to select text (must use tmux copy mode)
- Cannot click to switch panes (must use Ctrl+b + arrow keys)
- More keyboard-focused workflow
- Prevents accidental layout destruction

**Testing**: Verified in TEST 5 - mouse setting shows "off".

---

### ADR-007: WSL as Primary Environment

**Status**: Accepted
**Date**: 2026-01-16
**Context**: tmux unavailable on Windows, requires Unix-like environment.

**Decision**: Use WSL (Windows Subsystem for Linux) as the deployment target for Windows users.

**Rationale**:
- tmux is a Unix/Linux tool, not available natively on Windows
- WSL provides genuine Linux environment on Windows
- Better than alternatives (Cygwin, Git Bash with limited tmux support)
- Native Linux/macOS users can run directly

**Installation Path**:
1. Enable WSL on Windows
2. Install tmux in WSL
3. Copy ATMu project to WSL filesystem
4. Run installation script

**Consequences**:
- Adds WSL as dependency for Windows users
- Project must be copied from Windows to WSL filesystem
- Launch commands must use `wsl bash -l -c` prefix when executed from Windows
- Documentation must cover WSL setup

---

### ADR-008: Syntax Error Fix - Line 65 Escaping

**Status**: Accepted (Bug Fix)
**Date**: 2026-01-16
**Context**: `.tmux.conf.unmutable` line 65 had syntax error preventing config load.

**Problem**:
```bash
unbind-key -n }  # Syntax error - } needs escaping
```

**Decision**: Quote the closing brace character:
```bash
unbind-key -n "}"
```

**Rationale**:
- tmux requires special characters to be quoted in unbind commands
- The `}` character has special meaning in tmux/shell
- Quoting prevents interpretation as block delimiter

**Fix Applied**:
```bash
sed -i '65s/unbind-key -n }/unbind-key -n "}"/' ~/.tmux.conf.unmutable
```

**Consequences**:
- Config now loads without syntax error
- Must be applied to source file in repository
- Should be fixed in [.tmux.conf.unmutable](c:\Users\erikc\Dev\ATMu\.tmux.conf.unmutable:65)

**Testing**: Verified - `tmux source-file ~/.tmux.conf.unmutable` now succeeds.

---

### ADR-009: No Status Bar Updates (status-interval 0)

**Status**: Accepted
**Date**: 2026-01-16
**Context**: Reduce visual changes in locked dashboard.

**Decision**: Set `status-interval 0` to disable automatic status bar updates.

**Rationale**:
- Dashboard is meant to be stable and unchanging
- Constant status updates create visual noise
- Clock/date updates not necessary for monitoring use case
- Reduces tmux CPU usage

**Consequences**:
- Status bar won't show current time
- Must manually refresh status if needed: `Ctrl+b :refresh-client`
- More "frozen" appearance aligns with immutability goal

---

### ADR-010: No Automatic Window Renumbering

**Status**: Accepted
**Date**: 2026-01-16
**Context**: Maintain stable window indices.

**Decision**: Set `renumber-windows off` in immutability config.

**Rationale**:
- Automatic renumbering changes window indices when windows close
- Stable indices important for scripting and user expectations
- Aligns with immutability philosophy

**Consequences**:
- Window indices may have gaps if windows are closed
- More predictable window numbering

---

### ADR-011: Aggressive Resize Disabled

**Status**: Accepted
**Date**: 2026-01-16
**Context**: Prevent tmux from automatically resizing panes.

**Decision**: Set `aggressive-resize off` in immutability config.

**Rationale**:
- Aggressive resize causes panes to shrink when multiple clients attached
- Conflicts with immutability goal
- Maintains consistent layout regardless of client connections

**Consequences**:
- All clients see same size
- Smaller terminal clients may see cropped content

---

## Technical Constraints

### File Locations

**Windows (Development)**:
- Project: `c:\Users\erikc\Dev\ATMu`
- Files remain in Windows for version control

**WSL (Runtime)**:
- Project: `~/Dev/ATMu`
- Config: `~/.tmux.conf.unmutable`
- Session layout: `~/.tmuxinator/atmudashboard.yml`
- Launcher: `~/Dev/ATMu/launch-dashboard.sh`

### Dependencies

**Required**:
- tmux (v3.0+, tested with v3.4)
- bash
- WSL (Windows only)

**Optional**:
- tmuxinator (Ruby gem)
- Manual fallback available if not installed

---

## Testing Results (2026-01-16)

### ✓ Verified Working

1. **Session Creation**: atmudashboard session starts successfully
2. **3-Pane Layout**: Panes created (actual: 40x24, 39x12, 39x11)
3. **Pane Persistence**: `remain-on-exit on` working - panes marked as DEAD remain visible
4. **Mouse Disabled**: `mouse off` setting applied
5. **Alt+Arrow Keys Unbound**: 0 bindings in root table prevents accidental resize
6. **Configuration Files Installed**: Both `.tmux.conf.unmutable` and `.tmuxinator/atmudashboard.yml` present

### ⚠ Known Issues

1. **Manual Config Loading**: Immutability config must be manually sourced with `tmux source-file ~/.tmux.conf.unmutable`
   - Launcher script should do this automatically but wasn't tested in manual session creation
   - **ACTION**: Test actual `launch-dashboard.sh` script end-to-end

2. **Dimensions Don't Match Target**: Actual pane sizes smaller than plan target
   - Target: 133x59 (left), 66x29 (right panes)
   - Actual: 40x24, 39x12, 39x11
   - **CAUSE**: Terminal size constraints
   - **RESOLUTION**: Document required terminal size in [INSTALL.md](c:\Users\erikc\Dev\ATMu\INSTALL.md)

3. **Test Script Variable Expansion**: Bash variable substitution fails when executed via `wsl bash -c`
   - **CAUSE**: tmux not in PATH for non-login shells
   - **WORKAROUND**: Use `wsl bash -l -c` (login shell) or run scripts from within WSL
   - Test scripts have internal variable expansion issues

---

## Open Questions

1. Should prefix bindings also be disabled for true immutability?
   - Current: No (ADR-002 - admin access preserved)
   - Trade-off: Protection vs. flexibility

2. Should terminal size be auto-detected or configurable?
   - Current: Hardcoded 200x59 target
   - Consider: Dynamic sizing or config file option

3. Should `.tmux.conf` source `.tmux.conf.unmutable` automatically?
   - Current: Launcher sources it
   - Alternative: Add to user's `.tmux.conf` with conditional

---

## Future Considerations

1. **Configuration Options**: Make dimensions, commands, and aesthetics configurable
2. **Better Error Handling**: Add validation in launcher for terminal size, dependencies
3. **Respawn Commands**: Add helper script to respawn dead panes
4. **Status Bar Customization**: Optional locked status bar with project info
5. **Multiple Profiles**: Support different dashboard layouts (dev, ops, monitoring)

---

## References

- [plan.md](c:\Users\erikc\Dev\ATMu\plan.md) - Implementation plan and testing protocol
- [INSTALL.md](c:\Users\erikc\Dev\ATMu\INSTALL.md) - Installation instructions
- [.tmux.conf.unmutable](c:\Users\erikc\Dev\ATMu\.tmux.conf.unmutable) - Immutability configuration
- [launch-dashboard.sh](c:\Users\erikc\Dev\ATMu\launch-dashboard.sh) - Dashboard launcher
- [.tmuxinator.yml](c:\Users\erikc\Dev\ATMu\.tmuxinator.yml) - Session layout

---

## Change Log

- **2026-01-16**: Initial ADR created after Phase 1 implementation and testing
  - Documented all architectural decisions from implementation
  - Recorded testing results and known issues
  - Fixed syntax error on line 65 (ADR-008)
  - Verified immutability features working (remain-on-exit, mouse, key unbinding)
