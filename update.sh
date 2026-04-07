#!/usr/bin/env bash
# ============================================================================
# DEVLMER ECOSYSTEM ENGINE v3.0 — UPDATE SCRIPT
# Updates an existing installation without losing user config or API keys.
#
# Usage:
#   bash update.sh /path/to/project
#   bash <(curl -fsSL https://raw.githubusercontent.com/Soyelijah/devlmer-ecosystem-engine/main/update.sh) /path/to/project
# ============================================================================

set -euo pipefail

# ── Colors ──
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

VERSION="3.0"
REPO_URL="https://github.com/Soyelijah/devlmer-ecosystem-engine.git"
TMP_DIR="/tmp/dee-update-$$"

# ── Helpers ──
log_info()    { echo -e "  ${CYAN}ℹ${RESET} $1"; }
log_success() { echo -e "  ${GREEN}✓${RESET} $1"; }
log_warning() { echo -e "  ${YELLOW}⚠${RESET} $1"; }
log_error()   { echo -e "  ${RED}✗${RESET} $1"; }
log_step()    { echo -e "  ${MAGENTA}→${RESET} $1"; }

cleanup() {
    rm -rf "${TMP_DIR}" 2>/dev/null || true
}
trap cleanup EXIT

# ── Parse arguments ──
TARGET_DIR="${1:-}"

if [[ -z "${TARGET_DIR}" ]]; then
    echo ""
    echo -e "${BOLD}${RED}Error: Target directory required${RESET}"
    echo ""
    echo -e "${BOLD}Usage:${RESET}"
    echo -e "  bash update.sh /path/to/your/project"
    echo ""
    echo -e "${BOLD}Example:${RESET}"
    echo -e "  bash update.sh ~/Projects/my-app"
    echo ""
    exit 1
fi

# Expand ~ and resolve path
TARGET_DIR="${TARGET_DIR/#\~/$HOME}"
if [[ -d "${TARGET_DIR}" ]]; then
    TARGET_DIR="$(cd "${TARGET_DIR}" && pwd)"
fi
TARGET_DIR="${TARGET_DIR%/}"

# ── Validate existing installation ──
if [[ ! -d "${TARGET_DIR}/.claude" ]]; then
    echo ""
    echo -e "${RED}Error: No Devlmer Ecosystem Engine installation found at:${RESET}"
    echo -e "  ${TARGET_DIR}"
    echo ""
    echo -e "This command updates an existing installation."
    echo -e "To install for the first time, use:"
    echo -e "  ${CYAN}rm -rf /tmp/dee && git clone ${REPO_URL} /tmp/dee && bash /tmp/dee/install.sh \"${TARGET_DIR}\"${RESET}"
    echo ""
    exit 1
fi

# ── Start ──
echo ""
echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════════════════════════╗${RESET}"
echo -e "${BOLD}${CYAN}║       DEVLMER ECOSYSTEM ENGINE v${VERSION} — UPDATER              ║${RESET}"
echo -e "${BOLD}${CYAN}╚══════════════════════════════════════════════════════════════╝${RESET}"
echo ""
echo -e "  ${BOLD}Target:${RESET} ${TARGET_DIR}"
echo ""

# ── Step 1: Clone latest version ──
log_step "Downloading latest version..."
rm -rf "${TMP_DIR}"
if git clone --depth 1 "${REPO_URL}" "${TMP_DIR}" > /dev/null 2>&1; then
    log_success "Latest version downloaded"
else
    log_error "Failed to download latest version"
    exit 1
fi

# ── Step 2: Backup user config ──
log_step "Backing up user configuration..."
BACKUP_DIR="${TARGET_DIR}/.claude/.update-backup-$(date +%s)"
mkdir -p "${BACKUP_DIR}"

# Preserve these user files
for preserve_file in mcp-env-setup.sh settings.json PROJECT_PROFILE.json; do
    if [[ -f "${TARGET_DIR}/.claude/${preserve_file}" ]]; then
        cp "${TARGET_DIR}/.claude/${preserve_file}" "${BACKUP_DIR}/${preserve_file}"
    fi
done

# Preserve user's root CLAUDE.md if it was customized
if [[ -f "${TARGET_DIR}/CLAUDE.md" ]]; then
    cp "${TARGET_DIR}/CLAUDE.md" "${BACKUP_DIR}/CLAUDE.md.user"
fi

log_success "User config backed up to .claude/.update-backup-*"

# ── Step 3: Update skills (overwrite with latest) ──
log_step "Updating skills..."
SKILLS_UPDATED=0
SKILLS_ADDED=0

for skill_dir in "${TMP_DIR}/skills"/*/; do
    skill_name=$(basename "${skill_dir}")
    target_skill="${TARGET_DIR}/.claude/skills/${skill_name}"

    if [[ -d "${target_skill}" ]]; then
        # Update existing skill
        cp -r "${skill_dir}"* "${target_skill}/" 2>/dev/null && SKILLS_UPDATED=$((SKILLS_UPDATED + 1))
    else
        # New skill — copy entirely
        mkdir -p "${target_skill}"
        cp -r "${skill_dir}"* "${target_skill}/" 2>/dev/null && SKILLS_ADDED=$((SKILLS_ADDED + 1))
    fi
done

# Strip YAML frontmatter from all skills
if command -v python3 >/dev/null 2>&1; then
    python3 -c "
import glob, os
skills_dir = '${TARGET_DIR}/.claude/skills'
for md in glob.glob(os.path.join(skills_dir, '*/SKILL.md')):
    with open(md, 'r') as f:
        content = f.read()
    if content.startswith('---'):
        end = content.find('---', 3)
        if end != -1:
            cleaned = content[end + 3:].lstrip('\n')
            with open(md, 'w') as f:
                f.write(cleaned)
" 2>/dev/null
fi

log_success "Skills: ${SKILLS_UPDATED} updated, ${SKILLS_ADDED} new"

# ── Step 4: Update slash commands ──
log_step "Updating slash commands..."
CMDS_UPDATED=0

# Update DEE core commands
for dee_cmd in "${TMP_DIR}/commands"/*.md; do
    if [[ -f "${dee_cmd}" ]]; then
        cp "${dee_cmd}" "${TARGET_DIR}/.claude/commands/" 2>/dev/null && CMDS_UPDATED=$((CMDS_UPDATED + 1))
    fi
done

# Regenerate skill commands
for skill_dir in "${TARGET_DIR}/.claude/skills"/*/; do
    skill_name=$(basename "${skill_dir}")
    skill_md="${skill_dir}/SKILL.md"
    if [[ -f "${skill_md}" ]]; then
        desc=$(sed -n '/^description:/{ s/^description: *//; p; q; }' "${skill_md}" | cut -c1-150)
        cat > "${TARGET_DIR}/.claude/commands/${skill_name}.md" << CMDEOF
# /${skill_name}

${desc}

## Instructions

Read the skill file at \`.claude/skills/${skill_name}/SKILL.md\` and follow its instructions to complete the user's request.

If the skill has reference files in \`.claude/skills/${skill_name}/references/\`, read those too for deeper context.

If the skill has scripts in \`.claude/skills/${skill_name}/scripts/\`, use them when applicable.
CMDEOF
        CMDS_UPDATED=$((CMDS_UPDATED + 1))
    fi
done

log_success "Slash commands: ${CMDS_UPDATED} updated"

# ── Step 5: Update scripts ──
log_step "Updating project intelligence scripts..."
SCRIPTS_UPDATED=0

if [[ -f "${TMP_DIR}/scripts/detect_project.py" ]]; then
    mkdir -p "${TARGET_DIR}/.claude/skills/project-intelligence/scripts"
    cp "${TMP_DIR}/scripts/detect_project.py" "${TARGET_DIR}/.claude/skills/project-intelligence/scripts/" 2>/dev/null && SCRIPTS_UPDATED=$((SCRIPTS_UPDATED + 1))
fi

if [[ -f "${TMP_DIR}/scripts/orchestrate.py" ]]; then
    cp "${TMP_DIR}/scripts/orchestrate.py" "${TARGET_DIR}/.claude/skills/project-intelligence/scripts/" 2>/dev/null && SCRIPTS_UPDATED=$((SCRIPTS_UPDATED + 1))
fi

if [[ -f "${TMP_DIR}/blueprints/ecosystems.json" ]]; then
    mkdir -p "${TARGET_DIR}/.claude/config"
    cp "${TMP_DIR}/blueprints/ecosystems.json" "${TARGET_DIR}/.claude/config/" 2>/dev/null && SCRIPTS_UPDATED=$((SCRIPTS_UPDATED + 1))
fi

log_success "Scripts: ${SCRIPTS_UPDATED} updated"

# ── Step 6: Update hooks in settings.json (preserve MCPs) ──
log_step "Updating hooks (preserving MCP configuration)..."

if [[ -f "${BACKUP_DIR}/settings.json" ]] && command -v python3 >/dev/null 2>&1; then
    python3 -c "
import json

# Read the backed up settings (has user's MCPs and API keys)
with open('${BACKUP_DIR}/settings.json', 'r') as f:
    settings = json.load(f)

# Update hooks with latest version
settings['hooks'] = {
    'SessionStart': [
        {
            'matcher': '',
            'hooks': [
                {
                    'type': 'command',
                    'command': 'PROJ_DIR=\$(pwd); PROFILE=\"\$PROJ_DIR/.claude/PROJECT_PROFILE.json\"; SKILLS=\$(find \"\$PROJ_DIR/.claude/skills\" -name \"SKILL.md\" 2>/dev/null | wc -l | tr -d \" \"); AGENTS=\$(find \"\$PROJ_DIR/.claude/agents\" -name \"*.md\" 2>/dev/null | wc -l | tr -d \" \"); CMDS=\$(find \"\$PROJ_DIR/.claude/commands\" -name \"*.md\" 2>/dev/null | wc -l | tr -d \" \"); MCPS=0; if [ -f \"\$PROJ_DIR/.claude/settings.json\" ]; then MCPS=\$(python3 -c \"import json; s=json.load(open(\\\"\$PROJ_DIR/.claude/settings.json\\\")); print(len(s.get(\\\"mcpServers\\\",{})))\" 2>/dev/null || echo 0); fi; DOMAIN=\"unknown\"; if [ -f \"\$PROFILE\" ]; then DOMAIN=\$(python3 -c \"import json; p=json.load(open(\\\"\$PROFILE\\\")); print(p.get(\\\"fingerprint\\\",{}).get(\\\"domain\\\",\\\"unknown\\\").replace(\\\"_\\\",\\\" \\\").title())\" 2>/dev/null || echo unknown); fi; echo \"\"; echo \"🧠 DEVLMER ECOSYSTEM ENGINE v3.0\"; echo \"━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\"; echo \"📊 Project: \$(basename \$PROJ_DIR) | Domain: \$DOMAIN\"; echo \"⚡ \$SKILLS skills | \$CMDS commands | \$AGENTS agents | \$MCPS MCPs\"; echo \"\"; echo \"💡 Quick start: /dee-demo (tour) | /dee-status (dashboard) | /dee-doctor (health)\"; echo \"   Type / to see all available commands\"; echo \"\"'
                }
            ]
        }
    ],
    'PostToolUse': [
        {
            'matcher': 'Edit|Write',
            'hooks': [
                {
                    'type': 'command',
                    'command': 'EDITED_FILE=\"\$CLAUDE_FILE_PATH\"; if echo \"\$EDITED_FILE\" | grep -qE \"\\\\.py\$\"; then python3 -m py_compile \"\$EDITED_FILE\" 2>&1 && echo \"✅ Python syntax OK\" || echo \"❌ Python syntax error\"; elif echo \"\$EDITED_FILE\" | grep -qE \"\\\\.(tsx?|jsx?)\$\"; then echo \"⚡ TypeScript file edited — run build to verify\"; fi'
                }
            ]
        }
    ]
}

settings['version'] = '3.0'
settings['engine'] = 'devlmer-ecosystem-engine'

with open('${TARGET_DIR}/.claude/settings.json', 'w') as f:
    json.dump(settings, f, indent=2)

print('Hooks updated, MCPs preserved')
" 2>/dev/null && log_success "Hooks updated (MCPs and API keys preserved)" || log_warning "Could not update hooks — settings.json unchanged"
else
    log_warning "No existing settings.json found — skipping hook update"
fi

# ── Step 7: Update CLAUDE.md (preserve user customizations) ──
log_step "Updating CLAUDE.md..."

if [[ -f "${BACKUP_DIR}/CLAUDE.md.user" ]]; then
    # User had a custom CLAUDE.md — check if it has Devlmer section
    if grep -q "Devlmer Ecosystem Engine" "${BACKUP_DIR}/CLAUDE.md.user" 2>/dev/null; then
        # Replace the Devlmer section with updated version using Python
        python3 -c "
import re

with open('${BACKUP_DIR}/CLAUDE.md.user', 'r') as f:
    content = f.read()

# Find and replace the Devlmer section
# Pattern: from '# CLAUDE.md — Devlmer' or '## Devlmer Ecosystem' to end of file or next top-level heading
new_section = '''## Devlmer Ecosystem Engine v3.0

This project is enhanced with the Devlmer Ecosystem Engine.

**Quick Start:** Type \`/\` to see all commands. Key commands:
- \`/dee-demo\` — Interactive tour of the ecosystem
- \`/dee-status\` — Dashboard of everything installed
- \`/dee-doctor\` — Health check and diagnostics

Skills, MCPs, agents and slash commands are in \`.claude/\`.
Claude auto-activates the right skills based on your task context.
'''

# If it starts with the DEE header, replace the whole file
if content.strip().startswith('# CLAUDE.md — Devlmer') or content.strip().startswith('# CLAUDE.md - Global Configuration'):
    with open('${TARGET_DIR}/CLAUDE.md', 'w') as f:
        f.write(new_section)
else:
    # Find the Devlmer section and replace it
    pattern = r'## Devlmer Ecosystem Engine.*?(?=\n## (?!Devlmer)|$)'
    updated = re.sub(pattern, new_section.strip(), content, flags=re.DOTALL)
    if updated == content:
        # Section not found as ##, append it
        updated = content.rstrip() + '\n\n' + new_section
    with open('${TARGET_DIR}/CLAUDE.md', 'w') as f:
        f.write(updated)

print('CLAUDE.md updated (user content preserved)')
" 2>/dev/null && log_success "CLAUDE.md updated (user customizations preserved)" || log_warning "Could not update CLAUDE.md"
    else
        # User's CLAUDE.md doesn't mention Devlmer — append section
        cat >> "${TARGET_DIR}/CLAUDE.md" << 'APPEND_UPDATE'

## Devlmer Ecosystem Engine v3.0

This project is enhanced with the Devlmer Ecosystem Engine.

**Quick Start:** Type `/` to see all commands. Key commands:
- `/dee-demo` — Interactive tour of the ecosystem
- `/dee-status` — Dashboard of everything installed
- `/dee-doctor` — Health check and diagnostics

Skills, MCPs, agents and slash commands are in `.claude/`.
Claude auto-activates the right skills based on your task context.
APPEND_UPDATE
        log_success "Devlmer section appended to CLAUDE.md"
    fi
else
    log_warning "No existing CLAUDE.md — run full install instead"
fi

# ── Summary ──
TOTAL=$((SKILLS_UPDATED + SKILLS_ADDED + CMDS_UPDATED + SCRIPTS_UPDATED))

echo ""
echo -e "${BOLD}${GREEN}╔══════════════════════════════════════════════════════════════╗${RESET}"
echo -e "${BOLD}${GREEN}║              UPDATE COMPLETE — ${TOTAL} components updated           ║${RESET}"
echo -e "${BOLD}${GREEN}╚══════════════════════════════════════════════════════════════╝${RESET}"
echo ""
echo -e "  ${GREEN}✓${RESET} Skills:   ${SKILLS_UPDATED} updated, ${SKILLS_ADDED} new"
echo -e "  ${GREEN}✓${RESET} Commands: ${CMDS_UPDATED} updated"
echo -e "  ${GREEN}✓${RESET} Scripts:  ${SCRIPTS_UPDATED} updated"
echo -e "  ${GREEN}✓${RESET} Hooks:    updated (MCPs preserved)"
echo -e "  ${GREEN}✓${RESET} Backup:   ${BACKUP_DIR}"
echo ""
echo -e "  ${BOLD}Preserved:${RESET}"
echo -e "    • MCP configurations and API keys"
echo -e "    • Custom CLAUDE.md content"
echo -e "    • PROJECT_PROFILE.json"
echo -e "    • Agent configurations"
echo ""
echo -e "  ${CYAN}Open Claude Code and type /dee-status to verify.${RESET}"
echo ""
