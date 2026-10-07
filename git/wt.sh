#!/usr/bin/env bash
set -euo pipefail

DIM='\033[2m'
GREEN='\033[0;32m'
RED='\033[0;31m'
RESET='\033[0m'
YELLOW='\033[1;33m'

fetch_remote_refs() {
    git fetch --prune origin 2>/dev/null
}

# Outputs "<path>\t<branch>" per worktree, DETACHED if no branch
get_worktrees() {
    local path="" branch=""
    while IFS= read -r line; do
        case "$line" in
            worktree\ *)  path="${line#worktree }" ; branch="" ;;
            branch\ *)    branch="${line#branch refs/heads/}" ;;
            "")
                if [[ -n "$path" ]] && [[ "$(basename "$path")" != ".bare" ]]; then
                    printf '%s\t%s\n' "$path" "${branch:-DETACHED}"
                fi
                path="" ; branch=""
                ;;
        esac
    done < <(git worktree list --porcelain)
    if [[ -n "$path" ]] && [[ "$(basename "$path")" != ".bare" ]]; then
        printf '%s\t%s\n' "$path" "${branch:-DETACHED}"
    fi
}

remote_branch_exists() {
    git show-ref --verify --quiet "refs/remotes/origin/$1"
}

worktree_is_dirty() {
    ! git -C "$1" diff --quiet 2>/dev/null || ! git -C "$1" diff --cached --quiet 2>/dev/null
}

cmd_list() {
    printf "Fetching remote refs..."
    fetch_remote_refs
    printf "done\n\n"

    local is_first=true
    while IFS=$'\t' read -r path branch; do
        local dir
        dir="$(basename "$path")"

        if $is_first; then
            is_first=false
            printf "${DIM}  %-45s  [main]${RESET}\n" "$dir"
            continue
        fi

        if [[ "$branch" == "DETACHED" ]]; then
            printf "${YELLOW}  %-45s  (detached HEAD)${RESET}\n" "$dir"
        elif remote_branch_exists "$branch"; then
            printf "${GREEN}  %-45s  %s${RESET}\n" "$dir" "$branch"
        else
            printf "${RED}  %-45s  %s  ← orphan${RESET}\n" "$dir" "$branch"
        fi
    done < <(get_worktrees)
}

cmd_purge() {
    printf "Fetching remote refs... "
    fetch_remote_refs
    printf "done\n\n"

    local is_first=true
    local purged=0
    local skipped=0

    while IFS=$'\t' read -r path branch; do
        if $is_first; then
            is_first=false
            continue
        fi

        [[ "$branch" == "DETACHED" ]] && continue
        remote_branch_exists "$branch" && continue

        if worktree_is_dirty "$path"; then
            printf "${YELLOW}  Skipping (dirty): %s${RESET}\n" "$(basename "$path")"
            skipped=$((skipped + 1))
            continue
        fi

        printf "  Removing: %s (%s)\n" "$(basename "$path")" "$branch"
        git worktree remove "$path"
        purged=$((purged + 1))
    done < <(get_worktrees)

    printf "\n%d removed, %d skipped (dirty).\n" "$purged" "$skipped"
}

cmd_new() {
    local folder="${1:-}"
    local origin="${2:-}"
    local branch="${3:-}"

    if [[ ! -d "$PWD/.bare" ]]; then
        printf "${RED}Error: no .bare directory found in %s${RESET}\n" "$PWD"
        exit 1
    fi

    if [[ -z "$folder" || -z "$origin" || -z "$branch" ]]; then
        printf "Usage: %s new <dir_name> <origin> <branch_name>\n" "$(basename "$0")"
        exit 1
    fi

    local worktree_path="$PWD/$folder"

    printf "Creating worktree %s from %s...\n" "$folder" "$origin"
    git worktree add "$worktree_path" "$origin" -b "$branch"

    (cd "$worktree_path")
    printf "\nWorktree %s ready.\n" "$folder"
}

cmd_review() {
    local folder="${1:-}"
    local origin="${2:-}"

    if [[ ! -d "$PWD/.bare" ]]; then
        printf "${RED}Error: no .bare directory found in %s${RESET}\n" "$PWD"
        exit 1
    fi

    if [[ -z "$folder" || -z "$origin" ]]; then
        printf "Usage: %s review <dir_name> <origin>\n" "$(basename "$0")"
        exit 1
    fi

    local worktree_path="$PWD/$folder"

    printf "Creating worktree %s from %s...\n" "$folder" "$origin"
    git worktree add "$worktree_path" "$origin"

    (cd "$worktree_path")
    printf "\nWorktree %s ready.\n" "$folder"
}

case "${1:-}" in
    new)    cmd_new "${@:2}" ;;
    purge)  cmd_purge ;;
    review) cmd_review "${@:2}" ;;
    "")     cmd_list  ;;
    *)
        printf "Usage: %s [new <dir> <origin> <branch> | purge | review <dir> <origin>]\n" "$(basename "$0")"
        exit 1
        ;;
esac
