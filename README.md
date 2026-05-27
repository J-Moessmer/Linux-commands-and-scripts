# Linux Commands and Scripts

This repository serves as a centralized collection for all of my small Linux projects, utility scripts, and commands. Each project is organized in its own subdirectory and contains its own detailed documentation.

## Table of Contents (TOC)

- [User Login Data Script](./user-login-data-script/README.md) - Bash script for automated user creation from a CSV file, supporting various Linux distributions.

---

## Project Details

### [User Login Data Script](./user-login-data-script/README.md)
* **Path**: `user-login-data-script/`
* **Description**: Reads a CSV file containing first names, last names, and birth dates, and creates corresponding Linux system users.
* **Key Features**:
  - Automatically detects the active Linux distribution (e.g., Debian/Ubuntu, RHEL/Fedora, Alpine, Arch) and applies the correct user-creation commands.
  - Normalizes names to generate valid Unix usernames (converts to lowercase, cleans German umlauts like `ä` -> `ae`, and strips invalid characters).
  - Assigns standard passwords following the pattern `Firstname.Lastname.Birthdate`.
  - Automatically cleans Windows carriage returns (`\r\n`).