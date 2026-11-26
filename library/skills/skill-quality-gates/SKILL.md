---
name: skill-quality-gates
description: "Use to gate an agent skill before publishing or installing: structure, portability, score, evals."
---

Concrete, checkable pass/fail gates for an agent skill (SKILL.md plus bundled files), applied by hand with ordinary file-reading and search tools. Complements a skill-authoring skill (how to write, pressure-test and adopt skills) and a security-scanner skill (if installed): this skill adds structure and portability gates, a scoring rubric, eval-case design and result interpretation, and a verdict rubric. The criteria are tool-agnostic. No evaluator or scanner needs to be installed; the optional `skillspector` command-line scanner (NVIDIA SkillSpector) may add a static-security line if the user already has it. Never install tools just to run a gate.

The numbers quoted here come from upstream documentation. If the publishing collection sets stricter limits (for example a shorter description or a smaller body), those win; a common strict profile is: one-line quoted description of 200 characters or fewer, `SKILL.md` under about 500 lines, long material in `references/`.

## Pick the tier

- **LOW - quick structure check** (editing one skill): run Gate 1 and Gate 2 on the changed files only.
- **MEDIUM - pre-publish or pre-adoption review**: Gates 1-4, plus a security line from whichever scanner is available (a security-scanner skill, or optionally `skillspector scan <dir> --no-llm`), or a manual source read if none is. Report gates and score separately.
- **HIGH - claims about effectiveness** (the skill must demonstrably help): Gates 1-5; pressure-test with subagents (or fresh sessions) with and without the skill, using the eval design in `references/eval-design.md`.

## Gates

1. **Structure (fail on any).**
   - `name`: kebab-case, starts with a letter, 1-64 chars, no leading/trailing/double hyphen, equals the directory, no reserved words `anthropic` or `claude`.
   - `description`: present, 1-1024 chars, states when to use it, "Use ..." trigger inside its first 60 chars.
   - No duplicate frontmatter keys, no tab indentation in YAML, no UTF-8 BOM, no XML-style tags in any frontmatter value, all keys strings (quote keys like `"yes"`).
   - Exactly one `SKILL.md` at the root; no symlinked manifest, no nested `SKILL.md` inside the skill.
   - Forbidden fields: `alwaysApply`, `globs`. Unknown fields: LOW advisory.
   - Dead relative Markdown links, unknown subdirectories (expected: `references/`, `scripts/`, `assets/`, `agents/`, `evals/`, `tests/`, `config/`, `tools/`) and unpinned dependency declarations: report.
2. **Hidden content (fail on any in prose or code).** Invisible characters: Unicode tag block U+E0000-E007F (critical; decodes hidden text), bidi controls U+202A-202E and U+2066-2069 (high), zero-width U+200B/200C/200D/2060/FEFF (medium/low), variation selectors (low). Search with grep using a PCRE class of these ranges (for example `grep -rP '[\x{E0000}-\x{E007F}\x{202A}-\x{202E}\x{2066}-\x{2069}\x{200B}-\x{200D}\x{2060}\x{FEFF}]' <skill-dir>`). A BOM at byte zero is only a portability issue.
3. **Portability.** One skill must load on several harnesses. Check the rules in `references/frontmatter-and-portability.md` (list budgets, size caps, placeholder substitution, ignored fields). Also check for machine-specific content: absolute user paths, drive letters, hostnames, personal names, agent-specific URIs or tool names.
4. **Quality score (0-100).** Correctness 35, Discoverability 25, Reliability 25, Efficiency 15. Pass needs >= 70 and no high/critical finding. Scoring checks and deductions: `references/quality-rubric.md`. Score by evidence found in the files; adding keywords to move the score is not an improvement.
5. **Evidence of effect** (HIGH tier only). Eval cases and result reading: `references/eval-design.md`.

## Rules

- The gate verdict and the quality score are separate results. A skill with grade A still fails if any gate fails; report both and never call a skill passing from the score alone.
- A missing measurement is `NO SCORE`, never 0, and is never averaged in. A check you could not run (scanner missing, no eval cases, no provider) is reported as incomplete, not as a pass.
- Static checks cover structure and wording, not whether the instructions are correct. A high score is not evidence the skill works; only behavior with and without the skill is.
- Never downgrade an unexplained high or critical finding because of the author's reputation, the skill's name, or a low numeric score.
- Do not execute scripts from the skill under review; read them. Do not install tools, extras or dependencies to run a gate.
- Do not invent eval cases for the user's skill. Ask for three to five real requests, what a good result looks like for each, and one request that must not trigger it; mark any draft you write as a draft for review.
- Report as: gate table (gate, result, evidence file:line), score with per-category notes, verdict, what was not run and why. Verdict vocabulary and rubric for adoption decisions: `references/adoption-verdict.md`.

## References

- `references/frontmatter-and-portability.md` - load for Gate 1 and Gate 3 details: field limits, severities, per-harness list budgets, size caps, placeholder and invocation quirks.
- `references/quality-rubric.md` - load for Gate 4: category deductions, expected headings, error-handling terms, description length, and the nine-criterion judged rubric.
- `references/eval-design.md` - load for Gate 5: eval case shape, buckets, outcome-only expectations, sufficiency, skill lift, reading results.
- `references/adoption-verdict.md` - load when deciding whether a third-party skill is safe to install: APPROVE / CAUTION / REJECT rubric, score posture, semantic checks, optional scanner output notes for Windows.
