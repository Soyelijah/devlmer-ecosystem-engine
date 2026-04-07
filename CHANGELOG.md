# Changelog

Todas las versiones notables de Devlmer Ecosystem Engine están documentadas aquí.

El formato sigue [Keep a Changelog](https://keepachangelog.com/es-ES/1.1.0/) y este proyecto adhiere a [Semantic Versioning](https://semver.org/lang/es/).

---

## [3.1.1] - 2026-04-07

### Agregado
-   [0;36m?[0m Describe cada cosa nueva [2m(una por línea, línea vacía para terminar)[0m
-     [2m•[0m     [2m•[0m 41 skills nuevas, enterprise CLI installer, 22 dominios, config templates

### Cambiado
-   [0;36m?[0m Describe cada cambio [2m(una por línea, línea vacía para terminar)[0m
-     [2m•[0m     [2m•[0m     [2m•[0m Landing y wizard actualizados con nuevo método curl | bash
- Estadísticas actualizadas a 62 skills y 22 dominios

### Corregido
-   [0;36m?[0m Describe cada fix [2m(una por línea, línea vacía para terminar)[0m
-     [2m•[0m     [2m•[0m     [2m•[0m Wizard generaba comando antiguo git clone en vez de curl
- Duplicado de tarjeta DevTools en landing

---


## [3.1.0] - 2026-04-07

### Agregado
- **41 skills nuevas** — Total expandido de 21 a 62 skills enterprise con contenido profesional real:
  - **Dev** (8): `security-audit`, `refactor`, `unit-test-generator`, `documentation`, `api-integration`, `docker-deploy`, `commit-commands`, `db-migration`
  - **Design** (7): `frontend-design`, `ux-copy`, `brand-guidelines`, `theme-factory`, `canvas-design`, `dashboard-audit`, `performance-optimization`
  - **Infra** (7): `data-validation`, `k8s-validation`, `risk-assessment`, `ml-validation`, `dependency-graph`, `workspace-tools`, `db-migration`
  - **Domain** (7): `data-pipeline`, `contract-validation`, `content-validation`, `schema-management`, `payment-validation`, `inventory-management`, `websocket-validation`
  - **Testing** (2): `mobile-testing`, `real-time-testing`
  - **Enterprise** (4): `enterprise-search`, `internal-comms`, `slack-gif-creator`, `algorithmic-art`
  - **Docs** (4): `docx`, `pdf`, `xlsx`, `pptx`
  - **Productivity** (3): `schedule`, `productivity-memory`, `productivity-tasks`
- **5 slash commands nuevos**: `security-audit`, `api-integration`, `theme-factory`, `github-auth`, `nano-banana`
- **Config templates**: `dee-config.yaml`, `github-config.json`, `nano-banana-config.json`, `create-skill.sh`, `ecosystems.json`, `.deeignore`
- **Enterprise CLI installer** (`install-cli.sh`): Instalación via `curl -fsSL ... | bash` con detección de OS, verificación de dependencias, colores enterprise y spinner animado.
- **8 dominios nuevos en blueprints**: Legal, Logistics, Marketing, HR Platform, API Platform, Real Estate, Web3, Mobile App — total 22 dominios.
- **`copy_config_templates()`** en `install.sh`: Copia automática de archivos de configuración al directorio del proyecto.

### Cambiado
- **Landing page**: Estadísticas actualizadas (62 skills, 22 dominios, 70+ comandos), 22 tarjetas de dominio, grid de skills expandido.
- **Wizard de instalación** (`wizard.js`): Método principal cambiado a `curl | bash`, simulación traducida al español, conteos actualizados a 62 skills.
- **`install.sh`**: Nuevos directorios (`memory/`, `scripts/`, `blueprints/`, `commands/`, `agents/`) y paso de config templates.

### Corregido
- Fix: Wizard generaba comando de instalación antiguo (`git clone`) en lugar del nuevo método `curl | bash`.
- Fix: Tarjeta de dominio DevTools duplicada en landing.
- Fix: Skill `copywriting` tenía directorio anidado duplicado y symlink roto.

---

## [3.0.0] - 2026-04-06

### Agregado
- **CLI global `dee`**: Comando instalado automáticamente en `~/.local/bin/dee` con subcomandos: `install`, `update`, `status`, `doctor`, `uninstall`, `version`, `help`.
- **`update.sh`**: Script de actualización que preserva API keys, MCPs, CLAUDE.md y PROJECT_PROFILE.json mientras actualiza skills, hooks y commands.
- **Slash commands DEE**: 3 nuevos comandos dentro de Claude Code:
  - `/dee-demo` — Tour interactivo del ecosistema instalado
  - `/dee-status` — Dashboard de componentes y configuración
  - `/dee-doctor` — Health check con scoring 0-100 y diagnóstico
- **SessionStart hook mejorado**: Dashboard dinámico que muestra proyecto, dominio, conteo real de skills/commands/agents/MCPs al abrir Claude Code.
- **PostToolUse hook**: Auto-verificación de sintaxis Python y TypeScript al editar archivos.
- **Reporte de instalación mejorado**: 5 secciones enterprise: detección de proyecto, componentes instalados (por nombre), archivos de configuración, integraciones y sistema.
- **8 skills enterprise reescritas** con contenido profesional real (400-1600 líneas cada una):
  - `senior-architect` (1485 líneas) — Diseño de sistemas, CQRS, Event Sourcing, DDD
  - `senior-backend` (1598 líneas) — Multi-lenguaje, APIs, migrations, testing
  - `senior-security` (796 líneas) — STRIDE, OWASP, compliance, penetration testing
  - `code-reviewer` (789 líneas) — Multi-lenguaje, scoring, code smells, refactoring
  - `brand-identity` (375 líneas) — Identidad visual enterprise
  - `marketing-graphic-design` (409 líneas) — Assets profesionales
  - `git-commit-helper` (768 líneas) — Conventional commits automáticos
  - `ui-design-system` (809 líneas) — Design tokens y componentes
- **`detect_project.py` mejorado**: Parsing real de `package.json`, `requirements.txt`, `Dockerfile`, `go.mod` y más. 157+ firmas de tecnología.
- **Landing page profesional**: Completamente rediseñada con información precisa, secciones de instalación, actualización, arquitectura y experiencia en Claude Code.
- **CHANGELOG.md**: Historial de versiones con formato Keep a Changelog.

### Cambiado
- **CLAUDE.md** ahora se genera en la raíz del proyecto (no en `.claude/`), siguiendo la convención de Claude Code.
- **Skills sin YAML frontmatter**: El instalador ahora elimina automáticamente el frontmatter `---` de todos los SKILL.md para compatibilidad con Claude Code.
- **settings.json**: Formato de hooks actualizado al schema v3 de Claude Code (array de objetos con `matcher` y `hooks`).
- **Instalador**: Refactorizado con funciones modulares, mejor manejo de errores y output más limpio.

### Corregido
- Fix: `TARGET_DIR` no se pasaba como variable de entorno al script de strip de frontmatter.
- Fix: Parser de `PROJECT_PROFILE.json` fallaba con `technologies` como dict en vez de lista.
- Fix: Conflicto de EOF heredoc en la generación de `settings.json`.
- Fix: Landing page tenía paths placeholder (`/path/to/your/project`), tiempos incorrectos (~40s) y claims falsos.

---

## [2.0.0] - 2026-03-15

### Agregado
- Instalador interactivo con setup wizard para API keys.
- Autenticación con GitHub durante la instalación.
- Blueprint matching por dominio empresarial.
- 14 dominios empresariales soportados.
- `ecosystems.json` con blueprints por dominio.
- Agents especializados generados automáticamente.
- `orchestrate.py` para coordinación multi-agent.

### Cambiado
- Skills expandidas de 12 a 21+.
- MCPs expandidos de 8 a 23+.
- Detección de proyecto mejorada con más firmas.

---

## [1.0.0] - 2026-02-01

### Agregado
- Instalador bash inicial (`install.sh`).
- Detección básica de proyecto con `detect_project.py`.
- 12 skills iniciales con contenido básico.
- 8 MCP servers pre-configurados.
- Hooks básicos de SessionStart.
- Landing page inicial.
- Soporte para macOS y Linux.

---

[3.1.0]: https://github.com/Soyelijah/devlmer-ecosystem-engine/compare/v3.0.0...v3.1.0
[3.0.0]: https://github.com/Soyelijah/devlmer-ecosystem-engine/compare/v2.0.0...v3.0.0
[2.0.0]: https://github.com/Soyelijah/devlmer-ecosystem-engine/compare/v1.0.0...v2.0.0
[1.0.0]: https://github.com/Soyelijah/devlmer-ecosystem-engine/releases/tag/v1.0.0
[3.1.1]: https://github.com/Soyelijah/devlmer-ecosystem-engine/compare/v3.1.0...v3.1.1
