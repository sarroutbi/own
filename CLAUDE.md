# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

A personal collection of utility scripts (primarily Bash) and development environment configurations. Not a traditional software project — there is no build system, package manager, or test suite.

## CI / Quality Checks

- **Spellcheck** runs on every push/PR that touches `*.md` files via GitHub Actions (`.github/workflows/spellcheck.yaml`). Custom dictionary words go in `.wordlist.txt`.
- **ShellCheck** is used to lint shell scripts (run manually: `shellcheck <script>`). Commits should pass ShellCheck before merging.

## Repository Structure

- `scripts/` — Utility scripts organized by category (e.g., `utils/`, `strings/`, `gittools/`, `bootable_containers/`, `operator-sdk-installation/`). Each subdirectory is self-contained.
- `config/` — Development environment configs: Emacs (language-specific variants), tmux (shared base in `tmux.common.conf` sourced by project-specific scripts), GNU Screen, XMonad, and bash aliases.
- `bookmarks/` — Browser bookmark exports.

## Conventions

- **Shell scripts** use `#!/bin/bash` and should include an ISC or GPL license header with copyright attribution.
- **Commit messages** follow the pattern: `<Verb> <description>` (e.g., "Add bootable containers basic script", "Fix issues reported by shellcheck"). Do not include PR/issue numbers — GitHub appends them on merge.
- **Tmux configs** follow a session-factory pattern: project-specific scripts (e.g., `tmux_nbde_tangserver.sh`) source the shared `tmux.common.conf` and create standardized window layouts (console, compile, edit, DOC, misc).
- Generated `Containerfile` artifacts are git-ignored via `scripts/.gitignore`.
