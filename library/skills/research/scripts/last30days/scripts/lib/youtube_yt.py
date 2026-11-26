"""YouTube search and transcript extraction via yt-dlp for the v3.0.0 pipeline.

Uses yt-dlp (https://github.com/yt-dlp/yt-dlp) for both YouTube search and
transcript extraction. No API keys needed — just have yt-dlp installed.

Inspired by Peter Steinberger's toolchain approach (yt-dlp + summarize CLI).
"""

import copy

import json

import math

import os

import re


import shutil

import sys

import tempfile

import threading

import time

import urllib.error

import urllib.request

from concurrent.futures import ThreadPoolExecutor, as_completed

from pathlib import Path

from typing import Any, Dict, List, Optional, Set, Tuple

DEPTH_CONFIG = {
    "quick": 6,
    "default": 8,
    "deep": 40,
}

from . import dates, health, http, log, subproc

from .query import infer_query_intent

from .relevance import token_overlap_relevance as _compute_relevance

_SEARCH_TIMEOUT = 120  # seconds per ytsearch metadata extraction

_YTDLP_MAX_CONCURRENT = 2

_ytdlp_slots = threading.Semaphore(_YTDLP_MAX_CONCURRENT)

_search_cache: Dict[Tuple[str, int, str, str, Optional[str]], Dict[str, Any]] = {}

_search_inflight: Dict[Tuple[str, int, str, str, Optional[str]], tuple[threading.Event, list]] = {}

_search_cache_lock = threading.Lock()

def _log(msg: str):
    log.source_log("YouTube", msg, tty_only=False)

def reset_search_cache() -> None:
    """Clear the in-run ytsearch cache.

    Call at the start of each top-level research run so a long-lived process
    (agent host, REPL, test suite) does not reuse results across runs. Within
    one comparison fan-out the cache stays hot so identical queries coalesce.
    """
    with _search_cache_lock:
        _search_cache.clear()
        _search_inflight.clear()

def _env_positive_float(name: str, default: float) -> float:
    """Read a positive finite float from the environment, else ``default``."""
    raw = os.environ.get(name, "").strip()
    try:
        value = float(raw) if raw else float(default)
    except ValueError:
        return float(default)
    if not math.isfinite(value) or value <= 0:
        return float(default)
    return value

def _search_timeout() -> float:
    """Return the ytsearch timeout, preserving the 120s default."""
    return _env_positive_float("LAST30DAYS_YT_SEARCH_TIMEOUT", float(_SEARCH_TIMEOUT))

def _run_ytdlp(cmd: List[str], *, timeout: float) -> subproc.SubprocResult:
    """Run a yt-dlp command under the process-wide concurrency gate."""
    with _ytdlp_slots:
        return subproc.run_with_timeout(cmd, timeout=timeout)

def _claim_search_slot(
    cache_key: Tuple[str, int, str, str, Optional[str]],
) -> tuple[Optional[Dict[str, Any]], Optional[threading.Event], Optional[list], bool]:
    """Return ``(cached, event, slot, is_leader)`` for search coalesce.

    - Cache hit: ``(payload, None, None, False)`` — caller returns ``payload``.
    - Waiter: ``(None, event, slot, False)`` — caller awaits ``slot`` via ``event``.
    - Leader: ``(None, event, slot, True)`` — caller runs yt-dlp and finishes the slot.
    """
    with _search_cache_lock:
        cached = _search_cache.get(cache_key)
        if cached is not None:
            return copy.deepcopy(cached), None, None, False
        existing = _search_inflight.get(cache_key)
        if existing is not None:
            return None, existing[0], existing[1], False
        event = threading.Event()
        slot: list = [None]
        _search_inflight[cache_key] = (event, slot)
        return None, event, slot, True

def _finish_search_slot(
    cache_key: Tuple[str, int, str, str, Optional[str]],
    payload: Dict[str, Any],
    *,
    event: threading.Event,
    slot: list,
) -> Dict[str, Any]:
    """Publish a search result to waiters; cache only clean (non-error) payloads.

    Ownership is by slot identity: after ``reset_search_cache()`` clears the
    registry, a stale leader must still wake its own waiters but must not pop
    or overwrite a newer run's registration for the same key.
    """
    shared = copy.deepcopy(payload)
    with _search_cache_lock:
        if slot[0] is not None:
            # Idempotent re-finish of this slot (e.g. finally after return).
            event.set()
            return payload
        slot[0] = shared
        current = _search_inflight.get(cache_key)
        if current is not None and current[1] is slot:
            if not payload.get("error"):
                _search_cache[cache_key] = shared
            _search_inflight.pop(cache_key, None)
        # else: stale leader after a reset — wake local waiters only.
        event.set()
    return payload

def _await_search_slot(
    event: threading.Event,
    slot: list,
) -> Dict[str, Any]:
    """Wait for a leader search to publish.

    Waiters block until the leader finishes (success or failure). The leader
    path always publishes via ``_finish_search_slot``, including on unexpected
    exceptions, so a timed wait would only invent a false timeout while the
    leader was still queued behind other yt-dlp work.
    """
    event.wait()
    shared = slot[0]
    if isinstance(shared, dict):
        return copy.deepcopy(shared)
    return {"items": [], "error": "YouTube search failed"}

def classify_run_failure(detail: str) -> str:
    """Map yt-dlp's text-only throttling and bot-gate errors."""
    text = detail.lower()
    if any(marker in text for marker in ("yt-dlp not installed", "yt-dlp not found")):
        return health.SKIPPED_UNCONFIGURED
    if any(marker in text for marker in ("timed out", "timeout")):
        return health.TIMEOUT
    if any(
        marker in text
        for marker in ("http error 429", "confirm you're not a bot", "confirm you’re not a bot", "bot-gate")
    ):
        return health.RATE_LIMITED
    if any(marker in text for marker in ("sign in", "login required", "cookies are no longer valid")):
        return health.AUTH_FAILED
    return http.classify_failure(message=detail)

def is_ytdlp_installed() -> bool:
    """Check whether the local yt-dlp binary is on PATH."""
    return shutil.which("yt-dlp") is not None




_PLAYER_CLIENT_RE = re.compile(r"^[A-Za-z0-9_-]+$")

def _ytdlp_player_client() -> Optional[str]:
    """Return the yt-dlp YouTube player_client, or None to leave the default.

    Default is ``android``, which bypasses the web bot-gate without cookies.
    Set ``LAST30DAYS_YT_PLAYER_CLIENT`` empty to disable; any other value is
    passed through when it is a safe extractor token.
    """
    if "LAST30DAYS_YT_PLAYER_CLIENT" in os.environ:
        raw = os.environ.get("LAST30DAYS_YT_PLAYER_CLIENT", "").strip()
        if not raw:
            return None
    else:
        raw = "android"
    if not _PLAYER_CLIENT_RE.match(raw):
        sys.stderr.write(
            f"[youtube_yt] WARNING: LAST30DAYS_YT_PLAYER_CLIENT={raw!r} "
            "is not a plain player-client token; ignoring.\n"
        )
        return None
    return raw

def _ytdlp_cmd_needs_player_client(cmd: List[str]) -> bool:
    blob = " ".join(cmd)
    return any(
        marker in blob
        for marker in (
            "ytsearch",
            "youtube.com",
            "--write-comments",
            "--write-auto-subs",
        )
    )

def _inject_youtube_player_client(cmd: List[str]) -> List[str]:
    """Merge player_client into a single youtube --extractor-args (#1052).

    yt-dlp does not merge two ``--extractor-args`` for the same extractor;
    the last one wins. Always fold into an existing ``youtube:`` spec.
    """
    client = _ytdlp_player_client()
    if not client or not _ytdlp_cmd_needs_player_client(cmd):
        return list(cmd)
    out = list(cmd)
    needle = f"player_client={client}"
    for i, arg in enumerate(out):
        if arg == "--extractor-args" and i + 1 < len(out):
            spec = out[i + 1]
            if spec.startswith("youtube:"):
                if "player_client=" in spec:
                    return out
                out[i + 1] = f"{spec};{needle}"
                return out
    out.extend(["--extractor-args", f"youtube:{needle}"])
    return out



def _wrap_ytdlp_cmd(cmd: List[str]) -> List[str]:
    """Return the yt-dlp command with the default player client injected.

    Vendored build: SSH routing and proxy overrides are removed so yt-dlp only
    ever runs locally and directly.
    """
    return _inject_youtube_player_client(cmd)

def _extract_core_subject(topic: str) -> str:
    """Extract core subject from verbose query for YouTube search.

    NOTE: 'tips', 'tricks', 'tutorial', 'guide', 'review', 'reviews'
    are intentionally KEPT — they're YouTube content types that improve search.
    """
    from .query import VIRAL_NOISE, extract_core_subject
    # YouTube extends VIRAL_NOISE with temporal/meta words the planner emits
    # that don't appear in YouTube titles (months, recent year tokens, etc.).
    _YT_EXTRA = frozenset({
        'last', 'days', 'recent', 'recently', 'month', 'week',
        'january', 'february', 'march', 'april', 'may', 'june',
        'july', 'august', 'september', 'october', 'november', 'december',
        '2025', '2026', '2027',
        'music', 'public', 'appearances', 'developments', 'discussions', 'coverage',
    })
    return extract_core_subject(topic, noise=VIRAL_NOISE | _YT_EXTRA)

_RECENT_FRESHNESS_MODES = frozenset({"strict_recent", "balanced_recent"})

def _apply_date_window(
    items: List[Dict[str, Any]],
    from_date: str,
    to_date: str,
    freshness_mode: Optional[str],
) -> List[Dict[str, Any]]:
    """Prefer in-window videos; scope the keep-all fallback by freshness mode.

    Videos published after ``to_date`` (an --as-of window) are never kept.
    3+ in-window videos: keep only those (every mode). Fewer: recent modes
    keep only the in-window ones; evergreen_ok and unknown/None keep all so
    evergreen topics can still fall back to older videos.
    """
    items = [i for i in items if not (i["date"] and i["date"] > to_date)]
    recent = [i for i in items if i["date"] and i["date"] >= from_date]
    if len(recent) >= 3:
        _log(f"Found {len(recent)} videos within date range")
        return recent
    if freshness_mode in _RECENT_FRESHNESS_MODES:
        _log(
            f"Found {len(items)} videos ({len(recent)} within date range, "
            f"keeping only in-range for {freshness_mode})"
        )
        return recent
    _log(f"Found {len(items)} videos ({len(recent)} within date range, keeping all)")
    return items

def search_youtube(
    topic: str,
    from_date: str,
    to_date: str,
    depth: str = "default",
    freshness_mode: Optional[str] = None,
) -> Dict[str, Any]:
    """Search YouTube via yt-dlp. No API key needed.

    Args:
        topic: Search topic
        from_date: Start date (YYYY-MM-DD)
        to_date: End date (YYYY-MM-DD)
        depth: 'quick', 'default', or 'deep'
        freshness_mode: Plan freshness mode; scopes the out-of-window
            fallback (see _apply_date_window). None keeps the soft fallback.

    Returns:
        Dict with 'items' list of video metadata dicts.
    """
    if not is_ytdlp_installed():
        return {"items": [], "error": "yt-dlp not installed"}

    count = DEPTH_CONFIG.get(depth, DEPTH_CONFIG["default"])
    core_topic = _extract_core_subject(topic)
    cache_key = (core_topic, count, from_date, to_date, freshness_mode)
    timeout = _search_timeout()

    cached, event, slot, is_leader = _claim_search_slot(cache_key)
    if cached is not None:
        _log(f"YouTube search cache hit for '{core_topic}' (count={count})")
        return cached
    assert event is not None and slot is not None
    if not is_leader:
        _log(f"YouTube search awaiting in-flight query for '{core_topic}'")
        return _await_search_slot(event, slot)

    def _publish(payload: Dict[str, Any]) -> Dict[str, Any]:
        return _finish_search_slot(cache_key, payload, event=event, slot=slot)

    _log(f"Searching YouTube for '{core_topic}' (since {from_date}, count={count})")

    # yt-dlp search with full metadata (no --flat-playlist so dates are real).
    # NOTE: --dateafter intentionally omitted — YouTube search returns
    # relevance-sorted results and strict date filtering returns 0 for
    # evergreen topics. Python soft filter (below) handles date filtering.
    cmd = [
        "yt-dlp",
        "--ignore-config",
        "--no-cookies-from-browser",
        f"ytsearch{count}:{core_topic}",
        "--dump-json",
        "--no-warnings",
        "--no-download",
    ]
    cmd = _wrap_ytdlp_cmd(cmd)

    published: Dict[str, Any] | None = None
    try:
        try:
            result = _run_ytdlp(cmd, timeout=timeout)
        except subproc.SubprocTimeout:
            _log(f"YouTube search timed out ({timeout:g}s)")
            published = _publish(
                {"items": [], "error": f"Search timed out after {timeout:g}s"}
            )
            return published
        except FileNotFoundError:
            published = _publish({"items": [], "error": "yt-dlp not found"})
            return published

        stdout = result.stdout
        if result.returncode != 0 and not stdout.strip():
            stderr_first = (result.stderr or "").strip().splitlines()
            first_line = stderr_first[0] if stderr_first else "(no stderr)"
            _log(f"YouTube search failed (rc={result.returncode}): {first_line}")
            error = f"yt-dlp search failed: {first_line}"
            published = _publish({"items": [], "error": error})
            return published
        if not stdout.strip():
            _log("YouTube search returned 0 results")
            published = _publish({"items": []})
            return published

        # Parse JSON-per-line output
        items = []
        for line in stdout.strip().split("\n"):
            line = line.strip()
            if not line:
                continue
            try:
                video = json.loads(line)
            except json.JSONDecodeError:
                continue

            video_id = video.get("id", "")
            view_count = video.get("view_count") if video.get("view_count") is not None else 0
            like_count = video.get("like_count") if video.get("like_count") is not None else 0
            comment_count = video.get("comment_count") if video.get("comment_count") is not None else 0
            upload_date = video.get("upload_date", "")  # YYYYMMDD

            # Convert YYYYMMDD to YYYY-MM-DD
            date_str = None
            if upload_date and len(upload_date) == 8:
                date_str = f"{upload_date[:4]}-{upload_date[4:6]}-{upload_date[6:8]}"

            description = str(video.get("description", ""))[:500]
            items.append({
                "video_id": video_id,
                "title": video.get("title", ""),
                "url": f"https://www.youtube.com/watch?v={video_id}",
                "channel_name": video.get("channel", video.get("uploader", "")),
                "date": date_str,
                "engagement": {
                    "views": view_count,
                    "likes": like_count,
                    "comments": comment_count,
                },
                "duration": video.get("duration"),
                "relevance": _compute_relevance(core_topic, f"{video.get('title', '')} {description}"),
                "why_relevant": f"YouTube: {video.get('title', core_topic)[:60]}",
                "description": description,
            })

        # Date filter: prefer recent items; the keep-all fallback is scoped
        # by freshness mode (evergreen only), see _apply_date_window.
        items = _apply_date_window(items, from_date, to_date, freshness_mode)

        # Sort by views descending
        items.sort(key=lambda x: x["engagement"]["views"], reverse=True)
        published = _publish({"items": items})
        return published
    except Exception as exc:
        # Post-subprocess failures (parse/relevance/sort) must still unblock
        # coalesced waiters — otherwise the inflight key orphans forever.
        published = _publish({"items": [], "error": str(exc)})
        return published
    finally:
        if published is None:
            _publish({"items": [], "error": "YouTube search failed"})
