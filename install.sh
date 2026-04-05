#!/usr/bin/env bash

################################################################################
#
# DEVLMER ECOSYSTEM ENGINE v3.0 - Master Installer Script
#
# A comprehensive, enterprise-grade installer for the Devlmer Ecosystem Engine.
# Handles GitHub authentication, Nano-Banana-MCP setup, skill installation,
# project intelligence setup, MCP integration, and global configuration initialization.
#
# Product: Devlmer Ecosystem Engine v3.0 (DEE by Devlmer)
# Author: Pierre Solier (Devlmer)
# Website: devlmer.com
#
# Usage:
#   ./install.sh [target-directory] [options]
#   ./install.sh --help
#   ./install.sh --skills-only
#   ./install.sh --scan-only
#   ./install.sh --github-token <token>
#   ./install.sh --gemini-key <key>
#
# Version: 3.0
# Last Updated: 2026-04-04
#
################################################################################

set -euo pipefail

# ============================================================================
# COLOR DEFINITIONS
# ============================================================================

readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly MAGENTA='\033[0;35m'
readonly WHITE='\033[1;37m'
readonly RESET='\033[0m'
readonly BOLD='\033[1m'
readonly DIM='\033[2m'

# Progress indicators
readonly CHECK="${GREEN}✓${RESET}"
readonly CROSS="${RED}✗${RESET}"
readonly WARN="${YELLOW}⚠${RESET}"
readonly INFO="${BLUE}ℹ${RESET}"
readonly ARROW="${CYAN}→${RESET}"

# ============================================================================
# GLOBAL VARIABLES
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR=""
MODE="full"  # full, skills-only, scan-only
VERBOSE=0

# GitHub authentication
GITHUB_TOKEN=""
GITHUB_PAT=""
GITHUB_AUTHENTICATED=0
NO_GITHUB=0

# Nano-Banana MCP
GEMINI_KEY=""
NANO_BANANA_INSTALLED=0

# Statistics
SKILLS_INSTALLED=0
SKILLS_FAILED=0
EXTERNAL_SKILLS_INSTALLED=0
MCPS_INSTALLED=0
MCPS_FAILED=0
AGENTS_CONFIGURED=0
AGENTS_FAILED=0
CONFIG_FILES_CREATED=0
SCRIPTS_COPIED=0

# Track timing
INSTALL_START_TIME=$(date +%s)

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

log_header() {
    echo -e "${BOLD}${CYAN}>>> ${1}${RESET}"
}

log_success() {
    echo -e "${CHECK} ${GREEN}${1}${RESET}"
}

log_error() {
    echo -e "${CROSS} ${RED}${1}${RESET}"
}

log_warning() {
    echo -e "${WARN} ${YELLOW}${1}${RESET}"
}

log_info() {
    echo -e "${INFO} ${BLUE}${1}${RESET}"
}

log_step() {
    echo -e "${ARROW} ${CYAN}${1}${RESET}"
}

log_verbose() {
    if [[ ${VERBOSE} -eq 1 ]]; then
        echo -e "    ${WHITE}${1}${RESET}"
    fi
}

log_section() {
    echo ""
    echo -e "${BOLD}${MAGENTA}╔════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${BOLD}${MAGENTA}║  ${1}${RESET}"
    echo -e "${BOLD}${MAGENTA}╚════════════════════════════════════════════════════════════╝${RESET}"
}

log_subsection() {
    echo ""
    echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════════${RESET}"
    echo -e "${BOLD}${BLUE}  ${1}${RESET}"
    echo -e "${BOLD}${BLUE}═══════════════════════════════════════════════════════════${RESET}"
}

# ============================================================================
# BANNER AND HELP
# ============================================================================

show_banner() {
    echo -e "${BOLD}${MAGENTA}"
    cat << 'EOF'
╔════════════════════════════════════════════════════════════════════════════╗
║                                                                            ║
║               ██████╗ ███████╗██╗   ██╗███╗   ███╗██╗     ███████╗██████╗ ║
║               ██╔══██╗██╔════╝██║   ██║████╗ ████║██║     ██╔════╝██╔══██╗║
║               ██║  ██║█████╗  ██║   ██║██╔████╔██║██║     █████╗  ██████╔╝║
║               ██║  ██║██╔══╝  ╚██╗ ██╔╝██║╚██╔╝██║██║     ██╔══╝  ██╔══██╗║
║               ██████╔╝███████╗ ╚████╔╝ ██║ ╚═╝ ██║███████╗███████╗██║  ██║║
║               ╚═════╝ ╚══════╝  ╚═══╝  ╚═╝     ╚═╝╚══════╝╚══════╝╚═╝  ╚═╝║
║                                                                            ║
║                    DEVLMER ECOSYSTEM ENGINE v3.0                          ║
║                     Master Installer & Configuration Suite                ║
║                                                                            ║
║             Production-Grade Installation for Enterprise Environments      ║
║                                                                            ║
║                         by Pierre Solier (Devlmer)                        ║
║                              devlmer.com                                  ║
║                                                                            ║
╚════════════════════════════════════════════════════════════════════════════╝
EOF
    echo -e "${RESET}"
}

show_help() {
    cat << EOF

${BOLD}DEVLMER ECOSYSTEM ENGINE v3.0 - Master Installer${RESET}

${BOLD}USAGE:${RESET}
    ./install.sh [target-directory] [options]

${BOLD}ARGUMENTS:${RESET}
    target-directory    Install location (default: current directory)

${BOLD}OPTIONS:${RESET}
    --help              Show this help message and exit
    --skills-only       Install skills only, skip project scanning
    --scan-only         Run project fingerprinting only, skip skill install
    --verbose           Enable verbose output
    --no-external       Skip external skill installations (from npm)
    --no-mcp            Skip MCP (Model Context Protocol) installations
    --no-github         Skip GitHub authentication (do not offer repo sync/backup)
    --github-token      Provide GitHub Personal Access Token (non-interactive)
    --gemini-key        Provide Gemini API key for Nano-Banana MCP (non-interactive)

${BOLD}EXAMPLES:${RESET}
    ./install.sh /path/to/project
    ./install.sh . --skills-only
    ./install.sh ~ --scan-only --verbose
    ./install.sh . --github-token ghp_xxxxxxxxxxxx
    ./install.sh . --gemini-key AIzaSy...

${BOLD}ENVIRONMENT:${RESET}
    Works on macOS 11+ and Linux (Ubuntu 18+, CentOS 7+)
    Requires: bash 4.0+, node 16+, python 3.8+
    Optional: GitHub CLI (gh) for GitHub authentication

EOF
}

# ============================================================================
# PLATFORM DETECTION
# ============================================================================

detect_platform() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        echo "linux"
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        echo "macos"
    else
        echo "unknown"
    fi
}

check_dependencies() {
    log_step "Verifying dependencies..."

    local missing=0

    # Check bash version
    if [[ ${BASH_VERSINFO[0]} -lt 4 ]]; then
        log_error "Bash 4.0+ required (found ${BASH_VERSION})"
        missing=1
    fi

    # Check node/npm
    if ! command -v node &> /dev/null; then
        log_warning "Node.js not found (required for skill installations)"
        missing=1
    else
        log_verbose "Node.js: $(node --version)"
    fi

    # Check python
    if ! command -v python3 &> /dev/null; then
        log_warning "Python 3 not found (required for project scanning)"
        missing=1
    else
        log_verbose "Python 3: $(python3 --version)"
    fi

    if [[ ${missing} -eq 1 ]]; then
        log_warning "Some optional dependencies are missing. Install may be incomplete."
    else
        log_success "All dependencies verified"
    fi
}

# ============================================================================
# DIRECTORY SETUP
# ============================================================================

setup_directories() {
    log_step "Setting up directory structure..."

    if [[ ! -d "${TARGET_DIR}" ]]; then
        log_error "Target directory does not exist: ${TARGET_DIR}"
        return 1
    fi

    # Create .claude directory structure
    mkdir -p "${TARGET_DIR}/.claude/skills"
    mkdir -p "${TARGET_DIR}/.claude/hooks"
    mkdir -p "${TARGET_DIR}/.claude/config"
    mkdir -p "${TARGET_DIR}/.claude/logs"

    # Create global Devlmer directory
    mkdir -p "${HOME}/.devlmer"

    log_success "Directory structure created"
    log_verbose "${TARGET_DIR}/.claude/"
    log_verbose "${TARGET_DIR}/.claude/skills/"
    log_verbose "${TARGET_DIR}/.claude/hooks/"
    log_verbose "${TARGET_DIR}/.claude/config/"
    log_verbose "${TARGET_DIR}/.claude/logs/"
    log_verbose "${HOME}/.devlmer/"
}

# ============================================================================
# GITHUB AUTHENTICATION
# ============================================================================

check_github_cli() {
    if command -v gh &> /dev/null; then
        return 0
    else
        return 1
    fi
}

github_status() {
    if check_github_cli; then
        if gh auth status &> /dev/null; then
            return 0
        else
            return 1
        fi
    else
        return 1
    fi
}

get_github_auth_interactive() {
    log_step "Checking GitHub authentication..."

    if github_status; then
        log_success "GitHub CLI is already authenticated"
        GITHUB_AUTHENTICATED=1
        return 0
    fi

    if check_github_cli; then
        log_info "GitHub CLI found but not authenticated"
        log_step "Would you like to authenticate with GitHub? (recommended for repo sync)"
        read -p "Authenticate with GitHub? [y/N] " -r

        if [[ $REPLY =~ ^[Yy]$ ]]; then
            if gh auth login --web &> /dev/null; then
                log_success "GitHub authentication successful"
                GITHUB_AUTHENTICATED=1
                return 0
            else
                log_warning "GitHub authentication failed"
                return 1
            fi
        else
            log_info "GitHub authentication skipped"
            return 0
        fi
    else
        log_info "GitHub CLI not found, attempting Personal Access Token setup..."
        log_step "Do you have a GitHub Personal Access Token? [y/N]"
        read -p "Enter PAT? [y/N] " -r

        if [[ $REPLY =~ ^[Yy]$ ]]; then
            read -sp "Enter your GitHub Personal Access Token: " GITHUB_PAT
            echo ""
            if [[ -n "${GITHUB_PAT}" ]]; then
                GITHUB_AUTHENTICATED=1
                log_success "GitHub PAT configured"
                return 0
            fi
        fi

        log_info "Proceeding without GitHub authentication"
        return 0
    fi
}

save_github_auth() {
    local auth_file="${HOME}/.devlmer/github-auth.json"

    if [[ -n "${GITHUB_PAT}" ]]; then
        cat > "${auth_file}" << EOF
{
  "authenticated": true,
  "method": "pat",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
  "token": "${GITHUB_PAT}"
}
EOF
        chmod 600 "${auth_file}"
        log_verbose "GitHub auth stored securely in ${auth_file}"
    elif [[ ${GITHUB_AUTHENTICATED} -eq 1 ]]; then
        cat > "${auth_file}" << EOF
{
  "authenticated": true,
  "method": "cli",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF
        log_verbose "GitHub CLI auth status stored"
    fi
}

offer_github_features() {
    if [[ ${GITHUB_AUTHENTICATED} -eq 0 ]]; then
        return 0
    fi

    log_info "GitHub authentication successful. Additional features available:"
    log_step "Repository synchronization"
    log_step "Configuration backup to GitHub"
    log_step "Automated updates from upstream"
    echo ""

    log_step "Initializing git repository and backing up ecosystem config..."

    # Initialize git if needed
    if [[ ! -d "${TARGET_DIR}/.git" ]]; then
        if git -C "${TARGET_DIR}" init &> /dev/null; then
            log_verbose "Git repository initialized in ${TARGET_DIR}"
        else
            log_warning "Failed to initialize git repository"
            return 1
        fi
    else
        log_verbose "Git repository already initialized"
    fi

    # Configure git user if not already set (for commits)
    if ! git -C "${TARGET_DIR}" config user.email &> /dev/null; then
        git -C "${TARGET_DIR}" config user.email "devlmer-ecosystem@local" &> /dev/null || true
    fi
    if ! git -C "${TARGET_DIR}" config user.name &> /dev/null; then
        git -C "${TARGET_DIR}" config user.name "Devlmer Ecosystem" &> /dev/null || true
    fi

    # Add and commit .claude directory if it exists
    if [[ -d "${TARGET_DIR}/.claude" ]]; then
        if git -C "${TARGET_DIR}" add .claude/ 2>/dev/null; then
            if git -C "${TARGET_DIR}" commit -m "Devlmer: ecosystem configured" &> /dev/null; then
                log_success "Ecosystem config committed to git"
            else
                log_verbose "No changes to commit (or commit failed)"
            fi
        else
            log_verbose "Failed to add .claude/ to git"
        fi
    fi

    # Check for remote and offer to push
    if git -C "${TARGET_DIR}" remote get-url origin &> /dev/null; then
        log_step "A git remote 'origin' is configured."
        read -p "Would you like to push ecosystem backup to origin? [y/N] " -r

        if [[ $REPLY =~ ^[Yy]$ ]]; then
            # Create branch if needed, but don't force
            local branch_name=".devlmer-backup-$(date +%s)"
            log_step "Creating backup branch: ${branch_name}"

            if git -C "${TARGET_DIR}" checkout -b "${branch_name}" 2>/dev/null; then
                if git -C "${TARGET_DIR}" push -u origin "${branch_name}" 2>/dev/null; then
                    log_success "Configuration backed up to branch: ${branch_name}"
                else
                    log_warning "Failed to push to origin (check permissions and credentials)"
                    return 1
                fi
            else
                log_warning "Failed to create backup branch"
                return 1
            fi
        else
            log_info "Skipped remote push (use 'git push' manually when ready)"
        fi
    else
        log_info "No git remote configured (add one with 'git remote add origin <url>')"
    fi
}

# ============================================================================
# NANO-BANANA-MCP SETUP
# ============================================================================

setup_nano_banana_mcp() {
    log_subsection "NANO-BANANA-MCP SETUP"

    local mcp_dir="${SCRIPT_DIR}/nano-banana-mcp"

    if [[ ! -d "${mcp_dir}" ]]; then
        log_warning "Nano-Banana-MCP not found in bundle (optional)"
        return 0
    fi

    log_step "Found bundled Nano-Banana-MCP"

    # Check for package.json
    if [[ ! -f "${mcp_dir}/package.json" ]]; then
        log_warning "Nano-Banana-MCP package.json not found"
        return 1
    fi

    # Install dependencies
    log_step "Installing Nano-Banana-MCP dependencies..."
    if cd "${mcp_dir}" && npm install 2>/dev/null; then
        log_success "Nano-Banana-MCP dependencies installed"
    else
        log_warning "Failed to install Nano-Banana-MCP dependencies"
        return 1
    fi

    # Get or prompt for Gemini API key
    if [[ -z "${GEMINI_KEY}" ]]; then
        log_step "Nano-Banana-MCP requires a Gemini API key"
        read -sp "Enter your Gemini API key (or press Enter to skip): " GEMINI_KEY
        echo ""
    fi

    if [[ -n "${GEMINI_KEY}" ]]; then
        save_nano_banana_config
        add_nano_banana_to_settings
        NANO_BANANA_INSTALLED=1
        log_success "Nano-Banana-MCP configured"
    else
        log_info "Skipping Nano-Banana-MCP configuration"
    fi

    cd - > /dev/null
}

save_nano_banana_config() {
    local config_file="${HOME}/.devlmer/nano-banana-config.json"

    cat > "${config_file}" << EOF
{
  "enabled": true,
  "gemini_api_key": "${GEMINI_KEY}",
  "version": "3.0",
  "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF
    chmod 600 "${config_file}"
    log_verbose "Nano-Banana config saved to ${config_file}"
}

add_nano_banana_to_settings() {
    local settings_file="${TARGET_DIR}/.claude/config/settings.json"

    if [[ ! -f "${settings_file}" ]]; then
        log_verbose "Settings file not yet created, creating default with nano-banana config"

        # Create directory if it doesn't exist
        mkdir -p "${TARGET_DIR}/.claude/config" || {
            log_warning "Failed to create .claude/config directory"
            return 1
        }

        # Create settings file with nano-banana config
        cat > "${settings_file}" << EOF
{
  "mcpServers": {
    "nano-banana": {
      "command": "node",
      "args": ["${SCRIPT_DIR}/nano-banana-mcp/index.js"],
      "env": {
        "GEMINI_API_KEY": "${GEMINI_KEY}"
      }
    }
  }
}
EOF
        chmod 600 "${settings_file}"
        log_success "Created settings.json with nano-banana-mcp configuration"
        return 0
    fi

    # Add nano-banana-mcp to existing mcpServers section (if python is available)
    if command -v python3 &> /dev/null; then
        python3 << PYTHON_SCRIPT
import json
import sys
import os

try:
    settings_file = '${settings_file}'

    with open(settings_file, 'r') as f:
        settings = json.load(f)

    if 'mcpServers' not in settings:
        settings['mcpServers'] = {}

    settings['mcpServers']['nano-banana'] = {
        'command': 'node',
        'args': ['${SCRIPT_DIR}/nano-banana-mcp/index.js'],
        'env': {
            'GEMINI_API_KEY': '${GEMINI_KEY}'
        }
    }

    with open(settings_file, 'w') as f:
        json.dump(settings, f, indent=2)

    # Ensure proper permissions
    os.chmod(settings_file, 0o600)

except Exception as e:
    sys.stderr.write(f"Error updating settings.json: {e}\n")
    sys.exit(1)
PYTHON_SCRIPT
        if [[ $? -eq 0 ]]; then
            log_success "Updated settings.json with nano-banana-mcp configuration"
        else
            log_warning "Failed to update settings.json with python script"
            return 1
        fi
    else
        log_warning "python3 not available, settings.json update skipped"
        return 1
    fi
}

# ============================================================================
# SKILL INSTALLATION
# ============================================================================

copy_bundled_skills() {
    log_step "Copying bundled skills..."

    local skills_dir="${SCRIPT_DIR}/skills"

    if [[ ! -d "${skills_dir}" ]] || [[ -z "$(ls -A "${skills_dir}" 2>/dev/null)" ]]; then
        log_warning "No bundled skills found in ${skills_dir}"
        return 0
    fi

    local skill_count=0
    for skill in "${skills_dir}"/*; do
        if [[ -d "${skill}" ]]; then
            local skill_name=$(basename "${skill}")
            cp -r "${skill}" "${TARGET_DIR}/.claude/skills/"
            skill_count=$((skill_count + 1))
            log_verbose "Copied skill: ${skill_name}"
        fi
    done

    if [[ ${skill_count} -gt 0 ]]; then
        SKILLS_INSTALLED=${skill_count}
        log_success "Copied ${skill_count} bundled skill(s)"
    else
        log_info "No bundled skills to copy"
    fi
}

install_external_skill() {
    local skill_url="$1"
    local skill_name="$2"

    log_step "Installing external skill: ${skill_name}"

    if command -v npx &> /dev/null; then
        if npx -y skills add "${skill_url}" --skill "${skill_name}" --yes 2>/dev/null; then
            EXTERNAL_SKILLS_INSTALLED=$((EXTERNAL_SKILLS_INSTALLED + 1))
            log_success "Installed: ${skill_name}"
            return 0
        else
            log_warning "Failed to install: ${skill_name}"
            SKILLS_FAILED=$((SKILLS_FAILED + 1))
            return 1
        fi
    else
        log_warning "npm/npx not available, skipping: ${skill_name}"
        return 1
    fi
}

install_copywriting_skill() {
    log_step "Installing copywriting skill..."

    if command -v npx &> /dev/null; then
        if npx -y skills add https://github.com/coreyhaines31/marketingskills --skill copywriting --yes 2>/dev/null; then
            EXTERNAL_SKILLS_INSTALLED=$((EXTERNAL_SKILLS_INSTALLED + 1))
            log_success "Installed: copywriting skill"
            return 0
        else
            log_warning "Failed to install copywriting skill"
            SKILLS_FAILED=$((SKILLS_FAILED + 1))
            return 1
        fi
    else
        log_warning "npm/npx not available, skipping copywriting skill"
        return 1
    fi
}

install_external_skills() {
    log_section "INSTALLING EXTERNAL SKILLS"

    local skills=(
        "development/senior-frontend"
        "development/senior-backend"
        "development/senior-architect"
        "development/senior-fullstack"
        "development/code-reviewer"
        "development/skill-creator"
        "development/webapp-testing"
        "development/senior-security"
        "development/mcp-builder"
        "development/senior-prompt-engineer"
        "development/brainstorming"
        "development/git-commit-helper"
        "creative-design/ui-ux-pro-max"
        "creative-design/ui-design-system"
        "creative-design/mobile-design"
    )

    if ! command -v npx &> /dev/null; then
        log_warning "npm/npx not found. Skipping external skill installations."
        log_info "Install Node.js to enable external skill installations."
        return 0
    fi

    log_info "Installing ${#skills[@]} external skills from claude-code-templates..."
    echo ""

    for skill in "${skills[@]}"; do
        if npx claude-code-templates@latest "${skill}" --yes 2>/dev/null; then
            EXTERNAL_SKILLS_INSTALLED=$((EXTERNAL_SKILLS_INSTALLED + 1))
            log_success "Installed: ${skill}"
        else
            log_warning "Failed to install: ${skill}"
            SKILLS_FAILED=$((SKILLS_FAILED + 1))
        fi
    done

    # Special case: copywriting skill
    install_copywriting_skill

    echo ""
    log_info "External skills installation complete (${EXTERNAL_SKILLS_INSTALLED} succeeded, ${SKILLS_FAILED} failed)"
}

# ============================================================================
# MCP INSTALLATION
# ============================================================================

install_mcp() {
    local mcp_name="$1"
    local mcp_repo="$2"

    log_step "Installing MCP: ${mcp_name}"

    if command -v npx &> /dev/null; then
        if npx -y @anthropic/create-mcp "${mcp_repo}" 2>/dev/null; then
            MCPS_INSTALLED=$((MCPS_INSTALLED + 1))
            log_success "Installed MCP: ${mcp_name}"
            return 0
        else
            log_warning "Failed to install MCP: ${mcp_name}"
            MCPS_FAILED=$((MCPS_FAILED + 1))
            return 1
        fi
    else
        log_warning "npm/npx not available, skipping MCP: ${mcp_name}"
        return 1
    fi
}

install_mcps() {
    log_section "INSTALLING & CONFIGURING MCPS (MODEL CONTEXT PROTOCOLS)"

    if ! command -v npx &> /dev/null; then
        log_warning "npm/npx not found. Skipping MCP installations."
        log_info "Install Node.js to enable MCP installations."
        return 0
    fi

    if ! command -v python3 &> /dev/null; then
        log_warning "Python 3 not available. Skipping MCP installations."
        return 0
    fi

    # Check if PROJECT_PROFILE.json exists
    local profile_path="${TARGET_DIR}/.claude/PROJECT_PROFILE.json"
    if [[ ! -f "${profile_path}" ]]; then
        log_info "No PROJECT_PROFILE.json found. Skipping MCP installation from profile."
        return 0
    fi

    log_info "Reading recommended MCPs from PROJECT_PROFILE.json..."

    # Create MCP servers directory
    mkdir -p "${TARGET_DIR}/.claude/mcps"

    # Initialize settings.json if it doesn't exist
    local settings_file="${TARGET_DIR}/.claude/settings.json"
    if [[ ! -f "${settings_file}" ]]; then
        echo '{"mcpServers": {}}' > "${settings_file}"
    fi

    # Master MCP resolution, validation & installation via Python
    profile_path="${profile_path}" TARGET_DIR="${TARGET_DIR}" python3 << 'MCP_INSTALLER_BLOCK'
import json
import subprocess
import os
import sys
import shutil

profile_path = os.environ.get('profile_path', '')
target_dir = os.environ.get('TARGET_DIR', '')
settings_file = os.path.join(target_dir, '.claude/settings.json')

# ═══════════════════════════════════════════════════════════════════
# DEVLMER MCP REGISTRY v3.0
# Maps short names to verified npm packages with proper configurations
# ═══════════════════════════════════════════════════════════════════
MCP_REGISTRY = {
    # ── Official MCP Protocol Servers ──────────────────────────────
    "github": {
        "package": "@modelcontextprotocol/server-github",
        "env": {"GITHUB_PERSONAL_ACCESS_TOKEN": ""},
        "description": "GitHub repos, issues, PRs, code search",
        "env_prompt": "GITHUB_PERSONAL_ACCESS_TOKEN"
    },
    "slack": {
        "package": "@modelcontextprotocol/server-slack",
        "env": {"SLACK_BOT_TOKEN": "", "SLACK_TEAM_ID": ""},
        "description": "Slack channels, messages, threads"
    },
    "postgres": {
        "package": "@modelcontextprotocol/server-postgres",
        "args_extra": [],
        "description": "PostgreSQL database queries"
    },
    "redis": {
        "package": "@modelcontextprotocol/server-redis",
        "env": {"REDIS_URL": "redis://localhost:6379"},
        "description": "Redis key-value operations"
    },
    "memory": {
        "package": "@modelcontextprotocol/server-memory",
        "description": "Persistent memory for conversations"
    },
    "puppeteer": {
        "package": "@modelcontextprotocol/server-puppeteer",
        "description": "Browser automation with Puppeteer"
    },
    "filesystem": {
        "package": "@modelcontextprotocol/server-filesystem",
        "description": "Local filesystem read/write"
    },
    "brave-search": {
        "package": "@modelcontextprotocol/server-brave-search",
        "env": {"BRAVE_API_KEY": ""},
        "description": "Brave search engine integration"
    },
    "everything": {
        "package": "@modelcontextprotocol/server-everything",
        "description": "Combined MCP capabilities server"
    },

    # ── Community / Verified MCP Servers ───────────────────────────
    "playwright": {
        "package": "mcp-playwright",
        "description": "Browser automation with Playwright"
    },
    "context7": {
        "package": "@upstash/context7-mcp",
        "description": "Up-to-date library documentation"
    },
    "notion": {
        "package": "@notionhq/notion-mcp-server",
        "env": {"NOTION_API_KEY": ""},
        "description": "Notion pages, databases, search"
    },
    "stripe": {
        "package": "mcp-server-stripe",
        "env": {"STRIPE_SECRET_KEY": ""},
        "description": "Stripe payments, subscriptions, invoices"
    },
    "discord": {
        "package": "mcp-server-discord",
        "env": {"DISCORD_BOT_TOKEN": ""},
        "description": "Discord channels, messages, guilds"
    },
    "telegram": {
        "package": "mcp-server-telegram",
        "env": {"TELEGRAM_BOT_TOKEN": ""},
        "description": "Telegram messages, chats, bots"
    },
    "whatsapp": {
        "package": "mcp-server-whatsapp",
        "description": "WhatsApp messaging integration"
    },
    "elasticsearch": {
        "package": "mcp-server-elasticsearch",
        "env": {"ELASTICSEARCH_URL": "http://localhost:9200"},
        "description": "Elasticsearch search & indexing"
    },
    "sentry": {
        "package": "sentry-mcp",
        "env": {"SENTRY_AUTH_TOKEN": ""},
        "description": "Sentry error tracking & monitoring"
    },
    "supabase": {
        "package": "supabase-mcp",
        "env": {"SUPABASE_URL": "", "SUPABASE_KEY": ""},
        "description": "Supabase database, auth, storage"
    },
    "datadog": {
        "package": "datadog-mcp",
        "env": {"DD_API_KEY": "", "DD_APP_KEY": ""},
        "description": "Datadog monitoring & observability"
    },
    "langchain": {
        "package": "langchain-mcp",
        "description": "LangChain agent framework integration"
    },
    "pinecone": {
        "package": "@pinecone-database/mcp",
        "env": {"PINECONE_API_KEY": ""},
        "description": "Pinecone vector database"
    },
    "chromadb": {
        "package": "chromadb-mcp",
        "description": "ChromaDB vector database"
    },
    "e2b": {
        "package": "@e2b/mcp-server",
        "env": {"E2B_API_KEY": ""},
        "description": "E2B code sandbox execution"
    },
    "sendgrid": {
        "package": "sendgrid-mcp-server",
        "env": {"SENDGRID_API_KEY": ""},
        "description": "SendGrid email delivery"
    },
    "firecrawl": {
        "package": "firecrawl-mcp",
        "env": {"FIRECRAWL_API_KEY": ""},
        "description": "Web scraping & crawling"
    },

    # ── Fallback resolution patterns ──────────────────────────────
    # If a name isn't in the registry, we try these patterns in order:
    # 1. @modelcontextprotocol/server-{name}
    # 2. mcp-server-{name}
    # 3. {name}-mcp
    # 4. mcp-{name}
}

def resolve_mcp_package(name):
    """Resolve a short MCP name to its real npm package."""
    name_lower = name.lower().strip()

    # Direct registry lookup
    if name_lower in MCP_REGISTRY:
        return MCP_REGISTRY[name_lower]

    # Return None if not in registry — we'll try fallback patterns
    return None

def validate_npm_package(package_name):
    """Check if an npm package exists (fast check via npm info)."""
    try:
        result = subprocess.run(
            ["npm", "info", package_name, "name"],
            capture_output=True, text=True, timeout=15
        )
        return result.returncode == 0 and result.stdout.strip() != ""
    except:
        return False

def try_resolve_unknown(name):
    """Try common patterns to find an unknown MCP package."""
    patterns = [
        f"@modelcontextprotocol/server-{name}",
        f"mcp-server-{name}",
        f"{name}-mcp",
        f"mcp-{name}",
    ]
    for pattern in patterns:
        if validate_npm_package(pattern):
            return {"package": pattern, "description": f"{name} MCP server (auto-resolved)"}
    return None

# ═══════════════════════════════════════════════════════════════════
# MAIN INSTALLATION LOGIC
# ═══════════════════════════════════════════════════════════════════

try:
    with open(profile_path, 'r') as f:
        profile = json.load(f)

    # Collect all MCP names from profile
    recommended = profile.get('recommended_mcps', [])
    installed = profile.get('installed_mcps', [])
    all_names = list(set(
        [(m.get('name', '') if isinstance(m, dict) else str(m)) for m in recommended] +
        [(m.get('name', '') if isinstance(m, dict) else str(m)) for m in installed]
    ))
    all_names = [n for n in all_names if n and 'nano-banana' not in n.lower()]

    # Load existing settings
    settings = {}
    if os.path.exists(settings_file):
        with open(settings_file, 'r') as sf:
            settings = json.load(sf)
    if 'mcpServers' not in settings:
        settings['mcpServers'] = {}

    total = len(all_names)
    configured = 0
    skipped = 0
    failed = 0
    resolved_unknown = 0

    print(f"\n{'═' * 60}")
    print(f"  DEVLMER MCP INSTALLER — {total} servers to configure")
    print(f"{'═' * 60}\n")

    for i, name in enumerate(sorted(all_names), 1):
        prefix = f"  [{i:2d}/{total}]"

        # Skip already configured
        if name in settings['mcpServers']:
            print(f"{prefix} ⏩ {name} — already configured")
            skipped += 1
            continue

        # Try registry lookup
        info = resolve_mcp_package(name)

        if info:
            package = info['package']
            env_vars = info.get('env', {})
            desc = info.get('description', '')
            print(f"{prefix} 📦 {name} → {package}")
            if desc:
                print(f"         ℹ️  {desc}")

            # Build MCP config
            config = {
                "command": "npx",
                "args": ["-y", package],
            }
            if env_vars:
                config["env"] = env_vars
                empty_keys = [k for k, v in env_vars.items() if not v]
                if empty_keys:
                    print(f"         ⚠️  Requires env: {', '.join(empty_keys)}")

            settings['mcpServers'][name] = config
            configured += 1

        else:
            # Try auto-resolution for unknown packages
            print(f"{prefix} 🔍 {name} — not in registry, searching npm...")
            resolved = try_resolve_unknown(name)
            if resolved:
                package = resolved['package']
                print(f"         ✅ Found: {package}")
                settings['mcpServers'][name] = {
                    "command": "npx",
                    "args": ["-y", package],
                    "env": {}
                }
                configured += 1
                resolved_unknown += 1
            else:
                print(f"         ❌ No valid npm package found — skipping")
                failed += 1

    # Save settings
    with open(settings_file, 'w') as sf:
        json.dump(settings, sf, indent=2)

    # Summary
    print(f"\n{'═' * 60}")
    print(f"  MCP INSTALLATION SUMMARY")
    print(f"{'─' * 60}")
    print(f"  ✅ Configured:     {configured} servers")
    if resolved_unknown:
        print(f"     └─ Auto-resolved: {resolved_unknown} (searched npm)")
    print(f"  ⏩ Already existed: {skipped} servers")
    if failed:
        print(f"  ❌ Not found:      {failed} servers")
    print(f"  📄 Settings saved: {settings_file}")
    print(f"{'═' * 60}\n")

    # Generate env setup instructions if needed
    env_instructions = []
    for name, config in settings.get('mcpServers', {}).items():
        if isinstance(config, dict) and 'env' in config:
            for key, val in config['env'].items():
                if not val:
                    env_instructions.append(f"  export {key}=your-{key.lower().replace('_', '-')}-here")

    if env_instructions:
        env_file = os.path.join(target_dir, '.claude/mcp-env-setup.sh')
        with open(env_file, 'w') as ef:
            ef.write("#!/bin/bash\n")
            ef.write("# ═══════════════════════════════════════════════════════\n")
            ef.write("# DEVLMER MCP — Environment Variables Setup\n")
            ef.write("# Fill in your API keys and source this file:\n")
            ef.write("#   source .claude/mcp-env-setup.sh\n")
            ef.write("# ═══════════════════════════════════════════════════════\n\n")
            seen = set()
            for line in env_instructions:
                key = line.split('=')[0].strip()
                if key not in seen:
                    ef.write(line.replace('  ', '') + "\n")
                    seen.add(key)
        os.chmod(env_file, 0o755)
        print(f"  💡 API keys needed — edit: .claude/mcp-env-setup.sh")
        print(f"     Then run: source .claude/mcp-env-setup.sh\n")

except Exception as e:
    print(f"❌ Error in MCP installation: {e}")
    import traceback
    traceback.print_exc()
MCP_INSTALLER_BLOCK

    MCPS_INSTALLED=$(python3 -c "
import json
try:
    with open('${TARGET_DIR}/.claude/settings.json') as f:
        s = json.load(f)
    print(len(s.get('mcpServers', {})))
except:
    print(0)
" 2>/dev/null || echo "0")

    log_success "MCP installation complete — ${MCPS_INSTALLED} servers configured in settings.json"
}

# ============================================================================
# AGENT CONFIGURATION
# ============================================================================

configure_agents() {
    log_section "CONFIGURING AGENTS"

    # Check if PROJECT_PROFILE.json exists
    local profile_path="${TARGET_DIR}/.claude/PROJECT_PROFILE.json"
    if [[ ! -f "${profile_path}" ]]; then
        log_info "No PROJECT_PROFILE.json found. Skipping agent configuration."
        return 0
    fi

    log_info "Reading recommended agents from PROJECT_PROFILE.json..."

    # Create agents directory
    mkdir -p "${TARGET_DIR}/.claude/agents"

    # Use Python to extract and configure agents
    if command -v python3 &> /dev/null; then
        profile_path="${profile_path}" TARGET_DIR="${TARGET_DIR}" python3 << 'CONFIGURE_AGENTS_BLOCK'
import json
import os
import sys

profile_path = os.environ.get('profile_path', '')
target_dir = os.environ.get('TARGET_DIR', '')
agents_dir = os.path.join(target_dir, '.claude/agents')

try:
    with open(profile_path, 'r') as f:
        profile = json.load(f)
        agents = profile.get('agents', profile.get('recommended_agents', []))
        domain = profile.get('fingerprint', {}).get('domain', 'general')

        if isinstance(agents, list) and agents:
            for agent_item in agents:
                if isinstance(agent_item, dict):
                    agent_name = agent_item.get('name', '')
                    description = agent_item.get('role', agent_item.get('description', 'Specialized agent'))
                elif isinstance(agent_item, str):
                    agent_name = agent_item
                    description = f'Specialized {agent_item} agent'
                else:
                    continue

                if not agent_name:
                    continue

                # Create agent markdown file
                agent_file = os.path.join(agents_dir, f"{agent_name}.md")

                # Generate agent file content
                agent_content = f"""---
name: {agent_name}
description: {description}
model: sonnet
---

You are a specialized agent for {domain}. Your role is to {description}.

## Your Capabilities
- Analyzing and understanding {domain} context
- Making decisions based on available data
- Reporting findings with supporting evidence
- Collaborating with other agents and systems

## Rules
1. Always verify information before acting
2. Report findings with evidence and reasoning
3. Maintain clear communication with users
4. Respect all safety and security guidelines
5. Ask for clarification when requirements are ambiguous

## Domain Expertise
This agent specializes in {domain} and understands:
- Industry best practices
- Common workflows and patterns
- Key challenges and solutions
- Integration points with other systems
"""

                try:
                    with open(agent_file, 'w') as af:
                        af.write(agent_content)
                    print(f"Created agent: {agent_name}")
                except Exception as e:
                    print(f"Failed to create agent {agent_name}: {e}", file=sys.stderr)
        else:
            print("No agents found in profile")

except Exception as e:
    print(f"Error processing agents: {e}", file=sys.stderr)
CONFIGURE_AGENTS_BLOCK

        # Count created agents
        if [[ -d "${TARGET_DIR}/.claude/agents" ]]; then
            AGENTS_CONFIGURED=$(ls -1 "${TARGET_DIR}/.claude/agents"/*.md 2>/dev/null | wc -l)
        fi
    else
        log_warning "Python 3 not available for agent configuration"
        return 1
    fi

    log_info "Agent configuration complete (${AGENTS_CONFIGURED} agents created)"
}

# ============================================================================
# PROJECT INTELLIGENCE & BLUEPRINTS
# ============================================================================

copy_blueprints() {
    log_step "Copying blueprints..."

    local blueprints_dir="${SCRIPT_DIR}/blueprints"

    if [[ ! -d "${blueprints_dir}" ]] || [[ -z "$(ls -A "${blueprints_dir}" 2>/dev/null)" ]]; then
        log_warning "No blueprints found in ${blueprints_dir}"
        return 0
    fi

    cp -r "${blueprints_dir}"/* "${TARGET_DIR}/.claude/config/" 2>/dev/null || true
    CONFIG_FILES_CREATED=$((CONFIG_FILES_CREATED + 1))
    log_success "Blueprints copied to .claude/config/"
}

copy_scripts() {
    log_step "Copying project intelligence scripts..."

    local scripts_dir="${SCRIPT_DIR}/scripts"

    if [[ ! -d "${scripts_dir}" ]] || [[ -z "$(ls -A "${scripts_dir}" 2>/dev/null)" ]]; then
        log_info "No project intelligence scripts found"
        return 0
    fi

    cp -r "${scripts_dir}"/* "${TARGET_DIR}/.claude/" 2>/dev/null || true
    SCRIPTS_COPIED=$((SCRIPTS_COPIED + 1))
    log_success "Project intelligence scripts copied"
    log_verbose "Scripts copied from: ${scripts_dir}"
}

# ============================================================================
# HOOKS SETUP
# ============================================================================

setup_hooks() {
    log_step "Configuring Claude Code hooks..."

    # Create SessionStart hook for project intelligence
    cat > "${TARGET_DIR}/.claude/hooks/session-start.md" << 'EOF'
# SessionStart Hook

This hook executes at the start of each Claude Code session.

## Responsibilities
- Run project fingerprinter (detect_project.py)
- Generate PROJECT_PROFILE.json
- Load context from memory/ directory
- Initialize orchestration state

## Implementation
Triggered automatically by Claude Code when opening .claude/hooks/session-start.md
EOF

    # Create PreToolUse hook for auto-verification
    cat > "${TARGET_DIR}/.claude/hooks/pre-tool-use.md" << 'EOF'
# PreToolUse Hook

This hook executes before any tool invocation.

## Responsibilities
- Validate tool parameters
- Check for security implications
- Apply rate limiting where necessary

## Implementation
Triggered automatically by Claude Code before tool calls
EOF

    # Create PostToolUse hook for auto-verification
    cat > "${TARGET_DIR}/.claude/hooks/post-tool-use.md" << 'EOF'
# PostToolUse Hook

This hook executes after tool execution completes.

## Responsibilities
- Verify tool execution success
- Update project profile
- Log outcomes to audit trail
- Trigger auto-verify workflows (code-review, security-audit, etc.)

## Implementation
Triggered automatically by Claude Code after tool calls
EOF

    log_success "Hook configurations created"
}

# ============================================================================
# GLOBAL CONFIGURATION
# ============================================================================

create_global_claude_md() {
    log_step "Creating global CLAUDE.md..."

    cat > "${TARGET_DIR}/.claude/CLAUDE.md" << 'EOF'
# CLAUDE.md - Global Configuration

Auto-generated by Devlmer Ecosystem Engine Installer v3.0

## System Configuration

### Hooks
- **SessionStart**: Project fingerprinting and context initialization
- **PreToolUse**: Parameter validation and security checks
- **PostToolUse**: Auto-verification (code-review, tests, security-audit)

### Skills
All available skills have been installed to `.claude/skills/`

### Project Intelligence
- **Fingerprinter**: `detect_project.py` - Scans project structure
- **Orchestrator**: `orchestrate.py` - Coordinates multi-agent tasks
- **Blueprint**: `ecosystems.json` - Architecture template library

### Logging
- All sessions logged to `.claude/logs/`
- Project profile generated at `.claude/PROJECT_PROFILE.json`

## Auto-Activation Rules

Skills are auto-activated based on context:
- Writing copy/marketing → copywriting skill
- Creating documents → docx, pdf, pptx, xlsx skills
- Scheduling → schedule skill + mcp__scheduled-tasks
- Calendar work → gcal_* tools
- Web browsing → Playwright tools
- Code changes → auto code-review + security-audit if sensitive

## GitHub Integration

GitHub authentication status stored in `~/.devlmer/github-auth.json`
- Enables repository synchronization
- Supports automated configuration backups
- Facilitates upstream updates

## Nano-Banana-MCP

Gemini API configuration stored in `~/.devlmer/nano-banana-config.json`
- Provides advanced AI capabilities
- Requires valid Gemini API key
EOF

    CONFIG_FILES_CREATED=$((CONFIG_FILES_CREATED + 1))
    log_success "Global CLAUDE.md created"
}

create_settings_json() {
    log_step "Creating settings.json..."

    local settings_file="${TARGET_DIR}/.claude/settings.json"

    # If settings.json already exists (e.g., from install_mcps), merge instead of overwrite
    if [[ -f "${settings_file}" ]]; then
        log_info "settings.json already exists — merging Devlmer config..."
        if command -v python3 &> /dev/null; then
            TARGET_DIR="${TARGET_DIR}" python3 << 'MERGE_SETTINGS'
import json, os
target_dir = os.environ.get('TARGET_DIR', '')
settings_file = os.path.join(target_dir, '.claude/settings.json')
try:
    with open(settings_file, 'r') as f:
        existing = json.load(f)
    # Add Devlmer metadata without touching mcpServers
    existing.setdefault('version', '3.0')
    existing.setdefault('engine', 'devlmer-ecosystem-engine')
    existing.setdefault('brand', 'Devlmer')
    existing.setdefault('website', 'https://devlmer.com')
    existing.setdefault('author', 'Pierre Solier')
    existing.setdefault('hooks', {"session_start": True, "pre_tool_use": True, "post_tool_use": True})
    existing.setdefault('skills', {"auto_activate": True, "verify_execution": True})
    existing.setdefault('logging', {"enabled": True, "level": "info", "directory": ".claude/logs"})
    existing.setdefault('project_intelligence', {"fingerprinting": True, "auto_detect": True, "profile_path": ".claude/PROJECT_PROFILE.json"})
    existing.setdefault('security', {"audit_sensitive_changes": True, "require_confirmation": True})
    existing.setdefault('github', {"auth_file": "~/.devlmer/github-auth.json", "enabled": True})
    with open(settings_file, 'w') as f:
        json.dump(existing, f, indent=2)
    print("✅ Merged Devlmer config into existing settings.json")
except Exception as e:
    print(f"⚠️ Error merging settings: {e}")
MERGE_SETTINGS
        fi
        CONFIG_FILES_CREATED=$((CONFIG_FILES_CREATED + 1))
        log_success "Settings.json merged successfully"
        return 0
    fi

    cat > "${settings_file}" << 'EOF'
{
  "version": "3.0",
  "engine": "devlmer-ecosystem-engine",
  "brand": "Devlmer",
  "website": "https://devlmer.com",
  "author": "Pierre Solier",
  "created_at": "2026-04-04T00:00:00Z",
  "hooks": {
    "session_start": true,
    "pre_tool_use": true,
    "post_tool_use": true
  },
  "skills": {
    "auto_activate": true,
    "verify_execution": true
  },
  "logging": {
    "enabled": true,
    "level": "info",
    "directory": ".claude/logs"
  },
  "project_intelligence": {
    "fingerprinting": true,
    "auto_detect": true,
    "profile_path": ".claude/PROJECT_PROFILE.json"
  },
  "security": {
    "audit_sensitive_changes": true,
    "require_confirmation": true
  },
  "github": {
    "auth_file": "~/.devlmer/github-auth.json",
    "enabled": true
  },
  "mcpServers": {
    "nano-banana": {
      "enabled": false,
      "config_file": "~/.devlmer/nano-banana-config.json"
    }
  }
}
EOF

    CONFIG_FILES_CREATED=$((CONFIG_FILES_CREATED + 1))
    log_success "Settings.json created"
}

# ============================================================================
# PROJECT FINGERPRINTING
# ============================================================================

run_project_fingerprinter() {
    log_step "Running project fingerprinter..."

    local fingerprinter="${SCRIPT_DIR}/scripts/detect_project.py"

    if [[ ! -f "${fingerprinter}" ]]; then
        log_info "Project fingerprinter script not found (optional)"
        return 0
    fi

    if ! command -v python3 &> /dev/null; then
        log_warning "Python 3 not found, skipping fingerprinting"
        return 0
    fi

    if cd "${TARGET_DIR}" && python3 "${fingerprinter}" "$(pwd)" > /dev/null 2>&1; then
        log_success "Project fingerprinting completed"
        return 0
    else
        log_warning "Project fingerprinting encountered issues"
        return 1
    fi
}

run_orchestrator() {
    log_step "Running project orchestrator..."

    local orchestrator="${SCRIPT_DIR}/scripts/orchestrate.py"
    local blueprints="${SCRIPT_DIR}/blueprints/ecosystems.json"

    if [[ ! -f "${orchestrator}" ]]; then
        log_info "Project orchestrator script not found (optional)"
        return 0
    fi

    if ! command -v python3 &> /dev/null; then
        log_warning "Python 3 not found, skipping orchestration"
        return 0
    fi

    # Copy blueprints to target if not present
    if [[ -f "${blueprints}" ]]; then
        mkdir -p "${TARGET_DIR}/.claude/skills/project-intelligence/blueprints"
        cp "${blueprints}" "${TARGET_DIR}/.claude/skills/project-intelligence/blueprints/ecosystems.json" 2>/dev/null || true
    fi

    # Run orchestrator and save profile
    cd "${TARGET_DIR}"
    if python3 "${orchestrator}" "$(pwd)" --profile > "${TARGET_DIR}/.claude/PROJECT_PROFILE.json" 2>/dev/null; then
        log_success "Project profile saved to .claude/PROJECT_PROFILE.json"
    fi

    # Also print summary
    if python3 "${orchestrator}" "$(pwd)" --summary 2>/dev/null; then
        log_success "Project orchestration completed"
        return 0
    else
        log_warning "Project orchestration encountered issues"
        return 1
    fi
}

# ============================================================================
# ARGUMENT PARSING
# ============================================================================

parse_arguments() {
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --help)
                show_help
                exit 0
                ;;
            --skills-only)
                MODE="skills-only"
                shift
                ;;
            --scan-only)
                MODE="scan-only"
                shift
                ;;
            --verbose)
                VERBOSE=1
                shift
                ;;
            --no-external)
                NO_EXTERNAL=1
                shift
                ;;
            --no-mcp)
                NO_MCP=1
                shift
                ;;
            --no-github)
                NO_GITHUB=1
                shift
                ;;
            --github-token)
                GITHUB_TOKEN="$2"
                GITHUB_AUTHENTICATED=1
                shift 2
                ;;
            --gemini-key)
                GEMINI_KEY="$2"
                shift 2
                ;;
            *)
                # First positional argument is the target directory
                if [[ ! "$1" == -* ]]; then
                    TARGET_DIR="$1"
                    shift
                else
                    log_error "Unknown option: $1"
                    show_help
                    exit 1
                fi
                ;;
        esac
    done
}

# ============================================================================
# SUMMARY & REPORTING
# ============================================================================

calculate_duration() {
    local end_time=$(date +%s)
    local duration=$((end_time - INSTALL_START_TIME))

    local minutes=$((duration / 60))
    local seconds=$((duration % 60))

    if [[ ${minutes} -gt 0 ]]; then
        echo "${minutes}m ${seconds}s"
    else
        echo "${seconds}s"
    fi
}

show_summary() {
    local duration=$(calculate_duration)

    log_section "INSTALLATION SUMMARY"

    echo ""
    echo -e "${BOLD}Bundled Skills:${RESET}"
    echo -e "  ${GREEN}✓ Copied:${RESET} ${SKILLS_INSTALLED}"

    if [[ ${EXTERNAL_SKILLS_INSTALLED} -gt 0 ]] || [[ ${SKILLS_FAILED} -gt 0 ]]; then
        echo ""
        echo -e "${BOLD}External Skills:${RESET}"
        echo -e "  ${GREEN}✓ Installed:${RESET} ${EXTERNAL_SKILLS_INSTALLED}"
        if [[ ${SKILLS_FAILED} -gt 0 ]]; then
            echo -e "  ${RED}✗ Failed:${RESET} ${SKILLS_FAILED}"
        fi
    fi

    if [[ ${MCPS_INSTALLED} -gt 0 ]] || [[ ${MCPS_FAILED} -gt 0 ]]; then
        echo ""
        echo -e "${BOLD}MCPs (Model Context Protocols):${RESET}"
        echo -e "  ${GREEN}✓ Installed:${RESET} ${MCPS_INSTALLED}"
        if [[ ${MCPS_FAILED} -gt 0 ]]; then
            echo -e "  ${RED}✗ Failed:${RESET} ${MCPS_FAILED}"
        fi
    fi

    if [[ ${AGENTS_CONFIGURED} -gt 0 ]] || [[ ${AGENTS_FAILED} -gt 0 ]]; then
        echo ""
        echo -e "${BOLD}Agents:${RESET}"
        echo -e "  ${GREEN}✓ Configured:${RESET} ${AGENTS_CONFIGURED}"
        if [[ ${AGENTS_FAILED} -gt 0 ]]; then
            echo -e "  ${RED}✗ Failed:${RESET} ${AGENTS_FAILED}"
        fi
    fi

    echo ""
    echo -e "${BOLD}GitHub Authentication:${RESET}"
    if [[ ${GITHUB_AUTHENTICATED} -eq 1 ]]; then
        echo -e "  ${GREEN}✓ Status:${RESET} Authenticated"
        echo -e "  ${CYAN}Config:${RESET} ${HOME}/.devlmer/github-auth.json"
    else
        echo -e "  ${YELLOW}○ Status:${RESET} Not authenticated"
    fi

    echo ""
    echo -e "${BOLD}Nano-Banana-MCP:${RESET}"
    if [[ ${NANO_BANANA_INSTALLED} -eq 1 ]]; then
        echo -e "  ${GREEN}✓ Status:${RESET} Installed & Configured"
        echo -e "  ${CYAN}Config:${RESET} ${HOME}/.devlmer/nano-banana-config.json"
    else
        echo -e "  ${YELLOW}○ Status:${RESET} Not installed"
    fi

    echo ""
    echo -e "${BOLD}Configuration:${RESET}"
    echo -e "  ${GREEN}✓ Config files:${RESET} ${CONFIG_FILES_CREATED}"
    echo -e "  ${GREEN}✓ Scripts copied:${RESET} ${SCRIPTS_COPIED}"

    echo ""
    echo -e "${BOLD}Installation Details:${RESET}"
    echo -e "  ${CYAN}Target directory:${RESET} ${TARGET_DIR}"
    echo -e "  ${CYAN}Mode:${RESET} ${MODE}"
    echo -e "  ${CYAN}Platform:${RESET} $(detect_platform)"
    echo -e "  ${CYAN}Duration:${RESET} ${duration}"

    echo ""
    echo -e "${BOLD}${GREEN}Installation Complete!${RESET}"
    echo ""

    if [[ -f "${TARGET_DIR}/.claude/CLAUDE.md" ]]; then
        echo -e "${CYAN}Next steps:${RESET}"
        echo -e "  1. Review configuration: ${TARGET_DIR}/.claude/CLAUDE.md"
        echo -e "  2. Verify skills: ls ${TARGET_DIR}/.claude/skills/"
        echo -e "  3. Check project profile: ${TARGET_DIR}/.claude/PROJECT_PROFILE.json"
        if [[ ${GITHUB_AUTHENTICATED} -eq 1 ]]; then
            echo -e "  4. Review GitHub auth: ${HOME}/.devlmer/github-auth.json"
        fi
        echo ""
    fi
}

show_product_info() {
    echo ""
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════════${RESET}"
    echo -e "${BOLD}${MAGENTA}  DEVLMER ECOSYSTEM ENGINE v3.0${RESET}"
    echo -e "${BOLD}${MAGENTA}  by Pierre Solier (Devlmer)${RESET}"
    echo -e "${BOLD}${MAGENTA}  https://devlmer.com${RESET}"
    echo -e "${BOLD}${MAGENTA}═══════════════════════════════════════════════════════════${RESET}"
    echo ""
}

# ============================================================================
# MAIN INSTALLATION FLOW
# ============================================================================

main() {
    show_banner

    # Parse arguments
    parse_arguments "$@"

    # Default target directory to current directory if not set
    if [[ -z "${TARGET_DIR}" ]]; then
        TARGET_DIR="."
    fi

    log_info "Installation Mode: ${MODE}"
    log_info "Target Directory: ${TARGET_DIR}"
    echo ""

    # Detect platform
    local platform=$(detect_platform)
    if [[ "${platform}" == "unknown" ]]; then
        log_warning "Unknown platform. Installation may have issues."
    fi

    # Check dependencies
    check_dependencies
    echo ""

    # Setup directories
    log_section "DIRECTORY SETUP"
    setup_directories
    echo ""

    # GitHub authentication (early in process, skippable)
    if [[ "${NO_GITHUB}" -eq 0 ]]; then
        log_section "GITHUB AUTHENTICATION"
        if [[ -n "${GITHUB_TOKEN}" ]]; then
            GITHUB_AUTHENTICATED=1
            log_success "GitHub token provided via command line"
            save_github_auth
            offer_github_features
        elif [[ -t 0 ]]; then
            # Interactive terminal — ask user
            get_github_auth_interactive
            save_github_auth
            offer_github_features
        else
            log_info "Non-interactive mode — skipping GitHub auth (use --github-token to provide)"
        fi
        echo ""
    else
        log_info "GitHub authentication skipped (--no-github)"
        echo ""
    fi

    # Nano-Banana-MCP setup
    if [[ "${MODE}" != "scan-only" ]] && [[ -z "${NO_MCP:-}" ]]; then
        setup_nano_banana_mcp
        echo ""
    fi

    # Bundled skills installation (all modes except scan-only)
    if [[ "${MODE}" != "scan-only" ]]; then
        log_section "INSTALLING BUNDLED SKILLS"
        copy_bundled_skills
        echo ""
    fi

    # External skills installation (full and skills-only modes)
    if [[ "${MODE}" != "scan-only" ]] && [[ -z "${NO_EXTERNAL:-}" ]]; then
        install_external_skills
        echo ""
    fi

    # Configuration setup (all modes except skills-only)
    # IMPORTANT: create_settings_json MUST run BEFORE install_mcps
    # so MCPs can merge into the existing settings file
    if [[ "${MODE}" != "skills-only" ]]; then
        log_section "CONFIGURATION & SETUP"

        copy_blueprints
        copy_scripts
        setup_hooks
        create_global_claude_md
        create_settings_json

        echo ""
    fi

    # Project intelligence scanning (full and scan-only modes)
    # MUST run BEFORE install_mcps because the fingerprinter/orchestrator
    # creates PROJECT_PROFILE.json which install_mcps reads
    if [[ "${MODE}" != "skills-only" ]]; then
        log_section "PROJECT INTELLIGENCE"

        run_project_fingerprinter
        run_orchestrator

        echo ""
    fi

    # MCP installation (full and skills-only modes)
    # Runs AFTER orchestrator (which creates the profile with MCPs)
    # and AFTER create_settings_json (which creates the base settings file)
    if [[ "${MODE}" != "scan-only" ]] && [[ -z "${NO_MCP:-}" ]]; then
        install_mcps
        echo ""
    fi

    # Agent configuration (requires PROJECT_PROFILE.json from orchestrator)
    if [[ "${MODE}" != "skills-only" ]]; then
        configure_agents
        echo ""
    fi

    # Show summary
    show_summary

    # Product info
    show_product_info
}

# ============================================================================
# ENTRY POINT
# ============================================================================

# Handle early exit flags
if [[ $# -eq 0 ]] || [[ "$1" == "--help" ]]; then
    show_banner
    if [[ $# -eq 0 ]]; then
        main "."
    else
        show_help
    fi
else
    # Standard installation
    main "$@"
fi

exit 0
