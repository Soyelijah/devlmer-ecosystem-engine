# Security Policy

## Devlmer Ecosystem Engine — Security

### Supported Versions

| Version | Supported          |
|---------|--------------------|
| 3.1.x   | ✅ Active support  |
| 3.0.x   | ⚠️ Critical fixes only |
| < 3.0   | ❌ End of life     |

### Reporting a Vulnerability

We take security seriously. If you discover a security vulnerability in Devlmer Ecosystem Engine, please report it responsibly.

**Do NOT open a public GitHub issue for security vulnerabilities.**

Instead, please send a detailed report to:

📧 **solier.elijah@gmail.com**

Include the following in your report:

1. **Description** of the vulnerability
2. **Steps to reproduce** the issue
3. **Potential impact** assessment
4. **Suggested fix** (if you have one)
5. **Your contact information** for follow-up

### Response Timeline

| Action | Timeframe |
|--------|-----------|
| Acknowledgment of report | Within 48 hours |
| Initial assessment | Within 5 business days |
| Fix development | Within 15 business days |
| Public disclosure | After fix is released |

### Security Practices

Devlmer Ecosystem Engine follows these security practices:

- **No credential storage**: DEE never stores API keys, tokens, or passwords. It uses existing credentials from GitHub CLI and system keychains.
- **Non-destructive installation**: All files are installed to `.claude/` directory only. Existing project code is never modified.
- **Transparent operations**: The installer shows every action it takes. Use `--verbose` for full detail.
- **No remote code execution**: Skills are static Markdown files, not executable code. No arbitrary code is downloaded or executed.
- **Dependency minimalism**: DEE relies only on Bash, Python 3, and Git — no additional packages are installed.

### Scope

The following are in scope for security reports:

- The installer (`install.sh`)
- The CLI tool (`bin/dee`)
- Update and setup scripts
- MCP configuration templates
- Landing page and web assets

The following are **out of scope**:

- Third-party MCP servers (report to respective maintainers)
- Claude Code / Claude AI platform (report to Anthropic)
- GitHub CLI (report to GitHub)

### Acknowledgments

We appreciate responsible disclosure. Security researchers who report valid vulnerabilities will be credited in the release notes (unless they prefer to remain anonymous).

---

Copyright © 2024–2026 [Pierre Solier](https://github.com/Soyelijah) · Devlmer
