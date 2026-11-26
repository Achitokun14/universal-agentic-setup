---
name: batch-worktree-migration
description: "Use for a big migration or refactor of independent units: plan, isolated worktrees, one verified merge."
---

# Batch migration in isolated worktrees

A big mechanical change (library migration, API rename, lint-rule rollout, file-format move) is split into independent units, each done in its own checkout, then merged once and verified once. Nothing leaves the machine without the user's approval.

## 1. Plan (read-only)
1. Inspect the repository. Split the change into N units that touch **disjoint files** and do not depend on each other's results. If units overlap, merge them into one unit or run them in order.
2. Define one **end-to-end verification command** (build plus tests, or the project's own check) and, per unit, the narrow check that proves that unit.
3. Show the user: the unit list with files per unit, the verification commands, the base branch, and N. Default cap N at 8; ask before going higher. **Wait for approval.**

## 2. Execute
1. Check the base is clean (`git status --porcelain` empty); if not, ask.
2. For each unit, create an isolated checkout from the base: `git worktree add <sibling-folder> -b batch/unit-<i>` (name the folder next to the project, never inside it). A separate full copy of the folder works too if worktrees are unsuitable.
3. One worker per unit (a subagent if available, otherwise do the units in order), each with a self-contained brief: unit files, the transformation rule, the unit check, what to report. The worker edits only its unit's files and runs the unit check.
4. A unit that fails its check after 2 repair attempts is reported and left out; it does not block the others.

## 3. Integrate
1. Create a local integration branch from the base. Merge the passing unit branches one at a time. On a merge conflict, stop and report; do not resolve by guessing.
2. Run the end-to-end verification command on the integration branch and quote the real output.
3. Push, open a pull request or merge into the main branch **only after the user approves**. Offer one consolidated pull request. Never force-push.

## 4. Clean up
Only after the user agrees, remove the worktrees and branches this run created (`git worktree remove <folder>`, `git branch -d <branch>`; no `--force`). Leave anything you did not create.

## Notes
- Shared dev-server ports and shared dependency folders can still collide between worktrees; run units' tests one at a time when they do.
- The `agent-topology-chooser` skill (if installed) tells whether a fan-out is worth it at all; small changes should stay in one session.

*Distilled from a third-party video summary of the `/batch` workflow in a skill suite attributed to Claude Code's creator. Method restated in own words.*
