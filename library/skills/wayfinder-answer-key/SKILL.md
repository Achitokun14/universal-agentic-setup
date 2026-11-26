---
name: wayfinder-answer-key
description: "Use before an autonomous build-and-critic loop on a novel app: settle decisions, write pass/fail checks."
---

# Wayfinder answer key

Builder-and-critic loops fail on new kinds of product for two reasons: the main agent writes vague critic prompts, and with no named quality bar the critic invents its own standards. Remove the fog first: settle every decision, then write the exact pass/fail checks the critic must use.

## Phase 1 - find the fog and interview
1. Read the request and the existing repository. List the **fog**: decisions where answering A changes the options for B (roles and permissions, currencies and tax, data persistence, integrations).
2. Interview the user (the `grill-me` or `plan-and-design` skill, if installed; otherwise ask directly): short, high-leverage questions, each with your recommended default, until every branch is settled. Never guess a business rule silently; record an unanswered one as an open question.
3. Ask the user for a **reference bar**: a named product, standard or earlier release that defines "good enough". Without one, critics make up arbitrary standards.

## Phase 2 - two reference files
Propose a folder (default `.wayfinder/` in the project root) and create it only after the user agrees. Write:
1. `map.md` - every settled decision with its reason, the reference bar, and explicit non-goals (what NOT to build). Open questions listed separately.
2. `answer-key.md` - a numbered list of binary checks derived only from `map.md`. Each check has: an ID; the precondition (user role, data state); the exact action (a test command, a script, a browser step); the expected observable result (database row, HTTP status, visible text). Commands run against local or test environments only; none may delete data outside a test fixture, spend money or send messages.

Show both files and wait for approval. After approval, change them only through an amendment the user approves (record date and reason in the file).

## Phase 3 - run the loop
Cap the loop (default 5 rounds; stop sooner if two rounds make no progress) and report.
- Every **builder** gets `map.md` and its own task, not the answer key.
- Every **critic** is a fresh-context reviewer that gets only `answer-key.md` and the built result. It grades each check pass or fail with evidence (command output, screenshot path) and returns the failing IDs. It must not add subjective criteria. If it believes a check is missing, it reports an "answer-key gap" for the user to decide.
- The critic runs on a model tier at least as strong as the builders'.
- Done means every check passes with evidence, or the cap is reached and you report what fails.

## Rules
- The answer key comes from decisions, not from the code that was built.
- Do not run any answer-key command until the user approved the file, and never against production.
- Do not edit instruction files, settings or hooks; use the `invariant-tests-gate` skill (if installed) when the checks should become committed tests.

*Distilled from a third-party video summary combining a plan-clearing skill with an answer-key output for critic loops. Method restated in own words.*
