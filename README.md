---
# Devlmer Ecosystem Engine v3.1
## Installation & User Guide (Spanish)

[![Version 3.1.1](https://img.shields.io/badge/version-3.1.1-blue.svg)](https://github.com/Soyelijah/devlmer-ecosystem-engine)
[![MIT License](https://img.shields.io/badge/license-MIT-green.svg)](LICENSE)
[![62 Skills](https://img.shields.io/badge/bundled%20skills-62-orange.svg)]()
[![Enterprise Grade](https://img.shields.io/badge/quality-enterprise%20grade-purple.svg)]()

**Versión:** 3.1.1 — The Enterprise Standard
**Autor:** Pierre Solier (Devlmer)
**Licencia:** MIT
**Marca:** Devlmer
**Lema:** Intelligent ecosystems for every project
**Última actualización:** Abril 2026

---

## What is DEE?

### ¿Qué es DEE?

**Devlmer Ecosystem Engine (DEE) v3.1** es un motor inteligente y de nivel empresarial que detecta automáticamente qué tipo de proyecto estás utilizando e **instala todo lo que necesitas para trabajar profesionalmente** en un único comando.

Sin importar si trabajas con:
- Aplicaciones React, Vue, Angular o Svelte
- Servidores FastAPI, NestJS, Django o Express
- Bases de datos PostgreSQL, MongoDB o DynamoDB
- Comercio algorítmico o trading bot
- Aplicaciones móviles, data science, o infraestructura en la nube

**DEE** detecta tu tipo de proyecto y carga automáticamente:
- **62 habilidades profesionales** especializadas y auditadas
- **Motor de inteligencia de proyecto** que detecta automáticamente tu stack tecnológico
- **Plugins y MCPs** recomendados para tu stack
- **Hooks de sesión** para auto-verificación y garantía de calidad
- **Agentes generados automáticamente** basados en tu pila tecnológica
- **Integración con GitHub CLI** para verificar estado de autenticación
- **Generación de imágenes Nano-Banana-MCP** (Gemini AI) para visualización

El resultado: Una experiencia de desarrollo completamente personalizada, lista para usar, sin configuración manual complicada, con herramientas para mantener calidad profesional.

---

## For Claude Agents (Instrucciones para tu Agente)

### Si alguien te envía este mensaje, cópialo y pégalo en tu agente Claude:

```
Instala el Devlmer Ecosystem Engine v3.1 en mi proyecto. Ejecuta estos comandos:

git clone https://github.com/Soyelijah/devlmer-ecosystem-engine.git /tmp/dee-install
bash /tmp/dee-install/install.sh .

Esto instalará 62 skills profesionales, 8 slash commands, MCPs recomendados,
agentes especializados y hooks de auto-verificación. El instalador detectará
automáticamente mi tipo de proyecto y personalizará todo.

Después de instalar, verifica con: ls .claude/skills/ && ls .claude/commands/
```

### Instalación Remota (Una Línea)

Si ya tienes Claude Code o Cowork configurado, puedes instalar DEE con un solo comando desde cualquier terminal:

```bash
git clone https://github.com/Soyelijah/devlmer-ecosystem-engine.git /tmp/dee-install && bash /tmp/dee-install/install.sh /ruta/a/tu/proyecto
```

Para saltar configuración interactiva (GitHub y external skills):
```bash
git clone https://github.com/Soyelijah/devlmer-ecosystem-engine.git /tmp/dee-install && bash /tmp/dee-install/install.sh /ruta/a/tu/proyecto --no-github --no-external
```

---

## Requirements

### Requisitos Previos

Antes de instalar DEE, necesitas tener instalado en tu computadora:

**1. Node.js 18 o superior + npm**
- Descarga desde: https://nodejs.org/
- Verifica que esté instalado: `node --version` y `npm --version`
- En macOS: `brew install node`
- En Windows: Usa el instalador desde nodejs.org
- En Linux: `sudo apt-get install nodejs npm`

**2. Python 3.8 o superior**
- Descarga desde: https://www.python.org/
- Verifica que esté instalado: `python3 --version`
- En macOS: `brew install python3`
- En Windows: Usa el instalador desde python.org
- En Linux: `sudo apt-get install python3 python3-pip`

**3. Claude Code o Cowork instalado**
- Claude Code: Acceso desde https://claude.ai/code
- Cowork: Aplicación de escritorio disponible en https://cowork.claude.ai

**4. Git**
- Descarga desde: https://git-scm.com/
- Verifica que esté instalado: `git --version`
- En macOS: `brew install git`
- En Windows: Usa el instalador desde git-scm.com
- En Linux: `sudo apt-get install git`

**5. Una terminal / línea de comandos**
- En macOS: Terminal.app o iTerm2
- En Windows: PowerShell, CMD, o Windows Terminal
- En Linux: Tu shell predeterminada (bash, zsh, etc.)

---

## Quick Install

### Instalación Rápida (Un Comando)

Si ya tienes todos los requisitos instalados, instala DEE con un solo comando:

```bash
git clone https://github.com/Soyelijah/devlmer-ecosystem-engine.git
cd devlmer-ecosystem-engine
bash install.sh /ruta/a/tu/proyecto
```

Reemplaza `/ruta/a/tu/proyecto` con la ruta completa a tu carpeta de proyecto.

**Ejemplo en macOS/Linux:**
```bash
bash install.sh ~/Documents/mi-aplicacion
```

**Ejemplo en Windows (PowerShell):**
```powershell
bash install.sh C:\Users\TuNombre\Documents\mi-aplicacion
```

El instalador tardará entre 2-5 minutos. Cuando termine, verás un mensaje de confirmación con el status completo de tu proyecto.

---

## Step by Step Installation

### Instalación Paso a Paso

Para usuarios sin experiencia con la terminal, aquí te mostramos exactamente qué hacer:

#### Paso 1: Abre la Terminal

**En macOS:**
- Presiona `Cmd + Espacio` (Spotlight search)
- Escribe "Terminal" y presiona Enter

**En Windows:**
- Presiona `Win + R`
- Escribe `powershell` y presiona Enter
- O abre "Windows Terminal" desde el menú Inicio

**En Linux:**
- Presiona `Ctrl + Alt + T` o abre tu terminal desde el menú de aplicaciones

Deberías ver una ventana con texto blanco sobre fondo oscuro.

#### Paso 2: Clona el Repositorio

Copia y pega esta línea exacta en tu terminal (presiona Enter al final):

```bash
git clone https://github.com/Soyelijah/devlmer-ecosystem-engine.git
```

Verás un mensaje como:
```
Cloning into 'devlmer-ecosystem-engine'...
remote: Enumerating objects: 1200, done.
...
```

Espera hasta que termine (puede tardar 30-60 segundos).

#### Paso 3: Navega al Directorio DEE

Copia y pega esta línea:

```bash
cd devlmer-ecosystem-engine
```

El nombre de tu carpeta en la terminal debería cambiar, mostrando algo como:
```
devlmer-ecosystem-engine $
```

#### Paso 4: Ejecuta el Instalador

Ahora ejecuta el script de instalación. Reemplaza `/ruta/a/tu/proyecto` con la ubicación de tu proyecto:

**Si tu proyecto está en el Escritorio (macOS):**
```bash
bash install.sh ~/Desktop/tu-proyecto
```

**Si tu proyecto está en Documentos (Windows):**
```bash
bash install.sh C:\Users\TuNombre\Documents\tu-proyecto
```

**Si tu proyecto está en la carpeta actual:**
```bash
bash install.sh .
```

Presiona Enter. Verás muchas líneas de información mientras DEE instala todo. Esto es normal.

**Tiempo esperado:** 2-5 minutos según tu conexión a internet.

#### Paso 5: Setup Wizard (Configuración Interactiva)

El instalador lanzará automáticamente un **Setup Wizard** que te pedirá:

```
╔══════════════════════════════════════════╗
║     DEE v3.1 — Setup Wizard             ║
╠══════════════════════════════════════════╣
║  GitHub Token (opcional):  ghp_xxx...   ║
║  Gemini API Key (opcional): AIza...     ║
║  Dominio detectado: [fintech]           ║
║  Skills a instalar: [62]              ║
╚══════════════════════════════════════════╝
```

Puedes presionar Enter para saltar cualquier paso opcional. Si no tienes API keys, el instalador funciona perfectamente sin ellas.

Para saltar el wizard completamente:
```bash
bash install.sh ~/tu-proyecto --no-github --no-external
```

#### Paso 6: Verifica la Instalación

Cuando el instalador termine, verás:

```
[✓] Devlmer Ecosystem Engine v3.1 instalado exitosamente
[✓] Motor de detección de proyecto: ACTIVO
[✓] 62 habilidades cargadas y verificadas
[✓] 8 slash commands generados en .claude/commands/
[✓] GitHub CLI verificado
[✓] Nano-Banana-MCP (Gemini) listo para imagen
[✓] Hooks de sesión inicializados
[✓] PROJECT_PROFILE.json generado

Tu proyecto está listo para desarrollo empresarial de nivel Devlmer.
```

#### Paso 7: Abre tu Proyecto en Claude Code o Cowork

```bash
# Opción A: Claude Code (terminal)
claude code ~/tu-proyecto

# Opción B: Cowork (aplicación de escritorio)
# Abre Cowork → Selecciona tu carpeta de proyecto
```

Una vez abierto, escribe `/skills` para verificar que todo está instalado. Deberías ver 62 skills disponibles.

Si algo falla, consulta la sección "Troubleshooting" abajo.

---

## What DEE Installs

### ¿Qué Instala DEE?

DEE instala automáticamente estos componentes en tu proyecto:

#### 1. 62 Habilidades Profesionales Auditadas (Skills)

Las habilidades se activan automáticamente según el contexto:

**Desarrollo de Software**
- `code-review` — Revisa el código busca errores, mejoras y patrones
- `security-audit` — Auditoría de seguridad para código de autenticación y trading
- `refactor` — Refactorización automática manteniendo funcionalidad
- `unit-test-generator` — Genera tests automáticamente
- `documentation` — Crea documentación técnica

**Diseño & Frontend**
- `frontend-design` — Crea interfaces distintivas y production-grade
- `theme-factory` — Sistema de temas y estilos
- `brand-guidelines` — Aplica colores y tipografía oficiales
- `canvas-design` — Diseño visual en PNG y PDF
- `ux-copy` — Microcopy y mensajes de error

**Gestión de Proyectos**
- `productivity:memory-management` — Sistema de memoria persistente
- `productivity:task-management` — Gestión de tareas
- `schedule` — Crea tareas programadas

**Almacenamiento & Documentos**
- `docx` — Crea y edita documentos Word
- `pdf` — Maneja archivos PDF
- `xlsx` — Crea y edita hojas de cálculo Excel
- `pptx` — Crea presentaciones PowerPoint

**Búsqueda & Análisis**
- `enterprise-search` — Búsqueda en múltiples fuentes
- `internal-comms` — Comunicación interna

**Multimedia & Inteligencia Visual**
- `slack-gif-creator` — Crea GIFs animados
- `algorithmic-art` — Arte algorítmico con p5.js

**Especialidades por Dominio**
- `skill-creator` — Crea nuevas habilidades personalizadas
- `mcp-builder` — Construye MCPs profesionales
- `api-integration` — Verifica integración con APIs
- `docker-deploy` — Verifica configuración Docker
- `commit-commands` — Asiste en commits Git

#### 2. Motor de Inteligencia de Proyecto

Un sistema que:
- **Detecta automáticamente** tu tipo de proyecto analizando stack y archivos de configuración
- **Carga configuración personalizada** según tu tecnología y patrón arquitectónico
- **Activa habilidades** relevantes contexto-inteligentemente
- **Genera agentes** especializados basados en tu pila tecnológica

#### 3. Hooks de Sesión Automáticos

Se ejecutan automáticamente cuando abres tu proyecto:
- `auto-scan` — Verifica la salud del proyecto
- `auto-verify` — Valida cambios en backend/frontend
- `auto-test` — Ejecuta tests si existen
- `fingerprint-update` — Actualiza la detección de proyecto

#### 4. Recomendaciones de MCP (Model Context Providers)

DEE recomienda automáticamente MCPs útiles:
- Google Drive / Notion / Asana (gestión)
- Cloudflare / AWS (infraestructura)
- Slack (comunicación)
- GitHub / GitLab (control de versiones)
- Y muchos más según tu proyecto

#### 5. Agentes Generados

DEE crea automáticamente agentes especializados:
- **CEO Agent** — Coordina decisiones y verifica código
- **Backend Agent** — Especialista en servidor (FastAPI, NestJS, etc.)
- **Frontend Agent** — Especialista en UI/UX
- **DevOps Agent** — Gestión de infraestructura
- **QA Agent** — Testing y calidad

#### 6. GitHub CLI Integration

DEE se integra con tu autenticación local de GitHub CLI:
- **Sin credenciales adicionales** — usa tu autenticación de GitHub CLI existente
- **Compatible** con repositorios privados y públicos
- **Respeta permisos** — mantiene la seguridad de tus repositorios
- **Integración MCP** — accede a GitHub mediante Model Context Providers
- **Listo de inmediato** — funciona después de `gh auth login`

**Beneficios:**
- No necesitas API keys adicionales en variables de entorno
- Usa tokens seguros que ya están configurados en tu máquina
- Integración transparente con herramientas estándar de GitHub
- Funciona con la configuración de permisos que ya tienes

#### 7. Nano-Banana-MCP - Generación de Imágenes con Gemini (NUEVO)

DEE integra **Nano-Banana-MCP** para generación inteligente de imágenes:
- **Generación de imágenes basada en texto** usando Google Gemini
- **Ideal para diseño de UI/UX** (mockups, prototipos visuales)
- **Generación de gráficos** (dashboards, reportes, charts)
- **Visualización de datos** complejos
- **Compatibilidad con pipelines** de diseño existentes
- **Optimizado para web y mobile**

**Casos de uso:**
- Crear thumbnails y preview images
- Generar mockups de features
- Visualizar arquitectura de sistemas
- Producir assets de marketing
- Crear gráficos de trading/finanzas

---

## Supported Domains

### Dominios Detectados (22 patrones)

DEE detecta automáticamente y optimiza para estos tipos de proyecto:

| Dominio | Descripción | Habilidades Cargadas |
|---------|-------------|---------------------|
| **Frontend - React** | Aplicaciones React con Vite, Next.js | frontend-design, theme-factory, ux-copy |
| **Frontend - Vue** | Aplicaciones Vue 3+, Nuxt | frontend-design, theme-factory |
| **Frontend - Angular** | Aplicaciones Angular, Ionic | frontend-design, ui-components |
| **Frontend - Svelte** | Aplicaciones Svelte, SvelteKit | frontend-design, theme-factory |
| **Backend - FastAPI** | Servidores FastAPI (Python async) | code-review, api-integration, docker-deploy |
| **Backend - NestJS** | Servidores NestJS (TypeScript) | code-review, api-integration, docker-deploy |
| **Backend - Django** | Servidores Django (Python) | code-review, api-integration, docker-deploy |
| **Backend - Express** | Servidores Express (Node.js) | code-review, api-integration, docker-deploy |
| **Database - PostgreSQL** | Bases de datos PostgreSQL + TimescaleDB | db-migration, data-validation |
| **Database - MongoDB** | Bases de datos MongoDB + Atlas | db-migration, data-validation |
| **Database - DynamoDB** | Bases de datos AWS DynamoDB | db-migration, data-validation |
| **Mobile - React Native** | Aplicaciones móviles React Native | frontend-design, mobile-testing |
| **Mobile - Flutter** | Aplicaciones Flutter (Dart) | frontend-design, mobile-testing |
| **Trading Bot** | Bots de trading algorítmico (Binance, etc.) | security-audit, api-integration, risk-assessment |
| **Data Science** | Proyectos de ML, análisis de datos (Python) | code-review, ml-validation, data-pipeline |
| **DevOps / Cloud** | Infraestructura Docker, Kubernetes, AWS | docker-deploy, security-audit, k8s-validation |
| **Monorepo** | Monorepos con Nx, Turborepo, Lerna | workspace-tools, dependency-graph |
| **Blockchain** | Smart contracts, Web3 (Solidity, Hardhat) | security-audit, contract-validation |
| **CMS** | Headless CMS (Strapi, Contentful) | content-validation, schema-management |
| **E-Commerce** | Tiendas online (Shopify, WooCommerce, custom) | payment-validation, inventory-management |
| **Chat / Real-time** | Aplicaciones de chat, WebSocket, Socket.io | websocket-validation, real-time-testing |
| **Internal Tools** | Dashboards, admin panels, herramientas internas | dashboard-audit, performance-optimization |

Cuando abres tu proyecto, DEE automáticamente:
1. Examina `package.json`, `pyproject.toml`, `go.mod`, etc.
2. Identifica tu dominio
3. Carga las habilidades y blueprints correspondientes
4. Se ajusta a tu pila tecnológica

---

## Usage

### Cómo Usar DEE

Después de instalar, **no necesitas hacer nada especial**. DEE funciona automáticamente:

#### 1. Abre tu Proyecto en Claude Code o Cowork

- Ve a https://claude.ai/code
- O abre la aplicación Cowork
- Abre tu carpeta de proyecto

#### 2. DEE Se Activa Automáticamente

Cuando abres tu proyecto, DEE:
- Detecta automáticamente tu tipo de proyecto
- Carga las habilidades relevantes
- Ejecuta hooks de verificación
- Propone soluciones contexto-inteligentes
- Verifica GitHub CLI si tu proyecto es un repositorio
- Prepara Nano-Banana-MCP para generación visual

#### 3. Las Habilidades Se Activan por Contexto

**Ejemplo 1: Escribes código Python en tu backend**
```python
def calculate_risk_exposure(position_size, leverage):
    # Tu código
```
DEE automáticamente carga `security-audit` y `code-review` y verifica tu código.

**Ejemplo 2: Editas un componente React**
```tsx
export function Dashboard() {
  // Tu código JSX
}
```
DEE automáticamente carga `frontend-design`, `ux-copy` y verifica con Playwright.

**Ejemplo 3: Trabajas con trading/binance**
DEE automáticamente carga `security-audit`, `api-integration` y `risk-assessment`.

**Ejemplo 4: Necesitas generar una imagen para tu UI**
DEE accede a Nano-Banana-MCP y genera mockups visuales usando Gemini.

#### 4. Solicita Habilidades Específicas

Puedes invocar manualmente cualquier habilidad escribiendo:
```
/code-review
/security-audit
/api-integration
/theme-factory
/github-auth
/nano-banana
```

#### 5. El Motor de Inteligencia Funciona Continuamente

DEE mantiene un "perfil inteligente" de tu proyecto:
- Aprende qué problemas encuentras frecuentemente
- Sugiere habilidades antes de que las necesites
- Adapta las respuestas a tu arquitectura
- Mejora continuamente
- Sincroniza cambios con GitHub automáticamente

---

## What You See in Claude Code

### Lo Que Ves en Claude Code Después de Instalar

Después de instalar DEE y abrir tu proyecto en Claude Code o Cowork, verás todo integrado nativamente:

#### `/skills` — Tus Habilidades Instaladas

Al escribir `/skills` en Claude Code verás todas las habilidades cargadas:

```
> /skills

  Installed Skills (62):
  ├── code-review          Code review con mejores prácticas
  ├── security-audit       Auditoría de seguridad enterprise
  ├── senior-architect     Arquitectura de sistemas
  ├── copywriting          Copy profesional y marketing
  ├── frontend-design      Diseño frontend production-grade
  ├── brand-identity       Identidad visual y branding
  ├── ui-design-system     Sistema de diseño UI
  ├── seo-optimizer        Optimización SEO
  ├── brainstorming        Ideación y lluvia de ideas
  ├── file-organizer       Organización de archivos
  └── [52+ más según tu dominio]
```

#### `/command-name` — Slash Commands Directos

Cada skill instalado genera un slash command invocable directamente:

```
> /code-review        → Ejecuta revisión de código
> /security-audit     → Auditoría de seguridad
> /senior-architect   → Análisis arquitectónico
> /copywriting        → Genera copy profesional
> /brainstorming      → Sesión de ideación
```

#### `/mcp` — Servidores MCP Conectados

```
> /mcp

  Connected MCP Servers (31):
  ├── github           Issues, PRs, branches, code search
  ├── google-calendar  Eventos, reuniones, agenda
  ├── notion           Documentación, wikis, bases de datos
  ├── asana            Gestión de tareas y proyectos
  ├── cloudflare       Workers, D1, R2, KV
  ├── cloudinary       Media, imágenes, transformaciones
  ├── canva            Diseño gráfico
  └── [8+ más según tu dominio]
```

#### `/plugin` — Plugins Activos

```
> /plugin

  Active Plugins:
  ├── playwright       Verificación visual frontend
  ├── context7         Docs actualizadas de librerías
  ├── code-simplifier  Simplificación de código
  ├── feature-dev      Desarrollo guiado de features
  ├── commit-commands  Git commits profesionales
  ├── claude-mem       Memoria persistente
  └── security-guidance Guía de seguridad
```

---

## Project Structure

### Estructura del Proyecto Instalado

Después de ejecutar DEE, tu proyecto tendrá esta estructura adicional:

```
tu-proyecto/
├── .claude/
│   ├── skills/                          # 62 habilidades personalizadas
│   │   ├── code-review/
│   │   │   └── SKILL.md
│   │   ├── security-audit/
│   │   │   └── SKILL.md
│   │   └── [54+ más]
│   ├── commands/                        # Slash commands auto-generados
│   │   ├── code-review.md              # → /code-review
│   │   ├── security-audit.md           # → /security-audit
│   │   ├── senior-architect.md         # → /senior-architect
│   │   └── [5+ más]
│   ├── blueprints/                      # Modelos de referencia (22)
│   │   ├── frontend-react/
│   │   ├── backend-fastapi/
│   │   └── [20 más]
│   ├── agents/                          # Agentes generados automáticamente
│   │   ├── ceo-agent.md
│   │   ├── backend-agent.md
│   │   ├── frontend-agent.md
│   │   └── [más según tu dominio]
│   ├── hooks/                           # Scripts de sesión automática
│   │   ├── on-session-start.sh
│   │   ├── on-backend-change.sh
│   │   └── on-frontend-change.sh
│   ├── config/
│   │   ├── project-fingerprint.json     # Detección automática
│   │   ├── mcp-recommendations.json     # MCPs sugeridos
│   │   ├── github-config.json           # Estado de GitHub CLI
│   │   └── nano-banana-config.json      # Configuración Gemini
│   ├── settings.json                    # Configuración de Claude Code
│   ├── PROJECT_PROFILE.json             # Perfil inteligente del proyecto
│   └── CLAUDE.md                        # Instrucciones globales auto-generadas
├── CLAUDE.md                            # Instrucciones personalizadas para Claude
├── skills-lock.json                     # Registro de skills instalados
└── [tu código existente sin cambios]
```

**Notas importantes:**
- DEE **no modifica tu código existente** — solo agrega la carpeta `.claude/`
- Los slash commands se generan automáticamente desde los skills instalados
- Puedes editar `CLAUDE.md` para personalizar el comportamiento de Claude
- Los cambios son completamente reversibles: elimina `.claude/` y `CLAUDE.md` para desinstalar
- El `PROJECT_PROFILE.json` contiene el fingerprint inteligente de tu proyecto

---

## GitHub Integration

### GitHub CLI Integration

DEE v3.1 verifica e integra con tu autenticación local de GitHub CLI:

#### Cómo Funciona

Cuando DEE detecta un proyecto con repositorio GitHub:
1. Verifica que tengas `gh` (GitHub CLI) instalado
2. Comprueba tu estado de autenticación con `gh auth status`
3. Permite que uses las herramientas MCP de GitHub de forma segura
4. Integra con tus tokens existentes de GitHub CLI (no almacena credenciales)

#### Características

**Seguridad:**
- No almacena credenciales en `.claude/config/`
- Usa los tokens seguros de GitHub CLI que ya existen en tu máquina
- Respeta los permisos que ya configuraste en GitHub CLI
- No requiere API keys adicionales

**Integración:**
- Acceso a repositorios según permisos de GitHub CLI
- Compatible con repositorios privados y públicos
- Funciona con GitHub Actions si tienes permisos
- Soporte para múltiples cuentas GitHub (si están configuradas en CLI)

**Configuración Inicial:**
```bash
# Primero, autenticate con GitHub CLI (solo una vez)
gh auth login

# Luego, DEE usará esos tokens automáticamente
./install.sh tu-proyecto
```

#### Requisitos

- GitHub CLI (`gh`) instalado: https://cli.github.com
- Autenticación con `gh auth login` completada
- Permisos en GitHub configurados según necesites

---

## Nano-Banana-MCP - Image Generation

### Nano-Banana-MCP: Generación Inteligente de Imágenes (NUEVO)

DEE integra **Nano-Banana-MCP**, que conecta con Google Gemini para generación de imágenes en tiempo real:

#### Qué es Nano-Banana?

Nano-Banana-MCP es un Model Context Provider que:
- Genera imágenes de alta calidad usando Google Gemini
- Acepta prompts en texto y produce assets visuales
- Se optimiza automáticamente para web y mobile
- Integra seamlessly con tu workflow de desarrollo

#### Casos de Uso

**1. Diseño de UI/UX**
```
/nano-banana "Dashboard moderne con gráficos de trading en tiempo real,
colores azul-cyan, glassmorphism, 1920x1080"
```

**2. Mockups de Features**
```
/nano-banana "Interfaz de carrito de compras con 3 productos,
botón de checkout, fondo gris claro, estilo minimalista"
```

**3. Gráficos de Datos**
```
/nano-banana "Gráfico de líneas mostrando tendencia alcista de
precio de Bitcoin, eje Y en USD, eje X fechas, colores verde-rojo"
```

**4. Visualización de Arquitectura**
```
/nano-banana "Diagrama de arquitectura de microservicios:
API Gateway → 3 servicios backend → PostgreSQL, estilo moderno"
```

**5. Assets de Marketing**
```
/nano-banana "Banner promocional para plataforma de trading,
logo Devlmer, colores corporativos, 1200x600px, profesional"
```

#### Configuración

En `CLAUDE.md`:
```yaml
nano_banana:
  enabled: true
  provider: google_gemini
  quality: high              # high, medium, low
  format: png                # png, jpg, webp
  auto_optimize: true        # Optimiza para web automáticamente
  cache_results: true        # Cachea imágenes generadas
```

#### Características

- **Calidad Enterprise**: Imágenes de 1024x1024 a 2048x2048
- **Optimización Automática**: Compresión y formato inteligente
- **Caching**: Reutiliza imágenes generadas previamente
- **Versionado**: Mantiene historial de generaciones
- **Integración Git**: Almacena assets en repositorio

---

## Customization

### Personalización

DEE está diseñado para ser completamente personalizable:

#### 1. Edita el Archivo CLAUDE.md

Después de la instalación, encontrarás un archivo `CLAUDE.md` en tu proyecto. Este archivo controla cómo funciona DEE:

```markdown
# CLAUDE.md

## User Preferences — Tu Nombre

- **Auto-use everything**: [Configura qué se auto-activa]
- **Language**: Spanish / English / [otro]
- **Decision authority**: Especifica quién toma decisiones
- **GitHub CLI**: Verificación de autenticación local
- **Nano-Banana MCP**: Preferencias de generación de imágenes
- **Custom rules**: [Tus propias reglas]

## Project Overview
[Descripción de tu proyecto]

## Architecture
[Arquitectura específica]
```

Puedes modificar:
- Qué habilidades se auto-activan
- Idioma de respuestas
- Preferencias de verificación de GitHub CLI
- Parámetros de Nano-Banana-MCP
- Reglas personalizadas

#### 2. Crea Skills Personalizadas

Para crear una habilidad personalizada para tu proyecto:

```bash
bash .claude/scripts/create-skill.sh nombre-de-mi-skill
```

Esto crea:
```
.claude/skills/nombre-de-mi-skill/
├── SKILL.md              # Definición
├── prompt.md             # Instrucciones para Claude
└── examples.md           # Ejemplos de uso
```

#### 3. Modifica Blueprints

Los blueprints (22 modelos) están en `.claude/blueprints/`. Puedes:

- Copiar un blueprint existente y adaptarlo
- Crear uno nuevo específico para tu proyecto
- Ajustar las recomendaciones de MCP

Ejemplo:
```
.claude/blueprints/
├── backend-fastapi/
│   ├── structure.md
│   ├── dependencies.md
│   ├── environment.md
│   └── validation-rules.md
```

#### 4. Agrega MCPs Recomendados

En `CLAUDE.md`, especifica qué MCPs activar:

```yaml
mcps:
  - cloudflare    # Infraestructura
  - notion        # Documentación
  - asana         # Gestión de tareas
  - slack         # Comunicación
  - github        # Control de versiones
```

#### 5. Configura Hooks Personalizados

En `.claude/hooks/`, crea scripts que se ejecuten automáticamente:

```bash
# Ejemplo: .claude/hooks/on-backend-change.sh
#!/bin/bash
echo "Backend cambió - ejecutando verificación personalizada..."
PYTHONPATH=. pytest tests/ -v
```

#### 6. Personaliza el Comportamiento de Agentes

En `.claude/agents/`, edita cómo se comportan los agentes:

```markdown
# ceo-agent.md

## Rol: CEO Agent

Tu responsabilidad es:
- Coordinar decisiones
- Verificar código con evidencia
- [Tus propias instrucciones]
```

---

## Troubleshooting

### Solución de Problemas

#### "No reconozco el comando 'bash'"

**Problema:** Estás en Windows y `bash` no está disponible.

**Solución 1: Usa PowerShell en su lugar**
En lugar de `bash install.sh`, escribe:
```powershell
./install.sh /ruta/tu/proyecto
```

**Solución 2: Instala Git Bash**
- Descarga Git desde https://git-scm.com/download/win
- Durante la instalación, selecciona "Git Bash"
- Abre "Git Bash" desde Inicio y ejecuta el comando

#### "Permission denied" al ejecutar install.sh

**En macOS/Linux:**
Primero hazlo ejecutable:
```bash
chmod +x install.sh
bash install.sh /ruta/tu/proyecto
```

#### "No se encuentra el directorio del proyecto"

**Verifica la ruta:**
```bash
# Primero, lista dónde estás
pwd

# Luego, lista el contenido
ls -la

# Navega a tu proyecto
cd /ruta/correcta/al/proyecto

# Ejecuta DEE desde tu directorio
bash ../devlmer-ecosystem-engine/install.sh .
```

#### "Node.js o Python no encontrado"

**Verifica la instalación:**
```bash
node --version          # Debería mostrar v18 o superior
npm --version           # Debería mostrar 9 o superior
python3 --version       # Debería mostrar 3.8 o superior
```

Si falta algo:
- **Node:** Descarga desde https://nodejs.org/
- **Python:** Descarga desde https://www.python.org/
- **En macOS con Homebrew:**
  ```bash
  brew install node
  brew install python3
  ```

#### "Git clone failed" - Error de conexión

**Soluciones:**
1. Verifica tu conexión a internet
2. Intenta de nuevo
3. Si tienes proxy, configúralo:
   ```bash
   git config --global http.proxy [proxy]
   git config --global https.proxy [proxy]
   ```

#### El instalador se detiene a mitad

**Reinicia el proceso:**
```bash
# Navega a devlmer-ecosystem-engine
cd devlmer-ecosystem-engine

# Ejecuta el instalador de nuevo (es idempotente)
bash install.sh /ruta/tu/proyecto
```

El instalador es seguro ejecutarlo múltiples veces.

#### "Devlmer Ecosystem Engine no se activa en Claude Code"

**Verifica:**
1. Abre el archivo `CLAUDE.md` en tu proyecto
2. Asegúrate de que esté bien formado (sin errores de sintaxis)
3. Reinicia Claude Code completamente (cierra y abre de nuevo)
4. Si persiste, verifica la consola de errores: `F12` → Console

#### "Las habilidades no se auto-activan"

**Verifica `CLAUDE.md`:**
```yaml
# Debe tener esta línea
Auto-use everything: ALL skills enabled
```

**Verifica `.claude/config/dee-config.yaml`:**
```yaml
auto_activation:
  enabled: true
  context_detection: true
```

#### "GitHub CLI no funciona"

**Verifica tu autenticación de GitHub:**
```bash
gh auth status
```

Si no ves tu usuario, autenticate primero:
```bash
gh auth login
```

#### "Nano-Banana-MCP no genera imágenes"

**Verifica credenciales de Gemini:**
```bash
cat .claude/config/nano-banana-config.json
```

**Verifica en CLAUDE.md:**
```yaml
nano_banana:
  enabled: true
  provider: google_gemini
```

**Reinicia MCP:**
```
/nano-banana --reset
```

#### "Mi proyecto es muy grande y DEE tarda mucho"

**Soluciones:**
1. Crea un archivo `.deeignore` para excluir directorios grandes:
   ```
   node_modules/
   .git/
   __pycache__/
   venv/
   build/
   dist/
   ```
2. Reinicia el instalador

#### "Quiero desinstalar DEE"

**Paso 1:** Elimina la carpeta `.claude/`:
```bash
rm -rf .claude/
```

**Paso 2 (Opcional):** Elimina el archivo `CLAUDE.md`:
```bash
rm CLAUDE.md
```

**Listo.** Tu proyecto vuelve al estado anterior.

#### "¿Cómo actualizo DEE?"

```bash
cd devlmer-ecosystem-engine
git pull origin main

# Actualiza en tu proyecto
bash install.sh /ruta/tu/proyecto
```

---

## File Structure Reference

### Referencia Rápida de Archivos

**Archivos principales que DEE crea:**

| Archivo/Carpeta | Propósito |
|-----------------|-----------|
| `.claude/` | Carpeta raíz de DEE (no editar manualmente) |
| `.claude/skills/` | 62 habilidades profesionales auditadas |
| `.claude/blueprints/` | Plantillas de configuración por tipo de proyecto |
| `.claude/agents/` | Agentes especializados (CEO, Backend, Frontend, etc.) |
| `.claude/hooks/` | Scripts que se ejecutan automáticamente |
| `.claude/config/project-fingerprint.json` | Detección automática de tu proyecto |
| `.claude/config/github-config.json` | Estado de GitHub CLI (informativo) |
| `.claude/config/nano-banana-config.json` | Configuración Nano-Banana-MCP |
| `.claude/config/dee-config.yaml` | Configuración de DEE |
| `.claude/memory/` | Memoria persistente entre sesiones |
| `CLAUDE.md` | Instrucciones personalizadas (EDITABLE) |
| `.deeignore` | Archivos ignorados por DEE |

---

## Tips & Best Practices

### Consejos para Aprovechar DEE al Máximo

**1. Mantén CLAUDE.md actualizado**
- Actualiza tu descripción de proyecto
- Especifica cambios en la arquitectura
- Documenta cambios arquitectónicos
- DEE aprende de esto

**2. Usa comandos slash para evocar habilidades**
- `/code-review` — Revisa tu código
- `/security-audit` — Verifica seguridad
- `/theme-factory` — Crea estilos
- `/mcp` — Gestiona servidores Model Context Provider
- `/nano-banana` — Genera imágenes con Gemini
- Y muchos más

**3. Verifica los hooks**
- Si algo no funciona, revisa `.claude/hooks/`
- Puedes editar o deshabilitar hooks personalizados

**4. Personaliza sin miedo**
- Crea skills propios
- Modifica blueprints
- Personaliza reglas y comportamientos
- DEE está hecho para adaptarse

**5. Colaboración en equipo**
- Comparte el repositorio con tu equipo
- Todos obtienen las mismas habilidades y reglas
- El archivo `CLAUDE.md` sincroniza preferencias
- Cada usuario mantiene su propia configuración local

**6. Aprovecha Nano-Banana-MCP**
- Genera mockups antes de codificar
- Crea gráficos para documentación
- Produce assets de diseño automáticamente
- Itera rápidamente en UI/UX

---

## Support & Community

### Soporte

**Documentación:**
- Visita https://github.com/Soyelijah/devlmer-ecosystem-engine

**Reportar problemas:**
- GitHub Issues: https://github.com/Soyelijah/devlmer-ecosystem-engine/issues

**Comunidad:**
- Slack: [Enlace a Slack de comunidad]
- Discord: [Enlace a Discord de comunidad]

---

## License

MIT License

Puedes usar, modificar y distribuir DEE libremente, siempre que:
- Reconozcas a los autores originales
- Incluyas una copia de la licencia MIT
- No vendas DEE como tuyo propio

Texto completo en: LICENSE (incluido en el repositorio)

---

## Credits & Authors

### Créditos

**Devlmer Ecosystem Engine v3.1.1**

Creado y mantenido por:
- **Pierre Solier** (Devlmer) — Conceptualización, diseño, desarrollo

**Agradecimientos especiales a:**
- El equipo de Anthropic por Claude Code y la capacidad de MCPs
- Google por Gemini AI (Nano-Banana-MCP)
- GitHub por control de versiones y APIs
- Comunidad open source por herramientas inspiradoras
- Usuarios tempranos que enviaron feedback

**Tecnologías base:**
- Claude AI (Anthropic)
- Google Gemini (Nano-Banana-MCP)
- Node.js & npm
- Python 3
- Git
- GitHub CLI (opcional, para integración)

---

## Frequently Asked Questions (FAQ)

### Preguntas Frecuentes

**P: ¿DEE funciona offline?**
R: No. DEE requiere conexión a internet para descargar habilidades, conectar con MCPs, y comunicarse con Claude API. Sin embargo, una vez que las sesiones están en ejecución, algunos componentes pueden funcionar offline.

**P: ¿Es seguro instalar DEE?**
R: Sí. DEE no modifica tu código existente. Todo se instala en `.claude/`. Puedes desinstalar eliminando esa carpeta. No almacena credenciales — usa tokens existentes de GitHub CLI cuando los tienes.

**P: ¿Puedo usar DEE en equipos?**
R: Sí. Comparte el repositorio entero con tu equipo. Todos obtendrán las mismas habilidades y configuración. Cada usuario mantiene su propia configuración de GitHub CLI de forma independiente.

**P: ¿Funciona con proyectos existentes?**
R: Sí. DEE funciona con cualquier proyecto existente. No necesita estar vacío.

**P: ¿Qué pasa si tengo múltiples proyectos?**
R: Instala DEE en cada uno por separado:
```bash
bash install.sh ~/proyecto1
bash install.sh ~/proyecto2
bash install.sh ~/proyecto3
```
Cada proyecto tendrá su propio `.claude/` con configuración independiente.

**P: ¿Puedo customizar completamente DEE?**
R: Sí. Edita `CLAUDE.md`, crea skills propios, modifica blueprints, configura GitHub y Nano-Banana. DEE está diseñado para adaptarse.

**P: ¿Qué hago si DEE no detecta correctamente mi proyecto?**
R: Edita `.claude/config/project-fingerprint.json` manualmente o actualiza `CLAUDE.md` con la información correcta.

**P: ¿Puedo usar DEE sin Claude Code/Cowork?**
R: Técnicamente sí, pero no obtendrías los beneficios completos. DEE funciona mejor integrado en Claude Code o Cowork.

**P: ¿Se puede ejecutar DEE desde CI/CD?**
R: Sí. El instalador es compatible con pipelines de CI/CD. Consulta la documentación avanzada para detalles.

**P: ¿Cómo se integra DEE con GitHub?**
R: DEE verifica tu autenticación local de GitHub CLI con `gh auth status`. No requiere credenciales adicionales ni almacena tokens. Usa la configuración que ya tienes en tu máquina.

**P: ¿Puedo usar Nano-Banana-MCP sin Gemini API?**
R: No, Nano-Banana-MCP requiere configuración de Google Gemini. DEE te guiará en la configuración inicial.

---

## Advanced Usage

### Uso Avanzado

Para usuarios avanzados, DEE ofrece capacidades adicionales:

#### Instalación sin interfaz gráfica

```bash
bash install.sh /ruta/proyecto --headless --auto-approve
```

#### Especificar dominio manualmente

```bash
bash install.sh /ruta/proyecto --domain backend-fastapi
```

#### Instalar solo skills específicas

```bash
bash install.sh /ruta/proyecto --skills code-review,security-audit
```

#### Generar reporte de detección

```bash
bash install.sh /ruta/proyecto --generate-report
```

#### Verificar estado de GitHub CLI

```bash
gh auth status
```

Si esto muestra tu usuario autenticado, DEE usará esa configuración automáticamente.

#### Nano-Banana-MCP con parámetros avanzados

```bash
/nano-banana --prompt "..." --size 2048x2048 --quality ultra --style realistic
```

Consulta `./install.sh --help` para todas las opciones.

---

## Getting Started Checklist

### Lista de Verificación para Comenzar

Usa esta checklist para asegurar que todo está listo:

- [ ] Node.js 18+ instalado
- [ ] Python 3.8+ instalado
- [ ] Claude Code o Cowork instalado
- [ ] Git instalado
- [ ] Terminal abierta
- [ ] Repositorio DEE clonado
- [ ] Ruta del proyecto identificada
- [ ] Instalador ejecutado
- [ ] Mensaje de éxito recibido
- [ ] Proyecto abierto en Claude Code
- [ ] CLAUDE.md revisado y personalizado
- [ ] GitHub CLI verificado (opcional)
- [ ] Nano-Banana-MCP verificado (opcional)
- [ ] Primer skill invocado (ej: `/code-review`)

Si todos los elementos tienen check, estás listo para empezar.

---

**Última actualización:** Abril 2026
**Versión actual:** DEE v3.1.1 by Devlmer
**Repositorio:** https://github.com/Soyelijah/devlmer-ecosystem-engine
**Lema:** Intelligent ecosystems for every project

---

*Created with excellence by Pierre Solier (Devlmer) for developers who demand enterprise-grade tooling, intelligent automation, and seamless collaboration without compromise.*
