# DEE System Diagnosis — Agent Team Review

**Date:** 2026-04-10  
**Analyzed by:** Claude Sonnet 4.6 (active deployment on `expense-approval-app`)  
**Severity scale:** 🔴 Critical | 🟠 High | 🟡 Medium | 🟢 Low

---

## Executive Summary

The Devlmer Ecosystem Engine has strong architecture bones but ships with several gaps that degrade its real-world effectiveness. Six issues were found across domain detection, agent quality, context loading, hook design, and missing files. This document is a field report from actual production use — every issue below was observed while running the engine on a real project.

---

## Issue 1 — Domain Detection: `fintech` keywords target crypto/trading, not expense management

**Severity:** 🔴 Critical  
**File:** `scripts/detect_project.py`, lines 241–248  

### Problem

The `fintech` domain pattern is tuned for algorithmic trading apps:

```python
"fintech": {
    "keywords": ["trading:3", "portfolio:3", "balance:2", "transaction:2",
                "ledger:3", "wallet:3", "exchange:2", "kyc:3", "compliance:2",
                "strategy:2", "signal:3", "binance:3", "order:1", "position:3",
                "risk:2", "pnl:3", "profit:2", "stop_loss:3", "take_profit:3",
                "candlestick:3", "ohlcv:3", "ticker:2", "market_data:3",
                "backtest:3", "drawdown:3", "sharpe:3", "alpha:3"],
```

An **expense approval app** (or any B2B fintech: reimbursements, budgets, invoicing, AP/AR) scores 0 on most of these terms. Meanwhile, the `social` domain wins because code files contain the words `notification`, `message`, `post` (as HTTP method or comment text), and `comment` (code comments) — generic programming vocabulary that gets false-positive matched.

**Evidence:** `expense-approval-app` was classified as `social` with `confidence: 1.0` despite being a multi-role expense management system.

### Fix

1. Split `fintech` into two sub-domains:
   - `fintech_trading` — keep current keywords
   - `expense_management` — new domain for AP/AR/reimbursement/budget apps

2. Add `expense_management` domain:

```python
"expense_management": {
    "keywords": [
        "expense:3", "reimbursement:3", "approval:3", "approver:3",
        "receipt:3", "budget:2", "cost_center:3", "policy:2",
        "invoice:2", "claim:2", "payroll:2", "finance:2",
        "audit:2", "compliance:2", "accounting:2", "spend:3",
        "department:2", "gl_code:3", "per_diem:3", "mileage:3",
        "pending_approval:3", "rejected:2", "reimbursed:3"
    ],
    "tech_boost": {"stripe": 0.1, "drizzle": 0.1}
},
```

3. Reduce false-positive weight on `social` by excluding generic programming terms. The `post:2` and `comment:2` keywords match HTTP methods and code comments — consider context-aware matching (e.g., only count if in variable/function names, not string literals).

---

## Issue 2 — Agents are hollow template stubs

**Severity:** 🔴 Critical  
**Files:** `.claude/agents/*.md` (all 16 files)

### Problem

The agents installed by the engine (`feed_agent`, `eval_agent`, `moderation_agent`, etc.) contain only 1–3 line descriptions with no actual instructions. Example of a typical agent file as installed:

```markdown
# feed_agent
Optimize feed algorithms, ranking, personalization, and content quality scoring
```

Claude cannot operate as a useful agent from this stub. When Claude spawns a subagent with only a role description and no instructions, the subagent has to invent its approach from scratch every time — no consistency, no domain knowledge, no workflow steps.

The agents are also tuned for social/ecommerce domains (feed, moderation, recommendation, inventory, pricing, SEO) and were installed on a fintech expense app where none of them are relevant.

### Fix

1. **Agents need real instructions**, not just role descriptions. Minimum viable agent file:
   - When to activate (trigger conditions)
   - Step-by-step workflow to follow
   - What inputs it expects
   - What outputs it produces
   - Domain-specific knowledge it applies

2. **Agent selection must be domain-aware.** The orchestrator should install only agents relevant to the detected domain. Example mapping:

```python
DOMAIN_AGENTS = {
    "expense_management": ["audit-agent", "policy-enforcer", "budget-monitor", "approvals-reviewer"],
    "social": ["feed_agent", "moderation_agent", "recommendation_agent"],
    "saas": ["churn-detector", "usage-monitor", "billing-agent"],
    "ecommerce": ["inventory_agent", "pricing_agent", "seo_agent"],
}
```

3. For `expense_management` specifically, useful agents would be:
   - `approval-workflow-agent` — validates state machine transitions
   - `policy-compliance-agent` — checks receipt requirements, amount limits
   - `budget-alert-agent` — monitors cost center spend vs. limits
   - `audit-trail-agent` — ensures every state change has an audit log entry

---

## Issue 3 — SessionStart hook loads ~490KB of skill content blindly

**Severity:** 🟠 High  
**File:** `.claude/settings.json` → `hooks.SessionStart`

### Problem

The current SessionStart hook cats ALL skill SKILL.md files into the context at session start. On a project with 65 skills, this produces ~490KB of context injection every session. This causes:

1. **Context window pressure** — skills crowd out actual code content
2. **No selectivity** — generic skills (algorithmic-art, brand-guidelines, canvas-design) load on a backend Node.js project
3. **Slow session start** — the hook runs for several seconds
4. **The wrong skills show up** — domain mismatch means irrelevant skills auto-activate

### Current approach (problematic):
```bash
for skill in senior-backend senior-security senior-frontend ... ; do
  cat "$SKILL_DIR/$skill/SKILL.md"
done
```

### Fix

Implement **smart skill selection** in SessionStart using PROJECT_PROFILE.json:

```bash
# Read domain from profile
DOMAIN=$(python3 -c "import json; p=json.load(open('$PROFILE')); print(p.get('fingerprint',{}).get('domain','unknown'))" 2>/dev/null)

# Load domain-appropriate skills only
case $DOMAIN in
  expense_management|fintech)
    SKILLS="senior-backend senior-security trpc-patterns expense-workflow db-migration"
    ;;
  social)
    SKILLS="senior-backend senior-frontend real-time-testing websocket-validation"
    ;;
  saas|web_app)
    SKILLS="senior-backend senior-frontend senior-architect code-reviewer"
    ;;
  *)
    SKILLS="senior-backend senior-security code-reviewer"
    ;;
esac

for skill in $SKILLS; do
  [ -f "$SKILL_DIR/$skill/SKILL.md" ] && cat "$SKILL_DIR/$skill/SKILL.md"
done
```

Target: load 4–6 domain-relevant skills (~80KB) instead of 14+ skills (~490KB).

---

## Issue 4 — No PreToolUse hook for proactive skill activation

**Severity:** 🟡 Medium  
**File:** `.claude/settings.json`

### Problem

Skills are supposed to "auto-activate" when relevant. The current hook only reacts after edits (PostToolUse on Edit|Write). There is no mechanism to suggest relevant skills **before** Claude starts working on a file.

The PostToolUse hook currently just echoes a hint message — Claude rarely reads hook stderr output mid-task.

### Fix

Add a PreToolUse hook that fires before Edit/Write operations and injects the skill content into context rather than just printing a hint:

```json
{
  "matcher": "Edit|Write",
  "hooks": [{
    "type": "command",
    "command": "FILE=\"$CLAUDE_FILE_PATH\"; PROJ_DIR=$(pwd); SKILL_DIR=\"$PROJ_DIR/.claude/skills\"; if echo \"$FILE\" | grep -qE '(auth|oauth|token|cors|rate.limit)'; then cat \"$SKILL_DIR/senior-security/SKILL.md\" 2>/dev/null; elif echo \"$FILE\" | grep -qE 'server/routers'; then cat \"$SKILL_DIR/trpc-patterns/SKILL.md\" 2>/dev/null; elif echo \"$FILE\" | grep -qE 'app/.*\\.(tsx?)$'; then cat \"$SKILL_DIR/expo-mobile-security/SKILL.md\" 2>/dev/null; fi"
  }]
}
```

This injects the skill body into the tool result context where Claude will actually read it before writing code.

---

## Issue 5 — `mcp-env-setup.sh` referenced but never created

**Severity:** 🟡 Medium  
**Files:** `/dee-doctor` command, `/dee-status` command, CLAUDE.md

### Problem

Multiple commands and documentation reference `.claude/mcp-env-setup.sh` as the location to configure MCP API keys. The install scripts never create this file. When users run `/dee-doctor`, it checks for this file and reports it missing — but provides no path to fix it.

### Fix

The `orchestrate.py` installer should create a template `mcp-env-setup.sh` based on which MCPs were installed:

```bash
#!/bin/bash
# MCP API Keys — fill in the values below
# Source this file: source .claude/mcp-env-setup.sh

# GitHub MCP
export GITHUB_TOKEN=""

# Stripe MCP (if installed)
export STRIPE_API_KEY=""

# Sentry MCP (if installed)
export SENTRY_AUTH_TOKEN=""

# Add to shell profile to auto-load:
# echo "source /path/to/.claude/mcp-env-setup.sh" >> ~/.bashrc
```

The `/dee-doctor` command should also output the exact command to open and edit this file, not just note its absence.

---

## Issue 6 — PROJECT_PROFILE.json maturity axes not updated after install

**Severity:** 🟢 Low  
**File:** `scripts/detect_project.py`, maturity assessment section

### Problem

The maturity axes (`ci_cd`, `containerized`, `security`, `monitoring`, etc.) are assessed at scan time but the profile is never updated as users add features. A project that starts without CI and later adds GitHub Actions workflows will still show `ci_cd: false` until manually re-scanned.

### Fix

Add a rescan command or a hook that detects when relevant files are added/modified and updates the profile:

```bash
# PostToolUse hook addition — trigger rescan if maturity-relevant files change
if echo "$FILE" | grep -qE '(\.github/workflows|Dockerfile|docker-compose)'; then
  echo "📊 DEE: Maturity-relevant file changed. Run /dee-status to update profile."
fi
```

Also provide a `/dee-rescan` command that re-runs `detect_project.py` in place and updates `.claude/PROJECT_PROFILE.json`.

---

## Issue 7 — Hooks use bash-only shell commands: broken on Windows without WSL

**Severity:** 🔴 Critical  
**Files:** `.claude/settings.json` (all hooks), `scripts/orchestrate.py` (hook generator)

### Problem

Every hook command in `settings.json` uses Unix-only shell utilities:

```bash
find "$PROJ_DIR/.claude/skills" -name 'SKILL.md' 2>/dev/null | wc -l | tr -d ' '
```

On **Windows without WSL**, this fails silently or errors completely because:

| Command | Windows equivalent | Status |
|---------|-------------------|--------|
| `find` | `dir /s /b` | Not compatible |
| `wc -l` | `Measure-Object` (PowerShell) | Not compatible |
| `tr -d ' '` | Does not exist | Not compatible |
| `$VAR` syntax | `%VAR%` (CMD) / `$env:VAR` (PS) | Not compatible |
| `/` path separator | `\` required in CMD | Breaks paths |

The engine was tested and designed for macOS/Linux. Windows users with Claude Code Desktop (a primary target) get a broken SessionStart hook — the banner never renders, skills never load, and no error is shown to the user.

**Evidence:** Observed directly on Windows 11 Pro. The SessionStart hook in `settings.json` ran but produced no output because `find` resolved to the Windows `find.exe` (string search tool, not file finder), causing the entire pipe to fail.

### Fix

Replace all hook shell scripts with a single Python script that runs identically on macOS, Linux, and Windows. Python is the only runtime guaranteed to be present across all three (required by `orchestrate.py` already).

**New approach — one Python hook for SessionStart:**

`scripts/session_start.py`:
```python
#!/usr/bin/env python3
"""DEE SessionStart hook — cross-platform (macOS, Linux, Windows)"""
import os
import sys
import json
from pathlib import Path

def main():
    proj_dir = Path(os.getcwd())
    claude_dir = proj_dir / ".claude"
    skills_dir = claude_dir / "skills"
    profile_path = claude_dir / "PROJECT_PROFILE.json"

    # Count components using pathlib (no shell needed)
    skills = list(skills_dir.glob("*/SKILL.md")) if skills_dir.exists() else []
    commands_dir = claude_dir / "commands"
    commands = list(commands_dir.glob("*.md")) if commands_dir.exists() else []
    agents_dir = claude_dir / "agents"
    agents = list(agents_dir.glob("*.md")) if agents_dir.exists() else []

    # Read profile
    domain = "unknown"
    if profile_path.exists():
        try:
            profile = json.loads(profile_path.read_text(encoding="utf-8"))
            domain = profile.get("fingerprint", {}).get("domain", "unknown")
        except Exception:
            pass

    # Domain → skill selection map (load only relevant skills)
    DOMAIN_SKILLS = {
        "expense_management": ["senior-backend", "senior-security", "trpc-patterns", "expense-workflow", "db-migration"],
        "fintech": ["senior-backend", "senior-security", "senior-architect", "performance-optimization"],
        "social": ["senior-backend", "senior-frontend", "real-time-testing", "websocket-validation"],
        "saas": ["senior-backend", "senior-frontend", "senior-architect", "code-reviewer"],
        "ecommerce": ["senior-backend", "senior-security", "performance-optimization"],
    }
    selected_skills = DOMAIN_SKILLS.get(domain, ["senior-backend", "senior-security", "code-reviewer"])

    # Print banner
    print()
    print("🧠 DEVLMER ECOSYSTEM ENGINE v3.1")
    print("━" * 43)
    print(f"📊 Project: {proj_dir.name} | Domain: {domain.replace('_', ' ').title()}")
    print(f"⚡ {len(skills)} skills | {len(commands)} commands | {len(agents)} agents")
    print()
    print("💡 Quick start: /dee-demo | /dee-status | /dee-doctor")
    print()
    print("📚 AUTO-LOADED SKILLS FOR THIS SESSION:")

    # Inject selected skill content
    for skill_name in selected_skills:
        skill_file = skills_dir / skill_name / "SKILL.md"
        if skill_file.exists():
            print(f"  ✅ /{skill_name}")
            print(skill_file.read_text(encoding="utf-8"))

    print("━" * 43)

if __name__ == "__main__":
    main()
```

**Updated hook in `settings.json`:**
```json
{
  "type": "command",
  "command": "python3 .claude/scripts/session_start.py 2>/dev/null || python .claude/scripts/session_start.py"
}
```

The `python3 || python` fallback handles Windows where the executable may be `python` instead of `python3`.

**Same pattern for PostToolUse hook** — replace bash conditionals with a Python script `scripts/post_tool_use.py` that reads `CLAUDE_FILE_PATH` env var (works on all platforms) and injects the right skill.

### Additional Windows fixes needed in `orchestrate.py`

The installer itself uses `subprocess` to run bash commands. Add OS detection:

```python
import platform
import subprocess

IS_WINDOWS = platform.system() == "Windows"

def run_command(cmd: str, shell_cmd: list = None):
    """Run a command cross-platform."""
    if IS_WINDOWS and shell_cmd:
        # Use PowerShell for Windows
        return subprocess.run(["powershell", "-Command"] + shell_cmd, capture_output=True)
    else:
        return subprocess.run(cmd, shell=True, capture_output=True, text=True)
```

---

## Summary Table

| # | Issue | Severity | File | Effort |
|---|-------|----------|------|--------|
| 1 | `fintech` domain pattern misses expense apps | 🔴 Critical | `scripts/detect_project.py` | Medium |
| 2 | Agents are hollow stubs, wrong domain | 🔴 Critical | `.claude/agents/*.md` | High |
| 7 | All hooks use bash-only commands — broken on Windows | 🔴 Critical | `.claude/settings.json`, `scripts/orchestrate.py` | Medium |
| 3 | SessionStart loads ~490KB of skills blindly | 🟠 High | `.claude/settings.json` hooks | Low |
| 4 | No PreToolUse hook for proactive skill injection | 🟡 Medium | `.claude/settings.json` hooks | Low |
| 5 | `mcp-env-setup.sh` never created by installer | 🟡 Medium | `scripts/orchestrate.py` | Low |
| 6 | PROJECT_PROFILE.json maturity never updates | 🟢 Low | `scripts/detect_project.py` | Medium |

---

## Recommended Priority Order

1. **Fix hooks for cross-platform** (Issue 7) — broken on Windows = broken for a large share of Claude Code Desktop users. The Python rewrite also solves Issue 3 (smart skill loading) in the same change.

2. **Fix domain detection** (Issue 1) — everything downstream depends on correct domain. Add `expense_management`, fix social false-positives.

3. **Write real agent instructions** (Issue 2) — 20 lines of domain workflow per agent transforms stubs into useful workers. Start with 3–4 per domain.

4. **Create mcp-env-setup.sh / mcp-env-setup.ps1 template** (Issue 5) — quick win, installer change. Need both `.sh` (Mac/Linux) and `.ps1` (Windows) variants.

5. **PreToolUse skill injection** (Issue 4) — improves auto-activation via Python hook.

6. **Profile rescan trigger** (Issue 6) — nice-to-have, can wait.

---

## What Works Well

- **TECH_SIGNATURES** detection is comprehensive (157 entries) and accurate for framework/library detection
- **Skill content quality** for core skills (senior-backend, senior-security, code-reviewer) is genuinely useful — good depth, practical patterns
- **Hook architecture** (PostToolUse on Edit|Write) is the right design pattern, just needs cross-platform implementation
- **Blueprint matching system** concept is sound — domain → skills → agents pipeline just needs correct domain input
- **`detect_project.py`** already uses pure Python + pathlib — it works on all platforms. The same approach should be applied to all hooks.

---

*Field report from active deployment. All issues are reproducible on `Soyelijah/expense-approval-app1` (branch: main, Windows 11 Pro).*
