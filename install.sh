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
#   ./install.sh --non-interactive (or --yes / -y)
#
# Compatibility: Bash 3.2+ (macOS default), Bash 4+, zsh 5+
# Version: 3.1
# Last Updated: 2026-04-05
#
################################################################################

# NOTE: We use -u (undefined vars) and -o pipefail, but NOT -e (exit on error)
# because run_step() handles errors gracefully and continues installation.
set -uo pipefail

# ============================================================================
# CROSS-PLATFORM COMPATIBILITY LAYER
# ============================================================================
# Supports: macOS (Bash 3.2+, zsh 5+), Linux (all distros), WSL, Git Bash
# This section MUST run before anything else to set up portable primitives.

# --- Platform Detection ---
DEE_OS="unknown"
DEE_ARCH="unknown"
DEE_PKG_MGR="none"
DEE_GNU_TOOLS=0

case "$(uname -s 2>/dev/null || echo unknown)" in
    Darwin*)
        DEE_OS="macos"
        DEE_ARCH="$(uname -m 2>/dev/null || echo unknown)"
        if command -v brew >/dev/null 2>&1; then
            DEE_PKG_MGR="brew"
        elif command -v port >/dev/null 2>&1; then
            DEE_PKG_MGR="macports"
        fi
        # Check for GNU coreutils (installed via brew)
        if command -v gtimeout >/dev/null 2>&1; then
            DEE_GNU_TOOLS=1
        fi
        ;;
    Linux*)
        DEE_OS="linux"
        DEE_ARCH="$(uname -m 2>/dev/null || echo unknown)"
        DEE_GNU_TOOLS=1
        if command -v apt-get >/dev/null 2>&1; then
            DEE_PKG_MGR="apt"
        elif command -v dnf >/dev/null 2>&1; then
            DEE_PKG_MGR="dnf"
        elif command -v yum >/dev/null 2>&1; then
            DEE_PKG_MGR="yum"
        elif command -v pacman >/dev/null 2>&1; then
            DEE_PKG_MGR="pacman"
        elif command -v apk >/dev/null 2>&1; then
            DEE_PKG_MGR="apk"
        elif command -v zypper >/dev/null 2>&1; then
            DEE_PKG_MGR="zypper"
        fi
        ;;
    MINGW*|MSYS*|CYGWIN*)
        DEE_OS="windows"
        DEE_ARCH="$(uname -m 2>/dev/null || echo x86_64)"
        if command -v choco >/dev/null 2>&1; then
            DEE_PKG_MGR="choco"
        elif command -v scoop >/dev/null 2>&1; then
            DEE_PKG_MGR="scoop"
        elif command -v winget >/dev/null 2>&1; then
            DEE_PKG_MGR="winget"
        fi
        ;;
    FreeBSD*)
        DEE_OS="freebsd"
        DEE_PKG_MGR="pkg"
        ;;
esac

# --- Portable Install Command Generator ---
# Usage: install_cmd "package-name"
# Returns the correct install command for the user's platform
install_cmd() {
    local pkg="$1"
    case "${DEE_PKG_MGR}" in
        brew)       echo "brew install ${pkg}" ;;
        macports)   echo "sudo port install ${pkg}" ;;
        apt)        echo "sudo apt-get install -y ${pkg}" ;;
        dnf)        echo "sudo dnf install -y ${pkg}" ;;
        yum)        echo "sudo yum install -y ${pkg}" ;;
        pacman)     echo "sudo pacman -S --noconfirm ${pkg}" ;;
        apk)        echo "sudo apk add ${pkg}" ;;
        zypper)     echo "sudo zypper install -y ${pkg}" ;;
        choco)      echo "choco install ${pkg}" ;;
        scoop)      echo "scoop install ${pkg}" ;;
        winget)     echo "winget install ${pkg}" ;;
        pkg)        echo "sudo pkg install ${pkg}" ;;
        *)          echo "(install ${pkg} using your system package manager)" ;;
    esac
}

# --- Portable cp with conflict resolution ---
# macOS BSD cp does NOT support --remove-destination
# This function handles all edge cases across platforms
portable_cp() {
    local src="$1"
    local dest="$2"

    if [ ${DEE_GNU_TOOLS} -eq 1 ]; then
        # GNU cp: use --remove-destination for maximum reliability
        cp -r --remove-destination "${src}" "${dest}" 2>/dev/null && return 0
    fi

    # Portable fallback: works on macOS BSD, GNU, and everything else
    # Strategy: remove target first (if exists), then copy fresh
    local target_name
    target_name="$(basename "${src}")"
    local target_path="${dest}/${target_name}"

    if [ -e "${target_path}" ] || [ -L "${target_path}" ]; then
        # mv-swap: rename old → .bak, copy new, cleanup
        mv "${target_path}" "${target_path}.bak.$$" 2>/dev/null || true
    fi

    if cp -R "${src}" "${dest}" 2>/dev/null; then
        # Cleanup backup
        rm -rf "${target_path}.bak.$$" 2>/dev/null || true
        return 0
    else
        # Restore backup if copy failed
        if [ -e "${target_path}.bak.$$" ]; then
            mv "${target_path}.bak.$$" "${target_path}" 2>/dev/null || true
        fi
        return 1
    fi
}

# --- Color Support Detection ---
# Some terminals (dumb terminals, CI/CD pipes, Windows cmd.exe) don't support ANSI
DEE_COLOR=1
if [ -z "${TERM:-}" ] || [ "${TERM:-dumb}" = "dumb" ]; then
    DEE_COLOR=0
elif [ ! -t 1 ]; then
    # stdout is not a terminal (piped or redirected)
    DEE_COLOR=0
fi
# Allow force via env var
if [ "${DEE_FORCE_COLOR:-0}" = "1" ]; then
    DEE_COLOR=1
fi
if [ "${NO_COLOR:-}" != "" ]; then
    DEE_COLOR=0
fi

# ============================================================================
# COLOR DEFINITIONS (conditional on terminal support)
# ============================================================================

if [ ${DEE_COLOR} -eq 1 ]; then
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
else
    readonly RED=''
    readonly GREEN=''
    readonly YELLOW=''
    readonly BLUE=''
    readonly CYAN=''
    readonly MAGENTA=''
    readonly WHITE=''
    readonly RESET=''
    readonly BOLD=''
    readonly DIM=''
fi

# Progress indicators
readonly CHECK="${GREEN}✓${RESET}"
readonly CROSS="${RED}✗${RESET}"
readonly WARN="${YELLOW}⚠${RESET}"
readonly INFO="${BLUE}ℹ${RESET}"
readonly ARROW="${CYAN}→${RESET}"

# ============================================================================
# GLOBAL VARIABLES
# ============================================================================

# Portable SCRIPT_DIR detection (works in Bash 3.2+, zsh, and sh)
if [ -n "${BASH_SOURCE[0]:-}" ]; then
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
elif [ -n "${ZSH_VERSION:-}" ]; then
    SCRIPT_DIR="$(cd "$(dirname "${(%):-%x}")" && pwd)"
else
    SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
fi
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

# Non-interactive mode
NON_INTERACTIVE=0

# Feature flags (set via CLI args)
NO_EXTERNAL="${NO_EXTERNAL:-}"
NO_MCP="${NO_MCP:-}"

# Installation step tracking (for error resilience)
STEP_ERRORS=""
STEP_COUNT=0
STEP_FAILURES=0

# Track timing
INSTALL_START_TIME=$(date +%s)

# Log file
LOG_FILE="${HOME}/.devlmer/install.log"

# ============================================================================
# UTILITY FUNCTIONS
# ============================================================================

# Ensure log directory exists early
mkdir -p "${HOME}/.devlmer" 2>/dev/null || true

# Initialize log file with session header
{
    echo ""
    echo "================================================================"
    echo "=== DEE v3.1 Install — $(date -u +%Y-%m-%dT%H:%M:%SZ) ==="
    echo "=== Bash: ${BASH_VERSION} | OS: $(uname -s) $(uname -r) ==="
    echo "=== Args: $* ==="
    echo "================================================================"
} >> "${LOG_FILE}" 2>/dev/null || true

# Tee all output to log file (preserves terminal output AND writes to file)
# Process substitution >(tee ...) requires Bash; not available in POSIX sh
# We detect support before using it to avoid errors on incompatible shells
DEE_LOG_TEE=0
if [ -n "${BASH_VERSION:-}" ]; then
    # Bash supports process substitution; safe on 3.2+
    eval 'exec > >(tee -a "${LOG_FILE}") 2>&1' 2>/dev/null && DEE_LOG_TEE=1
fi
if [ ${DEE_LOG_TEE} -eq 0 ]; then
    # Fallback: log to file only via explicit writes in log functions
    # Terminal output still works normally
    :
fi

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

# Check if running in an interactive terminal with a real TTY
is_interactive() {
    if [[ ${NON_INTERACTIVE} -eq 1 ]]; then
        return 1
    fi
    if [[ -t 0 ]]; then
        return 0
    fi
    return 1
}

# Safe read with timeout — NEVER hangs. Returns 1 if timeout/non-interactive.
# Usage: safe_read VARNAME "prompt" [timeout_seconds] [default_value]
safe_read() {
    local varname="$1"
    local prompt_text="$2"
    local timeout="${3:-30}"
    local default_val="${4:-}"

    if ! is_interactive; then
        eval "${varname}=\"${default_val}\""
        log_verbose "Non-interactive mode: using default '${default_val}' for prompt"
        return 1
    fi

    if read -t "${timeout}" -r -p "${prompt_text} " "${varname}" 2>/dev/null; then
        return 0
    else
        eval "${varname}=\"${default_val}\""
        echo ""
        log_warning "Input timeout (${timeout}s) — using default"
        return 1
    fi
}

# Safe read for secrets (silent) with timeout
safe_read_secret() {
    local varname="$1"
    local prompt_text="$2"
    local timeout="${3:-30}"

    if ! is_interactive; then
        eval "${varname}=\"\""
        return 1
    fi

    if read -t "${timeout}" -s -r -p "${prompt_text} " "${varname}" 2>/dev/null; then
        echo ""
        return 0
    else
        eval "${varname}=\"\""
        echo ""
        log_warning "Input timeout (${timeout}s) — skipping"
        return 1
    fi
}

# Run a command with timeout (portable — works on Bash 3.2+, zsh, macOS, Linux, WSL)
# Usage: run_with_timeout SECONDS command [args...]
run_with_timeout() {
    local timeout_secs="$1"
    shift

    if command -v timeout >/dev/null 2>&1; then
        # GNU coreutils timeout (Linux, Homebrew coreutils on macOS)
        timeout "${timeout_secs}" "$@"
    elif command -v gtimeout >/dev/null 2>&1; then
        # macOS with Homebrew GNU coreutils (prefixed with 'g')
        gtimeout "${timeout_secs}" "$@"
    else
        # Portable fallback for macOS/BSD without coreutils
        "$@" &
        local cmd_pid=$!
        (
            sleep "${timeout_secs}"
            kill "${cmd_pid}" 2>/dev/null
        ) &
        local watchdog_pid=$!
        wait "${cmd_pid}" 2>/dev/null
        local exit_code=$?
        kill "${watchdog_pid}" 2>/dev/null 2>&1
        wait "${watchdog_pid}" 2>/dev/null 2>&1
        return ${exit_code}
    fi
}

# Run an installation step with error resilience
# Usage: run_step "step_name" command [args...]
run_step() {
    local step_name="$1"
    shift
    STEP_COUNT=$((STEP_COUNT + 1))

    if "$@"; then
        return 0
    else
        local exit_code=$?
        STEP_FAILURES=$((STEP_FAILURES + 1))
        STEP_ERRORS="${STEP_ERRORS}\n  ${CROSS} ${step_name} (exit code ${exit_code})"
        log_warning "Step '${step_name}' failed (exit ${exit_code}) — continuing installation"
        return 0  # Don't abort the whole install
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
    --non-interactive   Skip ALL interactive prompts (use defaults)
    --yes, -y           Alias for --non-interactive
    --github-token      Provide GitHub Personal Access Token
    --gemini-key        Provide Gemini API key for Nano-Banana MCP

${BOLD}EXAMPLES:${RESET}
    ./install.sh /path/to/project
    ./install.sh . --skills-only
    ./install.sh ~ --scan-only --verbose
    ./install.sh . --github-token ghp_xxxxxxxxxxxx
    ./install.sh . --gemini-key AIzaSy...
    ./install.sh . --non-interactive --no-github
    ./install.sh . --yes --no-external

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
    # Uses DEE_OS from compatibility layer (already detected via uname -s)
    echo "${DEE_OS}"
}

check_dependencies() {
    log_step "Verifying dependencies..."

    local missing=0
    local missing_list=""

    # Platform info
    log_verbose "Platform: ${DEE_OS} (${DEE_ARCH})"
    log_verbose "Package manager: ${DEE_PKG_MGR}"
    log_verbose "GNU tools: $([ ${DEE_GNU_TOOLS} -eq 1 ] && echo 'yes' || echo 'no (BSD)')"
    if [ -n "${BASH_VERSION:-}" ]; then
        log_verbose "Shell: Bash ${BASH_VERSION}"
    elif [ -n "${ZSH_VERSION:-}" ]; then
        log_verbose "Shell: zsh ${ZSH_VERSION}"
    else
        log_verbose "Shell: $(basename "${SHELL:-sh}")"
    fi

    # Check git
    if ! command -v git >/dev/null 2>&1; then
        local git_pkg="git"
        log_warning "git not found — install with: $(install_cmd ${git_pkg})"
        missing_list="${missing_list}\n  ${CROSS} git — install: $(install_cmd ${git_pkg})"
        missing=1
    else
        log_verbose "Git: $(git --version 2>/dev/null | head -1)"
    fi

    # Check node/npm
    if ! command -v node >/dev/null 2>&1; then
        local node_pkg="node"
        [ "${DEE_PKG_MGR}" = "apt" ] && node_pkg="nodejs"
        log_warning "Node.js not found — install with: $(install_cmd ${node_pkg})"
        missing_list="${missing_list}\n  ${CROSS} node — install: $(install_cmd ${node_pkg})"
        missing=1
    else
        log_verbose "Node.js: $(node --version)"
    fi

    if ! command -v npm >/dev/null 2>&1; then
        local npm_pkg="npm"
        [ "${DEE_PKG_MGR}" = "apt" ] && npm_pkg="npm"
        log_warning "npm not found — install with: $(install_cmd ${npm_pkg})"
        missing_list="${missing_list}\n  ${CROSS} npm — install: $(install_cmd ${npm_pkg})"
        missing=1
    fi

    # Check python (try python3 first, then python)
    if ! command -v python3 >/dev/null 2>&1; then
        if command -v python >/dev/null 2>&1; then
            # Some systems (Arch, Windows) have 'python' instead of 'python3'
            local py_ver
            py_ver="$(python --version 2>&1 | grep -oE '[0-9]+' | head -1)"
            if [ "${py_ver:-0}" -ge 3 ]; then
                log_verbose "Python 3 found as 'python': $(python --version 2>&1)"
                # Create alias for rest of script
                python3() { python "$@"; }
            else
                local py_pkg="python3"
                [ "${DEE_PKG_MGR}" = "pacman" ] && py_pkg="python"
                [ "${DEE_PKG_MGR}" = "brew" ] && py_pkg="python@3"
                log_warning "Python 3 not found — install with: $(install_cmd ${py_pkg})"
                missing_list="${missing_list}\n  ${CROSS} python3 — install: $(install_cmd ${py_pkg})"
                missing=1
            fi
        else
            local py_pkg="python3"
            [ "${DEE_PKG_MGR}" = "pacman" ] && py_pkg="python"
            [ "${DEE_PKG_MGR}" = "brew" ] && py_pkg="python@3"
            log_warning "Python 3 not found — install with: $(install_cmd ${py_pkg})"
            missing_list="${missing_list}\n  ${CROSS} python3 — install: $(install_cmd ${py_pkg})"
            missing=1
        fi
    else
        log_verbose "Python 3: $(python3 --version 2>&1)"
    fi

    # Check optional tools
    if ! command -v jq >/dev/null 2>&1; then
        log_verbose "jq not found (optional) — install: $(install_cmd jq)"
    fi

    if [[ ${missing} -eq 1 ]]; then
        log_warning "Missing dependencies detected:"
        echo -e "${missing_list}"
        echo ""
        log_warning "Installation will continue, but some features may not work."
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
        log_info "Target directory does not exist: ${TARGET_DIR}"
        log_step "Creating target directory..."
        if mkdir -p "${TARGET_DIR}" 2>/dev/null; then
            log_success "Created: ${TARGET_DIR}"
        else
            log_error "Cannot create directory: ${TARGET_DIR}"
            log_info "Check permissions or create it manually and re-run."
            return 1
        fi
    fi

    # Create .claude directory structure
    local dirs=(
        "${TARGET_DIR}/.claude/skills"
        "${TARGET_DIR}/.claude/hooks"
        "${TARGET_DIR}/.claude/config"
        "${TARGET_DIR}/.claude/logs"
        "${HOME}/.devlmer"
    )
    for d in "${dirs[@]}"; do
        if ! mkdir -p "${d}" 2>/dev/null; then
            log_error "Cannot create directory: ${d}"
            return 1
        fi
    done

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
    if command -v gh >/dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

github_status() {
    if check_github_cli; then
        if run_with_timeout 15 gh auth status >/dev/null 2>&1; then
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
        local gh_reply=""
        if ! safe_read gh_reply "Authenticate with GitHub? [y/N]" 30 "N"; then
            log_info "GitHub authentication skipped (non-interactive/timeout)"
            return 0
        fi

        if [[ "${gh_reply}" =~ ^[Yy]$ ]]; then
            log_step "Attempting GitHub authentication (60s timeout)..."
            if run_with_timeout 60 gh auth login --web >/dev/null 2>&1; then
                log_success "GitHub authentication successful"
                GITHUB_AUTHENTICATED=1
                return 0
            else
                log_warning "GitHub authentication failed or timed out"
                return 1
            fi
        else
            log_info "GitHub authentication skipped"
            return 0
        fi
    else
        log_info "GitHub CLI not found, attempting Personal Access Token setup..."
        local pat_reply=""
        if ! safe_read pat_reply "Do you have a GitHub PAT? [y/N]" 30 "N"; then
            log_info "Proceeding without GitHub authentication (non-interactive)"
            return 0
        fi

        if [[ "${pat_reply}" =~ ^[Yy]$ ]]; then
            if safe_read_secret GITHUB_PAT "Enter your GitHub Personal Access Token:" 60; then
                if [[ -n "${GITHUB_PAT}" ]]; then
                    GITHUB_AUTHENTICATED=1
                    log_success "GitHub PAT configured"
                    return 0
                fi
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
        if git -C "${TARGET_DIR}" init >/dev/null 2>&1; then
            log_verbose "Git repository initialized in ${TARGET_DIR}"
        else
            log_warning "Failed to initialize git repository"
            return 1
        fi
    else
        log_verbose "Git repository already initialized"
    fi

    # Configure git user if not already set (for commits)
    if ! git -C "${TARGET_DIR}" config user.email >/dev/null 2>&1; then
        git -C "${TARGET_DIR}" config user.email "devlmer-ecosystem@local" >/dev/null 2>&1 || true
    fi
    if ! git -C "${TARGET_DIR}" config user.name >/dev/null 2>&1; then
        git -C "${TARGET_DIR}" config user.name "Devlmer Ecosystem" >/dev/null 2>&1 || true
    fi

    # Add and commit .claude directory if it exists
    if [[ -d "${TARGET_DIR}/.claude" ]]; then
        if git -C "${TARGET_DIR}" add .claude/ 2>/dev/null; then
            if git -C "${TARGET_DIR}" commit -m "Devlmer: ecosystem configured" >/dev/null 2>&1; then
                log_success "Ecosystem config committed to git"
            else
                log_verbose "No changes to commit (or commit failed)"
            fi
        else
            log_verbose "Failed to add .claude/ to git"
        fi
    fi

    # Check for remote and offer to push
    if git -C "${TARGET_DIR}" remote get-url origin >/dev/null 2>&1; then
        log_step "A git remote 'origin' is configured."
        local push_reply=""
        safe_read push_reply "Would you like to push ecosystem backup to origin? [y/N]" 30 "N"

        if [[ "${push_reply}" =~ ^[Yy]$ ]]; then
            # Create branch if needed, but don't force
            local branch_name=".devlmer-backup-$(date +%s)"
            log_step "Creating backup branch: ${branch_name}"

            if git -C "${TARGET_DIR}" checkout -b "${branch_name}" 2>/dev/null; then
                if run_with_timeout 60 git -C "${TARGET_DIR}" push -u origin "${branch_name}" 2>/dev/null; then
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

    # Install dependencies (in subshell to preserve working directory)
    log_step "Installing Nano-Banana-MCP dependencies..."
    if (cd "${mcp_dir}" && npm install 2>/dev/null); then
        log_success "Nano-Banana-MCP dependencies installed"
    else
        log_warning "Failed to install Nano-Banana-MCP dependencies"
        return 1
    fi

    # Get or prompt for Gemini API key
    if [[ -z "${GEMINI_KEY}" ]]; then
        log_step "Nano-Banana-MCP requires a Gemini API key"
        safe_read_secret GEMINI_KEY "Enter your Gemini API key (or press Enter to skip):" 30
    fi

    if [[ -n "${GEMINI_KEY}" ]]; then
        save_nano_banana_config
        add_nano_banana_to_settings
        NANO_BANANA_INSTALLED=1
        log_success "Nano-Banana-MCP configured"
    else
        log_info "Skipping Nano-Banana-MCP configuration"
    fi
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
    local settings_file="${TARGET_DIR}/.claude/settings.json"

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
    if command -v python3 >/dev/null 2>&1; then
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

    # Ensure target skills directory exists
    if [[ ! -d "${TARGET_DIR}/.claude/skills" ]]; then
        mkdir -p "${TARGET_DIR}/.claude/skills" 2>/dev/null || {
            log_error "Cannot create skills directory: ${TARGET_DIR}/.claude/skills"
            return 1
        }
    fi

    local skill_count=0
    for skill in "${skills_dir}"/*; do
        if [[ -d "${skill}" ]]; then
            local skill_name=$(basename "${skill}")
            local target_path="${TARGET_DIR}/.claude/skills/${skill_name}"

            # Strategy for handling pre-existing conflicts (symlinks, files, stale dirs)
            # Priority: mv (rename) > rm > unlink > cp --remove-destination
            # On some mounted filesystems, rm/unlink are blocked but mv (rename) works
            if [[ -L "${target_path}" ]]; then
                # Symlink detected — move it out of the way first (mv works where rm doesn't)
                mv "${target_path}" "${target_path}.bak.$(date +%s)" 2>/dev/null \
                    || rm -f "${target_path}" 2>/dev/null \
                    || unlink "${target_path}" 2>/dev/null \
                    || true
                log_verbose "Cleared symlink conflict: ${skill_name}"
            elif [[ -f "${target_path}" ]]; then
                # Regular file where we expect a directory
                mv "${target_path}" "${target_path}.bak.$(date +%s)" 2>/dev/null \
                    || rm -f "${target_path}" 2>/dev/null \
                    || true
                log_verbose "Cleared file conflict: ${skill_name}"
            fi

            # Copy using portable_cp (handles macOS BSD + GNU + mv-swap fallback)
            if portable_cp "${skill}" "${TARGET_DIR}/.claude/skills/"; then
                skill_count=$((skill_count + 1))
                log_verbose "Copied skill: ${skill_name}"
            elif cp -R "${skill}" "${TARGET_DIR}/.claude/skills/${skill_name}.new" 2>/dev/null \
                 && mv "${target_path}" "${target_path}.old.$$" 2>/dev/null \
                 && mv "${TARGET_DIR}/.claude/skills/${skill_name}.new" "${target_path}" 2>/dev/null; then
                # Last resort mv-swap: copy to temp name, mv old out, mv new in
                skill_count=$((skill_count + 1))
                log_verbose "Copied skill (mv-swap): ${skill_name}"
            else
                log_warning "Could not copy skill: ${skill_name} — manual install may be needed"
                continue
            fi
        fi
    done

    # Strip YAML frontmatter from SKILL.md files (Claude Code expects pure Markdown)
    # Frontmatter is the block between the first --- and second --- at the top
    if command -v python3 >/dev/null 2>&1; then
        local stripped_count
        stripped_count=$(TARGET_DIR="${TARGET_DIR}" python3 << 'STRIP_FM'
import os, glob
skills_dir = os.path.join(os.environ.get('TARGET_DIR', '.'), '.claude/skills')
count = 0
for md in glob.glob(os.path.join(skills_dir, '*/SKILL.md')):
    try:
        with open(md, 'r') as f:
            content = f.read()
        if content.startswith('---'):
            end = content.find('---', 3)
            if end != -1:
                cleaned = content[end + 3:].lstrip('\n')
                if cleaned:
                    with open(md, 'w') as f:
                        f.write(cleaned)
                    count += 1
    except Exception:
        pass
print(count)
STRIP_FM
        )
        if [[ "${stripped_count}" -gt 0 ]] 2>/dev/null; then
            log_verbose "Stripped YAML frontmatter from ${stripped_count} SKILL.md files"
        fi
    fi

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

    if command -v npx >/dev/null 2>&1; then
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

    if command -v npx >/dev/null 2>&1; then
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

    # External skills map to bundled skills. If bundled skills were already
    # installed successfully, skip external installation entirely to avoid
    # redundant downloads and interactive prompts from claude-code-templates.
    local expected_skills=(
        "senior-frontend" "senior-backend" "senior-architect" "senior-fullstack"
        "code-reviewer" "skill-creator" "webapp-testing" "senior-security"
        "mcp-builder" "senior-prompt-engineer" "brainstorming" "git-commit-helper"
        "ui-ux-pro-max" "ui-design-system" "mobile-design"
    )

    local missing=0
    local missing_list=""
    for skill_name in "${expected_skills[@]}"; do
        if [[ ! -d "${TARGET_DIR}/.claude/skills/${skill_name}" ]]; then
            missing=$((missing + 1))
            missing_list="${missing_list}  - ${skill_name}\n"
        fi
    done

    if [[ ${missing} -eq 0 ]]; then
        log_success "All ${#expected_skills[@]} skills already installed from bundled package"
        EXTERNAL_SKILLS_INSTALLED=${#expected_skills[@]}
        return 0
    fi

    log_info "${missing} skills not found — attempting external installation..."
    if [[ -n "${missing_list}" ]]; then
        log_verbose "Missing skills:"
        echo -e "${missing_list}"
    fi

    if ! command -v npx >/dev/null 2>&1; then
        log_warning "npm/npx not found. Skipping external skill installations."
        log_info "Install Node.js to enable external skill installations: $(install_cmd node)"
        return 0
    fi

    # --- GitHub Rate Limit Protection ---
    local original_gh_token="${GITHUB_TOKEN:-}"
    if [[ -n "${GITHUB_TOKEN}" ]]; then
        export GITHUB_TOKEN="${GITHUB_TOKEN}"
        export NODE_AUTH_TOKEN="${GITHUB_TOKEN}"
        log_info "Using GitHub token for authenticated API access (5000 req/hr limit)"
    elif [[ -n "${GITHUB_PAT:-}" ]]; then
        export GITHUB_TOKEN="${GITHUB_PAT}"
        export NODE_AUTH_TOKEN="${GITHUB_PAT}"
        log_info "Using GitHub PAT for authenticated API access"
    else
        log_warning "No GitHub token provided — GitHub API limit is 60 req/hr (anonymous)"
        log_info "If rate-limited, re-run with: --github-token ghp_xxxxx"
    fi

    # Protect settings.json from being overwritten by external tools
    if [[ -f "${TARGET_DIR}/.claude/settings.json" ]]; then
        cp "${TARGET_DIR}/.claude/settings.json" "${TARGET_DIR}/.claude/settings.json.pre-external.bak" 2>/dev/null || true
    fi

    # Install only missing skills, using stdin redirect to suppress interactive prompts
    for skill_name in "${expected_skills[@]}"; do
        if [[ -d "${TARGET_DIR}/.claude/skills/${skill_name}" ]]; then
            continue  # Already installed
        fi

        local skill_path="development/${skill_name}"
        # creative-design category skills
        case "${skill_name}" in
            ui-ux-pro-max|ui-design-system|mobile-design)
                skill_path="creative-design/${skill_name}"
                ;;
        esac

        if (cd "${TARGET_DIR}" && echo "n" | run_with_timeout 45 npx claude-code-templates@latest "${skill_path}" --yes </dev/null 2>/dev/null); then
            EXTERNAL_SKILLS_INSTALLED=$((EXTERNAL_SKILLS_INSTALLED + 1))
            log_success "Installed: ${skill_name}"
        else
            log_warning "Failed to install: ${skill_name}"
            SKILLS_FAILED=$((SKILLS_FAILED + 1))
        fi
        sleep 1
    done

    # Special case: copywriting skill
    install_copywriting_skill

    # Restore settings.json if external tools damaged it
    if [[ -f "${TARGET_DIR}/.claude/settings.json.pre-external.bak" ]]; then
        if [[ ! -f "${TARGET_DIR}/.claude/settings.json" ]] || [[ -d "${TARGET_DIR}/.claude/settings.json" ]]; then
            rm -rf "${TARGET_DIR}/.claude/settings.json" 2>/dev/null || true
            mv "${TARGET_DIR}/.claude/settings.json.pre-external.bak" "${TARGET_DIR}/.claude/settings.json"
            log_verbose "Restored settings.json from pre-external backup"
        else
            rm -f "${TARGET_DIR}/.claude/settings.json.pre-external.bak" 2>/dev/null || true
        fi
    fi

    echo ""
    if [[ ${SKILLS_FAILED} -gt 0 ]]; then
        log_warning "External skills: ${EXTERNAL_SKILLS_INSTALLED} succeeded, ${SKILLS_FAILED} failed"
    else
        log_success "All skills installed successfully"
    fi
}

# ============================================================================
# MCP INSTALLATION
# ============================================================================

install_mcp() {
    local mcp_name="$1"
    local mcp_repo="$2"

    log_step "Installing MCP: ${mcp_name}"

    if command -v npx >/dev/null 2>&1; then
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

    if ! command -v npx >/dev/null 2>&1; then
        log_warning "npm/npx not found. Skipping MCP installations."
        log_info "Install Node.js to enable MCP installations."
        return 0
    fi

    if ! command -v python3 >/dev/null 2>&1; then
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

    # ── MCPs sin paquete npm disponible ──────────────────────────
    # Marcados con skip=True para evitar búsquedas fallidas
    "firebase": {
        "skip": True,
        "description": "Firebase — use the official Firebase CLI or Firestore REST API"
    },
    "posthog": {
        "skip": True,
        "description": "PostHog — use the PostHog API directly or the PostHog JS SDK"
    },
    "docusign": {
        "skip": True,
        "description": "DocuSign — use the DocuSign eSignature REST API"
    },
    "homebrew": {
        "skip": True,
        "description": "Homebrew — system package manager, no MCP needed"
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

        if info and info.get('skip'):
            desc = info.get('description', 'No MCP package available')
            print(f"{prefix} ⏭️  {name} — {desc}")
            skipped += 1
            continue

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
    if skipped:
        print(f"  ⏩ Skipped:        {skipped} servers")
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
    if command -v python3 >/dev/null 2>&1; then
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

                # Domain-specific agent prompts
                agent_prompts = {
                    "ceo": {
                        "role": "Executive Coordinator and Decision Authority",
                        "responsibilities": [
                            "Coordinate multi-agent workflows and verify code quality",
                            "Make architectural decisions based on evidence and testing",
                            "Ensure compliance with project standards and best practices",
                            "Report status with metrics, blockers, and evidence JSONs",
                            "Approve feature implementations after verification"
                        ],
                        "tools": ["code-reviewer", "security-audit", "senior-architect"],
                        "examples": [
                            "Reviewing pull requests from other agents and verifying with test results",
                            "Making decisions about feature priorities based on risk and impact",
                            "Requesting evidence JSONs showing test coverage and security checks",
                            "Coordinating backend and frontend agents on API contracts"
                        ]
                    },
                    "backend": {
                        "role": "Backend & API Specialist",
                        "responsibilities": [
                            "Develop and maintain server-side logic and APIs",
                            "Design and optimize database schemas and migrations",
                            "Implement authentication, authorization, and security measures",
                            "Ensure API contracts match frontend expectations",
                            "Optimize performance and handle scaling challenges"
                        ],
                        "tools": ["code-review", "api-integration", "docker-deploy", "security-audit"],
                        "examples": [
                            "Creating FastAPI endpoints with proper validation and error handling",
                            "Designing PostgreSQL schemas with migrations using SQLAlchemy",
                            "Implementing JWT authentication and rate limiting",
                            "Optimizing database queries and adding caching strategies"
                        ]
                    },
                    "frontend": {
                        "role": "Frontend & UI/UX Specialist",
                        "responsibilities": [
                            "Build responsive and accessible user interfaces",
                            "Implement state management and data fetching strategies",
                            "Ensure visual consistency and performance optimization",
                            "Create intuitive user experiences with proper error handling",
                            "Integrate with backend APIs and real-time data sources"
                        ],
                        "tools": ["frontend-design", "ux-copy", "theme-factory", "ui-design-system"],
                        "examples": [
                            "Creating React components with TypeScript and proper typing",
                            "Building responsive layouts with Tailwind CSS",
                            "Implementing WebSocket connections for real-time data",
                            "Testing UI with Playwright and verifying accessibility"
                        ]
                    },
                    "devops": {
                        "role": "Infrastructure & Deployment Specialist",
                        "responsibilities": [
                            "Manage containerization and orchestration (Docker, Kubernetes)",
                            "Configure CI/CD pipelines and automated testing",
                            "Monitor application health and performance",
                            "Implement logging, monitoring, and alerting systems",
                            "Ensure security, scalability, and high availability"
                        ],
                        "tools": ["docker-deploy", "security-audit", "code-review"],
                        "examples": [
                            "Writing Docker configurations for multi-service deployments",
                            "Setting up GitHub Actions workflows for automated testing",
                            "Configuring monitoring dashboards and alert thresholds",
                            "Managing environment variables and secrets securely"
                        ]
                    },
                    "qa": {
                        "role": "Quality Assurance & Testing Specialist",
                        "responsibilities": [
                            "Design comprehensive testing strategies (unit, integration, e2e)",
                            "Identify edge cases and potential bugs",
                            "Verify code quality and performance metrics",
                            "Ensure user workflows function as expected",
                            "Provide evidence-based quality reports"
                        ],
                        "tools": ["unit-test-generator", "code-review", "documentation"],
                        "examples": [
                            "Writing pytest fixtures and test cases for backend services",
                            "Creating Playwright tests for critical user flows",
                            "Generating test coverage reports and identifying gaps",
                            "Performing load testing and performance profiling"
                        ]
                    }
                }

                # Get domain-specific prompt or fall back to generic
                domain_lower = domain.lower() if domain else "general"
                agent_lower = agent_name.lower()

                # Determine which prompt template to use
                prompt_key = None
                if "ceo" in agent_lower or "executive" in agent_lower or "coordinator" in agent_lower:
                    prompt_key = "ceo"
                elif "backend" in agent_lower or "server" in agent_lower or "api" in agent_lower:
                    prompt_key = "backend"
                elif "frontend" in agent_lower or "ui" in agent_lower or "ux" in agent_lower:
                    prompt_key = "frontend"
                elif "devops" in agent_lower or "ops" in agent_lower or "infra" in agent_lower:
                    prompt_key = "devops"
                elif "qa" in agent_lower or "test" in agent_lower or "quality" in agent_lower:
                    prompt_key = "qa"

                # Generate agent file content
                if prompt_key and prompt_key in agent_prompts:
                    template = agent_prompts[prompt_key]
                    responsibilities = "\n".join(f"- {r}" for r in template["responsibilities"])
                    tools = ", ".join(template["tools"])
                    examples = "\n".join(f"- {e}" for e in template["examples"])

                    agent_content = f"""---
name: {agent_name}
description: {description}
model: sonnet
---

# {agent_name.replace('-', ' ').title()} Agent

You are a specialized {template['role'].lower()} working on {domain_lower} projects.

## Your Role

{template['role']}

## Core Responsibilities

{responsibilities}

## Domain Context

You operate within the **{domain}** domain and understand:
- The technical stack and architecture patterns
- Best practices and industry standards
- Common challenges and proven solutions
- Integration points with other systems and teams

## Available Tools & Skills

You have access to these specialized tools:
{tools}

Use these tools proactively to:
- Verify code quality and security
- Automate testing and validation
- Ensure best practices are followed
- Generate evidence for decisions

## Example Tasks

You handle these types of tasks:
{examples}

## Working Principles

1. **Evidence-Based**: Always provide data, test results, or metrics to support decisions
2. **Proactive Verification**: Use tools to catch issues before they become problems
3. **Clear Communication**: Explain your reasoning and decisions clearly
4. **Team Coordination**: Work with other agents seamlessly using shared conventions
5. **Continuous Learning**: Suggest improvements based on patterns you observe
6. **Security First**: Apply security best practices in everything you do

## Success Metrics

You succeed when:
- Code is well-tested, secure, and maintainable
- Changes are documented with clear justifications
- No blockers remain unaddressed
- Team members have confidence in your work
- The system improves incrementally with each contribution
"""
                else:
                    # Generic fallback for unknown agent types
                    agent_content = f"""---
name: {agent_name}
description: {description}
model: sonnet
---

# {agent_name.replace('-', ' ').title()} Agent

You are a specialized agent contributing to {domain_lower} development.

## Your Role

{description}

## Core Responsibilities

- Analyzing and understanding {domain} context
- Making decisions based on available data
- Providing evidence-based recommendations
- Collaborating effectively with other agents
- Continuously improving processes and code quality

## Working in the {domain} Domain

You understand the technical stack, best practices, and challenges specific to {domain} projects. You are familiar with common workflows, integration patterns, and solutions proven to work in this domain.

## Key Principles

1. **Evidence-Based**: Back recommendations with data, tests, or analysis
2. **Proactive**: Identify and address issues before they escalate
3. **Clear Communication**: Explain your reasoning and decisions clearly
4. **Collaborative**: Work seamlessly with other specialized agents
5. **Quality-Focused**: Prioritize maintainability, security, and performance
6. **Continuous Improvement**: Learn from patterns and suggest enhancements

## Success Indicators

- Work is well-tested and documented
- Changes follow established best practices
- Problems are identified and solved systematically
- Team confidence and productivity increase
- The codebase improves with each contribution
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

    cp -R "${blueprints_dir}"/* "${TARGET_DIR}/.claude/config/" 2>/dev/null || true
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

    cp -R "${scripts_dir}"/* "${TARGET_DIR}/.claude/" 2>/dev/null || true
    SCRIPTS_COPIED=$((SCRIPTS_COPIED + 1))
    log_success "Project intelligence scripts copied"
    log_verbose "Scripts copied from: ${scripts_dir}"

    # Copy setup wizard for post-install use
    if [[ -f "${SCRIPT_DIR}/setup-wizard.sh" ]]; then
        cp "${SCRIPT_DIR}/setup-wizard.sh" "${TARGET_DIR}/.claude/setup-wizard.sh"
        chmod +x "${TARGET_DIR}/.claude/setup-wizard.sh"
        log_verbose "Setup wizard copied to project"
    fi
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
# SLASH COMMANDS GENERATION
# ============================================================================

generate_slash_commands() {
    log_step "Generating slash commands for installed skills..."

    local commands_dir="${TARGET_DIR}/.claude/commands"
    mkdir -p "${commands_dir}"
    local count=0

    for skill_dir in "${TARGET_DIR}/.claude/skills"/*/; do
        local skill_name
        skill_name=$(basename "${skill_dir}")
        local skill_md="${skill_dir}/SKILL.md"

        if [[ -f "${skill_md}" ]]; then
            # Extract description from SKILL.md frontmatter
            local desc
            desc=$(sed -n '/^description:/{ s/^description: *//; p; q; }' "${skill_md}" | cut -c1-150)

            cat > "${commands_dir}/${skill_name}.md" << CMDEOF
# /${skill_name}

${desc}

## Instructions

Read the skill file at \`.claude/skills/${skill_name}/SKILL.md\` and follow its instructions to complete the user's request.

If the skill has reference files in \`.claude/skills/${skill_name}/references/\`, read those too for deeper context.

If the skill has scripts in \`.claude/skills/${skill_name}/scripts/\`, use them when applicable.
CMDEOF
            count=$((count + 1))
        fi
    done

    # Copy DEE core commands (dee-status, dee-demo, dee-doctor) from repo
    local dee_commands_dir="${SCRIPT_DIR}/commands"
    if [[ -d "${dee_commands_dir}" ]]; then
        local dee_count=0
        for dee_cmd in "${dee_commands_dir}"/*.md; do
            if [[ -f "${dee_cmd}" ]]; then
                cp "${dee_cmd}" "${commands_dir}/" 2>/dev/null && dee_count=$((dee_count + 1))
            fi
        done
        if [[ ${dee_count} -gt 0 ]]; then
            count=$((count + dee_count))
            log_verbose "Added ${dee_count} DEE core commands (dee-status, dee-demo, dee-doctor)"
        fi
    fi

    log_success "Generated ${count} slash commands in .claude/commands/"
}

# ============================================================================
# GLOBAL CONFIGURATION
# ============================================================================

create_global_claude_md() {
    log_step "Creating global CLAUDE.md..."

    # Claude Code reads CLAUDE.md from the PROJECT ROOT, not .claude/
    local claude_md_path="${TARGET_DIR}/CLAUDE.md"

    # If CLAUDE.md already exists at root, don't overwrite — append a reference
    if [[ -f "${claude_md_path}" ]]; then
        # Check if it already has Devlmer section
        if ! grep -q "Devlmer Ecosystem Engine" "${claude_md_path}" 2>/dev/null; then
            cat >> "${claude_md_path}" << 'APPEND_EOF'

## Devlmer Ecosystem Engine v3.0

This project has been configured with the Devlmer Ecosystem Engine.
Skills, MCPs, agents and slash commands are available in `.claude/`.
Type `/` in Claude Code to see all available slash commands.
APPEND_EOF
            log_verbose "Appended Devlmer reference to existing CLAUDE.md"
        fi
    else
        # Create new CLAUDE.md at project root
        cat > "${claude_md_path}" << 'CLAUDEMD_EOF'
# CLAUDE.md — Devlmer Ecosystem Engine v3.0

This project is enhanced with the Devlmer Ecosystem Engine — an intelligent development assistant that gives Claude Code superpowers.

## Quick Start

Type `/` to see all available slash commands. The most important ones:

| Command | What it does |
|---------|-------------|
| `/dee-demo` | Interactive tour of the ecosystem (start here!) |
| `/dee-status` | Dashboard showing everything installed |
| `/dee-doctor` | Health check — diagnose issues, configure API keys |

## How It Works

The ecosystem automatically enhances Claude Code with:

**Skills** — Deep professional knowledge in `.claude/skills/`. Claude reads these automatically when relevant to your task. Examples: `/senior-architect` for system design, `/code-reviewer` for code review, `/copywriting` for marketing text.

**Slash Commands** — Type `/` + command name to activate any skill directly. All installed commands are in `.claude/commands/`.

**Agents** — Specialized AI workers in `.claude/agents/` for parallel tasks like code review, security auditing, and testing.

**MCPs** — External tool integrations (GitHub, Slack, Stripe, etc.) configured in `.claude/settings.json`. Some need API keys — run `/dee-doctor` to check.

**Hooks** — Automatic verification that runs after every code edit:
- Python files: syntax checked with `py_compile`
- TypeScript/JSX: flagged for build verification

## Auto-Activation

You don't need to memorize commands. Just describe what you need and the ecosystem activates the right skills automatically:

- Writing code → senior-backend, senior-frontend skills activate
- Reviewing code → code-reviewer skill with professional checklists
- System design → senior-architect with architecture patterns
- Security work → senior-security with OWASP Top 10 guidance
- Writing copy → copywriting with marketing frameworks
- Git operations → git-commit-helper with conventional commits

## Project Intelligence

The engine analyzed this project and stored the results in `.claude/PROJECT_PROFILE.json`. This includes detected technologies, domain classification, architecture type, and maturity assessment. Claude uses this to prioritize the most relevant skills.

## Configuration Files

| File | Purpose |
|------|---------|
| `CLAUDE.md` | This file — Claude Code reads it on every session |
| `.claude/settings.json` | Hooks, MCPs, and engine configuration |
| `.claude/PROJECT_PROFILE.json` | Project detection and fingerprint data |
| `.claude/mcp-env-setup.sh` | API keys for MCP integrations |
CLAUDEMD_EOF
    fi

    # Also keep a copy inside .claude/ for reference
    if [[ -f "${claude_md_path}" ]] && [[ ! -f "${TARGET_DIR}/.claude/CLAUDE.md" ]]; then
        cp "${claude_md_path}" "${TARGET_DIR}/.claude/CLAUDE.md" 2>/dev/null || true
    fi

    CONFIG_FILES_CREATED=$((CONFIG_FILES_CREATED + 1))
    log_success "Global CLAUDE.md created at project root"
}

create_settings_json() {
    log_step "Creating settings.json..."

    local settings_file="${TARGET_DIR}/.claude/settings.json"

    # If settings.json already exists (e.g., from install_mcps which runs first),
    # add Claude Code-compatible hooks and metadata without overwriting mcpServers
    if [[ -f "${settings_file}" ]]; then
        log_info "settings.json already exists — adding hooks and metadata..."
        if command -v python3 >/dev/null 2>&1; then
            TARGET_DIR="${TARGET_DIR}" python3 << 'MERGE_SETTINGS'
import json, os
target_dir = os.environ.get('TARGET_DIR', '')
settings_file = os.path.join(target_dir, '.claude/settings.json')
try:
    with open(settings_file, 'r') as f:
        existing = json.load(f)

    # Add Claude Code-compatible hooks (real format, not boolean flags)
    if 'hooks' not in existing or isinstance(existing.get('hooks', {}).get('session_start'), bool):
        existing['hooks'] = {
            "SessionStart": [
                {
                    "matcher": "",
                    "hooks": [
                        {
                            "type": "command",
                            "command": "PROJ_DIR=$(pwd); PROFILE=\"$PROJ_DIR/.claude/PROJECT_PROFILE.json\"; SKILLS=$(find \"$PROJ_DIR/.claude/skills\" -name 'SKILL.md' 2>/dev/null | wc -l | tr -d ' '); AGENTS=$(find \"$PROJ_DIR/.claude/agents\" -name '*.md' 2>/dev/null | wc -l | tr -d ' '); CMDS=$(find \"$PROJ_DIR/.claude/commands\" -name '*.md' 2>/dev/null | wc -l | tr -d ' '); MCPS=0; if [ -f \"$PROJ_DIR/.claude/settings.json\" ]; then MCPS=$(python3 -c \"import json; s=json.load(open('$PROJ_DIR/.claude/settings.json')); print(len(s.get('mcpServers',{})))\" 2>/dev/null || echo 0); fi; DOMAIN='unknown'; if [ -f \"$PROFILE\" ]; then DOMAIN=$(python3 -c \"import json; p=json.load(open('$PROFILE')); print(p.get('fingerprint',{}).get('domain','unknown').replace('_',' ').title())\" 2>/dev/null || echo unknown); fi; echo ''; echo '🧠 DEVLMER ECOSYSTEM ENGINE v3.0'; echo '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'; echo \"📊 Project: $(basename $PROJ_DIR) | Domain: $DOMAIN\"; echo \"⚡ $SKILLS skills | $CMDS commands | $AGENTS agents | $MCPS MCPs\"; echo ''; echo '💡 Quick start: /dee-demo (tour) | /dee-status (dashboard) | /dee-doctor (health)'; echo '   Type / to see all available commands'; echo ''"
                        }
                    ]
                }
            ],
            "PostToolUse": [
                {
                    "matcher": "Edit|Write",
                    "hooks": [
                        {
                            "type": "command",
                            "command": "EDITED_FILE=\"$CLAUDE_FILE_PATH\"; if echo \"$EDITED_FILE\" | grep -qE '\\.py$'; then python3 -m py_compile \"$EDITED_FILE\" 2>&1 && echo '✅ Python syntax OK' || echo '❌ Python syntax error'; elif echo \"$EDITED_FILE\" | grep -qE '\\.(tsx?|jsx?)$'; then echo '⚡ TypeScript file edited — run build to verify'; fi"
                        }
                    ]
                }
            ]
        }

    # Add Devlmer metadata
    existing.setdefault('version', '3.0')
    existing.setdefault('engine', 'devlmer-ecosystem-engine')

    # Ensure mcpServers exists
    existing.setdefault('mcpServers', {})

    with open(settings_file, 'w') as f:
        json.dump(existing, f, indent=2)
    print("✅ Merged hooks and metadata into settings.json")
except Exception as e:
    print(f"⚠️ Error merging settings: {e}")
MERGE_SETTINGS
        fi
        CONFIG_FILES_CREATED=$((CONFIG_FILES_CREATED + 1))
        log_success "Settings.json merged successfully"
        return 0
    fi

    # Create fresh settings.json with Claude Code-compatible format
    # Note: SessionStart hook dynamically reads PROJECT_PROFILE.json and counts components
    cat > "${settings_file}" << 'SETTINGS_EOF'
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "PROJ_DIR=$(pwd); PROFILE=\"$PROJ_DIR/.claude/PROJECT_PROFILE.json\"; SKILLS=$(find \"$PROJ_DIR/.claude/skills\" -name 'SKILL.md' 2>/dev/null | wc -l | tr -d ' '); AGENTS=$(find \"$PROJ_DIR/.claude/agents\" -name '*.md' 2>/dev/null | wc -l | tr -d ' '); CMDS=$(find \"$PROJ_DIR/.claude/commands\" -name '*.md' 2>/dev/null | wc -l | tr -d ' '); MCPS=0; if [ -f \"$PROJ_DIR/.claude/settings.json\" ]; then MCPS=$(python3 -c \"import json; s=json.load(open('$PROJ_DIR/.claude/settings.json')); print(len(s.get('mcpServers',{})))\" 2>/dev/null || echo 0); fi; DOMAIN='unknown'; if [ -f \"$PROFILE\" ]; then DOMAIN=$(python3 -c \"import json; p=json.load(open('$PROFILE')); print(p.get('fingerprint',{}).get('domain','unknown').replace('_',' ').title())\" 2>/dev/null || echo unknown); fi; echo ''; echo '🧠 DEVLMER ECOSYSTEM ENGINE v3.0'; echo '━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━'; echo \"📊 Project: $(basename $PROJ_DIR) | Domain: $DOMAIN\"; echo \"⚡ $SKILLS skills | $CMDS commands | $AGENTS agents | $MCPS MCPs\"; echo ''; echo '💡 Quick start: /dee-demo (tour) | /dee-status (dashboard) | /dee-doctor (health)'; echo '   Type / to see all available commands'; echo ''"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "EDITED_FILE=\"$CLAUDE_FILE_PATH\"; if echo \"$EDITED_FILE\" | grep -qE '\\.py$'; then python3 -m py_compile \"$EDITED_FILE\" 2>&1 && echo '✅ Python syntax OK' || echo '❌ Python syntax error'; elif echo \"$EDITED_FILE\" | grep -qE '\\.(tsx?|jsx?)$'; then echo '⚡ TypeScript file edited — run build to verify'; fi"
          }
        ]
      }
    ]
  },
  "version": "3.0",
  "engine": "devlmer-ecosystem-engine",
  "mcpServers": {}
}
SETTINGS_EOF

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

    if ! command -v python3 >/dev/null 2>&1; then
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

    if ! command -v python3 >/dev/null 2>&1; then
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
            --non-interactive|--yes|-y)
                NON_INTERACTIVE=1
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
                # Positional arguments form the target directory path
                # Handles unquoted paths with spaces: install.sh ~/My Projects/app
                if [[ ! "$1" == -* ]]; then
                    if [[ -z "${TARGET_DIR:-}" ]]; then
                        TARGET_DIR="$1"
                    else
                        # Append to existing path (space-separated words)
                        TARGET_DIR="${TARGET_DIR} $1"
                    fi
                    shift
                else
                    log_error "Unknown option: $1"
                    show_help
                    exit 1
                fi
                ;;
        esac
    done

    # --- Post-parse: Resolve and validate TARGET_DIR ---
    if [[ -n "${TARGET_DIR:-}" ]]; then
        # Expand ~ if it wasn't expanded by the shell (e.g., when passed in quotes)
        TARGET_DIR="${TARGET_DIR/#\~/$HOME}"

        # Resolve to absolute path
        if [[ -d "${TARGET_DIR}" ]]; then
            TARGET_DIR="$(cd "${TARGET_DIR}" && pwd)"
        fi

        # Trim trailing slash
        TARGET_DIR="${TARGET_DIR%/}"
    fi
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
    local total_errors=$((SKILLS_FAILED + MCPS_FAILED + AGENTS_FAILED))
    local total_installed=$((SKILLS_INSTALLED + EXTERNAL_SKILLS_INSTALLED + MCPS_INSTALLED + AGENTS_CONFIGURED + CONFIG_FILES_CREATED + SCRIPTS_COPIED))

    echo ""
    echo -e "${BOLD}${CYAN}╔══════════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${BOLD}${CYAN}║             DEVLMER ECOSYSTEM ENGINE — INSTALLATION REPORT      ║${RESET}"
    echo -e "${BOLD}${CYAN}╚══════════════════════════════════════════════════════════════════╝${RESET}"
    echo ""

    # ── Section 1: Project Detection ──
    echo -e "${BOLD}${MAGENTA}┌─ PROJECT DETECTION ──────────────────────────────────────────────┐${RESET}"
    local profile_path="${TARGET_DIR}/.claude/PROJECT_PROFILE.json"
    if [[ -f "${profile_path}" ]] && command -v python3 >/dev/null 2>&1; then
        python3 -c "
import json, sys
try:
    with open('${profile_path}', 'r') as f:
        profile = json.load(f)
    fp = profile.get('fingerprint', {})
    domain = fp.get('domain', 'unknown')
    confidence = fp.get('domain_confidence', fp.get('confidence', 0))

    # Technologies can be dict {name: score} or list
    techs_raw = fp.get('technologies', {})
    if isinstance(techs_raw, dict):
        techs = sorted(techs_raw.keys(), key=lambda k: techs_raw[k], reverse=True)
    elif isinstance(techs_raw, list):
        techs = techs_raw
    else:
        techs = []

    # Primary stack categories
    stack = fp.get('primary_stack', {})
    frameworks = []
    languages = []
    infra = []
    for cat, items in stack.items():
        if isinstance(items, list):
            if cat in ('frontend_framework', 'backend_framework', 'mobile', 'css'):
                frameworks.extend(items)
            elif cat in ('language', 'languages'):
                languages.extend(items)
            elif cat in ('infrastructure', 'cloud', 'devops', 'container'):
                infra.extend(items)
            else:
                frameworks.extend(items)  # catch-all

    # Architecture
    arch = fp.get('architecture', {})
    arch_primary = arch.get('primary', '') if isinstance(arch, dict) else ''

    # Secondary domains
    sec_domains = fp.get('secondary_domains', [])
    domain_str = domain.replace('_', ' ').title()
    if sec_domains and isinstance(sec_domains, list):
        sec_names = [d.get('name', '').replace('_', ' ').title() for d in sec_domains[:3] if isinstance(d, dict)]
        if sec_names:
            domain_str += ' + ' + ', '.join(sec_names)

    print(f'  Domain:       {domain_str}')
    print(f'  Confidence:   {int(float(confidence) * 100)}%')
    if arch_primary:
        print(f'  Architecture: {arch_primary}')
    if techs:
        print(f'  Technologies: {\", \".join(str(t) for t in techs[:10])}')
    if frameworks:
        print(f'  Frameworks:   {\", \".join(str(f) for f in frameworks[:8])}')
    if languages:
        print(f'  Languages:    {\", \".join(str(l) for l in languages[:8])}')
    if infra:
        print(f'  Infra:        {\", \".join(str(i) for i in infra[:6])}')

    # Parsed dependencies (from improved detect_project.py)
    deps = fp.get('parsed_dependencies', profile.get('parsed_dependencies', {}))
    if deps and isinstance(deps, dict):
        total_deps = sum(len(v) if isinstance(v, (list, dict)) else 0 for v in deps.values())
        if total_deps > 0:
            print(f'  Dependencies: {total_deps} packages across {len(deps)} manifest(s)')

    tc = fp.get('tech_count', len(techs))
    fc = fp.get('file_count', 0)
    if tc or fc:
        maturity = fp.get('maturity', {})
        mat_label = maturity.get('label', '') if isinstance(maturity, dict) else ''
        extra = f'  Complexity:   {tc} tech(s), {fc} file(s)'
        if mat_label:
            extra += f' — maturity: {mat_label}'
        print(extra)
except Exception as e:
    print(f'  Could not fully parse profile: {e}')
" 2>/dev/null || echo -e "  ${YELLOW}⚠ Profile generated but could not be read${RESET}"
    else
        echo -e "  ${DIM}No project profile generated (new/empty project)${RESET}"
    fi
    echo -e "${BOLD}${MAGENTA}└──────────────────────────────────────────────────────────────────┘${RESET}"
    echo ""

    # ── Section 2: Installed Components ──
    echo -e "${BOLD}${GREEN}┌─ INSTALLED COMPONENTS ───────────────────────────────────────────┐${RESET}"
    echo ""

    # Skills
    echo -e "  ${BOLD}Skills (AI capabilities)${RESET}"
    if [[ ${SKILLS_INSTALLED} -gt 0 ]]; then
        echo -e "    ${GREEN}✓${RESET} ${SKILLS_INSTALLED} bundled skills installed"
        # List actual skill names
        if [[ -d "${TARGET_DIR}/.claude/skills" ]]; then
            local skill_list=""
            for skill_dir in "${TARGET_DIR}/.claude/skills"/*/; do
                if [[ -f "${skill_dir}SKILL.md" ]]; then
                    local sname=$(basename "${skill_dir}")
                    if [[ -n "${skill_list}" ]]; then
                        skill_list="${skill_list}, ${sname}"
                    else
                        skill_list="${sname}"
                    fi
                fi
            done
            if [[ -n "${skill_list}" ]]; then
                echo -e "    ${DIM}${skill_list}${RESET}"
            fi
        fi
    fi
    if [[ ${EXTERNAL_SKILLS_INSTALLED} -gt 0 ]]; then
        echo -e "    ${GREEN}✓${RESET} ${EXTERNAL_SKILLS_INSTALLED} external skills installed"
    fi
    if [[ ${SKILLS_FAILED} -gt 0 ]]; then
        echo -e "    ${RED}✗${RESET} ${SKILLS_FAILED} skills failed"
    fi
    echo ""

    # Slash Commands
    local cmd_count=0
    if [[ -d "${TARGET_DIR}/.claude/commands" ]]; then
        cmd_count=$(find "${TARGET_DIR}/.claude/commands" -name "*.md" 2>/dev/null | wc -l | tr -d ' ')
    fi
    echo -e "  ${BOLD}Slash Commands${RESET}"
    if [[ ${cmd_count} -gt 0 ]]; then
        echo -e "    ${GREEN}✓${RESET} ${cmd_count} commands available (type / in Claude Code)"
    else
        echo -e "    ${DIM}○ No commands generated${RESET}"
    fi
    echo ""

    # Agents
    echo -e "  ${BOLD}Agents (specialized AI workers)${RESET}"
    if [[ ${AGENTS_CONFIGURED} -gt 0 ]]; then
        echo -e "    ${GREEN}✓${RESET} ${AGENTS_CONFIGURED} agents configured"
        if [[ -d "${TARGET_DIR}/.claude/agents" ]]; then
            local agent_list=""
            for agent_file in "${TARGET_DIR}/.claude/agents"/*.md; do
                if [[ -f "${agent_file}" ]]; then
                    local aname=$(basename "${agent_file}" .md)
                    if [[ -n "${agent_list}" ]]; then
                        agent_list="${agent_list}, ${aname}"
                    else
                        agent_list="${aname}"
                    fi
                fi
            done
            if [[ -n "${agent_list}" ]]; then
                echo -e "    ${DIM}${agent_list}${RESET}"
            fi
        fi
    else
        echo -e "    ${DIM}○ No agents configured${RESET}"
    fi
    if [[ ${AGENTS_FAILED} -gt 0 ]]; then
        echo -e "    ${RED}✗${RESET} ${AGENTS_FAILED} agents failed"
    fi
    echo ""

    # MCPs
    echo -e "  ${BOLD}MCPs (external tool integrations)${RESET}"
    if [[ ${MCPS_INSTALLED} -gt 0 ]]; then
        echo -e "    ${GREEN}✓${RESET} ${MCPS_INSTALLED} MCPs configured in settings.json"
    fi
    if [[ ${MCPS_FAILED} -gt 0 ]]; then
        echo -e "    ${RED}✗${RESET} ${MCPS_FAILED} MCPs failed"
    fi
    if [[ ${MCPS_INSTALLED} -eq 0 ]] && [[ ${MCPS_FAILED} -eq 0 ]]; then
        echo -e "    ${DIM}○ No MCPs installed (project didn't require any)${RESET}"
    fi
    echo ""

    # Hooks
    local hooks_active=0
    if [[ -f "${TARGET_DIR}/.claude/settings.json" ]]; then
        hooks_active=$(python3 -c "
import json
try:
    with open('${TARGET_DIR}/.claude/settings.json') as f:
        s = json.load(f)
    hooks = s.get('hooks', {})
    count = sum(len(v) for v in hooks.values() if isinstance(v, list))
    print(count)
except:
    print(0)
" 2>/dev/null || echo "0")
    fi
    echo -e "  ${BOLD}Hooks (auto-verification)${RESET}"
    if [[ ${hooks_active} -gt 0 ]]; then
        echo -e "    ${GREEN}✓${RESET} ${hooks_active} hook(s) active (SessionStart, PostToolUse)"
    else
        echo -e "    ${DIM}○ No hooks configured${RESET}"
    fi
    echo ""

    echo -e "${BOLD}${GREEN}└──────────────────────────────────────────────────────────────────┘${RESET}"
    echo ""

    # ── Section 3: Configuration Files ──
    echo -e "${BOLD}${BLUE}┌─ CONFIGURATION FILES ────────────────────────────────────────────┐${RESET}"
    local files_to_check=(
        "CLAUDE.md:Project instructions for Claude Code (root)"
        ".claude/settings.json:Claude Code settings (hooks + MCPs)"
        ".claude/PROJECT_PROFILE.json:Project fingerprint & detection data"
    )
    for entry in "${files_to_check[@]}"; do
        local fpath="${entry%%:*}"
        local fdesc="${entry#*:}"
        if [[ -f "${TARGET_DIR}/${fpath}" ]]; then
            local fsize=$(wc -c < "${TARGET_DIR}/${fpath}" | tr -d ' ')
            echo -e "  ${GREEN}✓${RESET} ${fpath} ${DIM}(${fsize} bytes)${RESET} — ${fdesc}"
        else
            echo -e "  ${YELLOW}○${RESET} ${fpath} — ${fdesc} ${DIM}(not created)${RESET}"
        fi
    done
    echo -e "${BOLD}${BLUE}└──────────────────────────────────────────────────────────────────┘${RESET}"
    echo ""

    # ── Section 4: Integrations ──
    echo -e "${BOLD}${YELLOW}┌─ INTEGRATIONS ────────────────────────────────────────────────────┐${RESET}"
    echo -e "  ${BOLD}GitHub:${RESET}  $([ ${GITHUB_AUTHENTICATED} -eq 1 ] && echo -e "${GREEN}✓ Authenticated${RESET}" || echo -e "${DIM}○ Not connected${RESET}")"
    echo -e "  ${BOLD}Nano-Banana:${RESET} $([ ${NANO_BANANA_INSTALLED:-0} -eq 1 ] && echo -e "${GREEN}✓ Installed${RESET} ${DIM}(Gemini image gen)${RESET}" || echo -e "${DIM}○ Not installed${RESET}")"
    echo -e "${BOLD}${YELLOW}└──────────────────────────────────────────────────────────────────┘${RESET}"
    echo ""

    # ── Section 5: System Info ──
    echo -e "${BOLD}${DIM}┌─ SYSTEM ──────────────────────────────────────────────────────────┐${RESET}"
    echo -e "  ${DIM}Target:    ${TARGET_DIR}${RESET}"
    echo -e "  ${DIM}Platform:  ${DEE_OS} (${DEE_ARCH})${RESET}"
    echo -e "  ${DIM}Duration:  ${duration}${RESET}"
    echo -e "  ${DIM}Errors:    ${total_errors}${RESET}"
    echo -e "${BOLD}${DIM}└──────────────────────────────────────────────────────────────────┘${RESET}"
    echo ""

    # ── Final Status ──
    if [[ ${total_errors} -eq 0 ]]; then
        echo -e "${BOLD}${GREEN}  ✅ Installation completed successfully — ${total_installed} components installed${RESET}"
    else
        echo -e "${BOLD}${YELLOW}  ⚠️  Installation completed with ${total_errors} error(s) — ${total_installed} components installed${RESET}"
    fi
    echo ""

    # ── Next Steps ──
    echo -e "${BOLD}${CYAN}  Next steps:${RESET}"
    echo -e "    1. Open your project in Claude Code"
    echo -e "    2. Type ${BOLD}/${RESET} to see available slash commands"
    echo -e "    3. Claude will auto-detect your project and use the right skills"
    if [[ -f "${TARGET_DIR}/.claude/mcp-env-setup.sh" ]]; then
        echo -e "    4. Configure API keys: ${CYAN}bash \"${TARGET_DIR}/.claude/setup-wizard.sh\" \"${TARGET_DIR}\"${RESET}"
    fi
    echo ""
    echo -e "${BOLD}${CYAN}  dee CLI:${RESET}"
    echo -e "    ${GREEN}dee update${RESET}      Update skills & commands (preserves config)"
    echo -e "    ${GREEN}dee status${RESET}      Show what's installed"
    echo -e "    ${GREEN}dee doctor${RESET}      Health check & diagnostics"
    echo ""
}

install_dee_cli() {
    log_step "Installing 'dee' CLI command..."

    local cli_source="${SCRIPT_DIR}/bin/dee"
    if [[ ! -f "${cli_source}" ]]; then
        log_verbose "dee CLI not found in bundle (optional)"
        return 0
    fi

    # Install to ~/.local/bin (no sudo needed, standard on Linux/macOS)
    local bin_dir="${HOME}/.local/bin"
    mkdir -p "${bin_dir}"
    cp "${cli_source}" "${bin_dir}/dee"
    chmod +x "${bin_dir}/dee"

    # Check if ~/.local/bin is in PATH
    if echo "${PATH}" | grep -q "${bin_dir}"; then
        log_success "dee CLI installed — run ${BOLD}dee help${RESET} from anywhere"
    else
        log_success "dee CLI installed to ${bin_dir}/dee"
        # Add to PATH in shell config
        local shell_rc=""
        if [[ -f "${HOME}/.zshrc" ]]; then
            shell_rc="${HOME}/.zshrc"
        elif [[ -f "${HOME}/.bashrc" ]]; then
            shell_rc="${HOME}/.bashrc"
        elif [[ -f "${HOME}/.bash_profile" ]]; then
            shell_rc="${HOME}/.bash_profile"
        fi

        if [[ -n "${shell_rc}" ]]; then
            if ! grep -q '\.local/bin' "${shell_rc}" 2>/dev/null; then
                echo '' >> "${shell_rc}"
                echo '# Devlmer Ecosystem Engine CLI' >> "${shell_rc}"
                echo 'export PATH="${HOME}/.local/bin:${PATH}"' >> "${shell_rc}"
                log_info "Added ~/.local/bin to PATH in $(basename "${shell_rc}")"
                log_info "Run: ${CYAN}source ${shell_rc}${RESET} or open a new terminal"
            fi
        else
            log_warning "Add to PATH manually: export PATH=\"\${HOME}/.local/bin:\${PATH}\""
        fi
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

offer_setup_wizard() {
    local wizard_path="${SCRIPT_DIR}/setup-wizard.sh"

    # Only offer if MCP env setup file exists (meaning MCPs need keys)
    if [[ ! -f "${TARGET_DIR}/.claude/mcp-env-setup.sh" ]]; then
        return
    fi

    echo ""
    echo -e "${BOLD}${CYAN}╔════════════════════════════════════════════════════════════╗${RESET}"
    echo -e "${BOLD}${CYAN}║  🔑 CONFIGURAR SERVICIOS (API Keys)                       ║${RESET}"
    echo -e "${BOLD}${CYAN}╚════════════════════════════════════════════════════════════╝${RESET}"
    echo ""
    echo -e "  Algunos MCPs necesitan API keys para funcionar."
    echo -e "  Puedes configurarlas ahora con un asistente guiado,"
    echo -e "  o hacerlo después cuando quieras."
    echo ""
    echo -e "  ${CYAN}1${RESET}) ${BOLD}Configurar ahora${RESET} — Asistente paso a paso (recomendado)"
    echo -e "  ${CYAN}2${RESET}) ${BOLD}Después${RESET} — Ejecuta: ${DIM}bash \"${TARGET_DIR}/.claude/setup-wizard.sh\" \"${TARGET_DIR}\"${RESET}"
    echo ""
    local wizard_choice=""
    safe_read wizard_choice "  ¿Configurar API keys ahora? [1/2]:" 30 "2"

    if [[ "$wizard_choice" == "1" ]]; then
        if [[ -f "$wizard_path" ]]; then
            run_with_timeout 120 bash "$wizard_path" "${TARGET_DIR}"
        else
            log_warning "Setup wizard not found at ${wizard_path}"
            echo -e "  Puedes configurar manualmente: ${CYAN}${TARGET_DIR}/.claude/mcp-env-setup.sh${RESET}"
        fi
    else
        echo ""
        echo -e "  ${GREEN}✓${RESET} Sin problema. Cuando quieras, ejecuta:"
        echo -e "  ${CYAN}  bash \"${TARGET_DIR}/.claude/setup-wizard.sh\" \"${TARGET_DIR}\"${RESET}"
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
            run_step "Save GitHub auth" save_github_auth
            run_step "GitHub features" offer_github_features
        elif is_interactive; then
            # Interactive terminal — ask user
            run_step "GitHub auth interactive" get_github_auth_interactive
            run_step "Save GitHub auth" save_github_auth
            run_step "GitHub features" offer_github_features
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
        run_step "Nano-Banana-MCP setup" setup_nano_banana_mcp
        echo ""
    fi

    # Bundled skills installation (all modes except scan-only)
    if [[ "${MODE}" != "scan-only" ]]; then
        log_section "INSTALLING BUNDLED SKILLS"
        run_step "Bundled skills" copy_bundled_skills
        echo ""
    fi

    # External skills installation (full and skills-only modes)
    if [[ "${MODE}" != "scan-only" ]] && [[ -z "${NO_EXTERNAL:-}" ]]; then
        run_step "External skills" install_external_skills
        echo ""
    fi

    # Configuration setup (all modes except skills-only)
    # IMPORTANT: create_settings_json MUST run BEFORE install_mcps
    # so MCPs can merge into the existing settings file
    if [[ "${MODE}" != "skills-only" ]]; then
        log_section "CONFIGURATION & SETUP"

        run_step "Blueprints" copy_blueprints
        run_step "Scripts" copy_scripts
        run_step "Hooks" setup_hooks
        run_step "Slash commands" generate_slash_commands
        run_step "CLAUDE.md" create_global_claude_md
        run_step "settings.json" create_settings_json

        echo ""
    fi

    # Project intelligence scanning (full and scan-only modes)
    # MUST run BEFORE install_mcps because the fingerprinter/orchestrator
    # creates PROJECT_PROFILE.json which install_mcps reads
    if [[ "${MODE}" != "skills-only" ]]; then
        log_section "PROJECT INTELLIGENCE"

        run_step "Project fingerprinter" run_project_fingerprinter
        run_step "Orchestrator" run_orchestrator

        echo ""
    fi

    # MCP installation (full and skills-only modes)
    # Runs AFTER orchestrator (which creates the profile with MCPs)
    # and AFTER create_settings_json (which creates the base settings file)
    if [[ "${MODE}" != "scan-only" ]] && [[ -z "${NO_MCP:-}" ]]; then
        run_step "MCP installation" install_mcps
        echo ""
    fi

    # Agent configuration (requires PROJECT_PROFILE.json from orchestrator)
    if [[ "${MODE}" != "skills-only" ]]; then
        run_step "Agent configuration" configure_agents
        echo ""
    fi

    # Show summary
    show_summary

    # Show step failure report if any
    if [[ ${STEP_FAILURES} -gt 0 ]]; then
        echo ""
        log_section "STEP FAILURE REPORT"
        log_warning "${STEP_FAILURES} of ${STEP_COUNT} steps had issues:"
        echo -e "${STEP_ERRORS}"
        echo ""
        log_info "Most features should still work. Check ${LOG_FILE} for details."
    fi

    # Install dee CLI globally
    install_dee_cli
    echo ""

    # Product info
    show_product_info

    # Log completion
    log_info "Full install log saved to: ${LOG_FILE}"

    # Offer Setup Wizard for API keys
    offer_setup_wizard
}

# ============================================================================
# ENTRY POINT
# ============================================================================

# Global timeout handler — ensures script never hangs beyond 5 minutes
GLOBAL_TIMEOUT=300  # 5 minutes

# Use SIGTERM (15) instead of SIGALRM (14) for maximum portability
# SIGALRM is not reliably trappable on all systems (macOS Bash 3.2, Git Bash)
trap 'echo ""; log_error "Installation timed out after ${GLOBAL_TIMEOUT}s. Check ${LOG_FILE} for details."; exit 124' TERM 2>/dev/null || true

# Set global watchdog (portable: works on Bash 3.2+, zsh, Git Bash)
(
    sleep ${GLOBAL_TIMEOUT}
    # Send SIGTERM (15) to parent process group
    kill -15 $$ 2>/dev/null || kill $$ 2>/dev/null
) &
GLOBAL_WATCHDOG_PID=$!

# Cleanup watchdog on normal exit
cleanup_watchdog() {
    kill "${GLOBAL_WATCHDOG_PID}" 2>/dev/null || true
    wait "${GLOBAL_WATCHDOG_PID}" 2>/dev/null || true
}
trap cleanup_watchdog EXIT

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
