#!/bin/bash

echo "Verifying $1"
# TODO: We might be able to check GITHUB_TOKEN and update the --path to make it work locally.

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

complex_path="test-complex"
simple_path="test-simple"
simple_wifi_arg=""
complex_wifi_arg=""

# H2 has no wifi
if [ "$1" != "esp32h2" ]; then
    simple_wifi_arg="-d wifi=false"
    complex_wifi_arg="-d wifi=true"
fi

# Complex template
cargo generate \
    --path "/home/runner/work/esp-template/esp-template/esp-template-gh" \
    --silent --vcs=none --name=test-complex \
    -d advanced=true -d ci=false -d devcontainer=false -d wokwi=false \
    -d alloc=true -d logging=true $simple_wifi_arg \
    -d mcu=$1

# Simple template
cargo generate \
    --path "/home/runner/work/esp-template/esp-template/esp-template-gh" \
    --silent --vcs=none --name=test-simple \
    -d advanced=true -d ci=false -d devcontainer=false -d wokwi=false \
    -d alloc=false -d logging=false $complex_wifi_arg \
    -d mcu=$1

# Perform checks for complex and simple templates
perform_checks test-complex
perform_checks test-simple

# Clean up
rm -rf test-complex test-simple
