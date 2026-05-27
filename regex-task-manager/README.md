# Regex Task Manager

This project is a terminal-based dashboard that guides you through several regular expression tasks (designed for extraction, parsing, and filtering).

It provides an interactive menu (TUI) to run specific sub-scripts that demonstrate how to use `grep`, `sed`, and `awk` with regular expressions on live Linux system utilities or fallback data backups.

## Dashboard Menu

### [start_task_manager.sh](./start_task_manager.sh)
The main entry point script. It provides a visual menu listing all 10 assignments, prompts for user selection, and executes the target script.

**To launch the dashboard**:
```bash
chmod +x start_task_manager.sh
./start_task_manager.sh
```

---

## Assignments & Scripts (inside `scripts/`)

Each assignment is mapped to a dedicated script:

1. **Task 1: Extract IPv4 Addresses** (`task_01_ipv4.sh`)
   - Uses a mathematically correct regex to extract valid IPv4 octets (0–255) from the output of `ifconfig`, `ip addr`, `ip route`, or `nmcli`.
2. **Task 1.b: Extract IPv6 Addresses** (`task_02_ipv6.sh`)
   - Filters standard and compressed IPv6 notations from network configuration outputs.
3. **Task 2: Extract Network Interfaces** (`task_03_interfaces.sh`)
   - Extracts network interface names (e.g. `eth0`, `lo`, `wlan0`) using command-specific parsing.
4. **Task 3: Passwd Regular Users** (`task_04_users.sh`)
   - Reads `/etc/passwd` and identifies regular user accounts (UID >= 1000) using the regex `[1-9][0-9]{3,}`.
5. **Task 4: Group Regular Groups** (`task_05_groups.sh`)
   - Reads `/etc/group` and filters regular group accounts (GID >= 1000).
6. **Task 5: Extract Services Column** (`task_06_extract_services.sh`)
   - Uses `sed` to strip empty and comment lines, capture the second column (port/protocol) from `/etc/services`, and write the results to `services_extracted.txt`.
7. **Task 6: Count 3-Digit TCP Ports** (`task_07_count_3digit_tcp.sh`)
   - Reads the output of Task 5 and counts all TCP ports containing exactly 3 digits.
8. **Task 7: Count 2- & 5-Digit TCP Ports** (`task_08_count_2_5digit_tcp.sh`)
   - Counts and sums all TCP ports matching exactly 2 or 5 digits.
9. **Task 8: Count Unique Protocols** (`task_09_unique_protocols.sh`)
   - Deduplicates and lists all unique transport protocols (e.g., `tcp`, `udp`, `sctp`) in the services dump.
10. **Task 9: Count UDP Ports** (`task_10_count_udp.sh`)
    - Performs the counts from Tasks 6 & 7 specifically for the UDP protocol.
