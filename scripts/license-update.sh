#!/usr/bin/env bash

# Get full date: "January 1, 2025"
FULL_DATE=$(date +"%B %d, %Y")

# Update LICENSE file, replacing only the date
sed -i "s/Copyright © [A-Za-z]* [0-9]*, [0-9]*\(.*\)$/Copyright © $FULL_DATE\1/" LICENSE

# Update README.md file, replacing only the date
sed -i "s/Copyright © [A-Za-z]* [0-9]*, [0-9]*\(.*\)$/Copyright © $FULL_DATE\1/" README.md
