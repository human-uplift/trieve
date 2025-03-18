#!/bin/bash

# Note: There's a 4-minute limit on this script
# We don't use set -e to ensure the script continues even if parts fail

echo "Starting setup process (4-minute time limit)..."

# Create essential directories first
echo "Creating essential directories..."
mkdir -p server/tmp

# Setup environment files if they don't exist (essential)
echo "Setting up environment files..."

# Validate frontend directories based on what actually exists
VALID_FRONTENDS=()
for dir in frontends/*/; do
  if [ -d "$dir" ]; then
    frontend=$(basename "$dir")
    VALID_FRONTENDS+=("$frontend")
  fi
done

echo "Found frontend directories: ${VALID_FRONTENDS[*]}"

# Process .env files
for env_file in .env.*; do
  # Skip if file doesn't exist or isn't a regular file
  [ ! -f "$env_file" ] && continue
  
  # Extract the part after .env.
  name="${env_file#.env.}"
  
  if [ "$name" = "server" ]; then
    # Handle server env file
    dest_dir="server"
    dest_file="$dest_dir/.env"
    
    # Ensure directory exists
    mkdir -p "$dest_dir"
    
    if [ ! -f "$dest_file" ]; then
      echo "Copying $env_file to $dest_file"
      cp "$env_file" "$dest_file" || echo "Failed to copy $env_file to $dest_file"
    fi
  elif [ "$name" = "docker-compose" ] || [ "$name" = "example" ]; then
    # Skip docker-compose and example env files
    echo "Skipping $env_file (not for direct use)"
    continue
  else
    # Check if this is a valid frontend directory
    is_valid=false
    for frontend in "${VALID_FRONTENDS[@]}"; do
      if [ "$name" = "$frontend" ]; then
        is_valid=true
        break
      fi
    done
    
    if [ "$is_valid" = true ]; then
      dest_dir="frontends/$name"
      dest_file="$dest_dir/.env"
      
      # Ensure directory exists
      mkdir -p "$dest_dir"
      
      if [ ! -f "$dest_file" ]; then
        echo "Copying $env_file to $dest_file"
        cp "$env_file" "$dest_file" || echo "Failed to copy $env_file to $dest_file"
      fi
    else
      echo "Skipping $env_file (no matching frontend directory found)"
    fi
  fi
done

# Check for minimum essential tools
echo "Checking for essential development tools..."

# Check if we need to install essential system packages
ESSENTIAL_PKGS_NEEDED=false
if ! command -v curl &> /dev/null || ! command -v gcc &> /dev/null; then
  ESSENTIAL_PKGS_NEEDED=true
fi

# Install minimal essential packages if needed
if [ "$ESSENTIAL_PKGS_NEEDED" = true ]; then
  echo "Installing minimal essential packages..."
  if command -v apt-get &> /dev/null; then
    apt-get update -qq || (command -v sudo &> /dev/null && sudo apt-get update -qq) || echo "Could not update apt. Continuing..."
    apt-get install -yq curl gcc || (command -v sudo &> /dev/null && sudo apt-get install -yq curl gcc) || echo "Could not install minimal packages. Continuing..."
  elif command -v pacman &> /dev/null; then
    pacman -Sy --noconfirm base-devel || (command -v sudo &> /dev/null && sudo pacman -Sy --noconfirm base-devel) || echo "Could not install minimal packages. Continuing..."
  else
    echo "No supported package manager detected."
  fi
fi

# Check Rust availability (essential)
if ! command -v rustc &> /dev/null; then
  echo "Rust not found, installing minimal Rust toolchain..."
  # Use timeout to ensure this doesn't hang indefinitely
  timeout 60 curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --profile minimal || echo "Failed to install Rust. Continuing..."
  
  # Source path to rustc for the rest of this script
  source "$HOME/.cargo/env" 2>/dev/null || echo "Failed to source cargo env. You may need to restart your shell."
else
  echo "Rust is already installed"
fi

# Basic Node.js check (essential for frontend work)
if ! command -v node &> /dev/null; then
  echo "Node.js not found. For frontend development, you'll need to install Node.js LTS."
  echo "To install Node.js manually, visit: https://nodejs.org/en/download/"
else
  echo "Node.js is installed: $(node --version)"
fi

if ! command -v yarn &> /dev/null; then
  echo "Yarn not found. For frontend development, you'll need to install Yarn."
  echo "To install Yarn manually: npm install -g yarn"
  
  # Try a quick installation of yarn if npm is available
  if command -v npm &> /dev/null; then
    echo "Installing Yarn using npm..."
    timeout 30 npm install -g yarn || echo "Failed to install Yarn. You'll need to install it manually."
  fi
else
  echo "Yarn is installed: $(yarn --version)"
fi

# =======================================================
# NOTICE TO USER: The script has a 4-minute time limit.
# The following operations are skipped for CI but recommended for local development.
# =======================================================
echo ""
echo "==== NOTICE ===="
echo "The following operations are skipped during CI due to the 4-minute time limit:"
echo "1. Full system dependency installation"
echo "2. cargo-watch installation"
echo "3. Running 'yarn install' to install all Node.js dependencies"
echo ""
echo "For local development, you should run these manually:"
echo "- Install system dependencies: apt/pacman install libpq-dev libssl-dev python3 python3-pip pkg-config g++ make"
echo "- Install cargo-watch: cargo install cargo-watch"
echo "- Install Node.js dependencies: yarn install"
echo "==== END NOTICE ===="
echo ""

echo "Basic setup completed successfully!"
echo "Note: For full development environment setup, please refer to the README.md"
