#!/usr/bin/env bash

# ================================================
# Bash Password Generator
# Supports: macOS / Linux
# Length: 12 to 48 characters
# Security profiles: low, medium, high, ultra
# Source of entropy: /dev/urandom
# ================================================

VERSION="1.0.0"


# ---------- COLORS ----------
green="\033[32m"
red="\033[31m"
yellow="\033[33m"
blue="\033[34m"
reset="\033[0m"

# ---------- ERROR HANDLER ----------
error() {
    echo -e "${red}Error: $1${reset}" >&2
    exit 1
}

# ---------- HELP ----------
show_help() {
    echo -e "${blue}Bash Password Generator${reset}"
    echo "Usage: passgen [-l <length>] [-p <profile>] [-c] [-i] [-v] [-h]"
    echo "Options:"
    echo "  -l <n>       Password length (12–48). Default: 16"
    echo "  -p <profile> Profile: low, medium, high, ultra. Default: high"
    echo "  -c           Copy password to clipboard (pbcopy/xclip)"
    echo "  -i           Interactive mode"
    echo "  -v           Show version"
    echo "  -h           Show help"
}

# ---------- VERSION ----------
show_version() {
    echo "Bash Password Generator v$VERSION"
}

# ---------- CHARSET PROFILES ----------
get_charset() {
    local profile="$1"
    case "$profile" in
        low)    echo "a-z" ;;
        medium) echo "A-Za-z0-9" ;;
        high)   echo "A-Za-z0-9!@#\$%&*()_+=\-{}\[\]<>?" ;;
        ultra)  echo "A-Za-z0-9!@#\$%&*()_+=\-{}\[\]<>?~^.,;:/|" ;;
        *)      echo "" ;;
    esac
}

# ---------- COPY TO CLIPBOARD ----------
copy_clipboard() {
    local pass="$1"
    if command -v pbcopy &>/dev/null; then
        echo -n "$pass" | pbcopy
        return 0
    elif command -v xclip &>/dev/null; then
        echo -n "$pass" | xclip -selection clipboard
        return 0
    fi
    return 1
}

# ---------- INTERACTIVE MODE ----------
interactive_mode() {
    echo -e "${yellow}Interactive mode${reset}"
    local length profile choice password

    read -p "Password length (12–48): " length
    if ! [[ "$length" =~ ^[0-9]+$ ]] || [ "$length" -lt 12 ] || [ "$length" -gt 48 ]; then
        error "Invalid length."
    fi

    echo "Security profiles:"
    echo "  1) low"
    echo "  2) medium"
    echo "  3) high"
    echo "  4) ultra"
    read -p "Choose (1–4): " choice

    case "$choice" in
        1) profile="low" ;;
        2) profile="medium" ;;
        3) profile="high" ;;
        4) profile="ultra" ;;
        *) error "Invalid option." ;;
    esac

    password=$(generate_password "$length" "$profile")
    echo -e "${green}Generated password:${reset} $password"
    if [ "$COPY" -eq 1 ]; then
        if copy_clipboard "$password"; then
            echo -e "${blue}Password copied to clipboard.${reset}"
        else
            error "Clipboard not supported on this system."
        fi
    fi
}

# ---------- GENERATE PASSWORD (SECURE) ----------
generate_password() {
    local length="$1"
    local profile="$2"
    local charset

    charset="$(get_charset "$profile")"
    [[ -z "$charset" ]] && error "Invalid profile."

    LC_ALL=C tr -dc "$charset" < /dev/urandom | head -c "$length"
}

# ---------- DEFAULTS ----------
LENGTH=16
PROFILE="high"
COPY=0
INTERACTIVE=0

# ---------- ARGUMENTS ----------
while getopts "l:p:icvh" opt; do
    case "$opt" in
        l) LENGTH="$OPTARG" ;;
        p) PROFILE="$OPTARG" ;;
        c) COPY=1 ;;
        i) INTERACTIVE=1 ;;
        v) show_version; exit 0 ;;
        h) show_help; exit 0 ;;
        *) show_help; exit 1 ;;
    esac
done


# ---------- LENGTH CHECK ----------
if ! [[ "$LENGTH" =~ ^[0-9]+$ ]]; then
    error "length must be numeric."
fi
if [ "$LENGTH" -lt 12 ] || [ "$LENGTH" -gt 48 ]; then
    error "password length must be between 12 and 48."
fi

# ---------- RUN ----------

if [ "$INTERACTIVE" -eq 1 ]; then
    interactive_mode
    exit 0
fi

password=$(generate_password "$LENGTH" "$PROFILE")
echo -e "${green}Generated password:${reset} $password"
if [ "$COPY" -eq 1 ]; then
    if copy_clipboard "$password"; then
        echo -e "${blue}Password copied to clipboard.${reset}"
    else
        error "Clipboard not supported on this system."
    fi
fi
