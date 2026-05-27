#!/usr/bin/env bash

# ==============================================================================
# Script Name:  create_users.sh
# Description:  Creates Linux user accounts from a CSV file (FirstName, LastName, BirthDate)
#               with default passwords formatted as "FirstName.LastName.BirthDate".
#               Detects the running Linux distribution and adapts commands.
# Requirements: Must be run as root/sudo.
# ==============================================================================

# Exit immediately if a command exits with a non-zero status
set -o pipefail

# --- Color Definitions for Output ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Disable colors if output is not a TTY
if [ ! -t 1 ]; then
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    NC=''
fi

# --- Helper Functions ---

# Print info message
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

# Print success message
log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Print warning message
log_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

# Print error message and optionally exit
log_error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
    if [ "$2" = "exit" ]; then
        exit 1
    fi
}

# Print usage instructions
show_usage() {
    echo "Usage: sudo $0 <path_to_csv_file>"
    echo "Format of CSV: FirstName,LastName,BirthDate"
    echo "Supported delimiters: comma (,) or semicolon (;)"
}

# Normalize text to produce a valid Linux username
normalize_username() {
    local input="$1"
    # Convert to lowercase
    input=$(echo "$input" | tr '[:upper:]' '[:lower:]')
    # Replace German Umlauts & Special characters
    input=$(echo "$input" | sed 's/ä/ae/g; s/ö/oe/g; s/ü/ue/g; s/ß/ss/g')
    # Replace spaces with dashes
    input=$(echo "$input" | sed 's/ /-/g')
    # Remove any character that is not lowercase alphanumeric, dot, or dash
    input=$(echo "$input" | sed 's/[^a-z0-9.-]//g')
    # Remove trailing dot or dash just in case
    input=$(echo "$input" | sed 's/[.-]$//g')
    echo "$input"
}

# --- Validation: Run as root ---
if [ "$EUID" -ne 0 ]; then
    log_error "This script must be run as root or with sudo." "exit"
fi

# --- Validation: Argument Check ---
if [ $# -ne 1 ] || [ "$1" = "-h" ] || [ "$1" = "--help" ]; then
    show_usage
    exit 1
fi

CSV_FILE="$1"

# Check if CSV file exists
if [ ! -f "$CSV_FILE" ]; then
    log_error "File '$CSV_FILE' not found." "exit"
fi

# --- Distribution Detection ---
DISTRO_ID="unknown"
DISTRO_NAME="Unknown Linux Distribution"

detect_distro() {
    if [ -f /etc/os-release ]; then
        # Load variables from os-release
        . /etc/os-release
        DISTRO_ID="$ID"
        DISTRO_NAME="$NAME"
    elif [ -f /etc/debian_version ]; then
        DISTRO_ID="debian"
        DISTRO_NAME="Debian"
    elif [ -f /etc/redhat-release ]; then
        DISTRO_ID="rhel"
        DISTRO_NAME="Red Hat Enterprise Linux"
    fi
    log_info "Detected OS: $DISTRO_NAME ($DISTRO_ID)"
}

detect_distro

# --- User Creation Wrapper ---
# Adapts command options based on distribution
create_user_account() {
    local username="$1"
    local shell="/bin/bash"

    # Alpine Linux uses BusyBox commands
    if [ "$DISTRO_ID" = "alpine" ]; then
        shell="/bin/sh"
        # -s: login shell
        # -D: don't assign password (we set it later)
        if adduser -s "$shell" -D "$username" >/dev/null 2>&1; then
            return 0
        else
            return 1
        fi
    else
        # Standard useradd for Debian, Ubuntu, RHEL, CentOS, Fedora, Arch, etc.
        # Check if bash is available, fallback to sh if not
        if [ ! -x /bin/bash ]; then
            shell="/bin/sh"
        fi
        # -m: create home directory
        # -s: shell
        if useradd -m -s "$shell" "$username" >/dev/null 2>&1; then
            return 0
        else
            return 1
        fi
    fi
}

# --- Password Assignment Wrapper ---
# Securely sets password using distribution-appropriate method
set_user_password() {
    local username="$1"
    local password="$2"

    # 1. Preferred method: chpasswd (works on Debian, Ubuntu, Fedora, Alpine, RHEL, etc.)
    if command -v chpasswd >/dev/null 2>&1; then
        if echo "$username:$password" | chpasswd >/dev/null 2>&1; then
            return 0
        fi
    fi

    # 2. Fallback: passwd --stdin (supported on some RedHat/CentOS flavors)
    if passwd --help 2>&1 | grep -q -- "--stdin"; then
        if echo "$password" | passwd --stdin "$username" >/dev/null 2>&1; then
            return 0
        fi
    fi

    # 3. Fallback: Interactive emulation
    if printf "%s\n%s\n" "$password" "$password" | passwd "$username" >/dev/null 2>&1; then
        return 0
    fi

    return 1
}

# --- Process CSV File ---

# Detect CSV Delimiter (comma or semicolon)
first_line=$(head -n 1 "$CSV_FILE" | tr -d '\r')
if echo "$first_line" | grep -q ";"; then
    DELIMITER=";"
    log_info "Detected delimiter: Semicolon (;)"
else
    DELIMITER=","
    log_info "Detected delimiter: Comma (,)"
fi

log_info "Processing users from CSV..."
echo "--------------------------------------------------"

success_count=0
fail_count=0
skip_count=0

# Clean carriage returns (\r) to support Windows-edited CSVs
tr -d '\r' < "$CSV_FILE" | while IFS="$DELIMITER" read -r first_name last_name birth_date || [ -n "$first_name" ]; do
    # Trim leading/trailing whitespace
    first_name=$(echo "$first_name" | xargs)
    last_name=$(echo "$last_name" | xargs)
    birth_date=$(echo "$birth_date" | xargs)

    # Skip header line (check English and German headers for flexibility)
    if [[ "${first_name,,}" == "firstname" ]] || [[ "${first_name,,}" == "vorname" ]]; then
        continue
    fi

    # Skip empty lines
    if [ -z "$first_name" ] && [ -z "$last_name" ]; then
        continue
    fi

    # Generate Username and Password
    username=$(normalize_username "${first_name}.${last_name}")
    password="${first_name}.${last_name}.${birth_date}"

    # Validation: Ensure username is not empty
    if [ -z "$username" ]; then
        log_error "Could not generate a valid username for '$first_name $last_name'. Skipping."
        ((fail_count++))
        continue
    fi

    # Check if user already exists
    if id "$username" >/dev/null 2>&1; then
        log_warning "User '$username' already exists. Skipping user creation."
        ((skip_count++))
        continue
    fi

    # Create user
    if create_user_account "$username"; then
        # Set password
        if set_user_password "$username" "$password"; then
            log_success "Created user '$username' with password '$password'"
            ((success_count++))
        else
            log_error "User '$username' was created, but setting the password failed."
            ((fail_count++))
        fi
    else
        log_error "Failed to create user account for '$username'."
        ((fail_count++))
    fi
done

echo "--------------------------------------------------"
log_info "Summary:"
log_success "  Successfully created: $success_count"
[ $skip_count -gt 0 ] && log_warning "  Skipped (already exists): $skip_count"
[ $fail_count -gt 0 ] && log_error "  Failed: $fail_count"

exit 0
