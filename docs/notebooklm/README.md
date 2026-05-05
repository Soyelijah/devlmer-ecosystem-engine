# DEE NotebookLM Kit

Generate professional installation tutorials (audio podcast or video) for Devlmer Ecosystem Engine using Google's NotebookLM.

---

## What's in this directory

| File | Purpose |
|---|---|
| **[HOW_TO_GENERATE.md](HOW_TO_GENERATE.md)** | Step-by-step walkthrough: open NotebookLM → upload sources → generate audio → publish |
| **[SOURCES.md](SOURCES.md)** | Curated list of 8 sources to upload to NotebookLM (in priority order) |
| **[SCRIPT_NARRATIVE.md](SCRIPT_NARRATIVE.md)** | Pre-written conversational script for two-host podcast format |

---

## Quick start

1. Open https://notebooklm.google.com and sign in
2. Create a new notebook
3. Upload the 8 sources listed in [SOURCES.md](SOURCES.md)
4. Click "Audio Overview" → "Customize"
5. Paste the prompt from [HOW_TO_GENERATE.md](HOW_TO_GENERATE.md) Step 3
6. Click Generate, wait 2–5 minutes
7. Download the audio
8. (Optional) Convert to video with ffmpeg or Headliner
9. Publish to YouTube + link from README.md

**Total time:** ~15 minutes from zero to published tutorial.

---

## Why NotebookLM?

- ✅ **Free** (currently)
- ✅ **AI-narrated** in natural conversational style
- ✅ **Two-host podcast format** sounds like a real interview, not a robot reading docs
- ✅ **Auto-generates** from your existing docs (no manual scripting)
- ✅ **Re-runnable** when DEE releases new versions
- ✅ **Cross-platform** access (any browser)

---

## Updating tutorials when DEE evolves

When v4.0.2 or v4.1.0 releases:

1. Update `SCRIPT_NARRATIVE.md` in this directory with new features
2. Update `CHANGELOG.md` references
3. Open existing NotebookLM notebook (your sources stay)
4. Click "Refresh sources"
5. Re-generate Audio Overview
6. Replace YouTube video with new version

NotebookLM remembers your prompts, so consistent style across releases.

---

## Production-quality output

For a professional video that goes on YouTube + Devlmer.com landing:

1. Generate base audio with NotebookLM (this kit)
2. Process audio with [Adobe Podcast](https://podcast.adobe.com/) (free) for noise reduction
3. Create branded waveform with [Headliner](https://headliner.app/) ($14/mo unlimited)
4. Add captions with YouTube Studio auto-caption
5. Publish

Estimated total cost: $0–$14/mo depending on tools used.

---

## Audience

The generated tutorial is designed to reach:

- 🌟 **Developers** evaluating AI-assisted tools
- 🌟 **DevOps engineers** considering ecosystem-wide automation
- 🌟 **Tech leads** looking for team-wide AI infrastructure
- 🌟 **Solopreneurs** building products with Claude Code/Cowork
- 🌟 **Indie hackers** wanting professional dev workflows

The script is calibrated for someone who has heard of Claude Code/Cowork but doesn't know DEE specifically.

---

**Maintained by:** [@Soyelijah](https://github.com/Soyelijah) — Devlmer
