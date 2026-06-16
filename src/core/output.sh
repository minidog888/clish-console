#!/usr/bin/env bash
# ============================================
# Table Output Helper (Strict Namespaced)
# ============================================

clish_console_core_output_table() {
    local -a headers=()
    local -a rows=()
    local in_rows=false
    for arg in "$@"; do
        if [[ "$arg" == "--" ]]; then
            in_rows=true
            continue
        fi
        if [[ "$in_rows" == false ]]; then
            headers+=("$arg")
        else
            rows+=("$arg")
        fi
    done

    local -a widths=()
    for i in "${!headers[@]}"; do
        widths[i]=${#headers[i]}
    done
    for row in "${rows[@]}"; do
        IFS='|' read -ra cols <<< "$row"
        for i in "${!cols[@]}"; do
            if [[ ${#cols[i]} -gt ${widths[i]} ]]; then
                widths[i]=${#cols[i]}
            fi
        done
    done

    local header_line=""
    for i in "${!headers[@]}"; do
        header_line+="$(printf "%-${widths[i]}s" "${headers[i]}")  "
    done
    echo "$header_line"

    local sep_line=""
    for i in "${!headers[@]}"; do
        sep_line+="$(printf "%${widths[i]}s" | tr ' ' '-')  "
    done
    echo "$sep_line"

    for row in "${rows[@]}"; do
        IFS='|' read -ra cols <<< "$row"
        local row_line=""
        for i in "${!cols[@]}"; do
            row_line+="$(printf "%-${widths[i]}s" "${cols[i]}")  "
        done
        echo "$row_line"
    done
}