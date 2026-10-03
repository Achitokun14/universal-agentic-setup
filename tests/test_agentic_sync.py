#!/usr/bin/env python3
"""tests/test_agentic_sync.py — unittest suite for scripts/agentic_sync.py.

All runs target throwaway sandbox homes (tempfile), never the real home.
Run: python -m unittest discover -s tests -v
"""

import json
import re
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

REPO = Path(__file__).resolve().parent.parent
sys.path.insert(0, str(REPO / "scripts"))
import agentic_sync as usas  # noqa: E402

PY = sys.executable
SCRIPT = REPO / "scripts" / "agentic_sync.py"

SECRET_RE = re.compile(
    r"sk-[a-zA-Z0-9_-]{20,}|ghp_[a-zA-Z0-9]{20,}|xoxb-[a-zA-Z0-9-]{20,}"
    r"|AKIA[0-9A-Z]{16}|AIza[0-9A-Za-z_-]{35}|enc2:[a-f0-9]+"
)


def run_sync(*args, home):
    return subprocess.run(
        [PY, str(SCRIPT), *args, "--home", str(home)],
        capture_output=True, text=True, encoding="utf-8",
    )


class Sandbox(unittest.TestCase):
    def setUp(self):
        self.home = Path(tempfile.mkdtemp(prefix="uas-test-"))

    def tearDown(self):
        import shutil
        shutil.rmtree(self.home, ignore_errors=True)


# ------------------------------------------------------------ registry ----

class TestRegistrySchema(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.reg = json.loads((REPO / "agents" / "registry.json").read_text(encoding="utf-8"))
        cls.fmt = set(cls.reg["formats"])

    def test_entry_count_and_ids(self):
        ids = [a["id"] for a in self.reg["agents"]]
        self.assertEqual(len(ids), 26)
        self.assertEqual(len(set(ids)), 26)
        for i in ids:
            self.assertRegex(i, r"^[a-z][a-z0-9-]*$")

    def test_required_fields(self):
        for a in self.reg["agents"]:
            for key in ("id", "name", "vendor", "url", "detect", "context", "skills", "mcp", "manual"):
                self.assertIn(key, a, f"{a['id']}: missing {key}")
            self.assertRegex(a["url"], r"^https://")

    def test_formats_known(self):
        for a in self.reg["agents"]:
            fmt = (a.get("mcp") or {}).get("format")
            if fmt:
                self.assertIn(fmt, self.fmt, a["id"])

    def test_auto_agents_fully_specified(self):
        for a in self.reg["agents"]:
            if not a["manual"]:
                mcp = a["mcp"]
                self.assertTrue(mcp.get("path"), a["id"])
                self.assertTrue(mcp.get("format"), a["id"])

    def test_manual_agents_have_reason(self):
        for a in self.reg["agents"]:
            if a["manual"]:
                self.assertTrue(a.get("manual_reason", "").strip(), a["id"])

    def test_path_placeholders_valid(self):
        for a in self.reg["agents"]:
            ctx = a.get("context") or {}
            for spec in (ctx.get("files") or {}).values():
                if spec:
                    for p in spec:
                        self.assertTrue(p == "~" or p.startswith("~/") or p.startswith("{appdata}"), p)
            mcp = a.get("mcp") or {}
            if isinstance(mcp.get("path"), dict):
                for p in mcp["path"].values():
                    if p:
                        self.assertTrue(p.startswith("~/") or p.startswith("{appdata}"), p)


# ------------------------------------------------------------- secrets ----

class TestNoSecretValues(unittest.TestCase):
    def test_catalogs_and_registry_carry_no_secret_values(self):
        for rel in ("core/mcp/servers.json", "core/skills/catalog.json",
                    "core/tools/catalog.json", "agents/registry.json",
                    "docs/AGENTS-MATRIX.md"):
            path = REPO / rel
            if not path.exists():
                continue
            text = path.read_text(encoding="utf-8")
            hits = SECRET_RE.findall(text)
            self.assertEqual(hits, [], f"{rel}: secret-shaped strings {hits}")

    def test_env_entries_are_names_only(self):
        servers = json.loads((REPO / "core" / "mcp" / "servers.json").read_text(encoding="utf-8"))["servers"]
        for srv in servers:
            for name in srv.get("env") or []:
                self.assertRegex(name, r"^[A-Z][A-Z0-9_]*$")  # NAMES, uppercase identifiers
                self.assertNotRegex(name, r"[=:]")            # no key=value pairs
        # rendered entries use ${VAR} placeholders, never values
        env_srv = next(s for s in servers if s.get("env"))
        entry = usas.render_entry("mcpservers-json", env_srv)
        self.assertEqual(entry["env"], {n: "${" + n + "}" for n in env_srv["env"]})


# -------------------------------------------------------- golden renders ----

class TestGoldenRenders(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.duck = {"name": "duckduckgo", "description": "search", "transport": "stdio",
                    "command": "npx", "args": ["-y", "duckduckgo-mcp-server"], "env": []}
        cls.fire = {"name": "firecrawl", "description": "scrape", "transport": "stdio",
                    "command": "npx", "args": ["-y", "firecrawl-mcp"],
                    "env": ["FIRECRAWL_API_KEY"]}
        cls.remote = {"name": "example", "description": "demo", "transport": "http",
                      "url": "https://mcp.example.com/mcp", "env": []}

    def test_claude_json(self):
        out = usas.json_mcp_merge("", "claude-json", [self.duck, self.fire])
        self.assertEqual(json.loads(out), {
            "mcpServers": {
                "duckduckgo": {"command": "npx", "args": ["-y", "duckduckgo-mcp-server"]},
                "firecrawl": {"command": "npx", "args": ["-y", "firecrawl-mcp"],
                              "env": {"FIRECRAWL_API_KEY": "${FIRECRAWL_API_KEY}"}},
            }})

    def test_serverurl_json_uses_serverurl_for_remote(self):
        out = usas.json_mcp_merge("", "serverurl-json", [self.remote])
        self.assertEqual(json.loads(out)["mcpServers"]["example"], {"serverUrl": "https://mcp.example.com/mcp"})

    def test_mcpservers_json_url_for_remote(self):
        out = usas.json_mcp_merge("", "mcpservers-json", [self.remote])
        self.assertEqual(json.loads(out)["mcpServers"]["example"], {"url": "https://mcp.example.com/mcp"})

    def test_opencode_json(self):
        out = usas.json_mcp_merge("", "opencode-json", [self.duck, self.remote])
        data = json.loads(out)["mcp"]
        self.assertEqual(data["duckduckgo"], {"type": "local",
                                             "command": ["npx", "-y", "duckduckgo-mcp-server"]})
        self.assertEqual(data["example"], {"type": "remote", "url": "https://mcp.example.com/mcp"})

    def test_zed_json(self):
        out = usas.json_mcp_merge("", "zed-json", [self.duck])
        self.assertEqual(json.loads(out)["context_servers"]["duckduckgo"],
                         {"command": {"path": "npx", "args": ["-y", "duckduckgo-mcp-server"]}})

    def test_amp_json(self):
        out = usas.json_mcp_merge("", "amp-json", [self.duck])
        self.assertEqual(json.loads(out)["amp"]["mcpServers"]["duckduckgo"],
                         {"command": "npx", "args": ["-y", "duckduckgo-mcp-server"]})

    def test_crush_json(self):
        out = usas.json_mcp_merge("", "crush-json", [self.duck])
        self.assertEqual(json.loads(out)["mcp"]["duckduckgo"],
                         {"command": "npx", "args": ["-y", "duckduckgo-mcp-server"]})

    def test_codex_toml(self):
        out = usas.toml_mcp_merge("", [self.duck, self.fire])
        self.assertEqual(out,
                         '# [mcp_servers.duckduckgo] — managed by universal-agentic-setup\n'
                         '[mcp_servers.duckduckgo]\n'
                         'command = "npx"\n'
                         'args = ["-y", "duckduckgo-mcp-server"]\n'
                         '\n'
                         '# [mcp_servers.firecrawl] — managed by universal-agentic-setup\n'
                         '[mcp_servers.firecrawl]\n'
                         'command = "npx"\n'
                         'args = ["-y", "firecrawl-mcp"]\n'
                         'env = { FIRECRAWL_API_KEY = "${FIRECRAWL_API_KEY}" }\n')

    def test_codex_toml_preserves_unrelated_tables(self):
        existing = ('model = "o4"\n\n'
                    '[mcp_servers.user_tool]\ncommand = "mine"\n\n'
                    '[profile.default]\nsandbox = "workspace-write"\n')
        out = usas.toml_mcp_merge(existing, [self.duck])
        self.assertIn('model = "o4"', out)
        self.assertIn('[mcp_servers.user_tool]', out)
        self.assertIn('[profile.default]', out)
        self.assertIn('[mcp_servers.duckduckgo]', out)
        # user table keeps its position (top), managed table appended below it
        self.assertLess(out.index("[mcp_servers.user_tool]"), out.index("[mcp_servers.duckduckgo]"))


# ------------------------------------------------------- managed block ----

class TestManagedBlock(unittest.TestCase):
    def setUp(self):
        self.block = usas.core_block_text()

    def test_core_file_has_markers(self):
        self.assertIn("<!-- BEGIN: universal-agentic-setup managed block", self.block)
        self.assertIn("<!-- END: universal-agentic-setup managed block -->", self.block)

    def test_insert_into_fresh_file(self):
        out = usas.managed_block_apply("", self.block)
        self.assertEqual(out, self.block + "\n")

    def test_insert_after_existing_content(self):
        out = usas.managed_block_apply("My rules.\n", self.block)
        self.assertTrue(out.startswith("My rules.\n\n"))
        self.assertIn("BEGIN: universal-agentic-setup", out)

    def test_replace_existing_block_only(self):
        first = usas.managed_block_apply("Keep me.\n", self.block)
        newer = self.block.replace("Core (always on)", "Core (always on) v2")
        out = usas.managed_block_apply(first, newer)
        self.assertEqual(out, "Keep me.\n\n" + newer + "\n")

    def test_remove(self):
        first = usas.managed_block_apply("Before.\n\n" + self.block + "\n\nAfter.\n", self.block)
        out = usas.managed_block_remove(first)
        self.assertNotIn("BEGIN: universal-agentic-setup", out)
        self.assertIn("Before.", out)
        self.assertIn("After.", out)
        self.assertEqual(out, "Before.\n\nAfter.\n")


# ------------------------------------------------------ end-to-end sync ----

class TestApplyIdempotency(Sandbox):
    def test_apply_twice_byte_identical(self):
        (self.home / ".claude").mkdir()
        (self.home / ".codex").mkdir()
        (self.home / ".gemini").mkdir()
        (self.home / ".config" / "opencode").mkdir(parents=True)
        (self.home / ".claude.json").write_text(
            '{"firstRun": true, "mcpServers": {"user": {"command": "u"}}}', encoding="utf-8")
        (self.home / ".codex" / "config.toml").write_text(
            'model = "o4"\n\n[mcp_servers.user]\ncommand = "u"\n', encoding="utf-8")
        (self.home / ".gemini" / "settings.json").write_text(
            '{"theme": "auto", "mcpServers": {"user": {"command": "u"}}}', encoding="utf-8")

        r1 = run_sync("--apply", "--only", "claude-code,codex,gemini-cli,opencode", home=self.home)
        self.assertEqual(r1.returncode, 0, r1.stderr)

        def digest():
            return {str(p.relative_to(self.home)).replace("\\", "/"):
                    p.read_bytes() for p in sorted(self.home.rglob("*")) if p.is_file()}

        after1 = digest()
        self.assertTrue(any("AGENTS.md" in k for k in after1))
        self.assertTrue(any("config.toml" in k for k in after1))
        r2 = run_sync("--apply", "--only", "claude-code,codex,gemini-cli,opencode", home=self.home)
        self.assertEqual(r2.returncode, 0, r2.stderr)
        after2 = digest()
        self.assertEqual(after1, after2, "second apply must be byte-identical everywhere")


class TestManifestSequencing(Sandbox):
    """Regression: setup.sh runs agentic_sync twice (phase 1: --only claude-code,
    phase 4: full sweep). The second run must record every wired agent, keep the
    no-op agent's recorded state, and stay byte-identical on a third run."""

    def test_phase1_then_full_sweep_records_all(self):
        r1 = run_sync("--apply", "--only", "claude-code,codex,gemini-cli,opencode", home=self.home)
        self.assertEqual(r1.returncode, 0, r1.stderr)
        # full sweep ends with manual/no-op agents — must not discard records
        r2 = run_sync("--apply", home=self.home)
        self.assertEqual(r2.returncode, 0, r2.stderr)
        manifest = json.loads(
            (self.home / ".universal-agentic-manifest.json").read_text(encoding="utf-8"))
        recorded = set(manifest["agents"])
        for expect in ("claude-code", "codex", "gemini-cli", "opencode"):
            self.assertIn(expect, recorded)
        # no-op re-run of a previously recorded agent must NOT drop its state
        r3 = run_sync("--apply", "--only", "claude-code", home=self.home)
        self.assertEqual(r3.returncode, 0, r3.stderr)
        manifest3 = json.loads(
            (self.home / ".universal-agentic-manifest.json").read_text(encoding="utf-8"))
        self.assertIn("claude-code", manifest3["agents"])
        # byte-identical no-op re-run (manifest untouched when nothing changed)
        before = (self.home / ".universal-agentic-manifest.json").read_bytes()
        run_sync("--apply", "--only", "claude-code", home=self.home)
        after = (self.home / ".universal-agentic-manifest.json").read_bytes()
        self.assertEqual(before, after)


    def test_codex_toml_fresh_double_apply_identical(self):
        """Regression: managed table at file top (fresh config) — the second
        apply must not gain a leading blank line."""
        h1, h2 = tempfile.mkdtemp(prefix="uas-t1-"), tempfile.mkdtemp(prefix="uas-t2-")
        try:
            run_sync("--apply", "--only", "codex", home=h1)
            run_sync("--apply", "--only", "codex", home=h1)
            run_sync("--apply", "--only", "codex", home=h2)
            a = (Path(h1) / ".codex" / "config.toml").read_bytes()
            b = (Path(h2) / ".codex" / "config.toml").read_bytes()
            self.assertEqual(a, b)
            self.assertFalse(a.startswith(b"\n"))
        finally:
            import shutil
            shutil.rmtree(h1, ignore_errors=True)
            shutil.rmtree(h2, ignore_errors=True)


class TestUnrelatedKeysPreserved(Sandbox):
    def test_user_entries_and_top_level_keys_survive(self):
        (self.home / ".cursor").mkdir()
        (self.home / ".cursor" / "mcp.json").write_text(
            '{"mcpServers": {"mine": {"command": "mine", "args": ["--x"]}}, "cursorFlag": 1}',
            encoding="utf-8")
        r = run_sync("--apply", "--only", "cursor", home=self.home)
        self.assertEqual(r.returncode, 0, r.stderr)
        data = json.loads((self.home / ".cursor" / "mcp.json").read_text(encoding="utf-8"))
        self.assertEqual(data["cursorFlag"], 1)
        self.assertEqual(data["mcpServers"]["mine"], {"command": "mine", "args": ["--x"]})
        self.assertIn("duckduckgo", data["mcpServers"])
        self.assertIn("playwright", data["mcpServers"])


class TestUninstallRestores(Sandbox):
    def test_round_trip_returns_original_bytes(self):
        (self.home / ".codex").mkdir()
        original_toml = 'model = "o4"\n\n[mcp_servers.mine]\ncommand = "mine"\n'
        (self.home / ".codex" / "config.toml").write_text(original_toml, encoding="utf-8")
        original_md = "My own codex rules.\n"
        (self.home / ".codex" / "AGENTS.md").write_text(original_md, encoding="utf-8")

        r = run_sync("--apply", "--only", "codex", home=self.home)
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertIn("[mcp_servers.duckduckgo]",
                      (self.home / ".codex" / "config.toml").read_text(encoding="utf-8"))
        self.assertTrue(list(self.home.glob(".codex/config.toml.bak-*")),
                        "timestamped backup must exist")

        r = run_sync("--uninstall", "--apply", home=self.home)
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertEqual((self.home / ".codex" / "config.toml").read_text(encoding="utf-8"),
                         original_toml)
        self.assertEqual((self.home / ".codex" / "AGENTS.md").read_text(encoding="utf-8"),
                         original_md)
        self.assertFalse(list(self.home.glob(".codex/*.bak-*")), "backups cleaned up")
        self.assertFalse((self.home / ".universal-agentic-manifest.json").exists(),
                         "manifest removed")

    def test_created_files_removed_when_no_backup(self):
        r = run_sync("--apply", "--only", "cursor", home=self.home)
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertTrue((self.home / ".cursor" / "mcp.json").exists())
        r = run_sync("--uninstall", "--apply", home=self.home)
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertFalse((self.home / ".cursor" / "mcp.json").exists(),
                         "file created by us must be removed")


class TestDryRunWritesNothing(Sandbox):
    def test_default_dry_run_leaves_home_empty(self):
        (self.home / ".claude").mkdir()
        r = run_sync(home=self.home)
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertIn("DRY-RUN", r.stdout)
        leftovers = [p for p in self.home.rglob("*") if p.is_file()]
        self.assertEqual(leftovers, [])

    def test_skills_dry_run_prints_commands(self):
        r = run_sync("--skills", "--only", "claude-code", home=self.home)
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertIn("(dry-run) npx skills add", r.stdout)
        self.assertIn("anthropics/skills", r.stdout)


class TestDetectionAndFilters(Sandbox):
    def test_path_detection_and_skip(self):
        (self.home / ".codex").mkdir()
        (self.home / ".gemini").mkdir()
        sync = usas.Sync(self.home, dry_run=True)
        real_which = usas.shutil.which
        usas.shutil.which = lambda _name: None  # isolate from this machine's PATH
        try:
            det = sync.detect_all()
        finally:
            usas.shutil.which = real_which
        self.assertIn("codex", det)
        self.assertIn("gemini-cli", det)
        self.assertEqual(det["codex"], "path '~/.codex'")
        selected = sync.selected_agents(skip="gemini-cli")
        self.assertEqual([a["id"] for a in selected if a["id"] == "gemini-cli"], [])

    def test_unknown_id_rejected(self):
        r = run_sync("--only", "nope", home=self.home)
        self.assertEqual(r.returncode, 2)
        self.assertIn("unknown agent id", r.stderr)

    def test_manual_agents_never_written(self):
        (self.home / ".config" / "goose").mkdir(parents=True)
        r = run_sync("--apply", "--only", "goose", home=self.home)
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertIn("MANUAL", r.stdout)
        leftovers = [p for p in self.home.rglob("*") if p.is_file()]
        self.assertEqual(leftovers, [])


class TestMarkdownListing(unittest.TestCase):
    def test_matrix_generation(self):
        r = run_sync("--list", "--markdown", home=tempfile.mkdtemp(prefix="uas-md-"))
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertIn("# Agents matrix", r.stdout)
        self.assertIn("26 agents", r.stdout)
        for a in ("claude-code", "zed-json", "codex-toml", "Manual agents and why"):
            self.assertIn(a, r.stdout)
        committed = (REPO / "docs" / "AGENTS-MATRIX.md")
        if committed.exists():
            self.assertEqual(committed.read_text(encoding="utf-8").splitlines()[2:],
                             r.stdout.splitlines()[2:],
                             "docs/AGENTS-MATRIX.md is stale — regenerate with "
                             "`python scripts/agentic_sync.py --list --markdown > docs/AGENTS-MATRIX.md`")


if __name__ == "__main__":
    unittest.main()
