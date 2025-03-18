#!/bin/bash
set -e

echo "Checking development environment for Trieve repository..."

# Simply check for required tools
echo "Checking for required development tools..."

# Check for Rust
if command -v rustc &> /dev/null; then
    RUST_VERSION=$(rustc --version)
    echo "✅ Rust is installed: $RUST_VERSION"
else
    echo "❌ Rust is required but not installed. Please install from https://rustup.rs/"
fi

# Check for Node.js
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    echo "✅ Node.js is installed: $NODE_VERSION"
    
    # Warn about Node.js version if it's less than 20
    if [[ $(echo "$NODE_VERSION" | tr -d 'v' | cut -d. -f1) -lt 20 ]]; then
        echo "⚠️  Warning: Some dependencies require Node.js 20+. You have $NODE_VERSION."
        echo "   Consider upgrading your Node.js version."
    fi
else
    echo "❌ Node.js is required but not installed. Please install from https://nodejs.org/"
fi

# Check for package managers
if command -v yarn &> /dev/null; then
    YARN_VERSION=$(yarn --version)
    echo "✅ Yarn is installed: $YARN_VERSION"
else
    echo "⚠️  Yarn is not installed. npm will be used if needed."
fi

echo ""
echo "Setup check complete!"
echo ""
echo "📋 Manual Setup Instructions:"
echo "- To install Rust dependencies: cd into the specific directory and run 'cargo fetch'"
echo "- To install Node.js dependencies: cd into the specific directory and run 'yarn install'"
echo "- For Rust development: consider installing 'cargo install diesel_cli --no-default-features --features postgres'"
echo ""
echo "Note: The repository has a 4-minute limit for setup scripts. For a more complete setup,"
echo "you'll need to install dependencies manually in the directories you're working with."
