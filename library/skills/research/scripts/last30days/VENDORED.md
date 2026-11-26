# Vendored subset of last30days-skill (MIT)

Source: https://github.com/mvanhorn/last30days-skill v3.28.0, `skills/last30days/scripts/lib/`. License: `LICENSE` (MIT, Matt Van Horn).

This is a pruned, free-sources-only build. `scripts/last30days.py` is a new ~300-line driver written for this build; the upstream 4.4k-line CLI and 6.6k-line pipeline are NOT included.

## Kept (unchanged unless listed)
`http, log, query, relevance, cjk, dates, subproc, windows_job, bounded_get, hackernews, polymarket, reddit_public, reddit_keyless, reddit_search, reddit_listing, reddit_shreddit, reddit_arctic, reddit_enrich, youtube_yt`

## Changed
- `health.py`: reduced to outcome-state constants (upstream shells out to package managers / `npx -y`).
- `usage.py`: no-op stubs (upstream journals provider charges).
- `http.py`: removed `scrapecreators_headers` and the Keychain-key lookup.
- `youtube_yt.py`: cut down to search only (yt-dlp, `--no-cookies-from-browser`); removed SSH routing, proxy env, transcripts, comment fetching, ScrapeCreators client.
- `reddit_enrich.py`: removed the ScrapeCreators enrichment function. `reddit_search.py`: inlined the time-window helper from the deleted `reddit.py`. `reddit_keyless.py`: dropped the optional `rerank` import.

## Removed entirely (never copied)
X/Twitter (bird client, xAI, xurl), TikTok/Instagram/Threads/LinkedIn/Bluesky/Truth Social and other ScrapeCreators-backed sources, browser-cookie readers (`chrome_cookies`, `cookie_extract`, `safari_cookies`, `agentcookie`, `chrome_cdp`), keychain/`pass` credential loading (`env.py`), hosted-LLM planner/reranker (`providers`, `planner`, `rerank`), web-search/fetch fallbacks (DuckDuckGo, Startpage, r.jina.ai), `html_publish` (api.ht-ml.app), `setup_wizard`, library/feed/store/watchlist (disk writes), doctor.

## Driver guarantees
Drops API keys, tokens, `*_BASE_URL`, proxies, cookie hints and every `LAST30DAYS_*` env var before importing the engine; accepts only `reddit,hackernews,polymarket,youtube`; prints to stdout, writes nothing, publishes nothing. Hosts contacted: www.reddit.com, arctic-shift.photon-reddit.com, hn.algolia.com, hacker-news.firebaseio.com, gamma-api.polymarket.com, YouTube via local yt-dlp.

Subprocesses spawned: local `yt-dlp` (search only), `taskkill` (cleanup of timed-out children), and `bounded_get.py` re-executing itself with `python -I` to enforce GET deadlines. Nothing else.

The string `search-telemetry-tracker` in `reddit_search.py` is a Reddit HTML tag the parser reads for post metadata, not telemetry.
