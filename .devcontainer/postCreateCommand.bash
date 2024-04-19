#!/bin/bash

echo give permission to bashfiles
chmod a+x bt.bash sub.bash
chmod a+x scripts/change_launch.bash


# 先にrust-toolchainをインストールするとcargo-competeがコンパイルできなかった2024/4/19
if [ -f "rust-toolchain" ]; then
    rm rust-toolchain
fi

# cargo-memberで書き込むため
echo make Cargo.toml
touch Cargo.toml
sudo chmod a+w Cargo.toml

# install cargo tools
echo install cargo tools
cargo install cargo-compete
cargo install cargo-member
cargo compete i atcoder
echo clone ac-library-rs
git clone https://github.com/rust-lang-ja/ac-library-rs.git

rustup component add rustfmt
rustup component add clippy

echo login to atcoder
cargo compete l atcoder

# install rustup tools
echo install rust-toolchain
echo "1.70" > rust-toolchain
cargo -V

# install online-judge-tools for generater
# pip3 install online-judge-template-generator


# rustup install 1.70
# rustup install 1.70.0-x86_64-unknown-linux-gnu

# The installation of fish is your choice.
# echo install fish and fisher
# sudo apt-add-repository ppa:fish-shell/release-3
# sudo apt-get update
# sudo apt-get install fish
# curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher