#!/bin/bash
set -e

# Run Rust formatters
echo "Running Rust formatters..."
cargo fmt --manifest-path=./server/Cargo.toml

# Run JavaScript/TypeScript formatters and fixable linters
echo "Running JavaScript/TypeScript formatters and fixable linters..."
yarn lint

echo "Precommit checks completed successfully!"
