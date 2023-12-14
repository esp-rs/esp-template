echo "Verifying $1"
# TODO: We might be able to check GITHUB_TOKEN and update the --path to make it work locally.
# Complex template
cargo generate \
    --path "/home/runner/work/esp-template/esp-template/esp-template-gh" \
    --silent --vcs=none --name=test-complex \
    -d advanced=true -d ci=false -d devcontainer=false -d wokwi=false \
    -d alloc=true -d logging=true -d wifi=true \
    -d mcu=$1
# Simple template
cargo generate \
    --path "/home/runner/work/esp-template/esp-template/esp-template-gh" \
    --silent --vcs=none --name=test-simple \
    -d advanced=true -d ci=false -d devcontainer=false -d wokwi=false \
    -d alloc=false -d logging=false -d wifi=false \
    -d mcu=$1

cd test-complex
echo "Build check"
cargo build --release
echo "Rustfmt check"
cargo fmt -- --check
echo "Clippy check"
cargo clippy --no-deps -- -D warnings -A dead_code -A clippy::empty_loop
cd ../test-simple
echo "Build check"
cargo build --release
echo "Rustfmt check"
cargo fmt -- --check
echo "Clippy check"
cargo clippy --no-deps -- -D warnings -A dead_code -A clippy::empty_loop
cd ..
rm -rf test-*
