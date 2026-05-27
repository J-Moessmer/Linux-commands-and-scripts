# IPv6 Validation

This utility validates IPv6 address strings against POSIX-extended regular expressions (supporting standard block layouts, compressed notations like `::`, link-local scopes, and mapped IPv4 addresses).

## Script

### [validate_ipv6.sh](./validate_ipv6.sh)
Checks whether an IP address matches the standard IPv6 specification. It can be run with a direct command-line argument or interactively.

**Usage with Argument**:
```bash
chmod +x validate_ipv6.sh
./validate_ipv6.sh 2001:db8::8a2e:370:7334
```

**Interactive Usage**:
```bash
./validate_ipv6.sh
# Will prompt: Please enter an IPv6 address to validate:
```

## Flowchart

```mermaid
graph TD
    start["Start"] --> read_input["Read Input"]
    read_input --> validate["Validate IPv6"]
    validate --> result["Print Result"]
    result --> end["End"]
```

## Example Run

```bash
chmod +x validate_ipv6.sh
./validate_ipv6.sh 2001:db8::8a2e:370:7334
```

Sample output:
```
2001:db8::8a2e:370:7334 is a valid IPv6 address.
```

```bash
./validate_ipv6.sh
# Prompt:
# Please enter an IPv6 address to validate:
2001:0db8:85a3:0000:0000:8a2e:0370:7334
```

Sample output:
```
2001:0db8:85a3:0000:0000:8a2e:0370:7334 is a valid IPv6 address.
```
