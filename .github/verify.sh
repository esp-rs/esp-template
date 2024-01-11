#!/bin/bash

set -e

echo "Verifying $1"

# If you want to execute this script locally, you need to update the path to
# esp-template direcotry and execute it from a folder outside of the esp-template
template_path="esp-template-gh"

# Function to perform build, Rustfmt check, and Clippy check
perform_checks() {
    cd "$1"
    echo " - Build check"
    cargo build --release
    echo "- Rustfmt check"
    cargo fmt -- --check
    echo "- Clippy check"
    cargo clippy --no-deps -- -D warnings -A dead_code -A clippy::empty_loop
    cd ..
}

# Generate templates
cargo generate \
    -a \
    --path $template_path --name=test-complex --silent --vcs=none \
    -d advanced=true -d ci=false -d devcontainer=false -d wokwi=false \
    -d alloc=true -d wifi=true -d mcu=$1

cargo generate \
    -a \
    --path $template_path --name=test-simple --silent --vcs=none \
    -d advanced=false -d mcu=$1

# Perform checks
perform_checks test-complex
perform_checks test-simple

# Clean up
rm -rf test-complex test-simple
