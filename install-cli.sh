#!/usr/bin/env bash
# ╔══════════════════════════════════════════════════════════════════════════╗
# ║                                                                        ║
# ║              DEVLMER ECOSYSTEM ENGINE — CLI INSTALLER                  ║
# ║                                                                        ║
# ║   curl -fsSL https://raw.githubusercontent.com/Soyelijah/              ║
# ║         devlmer-ecosystem-engine/main/install-cli.sh | bash            ║
# ║                                                                        ║
# ╚══════════════════════════════════════════════════════════════════════════╝
#
# This script installs the 'dee' CLI globally. After installation,
# use 'dee install <path>' to set up ecosystems on your projects.
#
# Requirements: git, bash 3.2+, python3
# Supports: macOS (Intel & Apple Silicon), Linux (x86_64, arm64)
# ────────────────────────────────────────────────────────────────────────────

set -euo pipefail

# ── Constants ──
REPO_URL="https://github.com/Soyelijah/devlmer-ecosystem-engine.git"
REPO_SHORT="Soyelijah/devlmer-ecosystem-engine"
TMP_DIR="/tmp/dee-install-$$"
INSTALL_DIR="${HOME}/.local/bin"
DEE_HOME="${HOME}/.dee"

# ── Colors (use $'...' for real escape bytes) ──
RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[1;33m'
CYAN=$'\033[0;36m'
MAGENTA=$'\033[0;35m'
BLUE=$'\033[0;34m'
BOLD=$'\033[1m'
DIM=$'\033[2m'
RESET=$'\033[0m'

# ── Cleanup ──
cleanup() { rm -rf "${TMP_DIR}" 2>/dev/null || true; }
trap cleanup EXIT

# ── Logging ──
info()    { echo "  ${CYAN}●${RESET} $1"; }
success() { echo "  ${GREEN}✓${RESET} $1"; }
warn()    { echo "  ${YELLOW}!${RESET} $1"; }
fail()    { echo "  ${RED}✗${RESET} $1"; exit 1; }
step()    { echo ""; echo "  ${BOLD}$1${RESET}"; }

# ── Spinner for long operations ──
spinner() {
    local pid=$1
    local msg="${2:-}"
    local frames=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧" "⠇" "⠏")
    local i=0
    while kill -0 "$pid" 2>/dev/null; do
        printf "\r  ${CYAN}${frames[$i]}${RESET} ${msg}" >&2
        i=$(( (i + 1) % ${#frames[@]} ))
        sleep 0.08
    done
    printf "\r" >&2
}

# ════════════════════════════════════════════════════════════════════════════
# SYSTEM DETECTION
# ════════════════════════════════════════════════════════════════════════════

detect_system() {
    OS="unknown"
    ARCH="unknown"
    SHELL_NAME="unknown"
    SHELL_RC=""

    # OS
    case "$(uname -s)" in
        Darwin*)  OS="macOS" ;;
        Linux*)   OS="Linux" ;;
        MINGW*|MSYS*|CYGWIN*) OS="Windows (WSL/Git Bash)" ;;
        *)        OS="$(uname -s)" ;;
    esac

    # Architecture
    case "$(uname -m)" in
        x86_64|amd64)   ARCH="x86_64" ;;
        arm64|aarch64)  ARCH="arm64" ;;
        *)              ARCH="$(uname -m)" ;;
    esac

    # macOS specific
    if [[ "${OS}" == "macOS" ]]; then
        MACOS_VERSION=$(sw_vers -productVersion 2>/dev/null || echo "unknown")
        if [[ "${ARCH}" == "arm64" ]]; then
            CHIP="Apple Silicon"
        else
            CHIP="Intel"
        fi
    fi

    # Shell
    SHELL_NAME=$(basename "${SHELL:-/bin/bash}")
    case "${SHELL_NAME}" in
        zsh)  SHELL_RC="${HOME}/.zshrc" ;;
        bash) SHELL_RC="${HOME}/.bashrc" ;;
        fish) SHELL_RC="${HOME}/.config/fish/config.fish" ;;
        *)    SHELL_RC="${HOME}/.profile" ;;
    esac
}

# ════════════════════════════════════════════════════════════════════════════
# REQUIREMENT CHECKS
# ════════════════════════════════════════════════════════════════════════════

check_requirements() {
    local all_ok=true

    # Git
    if command -v git &>/dev/null; then
        local git_ver
        git_ver=$(git --version | grep -oE '[0-9]+\.[0-9]+' | head -1)
        success "git ${git_ver}"
    else
        fail "git no encontrado. Instálalo primero: https://git-scm.com"
    fi

    # Python 3
    if command -v python3 &>/dev/null; then
        local py_ver
        py_ver=$(python3 --version 2>&1 | grep -oE '[0-9]+\.[0-9]+' | head -1)
        success "python ${py_ver}"
    else
        warn "python3 no encontrado — algunas funciones avanzadas no estarán disponibles"
    fi

    # Bash version
    local bash_ver="${BASH_VERSION:-unknown}"
    local bash_major="${bash_ver%%.*}"
    if [[ "${bash_major}" -ge 3 ]] 2>/dev/null; then
        success "bash ${bash_ver}"
    else
        warn "bash ${bash_ver} — se recomienda 3.2+"
    fi

    # Claude Code (optional)
    if command -v claude &>/dev/null; then
        success "claude code detectado"
    else
        info "claude code no detectado ${DIM}(opcional — instálalo desde claude.ai/code)${RESET}"
    fi

    # Disk space
    local free_mb
    if command -v df &>/dev/null; then
        free_mb=$(df -m "${HOME}" 2>/dev/null | awk 'NR==2{print $4}' || echo "0")
        if [[ "${free_mb}" -gt 50 ]] 2>/dev/null; then
            success "espacio en disco: ${free_mb}MB disponibles"
        else
            warn "poco espacio en disco: ${free_mb}MB"
        fi
    fi
}

# ════════════════════════════════════════════════════════════════════════════
# INSTALLATION
# ════════════════════════════════════════════════════════════════════════════

install_cli() {
    # Clone repo
    rm -rf "${TMP_DIR}"
    git clone --depth 1 --quiet "${REPO_URL}" "${TMP_DIR}" 2>/dev/null &
    spinner $! "Descargando última versión..."
    wait $! 2>/dev/null

    if [[ ! -f "${TMP_DIR}/bin/dee" ]]; then
        fail "Error descargando el repositorio. Revisa tu conexión."
    fi
    success "Última versión descargada"

    # Get version from downloaded file
    DEE_VERSION=$(grep '^VERSION=' "${TMP_DIR}/bin/dee" 2>/dev/null | head -1 | cut -d'"' -f2)

    # Create install directory
    mkdir -p "${INSTALL_DIR}"

    # Check if already installed
    local existing=""
    if [[ -f "${INSTALL_DIR}/dee" ]]; then
        existing=$(grep '^VERSION=' "${INSTALL_DIR}/dee" 2>/dev/null | head -1 | cut -d'"' -f2)
    fi

    # Copy binary
    cp "${TMP_DIR}/bin/dee" "${INSTALL_DIR}/dee"
    chmod +x "${INSTALL_DIR}/dee"
    success "CLI instalado en ${DIM}${INSTALL_DIR}/dee${RESET}"

    if [[ -n "${existing}" ]]; then
        info "Versión anterior: v${existing} → v${DEE_VERSION}"
    fi

    # Create DEE_HOME for config
    mkdir -p "${DEE_HOME}"

    # Store repo source for future updates
    echo "${REPO_URL}" > "${DEE_HOME}/source"
    echo "${DEE_VERSION}" > "${DEE_HOME}/version"
    date -u +"%Y-%m-%dT%H:%M:%SZ" > "${DEE_HOME}/installed_at"
    success "Configuración guardada en ${DIM}${DEE_HOME}${RESET}"
}

# ════════════════════════════════════════════════════════════════════════════
# PATH SETUP
# ════════════════════════════════════════════════════════════════════════════

setup_path() {
    # Check if already in PATH
    if echo "${PATH}" | tr ':' '\n' | grep -q "^${INSTALL_DIR}$"; then
        success "PATH ya configurado"
        return 0
    fi

    # Add to shell RC file
    local path_line="export PATH=\"${INSTALL_DIR}:\$PATH\""

    if [[ "${SHELL_NAME}" == "fish" ]]; then
        path_line="set -gx PATH ${INSTALL_DIR} \$PATH"
    fi

    if [[ -n "${SHELL_RC}" && -f "${SHELL_RC}" ]]; then
        # Check if already added
        if grep -q "${INSTALL_DIR}" "${SHELL_RC}" 2>/dev/null; then
            success "PATH ya está en ${DIM}${SHELL_RC}${RESET}"
        else
            echo "" >> "${SHELL_RC}"
            echo "# Devlmer Ecosystem Engine" >> "${SHELL_RC}"
            echo "${path_line}" >> "${SHELL_RC}"
            success "PATH agregado a ${DIM}${SHELL_RC}${RESET}"
        fi
    elif [[ -n "${SHELL_RC}" ]]; then
        # RC file doesn't exist, create it
        echo "# Devlmer Ecosystem Engine" > "${SHELL_RC}"
        echo "${path_line}" >> "${SHELL_RC}"
        success "Creado ${DIM}${SHELL_RC}${RESET} con PATH"
    fi

    # Export for current session
    export PATH="${INSTALL_DIR}:${PATH}"
}

# ════════════════════════════════════════════════════════════════════════════
# VERIFY INSTALLATION
# ════════════════════════════════════════════════════════════════════════════

verify_installation() {
    if command -v dee &>/dev/null; then
        local installed_ver
        installed_ver=$(dee version 2>/dev/null | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | head -1)
        success "Verificado: ${BOLD}dee${RESET} ${installed_ver} funciona correctamente"
        return 0
    fi

    # If 'dee' not found yet, try sourcing the RC
    if [[ -n "${SHELL_RC}" ]]; then
        # shellcheck disable=SC1090
        source "${SHELL_RC}" 2>/dev/null || true
        if command -v dee &>/dev/null; then
            success "Verificado: ${BOLD}dee${RESET} funciona correctamente"
            return 0
        fi
    fi

    # Direct path check
    if [[ -x "${INSTALL_DIR}/dee" ]]; then
        local ver
        ver=$("${INSTALL_DIR}/dee" version 2>/dev/null | grep -oE 'v[0-9]+\.[0-9]+\.[0-9]+' | head -1)
        success "Instalado: ${BOLD}${INSTALL_DIR}/dee${RESET} ${ver}"
        warn "Abre una nueva terminal o ejecuta: ${BOLD}source ${SHELL_RC}${RESET}"
        return 0
    fi

    fail "La instalación no se pudo verificar"
}

# ════════════════════════════════════════════════════════════════════════════
# MAIN
# ════════════════════════════════════════════════════════════════════════════

main() {
    clear 2>/dev/null || true
    echo ""
    echo "  ${BOLD}${CYAN}╔══════════════════════════════════════════════════════════╗${RESET}"
    echo "  ${BOLD}${CYAN}║                                                          ║${RESET}"
    echo "  ${BOLD}${CYAN}║${RESET}     ${BOLD}⚡ DEVLMER ECOSYSTEM ENGINE${RESET}                         ${BOLD}${CYAN}║${RESET}"
    echo "  ${BOLD}${CYAN}║${RESET}     ${DIM}Instalador del CLI${RESET}                                   ${BOLD}${CYAN}║${RESET}"
    echo "  ${BOLD}${CYAN}║                                                          ║${RESET}"
    echo "  ${BOLD}${CYAN}╚══════════════════════════════════════════════════════════╝${RESET}"
    echo ""

    # ── System Detection ──
    step "◆ SISTEMA"
    detect_system

    if [[ "${OS}" == "macOS" ]]; then
        success "${OS} ${MACOS_VERSION} · ${CHIP} (${ARCH})"
    else
        success "${OS} · ${ARCH}"
    fi
    success "Shell: ${SHELL_NAME} ${DIM}→ ${SHELL_RC}${RESET}"

    # ── Requirements ──
    step "◆ REQUISITOS"
    check_requirements

    # ── Installation ──
    step "◆ INSTALACIÓN"
    install_cli

    # ── PATH ──
    step "◆ CONFIGURACIÓN"
    setup_path

    # ── Verify ──
    step "◆ VERIFICACIÓN"
    verify_installation

    # ── Done ──
    echo ""
    echo "  ${BOLD}${GREEN}╔══════════════════════════════════════════════════════════╗${RESET}"
    echo "  ${BOLD}${GREEN}║                                                          ║${RESET}"
    echo "  ${BOLD}${GREEN}║${RESET}     ${BOLD}${GREEN}✓${RESET} ${BOLD}dee v${DEE_VERSION} instalado correctamente${RESET}              ${BOLD}${GREEN}║${RESET}"
    echo "  ${BOLD}${GREEN}║                                                          ║${RESET}"
    echo "  ${BOLD}${GREEN}╚══════════════════════════════════════════════════════════╝${RESET}"
    echo ""
    echo "  ${BOLD}Siguiente paso:${RESET} instala el ecosistema en tu proyecto:"
    echo ""
    echo "    ${CYAN}\$${RESET} ${BOLD}dee install ~/Projects/mi-app${RESET}"
    echo ""
    echo "  ${DIM}Otros comandos útiles:${RESET}"
    echo "    ${CYAN}\$${RESET} dee install          ${DIM}Instalar en la carpeta actual${RESET}"
    echo "    ${CYAN}\$${RESET} dee help             ${DIM}Ver todos los comandos${RESET}"
    echo "    ${CYAN}\$${RESET} dee self-update      ${DIM}Actualizar el CLI${RESET}"
    echo ""
    echo "  ${DIM}Más info: https://github.com/${REPO_SHORT}${RESET}"
    echo ""

    # Hint about new terminal if PATH wasn't available
    if ! command -v dee &>/dev/null; then
        echo "  ${YELLOW}►${RESET} Abre una nueva terminal para usar ${BOLD}dee${RESET}, o ejecuta:"
        echo "    ${CYAN}\$${RESET} source ${SHELL_RC}"
        echo ""
    fi
}

main "$@"
