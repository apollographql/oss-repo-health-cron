# Repository Guidelines

## Summary

This is a bucket of scripts for handing off a regular rotation for a "Caretaker" rotation; it's kind of like an on-call rotation where team members take turns being the POC for certain interrupt-driven workflows.  We use data from PagerDuty and the Slack API, among other things, to coordinate handoffs.

## Project Structure & Module Organization
- `scripts/` holds the Bash automation used by GitHub Actions (health checks, handoff messages, stats). Script names are descriptive and generally kebab-case (e.g., `issues-without-replies-last-72-hours.sh`).
- `.github/workflows/` contains scheduled and manual workflows that check out target repositories, run scripts, and post to Slack.
- `renovate.json` configures dependency update automation for workflow actions.

## Build, Test, and Development Commands
There is no build step; workflows execute Bash scripts directly. Common local runs:
- `bash scripts/get-relative-dates.sh` — sets date environment helpers used by other scripts.
- `GH_TOKEN=... bash scripts/issues-with-new-comments-last-7-days.sh` — queries issues via `gh` for the current repo.
- `bash scripts/apollo-client-caretaker-handoff.sh` — runs the handoff script (requires PagerDuty + Slack env vars).

Dependencies: `bash`, `gh` CLI, `jq`, and `bc`. Most scripts expect `GH_TOKEN` and may rely on `GITHUB_OUTPUT` when run in CI.

## Coding Style & Naming Conventions
- Shell scripts are Bash (`#!/usr/bin/env bash`) with two-space indentation and explicit quoting for variables.
- Environment variables are uppercase (e.g., `GH_TOKEN`, `SLACK_BOT_TOKEN`).
- Workflow filenames and script filenames use kebab-case; keep new scripts under `scripts/`.

## Testing Guidelines
- No unit tests are defined. Validation is done by running scripts locally and by scheduled workflows.
- When changing scripts, run the relevant script locally against a test repo or invoke the workflow via `workflow_dispatch`.

## Commit & Pull Request Guidelines
- Commit messages follow a Conventional Commits style, e.g., `fix: ...`, `chore: ...`, `chore(deps): ...`, `feat: ...`.
- PRs should describe the script/workflow changes, list any new secrets or required env vars, and note which workflows were exercised.

## Security & Configuration Tips
- Secrets are injected via GitHub Actions (e.g., `GH_TOKEN`, `PD_TOKEN`, `SLACK_BOT_TOKEN`). Never echo or log token values.
- Keep Slack payload changes minimal and verify formatting by running the workflow in a test channel where possible.
