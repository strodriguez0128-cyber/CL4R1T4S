#!/usr/bin/env bash
# connect.sh — Terminal connection helper for CL4R1T4S
# Usage: bash connect.sh

set -e

REPO_URL="https://github.com/strodriguez0128-cyber/CL4R1T4S.git"
REPO_SSH="git@github.com:strodriguez0128-cyber/CL4R1T4S.git"
REPO_NAME="CL4R1T4S"

# ─────────────────────────────────────────────────────────────
# Helpers
# ─────────────────────────────────────────────────────────────
green()  { printf '\033[0;32m%s\033[0m\n' "$*"; }
yellow() { printf '\033[0;33m%s\033[0m\n' "$*"; }
red()    { printf '\033[0;31m%s\033[0m\n' "$*"; }
info()   { printf '  \033[0;36m→\033[0m %s\n' "$*"; }

require() {
  command -v "$1" &>/dev/null || { red "Required tool not found: $1"; exit 1; }
}

# ─────────────────────────────────────────────────────────────
# Preflight checks
# ─────────────────────────────────────────────────────────────
require git

echo ""
green "=== CL4R1T4S — Terminal Connection Helper ==="
echo ""

# ─────────────────────────────────────────────────────────────
# 1. Choose connection method
# ─────────────────────────────────────────────────────────────
echo "Connection method:"
echo "  1) HTTPS  (works everywhere, prompts for credentials)"
echo "  2) SSH    (requires an SSH key already added to GitHub)"
echo ""
printf "Choose [1/2] (default: 1): "
read -r METHOD
METHOD="${METHOD:-1}"

if [[ "$METHOD" == "2" ]]; then
  CLONE_URL="$REPO_SSH"
  yellow "Using SSH: $CLONE_URL"
else
  CLONE_URL="$REPO_URL"
  yellow "Using HTTPS: $CLONE_URL"
fi

echo ""

# ─────────────────────────────────────────────────────────────
# 2. If inside the repo already, just configure the remote
# ─────────────────────────────────────────────────────────────
if git rev-parse --is-inside-work-tree &>/dev/null 2>&1; then
  info "Already inside a git repository."

  CURRENT_REMOTE=$(git remote get-url origin 2>/dev/null || true)
  if [[ -n "$CURRENT_REMOTE" ]]; then
    info "Current remote: $CURRENT_REMOTE"
    printf "  Update remote origin to %s? [y/N]: " "$CLONE_URL"
    read -r UPDATE_REMOTE
    if [[ "${UPDATE_REMOTE,,}" == "y" ]]; then
      git remote set-url origin "$CLONE_URL"
      green "Remote origin updated."
    fi
  else
    git remote add origin "$CLONE_URL"
    green "Remote origin added."
  fi

# ─────────────────────────────────────────────────────────────
# 3. Otherwise, clone the repository
# ─────────────────────────────────────────────────────────────
else
  if [[ -d "$REPO_NAME" ]]; then
    yellow "Directory '$REPO_NAME' already exists."
    printf "  Remove and re-clone? [y/N]: "
    read -r RECLONE
    if [[ "${RECLONE,,}" == "y" ]]; then
      rm -rf "$REPO_NAME"
    else
      info "Skipping clone. Entering existing directory."
      cd "$REPO_NAME"
    fi
  fi

  if [[ ! -d "$REPO_NAME" ]]; then
    info "Cloning $CLONE_URL …"
    git clone "$CLONE_URL" "$REPO_NAME"
    green "Repository cloned into ./$REPO_NAME"
  fi

  cd "$REPO_NAME"
fi

# ─────────────────────────────────────────────────────────────
# 4. Git identity (if not set globally)
# ─────────────────────────────────────────────────────────────
GIT_NAME=$(git config --global user.name 2>/dev/null || true)
GIT_EMAIL=$(git config --global user.email 2>/dev/null || true)

if [[ -z "$GIT_NAME" || -z "$GIT_EMAIL" ]]; then
  echo ""
  yellow "Git identity not configured globally."
  printf "  Your name : "; read -r INPUT_NAME
  printf "  Your email: "; read -r INPUT_EMAIL
  git config --global user.name  "$INPUT_NAME"
  git config --global user.email "$INPUT_EMAIL"
  green "Git identity saved."
fi

# ─────────────────────────────────────────────────────────────
# 5. Fetch & display status
# ─────────────────────────────────────────────────────────────
echo ""
info "Fetching latest refs …"
git fetch --all --prune 2>/dev/null || yellow "Fetch failed — check your connection."

echo ""
green "Connection established. Repository status:"
echo ""
git status
echo ""
green "Available branches:"
git branch -a
echo ""
green "Done. You are connected to: $(git remote get-url origin)"
echo ""
