# Contributing to universal-agentic-setup

Thanks for considering a contribution! This project is **open source under MIT** — anyone can use, fork, and modify it freely. Contributions to **this** repository, however, follow a strict pull-request workflow.

## Contribution policy

**Direct pushes to `main` are disabled for everyone except the repository owner.**

To contribute:

1. **Fork** the repository to your GitHub account.
2. **Clone** your fork locally and create a feature branch:
   ```bash
   git checkout -b feat/short-description
   ```
3. **Make your changes** following the conventions below.
4. **Test** your changes — at minimum run:
   ```bash
   bash install.sh --dry-run user
   ```
   …and verify no `/home/<you>` paths leak into committed files.
5. **Commit** with a Conventional Commits message:
   ```
   feat: add <thing>
   fix: correct <bug>
   docs: clarify <section>
   chore: bump <version>
   refactor: <area>
   ```
6. **Push** to your fork and **open a Pull Request** against `main`.
7. **Wait for review.** The owner will review every PR personally. Expect questions. Expect requested changes. Not every PR is merged.

### What gets accepted

| Likely to merge | Likely to bounce |
|---|---|
| Bug fixes with clear repro | "Refactored everything" PRs |
| New scripts that fit the existing structure | Style-only churn |
| Documentation improvements | New deps without strong justification |
| Compatibility shims (new OS, new agent CLI) | Sweeping renames |
| Security fixes (file an issue first — see SECURITY.md) | Adding telemetry / phone-home |

### Coding conventions

- **Bash**: `set -euo pipefail`, quote variables, prefer `[[ ]]` over `[ ]`, idempotent operations
- **Python**: 3.10+, stdlib only when possible, `pathlib` over `os.path`
- **Paths**: NEVER hard-code `/home/<user>` — always use `$HOME` or `~/`
- **Secrets**: NEVER commit. Use placeholders like `sk-cp-...` or `${VAR}` references
- **Comments**: explain *why*, not *what*. Code that needs a comment to explain *what* is usually unclear code

### Testing locally

```bash
# Sanity check
bash install.sh --dry-run user
bash install.sh --dry-run project /tmp/some-test-repo

# Secret scan (must return nothing)
grep -rEI 'sk-[a-zA-Z0-9_-]{20,}|ghp_[a-zA-Z0-9]{20,}|AKIA[0-9A-Z]{16}|AIza[0-9A-Za-z_-]{35}' .

# Path leak scan (must return nothing)
grep -rEI '/home/[a-z]+/' .
```

### Commit signing

Sign your commits if you can. Not strictly required but appreciated:

```bash
git commit -S -m "fix: ..."
```

### Code of Conduct

By contributing you agree to follow `CODE_OF_CONDUCT.md`. Be civil, focus on the work, give people space to be wrong.

### Questions?

Open a **Discussion**, not an issue. Issues are for bugs, feature requests, and CVE reports only.

### License of contributions

By submitting a PR you agree that your contribution will be licensed under the same MIT license as the rest of the project. You retain copyright; you grant the project permission to redistribute under MIT.
