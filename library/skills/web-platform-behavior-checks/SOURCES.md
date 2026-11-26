# Sources

- Upstream: vercel-labs/agent-browser (https://github.com/vercel-labs/agent-browser), `skill-data/modern-web-guidance`, Apache-2.0.
- Taken: the rule-to-browser-check method and the probes for layout shift, reduced motion, color scheme and modal dialog, rewritten as plain Playwright snippets in `references/checks.md`.
- Not taken: the upstream agent-browser and modern-web-guidance CLIs; the `npx modern-web-guidance@latest` command was dropped.
- Added locally: the dialog probe runs against a local server with test data only, with a harmless trigger and a harmless background link.
