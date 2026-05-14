# CLAUDE.md

This file documents the repository for AI assistants (Claude and others) working on this codebase.

## Project Overview

**Repository:** `MrAntiRatio/clauded`

This repository is currently in initial setup. Update this section with a description of the project's purpose, goals, and target audience as the codebase develops.

## Repository Structure

```
clauded/
├── CLAUDE.md          # This file — AI assistant guidance
└── (project files TBD)
```

Update this tree as the project grows.

## Development Workflow

### Branching Strategy

- `main` — stable, production-ready code
- `claude/<description>-<id>` — AI-assisted feature branches
- Feature branches should be short-lived and merged via pull request

### Commits

Write commit messages in the imperative mood ("Add feature" not "Added feature"). Keep the subject line under 72 characters. Include context in the body when the *why* is non-obvious.

### Pull Requests

- Target `main` unless otherwise specified
- Include a short summary of what changed and why
- All CI checks must pass before merging

## Key Conventions

### Code Style

Document language-specific style rules here once a primary language is chosen (e.g., linter config, formatter, naming conventions).

### Testing

Document test runner, test file locations, and how to run the full test suite here.

### Environment Setup

Document required environment variables, dependencies, and local setup steps here.

## AI Assistant Guidelines

- **Scope:** Make only the changes required by the current task. Do not refactor surrounding code or add unrequested features.
- **Comments:** Default to no comments. Only add one when the *why* is non-obvious (hidden constraint, workaround, subtle invariant).
- **Security:** Never introduce command injection, XSS, SQL injection, or other OWASP top-10 vulnerabilities. Validate at system boundaries only.
- **Commits:** Create new commits rather than amending existing ones. Use descriptive messages.
- **Branch:** Always develop on the branch specified for the task. Never push to `main` directly.
- **Secrets:** Never commit `.env` files, credentials, or API keys.
- **Reversibility:** Confirm with the user before taking destructive or hard-to-reverse actions (force push, file deletion, schema drops, etc.).

## Updating This File

Keep this file current as the project evolves. Update the structure tree, conventions, and workflow sections whenever significant changes are made to project layout, tooling, or process.
