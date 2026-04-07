# Contributing to Devlmer Ecosystem Engine

Thank you for your interest in contributing to **Devlmer Ecosystem Engine (DEE)**. This document provides guidelines and instructions for contributing.

## Table of Contents

1. [Getting Started](#getting-started)
2. [Development Setup](#development-setup)
3. [How to Contribute](#how-to-contribute)
4. [Pull Request Process](#pull-request-process)
5. [Coding Standards](#coding-standards)
6. [Reporting Issues](#reporting-issues)

## Getting Started

Before contributing, please:

1. Read the [README](https://github.com/Soyelijah/devlmer-ecosystem-engine/blob/main/README.md) to understand the project
2. Check existing [issues](https://github.com/Soyelijah/devlmer-ecosystem-engine/issues) for related discussions
3. Review the [Code of Conduct](https://github.com/Soyelijah/devlmer-ecosystem-engine/blob/main/CODE_OF_CONDUCT.md)

## Development Setup

```bash
# Clone the repository
git clone https://github.com/Soyelijah/devlmer-ecosystem-engine.git
cd devlmer-ecosystem-engine

# Verify prerequisites
bash --version    # Bash 4.0+
python3 --version # Python 3.8+
git --version     # Git 2.20+

# Run the installer on a test project
bash install.sh /path/to/test-project --verbose
```

## How to Contribute

### Creating New Skills

Skills are the core of DEE. To contribute a new skill:

1. Create a directory under `skills/your-skill-name/`
2. Add a `SKILL.md` file following the existing skill format
3. Register the skill in `blueprints/ecosystems.json` under the appropriate domain
4. Test with `bash install.sh /path/to/test-project`

### Improving the Installer

The main installer (`install.sh`) handles project detection and ecosystem setup:

1. Fork the repository and create a feature branch
2. Make changes to `install.sh` or related scripts
3. Test on at least 3 different project types
4. Document any new flags or behaviors

### Adding MCP Integrations

MCP configurations live in `blueprints/ecosystems.json`:

1. Add the MCP definition with name, description, and configuration
2. Map it to the appropriate domain(s)
3. Test the integration end-to-end

## Pull Request Process

1. **Fork** the repository and create your branch from `main`
2. **Name** your branch descriptively: `feat/new-skill-name`, `fix/installer-bug`, `docs/readme-update`
3. **Write** clear commit messages following [Conventional Commits](https://www.conventionalcommits.org/):
   - `feat:` new features
   - `fix:` bug fixes
   - `docs:` documentation changes
   - `style:` formatting, no code change
   - `refactor:` code restructuring
   - `test:` adding or updating tests
4. **Test** your changes thoroughly
5. **Submit** a Pull Request with:
   - Clear description of changes
   - Screenshots if applicable
   - Reference to any related issues
6. **Wait** for review from the maintainer

### PR Requirements

- All existing functionality must remain intact
- New skills must include complete `SKILL.md` documentation
- Installer changes must be backward-compatible
- No secrets, API keys, or credentials in code

## Coding Standards

### Bash Scripts

- Use `#!/usr/bin/env bash` shebang
- Enable strict mode: `set -euo pipefail`
- Quote all variables: `"${variable}"`
- Use functions for reusable logic
- Add comments for complex operations

### Markdown

- Use ATX-style headers (`#`, `##`, `###`)
- Include blank lines before and after code blocks
- Keep line length under 120 characters where practical

### File Organization

```
devlmer-ecosystem-engine/
├── bin/              # CLI tools (dee)
├── blueprints/       # Domain definitions (ecosystems.json)
├── commands/         # Slash command definitions
├── config/           # Configuration templates
├── landing/          # Landing page
├── mcps/             # MCP server implementations
├── scripts/          # Utility scripts
├── skills/           # All 62 professional skills
├── install.sh        # Main installer
├── update.sh         # Update script
└── setup-wizard.sh   # Interactive setup
```

## Reporting Issues

When reporting bugs, please include:

1. **DEE version** (`dee version`)
2. **Operating system** and version
3. **Steps to reproduce** the issue
4. **Expected behavior** vs actual behavior
5. **Error output** (if applicable)
6. **Project type** being targeted

Use the appropriate [issue template](https://github.com/Soyelijah/devlmer-ecosystem-engine/issues/new/choose) when available.

---

Copyright © 2024–2026 [Pierre Solier](https://github.com/Soyelijah) · Devlmer
