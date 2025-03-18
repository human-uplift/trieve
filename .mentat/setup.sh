#!/bin/bash
set -e

# Attempt to install system dependencies without sudo (for CI environment)
echo "Checking system dependencies..."
if command -v apt-get &> /dev/null; then
  echo "Debian/Ubuntu detected, attempting to install dependencies (without sudo)..."
  # Try without sudo first, fall back to sudo if permission denied and sudo exists
  apt-get update || (command -v sudo &> /dev/null && sudo apt-get update) || echo "Could not update apt. Continuing..."
  apt-get install -y curl gcc g++ make pkg-config python3 python3-pip libpq-dev libssl-dev openssl || \
    (command -v sudo &> /dev/null && sudo apt-get install -y curl gcc g++ make pkg-config python3 python3-pip libpq-dev libssl-dev openssl) || \
    echo "Could not install dependencies with apt-get. Continuing..."
elif command -v pacman &> /dev/null; then
  echo "Arch Linux detected, attempting to install dependencies (without sudo)..."
  pacman -S --noconfirm base-devel postgresql-libs || \
    (command -v sudo &> /dev/null && sudo pacman -S --noconfirm base-devel postgresql-libs) || \
    echo "Could not install dependencies with pacman. Continuing..."
else
  echo "No supported package manager detected. Skipping system dependencies installation."
  echo "Please ensure required dependencies are available."
fi

# Install Rust if not installed
if ! command -v rustc &> /dev/null; then
  echo "Rust not found, installing..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  # Source path to rustc for the rest of this script
  source "$HOME/.cargo/env" || echo "Failed to source cargo env. You may need to restart your shell."
else
  echo "Rust is already installed"
fi

# Install cargo-watch
if command -v rustc &> /dev/null && ! command -v cargo-watch &> /dev/null; then
  echo "Installing cargo-watch..."
  cargo install cargo-watch || echo "Failed to install cargo-watch. Continuing..."
else
  echo "cargo-watch is already installed or rust is not available"
fi

# Install Node.js and Yarn if not installed
if ! command -v node &> /dev/null; then
  echo "Node.js not found, attempting to install using NVM..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash || echo "Failed to install NVM. Continuing..."
  
  # Try to load NVM
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  
  # Try to install Node.js and Yarn
  if command -v nvm &> /dev/null; then
    nvm install --lts || echo "Failed to install Node.js with NVM. Continuing..."
    npm install -g yarn || echo "Failed to install Yarn. Continuing..."
  fi
else
  echo "Node.js is already installed"
  if ! command -v yarn &> /dev/null; then
    echo "Yarn not found, installing..."
    npm install -g yarn || echo "Failed to install Yarn. Continuing..."
  else
    echo "Yarn is already installed"
  fi
fi

# Install Node.js dependencies if Node.js is available
if command -v node &> /dev/null && command -v yarn &> /dev/null; then
  echo "Installing Node.js dependencies..."
  yarn install || echo "Failed to install Node.js dependencies. Continuing..."
else
  echo "Skipping Node.js dependencies installation since Node.js or Yarn is not available"
fi

# Make server tmp dir
mkdir -p server/tmp

# Setup environment files if they don't exist
for env_file in .env.analytics .env.chat .env.dashboard .env.server .env.search; do
  if [ -f "$env_file" ]; then
    dest_file="${env_file/.env./}"
    if [[ "$dest_file" == "server" ]]; then
      dest_file="server/.env"
    else
      dest_file="frontends/${dest_file}/.env"
    fi
    
    if [[ ! -f "$dest_file" ]]; then
      echo "Copying $env_file to $dest_file"
      cp "$env_file" "$dest_file"
    fi
  fi
done

echo "Setup completed successfully!"
