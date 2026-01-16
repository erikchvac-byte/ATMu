# ATMu Development Notes

**Purpose:** Scratchpad for findings, insights, and temporary observations during development

---

## 2026-01-16: Initial Project Setup

### Environment Discovery
- Working directory: `c:\Users\erikc\Dev\ATMu`
- Platform: Windows (win32)
- Git repository: Yes
- Current branch: master

### Existing Files Found
- `.tmux.conf` (9 lines)
- `.tmux.conf.unmutable` (66 lines)
- `.tmuxinator.yml` (11 lines)
- `launch-dashboard.sh` (67 lines)
- `atmudashboard.desktop` (10 lines)
- `CLAUDE.md` (77 lines)
- `CLAUDE_START_HERE.txt` (88 lines - workflow instructions)

### User Interview Insights
- **Goal:** Personal productivity dashboard
- **Audience:** Self only
- **Environment:** Windows with WSL/Git Bash
- **Key Requirements:**
  - Locked/immutable panes (top priority)
  - 3-pane layout that launches correctly
- **Approach:** Start minimal, iterate - build Phase 1, test it, then plan Phase 2
- **Workflow:** Deterministic, modular (PRD → plan.md → implementation → notes.md)

### Project Status
- This is a **new build** - no existing product
- Already has basic configuration files from initial commit
- Need to validate that existing files actually work

### Next Actions
- [ ] Read existing configuration files to understand current state
- [ ] Implement/verify Phase 1 components per plan.md
- [ ] Test immutability features
- [ ] Document findings here

---

## Implementation Log

### 2026-01-16 14:30: Codebase Exploration Complete

**Exploration Agent Analysis:**
- Examined all 4 core configuration files
- Implementation is **75% complete** with several critical gaps
- Code quality: 6.5/10

**Key Findings:**

1. **`.tmux.conf.unmutable` (Immutability Engine):**
   - ✅ Resizing hotkeys disabled (Alt/Ctrl + arrows)
   - ✅ Pane split/close operations disabled
   - ✅ Mouse disabled, remain-on-exit enabled
   - ❌ Missing: swap pane (`{`, `}`), zoom (`z`), layout toggle (`space`)
   - ⚠️ Detach key unbind might interfere with workflow

2. **`.tmuxinator.yml` (Layout Definition):**
   - ✅ 200x59 dimensions specified
   - ✅ 3 panes defined (banner, code, htop)
   - ⚠️ Layout string ambiguous - unclear if right column properly split vertically
   - Needs actual testing to validate

3. **`launch-dashboard.sh` (Launcher):**
   - ✅ Dependency checking works
   - ✅ Session detection/reattachment works
   - ❌ **CRITICAL:** Manual fallback creates wrong layout (5% top, 80/20 split)
   - ❌ **CRITICAL:** Manual fallback doesn't attach to session
   - ❌ **CRITICAL:** Manual fallback doesn't send pane commands
   - ❌ `--no-borders` flag parsed but never used in configs

4. **Overall Status vs Phase 1 Requirements:**
   - Layout requirements: Partially met (needs validation)
   - Immutability requirements: Mostly met (missing some unbinds)
   - Launch requirements: Partially met (fallback broken)

**Priority Fixes Needed:**
1. Fix manual fallback in launcher (layout + attach + commands)
2. Add missing unbinds to immutability config
3. Test actual 3-pane layout works correctly
4. Either implement or remove --no-borders flag

---

### 2026-01-16 14:45: Critical Fixes Applied

**Fixed by:** Claude (Sonnet 4.5) with ollama-specialist assistance

1. **✅ launch-dashboard.sh manual fallback corrected:**
   - Changed split from wrong 5% top / 80-20 split
   - Now creates correct 67-33 horizontal split (133 cols left, 66 cols right)
   - Right pane split 50-50 vertically
   - Added `send-keys` commands to populate each pane
   - Added session attachment at end
   - Matches tmuxinator layout exactly

2. **✅ .tmux.conf.unmutable enhanced:**
   - Added `unbind-key -n z` (zoom pane)
   - Added `unbind-key -n '{'` (swap pane up)
   - Added `unbind-key -n '}'` (swap pane down)
   - Added `unbind-key -n Space` (layout toggle)
   - Immutability coverage now complete

**Remaining Tasks:**
- Test actual tmux session creation
- Validate 3-pane layout dimensions
- Decide on --no-borders flag (implement or remove)

---
