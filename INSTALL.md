# Installing Devlmer Ecosystem Engine (DEE)

> **Quick Start:** copy-paste one of the methods below. Takes 60 seconds.

---

## Choose your installation method

| Method | For whom | Platform | Time |
|---|---|---|---|
| **[1. One-liner curl](#method-1--one-liner-curl-recommended)** | First-time users, casual installs | macOS / Linux | 30s |
| **[2. git clone](#method-2--git-clone-recommended-for-developers)** | Developers, contributors, power users | All platforms | 1m |
| **[3. ZIP download](#method-3--zip-download-windows-without-git)** | Windows users without Git | Windows | 2m |
| **[4. Dry-run preview](#method-4--dry-run-preview-cautious-users)** | Cautious users, CI pipelines | All platforms | 1m |

---

## Method 1 — One-liner curl (RECOMMENDED)

The fastest way to install DEE in any project:

```bash
curl -fsSL https://raw.githubusercontent.com/Soyelijah/devlmer-ecosystem-engine/main/install-cli.sh | bash
```

**What this does:**
1. Downloads `install-cli.sh`
2. Clones DEE temporarily to `/tmp/dee-install/`
3. Asks where to install (default: current directory)
4. Sets up `.claude/` with skills, commands, hooks, and config

**Requirements:** macOS 10.14+, Linux (Ubuntu 20+), or Windows with Git Bash.

---

## Method 2 — git clone (recommended for developers)

If you have Git installed, this is the most flexible method:

```bash
# Clone DEE to a temporary directory
git clone https://github.com/Soyelijah/devlmer-ecosystem-engine.git /tmp/dee-install

# Install in your project
bash /tmp/dee-install/install.sh /path/to/your/project

# Optional: clean up
rm -rf /tmp/dee-install
```

**Replace `/path/to/your/project`** with your actual project directory.

**Examples:**
```bash
# macOS / Linux
bash /tmp/dee-install/install.sh ~/Documents/my-app

# Windows (Git Bash)
bash /tmp/dee-install/install.sh "C:/Users/YourName/Documents/my-app"

# Current directory
bash /tmp/dee-install/install.sh .
```

---

## Method 3 — ZIP download (Windows without Git)

If you don't have Git installed:

```bash
# 1. Download DEE as ZIP
curl -L -o dee.zip https://github.com/Soyelijah/devlmer-ecosystem-engine/archive/refs/heads/main.zip

# 2. Extract
unzip dee.zip

# 3. Install
cd devlmer-ecosystem-engine-main
bash install.sh "C:/path/to/your/project"
```

Requires `bash` (comes with Git Bash on Windows).

---

## Method 4 — Dry-run preview (cautious users)

**NEW in v4.0.1:** Preview exactly what DEE would do BEFORE making any changes.

```bash
# Clone first
git clone https://github.com/Soyelijah/devlmer-ecosystem-engine.git /tmp/dee-install

# Dry-run: shows predicted changes, modifies NOTHING
bash /tmp/dee-install/install.sh /path/to/your/project --dry-run --non-interactive

# If you like the preview, run for real:
bash /tmp/dee-install/install.sh /path/to/your/project
```

**Sample dry-run output:**
```
[DRY-RUN] create /your-project/.claude/
[DRY-RUN] create /your-project/.claude/skills/ (64 skill(s))
[DRY-RUN] create /your-project/.claude/commands/ (8 slash command(s))
[DRY-RUN] modify /your-project/CLAUDE.md (append DEE footer)
... 19 total predicted operations

DRY-RUN SUMMARY
  + Would CREATE  : 16 item(s)
  ~ Would MODIFY  : 3 item(s)
  - Would DELETE  : 0 item(s)
```

`--dry-run` is guaranteed read-only — your project stays untouched until you run without the flag.

---

## Requirements

Before installing, ensure you have:

| Tool | Minimum version | Check |
|---|---|---|
| **Node.js** | 18+ | `node --version` |
| **Python** | 3.8+ | `python3 --version` |
| **Git** | 2.x+ | `git --version` |
| **bash** | 4.x+ (or 3.2 macOS) | `bash --version` |
| **Claude Code** or **Cowork** | latest | — |

### Install missing dependencies

**macOS:**
```bash
brew install node python3 git
```

**Linux (Ubuntu/Debian):**
```bash
sudo apt update && sudo apt install -y nodejs npm python3 python3-pip git
```

**Windows:**
- Node.js: https://nodejs.org/
- Python: https://www.python.org/downloads/
- Git for Windows (includes Git Bash): https://git-scm.com/download/win

---

## Post-install security checklist (IMPORTANT)

After any installation method, **immediately** add API key configs to your project's `.gitignore`:

```bash
cd /path/to/your/project

cat >> .gitignore <<'EOF'

# DEE local API keys — never commit
.claude/config/nano-banana-config.json
.claude/config/github-config.json
.claude/PROJECT_PROFILE.json
.claude/logs/
.claude/.dee-backup-*/
EOF
```

This prevents your `GEMINI_API_KEY` and `GITHUB_TOKEN` from accidentally being committed to a public repository.

---

## First-time setup (after install)

1. **Open your project in Claude Code or Cowork**
2. **Run health check:**
   ```
   /dee-doctor
   ```
3. **View what's installed:**
   ```
   /dee-status
   ```
4. **Take the interactive tour:**
   ```
   /dee-demo
   ```
5. **Configure API keys** (optional, only if you want image generation):
   - Edit `.claude/config/nano-banana-config.json`
   - Set your `GEMINI_API_KEY` (get one at https://aistudio.google.com/apikey)

---

## Updating an existing installation

DEE includes an `update.sh` script that preserves your local config:

```bash
cd /path/to/devlmer-ecosystem-engine  # or clone fresh
git pull origin main
bash update.sh /path/to/your/project
```

`update.sh` automatically backs up:
- `mcp-env-setup.sh`
- `settings.json`
- `PROJECT_PROFILE.json`
- `CLAUDE.md`

And updates skills, commands, hooks, and scripts.

---

## Installation flags reference

```bash
bash install.sh /path/to/project [OPTIONS]
```

| Flag | Description |
|---|---|
| `--help` | Show help |
| `--dry-run` | **NEW in v4.0.1** Preview changes without modifying files |
| `--skills-only` | Install skills only, skip project scanning |
| `--scan-only` | Install base config + project scan (skips skills/MCP — NOT a dry-run, see `--dry-run`) |
| `--verbose` | Enable verbose output |
| `--no-external` | Skip external skill installations (npm) |
| `--no-mcp` | Skip MCP installations |
| `--no-github` | Skip GitHub authentication |
| `--non-interactive`, `--yes`, `-y` | Skip ALL prompts (use defaults) |
| `--github-token TOKEN` | Provide GitHub PAT |
| `--gemini-key KEY` | Provide Gemini API key |
| `--update` | Re-copy skills, regenerate commands, update settings.json |

---

## Troubleshooting

### `bash: install.sh: Permission denied`
```bash
chmod +x /tmp/dee-install/install.sh
bash /tmp/dee-install/install.sh /path/to/project
```

### `python3: command not found` (macOS)
```bash
brew install python3
# or use full path:
which python3
```

### Windows: `UnicodeEncodeError` during install
**Fixed in v4.0.1.** Update DEE:
```bash
cd /path/to/devlmer-ecosystem-engine
git pull origin main
```

### `--scan-only` modifies my project (expected dry-run)
**Fixed in v4.0.1.** Use `--dry-run` instead:
```bash
bash install.sh /path/to/project --dry-run
```

### My API key got committed by accident
**Fixed in v4.0.1.** Update DEE — `.gitignore` now covers config files.

If you committed a key:
1. Rotate the key immediately at the provider's console
2. Use [BFG Repo-Cleaner](https://rtyley.github.io/bfg-repo-cleaner/) or `git-filter-repo` to remove from history
3. Force-push to overwrite remote (coordinate with team)

### Hooks not running on Windows
**Fixed in v4.0.1.** Hooks now use Python stdlib for cross-platform compatibility. Update DEE.

### "Domain: unknown" in banner / wrong tech detection
Known issue (#30). The fingerprinter sometimes misclassifies. Workaround: regenerate profile manually:
```bash
cd /path/to/your/project
python3 .claude/detect_project.py "$(pwd)" > .claude/PROJECT_PROFILE.json
```

---

## Uninstall DEE

To remove DEE from a project:

```bash
cd /path/to/your/project

# Backup first (just in case)
cp -r .claude .claude.backup-$(date +%Y%m%d)
cp CLAUDE.md CLAUDE.md.backup

# Remove DEE artifacts
rm -rf .claude
rm -f CLAUDE.md
rm -f .deeignore

# Restore your CLAUDE.md (optional, if you had one before DEE)
mv CLAUDE.md.backup CLAUDE.md
```

DEE never modifies your project's source code, so removing `.claude/` is safe.

---

## Verify installation success

Run this command in your DEE-installed project:

```bash
ls -la .claude/
```

You should see:
```
.claude/
├── agents/         (agent definitions)
├── commands/       (26 slash commands)
├── config/         (4 config files)
├── hooks/          (3 hooks)
├── skills/         (25 skills)
├── settings.json   (Claude Code config)
└── PROJECT_PROFILE.json  (auto-generated)
```

If all directories exist, DEE is correctly installed.

---

## Get help

- 📚 Full documentation: [README.md](README.md)
- 🎧 Audio/video tutorial: [docs/notebooklm/](docs/notebooklm/) (generate your own with NotebookLM)
- 🐛 Report bugs: [GitHub Issues](https://github.com/Soyelijah/devlmer-ecosystem-engine/issues)
- 💬 Discussions: [GitHub Discussions](https://github.com/Soyelijah/devlmer-ecosystem-engine/discussions)
- 🌐 Website: [devlmer.com](https://devlmer.com)

---

## What's new in v4.0.1

- 🔒 **Security:** API key configs now gitignored by default (#26)
- 🪟 **Windows:** No more `UnicodeEncodeError` during install (#24)
- 🛠️ **DX:** New `--dry-run` flag for safe previews (#25)

See [CHANGELOG.md](CHANGELOG.md) for full release notes.

---

**Built with ❤️ by [@Soyelijah](https://github.com/Soyelijah) — Devlmer**
