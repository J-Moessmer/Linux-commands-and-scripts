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

## Flowchart

```mermaid
graph TD
    start["Start"] --> my_first["my_first_script.sh"]
    my_first --> print_params["print_parameters.sh"]
    print_params --> end["End"]
```

## Example Usage

### my_first_script.sh

```bash
chmod +x my_first_script.sh
./my_first_script.sh
```

Sample output:
```
Hello, my_first_script.sh!
```

### print_parameters.sh

```bash
chmod +x print_parameters.sh
./print_parameters.sh arg1 arg2 arg3
```

Sample output:
```
Script name: print_parameters.sh
Argument count: 3
Argument 1: arg1
Argument 2: arg2
Argument 3: arg3
```
