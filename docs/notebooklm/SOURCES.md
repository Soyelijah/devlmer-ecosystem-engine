# NotebookLM Sources for DEE Tutorial Generation

> Curated list of sources to upload to NotebookLM for generating the DEE installation tutorial podcast/video. Listed in priority order.

---

## Required sources (upload these in this order)

### 1. INSTALL.md — Primary source
- **Path:** `INSTALL.md` (root of repo)
- **URL:** https://raw.githubusercontent.com/Soyelijah/devlmer-ecosystem-engine/main/INSTALL.md
- **Why:** Comprehensive installation guide with 4 methods, requirements, troubleshooting
- **NotebookLM tip:** Upload as "Website URL" so it stays current with future updates

### 2. README.md — Project context
- **Path:** `README.md` (root of repo)
- **URL:** https://raw.githubusercontent.com/Soyelijah/devlmer-ecosystem-engine/main/README.md
- **Why:** What DEE is, who it's for, what it includes (skills, MCPs, hooks)

### 3. CHANGELOG.md — Release context
- **Path:** `CHANGELOG.md` (root of repo)
- **URL:** https://raw.githubusercontent.com/Soyelijah/devlmer-ecosystem-engine/main/CHANGELOG.md
- **Why:** v4.0.1 changes (Windows fixes, security hardening, dry-run flag)

### 4. SCRIPT_NARRATIVE.md — Creative direction
- **Path:** `docs/notebooklm/SCRIPT_NARRATIVE.md`
- **Why:** Pre-written conversational script in two-host format. NotebookLM uses this as the structural template for the audio overview

---

## Recommended sources (improve depth)

### 5. Issue #26 — Security fix context
- **URL:** https://github.com/Soyelijah/devlmer-ecosystem-engine/issues/26
- **Why:** Detailed explanation of the API key gitignore fix in v4.0.1

### 6. Issue #24 — Windows compatibility fix
- **URL:** https://github.com/Soyelijah/devlmer-ecosystem-engine/issues/24
- **Why:** Context on the UnicodeEncodeError fix in v4.0.1

### 7. Issue #25 — Dry-run feature context
- **URL:** https://github.com/Soyelijah/devlmer-ecosystem-engine/issues/25
- **Why:** Why `--dry-run` was added in v4.0.1

### 8. GitHub Releases page
- **URL:** https://github.com/Soyelijah/devlmer-ecosystem-engine/releases
- **Why:** Official release notes, version history

---

## Optional sources (for advanced versions)

### 9. .env.example — Security pattern
- **URL:** https://raw.githubusercontent.com/Soyelijah/devlmer-ecosystem-engine/main/.env.example
- **Why:** Shows the safe-to-commit template approach for API keys

### 10. install.sh source code (advanced viewers)
- **URL:** https://raw.githubusercontent.com/Soyelijah/devlmer-ecosystem-engine/main/install.sh
- **Why:** Power users may want to peek at what the installer actually does

---

## Sources to AVOID uploading

These would dilute the tutorial focus:

- ❌ Skills directory contents (too detailed for tutorial)
- ❌ Internal scripts (`scripts/detect_project.py`, etc.)
- ❌ Old DIAGNOSIS.md (historical context, not actionable)
- ❌ Closed issues unrelated to v4.0.1
- ❌ License/contributing files (administrative)

---

## Total sources: 4 required + 4 recommended = **8 sources**

NotebookLM works best with focused, high-quality sources. 8 well-chosen sources produce better audio than 30 random ones.

---

## Source upload order in NotebookLM

When uploading, do them in this exact order so NotebookLM weights them correctly:

```
1. INSTALL.md        ← primary install reference
2. SCRIPT_NARRATIVE.md ← creative direction
3. README.md         ← project context
4. CHANGELOG.md      ← v4.0.1 specifics
5. Issue #26         ← security context
6. Issue #24         ← Windows fix context
7. Issue #25         ← dry-run context
8. GitHub Releases   ← official release notes
```

NotebookLM treats earlier sources as more authoritative.

---

## Refresh strategy

When DEE releases a new version:

1. Update `INSTALL.md` and `CHANGELOG.md` in the repo
2. Update version numbers in `SCRIPT_NARRATIVE.md`
3. Open NotebookLM, click "Refresh" on each source
4. Regenerate Audio Overview with same prompt
5. Result: updated tutorial reflecting the new version automatically

This avoids re-recording videos manually for every release.

---

## Generated artifacts naming convention

When you produce videos from these sources, suggested naming:

- **v4.0.1 tutorial:** `dee-tutorial-v4.0.1-installation.mp4`
- **Quick install:** `dee-quickstart-v4.0.1-60s.mp4`
- **Security focus:** `dee-security-v4.0.1.mp4`

This makes them findable later when DEE evolves to v5.0.

---

## See also

- [HOW_TO_GENERATE.md](HOW_TO_GENERATE.md) — step-by-step NotebookLM walkthrough
- [SCRIPT_NARRATIVE.md](SCRIPT_NARRATIVE.md) — conversational script template
