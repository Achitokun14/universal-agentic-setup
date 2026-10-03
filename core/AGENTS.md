<!-- BEGIN: universal-agentic-setup managed block (do not edit between these markers — rerun installer to update) -->
# Universal Agent Rules

Distilled, agent-neutral working rules applied by `universal-agentic-setup` to every
supported coding agent (Claude Code, Codex, Gemini CLI, Cursor, Copilot, OpenCode, …).

## Core (always on)

1. **Think before coding.** State assumptions, ask on ambiguity, surface tradeoffs. If multiple interpretations exist, present them — don't pick silently.
2. **Simplicity first.** Minimum code that solves the problem. No features beyond what was asked. 50 lines over 200.
3. **Surgical changes.** Touch only what's needed. Match existing style. Remove orphans **your** changes created; leave unrelated dead code.
4. **Goal-driven.** Define success criteria, loop until verified. For multi-file work, plan first.
5. **No AI attribution.** Never add `Co-Authored-By:`, `🤖`, or `Generated with …` lines to commits, PRs, or comments.
6. **Ask before destructive ops.** Pushes, deploys, schema resets, `docker system prune` — all require explicit approval.
7. **Update docs with code.** If a service/interface changes, its doc changes in the same commit.

## When missing a tool, prefer this order

1. Project-local MCP/skill → 2. User-level MCP/skill → 3. Local CLI → 4. Web search + fetch → 5. Ask the user.

## Pointers

- Supported agents and their config paths: `docs/AGENTS-MATRIX.md`
- Curated skill catalog: `docs/SKILLS.md` · CLI tool catalog: `docs/TOOLS.md`
- MCP server catalog: `core/mcp/servers.json` (env entries carry variable names only — never values)
<!-- END: universal-agentic-setup managed block -->
