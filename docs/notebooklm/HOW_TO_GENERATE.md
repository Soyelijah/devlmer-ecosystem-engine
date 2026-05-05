# How to generate DEE tutorial video/audio with NotebookLM

> Step-by-step guide to use Google NotebookLM to produce a podcast/video tutorial about installing and using Devlmer Ecosystem Engine.

---

## What is NotebookLM?

[NotebookLM](https://notebooklm.google.com) is Google's AI-powered notebook tool. You upload sources (documents, links, videos), and it generates AI-narrated summaries — including a feature called **"Audio Overview"** that produces a 10-minute podcast with two AI hosts discussing your sources naturally.

**Result:** professional-sounding podcast/video with two hosts explaining DEE, ready to share on YouTube, social media, or your website.

---

## Step-by-step generation guide

### Prerequisites

- Google account (any free Gmail works)
- Web browser (Chrome recommended)
- Approximately 15 minutes total

---

### Step 1 — Open NotebookLM

1. Go to https://notebooklm.google.com
2. Sign in with your Google account
3. Click **"Create new notebook"** (top right)

---

### Step 2 — Add sources

NotebookLM works by reading sources you provide. For DEE, upload these in order:

**Required sources (upload these):**

1. **README.md** from DEE repo
   - URL: https://raw.githubusercontent.com/Soyelijah/devlmer-ecosystem-engine/main/README.md
   - Or: Copy from your local clone at `Desktop/projects_qwen/devlmer-ecosystem-engine/README.md`
   - In NotebookLM: click **"Add source"** → **"Paste text"** or **"Website URL"**

2. **INSTALL.md** from DEE repo
   - URL: https://raw.githubusercontent.com/Soyelijah/devlmer-ecosystem-engine/main/INSTALL.md
   - The new comprehensive install guide

3. **CHANGELOG.md** from DEE repo
   - URL: https://raw.githubusercontent.com/Soyelijah/devlmer-ecosystem-engine/main/CHANGELOG.md
   - Includes v4.0.1 release notes

4. **SCRIPT_NARRATIVE.md** (this kit)
   - From `docs/notebooklm/SCRIPT_NARRATIVE.md` in the repo
   - This is the "creative direction" for the AI — it follows the conversational flow we want

**Optional sources (improve depth):**

5. GitHub releases page: https://github.com/Soyelijah/devlmer-ecosystem-engine/releases
6. Issue #24, #25, #26 (closed) — for context on v4.0.1 fixes

**Tip:** NotebookLM can handle up to 50 sources. Don't overload — 4 to 6 well-chosen sources work better than 20 random ones.

---

### Step 3 — Customize the audio overview

After uploading sources:

1. In the **Studio** panel (right side), find **"Audio Overview"**
2. Click **"Customize"** (next to the Generate button)
3. Paste this guidance prompt:

```
Generate a podcast-style audio overview targeting non-technical users who are
curious about Devlmer Ecosystem Engine (DEE). Two hosts having a natural
conversation. One host is a curious newcomer asking practical questions about
installation, security, and usage. The other host is knowledgeable and
explains in accessible language. Length: 8-12 minutes. Cover:

1. What DEE is and what it does (skills, commands, hooks, MCPs)
2. The 4 installation methods, when to use each
3. The new --dry-run feature in v4.0.1 for safe previews
4. Security: API keys are now gitignored automatically (v4.0.1)
5. Post-install commands: /dee-doctor, /dee-status, /dee-demo
6. How to update an existing installation
7. How to contribute on GitHub

Tone: friendly, professional, accessible. Avoid corporate jargon.
End with a clear call to action: visit github.com/Soyelijah/devlmer-ecosystem-engine.

Reference the SCRIPT_NARRATIVE.md document I uploaded for the conversational
flow and key talking points. Use it as creative direction, not verbatim.
```

4. Click **"Generate"**
5. Wait 2–5 minutes (NotebookLM generates the audio)

---

### Step 4 — Review and iterate

When the audio is ready:

1. Click play and listen all the way through
2. Check for:
   - ✅ Accuracy (DEE features, install commands, version numbers)
   - ✅ Pacing (not too fast, not too slow)
   - ✅ Tone (conversational, not robotic)
   - ✅ Call to action at the end
3. If something's off, click **"Customize"** again, refine the prompt, regenerate

**Common refinements:**

- "Make it shorter, around 8 minutes"
- "More energy in the first minute"
- "Less technical jargon"
- "Emphasize the v4.0.1 security fix more"

---

### Step 5 — Download the audio

Once happy:

1. Click the **three-dot menu** on the audio overview
2. Select **"Download"**
3. Save as `dee-installation-tutorial.wav` (or `.mp3`)

---

### Step 6 — Convert audio to video (optional)

To publish on YouTube/social media as video:

**Option A — Easiest: with a static image**

```bash
# Use ffmpeg (free, cross-platform)
ffmpeg -loop 1 -i cover.png -i dee-installation-tutorial.wav \
  -c:v libx264 -tune stillimage -c:a aac -b:a 192k -pix_fmt yuv420p \
  -shortest dee-installation-tutorial.mp4
```

Where `cover.png` is a logo image (e.g., DEE banner, 1920×1080).

**Option B — Animated waveform: use [Headliner](https://headliner.app/)**

1. Free service, sign up
2. Upload audio
3. Choose template (waveform animation, captions, branding)
4. Export as MP4

**Option C — Professional: hire video editor**

- Add captions, B-roll, animations
- Sync to key talking points
- Deliver as YouTube-ready MP4

---

### Step 7 — Publish

**Where to share:**

- **YouTube** — full video, public, listed under "Programming Tutorials"
- **GitHub** — link the video from README.md and INSTALL.md
- **Twitter/X** — short clip + link to full video
- **LinkedIn** — professional version
- **Devlmer.com** — embed on landing page

**Suggested video metadata:**

- **Title:** "Install Devlmer Ecosystem Engine in 60 seconds — DEE v4.0.1 walkthrough"
- **Description:** Include link to GitHub repo, INSTALL.md, and Devlmer.com
- **Tags:** `claude-code`, `cowork`, `ai-tools`, `developer-tools`, `git`, `bash`, `installation`, `tutorial`
- **Thumbnail:** DEE logo + "Install in 60s" text

---

## Quality checklist before publishing

Before sharing publicly, verify:

- [ ] Audio is clear, no glitches
- [ ] Hosts pronounce "Devlmer Ecosystem Engine" correctly
- [ ] Install commands are accurate (especially the curl one-liner)
- [ ] Version 4.0.1 is mentioned
- [ ] No misleading claims about features
- [ ] GitHub URL is correct
- [ ] Length is between 8-12 minutes (sweet spot for engagement)
- [ ] CTA at the end is clear

---

## Iterating with new releases

When DEE releases new versions:

1. Update `SCRIPT_NARRATIVE.md` with new features
2. Update `CHANGELOG.md` reference
3. Re-run NotebookLM with same prompt
4. Generate new audio overview
5. Replace old video on YouTube with new version (or upload as v4.0.2 tutorial)

NotebookLM keeps your notebook for re-runs, so you don't have to re-upload sources every time.

---

## Troubleshooting

### "Audio overview is too generic"

Add more specific guidance to the prompt:

```
Cover SPECIFICALLY these points: [list 5-7 bullet points]
Use the conversational style from SCRIPT_NARRATIVE.md.
Mention version v4.0.1 multiple times.
```

### "Hosts are too formal"

Add: "Make the conversation casual and natural. The newcomer host should ask follow-up questions like a real person would."

### "Audio is too long"

Add: "Target 8 minutes maximum. Cover the most important 5 points only."

### "It mispronounces 'Devlmer'"

Currently NotebookLM may pronounce it as "Devalmer" or "Develmer". You can:
1. Add to prompt: "Pronounce 'Devlmer' as DEV-luh-mur"
2. Or accept the variant and clarify in video description

---

## Cost

- **NotebookLM:** Free (currently)
- **YouTube hosting:** Free
- **Headliner waveform:** Free tier with watermark, $14/mo unlimited
- **ffmpeg approach:** Free, no watermark

Total cost to produce: $0 if you use ffmpeg + free tier tools.

---

## Done!

You now have a professional podcast/video tutorial for DEE that:

✅ Reaches non-technical users
✅ Covers all 4 install methods
✅ Explains v4.0.1 security improvements
✅ Generated automatically from your existing docs
✅ Can be regenerated on every release without manual scripting

**Next:** add the YouTube link to README.md so visitors can watch before installing.
