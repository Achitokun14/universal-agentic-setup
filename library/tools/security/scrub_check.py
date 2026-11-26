#!/usr/bin/env python3
"""Privacy / machine-specific scrub check for an export tree. Usage: scrub_check.py <dir> [--extra word1,word2]   (--extra = your own private words: user, host and project names; keep that list out of repositories)
Prints hits grouped by category; exit 1 if any hit outside the mail category."""
import os, re, sys, collections
root = sys.argv[1]
extra = sys.argv[sys.argv.index('--extra') + 1].split(',') if '--extra' in sys.argv else []
pats = {
 'private': '|'.join(re.escape(e) for e in extra) or r'(?!x)x',
 'overlay-ip': r'\b100\.(6[4-9]|[7-9]\d|1[01]\d|12[0-7])\.\d{1,3}\.\d{1,3}\b|\b(10\.\d{1,3}|192\.168|172\.(1[6-9]|2\d|3[01]))\.\d{1,3}\.\d{1,3}\b',
 'paths': r'[A-Za-z]:[\\/](?:Users|Projects|Caches|Program)|/home/\w+/|/Users/\w+',
 'secret': r'\b(?:sk-[A-Za-z0-9]{20,}|ghp_[A-Za-z0-9]{20,}|gho_[A-Za-z0-9]{20,}|AKIA[0-9A-Z]{16}|xox[baprs]-[A-Za-z0-9-]{10,}|AIza[0-9A-Za-z_-]{30,})|-----BEGIN [A-Z ]*PRIVATE KEY',
 'agenturi': r'\b(?:skill|help|local|rule|memory|vault)://|\.omp[/\\]|oh-my-pi|\bvwl?\s+(?:get|run|ls)\b',
}
hits = collections.defaultdict(list)
email = re.compile(r'[A-Za-z0-9._%+-]{1,40}@[A-Za-z0-9.-]{1,60}\.[A-Za-z]{2,}')
okmail = re.compile(r'@(example\.|resend\.dev|users\.noreply|youremail|your-?domain|domain\.|acme|company\.|test\.|localhost)', re.I)
for dp, dn, fn in os.walk(root):
    dn[:] = [d for d in dn if d not in ('.git', 'node_modules')]
    for f in fn:
        p = os.path.join(dp, f)
        if os.path.getsize(p) > 3_000_000:
            continue
        try:
            lines = open(p, encoding='utf-8').read().split('\n')
        except Exception:
            continue
        for i, line in enumerate(lines, 1):
            if len(line) > 2000:
                line = line[:2000]
            for k, pt in pats.items():
                m = re.search(pt, line, re.I)
                if m:
                    hits[k].append((os.path.relpath(p, root).replace('\\', '/'), i, line[max(0, m.start() - 30):m.end() + 30]))
            if '@' in line:
                for m in email.finditer(line):
                    if not okmail.search(m.group(0)) and not m.group(0).startswith('@') and '/' not in m.group(0):
                        hits['mail'].append((os.path.relpath(p, root).replace('\\', '/'), i, m.group(0)))
bad = 0
for k, v in hits.items():
    print('##', k, len(v))
    for x in v[:40]:
        print('  ', x)
    if k != 'mail':
        bad += len(v)
print('TOTAL hard hits (excluding mail):', bad)
sys.exit(1 if bad else 0)
