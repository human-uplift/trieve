#!/bin/bash
set -e

echo "Running lightweight pre-commit checks for Trieve repository..."

# Only process files that are staged for commit
echo "Checking only staged files..."
STAGED_FILES=$(git diff --cached --name-only)

if [ -z "$STAGED_FILES" ]; then
    echo "No staged files found. Nothing to check."
    exit 0
fi

# Process Rust files
RUST_FILES=$(echo "$STAGED_FILES" | grep -E '\.rs$' || true)
if [ -n "$RUST_FILES" ]; then
    echo "Formatting Rust files:"
    for file in $RUST_FILES; do
        if [ -f "$file" ]; then
            echo "  - $file"
            # Only try to format if rustfmt is available
            if command -v rustfmt &> /dev/null; then
                rustfmt "$file" || echo "    ⚠️  Warning: Could not format $file"
            else
                echo "    ⚠️  Warning: rustfmt not found, skipping format"
            fi
        fi
    done
fi

# Process JS/TS files - very minimal check to avoid timeouts
JS_TS_FILES=$(echo "$STAGED_FILES" | grep -E '\.(js|ts|jsx|tsx)$' || true)
if [ -n "$JS_TS_FILES" ]; then
    echo "JS/TS files detected (not auto-formatting to avoid timeouts):"
    for file in $JS_TS_FILES; do
        echo "  - $file"
    done
    echo "  ℹ️  Run formatting manually: yarn prettier --write '<pattern>'"
fi

echo ""
echo "✅ Pre-commit check complete!"
echo ""
echo "📋 For comprehensive checks, run these manually:"
echo "- For Rust: cargo fmt && cargo clippy"
echo "- For JS/TS: yarn format && yarn lint"
