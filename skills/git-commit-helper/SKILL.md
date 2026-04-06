---
name: git-commit-helper
description: Generate descriptive, semantic commit messages by analyzing git diffs. Enforces conventional commits format, suggests proper scope, identifies breaking changes, and ensures commit quality. Use when the user asks for help writing commit messages or reviewing staged changes.
metadata:
  version: 1.1.0
  author: Devlmer / Pierre Solier
  creator: Devlmer
  branding: Enterprise-grade commit message generation for professional teams
hooks:
  PostToolUse:
    - matcher: "Bash"
      hooks:
        - type: command
          command: "echo \"[$(date)] Git Commit Helper: Analyzed git diff for commit message\" >> ~/.claude/git-commit-helper.log"
---

# Git Commit Helper

## Quick start

Analyze staged changes and generate commit message:

```bash
# View staged changes
git diff --staged

# Generate commit message based on changes
# (Claude will analyze the diff and suggest a message)
```

## Commit message format

Follow conventional commits format:

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

### Types

- **feat**: New feature
- **fix**: Bug fix
- **docs**: Documentation changes
- **style**: Code style changes (formatting, missing semicolons)
- **refactor**: Code refactoring
- **test**: Adding or updating tests
- **chore**: Maintenance tasks

### Examples

**Feature commit:**
```
feat(auth): add JWT authentication

Implement JWT-based authentication system with:
- Login endpoint with token generation
- Token validation middleware
- Refresh token support
```

**Bug fix:**
```
fix(api): handle null values in user profile

Prevent crashes when user profile fields are null.
Add null checks before accessing nested properties.
```

**Refactor:**
```
refactor(database): simplify query builder

Extract common query patterns into reusable functions.
Reduce code duplication in database layer.
```

## Analyzing changes

Review what's being committed:

```bash
# Show files changed
git status

# Show detailed changes
git diff --staged

# Show statistics
git diff --staged --stat

# Show changes for specific file
git diff --staged path/to/file
```

## Commit message guidelines

**DO:**
- Use imperative mood ("add feature" not "added feature")
- Keep first line under 50 characters
- Capitalize first letter
- No period at end of summary
- Explain WHY not just WHAT in body

**DON'T:**
- Use vague messages like "update" or "fix stuff"
- Include technical implementation details in summary
- Write paragraphs in summary line
- Use past tense

## Multi-file commits

When committing multiple related changes:

```
refactor(core): restructure authentication module

- Move auth logic from controllers to service layer
- Extract validation into separate validators
- Update tests to use new structure
- Add integration tests for auth flow

Breaking change: Auth service now requires config object
```

## Scope examples

**Frontend:**
- `feat(ui): add loading spinner to dashboard`
- `fix(form): validate email format`

**Backend:**
- `feat(api): add user profile endpoint`
- `fix(db): resolve connection pool leak`

**Infrastructure:**
- `chore(ci): update Node version to 20`
- `feat(docker): add multi-stage build`

## Breaking changes

Indicate breaking changes clearly:

```
feat(api)!: restructure API response format

BREAKING CHANGE: All API responses now follow JSON:API spec

Previous format:
{ "data": {...}, "status": "ok" }

New format:
{ "data": {...}, "meta": {...} }

Migration guide: Update client code to handle new response structure
```

## Template workflow

1. **Review changes**: `git diff --staged`
2. **Identify type**: Is it feat, fix, refactor, etc.?
3. **Determine scope**: What part of the codebase?
4. **Write summary**: Brief, imperative description
5. **Add body**: Explain why and what impact
6. **Note breaking changes**: If applicable

## Interactive commit helper

Use `git add -p` for selective staging:

```bash
# Stage changes interactively
git add -p

# Review what's staged
git diff --staged

# Commit with message
git commit -m "type(scope): description"
```

## Amending commits

Fix the last commit message:

```bash
# Amend commit message only
git commit --amend

# Amend and add more changes
git add forgotten-file.js
git commit --amend --no-edit
```

## Best practices

1. **Atomic commits** - One logical change per commit
2. **Test before commit** - Ensure code works
3. **Reference issues** - Include issue numbers if applicable
4. **Keep it focused** - Don't mix unrelated changes
5. **Write for humans** - Future you will read this

## Smart Commit Analysis Protocol

When analyzing diffs, follow this workflow:

```
STEP 1: Scan the changes
├── What files changed?
├── What's the pattern? (mostly additions? refactoring? deletion?)
└── Is this breaking or additive?

STEP 2: Determine type
├── Features added? → feat
├── Bugs fixed? → fix
├── Refactoring without behavior change? → refactor
├── Tests added/modified? → test
├── Dependencies/config? → chore
├── Documentation? → docs
└── Code formatting? → style

STEP 3: Identify scope (1-2 words max)
├── Domain: auth, api, ui, db, build
├── Component: Button, Auth Service, Payment Form
└── Module: middleware, schema, store

STEP 4: Write impactful summary (<50 chars)
├── Starts with lowercase
├── Uses imperative mood (add, remove, update)
├── Shows impact clearly
├── Example: "add JWT refresh token rotation"

STEP 5: Generate detailed body
├── What changed and why
├── Implementation approach
├── Testing performed
├── Related tickets/PRs
```

## Scope Decision Tree

```
Is it authentication-related?
├── YES → scope: auth
└── NO → Check next...

Is it a database change?
├── YES → scope: db
└── NO → Check next...

Is it API-related?
├── YES → scope: api
└── NO → Check next...

Is it UI/frontend?
├── YES → scope: ui
└── NO → Check next...

Is it infrastructure/build?
├── YES → scope: build
└── NO → scope: [feature-name]
```

## Commit Message Quality Score

Evaluate commits using this rubric (aim for 90%+):

| Criterion | Points | Check |
|-----------|--------|-------|
| Follows conventional commits | 30% | Type(scope): message |
| Summary is clear & concise | 20% | Under 50 chars, explains change |
| Body explains WHY | 25% | Not just implementation details |
| Formatted for readability | 15% | Proper wrapping, spacing |
| Links to issues/PRs | 10% | References included when relevant |

## Commit message checklist

- [ ] Type is appropriate (feat/fix/docs/etc.)
- [ ] Scope is specific and clear
- [ ] Summary is under 50 characters
- [ ] Summary uses imperative mood
- [ ] Body explains WHY not just WHAT
- [ ] Breaking changes are clearly marked
- [ ] Related issue numbers are included
- [ ] No vague language ("update", "fix stuff")
- [ ] Formatted for readability (wrapped at 72 chars)
- [ ] Ready for git log history review
