#!/usr/bin/env bash
# ============================================
# Clish Console Help (Strict Namespaced)
# ============================================

clish_console_console_help_get_version() {
    if [[ -f "$PROJECT_ROOT/modulash.json" ]]; then
        jq -r '.version // "1.0.0"' "$PROJECT_ROOT/modulash.json" 2>/dev/null || echo "1.0.0"
    else
        echo "1.0.0"
    fi
}

clish_console_console_help_show_version() {
    if [[ "$CLISH_CONSOLE_CORE_INIT_QUIET" == "true" ]]; then
        return
    fi
    local version
    version="$(clish_console_console_help_get_version)"
    echo "Clish Console version ${version}"
}

_clish_console_console_help_list_commands() {
    if [[ "$CLISH_CONSOLE_CORE_INIT_QUIET" == "true" ]]; then
        return
    fi

    local -a cmd_paths=()

    # ---------- distinguish packaged vs development ----------
    if clish_console_is_packaged; then
        # Packaged mode: all commands are already functions
        local funcs
        funcs=$(declare -f | grep -E '^cmd_[a-zA-Z0-9_-]+_handle' | sed 's/^cmd_//;s/_handle.*//')
        for ns in $funcs; do
            local path="${ns//_//}"
            cmd_paths+=("$path")
        done
    else
        # Development mode: check file permissions and read executability
        if [[ ${#CLISH_CONSOLE_CONSOLE_KERNEL_COMMAND_PATHS[@]} -gt 0 ]]; then
            for candidate in "${CLISH_CONSOLE_CONSOLE_KERNEL_COMMAND_PATHS[@]}"; do
                local file="$CLISH_CONSOLE_CONSOLE_KERNEL_BIN_DIR/$candidate"

                # Check existence and readability (needed to source later)
                if [[ ! -f "$file" ]]; then
                    echo "Warning: '$file' is not a regular file. Skipping." >&2
                    continue
                fi
                if [[ ! -r "$file" ]]; then
                    echo "Warning: '$file' is not readable. Skipping." >&2
                    continue
                fi

                # Warn about missing execute permission, but still show the command
                if [[ ! -x "$file" ]]; then
                    echo "Warning: '$file' is not executable. Check permissions." >&2
                fi

                cmd_paths+=("$candidate")
            done
        # If no paths provided in development mode, result will be empty
        fi
    fi

    if [[ ${#cmd_paths[@]} -eq 0 ]]; then
        echo "  (no commands found)"
        return
    fi

    # Sort paths using while read loop to avoid SC2207
    local sorted_cmds=()
    while IFS= read -r line; do
        sorted_cmds+=("$line")
    done < <(printf "%s\n" "${cmd_paths[@]}" | sort)
    cmd_paths=("${sorted_cmds[@]}")

    local -a ungrouped=()
    local -a grouped_paths=()
    local -a grouped_groups=()
    for path in "${cmd_paths[@]}"; do
        if [[ "$path" == */* ]]; then
            local group="${path%%/*}"
            grouped_paths+=("$path")
            grouped_groups+=("$group")
        else
            ungrouped+=("$path")
        fi
    done

    # Helper to get description depending on mode
    _get_cmd_description() {
        local cmd_name="$1"
        local ns="cmd_${cmd_name//\//_}"

        if clish_console_is_packaged; then
            # In packaged mode functions are already in memory
            if declare -f "${ns}_description" >/dev/null; then
                "${ns}_description"
            fi
        else
            # Development mode: source the file (we already know it's readable)
            local file="$CLISH_CONSOLE_CONSOLE_KERNEL_BIN_DIR/$cmd_name"
            if [[ -f "$file" ]]; then
                # shellcheck source=/dev/null
                source "$file" 2>/dev/null
                if declare -f "${ns}_description" >/dev/null; then
                    "${ns}_description"
                fi
            fi
        fi
    }

    # Print ungrouped commands
    for cmd in "${ungrouped[@]}"; do
        local desc
        desc="$(_get_cmd_description "$cmd")"
        printf "    %-24s %s\n" "$cmd" "$desc"
    done
    [[ ${#ungrouped[@]} -gt 0 ]] && echo

    if [[ ${#grouped_paths[@]} -eq 0 ]]; then
        return
    fi

    local -a unique_groups=()
    for grp in "${grouped_groups[@]}"; do
        local found=0
        for ug in "${unique_groups[@]}"; do
            [[ "$ug" == "$grp" ]] && found=1 && break
        done
        [[ $found -eq 0 ]] && unique_groups+=("$grp")
    done

    for grp in "${unique_groups[@]}"; do
        echo -e "  ${CLISH_CONSOLE_CORE_INIT_COLOR_CYAN}${grp}${CLISH_CONSOLE_CORE_INIT_COLOR_RESET}"
        for i in "${!grouped_paths[@]}"; do
            if [[ "${grouped_groups[$i]}" == "$grp" ]]; then
                local full_path="${grouped_paths[$i]}"
                local display="${full_path//\//:}"
                local desc
                desc="$(_get_cmd_description "$full_path")"
                printf "    %-24s %s\n" "$display" "$desc"
            fi
        done
        echo
    done
}

clish_console_console_help_show_global_help() {
    if [[ "$CLISH_CONSOLE_CORE_INIT_QUIET" == "true" ]]; then
        return
    fi
    local version
    version="$(clish_console_console_help_get_version)"
    cat <<'BANNER'
 ___    _             _     
(  _`\ (_ )  _       ( )    
| ( (_) | | (_)  ___ | |__  
| |  _  | | | |/',__)|  _ `\
| (_( ) | | | |\__, \| | | |
(____/'(___)(_)(____/(_) (_)
BANNER
    echo
    echo "Clish Console version ${version}  $(date -u +"%Y-%m-%d %H:%M:%S")"
    echo
    echo "Usage:"
    echo "  $0 [options] <command> [arguments]"
    echo
    echo "Options:"
    printf "  ${CLISH_CONSOLE_CORE_INIT_COLOR_GREEN}%-28s${CLISH_CONSOLE_CORE_INIT_COLOR_RESET} %s\n" "-h, --help" "Display help for the given command"
    printf "  ${CLISH_CONSOLE_CORE_INIT_COLOR_GREEN}%-28s${CLISH_CONSOLE_CORE_INIT_COLOR_RESET} %s\n" "-q, --quiet" "Do not output any message"
    printf "  ${CLISH_CONSOLE_CORE_INIT_COLOR_GREEN}%-28s${CLISH_CONSOLE_CORE_INIT_COLOR_RESET} %s\n" "-V, --version" "Display this application version"
    printf "  ${CLISH_CONSOLE_CORE_INIT_COLOR_GREEN}%-28s${CLISH_CONSOLE_CORE_INIT_COLOR_RESET} %s\n" "-n, --no-interaction" "Do not ask any interactive question"
    printf "  ${CLISH_CONSOLE_CORE_INIT_COLOR_GREEN}%-28s${CLISH_CONSOLE_CORE_INIT_COLOR_RESET} %s\n" "-v|vv|vvv, --verbose" "Increase the verbosity of messages"
    # Only show --debug if debug is not explicitly disabled
    if [[ -z "${CLISH_CONSOLE_CLOSE_DEBUG_ENABLED:-}" ]]; then
        printf "  ${CLISH_CONSOLE_CORE_INIT_COLOR_GREEN}%-28s${CLISH_CONSOLE_CORE_INIT_COLOR_RESET} %s\n" "--debug" "Enable debug mode (set -x)"
    fi
    echo
    echo "Available commands:"
    _clish_console_console_help_list_commands
}