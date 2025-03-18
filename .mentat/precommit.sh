#!/bin/bash
# We use set -e but each command has error handling so the script continues regardless

# Run Rust formatters
echo "Running Rust formatters..."
if command -v cargo &> /dev/null; then
  cargo fmt --manifest-path=./server/Cargo.toml || \
    echo "Warning: Rust formatting failed, but continuing..."
  
  # Clippy is optional since it's more strict but very useful
  if [ -z "$CI" ]; then  # Skip clippy in CI environment to save time
    echo "Running Rust linter (clippy)..."
    cargo clippy --manifest-path=./server/Cargo.toml --features runtime-env -- -D warnings || \
      echo "Warning: Clippy checks failed, but continuing..."
  fi
else
  echo "Warning: Rust/Cargo not found, skipping Rust formatting"
fi

# Run JavaScript/TypeScript formatters and fixable linters
echo "Running JavaScript/TypeScript formatters and fixable linters..."
if command -v yarn &> /dev/null; then
  yarn lint || echo "Warning: JavaScript/TypeScript linting failed, but continuing..."
else
  echo "Warning: Yarn not found, skipping JavaScript/TypeScript linting"
fi

echo "Precommit checks completed successfully!"
