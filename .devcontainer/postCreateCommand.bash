#!/bin/bash

echo give permission to bashfiles
chmod a+x bt.bash sub.bash
sudo chmod a+x scripts/bt.bash scripts/sub.bash scripts/change_launch.bash

# install rustup tools
echo "1.70" > rust-toolchain
cargo -V

touch Cargo.toml

# install tools
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