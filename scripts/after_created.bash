touch rust-toolchain
echo "1.42" > rust-toolchain
cargo -V
rustup install 1.42
rustup install 1.42.0-x86_64-unknown-linux-gnu

# if you want to use rust-analyzer ,use rust-toolcain 1.65 or later
# echo "1.70" > rust-toolchain
# cargo -V
# rustup install 1.70
# rustup install 1.70.0-x86_64-unknown-linux-gnu