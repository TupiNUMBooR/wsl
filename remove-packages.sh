#!/usr/bin/env bash
set -euo pipefail

pacman -Rns $(comm -23 <(pacman -Qqe | sort) <(sort packages.txt))
