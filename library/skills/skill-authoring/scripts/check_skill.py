#!/usr/bin/env python3
"""Check a skill directory against the portable SKILL.md format.

Cross-platform: standard-library Python 3.8+, no third-party packages, no network.

Usage:
    python3 check_skill.py <skill-dir> [<skill-dir> ...]      (macOS / Linux)
    python  check_skill.py <skill-dir> [<skill-dir> ...]      (Windows)

Checks: frontmatter has only `name` and `description`; `name` equals the directory
name and is kebab-case; `description` is one double-quoted line of at most 200
characters; SKILL.md body is under 500 lines; references/ is not nested more than one
grouping folder deep;
relative links in SKILL.md resolve; no machine-specific or agent-specific URIs.
Exit code 1 if any problem is found.
"""
import re
import sys
from pathlib import Path

MAX_DESC = 200
MAX_BODY_LINES = 500
NAME_RE = re.compile(r"^[a-z0-9]+(-[a-z0-9]+)*$")
LEAK_RE = re.compile(
    r"(skill|help|local|agent|rule|memory)://|[A-Za-z]:[\\/](Users|Software|Caches)|/home/[a-z]+/|/Users/[A-Za-z]+/"
)
LINK_RE = re.compile(r"`((?:references|scripts)/[^`\s]+)`|\]\(((?:references|scripts)/[^)\s]+)\)")


def check(skill_dir: Path) -> list:
    problems = []
    skill_md = skill_dir / "SKILL.md"
    if not skill_md.is_file():
        return [f"{skill_dir}: SKILL.md missing"]
    text = skill_md.read_text(encoding="utf-8")
    lines = text.split("\n")
    if not lines or lines[0].strip() != "---":
        return [f"{skill_md}: first line must be ---"]
    try:
        end = next(i for i in range(1, len(lines)) if lines[i].strip() == "---")
    except StopIteration:
        return [f"{skill_md}: frontmatter is not closed with ---"]

    front = {}
    for raw in lines[1:end]:
        if not raw.strip():
            continue
        m = re.match(r"^([A-Za-z_-]+):\s*(.*)$", raw)
        if not m:
            problems.append(f"{skill_md}: frontmatter line is not `key: value`: {raw[:60]!r}")
            continue
        front[m.group(1)] = m.group(2).strip()

    extra = sorted(set(front) - {"name", "description"})
    if extra:
        problems.append(f"{skill_md}: frontmatter must only have name and description; remove {extra}")
    name = front.get("name", "")
    if name != skill_dir.resolve().name:
        problems.append(f"{skill_md}: name {name!r} must equal directory name {skill_dir.resolve().name!r}")
    if not NAME_RE.match(name):
        problems.append(f"{skill_md}: name must be kebab-case")
    desc = front.get("description")
    if desc is None:
        problems.append(f"{skill_md}: description missing")
    else:
        if not (len(desc) >= 2 and desc.startswith('"') and desc.endswith('"')):
            problems.append(f"{skill_md}: description must be a double-quoted one-line string")
        if len(desc) - 2 > MAX_DESC:
            problems.append(f"{skill_md}: description is {len(desc) - 2} chars (max {MAX_DESC})")

    body = lines[end + 1:]
    if len(body) > MAX_BODY_LINES:
        problems.append(f"{skill_md}: body is {len(body)} lines (max {MAX_BODY_LINES}); move detail to references/")

    for m in LINK_RE.finditer("\n".join(body)):
        rel = (m.group(1) or m.group(2)).rstrip(".,;:")
        if any(ch in rel for ch in "<>*{}") or "foo" in rel:
            continue  # placeholder or glob in prose, not a real link
        target = skill_dir / rel
        if not target.exists():
            problems.append(f"{skill_md}: linked path does not exist: {rel}")

    refs = skill_dir / "references"
    if refs.is_dir():
        for sub in refs.rglob("*"):
            # one grouping subfolder (references/<group>/file.md) is tolerated; deeper nesting is not
            if sub.is_dir() and len(sub.relative_to(refs).parts) > 1:
                problems.append(f"{sub}: references/ may nest at most one grouping folder deep")

    for f in [skill_md] + sorted(skill_dir.rglob("*.md")):
        for n, line in enumerate(f.read_text(encoding="utf-8", errors="replace").split("\n"), 1):
            if LEAK_RE.search(line):
                problems.append(f"{f}:{n}: machine-specific or agent-specific URI/path")
    return problems


def main(argv: list) -> int:
    if len(argv) < 2:
        print(__doc__)
        return 2
    bad = 0
    for arg in argv[1:]:
        found = check(Path(arg))
        for p in found:
            print(p)
        print(f"{arg}: {'FAIL' if found else 'ok'}")
        bad += bool(found)
    return 1 if bad else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv))
