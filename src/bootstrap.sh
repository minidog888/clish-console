#!/usr/bin/env bash
# ============================================
# Clish Console Bootstrap (Strict Namespaced)
# ============================================

# Public function to check if running in packaged mode
clish_console_is_packaged() {
    [[ "${CLISH_CONSOLE_PACKAGED:-false}" == "true" ]]
}

# If not set, default to false (development mode)
export CLISH_CONSOLE_PACKAGED="${CLISH_CONSOLE_PACKAGED:-false}"
export CLISH_CONSOLE_WORK_DIR="${CLISH_CONSOLE_WORK_DIR:-$PWD}"

import "@clish/console/core/init.sh"
import "@clish/console/core/log.sh"
import "@clish/console/core/options.sh"
import "@clish/console/core/input.sh"
import "@clish/console/core/output.sh"
import "@clish/console/core/progress.sh"
import "@clish/console/console/kernel.sh"
import "@clish/console/console/help.sh"

# Entry point (public API)
clish_console_bootstrap_main() {
    local CLISH_CONSOLE_BOOTSTRAP_QUIET=false
    local CLISH_CONSOLE_BOOTSTRAP_VERBOSE=0
    local CLISH_CONSOLE_BOOTSTRAP_GLOBAL_HELP=false
    local CLISH_CONSOLE_BOOTSTRAP_SHOW_VERSION=false
    local CLISH_CONSOLE_BOOTSTRAP_NO_INTERACTION=false
    local CLISH_CONSOLE_BOOTSTRAP_DEBUG=false

    while [[ $# -gt 0 ]]; do
        case "$1" in
            -V|--version) CLISH_CONSOLE_BOOTSTRAP_SHOW_VERSION=true; shift ;;
            -h|--help) CLISH_CONSOLE_BOOTSTRAP_GLOBAL_HELP=true; shift ;;
            -q|--quiet) CLISH_CONSOLE_BOOTSTRAP_QUIET=true; shift ;;
            -vvv) CLISH_CONSOLE_BOOTSTRAP_VERBOSE=3; shift ;;
            -vv) CLISH_CONSOLE_BOOTSTRAP_VERBOSE=2; shift ;;
            -v|--verbose) ((CLISH_CONSOLE_BOOTSTRAP_VERBOSE++)); shift ;;
            --ansi|--no-ansi) shift ;;
            -n|--no-interaction) CLISH_CONSOLE_BOOTSTRAP_NO_INTERACTION=true; shift ;;
            --env) shift 2 ;;
            --debug)
                if [[ -n "${CLISH_CONSOLE_CLOSE_DEBUG_ENABLED:-}" ]]; then
                    echo "Error: --debug is not enabled in this build" >&2
                    exit 1
                fi
                CLISH_CONSOLE_BOOTSTRAP_DEBUG=true
                shift
                ;;
            --) shift; break ;;
            -*|*) break ;;
        esac
    done

    export CLISH_CONSOLE_BOOTSTRAP_QUIET
    export CLISH_CONSOLE_BOOTSTRAP_VERBOSE
    export CLISH_CONSOLE_BOOTSTRAP_NO_INTERACTION
    export CLISH_CONSOLE_BOOTSTRAP_DEBUG

    if [[ "$CLISH_CONSOLE_BOOTSTRAP_DEBUG" == "true" ]]; then
        set -x
        export PS4='+ [${BASH_SOURCE}:${LINENO}] '
    fi

    if [[ "$CLISH_CONSOLE_BOOTSTRAP_SHOW_VERSION" == "true" ]]; then
        clish_console_console_help_show_version
        exit 0
    fi

    if [[ "$CLISH_CONSOLE_BOOTSTRAP_GLOBAL_HELP" == "true" || $# -eq 0 ]]; then
        clish_console_console_help_show_global_help
        exit 0
    fi

    clish_console_console_kernel_run_command "$@"
}