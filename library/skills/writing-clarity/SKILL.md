---
name: writing-clarity
description: "Use when writing or editing prose: remove AI-slop, write controlled English (STE) for agents and specs, co-author long docs; includes a cross-platform STE lint script."
---

# writing-clarity

Make prose direct, specific and unambiguous: strip AI-slop patterns, write controlled English where a misreading costs something, and co-author long documents with a reader test. Rules come from stop-slop (MIT), ASD-STE100-style rules (MIT), a doc-coauthoring workflow (Apache 2.0, distilled) and LinkedIn humanizer patterns (MIT, distilled); see `SOURCES.md`.

Not for creative or marketing voice where flatness hurts (fiction, ad copy, brand voice): apply only the "cut filler" checks there.

## Pick the tier

| Tier | Use when | Do |
|---|---|---|
| **low** | A paragraph, comment, commit message, chat reply | The 8 rules and quick checks below. No scoring. Return the edited text only |
| **medium** | Article, README, PR text, email, blog, docs page | Rules + checks, then score (below); revise until >= 35/50. Then lint with Vale if it is installed (`vale --config references/vale/.vale.ini file.md`, path relative to this skill's folder; see `references/vale.md`; skip if `vale` is not on PATH, and ask the user before installing it) |
| **high** | Tool/function descriptions, error messages, inter-agent prompts, specs, safety text, status reports | STE100 **Strict** mode + `ste-lint.py` (see "STE lint script" below). Long docs, RFCs, proposals: coauthoring workflow with a fresh-subagent reader test |

Social posts (LinkedIn etc.): `references/linkedin-patterns.md`.

## The 8 rules (stop-slop)

1. **Cut filler.** Delete throat-clearing openers ("Here's the thing", "It turns out", "The truth is"), emphasis crutches ("Let that sink in", "Full stop"), meta-commentary ("In this section we'll...") and all softeners, intensifiers and hedging adverbs (really, just, actually, genuinely, simply).
2. **Break formulaic structures.** No "not X, it's Y" contrasts, no negative listing ("Not a X. Not a Y. A Z."), no dramatic fragments, no rhetorical setups ("What if I told you...?"). State the point.
3. **Active voice, human subject.** Name who acts. No inanimate things doing human verbs ("the decision emerges", "the data tells us", "the market rewards"). Someone decides, reads, pays.
4. **Be specific.** Replace vague declaratives ("The implications are significant", "The reasons are structural") with the actual implication or reason. Avoid lazy extremes (every, always, never, nobody) doing vague work.
5. **Reader in the room.** "You" beats "people". No narrator-from-a-distance ("Nobody designed this", "This is why...").
6. **Vary rhythm.** Mix sentence lengths; two items beat three; end paragraphs differently; no em dashes (use a comma or a period).
7. **Trust the reader.** State facts; skip justification, reassurance ("And that's okay") and hand-holding.
8. **Cut quotables.** If a line sounds like a pull-quote, rewrite it plainly.

Quick checks before returning text: adverbs? passive? inanimate subject with human verb? sentence starting with Wh- or "So"/"Look,"? "here's what/this/that"? "not X, it's Y"? three same-length sentences in a row? punchy one-liner closing every paragraph? any em dash? a vague claim? meta-joiners? Details and word lists: `references/stop-slop/phrases.md`, `references/stop-slop/structures.md`.

### Score (medium tier)

Rate 1-10: directness, rhythm, trust, authenticity, density (anything cuttable?). Total < 35/50: revise and rescore once. Report the score only if the user asked.

## Editing discipline

- Preserve meaning, facts, numbers, names, quotes, code and links. Never add a fact, a cause, a statistic or an anecdote the source lacked. If a sentence needs one, ask the user.
- Keep hedges the author meant ("may have failed" stays a possibility). Confidence is content.
- Keep the author's voice; a clean draft gets a few touches, not a quota. Do not make text flat or choppy: stacking short sentences is itself a tell (`references/linkedin-patterns.md` over-correction check).
- Default output: the rewritten text only, no preamble, no change log. Give a short before/after list only when the user asks "what changed".
- Edit files in place with small targeted edits; never rewrite a whole file to change a few lines.
- Never promise the result passes AI detectors; no edit guarantees that.

## STE100 modes (high tier)

Pick a mode first (infer from text type unless told). The standard's ~900-word dictionary is NOT included (not freely redistributable), so lexical rules are "plainest word, used the same way every time", not dictionary compliance. Say so if the user needs certified STE.

- **Strict**: procedures, error messages, tool/function descriptions, inter-agent instructions, safety text. Every rule below, including one-word-one-meaning.
- **STE-flavored**: READMEs, PR text, changelogs, explanation. Structural rules in full; lexical rules advisory.

Structural rules: active voice (passive only when the actor is unknown or irrelevant); one instruction per sentence; <= 20 words for instructions, <= 25 for descriptions; no semicolons; no phrasal verbs (spin up, take off, reach out); no noun clusters over 3 words; keep subject, verb and articles (no telegraphic ellipsis); simple tenses (no present perfect unless current relevance is the point, then keep it and say so); one topic and <= 6 sentences per paragraph; lists for 3+ steps or conditions; verb not nominalisation ("inspect", not "perform an inspection of"); no marketing adjectives (seamless, robust, effortless); one name per concept, never rotate synonyms; keep modality (may/can/might stay), and if tense and modality conflict, modality wins.

Process: choose mode, read for meaning, walk sentence by sentence, run `ste-lint.py` (below), rewrite keeping meaning exactly, rerun. If a simpler phrase loses precision (a condition, scope, number) keep the longer one and add one line `Kept as-is: <phrase>, because <precision>`. If the input already complies, say so and change nothing. Rules summary and examples: `references/ste100/`.

### STE lint script

`scripts/ste-lint.py` is a single cross-platform Python 3 script (standard library only, no network; the same file runs on Windows, macOS and Linux, so no `.sh`/`.ps1` variants exist). It flags semicolons, long sentences, phrasal verbs, nominalisation, marketing adjectives, synonym rotation and dangling conjunctions; advisory only: passive voice, present perfect. Options: `--json`, `--baseline N`, `--disable rule,rule`, `--selftest`. Exit 1 on hard violations, 2 on usage errors. Paths are relative to this skill's folder; use the absolute path of the installed skill when running from a project.

#### macOS / Linux (bash)

```bash
python3 scripts/ste-lint.py file.md
echo "Text to check." | python3 scripts/ste-lint.py --json
```

#### Windows (PowerShell)

```powershell
python scripts/ste-lint.py file.md
"Text to check." | python scripts/ste-lint.py --json
```

## Co-authoring long docs (high tier)

Three stages: (1) gather context (meta questions, unstructured dump, 5-10 clarifying questions); (2) build section by section (questions, brainstorm, curate, gap check, draft, iterate; most uncertain section first, summary last); (3) reader test with a fresh subagent (if available) that sees only the document, plus an ambiguity pass. Full procedure: `references/coauthoring.md`. Offer it once; if declined, write freeform.

## References

- `references/stop-slop/phrases.md`
- `references/stop-slop/structures.md`
- `references/stop-slop/examples.md`
- `references/ste100/writing-rules.md`
- `references/ste100/before-after.md` (and `before-after-2.md`)
- `references/coauthoring.md`
- `references/linkedin-patterns.md`
- `references/vale.md` (config and rules in `references/vale/`)
- Script: `scripts/ste-lint.py` (license note in `scripts/LICENSE-ste-lint.txt`)
