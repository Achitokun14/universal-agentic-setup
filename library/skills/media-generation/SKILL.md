---
name: media-generation
description: "Write prompts for, or generate, images, video, music, posters, generative art and GIFs with the lightest suitable tool. Use when the user asks for AI media or code-made art; ask before any paid step."
---

# Media generation

Make or prompt images, video, music, posters, generative art and GIFs with the lightest tool that fits. In order of preference: write a prompt only; use an image/video tool the agent already has; code-made art (no quota); everything else (paid APIs, browser automation, local models) is optional and needs the user's go-ahead.

## Ask the user first (cost / account)
Any step that spends money or quota, or acts through the user's accounts, needs an explicit yes in this conversation, naming the tool and what it will cost or consume:
- paid generation APIs or credits (image/video/music vendors, hosted ComfyUI/cloud services);
- subscription-backed generation (a chat or cloud-AI plan's image/video/music allowance);
- browser automation of a web generation UI (Google Flow/Mixboard-style tools or extensions): it drives the user's logged-in account and may breach the service's terms or exhaust credits;
- installing large software or downloading multi-GB models.
State the estimate (credits, dollars, minutes, GB) before asking. Never use stored logins, cookies or API keys the user did not hand you for this task; read keys only from the environment variable the user names.

## Pick the tier

| Tier | Use when | How |
|---|---|---|
| **low** | User wants prompts only, or a prompt to paste elsewhere | Write the prompt with `references/prompt-images.md` (images) or `references/prompt-videos.md` (video). No generation call. Return 1-3 prompt variants plus settings (aspect, duration, negative constraints). |
| **medium: image** | One image or an edit | The agent's built-in image-generation tool, if it has one (see the field mapping in `references/prompt-images.md`). If none exists, give the prompt and settings and say so; do not invent a tool. Show the result path; iterate by changing one thing. |
| **medium: video / music** | One clip or one track | Only through a tool the user has set up and approved (for example a browser-automation MCP for Google Flow/Mixboard: `references/flow-and-mixboard.md`) or a vendor skill/API the user names. Otherwise deliver time-coded prompts. |
| **high: API-key image/video** | Paid credits: hosted video models, trained characters, text-heavy images, multi-shot films | The `higgsfield` skill, if installed, or the vendor's own documented API. Estimate cost and state it before any submit; ask first. |
| **high: series / batches** | Several videos, brand or image sets, consistent characters | Check the usage ledger/quota if the tool has one, confirm the count with the user before queueing, then batch with a prompts file or repeated calls carrying a verbatim style/character block. |
| **high: code-made** | Exact typography, posters, prints, reproducible art, GIFs, no quota | Static poster/art PNG/PDF: `references/canvas-design.md`. Seeded p5.js generative pieces: `references/algorithmic-art.md`. Slack GIFs/emoji: `references/slack-gif.md` (helpers in `scripts/slack_gif/`, cross-platform Python). |
| **high: local models / post** | Offline generation, upscaling, voice, programmatic video | ComfyUI (needs approval to install; hardware dependent): `references/comfyui.md`; upscaling with Upscayl or `ffmpeg`; voice with a local TTS the user approves; programmatic video with the `remotion-best-practices` skill if installed. |

Choose the tier from the request, say it in one line, and do not escalate on your own. Images: the built-in image tool before any browser-driven service. Video and music: a prompt first; generation only via an approved tool. Exact text, logos with wordmarks, charts, geometric posters: code-made art, or generate imagery then typeset text in code.

## Core rules
1. **Write the prompt before calling anything.** Apply the checklists in the prompt references: concrete subject, setting, light, camera/composition, style, exact quoted text (short), what must stay unchanged for edits; for video add camera moves, audio layers and the repeated character sheet.
2. **Ask only what changes the output** (aspect/size, duration, style anchor, text to render, count). Otherwise pick sensible defaults and state them.
3. **Quota and cost are real.** Check any usage ledger before batches, confirm any run above ~5 generations, and never loop retries on failures: diagnose once, then ask.
4. **Never operate or log into the user's automation browser yourself**: do not start, sign into or reconfigure it. Relay any "operator needed" / "browser not reachable" message verbatim and stop.
5. **People and rights**: do not generate photoreal images of real, identifiable people without their consent, sexual content involving real people, deceptive deepfakes, or confusable copies of living artists' styles/trademarked characters. Voice cloning only with the voice owner's consent. Label AI-generated media as such when the user will publish it.
6. **No publishing or uploading** generated media anywhere (social, stores, hosting, chat) without the user's explicit instruction in this conversation. Save locally and report the path. Default output folder: the one the user names, else `./media/<slug>/`.
7. **Verify what you made**: open the file (view the image/frames), check text spelling, aspect, clipping, loop, file size; report real results, including failures. Do not describe an output you did not look at.
8. **Do not assert tool state**: check before use (`which comfy` / `where comfy`, `typst`, `ffmpeg`, the tool's status call); if missing, give the install command and ask when it is large.
9. Keep prompts, seeds and settings with the output (a small `prompts.md` next to batches) so results are reproducible.
10. **No bundled fonts.** For text in code-made art use fonts the user already has installed, or a system font (see `references/canvas-design.md`); never download fonts without asking.

## Quick choices
- Thumbnail/hero/illustration: image tool, 16:9 or 3:2, explicit text in quotes, about 1536x1024.
- Logo exploration: several image variants at 1:1, then rebuild the chosen mark as vector/typography in code if exact lines matter.
- 8 s cinematic shot: write a time-coded prompt (`references/prompt-videos.md`); judge the result, then adjust the prompt (rerunning the same prompt rarely varies).
- Music bed: genre, mood, tempo (bpm), instruments, "no vocals".
- Poster for print or a typographic piece: `references/canvas-design.md` (Pillow/Typst), 2:3 at 2400x3600 or the paper size named.
- Animated Slack emoji: `references/slack-gif.md`; keep within the size/duration targets there.
- Upscale a good result 2x/4x: Upscayl (`references/comfyui.md`) or `ffmpeg` Lanczos for plain resizes.

## Optional alternatives
`imagine-cli` (OpenAI/Gemini image CLI) is an optional alternative only: see `references/imagine-cli-saved.md`. Do not install or run it without the user's decision.

## References
- `references/prompt-images.md` - image prompting techniques and the structured-field mapping.
- `references/prompt-videos.md` - video prompting (scene layers, camera, audio, time codes, references, consistency).
- `references/flow-and-mixboard.md` - optional browser-automation tools for Google Flow/Mixboard: ordering, quota and consent rules.
- `references/canvas-design.md` - philosophy-then-canvas poster/art method, tools, fonts.
- `references/algorithmic-art.md` - seeded p5.js method and a viewer skeleton.
- `references/slack-gif.md` - Slack GIF/emoji targets, helper API, motion recipes.
- `references/comfyui.md` - local ComfyUI, Upscayl, voice, Remotion/ffmpeg pointers.
- `references/imagine-cli-saved.md` - imagine-cli optional alternative.
- Assets/scripts: `assets/LICENSE-anthropics-skills-Apache-2.0.txt`, `scripts/slack_gif/` (Apache-2.0, Python; see `SOURCES.md`).
