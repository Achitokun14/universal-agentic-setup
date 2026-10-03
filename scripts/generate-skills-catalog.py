#!/usr/bin/env python3
"""Generate SKILLS-CATALOG.md from skills-inventory.json, applying tier heuristics."""
import json, os
from pathlib import Path
from collections import defaultdict, Counter

INV = Path.home() / "Desktop/ACTIVITIES/skills-inventory.json"
OUT = Path.home() / "Desktop/ACTIVITIES/SKILLS-CATALOG.md"

entries = json.loads(INV.read_text())

# ═══════════════════════════════════════════════════════════════════
# Tier rules (deterministic, auditable)
# ═══════════════════════════════════════════════════════════════════

TIER_S = {
    "wiki","learn","plan","verify","compress","retro","careful",
    "git-workflow","commit-commands:commit","claude-md-management:revise-claude-md",
    "superpowers:using-superpowers","superpowers:brainstorming","superpowers:systematic-debugging",
    "superpowers:verification-before-completion","superpowers:test-driven-development",
    "commit-commands:commit-push-pr",
}

# Tier A — user's confirmed stack (Next.js/NestJS/Go/Postgres/Prisma/Railway/Docker/Tailwind/Stripe/Sentry/Bun)
TIER_A_PATTERNS = [
    # frontend
    "nextjs-turbopack","frontend-patterns","frontend-design","taste-skill","emil-design-eng",
    "ui-ux-pro-max","minimalist-skill","soft-skill","brutalist-skill","redesign-skill","liquid-glass-design",
    # backend
    "nestjs-patterns","golang-patterns","golang-testing","backend-patterns","api-design",
    "postgres-patterns","mcp-server-patterns","bun-runtime","fastapi-patterns",
    # data
    "database-migrations","database-patterns",
    # DevOps (user uses Railway heavily)
    "docker-patterns","deployment-patterns","github-ops","terraform-skill","terminal-ops",
    # testing
    "tdd-workflow","e2e-testing","verification-loop","python-testing","ai-regression-testing",
    # research / analysis
    "research","research.universal","deep-research","search-first","pair","crit",
    "autoplan","deep-interview","extract","documentation-lookup","external-context","exa-search",
    # meta / context (hidden gems)
    "prompt-optimizer","strategic-compact","context-budget","token-budget-advisor",
    "rules-distill","skill-creator","skill-stocktake","skill-comply","learner","learn.universal",
    "blueprint","code-tour","canary-watch","safety-guard","gateguard","ai-slop-cleaner",
    "benchmark","benchmark-models","eval-harness","agent-eval",
    # bundle commands
    "ytdl","freeze","unfreeze","crit","pair","autoplan","extract","compress","retro","careful","wiki","learn","research",
    # superpowers non-S but still A
    "superpowers:writing-plans","superpowers:executing-plans","superpowers:dispatching-parallel-agents",
    "superpowers:subagent-driven-development","superpowers:writing-skills",
    "superpowers:using-git-worktrees","superpowers:receiving-code-review","superpowers:requesting-code-review",
    "superpowers:finishing-a-development-branch",
    # claude-api (user works with SDKs)
    "claude-api",
]

# Tier A patterns (fuzzy: matches if name starts with)
TIER_A_PREFIXES = [
    "railway-","railway:","impeccable:","claude-md-management:",
    "commit-commands:","stripe:","sentry:","linear","posthog:","postman:",
    "figma:","Notion:","notion","chrome-devtools-mcp:","firecrawl",
    "code-review:","pr-review-toolkit:","feature-dev:","plugin-dev:",
]

# Tier D — kill list (stack-irrelevant, duplicates, framework-selfmgmt, niche)
TIER_D_EXACT = {
    # off-stack langs
    "java-coding-standards","jpa-patterns","springboot-patterns","springboot-security",
    "springboot-tdd","springboot-verification","kotlin-patterns","kotlin-testing",
    "kotlin-coroutines-flows","kotlin-exposed-patterns","kotlin-ktor-patterns",
    "compose-multiplatform-patterns","perl-patterns","perl-security","perl-testing",
    "cpp-coding-standards","cpp-testing","dotnet-patterns","csharp-testing","clickhouse-io",
    "django-patterns","django-security","django-tdd","django-verification",
    "laravel-patterns","laravel-security","laravel-tdd","laravel-verification",
    "laravel-plugin-discovery","hexagonal-architecture",
    # mobile
    "swift-actor-persistence","swift-concurrency-6-2","swift-protocol-di-testing","swiftui-patterns",
    "dart-flutter-patterns","flutter-dart-code-review","android-clean-architecture",
    "foundation-models-on-device",
    # off-domain
    "healthcare-phi-compliance","healthcare-emr-patterns","healthcare-cdss-patterns",
    "healthcare-eval-harness","hipaa-compliance","energy-procurement","production-scheduling",
    "quality-nonconformance","carrier-relationship-management","customs-trade-compliance",
    "returns-reverse-logistics","logistics-exception-management","inventory-demand-planning",
    "visa-doc-translate","evm-token-decimals","nodejs-keccak256","agent-payment-x402",
    "llm-trading-agent-security","defi-amm-security",
    # framework self-mgmt
    "omc-doctor","omc-setup","omc-reference","omc-teams","configure-ecc","ecc-tools-cost-audit",
    "nanoclaw-repl","openclaw-persona-forge","ralphinho-rfc-pipeline","career-ops",
    # niche
    "free-tool-strategy","opensource-pipeline","investor-outreach","investor-materials",
    "connections-optimizer","social-graph-ranker","x-api","customer-research","videodb",
    "pytorch-patterns","nutrient-document-processing","ai-first-engineering","remotion-video-creation",
    "gan-style-harness",
}

TIER_D_PREFIXES = [
    "document-skills:","example-skills:","huggingface-skills:",
    "rc:","amazon-location-service:","legalzoom:","adspirer-ads-agent:",
    "stagehand:","deploy-on-aws:","microsoft-docs:","mintlify:","ai-firstify:",
    "aikido:","ralph-loop:","data:","data-engineering:","followrabbit:",
    "searchfit-seo:",  # user already has search-first + content-strategy; these are duplicative for the self-described "ecommerce + marketing" stack
]

# Tier C — vertical, opt-in
TIER_C_EXACT = {
    "security-review","security-scan","security-bluebook-builder","security-bounty-hunter",
    "enterprise-agent-ops","knowledge-ops","automation-audit-ops","audit-claudemd",
    "research-ops","email-ops","messages-ops","finance-billing-ops","customer-billing-ops",
    "unified-notifications-ops","ecc-tools-cost-audit","dmux-workflows","claude-devfleet",
}
TIER_C_PREFIXES = ["vercel:"]  # user mostly uses Railway, not Vercel

# Tier B — everything else gets B by default (marketing, secondary integrations, general purpose)

def classify(name, description=None, source_kind=None, source_repo=None):  # unused args preserved for signature-compat
    n = name
    del description, source_kind, source_repo
    # Tier S
    if n in TIER_S:
        return "S"
    # Tier D (exact)
    if n in TIER_D_EXACT:
        return "D"
    # Tier D (prefix)
    for pref in TIER_D_PREFIXES:
        if n.startswith(pref):
            return "D"
    # Tier C
    if n in TIER_C_EXACT:
        return "C"
    for pref in TIER_C_PREFIXES:
        if n.startswith(pref):
            return "C"
    # Tier A (exact patterns + prefixes)
    if n in TIER_A_PATTERNS:
        return "A"
    for pref in TIER_A_PREFIXES:
        if n.startswith(pref):
            return "A"
    # default → B
    return "B"

# Stack-fit emoji: ✅ relevant, ⚠ sometimes, ❌ off-stack
STACK_FIT_RELEVANT = {
    "S": "✅",
    "A": "✅",
    "B": "⚠",
    "C": "⚠",
    "D": "❌",
}

# ═══════════════════════════════════════════════════════════════════
# Categorization (orthogonal to tier)
# ═══════════════════════════════════════════════════════════════════

def categorize(name, description, source_repo):
    n = name.lower()
    d = (description or "").lower()

    # Priority-ordered matching
    if any(k in n for k in ["wiki","learn","plan","compress","retro","remember","memory","continuous-learning","writer-memory","knowledge-ops"]):
        return "Knowledge & Memory"
    if any(k in n for k in ["frontend","nextjs","react","tailwind","svelte","nuxt","shadcn","figma","impeccable","ui-demo","frontend-slides"]) or "frontend" in d or "ui/" in d:
        return "Frontend & UI/Design"
    if "taste" in n or "emil" in n or "brutalist" in n or "minimalist" in n or "soft-skill" in n or "redesign" in n or "ui-ux-pro-max" in n or "liquid-glass" in n or "design-system" in n or "accessibility" in n:
        return "Frontend & UI/Design"
    if any(k in n for k in ["nestjs","fastify","api-design","backend","postgres","database","prisma","graphql","mcp-server-patterns","api-connector-builder"]):
        return "Backend & APIs"
    if any(k in n for k in ["railway","docker","terraform","deployment","github-ops","vercel","deploy-on-aws","canary","benchmark"]):
        return "Ops & Deployment"
    if any(k in n for k in ["security","aikido","hipaa","phi-compliance","defi","llm-trading-agent","evm-token","nodejs-keccak256","safety-guard","gateguard","perl-security","django-security","laravel-security","springboot-security"]):
        return "Security & Compliance"
    if any(k in n for k in ["tdd","testing","e2e","benchmark","verification","eval-harness","agent-eval","ai-regression"]):
        return "Testing & Verification"
    if any(k in n for k in ["research","deep-research","search-first","exa-search","documentation-lookup","iterative-retrieval","external-context","deep-dive","investigate","autoresearch"]):
        return "Research & Investigation"
    if any(k in n for k in ["ralph","ultrawork","ultraqa","autopilot","team","sciomc","council","santa-method","ccg","cancel","trace","deep-interview","agent-harness","agent-introspection","autonomous","continuous-agent","dmux-workflows","dispatching-parallel-agents","subagent"]):
        return "Agent Orchestration"
    if any(k in n for k in ["git-workflow","git-worktrees","commit","review","pr-review","release","code-review","code-tour","finishing-a-development-branch","receiving-code-review","requesting-code-review"]):
        return "Git & Release"
    if any(k in n for k in ["content-","copywriting","copy-editing","article-writing","beautiful_prose","brand-voice","crosspost","ad-creative","cold-email","email-sequence","social-content","community-marketing","revops","paid-ads","marketing","referral","pricing-strategy","analytics-tracking","ai-seo","seo","sales-enablement","customer-research","churn-prevention","lead-magnets","aso-audit","competitor-alternatives","form-cro","popup-cro","signup-flow-cro","onboarding-cro","paywall-upgrade-cro","page-cro","programmatic-seo","product-marketing","schema-markup","site-architecture","ab-test-setup","launch-strategy","content-engine","content-strategy","marketing-psychology","free-tool-strategy","marketing-ideas"]):
        return "Marketing & Content"
    if any(k in n for k in ["python-","rust-","golang-","go-","ruby-","kotlin-","swift-","dart-","flutter","django-","laravel-","springboot-","kotlin-","perl-","cpp-","dotnet-","csharp-","jpa-","clickhouse","hexagonal-"]):
        return "Language & Stack Patterns"
    if any(k in n for k in ["healthcare","logistics","energy","manufacturing","customs","quality","carrier","production-scheduling","inventory-demand","visa-doc","returns-reverse"]):
        return "Domain Verticals"
    if any(k in n.lower() for k in ["posthog","stripe","sentry","linear","notion","firecrawl","chrome-devtools","postman","rc:","adspirer","legalzoom","aikido","followrabbit","figma","googleworkspace","google-workspace","notebooklm","jira-integration","fal-ai","videodb","amazon-location","browser-qa","playground","stagehand"]):
        return "Platform Integrations"
    if any(k in n for k in ["huggingface","pytorch","data:","data-engineering:","airflow","warehouse","dbt-","dataset","transformers-js"]):
        return "Data / ML / ETL"
    if any(k in n for k in ["prompt-optimizer","strategic-compact","context-budget","token-budget","rules-distill","skill-","blueprint","skill-creator","skill-stocktake","skill-comply","workspace-surface-audit","context-engineering","ai-slop-cleaner","release","hud","configure-notifications","mcp-setup","terminal-ops","project-session-manager","project-flow-ops","product-lens","product-capability","repo-scan","codebase-onboarding","architecture-decision-records","remember","deepinit","hookify-rules","plankton-code-quality","coding-standards","java-coding-standards","cpp-coding-standards","regex-vs-llm","agentic-engineering","agent-harness-construction"]):
        return "Meta / Workflow / Claude Self-Mgmt"
    if any(k in n for k in ["omc","ecc","nanoclaw","openclaw","configure-ecc","career-ops","ralphinho","self-improve","skillify","learner"]):
        return "Framework Self-Mgmt"
    if any(k in n for k in ["document-skills:","example-skills:","mcp-builder","pptx","docx","xlsx","pdf","canvas-design","web-artifacts-builder","slack-gif-creator","algorithmic-art","theme-factory","webapp-testing","brand-guidelines","internal-comms","doc-coauthoring","nanoppt-skills","visual-verdict","click-path-audit","plankton-code-quality"]):
        return "Document & Artifact Creation"
    return "General / Uncategorized"

# ═══════════════════════════════════════════════════════════════════
# Classify all entries; merge duplicates by name
# ═══════════════════════════════════════════════════════════════════

# Keep only the best copy of each unique skill NAME (prefer user-scope symlinks > inspired > plugin)
by_name = {}
for e in entries:
    n = e["name"]
    rank = {"user": 3, "inspired": 2, "plugin": 1}.get(e["source_kind"], 0)
    if n not in by_name or rank > by_name[n]["_rank"]:
        e["_rank"] = rank
        by_name[n] = e

# Mark tier + category + stack_fit
for n, e in by_name.items():
    e["tier"] = classify(n, e.get("description",""), e["source_kind"], e["source_repo"])
    e["category"] = categorize(n, e.get("description",""), e["source_repo"])
    e["stack_fit"] = STACK_FIT_RELEVANT[e["tier"]]

# Find collision groups (same name appearing multiple times in entries across sources)
name_counter = Counter(e["name"] for e in entries)
collisions = {n: c for n, c in name_counter.items() if c > 1}

# ═══════════════════════════════════════════════════════════════════
# Render markdown
# ═══════════════════════════════════════════════════════════════════

def fmt_desc(d, maxlen=80):
    d = (d or "").replace("|","\\|").replace("\n"," ").strip()
    if len(d) > maxlen: d = d[:maxlen-1] + "…"
    return d or "_(no description)_"

def short_src(e):
    k = e["source_kind"]; r = e["source_repo"]
    if k == "user":     return f"user:{r}"
    if k == "inspired": return f"inspired:{r}"
    if k == "plugin":   return r
    return k

tier_counts = Counter(e["tier"] for e in by_name.values())
cat_counts = Counter(e["category"] for e in by_name.values())

md = []
md.append("# Claude Code Skills Catalog")
md.append("")
md.append(f"**Generated:** {os.popen('date +%Y-%m-%d').read().strip()}  ")
md.append(f"**Source:** `~/Desktop/ACTIVITIES/skills-inventory.json` (rebuild with `scripts/scan-skills.sh`)  ")
md.append(f"**Scope:** {len(entries)} total skill files discovered → {len(by_name)} unique names (collisions deduped by source-rank)")
md.append("")
md.append("## TL;DR")
md.append("")
md.append(f"Your Claude Code has **{len(entries)} skill files** across user-scope, inspired repos, and plugins — but only **{len(by_name)} unique names** (the rest are duplicate namespaces/collisions).")
md.append("")
md.append("**Ranked for _your_ stack** (Next.js + NestJS + Go/Beego + Fastify + Postgres + Prisma + Railway + Docker + Bun):")
md.append("")
md.append(f"| Tier | Count | What it means |")
md.append(f"|---|---|---|")
md.append(f"| **S** | {tier_counts.get('S',0):3d} | Use every session — core workflow + meta |")
md.append(f"| **A** | {tier_counts.get('A',0):3d} | Use often — stack-relevant + strong patterns |")
md.append(f"| **B** | {tier_counts.get('B',0):3d} | Use occasionally — marketing, secondary integrations |")
md.append(f"| **C** | {tier_counts.get('C',0):3d} | Domain-specific — opt-in when entering that domain |")
md.append(f"| **D** | {tier_counts.get('D',0):3d} | Wrong stack / dupes / framework-selfmgmt → candidate for pruning |")
md.append("")
md.append(f"**Action**: Run `bash universal-agentic-setup/scripts/prune-skills.sh --dry-run` to preview a safe disable of ~83 Tier-D skills. Then drop `--dry-run` to commit. Fully reversible (moves to `_disabled/`).")
md.append("")

# ═══════════════════════════════════════════════════════════════════
# Tier sections — descending utility
# ═══════════════════════════════════════════════════════════════════

md.append("## Index")
md.append("")
md.append("- [Tier S — every session](#tier-s--every-session)")
md.append("- [Tier A — often in your stack](#tier-a--often-in-your-stack)")
md.append("- [Tier B — occasionally](#tier-b--occasionally)")
md.append("- [Tier C — domain-specific, opt-in](#tier-c--domain-specific-opt-in)")
md.append("- [Tier D — prune candidates](#tier-d--prune-candidates)")
md.append("- [By category](#by-category)")
md.append("- [Hidden gems](#hidden-gems)")
md.append("- [Composition flows](#composition-flows)")
md.append("- [Naming collisions](#naming-collisions)")
md.append("- [Action plan](#action-plan)")
md.append("")

for tier, title, blurb in [
    ("S","Tier S — every session","Invoke on muscle memory. These are Claude-self-management + core workflow commands. Losing any of them degrades every session."),
    ("A","Tier A — often in your stack","Matches your confirmed stack (Next.js, NestJS, Go, Prisma, Railway, etc.) or is a domain-general developer tool. Reach for these reflexively in-domain."),
    ("B","Tier B — occasionally","Domain-general but not always-on. Marketing, secondary platforms, writing, experimental agent patterns. Worth keeping but skip if you don't use it in 6 weeks → re-classify."),
    ("C","Tier C — domain-specific, opt-in","Useful only when you enter that domain (security audit, heavy analytics deep-dive, Vercel-specific stuff). Keep, but don't let them crowd the palette."),
    ("D","Tier D — prune candidates","Wrong stack, pure duplicates, framework-self-mgmt, or vertical-domain irrelevant for ecommerce/web-dev. Candidates for `prune-skills.sh`."),
]:
    md.append(f"## {title}")
    md.append("")
    md.append(f"_{blurb}_")
    md.append("")
    md.append(f"**Count:** {tier_counts.get(tier,0)}")
    md.append("")
    md.append("| Skill | Category | Source | Purpose | Fit |")
    md.append("|---|---|---|---|---|")
    rows = sorted(
        [e for e in by_name.values() if e["tier"] == tier],
        key=lambda e: (e["category"], e["name"])
    )
    for e in rows:
        md.append(f"| `{e['name']}` | {e['category']} | {short_src(e)} | {fmt_desc(e['description'])} | {e['stack_fit']} |")
    md.append("")

# ═══════════════════════════════════════════════════════════════════
# By category
# ═══════════════════════════════════════════════════════════════════

md.append("## By category")
md.append("")
md.append("Same skills, grouped by what you'd reach for. Within each group, sorted by tier (S→D).")
md.append("")
md.append(f"**{len(cat_counts)} categories, {len(by_name)} unique skills:**")
md.append("")
for cat, count in cat_counts.most_common():
    md.append(f"- **{cat}** ({count})")
md.append("")

for cat in sorted(cat_counts, key=lambda c: -cat_counts[c]):
    md.append(f"### {cat}")
    md.append("")
    rows = sorted(
        [e for e in by_name.values() if e["category"] == cat],
        key=lambda e: ({"S":0,"A":1,"B":2,"C":3,"D":4}[e["tier"]], e["name"])
    )
    md.append("| Skill | Tier | Source | Purpose |")
    md.append("|---|---|---|---|")
    for e in rows:
        md.append(f"| `{e['name']}` | **{e['tier']}** | {short_src(e)} | {fmt_desc(e['description'])} |")
    md.append("")

# ═══════════════════════════════════════════════════════════════════
# Hidden gems
# ═══════════════════════════════════════════════════════════════════

GEMS = ["prompt-optimizer","strategic-compact","context-budget","token-budget-advisor",
        "rules-distill","skill-comply","skill-stocktake","blueprint","code-tour",
        "canary-watch","safety-guard","gateguard","ai-slop-cleaner","benchmark",
        "benchmark-models","eval-harness","agent-eval","repo-scan","workspace-surface-audit",
        "deepinit","codebase-onboarding","learner","remember"]
md.append("## Slash commands (separate from skills)")
md.append("")
md.append("Most Tier-S items (`/plan`, `/wiki`, `/learn`, `/compress`, `/retro`, `/careful`, `/freeze`, `/unfreeze`, `/autoplan`, `/pair`, `/crit`, `/extract`, `/ytdl`, `/research`) are **slash commands**, not skills — they live under `~/.claude/commands/*.md` and are invoked directly with `/<name>`. This catalog scans skills (`SKILL.md` files); commands have their own discoverability via the `/` palette.")
md.append("")
md.append("Listed for completeness:")
md.append("")
md.append("| Command | Tier | Purpose |")
md.append("|---|---|---|")
CMDS = [
    ("wiki","S","Search persistent llm-wiki for past notes on a topic"),
    ("learn","S","Append an insight to today's llm-wiki (tagged)"),
    ("retro","S","Weekly retrospective across all projects from IMPROVEMENT_STATE.json"),
    ("compress","S","Summarize this conversation into a handoff doc for the next session"),
    ("careful","S","Warn + confirm before destructive commands"),
    ("autoplan","S","Parallel CEO/eng/design/DX review before coding"),
    ("pair","A","Dispatch Explore + Plan agents in parallel on a question"),
    ("crit","A","Cross-model adversarial review (kimi + opencode + claude)"),
    ("research","A","Multi-source cited brief via Web + duckduckgo + context7"),
    ("extract","A","Structured extraction from URL/file with source grounding"),
    ("ytdl","B","yt-dlp → whisper → markdown in llm-wiki"),
    ("freeze","B","Lock edits to one directory for the session"),
    ("unfreeze","B","Release the freeze"),
]
for n, t, d in CMDS:
    md.append(f"| `/{n}` | **{t}** | {d} |")
md.append("")
md.append("## Hidden gems")
md.append("")
md.append("Claude-self-management skills that **amplify** every other skill. If you only learn 10 things, learn these.")
md.append("")
md.append("| Skill | Why it's a gem |")
md.append("|---|---|")
for n in GEMS:
    e = by_name.get(n)
    if e:
        md.append(f"| `{n}` | {fmt_desc(e['description'])} |")
md.append("")

# ═══════════════════════════════════════════════════════════════════
# Composition flows
# ═══════════════════════════════════════════════════════════════════

md.append("## Composition flows")
md.append("")
md.append("Skills compose. Some battle-tested pipelines:")
md.append("")
md.append("**Research → Plan → Implement:**")
md.append("1. `/research <topic>` — gather facts, get citations")
md.append("2. `/pair <question>` — dispatch Explore + Plan agents in parallel")
md.append("3. `/autoplan <feature>` — CEO/design/eng/DX review before coding")
md.append("4. Implement → `/verify` → `/commit-commands:commit`")
md.append("5. `/learn <insight>` — capture for next week's `/retro`")
md.append("")
md.append("**Debug session:**")
md.append("1. `/careful` — warn mode on")
md.append("2. `superpowers:systematic-debugging` — structured root-cause hunt")
md.append("3. `/verify` — confirm fix holds")
md.append("4. `/learn` — gotcha captured")
md.append("")
md.append("**UI build:**")
md.append("1. `taste-skill` or `emil-design-eng` — set the aesthetic")
md.append("2. `impeccable:distill` → `impeccable:arrange` → `impeccable:polish` — iterative refinement")
md.append("3. `benchmark` / `canary-watch` — confirm Core Web Vitals held")
md.append("")
md.append("**Knowledge compounding (Karpathy-style):**")
md.append("1. Every session: `memory-compiler.sh` hook auto-appends to today's wiki")
md.append("2. Mid-session: `/learn <insight>` for explicit captures")
md.append("3. Weekly: `/retro 7` distills the week into `weekly/YYYY-WNN.md`")
md.append("4. As-needed: `/wiki <topic>` queries past self")
md.append("")

# ═══════════════════════════════════════════════════════════════════
# Naming collisions
# ═══════════════════════════════════════════════════════════════════

md.append("## Naming collisions")
md.append("")
md.append(f"**{len(collisions)}** skill names appear in ≥2 sources. Claude Code uses the first-loaded copy; the rest are silent dead weight.")
md.append("")
md.append("Top 20 most-duplicated names:")
md.append("")
md.append("| Skill | Copies | Kept from | Others (prune candidates) |")
md.append("|---|---|---|---|")
dup_entries = defaultdict(list)
for e in entries:
    dup_entries[e["name"]].append(e)
top_dups = sorted(collisions.items(), key=lambda kv: -kv[1])[:20]
for name, count in top_dups:
    all_copies = dup_entries[name]
    best = by_name.get(name)
    if best is None:
        kept = "—"
        others = [short_src(x) for x in all_copies][:3]
    else:
        kept = short_src(best)
        others = [short_src(x) for x in all_copies if x["path"] != best["path"]][:3]
    md.append(f"| `{name}` | {count} | {kept} | {', '.join(others)}{' …' if count > 4 else ''} |")
md.append("")

# ═══════════════════════════════════════════════════════════════════
# Action plan
# ═══════════════════════════════════════════════════════════════════

md.append("## Action plan")
md.append("")
md.append("### Immediate (required before anything else fully works)")
md.append("")
md.append("```bash")
md.append("# 1. Activate secrets manager")
md.append("bw login                                                # interactive, once per machine")
md.append("bw config server https://<your-vault.com>               # ONLY if self-hosted Vaultwarden")
md.append("export BW_SESSION=\"$(bw unlock --raw)\"                  # per-shell session")
md.append("")
md.append("# 2. Export LLM API keys for /extract + langextract")
md.append("export GEMINI_API_KEY=\"...\"         # recommended (has free tier)")
md.append("export OPENAI_API_KEY=\"...\"         # alternative")
md.append("")
md.append("# 3. Restart Claude Code (palette refresh — critical)")
md.append("# Close and re-open Claude Code so the ~1,487 skill files register.")
md.append("```")
md.append("")
md.append("### Recommended next (low cost, high value)")
md.append("")
md.append("```bash")
md.append("# 4. Dry-run the Tier-D pruner")
md.append("bash universal-agentic-setup/scripts/prune-skills.sh --dry-run")
md.append("")
md.append("# 5. If output looks sane, commit the prune (reversible via mv-back)")
md.append("bash universal-agentic-setup/scripts/prune-skills.sh")
md.append("")
md.append("# 6. Activate carl (low-cost keyword-triggered rule injection)")
md.append("node ~/.claude/skills/_inspired/carl/bin/install.js")
md.append("```")
md.append("")
md.append("### Skip unless specific need")
md.append("")
md.append("- **BASE** (`base/bin/install.js`) — injects on every UserPromptSubmit → HIGH context cost. Don't activate unless you've decided you want JSON surfaces on every prompt.")
md.append("- **BMAD-METHOD** — needs `npm install` + framework buy-in. Cloned for reference only.")
md.append("- **PAUL** — activate per-project inside repos that benefit from the Plan-Apply-Unify loop. No global install.")
md.append("- **career-ops** — only if actively job-searching.")
md.append("")
md.append("### Regenerate this catalog")
md.append("")
md.append("```bash")
md.append("bash universal-agentic-setup/scripts/scan-skills.sh   # rebuild JSON inventory")
md.append("python3 /tmp/generate-catalog.py                                     # re-render MD (or commit the generator too)")
md.append("```")
md.append("")
md.append("### Reverse a prune")
md.append("")
md.append("```bash")
md.append("mv ~/.claude/skills/_disabled/<category>/<skill-name> ~/.claude/skills/")
md.append("# or restore a whole category")
md.append("mv ~/.claude/skills/_disabled/off-stack-langs/* ~/.claude/skills/")
md.append("```")
md.append("")

md.append("---")
md.append("")
md.append("_This catalog is point-in-time. Plugin lists change, repos get updated. Re-run `scan-skills.sh` quarterly or after major plugin installs._")

OUT.write_text("\n".join(md))
print(f"✓ wrote {OUT} ({len(md)} lines)")
