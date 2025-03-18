#!/bin/bash
set -e

# Check and install system dependencies
if command -v apt-get &> /dev/null; then
  echo "Debian/Ubuntu detected, installing system dependencies..."
  sudo apt-get update
  sudo apt-get install -y curl gcc g++ make pkg-config python3 python3-pip libpq-dev libssl-dev openssl
elif command -v pacman &> /dev/null; then
  echo "Arch Linux detected, installing system dependencies..."
  sudo pacman -S --noconfirm base-devel postgresql-libs
else
  echo "Warning: Unable to detect package manager. Skipping system dependencies installation."
  echo "Please install required dependencies manually if needed."
fi

# Install Rust if not installed
if ! command -v rustc &> /dev/null; then
  echo "Rust not found, installing..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  source "$HOME/.cargo/env"
else
  echo "Rust is already installed"
fi

# Install cargo-watch
if ! command -v cargo-watch &> /dev/null; then
  echo "Installing cargo-watch..."
  cargo install cargo-watch
else
  echo "cargo-watch is already installed"
fi

# Install Node.js and Yarn if not installed
if ! command -v node &> /dev/null; then
  echo "Node.js not found, installing using NVM..."
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.5/install.sh | bash
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  nvm install --lts
  npm install -g yarn
else
  echo "Node.js is already installed"
  if ! command -v yarn &> /dev/null; then
    echo "Yarn not found, installing..."
    npm install -g yarn
  else
    echo "Yarn is already installed"
  fi
fi

# Install Node.js dependencies
echo "Installing Node.js dependencies..."
yarn install

# Make server tmp dir
mkdir -p server/tmp

# Setup environment files if they don't exist
for env_file in .env.analytics .env.chat .env.dashboard .env.server .env.search; do
  dest_file="${env_file/.env./}"
  if [[ "$dest_file" == "server" ]]; then
    dest_file="server/.env"
  else
    dest_file="frontends/${dest_file}/.env"
  fi
  
  if [[ ! -f "$dest_file" && -f "$env_file" ]]; then
    echo "Copying $env_file to $dest_file"
    cp "$env_file" "$dest_file"
  fi
done

echo "Setup completed successfully!"
