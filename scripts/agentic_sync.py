#!/usr/bin/env python3
"""agentic_sync.py — universal-agentic-setup v2 sync engine.

One agent-neutral source of truth (core/) rendered into every supported agent's
native config: managed AGENTS.md rules block + MCP server entries, preserving
all unrelated keys and user entries. Stdlib only (Python 3.9+).

Usage:
  python3 scripts/agentic_sync.py                    # detect + plan (dry-run, default)
  python3 scripts/agentic_sync.py --apply            # write configs
  python3 scripts/agentic_sync.py --apply --skills   # also install core skills via npx skills
  python3 scripts/agentic_sync.py --only claude-code,codex
  python3 scripts/agentic_sync.py --skip goose,amp
  python3 scripts/agentic_sync.py --list [--markdown]
  python3 scripts/agentic_sync.py --doctor
  python3 scripts/agentic_sync.py --uninstall        # remove managed blocks/MCP, restore .bak
  python3 scripts/agentic_sync.py --home /tmp/fake-home ...   # sandbox (tests/CI)

Safety: env entries carry variable NAMES only, rendered as ${VAR} placeholders.
Never writes secret values. Idempotent: applying twice leaves files byte-identical.
"""

import argparse
import json
import os
import re
import shutil
import subprocess
import sys
import time
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
VERSION_FILE = REPO_ROOT / "VERSION"
REGISTRY_PATH = REPO_ROOT / "agents" / "registry.json"
CORE_AGENTS_MD = REPO_ROOT / "core" / "AGENTS.md"
CORE_MCP_PATH = REPO_ROOT / "core" / "mcp" / "servers.json"
CORE_SKILLS_PATH = REPO_ROOT / "core" / "skills" / "catalog.json"
CORE_TOOLS_PATH = REPO_ROOT / "core" / "tools" / "catalog.json"

MARKER = "universal-agentic-setup"
MANIFEST_NAME = ".universal-agentic-manifest.json"
LEGACY_MANIFEST_REL = ".claude/.claude-universal-manifest.json"
BEGIN_PREFIX = f"<!-- BEGIN: {MARKER} managed block"
END_MARKER = f"<!-- END: {MARKER} managed block -->"
MANAGED_COMMENT = f"managed by {MARKER}"

BLOCK_RE = re.compile(
    r"[ \t]*" + re.escape(BEGIN_PREFIX) + r".*?" + re.escape(END_MARKER) + r"[ \t]*\n?",
    re.DOTALL,
)


# ---------------------------------------------------------------- helpers ----

def load_json(path):
    with open(path, encoding="utf-8") as fh:
        return json.load(fh)


def version():
    try:
        return VERSION_FILE.read_text(encoding="utf-8").strip()
    except OSError:
        return "dev"


def os_key():
    if sys.platform.startswith("win"):
        return "windows"
    if sys.platform == "darwin":
        return "macos"
    return "linux"


def resolve_home(explicit):
    """Home resolution order: --home > $UNIVERSAL_AGENTIC_HOME > $HOME > USERPROFILE."""
    if explicit:
        return Path(explicit).expanduser().resolve()
    for var in ("UNIVERSAL_AGENTIC_HOME", "HOME", "USERPROFILE"):
        val = os.environ.get(var)
        if val:
            return Path(val).expanduser().resolve()
    return Path.home()


def expand_path(spec, home):
    """Expand '~' and '{appdata}' placeholders against the given home."""
    appdata = home / "AppData" / "Roaming"
    text = spec.replace("{appdata}", str(appdata))
    if text == "~":
        return home
    if text.startswith("~/"):
        return home / text[2:]
    return Path(text)


def per_os(spec, okey):
    """registry per-OS field: dict {linux,macos,windows} (fall back to linux) or plain value."""
    if isinstance(spec, dict):
        if okey in spec:
            return spec[okey]
        return spec.get("linux")
    return spec


def rel_to_home(path, home):
    # Resolve both sides: macOS temp dirs live under /var -> /private/var, so a
    # resolved path never sits under an unresolved home.
    try:
        return str(Path(path).resolve().relative_to(Path(home).resolve()))
    except ValueError:
        return str(path)


# ------------------------------------------------------------ managed block ----

def core_block_text():
    return CORE_AGENTS_MD.read_text(encoding="utf-8").strip("\n")


def managed_block_apply(text, block):
    """Insert/replace the managed block in markdown text. Deterministic."""
    block_lines = block.splitlines()
    if BEGIN_PREFIX in text:
        cleaned = BLOCK_RE.sub("", text)
        text = cleaned
    body = text.rstrip("\n")
    if body:
        return body + "\n\n" + "\n".join(block_lines) + "\n"
    return "\n".join(block_lines) + "\n"


def managed_block_remove(text):
    cleaned = BLOCK_RE.sub("", text)
    cleaned = re.sub(r"\n{3,}", "\n\n", cleaned)
    return cleaned.rstrip("\n") + ("\n" if cleaned.strip() else "")


# ------------------------------------------------------------- MCP renderers ----

def _env_map(env_names):
    return {name: "${" + name + "}" for name in env_names}


def render_entry(fmt, server):
    """Render one catalog server entry in an agent-native JSON shape."""
    transport = server.get("transport", "stdio")
    env = _env_map(server.get("env") or [])
    if transport == "stdio":
        base = {"command": server["command"], "args": list(server.get("args") or [])}
        if env:
            base["env"] = env
        if fmt == "opencode-json":
            entry = {"type": "local", "command": [server["command"]] + list(server.get("args") or [])}
            if env:
                entry["env"] = env
            return entry
        if fmt == "zed-json":
            cmd = {"path": server["command"], "args": list(server.get("args") or [])}
            if env:
                cmd["env"] = env
            return {"command": cmd}
        if fmt == "crush-json":
            entry = {"command": server["command"], "args": list(server.get("args") or [])}
            if env:
                entry["env"] = env
            return entry
        return base  # claude-json / mcpservers-json / serverurl-json / amp-json
    # remote
    url_key = "serverUrl" if fmt == "serverurl-json" else "url"
    if fmt == "opencode-json":
        return {"type": "remote", "url": server["url"]}
    return {url_key: server["url"]}


def _container(fmt, data, create=True):
    """Return (container_dict, setter) for the format's MCP entries inside data."""
    if fmt in ("claude-json", "mcpservers-json", "serverurl-json"):
        data.setdefault("mcpServers", {})
        return data["mcpServers"]
    if fmt == "amp-json":
        data.setdefault("amp", {})
        if not isinstance(data["amp"], dict):
            raise ValueError("'amp' key is not an object")
        data["amp"].setdefault("mcpServers", {})
        return data["amp"]["mcpServers"]
    if fmt in ("opencode-json", "crush-json"):
        data.setdefault("mcp", {})
        return data["mcp"]
    if fmt == "zed-json":
        data.setdefault("context_servers", {})
        return data["context_servers"]
    raise ValueError(f"unknown JSON MCP format: {fmt}")


def _drop_if_empty(fmt, data):
    if fmt in ("claude-json", "mcpservers-json", "serverurl-json"):
        if isinstance(data.get("mcpServers"), dict) and not data["mcpServers"]:
            del data["mcpServers"]
    elif fmt == "amp-json":
        amp = data.get("amp")
        if isinstance(amp, dict) and isinstance(amp.get("mcpServers"), dict) and not amp["mcpServers"]:
            del amp["mcpServers"]
        if isinstance(amp, dict) and not amp:
            del data["amp"]
    elif fmt in ("opencode-json", "crush-json"):
        if isinstance(data.get("mcp"), dict) and not data["mcp"]:
            del data["mcp"]
    elif fmt == "zed-json":
        if isinstance(data.get("context_servers"), dict) and not data["context_servers"]:
            del data["context_servers"]


def json_mcp_merge(existing_text, fmt, servers):
    """Merge managed servers into a JSON config; returns new text or None if unchanged."""
    data = json.loads(existing_text) if existing_text.strip() else {}
    if not isinstance(data, dict):
        raise ValueError("config root is not a JSON object")
    container = _container(fmt, data)
    for srv in servers:
        container[srv["name"]] = render_entry(fmt, srv)
    return dump_json(data)


def json_mcp_remove(existing_text, fmt, names):
    """Remove managed server names; returns (new_text_or_None, remaining_names)."""
    if not existing_text.strip():
        return None, []
    data = json.loads(existing_text)
    if not isinstance(data, dict):
        return None, []
    container = _container(fmt, data)
    remaining = [n for n in names if n in container]
    for n in names:
        container.pop(n, None)
    _drop_if_empty(fmt, data)
    return dump_json(data), remaining


def dump_json(data):
    return json.dumps(data, indent=2, ensure_ascii=False) + "\n"


# ------------------------------------------------------------------ TOML ----

def _toml_table_header(name):
    return f"[mcp_servers.{name}]"


def _toml_render_table(server):
    name = server["name"]
    lines = [f"# {_toml_table_header(name)} — {MANAGED_COMMENT}", _toml_table_header(name)]
    if server.get("transport") == "stdio":
        lines.append(f"command = {json.dumps(server['command'])}")
        args = list(server.get("args") or [])
        if args:
            lines.append(f"args = {json.dumps(args)}")
        env = _env_map(server.get("env") or [])
        if env:
            inline = ", ".join(f"{k} = {json.dumps(v)}" for k, v in env.items())
            lines.append("env = { " + inline + " }")
    else:
        lines.append(f"url = {json.dumps(server['url'])}")
    return "\n".join(lines) + "\n"


def _toml_find_table(lines, name):
    """Return (start, end) line indexes (exclusive end) of the table, or None."""
    header = _toml_table_header(name)
    for i, line in enumerate(lines):
        stripped = line.strip()
        if not (stripped == header or stripped.startswith(header + " ")):
            continue
        start = i
        if i > 0 and lines[i - 1].strip().startswith("#") and MANAGED_COMMENT in lines[i - 1]:
            start = i - 1
        while start > 0 and lines[start - 1].strip() == "":
            start -= 1
        j = i + 1
        while j < len(lines) and not lines[j].lstrip().startswith("["):
            j += 1
        end = j
        # do not swallow the next table's managed comment or separating blanks
        while end > (i + 1):
            prev = lines[end - 1].strip()
            if prev == "" or (prev.startswith("#") and MANAGED_COMMENT in prev):
                end -= 1
            else:
                break
        return start, end
    return None


def toml_mcp_merge(existing_text, servers):
    lines = existing_text.splitlines()
    out = list(lines)
    for srv in servers:
        span = _toml_find_table(out, srv["name"])
        if span:
            del out[span[0]:span[1]]
            # a separator blank above the deleted span must not become a
            # leading blank line (breaks byte-idempotency)
            while out and out[0].strip() == "":
                out.pop(0)
        body = "\n".join(out).rstrip("\n")
        block = _toml_render_table(srv)
        new = body + "\n\n" + block if body else block
        out = new.splitlines()
    return ("\n".join(out) + "\n") if out else ""


def toml_mcp_remove(existing_text, names):
    out = existing_text.splitlines()
    removed = []
    for name in names:
        span = _toml_find_table(out, name)
        if span:
            del out[span[0]:span[1]]
            removed.append(name)
    text = "\n".join(out)
    text = re.sub(r"\n{3,}", "\n\n", text)
    if not text.strip():
        return "", removed
    return text.rstrip("\n") + "\n", removed


# ------------------------------------------------------------- file actions ----

class FileStore:
    """Read/write with timestamped backups; only writes when content changes."""

    def __init__(self, home, dry_run):
        self.home = home
        self.dry = dry_run
        self.changed = []   # list of (rel_path, kind)
        self.backups = {}   # rel path -> [backup rel paths]

    def backup(self, path):
        if not path.exists():
            return None
        stamp = time.strftime("%Y%m%dT%H%M%S")
        bak = path.with_name(path.name + f".bak-{stamp}")
        n = 0
        while bak.exists():
            n += 1
            bak = path.with_name(path.name + f".bak-{stamp}-{n}")
        if not self.dry:
            shutil.copy2(path, bak)
        rel = rel_to_home(bak, self.home)
        self.backups.setdefault(rel_to_home(path, self.home), []).append(rel)
        return bak

    def write(self, path, new_text, label):
        old = path.read_text(encoding="utf-8") if path.exists() else None
        if old is not None and old == new_text:
            return False
        existed = path.exists()
        if not self.dry:
            if existed:
                self.backup(path)
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text(new_text, encoding="utf-8", newline="\n")
        self.changed.append((rel_to_home(path, self.home), "updated" if existed else "created"))
        return True

    def restore_newest_backup(self, path):
        baks = sorted(path.parent.glob(path.name + ".bak-*"))
        if not baks:
            return None
        newest = baks[-1]
        if not self.dry:
            shutil.copy2(newest, path)
        return newest

    def delete_backups(self, path):
        for bak in path.parent.glob(path.name + ".bak-*"):
            if not self.dry:
                bak.unlink()


# ------------------------------------------------------------------ core ----

class Sync:
    def __init__(self, home, dry_run=True):
        self.home = Path(home)
        self.store = FileStore(self.home, dry_run)
        self.dry = dry_run
        self.registry = load_json(REGISTRY_PATH)
        self.agents = self.registry["agents"]
        self.mcp_catalog = load_json(CORE_MCP_PATH)["servers"]
        self.skills_catalog = load_json(CORE_SKILLS_PATH)
        self.tools_catalog = load_json(CORE_TOOLS_PATH)
        self.manifest_path = self.home / MANIFEST_NAME
        self.okey = os_key()
        self.core_text = core_block_text()
        self.default_servers = [s for s in self.mcp_catalog if s.get("default_enabled")]
        self.detected = {}

    # -- detection --------------------------------------------------------
    def detect_agent(self, agent):
        hints = agent.get("detect") or {}
        for binname in hints.get("binaries") or []:
            if shutil.which(binname):
                return f"binary '{binname}'"
        for spec in hints.get("paths") or []:
            if expand_path(spec, self.home).exists():
                return f"path '~/{rel_to_home(expand_path(spec, self.home), self.home)}'"
        return None

    def detect_all(self):
        for agent in self.agents:
            how = self.detect_agent(agent)
            if how:
                self.detected[agent["id"]] = how
        return self.detected

    # -- selection --------------------------------------------------------
    def selected_agents(self, only=None, skip=None):
        only_ids = {s.strip() for s in (only or "").split(",") if s.strip()}
        skip_ids = {s.strip() for s in (skip or "").split(",") if s.strip()}
        unknown = (only_ids | skip_ids) - {a["id"] for a in self.agents}
        if unknown:
            fail(f"unknown agent id(s): {', '.join(sorted(unknown))}. "
                 f"Run --list for the registry.")
        out = []
        for agent in self.agents:
            if only_ids and agent["id"] not in only_ids:
                continue
            if skip_ids and agent["id"] in skip_ids:
                continue
            out.append(agent)
        return out

    # -- context files ------------------------------------------------------
    def context_paths(self, agent):
        ctx = agent.get("context") or {}
        files = ctx.get("files")
        if not files:
            return []
        specs = per_os(files, self.okey) or []
        return [expand_path(s, self.home) for s in specs]

    # -- mcp file -----------------------------------------------------------
    def mcp_path(self, agent):
        mcp = agent.get("mcp") or {}
        spec = mcp.get("path")
        if not spec:
            return None
        spec = per_os(spec, self.okey)
        return expand_path(spec, self.home) if spec else None

    def mcp_format(self, agent):
        return (agent.get("mcp") or {}).get("format")

    # -- apply ---------------------------------------------------------------
    def apply_agent(self, agent):
        aid = agent["id"]
        rec = {"context": [], "mcp": None, "managed_mcp": [], "created": [], "backups": {}}

        def harvest():
            # snapshot (do not consume — the plan printer and save gate read
            # the same list); dedupe so context+mcp harvests don't double-count
            for rel, kind in list(self.store.changed):
                if kind == "created" and rel not in rec["created"]:
                    rec["created"].append(rel)

        # (a) context managed block
        for path in self.context_paths(agent):
            old = path.read_text(encoding="utf-8") if path.exists() else ""
            new = managed_block_apply(old, self.core_text)
            if self.store.write(path, new, f"{aid}: context block"):
                rec["context"].append(rel_to_home(path, self.home))
        harvest()
        # (b) MCP merge
        mpath = self.mcp_path(agent)
        fmt = self.mcp_format(agent)
        if mpath and fmt:
            if fmt == "codex-toml":
                old = mpath.read_text(encoding="utf-8") if mpath.exists() else ""
                new = toml_mcp_merge(old, self.default_servers)
                if self.store.write(mpath, new, f"{aid}: mcp tables"):
                    rec["mcp"] = rel_to_home(mpath, self.home)
                    rec["managed_mcp"] = [s["name"] for s in self.default_servers]
            else:
                old = mpath.read_text(encoding="utf-8") if mpath.exists() else ""
                try:
                    new = json_mcp_merge(old, fmt, self.default_servers)
                except (ValueError, json.JSONDecodeError) as exc:
                    say(f"  ! {aid}: skipping {mpath} — {exc}")
                    return rec
                if self.store.write(mpath, new, f"{aid}: mcp servers"):
                    rec["mcp"] = rel_to_home(mpath, self.home)
                    rec["managed_mcp"] = [s["name"] for s in self.default_servers]
            harvest()
        return rec

    def print_manual_instructions(self, agent):
        aid = agent["id"]
        say(f"  ■ {aid}: MANUAL — {agent.get('manual_reason', 'see registry')}")
        ctx = agent.get("context") or {}
        if ctx.get("note"):
            say(f"      context: {ctx['note']}")
        skills = agent.get("skills") or {}
        if skills.get("dirs"):
            say(f"      skills dirs: {', '.join(skills['dirs'])}")
        mcp = agent.get("mcp") or {}
        if mcp.get("note"):
            say(f"      mcp: {mcp['note']}")
        url = agent.get("url")
        if url:
            say(f"      docs: {url}")

    # -- manifest -------------------------------------------------------------
    def load_manifest(self):
        if self.manifest_path.exists():
            try:
                return load_json(self.manifest_path)
            except json.JSONDecodeError:
                say(f"  ! manifest unreadable: {self.manifest_path}")
        return None

    def save_manifest(self, records):
        now = time.strftime("%Y-%m-%dT%H:%M:%S")
        old = self.load_manifest() or {}
        agents = old.get("agents", {})
        for aid, rec in records.items():
            prev = agents.get(aid, {})
            rec_has_state = any([rec.get("context"), rec.get("mcp")])
            prev_has_state = any([prev.get("context"), prev.get("mcp")])
            if not rec_has_state:
                if not prev_has_state:
                    agents.pop(aid, None)  # never had state → nothing to record
                # else: no-op this run, but the previously recorded state stands
                continue
            ctx = list(prev.get("context") or [])
            for rel in rec.get("context") or []:
                if rel not in ctx:
                    ctx.append(rel)
            managed = list(prev.get("managed_mcp") or [])
            for name in rec.get("managed_mcp") or []:
                if name not in managed:
                    managed.append(name)
            merged = {
                "context": ctx,
                "mcp": rec.get("mcp") or prev.get("mcp"),
                "managed_mcp": managed,
                "created": sorted(set(prev.get("created", [])) | set(rec.get("created", []))),
                "backups": {**prev.get("backups", {}), **(rec.get("backups") or {})},
            }
            agents[aid] = merged
        manifest = {
            "name": MARKER,
            "version": version(),
            "installed_at": old.get("installed_at", now),
            "updated_at": now,
            "agents": agents,
        }
        if not self.dry:
            self.manifest_path.parent.mkdir(parents=True, exist_ok=True)
            if agents:
                self.manifest_path.write_text(dump_json(manifest), encoding="utf-8")
            else:
                self.manifest_path.unlink(missing_ok=True)

    # -- uninstall --------------------------------------------------------------
    def uninstall_agent(self, aid, rec):
        home = self.home
        changed = False
        for rel in rec.get("context", []):
            path = home / rel
            if not path.exists():
                continue
            restored = self.store.restore_newest_backup(path)
            text = path.read_text(encoding="utf-8")
            new = managed_block_remove(text)
            if new == text:
                say(f"  − {aid}: {rel} restored from backup (no managed block left)")
            elif restored is None and not new.strip() and rel in rec.get("created", []):
                if not self.dry:
                    path.unlink()
                say(f"  − {aid}: removed {rel} (was created by us)")
            elif self.store.write(path, new, f"{aid}: remove context block"):
                say(f"  − {aid}: stripped managed block from {rel}"
                    + (" (backup restored)" if restored else ""))
            self.store.delete_backups(path)
            changed = True
        mcp_rel = rec.get("mcp")
        if mcp_rel:
            path = home / mcp_rel
            if path.exists():
                restored = self.store.restore_newest_backup(path)
                fmt = self.mcp_format_by_id(aid)
                names = rec.get("managed_mcp") or []
                text = path.read_text(encoding="utf-8")
                if fmt == "codex-toml":
                    new, removed = toml_mcp_remove(text, names)
                else:
                    new, removed = json_mcp_remove(text, fmt, names)
                if restored is not None and not removed:
                    say(f"  − {aid}: {mcp_rel} restored from backup (no managed entries left)")
                elif restored is None and new.strip() in ("", "{}") and mcp_rel in rec.get("created", []):
                    if not self.dry:
                        path.unlink()
                    say(f"  − {aid}: removed {mcp_rel} (was created by us)")
                else:
                    self.store.write(path, new, f"{aid}: remove mcp entries")
                    say(f"  − {aid}: removed {len(removed)} managed MCP entr"
                        f"{'y' if len(removed) == 1 else 'ies'} from {mcp_rel}"
                        + (" (backup restored)" if restored else ""))
                self.store.delete_backups(path)
                changed = True
        return changed

    def mcp_format_by_id(self, aid):
        for agent in self.agents:
            if agent["id"] == aid:
                return self.mcp_format(agent)
        return None

    # -- skills -----------------------------------------------------------------
    def skills_commands(self):
        cmds = []
        for entry in self.skills_catalog.get("core", []):
            cmds.append(["npx", "skills", "add", entry["source"],
                         "--skill", entry["skill"], "-g", "-y"])
        return cmds

    def run_skills(self):
        cmds = self.skills_commands()
        say(f"skills: {len(cmds)} core catalog entries")
        for cmd in cmds:
            if self.dry:
                say("  (dry-run) " + " ".join(cmd))
            else:
                say("  $ " + " ".join(cmd))
                subprocess.run(cmd, check=False)


# ---------------------------------------------------------------- output ----

def say(msg):
    print(msg)


def fail(msg):
    print(f"error: {msg}", file=sys.stderr)
    sys.exit(2)


# ---------------------------------------------------------------- commands ----

def cmd_list(sync, markdown=False):
    if markdown:
        print(list_markdown(sync), end="")
        return 0
    say(f"universal-agentic-setup v{version()} — agent registry "
        f"({len(sync.agents)} agents, "
        f"{sum(1 for a in sync.agents if not a['manual'])} automatable, "
        f"{sum(1 for a in sync.agents if a['manual'])} manual)\n")
    header = f"{'ID':<16} {'AGENT':<28} {'MCP FORMAT':<18} {'MANUAL':<7} DETECTED"
    say(header)
    say("-" * len(header))
    for agent in sync.agents:
        fmt = (agent.get("mcp") or {}).get("format") or "—"
        det = sync.detected.get(agent["id"], "")
        say(f"{agent['id']:<16} {agent['name'][:27]:<28} {fmt:<18} "
            f"{'yes' if agent['manual'] else 'no':<7} {det}")
    say("\nUse --doctor for diagnostics, default run for a plan, --apply to write configs.")
    return 0


def list_markdown(sync):
    now = time.strftime("%Y-%m-%d")
    lines = []
    ap = lines.append
    ap("<!-- GENERATED by `python scripts/agentic_sync.py --list --markdown` — do not edit by hand. -->")
    ap(f"<!-- Regenerate: python scripts/agentic_sync.py --list --markdown > docs/AGENTS-MATRIX.md (last: {now}) -->")
    ap("")
    ap("# Agents matrix")
    ap("")
    ap(f"`universal-agentic-setup` v{version()} knows **{len(sync.agents)} agents**: "
       f"**{sum(1 for a in sync.agents if not a['manual'])}** are wired automatically "
       f"(managed rules block + MCP merge in the agent's native format), "
       f"**{sum(1 for a in sync.agents if a['manual'])}** are manual (printed instructions). "
       "Paths below are user-scope; `~` = home directory, `{appdata}` = Windows roaming AppData.")
    ap("")
    ap("| ID | Agent | Vendor | Context file | Skills dir(s) | MCP config | MCP format |")
    ap("|---|---|---|---|---|---|---|")
    for a in sync.agents:
        ctx = a.get("context") or {}
        files = ctx.get("files")
        if files:
            spec = per_os(files, "linux")
            ctx_cell = f"`{spec[0]}`" if isinstance(spec, list) and spec else "`—`"
        else:
            ctx_cell = "*(project-scope / none)*"
        skills = (a.get("skills") or {}).get("dirs") or []
        skills_cell = ", ".join(f"`{s}`" for s in skills[:2]) if skills else "*(none)*"
        mcp = a.get("mcp") or {}
        mcp_spec = mcp.get("path")
        if isinstance(mcp_spec, dict):
            mcp_spec = mcp_spec.get("linux")
        mcp_cell = f"`{mcp_spec}`" if mcp_spec else "*(see manual note)*"
        fmt = mcp.get("format")
        fmt_cell = f"`{fmt}`" if fmt else "*(manual)*"
        ap(f"| `{a['id']}` | [{a['name']}]({a['url']}) | {a['vendor']} | {ctx_cell} | {skills_cell} | {mcp_cell} | {fmt_cell} |")
    ap("")
    ap("## Manual agents and why")
    ap("")
    for a in sync.agents:
        if a["manual"]:
            ap(f"- **{a['name']}** (`{a['id']}`) — {a['manual_reason']}")
    ap("")
    ap("## Notes")
    ap("")
    ap("- Detection: a binary on PATH (e.g. `codex`) or an existing config path under `~` "
       "(e.g. `~/.codex`). `--only`/`--skip` override detection per id.")
    ap("- All renderers preserve unrelated keys and user entries; every modified file gets a "
       "timestamped `.bak` sibling first. Env entries are `${VAR}` name placeholders — never values.")
    ap("- Windows equivalents: most `~/.config/...` tools use the same path under the user "
       "profile; Zed uses `{appdata}\\Zed`. Unverified per-Windows paths default to the POSIX path.")
    ap("- Sources: every entry was verified against the vendor documentation linked in the "
       "Agent column (2026-10 audit).")
    return "\n".join(lines) + "\n"


def cmd_doctor(sync):
    say(f"universal-agentic-setup v{version()} — doctor")
    say(f"  python : {sys.version.split()[0]} ({sys.platform})")
    say(f"  home   : {sync.home}")
    say(f"  repo   : {REPO_ROOT}")
    npx = shutil.which("npx")
    say(f"  npx    : {npx or 'missing (--skills needs it)'}")
    node = shutil.which("node")
    say(f"  node   : {node or 'missing (--skills needs it)'}")
    # core files
    for label, path in (("core/AGENTS.md", CORE_AGENTS_MD),
                        ("core/mcp/servers.json", CORE_MCP_PATH),
                        ("core/skills/catalog.json", CORE_SKILLS_PATH),
                        ("core/tools/catalog.json", CORE_TOOLS_PATH),
                        ("agents/registry.json", REGISTRY_PATH)):
        try:
            if path.suffix == ".json":
                load_json(path)
            else:
                path.read_text(encoding="utf-8")
            say(f"  ✓ {label}")
        except Exception as exc:  # noqa: BLE001 — doctor reports, not raises
            say(f"  ✗ {label}: {exc}")
    # migration
    legacy = sync.home / LEGACY_MANIFEST_REL
    if legacy.exists():
        try:
            v1 = load_json(legacy).get("version", "?")
        except Exception:  # noqa: BLE001
            v1 = "?"
        say(f"  ! v1 manifest detected ({legacy}, version {v1}).")
        say("      Run the v1 './setup --uninstall' (v1.18.0 checkout) before applying v2 — "
            "see MIGRATION.md.")
    # detected agents
    det = sync.detect_all()
    say(f"  agents : {len(sync.agents)} in registry, {len(det)} detected here")
    for aid, how in sorted(det.items()):
        say(f"    • {aid} ({how})")
    if sync.manifest_path.exists():
        say(f"  manifest: {sync.manifest_path} (v2 state present)")
    return 0


def cmd_plan_apply(sync, apply=False, only=None, skip=None, skills=False):
    det = sync.detect_all()
    selected = sync.selected_agents(only, skip)
    mode = "APPLY" if apply else "DRY-RUN (default; pass --apply to write)"
    say(f"universal-agentic-setup v{version()} — {mode}")
    say(f"  home: {sync.home}")
    say(f"  mcp catalog: {len(sync.mcp_catalog)} servers "
        f"({len(sync.default_servers)} default-enabled) → agents/registry.json "
        f"({len(selected)} selected)\n")

    legacy = sync.home / LEGACY_MANIFEST_REL
    if legacy.exists():
        say("  ! v1 manifest detected — run v1 './setup --uninstall' first (MIGRATION.md)\n")

    records = {}
    changed_total = 0
    only_ids = {s.strip() for s in (only or "").split(",") if s.strip()}
    for agent in selected:
        aid = agent["id"]
        detected = aid in det or aid in only_ids
        if agent["manual"]:
            say(f"■ {aid} — manual")
            sync.print_manual_instructions(agent)
            say("")
            continue
        if not detected:
            say(f"○ {aid} — not detected, skipping (force with --only {aid})")
            say("")
            continue
        how = det.get(aid, "forced via --only")
        say(f"● {aid} — detected via {how}")
        rec = sync.apply_agent(agent)
        changed_total += len(sync.store.changed)
        for rel, kind in sync.store.changed:
            say(f"  {'+' if kind == 'created' else '~'} {rel}" + ("  (dry-run)" if sync.dry else ""))
        sync.store.changed = []
        records[aid] = rec
        say("")
    if skills:
        sync.run_skills()
        say("")
    if apply:
        if changed_total or sync.load_manifest() is None:
            sync.save_manifest(records)
        say(f"done — manifest: {sync.manifest_path}")
    else:
        say("dry-run complete — nothing written. Re-run with --apply to write configs.")
    return 0


def cmd_uninstall(sync, only=None, skip=None):
    manifest = sync.load_manifest()
    if not manifest or not manifest.get("agents"):
        say(f"nothing to uninstall — no v2 state at {sync.manifest_path}")
        legacy = sync.home / LEGACY_MANIFEST_REL
        if legacy.exists():
            say(f"note: v1 manifest present at {legacy} — use the v1 checkout's "
                f"'./setup --uninstall' (see MIGRATION.md)")
        return 0
    only_ids = {s.strip() for s in (only or "").split(",") if s.strip()}
    say(f"universal-agentic-setup v{version()} — UNINSTALL")
    say(f"  home: {sync.home}")
    remaining = {}
    for aid, rec in sorted(manifest["agents"].items()):
        if only_ids and aid not in only_ids:
            remaining[aid] = rec
            continue
        sync.uninstall_agent(aid, rec)
    if not sync.dry:
        if remaining:
            manifest["agents"] = remaining
            manifest["updated_at"] = time.strftime("%Y-%m-%dT%H:%M:%S")
            sync.manifest_path.write_text(dump_json(manifest), encoding="utf-8")
        else:
            sync.manifest_path.unlink(missing_ok=True)
            say(f"removed manifest {sync.manifest_path}")
    say("uninstall complete — managed blocks and managed MCP entries removed, "
        "backups restored where present" + ("  (dry-run)" if sync.dry else ""))
    return 0


# ------------------------------------------------------------------ main ----

def main(argv=None):
    # Windows pipes default to the legacy code page (cp1252), which cannot encode the
    # arrows and dashes in our output: always emit UTF-8 so pipes, CI and consoles agree.
    for stream in (sys.stdout, sys.stderr):
        reconfigure = getattr(stream, "reconfigure", None)
        if reconfigure:
            try:
                reconfigure(encoding="utf-8", errors="replace")
            except (ValueError, OSError):
                pass
    parser = argparse.ArgumentParser(
        prog="agentic_sync.py",
        description="Sync the universal-agentic-setup core into every detected agent "
                    "(dry-run by default).",
    )
    parser.add_argument("--apply", action="store_true", help="write configs (default is dry-run)")
    parser.add_argument("--only", help="comma-separated agent ids (forces undetected agents)")
    parser.add_argument("--skip", help="comma-separated agent ids to skip")
    parser.add_argument("--skills", action="store_true",
                        help="also install core skills via 'npx skills add ... -g -y'")
    parser.add_argument("--list", action="store_true", help="list the agent registry")
    parser.add_argument("--markdown", action="store_true",
                        help="with --list: emit docs/AGENTS-MATRIX.md markdown")
    parser.add_argument("--doctor", action="store_true", help="diagnostics only")
    parser.add_argument("--uninstall", action="store_true",
                        help="remove managed blocks/MCP entries, restore backups")
    parser.add_argument("--home", help="target home directory (sandbox/tests). Default: $HOME")
    parser.add_argument("--version", action="store_true", help="print version")
    args = parser.parse_args(argv)

    if args.version:
        say(f"universal-agentic-setup {version()}")
        return 0

    sync = Sync(resolve_home(args.home), dry_run=not args.apply)

    if args.doctor:
        return cmd_doctor(sync)
    if args.list:
        return cmd_list(sync, markdown=args.markdown)
    if args.uninstall:
        return cmd_uninstall(sync, only=args.only)
    return cmd_plan_apply(sync, apply=args.apply, only=args.only, skip=args.skip,
                          skills=args.skills)


if __name__ == "__main__":
    sys.exit(main())
