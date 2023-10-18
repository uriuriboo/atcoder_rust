#!/bin/bash

echo give permission to bashfiles
chmod u+x bt.bash,sub.bash,scripts/bt.bash,scripts/sub.bash,scripts/change_launch.bash

# install rustup tools
echo "1.70" > rust-toolchain
cargo -V
rustup component add rustfmt
rustup component add clippy

touch Cargo.toml

# install tools
cargo install cargo-compete
cargo install cargo-member
cargo compete i atcoder
echo clone ac-library-rs
git clone https://github.com/rust-lang-ja/ac-library-rs.git

echo login to atcoder
cargo compete l atcoder

# rustup install 1.70
# rustup install 1.70.0-x86_64-unknown-linux-gnu

# The installation of fish is your choice.
# echo install fish and fisher
# sudo apt-add-repository ppa:fish-shell/release-3
# sudo apt-get update
# sudo apt-get install fish
# curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher