#!/usr/bin/env bash
# ============================================
# Progress Bar Helpers (Strict Namespaced)
# ============================================

__CLISH_CONSOLE_CORE_PROGRESS_CURRENT=0
__CLISH_CONSOLE_CORE_PROGRESS_TOTAL=0
__CLISH_CONSOLE_CORE_PROGRESS_LAST_PERCENT=-1

clish_console_core_progress_start() {
    local total="$1"
    __CLISH_CONSOLE_CORE_PROGRESS_CURRENT=0
    __CLISH_CONSOLE_CORE_PROGRESS_TOTAL=$total
    __CLISH_CONSOLE_CORE_PROGRESS_LAST_PERCENT=-1
}

clish_console_core_progress_advance() {
    local step="${1:-1}"
    __CLISH_CONSOLE_CORE_PROGRESS_CURRENT=$((__CLISH_CONSOLE_CORE_PROGRESS_CURRENT + step))
    local percent=$((__CLISH_CONSOLE_CORE_PROGRESS_CURRENT * 100 / __CLISH_CONSOLE_CORE_PROGRESS_TOTAL))
    if [[ $percent -ne __CLISH_CONSOLE_CORE_PROGRESS_LAST_PERCENT ]]; then
        printf "\r[%-50s] %d%%" "$(printf '#%.0s' $(seq 1 $((percent/2))))" "$percent"
        __CLISH_CONSOLE_CORE_PROGRESS_LAST_PERCENT=$percent
    fi
    if [[ __CLISH_CONSOLE_CORE_PROGRESS_CURRENT -eq __CLISH_CONSOLE_CORE_PROGRESS_TOTAL ]]; then
        echo
    fi
}