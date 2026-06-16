#!/usr/bin/env bash
# ============================================
# Logging Helpers (Strict Namespaced)
# ============================================

_clish_console_core_log_message() {
    # shellcheck disable=SC2034
    local level="$1"
    local color="$2"
    local prefix="$3"
    shift 3
    if [[ "$CLISH_CONSOLE_CORE_INIT_QUIET" == "true" ]]; then
        return 0
    fi
    echo -e "${color}${prefix}$*${CLISH_CONSOLE_CORE_INIT_COLOR_RESET}"
}

clish_console_core_log_emergency() { _clish_console_core_log_message "EMERGENCY" "$CLISH_CONSOLE_CORE_INIT_COLOR_RED" "[EMERGENCY] " "$@"; }
clish_console_core_log_alert()     { _clish_console_core_log_message "ALERT"     "$CLISH_CONSOLE_CORE_INIT_COLOR_RED" "[ALERT] "     "$@"; }
clish_console_core_log_critical()  { _clish_console_core_log_message "CRITICAL"  "$CLISH_CONSOLE_CORE_INIT_COLOR_RED" "[CRITICAL] "  "$@"; }
clish_console_core_log_error()     { _clish_console_core_log_message "ERROR"     "$CLISH_CONSOLE_CORE_INIT_COLOR_RED" "[ERROR] "     "$@"; }
clish_console_core_log_warning()   { _clish_console_core_log_message "WARNING"   "$CLISH_CONSOLE_CORE_INIT_COLOR_YELLOW" "[WARNING] " "$@"; }
clish_console_core_log_notice()    { _clish_console_core_log_message "NOTICE"    "$CLISH_CONSOLE_CORE_INIT_COLOR_CYAN" "[NOTICE] "   "$@"; }
clish_console_core_log_info()      { _clish_console_core_log_message "INFO"      ""           "[INFO] "      "$@"; }
clish_console_core_log_debug()     { _clish_console_core_log_message "DEBUG"     "$CLISH_CONSOLE_CORE_INIT_COLOR_GRAY" "[DEBUG] "    "$@"; }

clish_console_core_log_success() {
    if [[ "$CLISH_CONSOLE_CORE_INIT_QUIET" != "true" ]]; then
        echo -e "${CLISH_CONSOLE_CORE_INIT_COLOR_GREEN}$*${CLISH_CONSOLE_CORE_INIT_COLOR_RESET}"
    fi
}