#!/usr/bin/env bash
# ============================================
# Declarative Options & Arguments (Strict Namespaced)
# ============================================

__CLISH_CONSOLE_CORE_OPTIONS_OPT_NAMES=()
__CLISH_CONSOLE_CORE_OPTIONS_OPT_HAS_ARG=()
__CLISH_CONSOLE_CORE_OPTIONS_OPT_DESC=()
__CLISH_CONSOLE_CORE_OPTIONS_ARG_NAMES=()
__CLISH_CONSOLE_CORE_OPTIONS_ARG_DESC=()

clish_console_core_options_clear_registry() {
    __CLISH_CONSOLE_CORE_OPTIONS_OPT_NAMES=()
    __CLISH_CONSOLE_CORE_OPTIONS_OPT_HAS_ARG=()
    __CLISH_CONSOLE_CORE_OPTIONS_OPT_DESC=()
    __CLISH_CONSOLE_CORE_OPTIONS_ARG_NAMES=()
    __CLISH_CONSOLE_CORE_OPTIONS_ARG_DESC=()
}

clish_console_core_options_option() {
    local name="$1"
    local desc=""
    local need_arg=false
    shift
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --arg) need_arg=true; shift ;;
            *) desc="$1"; shift ;;
        esac
    done
    __CLISH_CONSOLE_CORE_OPTIONS_OPT_NAMES+=("$name")
    __CLISH_CONSOLE_CORE_OPTIONS_OPT_HAS_ARG+=("$need_arg")
    __CLISH_CONSOLE_CORE_OPTIONS_OPT_DESC+=("$desc")
}

clish_console_core_options_argument() {
    local name="$1"
    local desc="${2:-}"
    __CLISH_CONSOLE_CORE_OPTIONS_ARG_NAMES+=("$name")
    __CLISH_CONSOLE_CORE_OPTIONS_ARG_DESC+=("$desc")
}

clish_console_core_options_generate_spec() {
    local spec=""
    for i in "${!__CLISH_CONSOLE_CORE_OPTIONS_OPT_NAMES[@]}"; do
        local name="${__CLISH_CONSOLE_CORE_OPTIONS_OPT_NAMES[$i]}"
        local need_arg="${__CLISH_CONSOLE_CORE_OPTIONS_OPT_HAS_ARG[$i]}"
        if [[ "$need_arg" == "true" ]]; then
            spec="$spec ${name}:"
        else
            spec="$spec ${name}"
        fi
    done
    spec="${spec# }"
    echo "$spec"
}

clish_console_core_options_generate_help() {
    if [[ "$CLISH_CONSOLE_CORE_INIT_QUIET" == "true" ]]; then
        return 1
    fi
    local output=""
    output+="Usage: $(basename "$0") ${__CLISH_CONSOLE_CONSOLE_KERNEL_CMD_NAME:-command}\n"
    if [[ ${#__CLISH_CONSOLE_CORE_OPTIONS_OPT_NAMES[@]} -gt 0 ]]; then
        output+="\nOptions:\n"
        for i in "${!__CLISH_CONSOLE_CORE_OPTIONS_OPT_NAMES[@]}"; do
            local name="${__CLISH_CONSOLE_CORE_OPTIONS_OPT_NAMES[$i]}"
            local need_arg="${__CLISH_CONSOLE_CORE_OPTIONS_OPT_HAS_ARG[$i]}"
            local desc="${__CLISH_CONSOLE_CORE_OPTIONS_OPT_DESC[$i]}"
            if [[ "$need_arg" == "true" ]]; then
                output+="  --${name}=<value>    ${desc}\n"
            else
                output+="  --${name}            ${desc}\n"
            fi
        done
    fi
    if [[ ${#__CLISH_CONSOLE_CORE_OPTIONS_ARG_NAMES[@]} -gt 0 ]]; then
        output+="\nArguments:\n"
        for i in "${!__CLISH_CONSOLE_CORE_OPTIONS_ARG_NAMES[@]}"; do
            local name="${__CLISH_CONSOLE_CORE_OPTIONS_ARG_NAMES[$i]}"
            local desc="${__CLISH_CONSOLE_CORE_OPTIONS_ARG_DESC[$i]}"
            output+="  ${name}               ${desc}\n"
        done
    fi
    echo -e "$output"
    return 0
}

clish_console_core_options_parse() {
    local spec="$1"
    shift
    # Build normalized option list (replace '-' with '_' in option names)
    local opts=()
    for token in $spec; do
        local opt_name
        if [[ "$token" == *: ]]; then
            opt_name="${token%:}"
        else
            opt_name="$token"
        fi
        # Normalize name
        opt_name="${opt_name//-/_}"
        opts+=("$opt_name")
    done

    # Clear old option variables (using normalized names)
    for opt in "${opts[@]}"; do
        unset "opt_$opt"
    done

    local leftover=()
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --)
                shift
                leftover+=("$@")
                break
                ;;
            --*)
                local raw="${1#--}"
                local opt="${raw%%=*}"
                local val="${raw#*=}"
                # Normalize option name (replace '-' with '_')
                local opt_underscore="${opt//-/_}"
                local found=0
                for declared in "${opts[@]}"; do
                    if [[ "$declared" == "$opt_underscore" ]]; then
                        found=1
                        # Check if argument is required: original spec contains "opt:"
                        if [[ "$spec" == *"$opt:"* ]]; then
                            if [[ "$val" != "$raw" ]]; then
                                printf -v "opt_$opt_underscore" "%s" "$val"
                            else
                                shift
                                printf -v "opt_$opt_underscore" "%s" "$1"
                            fi
                        else
                            printf -v "opt_$opt_underscore" "true"
                        fi
                        break
                    fi
                done
                if [[ $found -eq 0 ]]; then
                    clish_console_core_log_error "Unknown option: --$opt"
                fi
                ;;
            *)
                leftover+=("$1")
                ;;
        esac
        shift
    done
    # shellcheck disable=SC2034
    opt_arguments=("${leftover[@]}")
}