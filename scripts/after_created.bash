touch rust-toolchain
echo "1.42" > rust-toolchain
cargo -V
rustup install 1.42
rustup install 1.42.0-x86_64-unknown-linux-gnu