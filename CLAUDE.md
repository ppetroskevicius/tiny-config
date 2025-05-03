# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose
This repository contains shell scripts for setting up minimal development environments on Mac or Ubuntu with Sway on Wayland.

## Commands
- Shellcheck: `shellcheck *.sh`
- Test script locally: `bash -x <script>.sh` (run with `-x` flag for debug output)
- Check script formatting: `shfmt -i 2 -ci -d *.sh`
- Format scripts: `shfmt -i 2 -ci -w *.sh`

## Code Style Guidelines
- Use 2-space indentation in shell scripts
- Follow Google Shell Style Guide: https://google.github.io/styleguide/shellguide.html
- Use lowercase variable names
- Add error handling with `set -euo pipefail` at script beginning
- Always quote variables: `"$variable"`
- Use full paths for file operations
- Use `#!/usr/bin/env bash` for portability
- Check for command existence with `command -v <cmd> > /dev/null`
- Use meaningful function and variable names
- Organize code into logical functions
- Add comments for non-obvious operations