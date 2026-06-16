#!/usr/bin/env bash
# ============================================
# Interactive Input Helpers (Strict Namespaced)
# ============================================

clish_console_core_input_ask() {
    local prompt="$1"
    local default="$2"
    if [[ -n "$default" ]]; then
        read -r -p "$prompt [$default]: " answer
        echo "${answer:-$default}"
    else
        read -r -p "$prompt: " answer
        echo "$answer"
    fi
}

clish_console_core_input_secret() {
    local prompt="$1"
    read -r -s -p "$prompt: " answer
    echo >&2
    echo "$answer"
}

clish_console_core_input_confirm() {
    local prompt="$1"
    local default="${2:-n}"
    local default_upper=""
    if [[ "$default" == "y" ]]; then
        default_upper="Y/n"
    else
        default_upper="y/N"
    fi
    read -r -p "$prompt [$default_upper]: " answer
    answer="${answer:-$default}"
    [[ "$answer" =~ ^[Yy]$ ]] && return 0 || return 1
}

clish_console_core_input_choice() {
    local prompt="$1"
    shift
    local options=("$@")
    PS3="$prompt "
    select opt in "${options[@]}"; do
        if [[ -n "$opt" ]]; then
            echo "$opt"
            break
        else
            echo "Invalid option" >&2
        fi
    done
}