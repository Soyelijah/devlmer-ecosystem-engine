---
# DYSA Ecosystem Engine v3.0
## Installation & User Guide (Spanish)

**Version:** 3.0
**Author:** DYSA / Pierre Solier
**License:** MIT
**Last Updated:** April 2026

---

## What is DEE?

### ¿Qué es DEE?

DYSA Ecosystem Engine (DEE) es un motor inteligente de automatización que detecta automáticamente qué tipo de proyecto estás utilizando y **instala todo lo que necesitas para trabajar a nivel empresarial** en un único comando.

Sin importar si trabajas con:
- Aplicaciones React, Vue, Angular o Svelte
- Servidores FastAPI, NestJS, Django o Express
- Bases de datos PostgreSQL, MongoDB o DynamoDB
- Comercio algorítmico o trading bot
- Aplicaciones móviles, data science, o infraestructura en la nube

DEE detecta tu tipo de proyecto y carga automáticamente:
- **28+ habilidades profesionales** especializadas (skills)
- **Motor de inteligencia de proyecto** con 22 modelos de referencia (blueprints)
- **Plugins y MCPs** recomendados
- **Hooks de sesión** para auto-verificación
- **Agentes generados automáticamente** basados en tu pila tecnológica

El resultado: Una experiencia de desarrollo completamente personalizada y lista para empresas, sin configuración manual.

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
git clone https://github.com/Memory-Bank/dysa-ecosystem-engine.git
cd dysa-ecosystem-engine
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

El instalador tardará entre 2-5 minutos. Cuando termine, verás un mensaje de confirmación.

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
git clone https://github.com/Memory-Bank/dysa-ecosystem-engine.git
```

Verás un mensaje como:
```
Cloning into 'dysa-ecosystem-engine'...
remote: Enumerating objects: 1200, done.
...
```

Espera hasta que termine (puede tardar 30-60 segundos).

#### Paso 3: Navega al Directorio DEE

Copia y pega esta línea:

```bash
cd dysa-ecosystem-engine
```

El nombre de tu carpeta en la terminal debería cambiar, mostrando algo como:
```
dysa-ecosystem-engine $
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

#### Paso 5: Verifica la Instalación

Cuando el instalador termine, verás:

```
[✓] DYSA Ecosystem Engine v3.0 instalado exitosamente
[✓] Motor de detección de proyecto: ACTIVO
[✓] 28 habilidades cargadas
[✓] Hooks de sesión inicializados

Tu proyecto está listo para desarrollo empresarial.
```

Si algo falla, consulta la sección "Troubleshooting" abajo.

---

## What DEE Installs

### ¿Qué Instala DEE?

DEE instala automáticamente estos componentes en tu proyecto:

#### 1. 28+ Habilidades Profesionales (Skills)

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

**Multimedia**
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
- **Detecta automáticamente** tu tipo de proyecto (22 dominios soportados)
- **Carga blueprints** (22 modelos de referencia) personalizados para tu stack
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

---

## Supported Domains

### Dominios Soportados (22)

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

#### 4. Solicita Habilidades Específicas

Puedes invocar manualmente cualquier habilidad escribiendo:
```
/code-review
/security-audit
/api-integration
/theme-factory
```

#### 5. El Motor de Inteligencia Funciona Continuamente

DEE mantiene un "perfil inteligente" de tu proyecto:
- Aprende qué problemas encuentras frecuentemente
- Sugiere habilidades antes de que las necesites
- Adapta las respuestas a tu arquitectura
- Mejora continuamente

---

## Project Structure

### Estructura del Proyecto Instalado

Después de ejecutar DEE, tu proyecto tendrá esta estructura adicional:

```
tu-proyecto/
├── .claude/
│   ├── skills/                          # Habilidades personalizadas
│   │   ├── code-review/
│   │   ├── security-audit/
│   │   └── [26 más]
│   ├── blueprints/                      # Modelos de referencia (22)
│   │   ├── frontend-react/
│   │   ├── backend-fastapi/
│   │   ├── database-postgresql/
│   │   └── [19 más]
│   ├── agents/                          # Agentes generados automáticamente
│   │   ├── ceo-agent.md
│   │   ├── backend-agent.md
│   │   ├── frontend-agent.md
│   │   └── [más según tu proyecto]
│   ├── hooks/                           # Scripts de sesión automática
│   │   ├── on-session-start.sh
│   │   ├── on-backend-change.sh
│   │   ├── on-frontend-change.sh
│   │   └── on-test-run.sh
│   ├── config/
│   │   ├── project-fingerprint.json     # Detección automática
│   │   ├── mcp-recommendations.json     # MCPs sugeridos
│   │   └── dee-config.yaml              # Configuración de DEE
│   └── memory/
│       ├── claude-mem.json              # Memoria persistente
│       └── session-history.json
├── CLAUDE.md                            # Instrucciones personalizadas para Claude
├── .deeignore                           # Archivos ignorados por DEE
└── [tu código existente sin cambios]
```

**Notas importantes:**
- DEE **no modifica tu código existente**
- Todos los archivos de DEE están en `.claude/`
- Puedes editar `CLAUDE.md` para personalizar el comportamiento
- Los cambios son completamente reversibles

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
- **Custom rules**: [Tus propias reglas]

## Project Overview
[Descripción de tu proyecto]

## Architecture
[Arquitectura específica]
```

Puedes modificar:
- Qué habilidades se auto-activan
- Idioma de respuestas
- Reglas personalizadas
- Preferencias de formato

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
bash ../dysa-ecosystem-engine/install.sh .
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
# Navega a dysa-ecosystem-engine
cd dysa-ecosystem-engine

# Ejecuta el instalador de nuevo (es idempotente)
bash install.sh /ruta/tu/proyecto
```

El instalador es seguro ejecutarlo múltiples veces.

#### "DYSA Ecosystem Engine no se activa en Claude Code"

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
cd dysa-ecosystem-engine
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
| `.claude/skills/` | 28+ habilidades profesionales |
| `.claude/blueprints/` | 22 modelos de referencia por dominio |
| `.claude/agents/` | Agentes especializados (CEO, Backend, Frontend, etc.) |
| `.claude/hooks/` | Scripts que se ejecutan automáticamente |
| `.claude/config/project-fingerprint.json` | Detección automática de tu proyecto |
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
- DEE aprende de esto

**2. Usa comandos slash para evocar habilidades**
- `/code-review` — Revisa tu código
- `/security-audit` — Verifica seguridad
- `/theme-factory` — Crea estilos
- Y muchos más

**3. Verifica los hooks**
- Si algo no funciona, revisa `.claude/hooks/`
- Puedes editar o deshabilitar hooks personalizados

**4. Personaliza sin miedo**
- Crea skills propios
- Modifica blueprints
- DEE está hecho para adaptarse

**5. Colaboración en equipo**
- Comparte el repositorio con tu equipo
- Todos obtienen las mismas habilidades y reglas
- El archivo `CLAUDE.md` sincroniza preferencias

---

## Support & Community

### Soporte

**Documentación:**
- Visita https://github.com/Memory-Bank/dysa-ecosystem-engine

**Reportar problemas:**
- GitHub Issues: https://github.com/Memory-Bank/dysa-ecosystem-engine/issues

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

**DYSA Ecosystem Engine v3.0**

Creado y mantenido por:
- **Pierre Solier** (DYSA) — Conceptualización, diseño, desarrollo

**Agradecimientos especiales a:**
- El equipo de Anthropic por Claude Code y la capacidad de MCPs
- Comunidad open source por herramientas inspiradoras
- Usuarios tempranos que enviaron feedback

**Tecnologías base:**
- Claude AI (Anthropic)
- Node.js & npm
- Python 3
- Git

---

## Frequently Asked Questions (FAQ)

### Preguntas Frecuentes

**P: ¿DEE funciona offline?**
R: No. DEE requiere conexión a internet porque se comunica con Claude API y MCPs. Sin embargo, una vez que una sesión está en ejecución, algunos componentes pueden funcionar offline.

**P: ¿Es seguro instalar DEE?**
R: Sí. DEE no modifica tu código existente. Todo se instala en `.claude/`. Puedes desinstalar eliminando esa carpeta.

**P: ¿Puedo usar DEE en equipos?**
R: Sí. Comparte el repositorio entero con tu equipo. Todos obtendrán las mismas habilidades, blueprints y configuración.

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
R: Sí. Edita `CLAUDE.md`, crea skills propios, modifica blueprints. DEE está diseñado para adaptarse.

**P: ¿Qué hago si DEE no detecta correctamente mi proyecto?**
R: Edita `.claude/config/project-fingerprint.json` manualmente o actualiza `CLAUDE.md` con la información correcta.

**P: ¿Puedo usar DEE sin Claude Code/Cowork?**
R: Técnicamente sí, pero no obtendrías los beneficios completos. DEE funciona mejor integrado en Claude Code o Cowork.

**P: ¿Se puede ejecutar DEE desde CI/CD?**
R: Sí. El instalador es compatible con pipelines de CI/CD. Consulta la documentación avanzada para detalles.

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
- [ ] Primer skill invocado (ej: `/code-review`)

Si todos los elementos tienen check, estás listo para empezar.

---

**Última actualización:** April 2026
**Versión actual:** DEE v3.0
**Repositorio:** https://github.com/Memory-Bank/dysa-ecosystem-engine

---

*Created with care by DYSA for developers who want enterprise-grade tooling without the complexity.*
