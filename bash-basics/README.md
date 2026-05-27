# Bash Basics

This project directory contains basic shell scripts introduced for learning Bash programming concepts.

## Scripts

### 1. [my_first_script.sh](./my_first_script.sh)
A basic template script that prints a standard greeting and outputs its own script name using `$0`.

**Usage**:
```bash
chmod +x my_first_script.sh
./my_first_script.sh
```

### 2. [print_parameters.sh](./print_parameters.sh)
Demonstrates parameter parsing and positional arguments in Bash (from `$1` to `${10}`). It prints the script name, the total count of passed arguments (`$#`), and each parameter individual value.

**Usage**:
```bash
chmod +x print_parameters.sh
./print_parameters.sh arg1 arg2 arg3 arg4 arg5 arg6 arg7 arg8 arg9 arg10
```
