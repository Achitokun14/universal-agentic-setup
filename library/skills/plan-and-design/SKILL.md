---
name: plan-and-design
description: "Use before non-trivial builds: grill requirements, write spec/tickets/ADR, architecture review, handoff."
---

Decide what to build and how before building it: pick the lightest ceremony that removes the real uncertainty, produce a durable artifact only when someone will need it later, and stop at the plan. Execution of plans belongs to the agent's todo/subagent features (if available) or a separate session, not this skill.

## Pick the tier

Complexity = blast radius x uncertainty x reversibility. Start at the lowest tier that fits; escalate when you discover a hard-to-reverse decision, unclear requirements, or more than one module/session of work.

- **LOW** (clear ask, one area, easily reversed, <1 session): no files, no interview. Quick plan in chat: goal, 3-7 steps, how each is verified, risks. If nothing non-trivial is missing, just do it and say what you did.
- **MEDIUM** (several modules, fuzzy edges, 1-3 sessions): grill the open decisions (or a short one-pager if the user already decided), then spec and/or tickets written to the repo, ADR for any hard-to-reverse choice. Explore the codebase (code search, language server if available, otherwise `grep`/`rg`) before every question.
- **HIGH** (new subsystem, migration, auth/money/data model, public API, multi-session or multi-agent): full grill with premise challenge, 2-3 alternative approaches with a recommendation, eng review, spec + tickets (or a decision map for huge efforts), ADRs, then a fresh-eyes document review (subagents if the agent has them, otherwise a fresh session). Research external facts with the agent's web search or a docs-lookup tool, not memory.

Artifacts go where the repo already keeps them (`docs/adr/`, `docs/specs/`, `.scratch/`, an existing tracker doc). Creating a new directory, committing, or publishing to an issue tracker (`gh issue create`, Linear, etc.) needs the user's explicit confirmation of that action; local drafts and the OS temp dir are always fine. No telemetry, no external services, no auto-publishing.

## Pick the ceremony

| Ceremony | Use when | LOW | MEDIUM | HIGH | Load |
|---|---|---|---|---|---|
| **Quick plan** | ask is clear, just needs ordering | 3-7 bullets in chat | + test seams, risks, verify commands | implementation plan doc with task interfaces | `references/plan-doc.md` |
| **Grill** | requirements fuzzy, decisions unmade, user says "grill me" / "stress-test this" | skip | open decisions only, 3-8 questions | whole design tree + premise challenge | below, `references/grill-domain.md` |
| **Spec + tickets** | work must be handed over, reviewed, or split across sessions | skip | spec (short) or tickets | spec + tracer-bullet tickets with blocking edges; decision map if fog | `references/spec.md`, `references/tickets.md` |
| **ADR** | decision is hard to reverse, surprising later, and a real trade-off | skip | one ADR per such decision | ADR per decision + review checklist | `references/adr.md` |
| **Architecture deepening** | code is shallow, tangled, hard to test, or a risky cross-module change | skip | scan hot spots, 2-3 candidates | + design-it-twice subagents, change-impact map | `references/architecture-review.md` |
| **Plan review** | before committing to a plan that costs more than a day | skip | eng-review checklist | eng + product review, alternatives | `references/eng-review.md`, `references/eng-review-tests-ops.md`, `references/product-review.md` |
| **Handoff** | context is full, work pauses, another agent/session continues | skip | handoff note | handoff + references to every artifact | `references/handoff.md` |

Rule of thumb: fuzzy requirement -> Grill. Clear requirement but big -> Spec/tickets. Hard-to-undo choice -> ADR. Code shape is the problem -> Architecture deepening. Out of room -> Handoff.

## The Grill ceremony (one question at a time)

(Also the home of the standalone "grill me" request: a relentless interview to sharpen a plan or design; derived from mattpocock/skills, see `SOURCES.md`.)

Interview relentlessly until you and the user share an understanding of the design. Map the design as a tree: each decision branches into the decisions that depend on it.

1. **One question per turn.** Ask the single next most-blocking decision, then wait for the answer. Tell the user where you are in the tree ("Decision 3 of ~8: storage"). Never dump a questionnaire; batch only if the user asks and the questions are truly independent.
2. **Recommend an answer every time.** Format: the question (with options if it is a choice), then `Recommended: <answer> - <one-line reason>`. Word it so "yes" accepts your recommendation. The user decides; you never answer your own question or assume silence means yes.
3. **Explore instead of asking.** Facts are your job: read the code, tests, `git log`, docs, configs, ADRs and `GLOSSARY.md` (code search, file reads, language server if available); look up library behavior with a docs-lookup tool or web search. Ask the user only for decisions, preferences, priorities, and facts that exist only in their head. State what you found: "The repo already uses X in `src/y`; recommending we reuse it."
4. **Order by dependency.** Settle prerequisites first (goal, users, constraints, scope) before details (data shape, naming, edge cases). A decision that depends on an open one waits. New answers can reshape the tree: re-plan the frontier after each answer.
5. **Challenge, do not just record.** Flag contradictions with earlier answers or the code ("you said partial cancel is allowed, but `cancel()` voids the whole order - which is right?"). Pin vague terms to one name (`account`: Customer or User?). Stress-test with concrete edge-case scenarios. Push back when a choice looks over- or under-engineered, and say what you would do instead.
6. **Capture as you go**: resolved terms -> glossary entry, hard-to-reverse choices -> offer an ADR (see `references/grill-domain.md`). Keep a running list: Settled / Assumptions / Open.
7. **Finish when the tree is empty**: every branch visited, nothing silently assumed. Summarize decisions in a short list, ask the user to confirm, then propose the next ceremony (spec, tickets, plan). Do not start implementing until confirmed. If the user says "enough, just go", list your assumptions in one block and proceed.

## Rules

- Plan only what the user asked; do not expand scope, and record explicit out-of-scope items.
- Verify claims about the codebase before putting them in a plan; mark unknowns `unverified`, never guess at call paths from directory names.
- Prefer one seam to test at, the highest one that proves the behavior; use existing seams over new ones.
- Vertical slices: every ticket/step cuts through all layers and is demoable or verifiable alone (tracer bullets). Wide mechanical refactors are the exception: expand, migrate in batches, contract.
- Artifacts describe decisions and behavior, not file paths or code snippets that go stale (exception: a prototype snippet that encodes a decision precisely, e.g. a state machine or schema).
- Use the project's domain vocabulary (`GLOSSARY.md`) and respect existing ADRs; do not re-litigate a recorded decision without new evidence.
- Every plan names how each step is verified; hand the work to the `engineering-workflow` skill (if installed) or equivalent conventions (test first, verify, no push without confirmation).
- Keep plans small enough to hold in one context; if the effort exceeds a session, split into tickets or a decision map and use a handoff at the boundary.
- Never invent requirements, metrics, or user quotes; quantify non-functional requirements with numbers or mark them as open questions.
- When asked for options, give 2-3 real alternatives (one minimal, one ideal-architecture, optionally one lateral), a recommendation, and what each costs.
- Redact secrets and personal data from every artifact; refer to secrets by environment variable name (`$SECRET_NAME`) or secret-manager item name, never by value.

## References

- `references/grill-domain.md` - load when grilling: domain modeling, glossary, premise challenge, scenario stress tests.
- `references/plan-doc.md` - load to write a quick plan, implementation plan, prototype/spike, or large-project blueprint.
- `references/spec.md` - load to write a spec/PRD/tech spec and validate it.
- `references/tickets.md` - load to split work into tracer-bullet tickets or a decision map.
- `references/ticket-files.md` - load for the alternative per-ticket `rd.md` / `eval.md` / `board.md` file split (worker plus separate reviewer).
- `references/adr.md` - load to decide whether to write an ADR and how.
- `references/architecture-review.md` - load for deep-module vocabulary, deepening scans, design-it-twice, change-impact.
- `references/eng-review.md` - load to review a plan's scope, architecture, errors, security, code quality.
- `references/eng-review-tests-ops.md` - load for the test, performance, operability, rollout parts and required review outputs.
- `references/product-review.md` - load to challenge scope, premises, and alternatives (CEO lens, scope modes).
- `references/office-hours.md` - load when validating a business/product idea with forcing questions.
- `references/handoff.md` - load to write or resume from a handoff.
