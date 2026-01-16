# Product Requirements Document: ATMu

## Project Overview

**Project Name:** ATMu (Unmutable Tmux Dashboard)
**Version:** 0.1.0
**Status:** Initial Development
**Owner:** Erik (Personal Productivity Tool)

## Problem Statement

Need a locked, immutable 3-pane tmux dashboard for personal productivity that prevents accidental layout modifications during daily work. The dashboard should be reliable, launch easily, and maintain its structure regardless of user actions.

## Goals and Objectives

### Primary Goals
1. Create a tmux session with a fixed 3-pane layout that cannot be accidentally modified
2. Prevent users from resizing, closing, or rearranging panes
3. Provide a simple, reliable launch mechanism

### Secondary Goals
- Easy to reinstall or deploy on new machines
- Minimal complexity - only essential features
- Iterative development approach: build, test, refine

## Target Audience

**Primary User:** Self (personal tool)
**Environment:** Windows with WSL/Git Bash
**Technical Level:** Comfortable with tmux, terminal tools, and bash scripting

## Functional Requirements

### Phase 1: Core Immutable Dashboard (MVP)

#### 1.1 Layout Requirements
- **R1.1:** Create tmux session with exactly 3 panes
- **R1.2:** Fixed terminal dimensions: 200x59 characters
- **R1.3:** Pane arrangement:
  - Left pane: ~133 columns wide (main working area)
  - Right top pane: ~66 columns wide
  - Right bottom pane: ~66 columns wide

#### 1.2 Immutability Requirements
- **R2.1:** Disable all pane resizing hotkeys (Alt+arrows, Ctrl+arrows)
- **R2.2:** Prevent pane splitting operations
- **R2.3:** Prevent pane closing/killing operations
- **R2.4:** Disable window management operations
- **R2.5:** Disable mouse interactions that could modify layout
- **R2.6:** Set `remain-on-exit on` to prevent panes from closing when processes exit

#### 1.3 Launch Requirements
- **R3.1:** Single command to launch dashboard
- **R3.2:** Detect if session already exists and attach instead of creating new
- **R3.3:** Provide clear error messages if dependencies missing

### Future Phases (To Be Defined After Phase 1)

- Phase 2: Pane content customization
- Phase 3: Installation automation
- Phase 4: Testing and validation tools
- Phase 5: Documentation and polish

## Technical Constraints

### Environment
- **Operating System:** Windows (WSL or Git Bash environment)
- **Shell:** Bash
- **Dependencies:**
  - tmux (terminal multiplexer)
  - tmuxinator OR manual tmux session creation
  - Basic Unix utilities (cat, echo, sleep)

### Configuration Approach
- Layered configuration system:
  1. `.tmux.conf` - Main entry point, sources unmutable config
  2. `.tmux.conf.unmutable` - Core locking mechanism
  3. `.tmuxinator.yml` - Session layout definition (optional, fallback to manual creation)

## Non-Goals (Explicitly Out of Scope)

- Multi-user or team deployment
- Dynamic layout switching
- GUI or web interface
- Complex pane content management
- Integration with external services
- Cross-platform compatibility (focusing on Windows/WSL only)

## Success Criteria

### Phase 1 Success Metrics
1. Dashboard launches with 3 panes in correct positions
2. User cannot resize panes using standard tmux hotkeys
3. User cannot close panes using standard tmux operations
4. Panes remain open even if processes inside exit
5. Relaunching attaches to existing session if already running
6. No errors on clean launch

## Development Approach

### Methodology
- **Start minimal, iterate:** Build the absolute minimum viable product first
- **Test before expanding:** Verify Phase 1 works completely before planning Phase 2
- **Deterministic workflow:** Use plan.md for implementation, notes.md for discoveries
- **Modular rules:** Create `.claude/rules/*.md` for complex procedures

### Workflow
1. Generate `plan.md` from this PRD for Phase 1 implementation
2. Build Phase 1 components following plan.md
3. Test immutability and launch mechanisms
4. Document findings in notes.md
5. Refine based on testing
6. Plan Phase 2 only after Phase 1 is complete and validated

## Open Questions

1. Should tmuxinator be required or optional with manual fallback?
2. What specific commands/tools should run in each pane initially?
3. Should there be a `--no-borders` aesthetic option?
4. How should the dashboard handle terminal resizing?

## Approval and Sign-off

- **PRD Author:** Claude (based on user interview)
- **Product Owner:** Erik
- **Approval Date:** Pending review
- **Next Step:** Generate Phase 1 implementation plan (plan.md)
