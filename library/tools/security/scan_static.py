#!/usr/bin/env python3
"""Static security rules for agent skills (stdlib only, cross-platform).

Usage: python scan_static.py <skills-root> [--json out.json] [--name skill] [--extra word,word]
--extra adds your own private words (host names, project names, user names) to rule S10; keep that list out of any repository.
Each immediate subdirectory of <skills-root> containing SKILL.md is one skill.
Exit code 1 if any HIGH finding remains.

Rules (id: meaning)
  S1  secret read / credential file access instructed
  S2  data exfiltration (upload / POST of local data / webhook)
  S3  fetch-and-execute (curl|sh, iex(iwr), npx -y <pkg>@latest, eval of remote)
  S4  instruction to ignore the user / system / earlier instructions, or to hide actions
  S5  disables safety or approval (skip permissions, yolo, auto-approve, never ask)
  S6  hidden Unicode (zero-width, bidi, tag chars, private use, control chars)
  S7  encoded payload (long base64/hex blob, decode-and-run)
  S8  shell snippet needing manual review (rm -rf, sudo, chmod 777, registry, git push, docker privileged, ...)
  S9  frontmatter / format violation (name, description <=200 chars, only name+description keys)
  S10 machine-specific or personal detail (drive paths, home paths, private IPs, e-mail, agent-specific URIs)

A line is downgraded to INFO when it is clearly a prohibition or a labelled example
(contains never / do not / don't / refuse / must not / example / hostile / untrusted / ask the user / approval).
"""
import json
import os
import re
import sys
import unicodedata

NEG = re.compile(r"\b(never|do not|don't|dont|must not|refuse|forbid|forbidden|prohibit|example|hostile|untrusted|injection|"
                 r"ask (the )?user|ask first|approval|confirm|only after|unless the user|red flag|suspicious|attack|malicious|"
                 r"avoid|should not|not allowed|without the user|reject|block)\b", re.I)

RULES = [
    ("S1", "high", re.compile(r"(\.ssh[/\\]|id_rsa|id_ed25519|\.aws[/\\]credentials|\.netrc|\.npmrc|\.git-credentials|auth\.json|"
                              r"\.credentials\.json|credentials\.json|keychain|/etc/shadow|\bprintenv\b|\benv\s*\|\s*(grep|sort)|"
                              r"cat\s+[^\n|]*\.env\b|type\s+[^\n|]*\.env\b|Get-Content\s+[^\n|]*\.env\b|\$env:[A-Z_]*(KEY|TOKEN|SECRET))", re.I)),
    ("S2", "high", re.compile(r"(curl|wget|Invoke-WebRequest|iwr|Invoke-RestMethod|irm|requests\.post|fetch\()[^\n]{0,160}"
                              r"(-d\s|--data|-F\s|--upload-file|-X\s*POST|-Method\s+Post|-Body|webhook|pastebin|transfer\.sh|ngrok|requestbin|"
                              r"discord(app)?\.com/api/webhooks|hooks\.slack\.com)|\bnc\s+-|/dev/tcp/", re.I)),
    ("S3", "high", re.compile(r"((curl|wget)[^\n|]*\|\s*(sudo\s+)?(ba|z|da)?sh\b|iex\s*\(?\s*(iwr|irm|\(New-Object|Invoke-)|"
                              r"Invoke-Expression[^\n]*(iwr|irm|DownloadString)|\beval\s*\$?\(?\s*(curl|wget)|python3?\s+-c\s+[\"'][^\n]*urlopen|"
                              r"npx\s+(-y\s+|--yes\s+)?[@\w./-]+@latest|pip3?\s+install\s+[^\n]*(https?://|git\+)|bash\s+<\(\s*curl)", re.I)),
    ("S4", "high", re.compile(r"(ignore|disregard|forget|override)\s+(all\s+|any\s+|the\s+|your\s+)?(previous|prior|above|earlier|system|user|safety)\s+"
                              r"(instructions?|rules?|prompts?|messages?|guidelines?)|do not (tell|inform|mention|show)( this to)? the user|"
                              r"without (telling|informing|notifying) the user|you are now (in )?(developer|maintenance|admin|dan)|"
                              r"pretend (that )?the user (has )?(approved|consented)|(secretly|silently|covertly)\s+(run|send|upload|post|exfiltrat)", re.I)),
    ("S5", "high", re.compile(r"(--dangerously-skip-permissions|--yolo\b|--auto-approve|bypassPermissions|approval(Mode)?\s*[:=]\s*[\"']?yolo|"
                              r"\bauto[- ]approve (all|every|destructive|everything)|disable (the )?(safety|sandbox|approval|confirmation|guard|permission)|"
                              r"skip (the )?(approval|confirmation|permission|safety)|never ask (the user )?(for )?(permission|confirmation|approval)|"
                              r"(do not|don't) (ask|wait) for (the user'?s? )?(permission|confirmation|approval)|--no-verify\b|--force-with-lease|"
                              r"push\s+(--force|-f)\b)", re.I)),
    ("S7", "high", re.compile(r"([A-Za-z0-9+/]{120,}={0,2})|((?:\\x[0-9a-fA-F]{2}){12,})|(base64\s+(-d|--decode)[^\n]*\|\s*(ba)?sh)|"
                              r"(FromBase64String[^\n]*(iex|Invoke-Expression))|(atob\([^\n]*\)[^\n]*eval)", re.I)),
    ("S8", "medium", re.compile(r"(\brm\s+-[a-zA-Z]*r[a-zA-Z]*f|\brm\s+-[a-zA-Z]*f[a-zA-Z]*r|Remove-Item[^\n]*-Recurse[^\n]*-Force|\bsudo\b|chmod\s+-?R?\s*777|"
                                r"\bmkfs\b|\bdd\s+if=|HKLM:|HKCU:|reg\s+(add|delete)|git\s+push|git\s+reset\s+--hard|git\s+clean\s+-[a-z]*f|git\s+checkout\s+--\s|"
                                r"docker\s+run[^\n]*--privileged|docker\s+system\s+prune|DROP\s+(TABLE|DATABASE)|TRUNCATE\s+TABLE|"
                                r"kubectl\s+delete|terraform\s+(apply|destroy)|npm\s+publish|twine\s+upload|"
                                r"(npm|pnpm|yarn|pip3?|cargo|go|gem)\s+(install|add|i)\s+-g|(vercel|netlify|railway|fly)\s+(deploy|up)\b|"
                                r"\bssh\s+[^\n]*@|scp\s+|Set-ExecutionPolicy|Start-Process[^\n]*-Verb\s+RunAs|schtasks|crontab)", re.I)),
    ("S10", "low", re.compile(r"([A-Za-z]:[\\/](Users|Projects|Caches|Program Files|Windows)[\\/]|/Users/[A-Za-z0-9._-]+/|/home/[A-Za-z0-9._-]+/|"
                              r"\b(10|192\.168|172\.(1[6-9]|2\d|3[01]))\.\d{1,3}\.\d{1,3}(\.\d{1,3})?\b|\b100\.(6[4-9]|[7-9]\d|1[01]\d|12[0-7])\.\d{1,3}\.\d{1,3}\b|"
                              r"\b[A-Za-z0-9._%+-]+@(?!example\.|resend\.dev|youremail|users\.noreply)[A-Za-z0-9-]+\.[A-Za-z]{2,}\b|"
                              r"\b(skill|help|local|rule|memory|agent|vault|proc|history)://|\.omp[/\\]|oh-my-pi|\bOMP\b)", re.I)),
]

HIDDEN_CATS = {"Cf", "Co", "Cs", "Cn"}
ALLOWED_CF = {"\u200d"}  # ZWJ inside emoji sequences is checked separately
TEXT_EXT = {".md", ".txt", ".sh", ".ps1", ".py", ".js", ".mjs", ".ts", ".json", ".yaml", ".yml", ".toml", ".csv", ".html", ".css", ".ini", ".cfg", ""}


def iter_files(skill_dir):
    for dp, dn, fn in os.walk(skill_dir):
        dn[:] = [d for d in dn if d not in ("node_modules", ".git", "__pycache__")]
        for f in fn:
            yield os.path.join(dp, f)


def check_hidden(text):
    out = []
    for i, line in enumerate(text.splitlines(), 1):
        for ch in line:
            o = ord(ch)
            cat = unicodedata.category(ch)
            if ch in "\t\r\n":
                continue
            if cat == "Cc" or (cat in HIDDEN_CATS and ch not in ALLOWED_CF and ch != "\ufe0f") or 0xE0000 <= o <= 0xE007F:
                out.append((i, "U+%04X" % o))
                break
            if ch == "\u200d" and not re.search(r"[\U0001F300-\U0001FAFF\u2600-\u27BF]\u200d", line):
                out.append((i, "U+200D outside emoji"))
                break
    return out


def check_frontmatter(path, text):
    f = []
    m = re.match(r"^\ufeff?---\r?\n(.*?)\r?\n---\r?\n", text, re.S)
    if not m:
        return [("S9", "high", 1, "no YAML frontmatter")]
    block = m.group(1)
    keys = re.findall(r"^([A-Za-z_][\w-]*):", block, re.M)
    name = re.search(r"^name:\s*[\"']?([^\"'\n]+)", block, re.M)
    desc = re.search(r"^description:\s*(.*)$", block, re.M)
    d = os.path.basename(os.path.dirname(path))
    if not name:
        f.append(("S9", "high", 2, "missing name"))
    elif name.group(1).strip() != d:
        f.append(("S9", "high", 2, "name '%s' != directory '%s'" % (name.group(1).strip(), d)))
    if not desc:
        f.append(("S9", "high", 2, "missing description"))
    else:
        dv = desc.group(1).strip().strip("\"'")
        if len(dv) > 200:
            f.append(("S9", "medium", 3, "description %d chars (>200)" % len(dv)))
        if not re.search(r"\b(use|when|for)\b", dv, re.I):
            f.append(("S9", "low", 3, "description has no trigger wording"))
    extra = [k for k in keys if k not in ("name", "description")]
    if extra:
        f.append(("S9", "low", 2, "extra frontmatter keys: %s" % ",".join(extra)))
    return f


def scan_skill(skill_dir):
    findings = []
    skill_md = os.path.join(skill_dir, "SKILL.md")
    with open(skill_md, encoding="utf-8", errors="replace") as fh:
        findings += [dict(rule=r, sev=s, file="SKILL.md", line=l, text=t) for r, s, l, t in check_frontmatter(skill_md, fh.read())]
    nfiles = 0
    for path in iter_files(skill_dir):
        rel = os.path.relpath(path, skill_dir).replace("\\", "/")
        ext = os.path.splitext(path)[1].lower()
        nfiles += 1
        if ext not in TEXT_EXT:
            findings.append(dict(rule="S9", sev="medium", file=rel, line=0, text="non-text/binary file shipped (%s)" % ext))
            continue
        try:
            with open(path, encoding="utf-8") as fh:
                text = fh.read()
        except UnicodeDecodeError:
            findings.append(dict(rule="S6", sev="high", file=rel, line=0, text="file is not valid UTF-8"))
            continue
        for ln, code in check_hidden(text):
            findings.append(dict(rule="S6", sev="high", file=rel, line=ln, text="hidden/format character " + code))
        if re.search(r"<!--", text) and ext == ".md":
            fence = False
            for i, line in enumerate(text.splitlines(), 1):
                if line.strip().startswith("```"):
                    fence = not fence
                if "<!--" in line and not fence and "```" not in line:
                    findings.append(dict(rule="S6", sev="medium", file=rel, line=i, text="HTML comment outside code (can hide instructions): " + line.strip()[:100]))
        in_code = False
        for i, line in enumerate(text.splitlines(), 1):
            if line.strip().startswith("```"):
                in_code = not in_code
            for rid, sev, rx in RULES:
                m = rx.search(line)
                if not m:
                    continue
                s = sev
                note = ""
                if rid in ("S1", "S2", "S3", "S4", "S5", "S7", "S8") and NEG.search(line):
                    s = "info"
                    note = " [prohibition/example context]"
                if rid == "S8" and not in_code and not ext in (".sh", ".ps1", ".py"):
                    s = "info" if s != "info" else s
                    note = note or " [prose mention]"
                if rid == "S7" and re.fullmatch(r"[A-Za-z0-9+/=_.\-:]*", m.group(0)) and ("/" in m.group(0) and " " not in line.strip()[:20]) and len(set(m.group(0))) < 25:
                    # long path-like or repeated-character strings are not payloads
                    continue
                findings.append(dict(rule=rid, sev=s, file=rel, line=i, text=(line.strip()[:140] + note)))
    return dict(files=nfiles, findings=findings)


def main():
    argv = sys.argv[1:]
    if not argv:
        print(__doc__)
        return 2
    root = argv[0]
    out = None
    only = None
    if "--extra" in argv:
        words = [w for w in argv[argv.index("--extra") + 1].split(",") if w]
        if words:
            for i, (rid, sev, rx) in enumerate(RULES):
                if rid == "S10":
                    RULES[i] = (rid, sev, re.compile(rx.pattern + "|" + "|".join(re.escape(w) for w in words), re.I))
    if "--json" in argv:
        out = argv[argv.index("--json") + 1]
    if "--name" in argv:
        only = argv[argv.index("--name") + 1]
    res = {}
    for n in sorted(os.listdir(root)):
        p = os.path.join(root, n)
        if only and n != only:
            continue
        if os.path.isfile(os.path.join(p, "SKILL.md")):
            res[n] = scan_skill(p)
    if out:
        with open(out, "w", encoding="utf-8") as fh:
            json.dump(res, fh, indent=1)
    bad = 0
    for n, r in res.items():
        c = {}
        for f in r["findings"]:
            c[f["sev"]] = c.get(f["sev"], 0) + 1
        bad += c.get("high", 0)
        print("%-34s files=%-3d %s" % (n, r["files"], " ".join("%s=%d" % kv for kv in sorted(c.items())) or "clean"))
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main())
