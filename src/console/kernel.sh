#!/usr/bin/env bash
# ============================================
# Console Kernel (Strict Namespaced)
# ============================================

readonly CLISH_CONSOLE_CONSOLE_KERNEL_BIN_DIR="$PROJECT_ROOT/bin/commands"
CLISH_CONSOLE_CONSOLE_KERNEL_COMMAND_PATHS=()
CLISH_CONSOLE_CONSOLE_KERNEL_COMMAND_FILES=()

_clish_console_console_kernel_build_command_list() {
    if [[ ! -d "$CLISH_CONSOLE_CONSOLE_KERNEL_BIN_DIR" ]]; then
        return
    fi
    while IFS= read -r file; do
        if [[ -f "$file" && -x "$file" ]]; then
            local rel
            rel="${file#"$CLISH_CONSOLE_CONSOLE_KERNEL_BIN_DIR"/}"
            CLISH_CONSOLE_CONSOLE_KERNEL_COMMAND_PATHS+=("$rel")
            CLISH_CONSOLE_CONSOLE_KERNEL_COMMAND_FILES+=("$file")
        fi
    done < <(find "$CLISH_CONSOLE_CONSOLE_KERNEL_BIN_DIR" -type f -perm +111 | sort)
}
_clish_console_console_kernel_build_command_list

_clish_console_console_kernel_get_namespace() {
    local path="$1"
    local ns="${path//\//_}"
    echo "cmd_${ns}"
}

_clish_console_console_kernel_get_description() {
    local path="$1"
    local ns
    ns="$(_clish_console_console_kernel_get_namespace "$path")"
    local file="$CLISH_CONSOLE_CONSOLE_KERNEL_BIN_DIR/$path"
    (
        # shellcheck source=/dev/null
        source "$file" 2>/dev/null
        if declare -f "${ns}_description" >/dev/null; then
            "${ns}_description"
        fi
    ) 2>/dev/null
}

clish_console_console_kernel_run_command() {
    clish_console_core_options_clear_registry
    opt_arguments=()

    local user_cmd="$1"
    shift
    user_cmd="$(echo "$user_cmd" | tr ':' '/')"

    local ns
    ns="$(_clish_console_console_kernel_get_namespace "$user_cmd")"

    if declare -f "${ns}_handle" >/dev/null; then
        __CLISH_CONSOLE_CONSOLE_KERNEL_CMD_NAME="$user_cmd"
        if declare -f "${ns}_options" >/dev/null; then
            "${ns}_options"
            local opt_spec
            opt_spec="$(clish_console_core_options_generate_spec)"
            clish_console_core_options_parse "$opt_spec" "$@"
        fi

        # Handle --help (inline mode)
        if [[ $# -ge 1 && ( "$1" == "-h" || "$1" == "--help" ) ]]; then
            if declare -f "${ns}_description" >/dev/null; then
                echo "Usage: $0 $user_cmd"
                echo
                "${ns}_description"
                echo
            fi
            if declare -f "${ns}_options" >/dev/null; then
                clish_console_core_options_clear_registry
                "${ns}_options"
                clish_console_core_options_generate_help
            fi
            if ! declare -f "${ns}_description" >/dev/null && ! declare -f "${ns}_options" >/dev/null; then
                echo "No help available for '$user_cmd'"
            fi
            return 0
        fi

        # Execute command (inline mode)
        local required_args=${#__CLISH_CONSOLE_CORE_OPTIONS_ARG_NAMES[@]}
        # shellcheck disable=SC2154
        local provided_args=${#opt_arguments[@]}
        if [[ $provided_args -lt $required_args ]]; then
            clish_console_core_log_error "Missing required argument(s)."
            clish_console_core_log_error "Expected at least $required_args argument(s), got $provided_args."
            if [[ "$CLISH_CONSOLE_CORE_INIT_QUIET" != "true" ]]; then
                echo
                clish_console_core_options_clear_registry
                if declare -f "${ns}_options" >/dev/null; then
                    "${ns}_options" 2>/dev/null
                    clish_console_core_options_generate_help >&2
                fi
            fi
            return 1
        fi

        for i in "${!__CLISH_CONSOLE_CORE_OPTIONS_ARG_NAMES[@]}"; do
            local arg_name="${__CLISH_CONSOLE_CORE_OPTIONS_ARG_NAMES[$i]}"
            local arg_value="${opt_arguments[$i]}"
            printf -v "arg_$arg_name" "%s" "$arg_value"
        done

        "${ns}_handle" "$@"
        return $?
    fi

    # Development mode: load from file
    local cmd_rel=""
    for path in "${CLISH_CONSOLE_CONSOLE_KERNEL_COMMAND_PATHS[@]}"; do
        if [[ "$path" == "$user_cmd" ]]; then
            cmd_rel="$path"
            break
        fi
    done

    if [[ -z "$cmd_rel" ]]; then
        clish_console_core_log_error "Command '$user_cmd' not found."
        clish_console_console_help_show_global_help
        return 1
    fi

    local cmd_file="$CLISH_CONSOLE_CONSOLE_KERNEL_BIN_DIR/$cmd_rel"
    __CLISH_CONSOLE_CONSOLE_KERNEL_CMD_NAME="$cmd_rel"

    # shellcheck source=/dev/null
    if ! source "$cmd_file" 2>/dev/null; then
        clish_console_core_log_error "Failed to load command: $user_cmd"
        return 1
    fi

    local ns
    ns="$(_clish_console_console_kernel_get_namespace "$cmd_rel")"

    if ! declare -f "${ns}_handle" >/dev/null; then
        clish_console_core_log_error "Command '$user_cmd' does not define ${ns}_handle function."
        return 1
    fi

    # Handle --help (file mode)
    if [[ $# -ge 1 && ( "$1" == "-h" || "$1" == "--help" ) ]]; then
        if declare -f "${ns}_description" >/dev/null; then
            echo "Usage: $0 $user_cmd"
            echo
            "${ns}_description"
            echo
        fi
        if declare -f "${ns}_options" >/dev/null; then
            clish_console_core_options_clear_registry
            "${ns}_options"
            clish_console_core_options_generate_help
        fi
        if ! declare -f "${ns}_description" >/dev/null && ! declare -f "${ns}_options" >/dev/null; then
            echo "No help available for '$user_cmd'"
        fi
        return 0
    fi

    # Execute command (file mode)
    if declare -f "${ns}_options" >/dev/null; then
        clish_console_core_options_clear_registry
        "${ns}_options"
        local opt_spec
        opt_spec="$(clish_console_core_options_generate_spec)"
        clish_console_core_options_parse "$opt_spec" "$@"
    fi

    local required_args=${#__CLISH_CONSOLE_CORE_OPTIONS_ARG_NAMES[@]}
    # shellcheck disable=SC2154
    local provided_args=${#opt_arguments[@]}
    if [[ $provided_args -lt $required_args ]]; then
        clish_console_core_log_error "Missing required argument(s)."
        clish_console_core_log_error "Expected at least $required_args argument(s), got $provided_args."
        if [[ "$CLISH_CONSOLE_CORE_INIT_QUIET" != "true" ]]; then
            echo
            clish_console_core_options_clear_registry
            "${ns}_options" 2>/dev/null
            clish_console_core_options_generate_help >&2
        fi
        return 1
    fi

    for i in "${!__CLISH_CONSOLE_CORE_OPTIONS_ARG_NAMES[@]}"; do
        local arg_name="${__CLISH_CONSOLE_CORE_OPTIONS_ARG_NAMES[$i]}"
        local arg_value="${opt_arguments[$i]}"
        printf -v "arg_$arg_name" "%s" "$arg_value"
    done

    "${ns}_handle" "$@"
}