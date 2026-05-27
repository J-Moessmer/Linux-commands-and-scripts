#!/usr/bin/env bash

# ==============================================================================
# Script Name:  print_parameters.sh
# Description:  Demonstrates argument passing by printing parameters 1 to 10.
# Author:       Joshua Mößmer
# Date:         2026-05-13
# Note:         Braces must be used for parameters >= 10 (i.e. ${10}).
# ==============================================================================

echo "Script name: $0"
echo "Good day, this is my parameter printing script."
echo "Total arguments passed: $#"

echo "Parameter 1: $1"
echo "Parameter 2: $2"
echo "Parameter 3: $3"
echo "Parameter 4: $4"
echo "Parameter 5: $5"
echo "Parameter 6: $6"
echo "Parameter 7: $7"
echo "Parameter 8: $8"
echo "Parameter 9: $9"
echo "Parameter 10: ${10}"
