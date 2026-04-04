#!/usr/bin/env bash

################################################################################
#
# DYSA Ecosystem Engine v3.0 - Master Installer Script
#
# A comprehensive, enterprise-grade installer for the DYSA Ecosystem Engine.
# Handles skill installation, project intelligence setup, MCP integration, and
# global configuration initialization.
#
# Usage:
#   ./install.sh [target-directory] [options]
#   ./install.sh --help
#   ./install.sh --skills-only
#   ./install.sh --scan-only
#
# Author: DYSA Development Team
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
readonly WHITE='\033[1;37m'
readonly RESET='\033[0m'
readonly BOLD='\033[1m'

# Progress indicators
readonly CHECK="${GREEN}✓${RESET}"
readonly CROSS="${RED}✗${RESET}"
readonly WARN="${YELLOW}⚠${RESET}"
readonly INFO="${BLUE}ℹ${RESET}"

# ============================================================================
# GLOBAL VARIABLES
# ============================================================================

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET_DIR="${1:-.}"
MODE="full"  # full, skills-only, scan-only
VERBOSE=0

SKILLS_INSTALLED=0
SKILLS_FAILED=0
EXTERNAL_SKILLS_INSTALLED=0
MCPS_INSTALLED=0
MCPS_FAILED=0
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
    echo -e "${CYAN}  → ${1}${RESET}"
}

log_verbose() {
    if [[ ${VERBOSE} -eq 1 ]]; then
        echo -e "    ${WHITE}${1}${RESET}"
    fi
}

log_section() {
    echo ""
    echo -e "${BOLD}${BLUE}══════════════════════════════════════════════════════════${RESET}"
    echo -e "${BOLD}${BLUE}  ${1}${RESET}"
    echo -e "${BOLD}${BLUE}══════════════════════════════════════════════════════════${RESET}"
}

# ============================================================================
# BANNER AND HELP
# ============================================================================

show_banner() {
    echo -e "${BOLD}${CYAN}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║                                                              ║"
    echo "║          DYSA ECOSYSTEM ENGINE v3.0                         ║"
    echo "║          Master Installer & Configuration Suite             ║"
    echo "║                                                              ║"
    echo "║  Production-Grade Installation for Enterprise Environments  ║"
    echo "║                                                              ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${RESET}"
}

show_help() {
    cat << EOF

${BOLD}DYSA Ecosystem Engine v3.0 - Master Installer${RESET}

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

${BOLD}EXAMPLES:${RESET}
    ./install.sh /path/to/project
    ./install.sh . --skills-only
    ./install.sh ~ --scan-only --verbose

${BOLD}ENVIRONMENT:${RESET}
    Works on macOS 11+ and Linux (Ubuntu 18+, CentOS 7+)
    Requires: bash 4.0+, node 16+, python 3.8+

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

    log_success "Directory structure created"
    log_verbose "${TARGET_DIR}/.claude/"
    log_verbose "${TARGET_DIR}/.claude/skills/"
    log_verbose "${TARGET_DIR}/.claude/hooks/"
    log_verbose "${TARGET_DIR}/.claude/config/"
    log_verbose "${TARGET_DIR}/.claude/logs/"
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
    log_section "INSTALLING MCPS (Model Context Protocols)"

    if ! command -v npx &> /dev/null; then
        log_warning "npm/npx not found. Skipping MCP installations."
        log_info "Install Node.js to enable MCP installations."
        return 0
    fi

    log_info "Installing Model Context Protocols..."
    echo ""

    # Install Nano-Banana-MCP
    install_mcp "Nano-Banana-MCP" "https://github.com/ConechoAI/Nano-Banana-MCP"

    echo ""
    log_info "MCP installation complete (${MCPS_INSTALLED} succeeded, ${MCPS_FAILED} failed)"
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

Auto-generated by DYSA Ecosystem Engine Installer v3.0

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
EOF

    CONFIG_FILES_CREATED=$((CONFIG_FILES_CREATED + 1))
    log_success "Global CLAUDE.md created"
}

create_settings_json() {
    log_step "Creating settings.json..."

    cat > "${TARGET_DIR}/.claude/config/settings.json" << 'EOF'
{
  "version": "3.0",
  "engine": "dysa-ecosystem-engine",
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

    if cd "${TARGET_DIR}" && python3 "${fingerprinter}" 2>/dev/null; then
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

    if [[ ! -f "${orchestrator}" ]]; then
        log_info "Project orchestrator script not found (optional)"
        return 0
    fi

    if ! command -v python3 &> /dev/null; then
        log_warning "Python 3 not found, skipping orchestration"
        return 0
    fi

    if cd "${TARGET_DIR}" && python3 "${orchestrator}" 2>/dev/null; then
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
        echo ""
    fi
}

# ============================================================================
# MAIN INSTALLATION FLOW
# ============================================================================

main() {
    show_banner

    # Parse arguments
    parse_arguments "$@"

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

    # MCP installation (full and skills-only modes)
    if [[ "${MODE}" != "scan-only" ]] && [[ -z "${NO_MCP:-}" ]]; then
        install_mcps
        echo ""
    fi

    # Configuration setup (all modes except skills-only)
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
    if [[ "${MODE}" != "skills-only" ]]; then
        log_section "PROJECT INTELLIGENCE"

        run_project_fingerprinter
        run_orchestrator

        echo ""
    fi

    # Show summary
    show_summary
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
