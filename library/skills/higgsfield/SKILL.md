---
name: higgsfield
description: "Use for paid Higgsfield API image/video generation (Seedance, Kling, Soul ID, Ideogram): always estimate cost and ask the user before submitting."
---

Generate images and video with the user's Higgsfield API key (developer-console credits): pick a model tier, price it, generate, download, assemble. Every generation spends paid credits: estimate cost, then ask the user before submitting.

## When Higgsfield, when something else

| Need | Use |
|---|---|
| One still, edit, prompt-only help, no spend | the agent's built-in image tool or the `media-generation` skill (if installed), if the user has a free or subscription allowance |
| Short clip from another provider the user already has quota for | that provider's own tool |
| Video from any frame or reference, 4-30 s, 1080p/4K, multi-shot, motion transfer, trained character (Soul ID), exact-text posters (Ideogram 4) | **Higgsfield** |
| Exact typography, logos, charts, captions | code-made graphics or FFmpeg overlay; never trust AI-rendered text for more than a few words |
| Programmatic motion graphics | the `remotion-best-practices` skill (if installed) or plain code |

If the user did not ask for Higgsfield or paid credits and a free tool fits, say so in one line and use the free tool.

## Cost first (hard rule)

Before ANY submit (every image, clip, Soul ID training, retry): estimate cost (free), tell the user model, key params and the credits + USD figure, and ask the user before submitting. Wait for an explicit OK each time; an earlier OK covers only the exact generation(s) and budget that were approved. Batches, more than 5 submits, 1080p/4K, Cinema Studio, duration over 10 s, retries after a quality miss and estimates over about 5 USD need a fresh OK with the total stated. Prices differ per account and parameter; never quote numbers from memory. Failed and moderated (`nsfw`) requests are not charged; queued ones can be canceled with a refund. Never loop retries on a failure: diagnose once, then ask.

## Access paths (use the first that works)

1. **A Higgsfield MCP server** if the user's agent has one connected (look for tools such as `estimate_cost`, `validate_params`, `generate_image`, `generate_video`, `subscribe`, `get_status`, `cancel_job`, `upload_image`, `list_models`, `create_character`; names vary by server). Read each tool's description before first use. Submit returns a job handle; `subscribe` waits. Outputs are URLs: download them.
2. **REST API / official Python SDK** from the shell (details and the request flow in `references/cli.md`): estimate, submit, status, upload. Use for scripted/batch work and when no MCP is connected. Read the API key from an environment variable or your secret manager.
3. **Official `higgsfield` CLI**: only if the user has already logged in themselves. It bills the web-account subscription, not the API key credits, so say which wallet is spent. Never install it, log in, or pass credentials for the user.

Credentials: never print, log, write or put the key in command-line arguments, files or chat; pass it only through an environment variable or your secret manager. Never enable an MCP server's web/cookie/session backend.

## Pick the tier

Say the tier in one line; do not escalate on your own. Exact endpoints, params and caveats: `references/models.md` (image) and `references/models-video.md` (video).

**Image**

| Tier | Model (API path) | Fits |
|---|---|---|
| low | `z-image/turbo` (1k), `xai/grok-imagine-image-2.0` (quality low), `alibaba/qwen-image-3/text-to-image` | drafts, mood boards, fast iteration |
| medium | `higgsfield-ai/soul/v2/standard` (portraits, fashion, editorial, Soul ID), `recraft/v4.1/text-to-image` (flat/vector-style, palette control), `alibaba/qwen-image-3/edit` (1-3 reference edit), `ideogram/v4.0` (text in image) | keyframes, characters, style bible, assets |
| high | `ideogram/v4.0` with `rendering_speed: QUALITY`, `higgsfield-ai/soul/cinema`, `marketing-studio/image` (2k/4k, quality high), `higgsfield/ads-studio/v1.0` (1-8 ad concepts), `recraft/v4.1/pro/text-to-image` | hero stills, posters with text, ads, final keyframes |

**Video**

| Tier | Model (API path) | Fits |
|---|---|---|
| low | `kling-video/v3.0-turbo/image-to-video` (or `text-to-video`), `bytedance/seedance-2.5/*` at 480p, `lightricks/ltx-2.5/*/fast`, `minimax/hailuo-2.3/standard/*` | animatics, motion tests, camera/prompt probing |
| medium | `kling-video/v3.0/std/image-to-video`, `bytedance/seedance-2.5/image-to-video` at 720p, `kling-video/v3.0/pro/*` | per-shot clips, up to 6 shots in one Kling call |
| high | `bytedance/seedance-2.5/reference-to-video` at 1080p, `kling-video/o3/first-last-frame` (`mode: pro`), `higgsfield/cinema-studio/4.0`, `kling-video/v3.0/4k/*`, `bytedance/seedance-2.0/image-to-video` (4K) | final shots, character/product consistency, controlled arcs |

Selection logic:
- Text that must be legible inside the image: Ideogram 4 (short strings only, quote them, keep to a few words); anything longer or exact: overlay later.
- Same person across shots: train Soul ID once (`models.md`), generate keyframes with it, then image-to-video; or pass reference images to Seedance `reference-to-video` / Kling O3 `image-reference`.
- Controlled start and end (morphs, reveals, transitions): `kling-video/o3/first-last-frame`, or `end_image_url` on Seedance/LTX/Wan/PixVerse image-to-video.
- Cinematic look driven by director controls (era, genre, lens, camera, light, palette): `higgsfield/cinema-studio/4.0`. Edit or extend an existing clip: `bytedance/seedance-2.5/video-edit` / `video-extend`. Move one actor's performance onto another image: Kling motion control.
- 4K: Kling 3.0 4K or Seedance 2.0 (the Seedance 2.5 schema stops at 1080p).
- Probe cheap, finish expensive: validate the prompt and framing at the low tier, then rerun the same inputs one tier up only after the user approves.

## Multi-shot production workflow

Detail and prompts: `references/workflows.md`. Every submit below follows "estimate cost, ask the user before submitting".
1. **Brief and budget**: length, aspect, style, characters, shot list; total estimate (shots x clip estimate) stated up front and approved by the user.
2. **Style bible**: one paragraph (medium, palette, light, lens) plus a character sheet; paste both verbatim into every prompt. Soul ID or reference images for people.
3. **Keyframes**: one image per shot (medium/high image tier). Review each before asking to spend on video.
4. **Image-to-video per shot** (the keyframe is the first frame; prompt only motion and camera). Start at the low tier, finish at medium/high. Keep clips 3-8 s; stitch, do not stretch.
5. **Transitions**: first/last-frame or `end_image_url` for morphs, plain cuts or crossfades in FFmpeg otherwise.
6. **Assembly**: download everything, then FFmpeg: concat, audio bed/voiceover, crisp text overlay (titles, captions, logos) rendered in code, not by the model.
7. **Review**: view frames and play the cut; check identity drift, hands, text, artifacts, audio, length, aspect. Report real results, including failures.

## Rules

1. **Download outputs immediately** (retained at least 7 days, then may vanish); default folder `./media/<slug>/`, or the folder the user names. Keep each request's prompt, params, `request_id` and estimate in a small record (a one-line JSON file per request is enough).
2. Input media must be public HTTPS URLs; upload local files with the MCP `upload_image` tool or the API's upload helper (images jpeg/png/webp/gif, audio wav, video mp4). Tell the user their file leaves the machine; confirm before uploading personal photos.
3. Concurrency is limited (about 4 queued/running per account): submit in small waves, backoff on `400 ... concurrent`. After an ambiguous failure check status/output before resubmitting (MCP/SDK retries reuse one idempotency key; plain scripted calls do not unless you send an `Idempotency-Key` header).
4. Status: `queued` can be canceled; `in_progress` cannot. Terminal: `completed`, `failed`, `nsfw`, `canceled`.
5. People and rights: no photoreal real people without consent, no sexual content, no deceptive deepfakes, no trademarked characters or living artists' styles; Soul ID only from the person's own consenting photos. Label AI media when the user will publish it.
6. Never publish, post or upload results anywhere, and never run Higgsfield web/site deploy features, without the user's explicit instruction in this conversation.
7. Model catalog and schemas change: before first use of an endpoint in a session, validate params (`validate_params` or the estimate call, which rejects invalid bodies) rather than guessing field names. They differ per model (`image_url` vs `first_frame_url`, `image_urls`, `end_image_url` vs `last_frame_url`).
8. The `media-generation` skill (if installed) still governs prompts-only requests, quota-based tools and the people/rights policy.

## References

- `references/models.md`: load before calling an image endpoint or Soul ID (paths, key params, limits, error codes).
- `references/models-video.md`: load before calling a video endpoint (Seedance, Kling, Cinema Studio, LTX, Wan, motion control).
- `references/prompting-video.md`: load when writing video/keyframe prompts (Seedance, Kling multi-shot, Cinema Studio tokens, camera/motion vocabulary).
- `references/workflows.md`: load for ads, thumbnails, product photoshoots, explainers, brand sets, Soul ID training and the full multi-shot pipeline.
- `references/cli.md`: load when calling the REST API / SDK from a shell or using the official `higgsfield` CLI.
