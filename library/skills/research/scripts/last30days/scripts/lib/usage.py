"""No-op usage hooks (vendored build).

The upstream module journals provider charges to a local SQLite file. This
build only talks to free sources, so every hook does nothing.
"""

from __future__ import annotations


def begin_http(url: str, method: str):
    return None


def cancel(attempt) -> None:
    return None


def finish(attempt, payload) -> None:
    return None
