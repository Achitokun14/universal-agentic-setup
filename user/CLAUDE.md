<!-- BEGIN: universal-agentic-setup managed block (do not edit between these markers — rerun installer to update) -->
# Claude — Universal Rules

On session start, run `~/.claude/hooks/tool-inventory.sh` output check (auto-injected). Detailed references live in `~/.claude/docs/` — load a doc only when the current task needs it (e.g., `docs/HOOKS.md` when the user asks about hooks).

## Core (always on)

1. **Think before coding.** State assumptions, ask on ambiguity, surface tradeoffs. If multiple interpretations exist, present them — don't pick silently.
2. **Simplicity first.** Minimum code that solves the problem. No features beyond what was asked. 50 lines over 200.
3. **Surgical changes.** Touch only what's needed. Match existing style. Remove orphans **your** changes created; leave unrelated dead code.
4. **Goal-driven.** Define success criteria, loop until verified. For multi-file work, plan first.
5. **No AI attribution.** Never add `Co-Authored-By: Claude`, `🤖`, or `Generated with Claude Code` to commits, PRs, or comments.
6. **Ask before destructive ops.** Pushes, deploys, schema resets, `docker system prune` — all require explicit approval.
7. **Update docs with code.** If a service/interface changes, its doc changes in the same commit.

## When missing a tool, prefer this order

1. Project-local MCP/skill → 2. User-level MCP/skill → 3. Local CLI → 4. Web search + WebFetch → 5. Ask the user.

## Pointers

- Full rule details + enforcement: `~/.claude/docs/RULES.md`
- Permission tiers, plugins: `~/.claude/docs/SETTINGS.md`
- Hooks reference: `~/.claude/docs/HOOKS.md`
- Available MCPs / skills / ACPs: `~/.claude/docs/MCPS.md`, `SKILLS.md`, `ACPS.md`
- Web-fallback strategy: `~/.claude/docs/WEB-FALLBACK.md`
<!-- END: universal-agentic-setup managed block -->
