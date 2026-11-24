#!/bin/bash

set -euo pipefail

export DO_NOT_TRACK=1
export DISABLE_TELEMETRY=1
export HOMEBREW_NO_ANALYTICS=1
export HOMEBREW_NO_ENV_HINTS=1
export NPM_CONFIG_UPDATE_NOTIFIER=false
export NPM_CONFIG_FUND=false
export NPM_CONFIG_AUDIT=false

NODE_INSTALLS="${TOOLCHAIN_NODE_INSTALLS:-$HOME/.local/share/mise/installs/node}"
read -r -a BREW_CASKS <<< "${TOOLCHAIN_BREW_CASKS:-claude-code@latest codex}"
DRY_RUN=false

while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -d|--dry-run)
            DRY_RUN=true
            ;;
        *)
            echo "Unknown parameter: $1"
            exit 1
            ;;
    esac
    shift
done

update_brew_casks() {
    command -v brew >/dev/null 2>&1 || return 0

    local installed=()
    local cask
    for cask in "${BREW_CASKS[@]}"; do
        if brew list --cask "$cask" >/dev/null 2>&1; then
            installed+=("$cask")
        fi
    done
    [ "${#installed[@]}" -gt 0 ] || return 0

    brew update -q >/dev/null
    local outdated
    outdated="$(brew outdated --cask --greedy --verbose "${installed[@]}" || true)"
    if [ -z "$outdated" ]; then
        echo "current: brew casks ${installed[*]}"
        return 0
    fi

    printf '%s\n' "$outdated"
    if [ "$DRY_RUN" = false ]; then
        HOMEBREW_NO_AUTO_UPDATE=1 brew upgrade --cask --greedy "${installed[@]}"
    fi
}

update_agent_browser() {
    [ -d "$NODE_INSTALLS" ] || return 0

    local latest=""
    local seen=""
    local dir real package current
    for dir in "$NODE_INSTALLS"/*/; do
        real="$(cd "$dir" && pwd -P)"
        case " $seen " in
            *" $real "*) continue ;;
        esac
        seen="$seen $real"

        package="$real/lib/node_modules/agent-browser/package.json"
        [ -f "$package" ] || continue

        current="$(python3 -c 'import json, sys; print(json.load(open(sys.argv[1]))["version"])' "$package")"
        if [ -z "$latest" ]; then
            latest="$("$real/bin/npm" view agent-browser version)"
        fi

        if [ "$current" = "$latest" ]; then
            echo "current: $real agent-browser $current"
            continue
        fi

        echo "outdated: $real agent-browser $current -> $latest"
        if [ "$DRY_RUN" = false ]; then
            "$real/bin/npm" install -g "agent-browser@$latest"
        fi
    done
}

update_brew_casks
update_agent_browser
echo "skills CLI latest: $(npm view skills version)"
