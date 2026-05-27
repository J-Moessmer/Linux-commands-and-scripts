#!/usr/bin/env bash

# ==============================================================================
# Script Name:  start_task_manager.sh
# Description:  Central TUI-based dashboard for running and examining various
#               regular expression extraction tasks (Day 09 tasks).
# Author:       Tobias B / Joshua Mößmer
# Date:         2026-05-18
# ==============================================================================

# --- Color Definitions ---
GREEN='\e[1;32m'
CYAN='\e[1;36m'
YELLOW='\e[1;33m'
RED='\e[1;31m'
MAGENTA='\e[1;35m'
BLUE='\e[1;34m'
NC='\e[0m' # No Color

# Determine base directory to avoid relative path issues
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SCRIPT_DIR="$BASE_DIR/scripts"

# Verify that script directory exists
if [ ! -d "$SCRIPT_DIR" ]; then
    echo -e "${RED}[Error: Scripts directory '$SCRIPT_DIR' does not exist!]${NC}"
    exit 1
fi

# Ensure execute permissions for all sub-scripts
chmod +x "$SCRIPT_DIR"/*.sh 2>/dev/null

# Helper: Draw separator line
draw_line() {
    echo -e "${BLUE}─────────────────────────────────────────────────────────────────────────────${NC}"
}

# TUI Main Loop
while true; do
    clear
    echo -e "${BLUE}┌───────────────────────────────────────────────────────────────────────────┐${NC}"
    echo -e "${BLUE}│${NC}                ${MAGENTA}🛠️  LINUX REGEX TASK MANAGER (Day 09) 🛠️${NC}                     ${BLUE}│${NC}"
    echo -e "${BLUE}│${NC}  ${CYAN}Author: Tobia / Joshua${NC} │  ${CYAN}Date: 2026-05-18${NC}  │  ${CYAN}Topic: Regular Expressions${NC}  ${BLUE}│${NC}"
    echo -e "${BLUE}└───────────────────────────────────────────────────────────────────────────┘${NC}"
    
    echo -e " Select an assignment to execute:\n"
    
    echo -e "  ${GREEN}[1]${NC}  Task 1:   Extract IPv4 addresses from network configs"
    echo -e "  ${GREEN}[1b]${NC} Task 1.b: Extract IPv6 addresses from network configs"
    echo -e "  ${GREEN}[2]${NC}  Task 2:   Extract network interface names"
    echo -e "  ${GREEN}[3]${NC}  Task 3:   Filter usernames with UID >= 1000 from passwd"
    echo -e "  ${GREEN}[4]${NC}  Task 4:   Filter group names with GID >= 1000 from group"
    echo -e "  ${GREEN}[5]${NC}  Task 5:   Extract 2nd column (Port/Proto) from /etc/services"
    echo -e "  ${GREEN}[6]${NC}  Task 6:   Filter & count 3-digit TCP ports"
    echo -e "  ${GREEN}[7]${NC}  Task 7:   Filter & count 2-digit and 5-digit TCP ports"
    echo -e "  ${GREEN}[8]${NC}  Task 8:   Count unique transport protocols from extracted services"
    echo -e "  ${GREEN}[9]${NC}  Task 9:   Filter & count UDP ports (3-digit, 2-digit, 5-digit)"
    
    draw_line
    echo -e "  ${RED}[x]${NC}  Exit"
    draw_line
    
    echo -ne " ${YELLOW}Your choice (1-9, 1b, x): ${NC}"
    read -r choice
    
    case "$choice" in
        1)
            clear
            bash "$SCRIPT_DIR/task_01_ipv4.sh"
            ;;
        1b|1B)
            clear
            bash "$SCRIPT_DIR/task_02_ipv6.sh"
            ;;
        2)
            clear
            bash "$SCRIPT_DIR/task_03_interfaces.sh"
            ;;
        3)
            clear
            bash "$SCRIPT_DIR/task_04_users.sh"
            ;;
        4)
            clear
            bash "$SCRIPT_DIR/task_05_groups.sh"
            ;;
        5)
            clear
            bash "$SCRIPT_DIR/task_06_extract_services.sh"
            ;;
        6)
            clear
            bash "$SCRIPT_DIR/task_07_count_3digit_tcp.sh"
            ;;
        7)
            clear
            bash "$SCRIPT_DIR/task_08_count_2_5digit_tcp.sh"
            ;;
        8)
            clear
            bash "$SCRIPT_DIR/task_09_unique_protocols.sh"
            ;;
        9)
            clear
            bash "$SCRIPT_DIR/task_10_count_udp.sh"
            ;;
        x|X|q|Q)
            echo -e "\n${GREEN}Thank you for using Regex Task Manager. Goodbye!${NC}"
            exit 0
            ;;
        *)
            echo -e "\n${RED}[Invalid selection! Please enter a number from 1 to 9, 1b or 'x'.]${NC}"
            ;;
    esac
    
    echo -ne "\n${YELLOW}Press [ENTER] to return to the menu...${NC}"
    read -r
done
