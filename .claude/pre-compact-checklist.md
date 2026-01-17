# Pre-Compact Checklist

Before running `/compact`, ensure you complete these steps:

## 1. Update ADR.md

- [ ] Add any new architectural decisions made this session
- [ ] Document any bugs fixed and their root causes
- [ ] Record testing results in the Testing Results section
- [ ] Update Known Issues section
- [ ] Add entry to Change Log with today's date
- [ ] Save ADR.md

## 2. Update Project Documentation

- [ ] Update CLAUDE.md if workflow changed
- [ ] Update INSTALL.md if setup process changed
- [ ] Update README.md if user-facing features changed

## 3. Commit Changes

```bash
git add ADR.md CLAUDE.md
git commit -m "docs: Update ADR and project context before compaction"
```

## 4. Verify Critical Files

- [ ] ADR.md exists and is up to date
- [ ] All architectural decisions have ADR entries
- [ ] Known issues are documented
- [ ] Testing results are recorded

## 5. Run /compact

Only after completing steps 1-4, run:
```
/compact
```

---

## Why This Matters

Compaction summarizes conversations, losing detailed context. The ADR preserves:
- **Design rationale**: Why decisions were made
- **Testing results**: What actually works
- **Known issues**: What's broken and why
- **Trade-offs**: Consequences of decisions

Without ADR updates before compaction, this context is permanently lost.

---

## ADR Update Template

When adding to ADR.md, use this format:

```markdown
### ADR-XXX: Brief Decision Title

**Status**: Accepted | Proposed | Deprecated | Superseded
**Date**: YYYY-MM-DD
**Context**: What problem does this solve? Why was this needed?

**Decision**: What did we choose to do?

**Rationale**:
- Why this option over alternatives?
- What constraints influenced this?
- What evidence supports this?

**Consequences**:
- Benefits
- Drawbacks
- Trade-offs
- Impact on other components

**Testing**: How was this verified? What were the results?

---
```

Then update the Change Log at the bottom:

```markdown
## Change Log

- **YYYY-MM-DD**: Brief description of changes this session
  - Bullet points of specific updates
  - New ADRs added
  - Issues fixed
```
