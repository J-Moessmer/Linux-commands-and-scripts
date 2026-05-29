# Repository Context & AI Guidelines

This context file is designed for AI coding assistants (like Gemini, Cursor, Copilot, etc.) to quickly understand the structure, guidelines, and conventions of this repository. Refer to this file first to save context tokens and align with the repository standard.

---

## 1. Repository Purpose
This repository serves as a centralized collection of small Linux projects, utility scripts, and commands. All code, comments, documentation, and commit messages must be in **English**.

---

## 2. Directory Structure

Every project is self-contained in its own subdirectory with a dedicated `README.md` file:
```
.
├── README.md                  # Main repository overview, project index
├── .context/
│   └── context.md             # This file (AI Guidelines & rules)
├── assets/                    # Shared assets directory for projects (e.g., datasets, images)
├── user-login-data-script/    # CSV user account creator script
│   ├── create_users.sh
│   ├── users_sample.csv
│   └── README.md
├── bash-basics/               # Basic shell programming scripts
│   ├── my_first_script.sh
│   ├── print_parameters.sh
│   └── README.md
├── ipv6-validation/           # IPv6 address verification tool
│   ├── validate_ipv6.sh
│   └── README.md
├── regex-task-manager/        # Interactive Regex extraction TUI & scripts
│   ├── start_task_manager.sh
│   ├── README.md
│   └── scripts/
│       ├── task_01_ipv4.sh
│       ├── task_02_ipv6.sh
│       └── ... (tasks 3 to 10)
└── Auto-config_router/        # Automated Router/Client deployment system
    ├── autoconfig.sh
    ├── autoconfigv2.sh
    ├── Config.json
    ├── Config_template.json
    ├── Config_template.txt
    └── README.md
```

---

## 3. Project Index

| Project Name | Path | Description |
| :--- | :--- | :--- |
| **User Login Data Script** | `user-login-data-script/` | Reads user info from a CSV and creates Linux system accounts. Supports distro-aware command execution. |
| **Bash Basics** | `bash-basics/` | Basic introductory shell programming script exercises. |
| **IPv6 Validation** | `ipv6-validation/` | Regex-based address validation supporting CLI arguments and interactive prompts. |
| **Regex Task Manager** | `regex-task-manager/` | TUI dashboard to launch 10 different network, system, and protocol regex-extraction assignments. |
| **Auto-config Router** | `Auto-config_router/` | Distro-aware automation script for configuring systems as a Router or Client using a central JSON file. |

---

## 4. Scripting Standards & Conventions

To maintain high portability across Linux distributions:

* **Shell Compatibility**: Use `#!/usr/bin/env bash`.
* **Root Privileges**: Always verify if the script is run with root permissions if administrative tasks are involved (e.g., `[ "$EUID" -ne 0 ]`).
* **Distribution Awareness**:
  - Always check `/etc/os-release` to detect OS families.
  - Distinguish command structures between major OS platforms (e.g., standard `useradd` for Debian/RHEL/Arch vs. `adduser` for BusyBox/Alpine).
* **Portability of Commands**:
  - Fall back to standard shells `/bin/sh` if `/bin/bash` is absent (like in slim Alpine or custom Docker images).
  - Use `chpasswd` for setting passwords non-interactively if available, and provide fallbacks (`passwd --stdin` or interactive pipe emulation).
* **Windows Line Ending Compatibility**:
  - Scripts reading data files (like CSVs) must strip Carriage Returns (`\r`) automatically using commands like `tr -d '\r'` to support files edited on Windows hosts.
* **Robust Error Handling**:
  - Set `set -o pipefail` to ensure pipeline failures are detected.
  - Handle errors gracefully, and log warnings/errors with colored output (disabled if not writing to a TTY).
* **Naming Conventions**:
  - Folder names: `kebab-case` (e.g., `regex-task-manager`).
  - Script names: `snake_case.sh` (e.g., `task_01_ipv4.sh`).
  - Variables and functions inside scripts: `snake_case` (e.g., `first_name`, `normalize_username`).

---

## 5. Documentation Standards

Every project `README.md` must follow this structure:

1. **Title & Description** – Brief explanation of the project's purpose.
2. **Features** – Bullet-point list of capabilities.
3. **Flowchart** – Mermaid diagram illustrating the main execution flow.
4. **Usage / Example Run** – Step-by-step instructions (`chmod +x`, `sudo ./script.sh`) with sample terminal output.
5. **Technical Details** *(optional)* – Implementation notes for non-obvious logic.

### Mermaid Diagram Rules

* Always use `graph TD` (top-down) for flowcharts.
* **Avoid Mermaid reserved keywords as node IDs.** The following identifiers are reserved and will cause parse errors on GitHub:
  - `end`, `start`, `subgraph`
  - Use alternatives like `Done`, `Begin`, `Group` instead.
* Use plain identifiers without quotes where possible (e.g., `Start --> Menu`).
* Quoted labels with spaces are fine on the **right-hand side** of `-->` if wrapped in `["..."]`, but avoid them as standalone node IDs on the left.
* Always validate diagrams render correctly on GitHub before committing.

