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
├── assets/                    # Shared assets directory for projects (e.g., images, diagrams)
└── [project-name]/            # Kebab-case directory for each project
    ├── README.md              # Project-specific usage and instructions
    ├── [script].sh            # Shell scripts (where applicable)
    └── [data].csv             # Accompanying sample data
```

---

## 3. Project Index

| Project Name | Path | Description |
| :--- | :--- | :--- |
| **User Login Data Script** | `user-login-data-script/` | Reads user info from a CSV and creates Linux system accounts. Supports distro-aware command execution. |

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
  - Folder names: `kebab-case` (e.g., `user-login-data-script`).
  - Script names: `snake_case.sh` (e.g., `create_users.sh`).
  - Variables and functions inside scripts: `snake_case` (e.g., `first_name`, `normalize_username`).
