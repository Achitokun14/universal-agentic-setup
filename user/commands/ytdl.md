---
description: Download a video/podcast via yt-dlp, transcribe with whisper.cpp, save as markdown in llm-wiki.
argument-hint: "<url>"
---

Convert a video/podcast URL into a searchable markdown entry in the llm-wiki.

Steps:

1. If `$ARGUMENTS` is empty, ask: "What URL? (YouTube, podcast, any yt-dlp-supported source)".

2. Verify prerequisites with Bash:
   - `command -v yt-dlp` — if missing, print `pipx install yt-dlp` and stop.
   - `command -v whisper-cli` or `command -v whisper.cpp` or check `~/whisper.cpp/main` — if missing, note transcription is skipped (still downloads audio).

3. Invoke the helper script which already handles the pipeline:
   ```bash
   bash universal-agentic-setup/scripts/ytdl-to-wiki.sh "$ARGUMENTS"
   ```
   If the helper is missing (first-time machine), fall back to:
   ```bash
   slug=$(echo "$ARGUMENTS" | sha1sum | cut -c1-8)
   out="$HOME/Desktop/ACTIVITIES/llm-wiki/media/$(date +%Y%m%d)-$slug"
   mkdir -p "$out"
   yt-dlp --write-info-json --write-description -x --audio-format mp3 \
     -o "$out/%(title)s.%(ext)s" "$ARGUMENTS"
   # transcribe first .mp3
   whisper-cli -f "$out"/*.mp3 -otxt -of "$out/transcript" 2>/dev/null || true
   ```

4. Produce the markdown entry at `~/Desktop/ACTIVITIES/llm-wiki/media/<date>-<slug>.md`:
   ```markdown
   # <video title>

   **Source:** $ARGUMENTS
   **Downloaded:** YYYY-MM-DD
   **Duration:** <from info.json>
   **Uploader:** <from info.json>

   ## Description
   <from yt-dlp --write-description>

   ## Transcript
   <whisper output, or "Transcription skipped — whisper.cpp not installed">

   ## Key takeaways
   <if transcript exists, give 5 bullet summary>
   ```

5. Append a pointer to today's wiki file:
   `- 🎥 [<title>](media/<date>-<slug>.md) — <url>`

6. Print: `✓ ytdl complete — llm-wiki/media/<date>-<slug>.md`.

Large videos (>30 min): warn the user before transcribing and ask to proceed.
