#!/usr/bin/env bash
# ============================================
# Core Initialization (Strict Namespaced)
# ============================================

# shellcheck disable=SC2034
readonly CLISH_CONSOLE_CORE_INIT_COLOR_RESET='\033[0m'
readonly CLISH_CONSOLE_CORE_INIT_COLOR_GREEN='\033[32m'
readonly CLISH_CONSOLE_CORE_INIT_COLOR_YELLOW='\033[33m'
readonly CLISH_CONSOLE_CORE_INIT_COLOR_RED='\033[31m'
readonly CLISH_CONSOLE_CORE_INIT_COLOR_CYAN='\033[36m'
readonly CLISH_CONSOLE_CORE_INIT_COLOR_GRAY='\033[90m'

# These are set by bootstrap
CLISH_CONSOLE_CORE_INIT_QUIET=${CLISH_CONSOLE_BOOTSTRAP_QUIET:-false}
CLISH_CONSOLE_CORE_INIT_VERBOSE=${CLISH_CONSOLE_BOOTSTRAP_VERBOSE:-0}
export CLISH_CONSOLE_CORE_INIT_QUIET
export CLISH_CONSOLE_CORE_INIT_VERBOSE