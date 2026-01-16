#!/bin/bash

################################################################################
# ATMu Installation Script
# Installs the Unmutable 3-Pane Tmux Dashboard
#
# Features:
#   - Checks for required dependencies (tmux, bash)
#   - Creates backups of existing configs with timestamp
#   - Copies configuration files to home directory
#   - Makes launch script executable
#   - Verifies installation success
#   - Idempotent (safe to run multiple times)
#
# Usage: ./install.sh [--force]
#   --force  Skip confirmation prompts
################################################################################

set -o pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Installation variables
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
FORCE_INSTALL=false

# Tracking variables
INSTALLED_FILES=()
BACKED_UP_FILES=()
ERRORS=0
WARNINGS=0
