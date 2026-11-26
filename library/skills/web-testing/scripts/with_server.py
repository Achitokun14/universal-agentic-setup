#!/usr/bin/env python3
"""Start one or more dev servers, wait until their ports accept connections,
run a test command, then stop every server (whole process tree).

Adapted from anthropics/skills webapp-testing/scripts/with_server.py (Apache-2.0).
Changes: no shell (shell=False, argument lists only), per-server working
directory instead of "cd x && ...", output goes to log files (no pipe
deadlock), process-tree cleanup on Windows and POSIX, fail-fast if a server exits.

Cross-platform: one script for Windows, macOS and Linux; standard library
only, runs with a stock Python 3 interpreter (no .sh/.ps1 variants needed).

Usage:
    python with_server.py --server "pnpm dev" --port 3000 -- pnpm exec playwright test
    python with_server.py \
        --server "python server.py" --cwd backend --port 8000 \
        --server "pnpm dev" --cwd frontend --port 5173 \
        -- python my_check.py

Each --server is split into arguments with shlex (no shell features: no &&,
pipes, env-var expansion or redirects). Use --cwd (repeatable, same order as
--server; use "." for none) instead of `cd`. Pass environment through the
parent process.
"""

import argparse
import os
import shlex
import shutil
import signal
import socket
import subprocess
import sys
import tempfile
import time

IS_WINDOWS = os.name == "nt"


def wait_for_port(port, proc, timeout):
    """Return True once localhost:port accepts a connection; False on timeout
    or if the server process has already exited."""
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        if proc.poll() is not None:
            return False
        try:
            with socket.create_connection(("localhost", port), timeout=1):
                return True
        except OSError:
            time.sleep(0.5)
    return False


def split_command(cmd):
    """shlex split; on Windows keep backslashes in paths and strip wrapping quotes."""
    if not IS_WINDOWS:
        return shlex.split(cmd)
    return [t[1:-1] if len(t) > 1 and t[0] == t[-1] and t[0] in "\"'" else t
            for t in shlex.split(cmd, posix=False)]


def resolve(argv, cwd):
    """Resolve argv[0] via PATH/PATHEXT so npm/pnpm .cmd shims run without a shell."""
    exe = shutil.which(argv[0], path=None) or shutil.which(argv[0], path=os.path.abspath(cwd))
    if exe is None:
        raise FileNotFoundError(f"command not found: {argv[0]}")
    return [exe] + argv[1:]


def start(argv, cwd, log):
    kwargs = {"cwd": cwd, "stdin": subprocess.DEVNULL, "stdout": log, "stderr": subprocess.STDOUT}
    if IS_WINDOWS:
        kwargs["creationflags"] = subprocess.CREATE_NEW_PROCESS_GROUP
    else:
        kwargs["start_new_session"] = True
    return subprocess.Popen(resolve(argv, cwd), shell=False, **kwargs)


def stop(proc):
    if proc.poll() is not None:
        return
    try:
        if IS_WINDOWS:
            # /T kills the child tree (npm -> node -> vite), /F forces it.
            subprocess.run(
                ["taskkill", "/T", "/F", "/PID", str(proc.pid)],
                shell=False, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, timeout=15,
            )
        else:
            os.killpg(proc.pid, signal.SIGTERM)
        proc.wait(timeout=5)
    except (subprocess.TimeoutExpired, ProcessLookupError, PermissionError):
        proc.kill()
        proc.wait()


def main():
    p = argparse.ArgumentParser(description="Run a command with one or more servers running")
    p.add_argument("--server", action="append", dest="servers", required=True,
                   help='Server command, e.g. "pnpm dev" (repeatable)')
    p.add_argument("--port", action="append", dest="ports", type=int, required=True,
                   help="Port of each server (same count/order as --server)")
    p.add_argument("--cwd", action="append", dest="cwds", default=[],
                   help='Working directory of each server ("." for current); omit for all current')
    p.add_argument("--timeout", type=int, default=60, help="Seconds to wait per server (default 60)")
    p.add_argument("command", nargs=argparse.REMAINDER, help="Command to run once all servers are ready, after --")
    args = p.parse_args()

    command = args.command[1:] if args.command and args.command[0] == "--" else args.command
    if not command:
        sys.exit("error: no command given after --")
    if len(args.servers) != len(args.ports):
        sys.exit("error: number of --server and --port arguments must match")
    cwds = args.cwds or ["."] * len(args.servers)
    if len(cwds) != len(args.servers):
        sys.exit("error: give --cwd for every --server or for none")

    procs, logs = [], []
    code = 1
    try:
        for i, (cmd, port, cwd) in enumerate(zip(args.servers, args.ports, cwds), 1):
            argv = split_command(cmd)
            if not argv:
                sys.exit(f"error: empty --server #{i}")
            log = tempfile.NamedTemporaryFile(prefix=f"with_server_{i}_", suffix=".log", delete=False)
            logs.append(log.name)
            print(f"[{i}/{len(args.servers)}] starting: {cmd}  (cwd={cwd}, log={log.name})")
            try:
                proc = start(argv, cwd, log)
            finally:
                log.close()  # the child keeps its own handle
            procs.append(proc)
            if not wait_for_port(port, proc, args.timeout):
                raise RuntimeError(f"server {i} not ready on port {port} within {args.timeout}s "
                                   f"(or exited early); see {log.name}")
            print(f"    ready on port {port}")
        print(f"running: {shlex.join(command) if not IS_WINDOWS else subprocess.list2cmdline(command)}\n")
        code = subprocess.run(resolve(command, "."), shell=False).returncode
    except (RuntimeError, FileNotFoundError) as exc:
        print(f"error: {exc}", file=sys.stderr)
    finally:
        for proc in procs:
            stop(proc)
        print(f"\nstopped {len(procs)} server(s); logs: {', '.join(logs) or 'none'}")
    sys.exit(code)


if __name__ == "__main__":
    main()
