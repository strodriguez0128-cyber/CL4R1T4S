#!/bin/bash
set -euo pipefail

# Only run setup in remote (Claude Code on the web) environments
if [ "${CLAUDE_CODE_REMOTE:-}" != "true" ]; then
  exit 0
fi

echo "CL4R1T4S session-start hook: verifying environment..."

# Verify git is available (used for contributions/PRs)
if ! command -v git &>/dev/null; then
  echo "WARNING: git not found in PATH" >&2
fi

# Report available formatting/linting tools
if command -v prettier &>/dev/null; then
  echo "prettier available: $(prettier --version)"
  echo "  -> Run 'prettier --check <file>' to lint markdown files"
  echo "  -> Run 'prettier --write <file>' to auto-format markdown files"
else
  echo "prettier not found; markdown formatting tool unavailable."
fi

echo "Environment check complete."
