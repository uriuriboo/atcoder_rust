#!/bin/bash

if [ -e rust-toolchain ];then
    rm rust-toolchain
fi
echo give permission to bashfiels
chmod a+x bt.bash
chmod a+x sub.bash
chmod a+x scripts/bt.bash
chmod a+x scripts/sub.bash
echo install fish and fisher
sudo apt-add-repository ppa:fish-shell/release-3
sudo apt-get update
sudo apt-get install fish
curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher
cargo install cargo-compete
cargo compete i atcoder
echo login to atcoder
cargo compete l atcoder
# touch rust-toolchain
# echo "1.42" > rust-toolchain
# cargo -V
# rustup install 1.42
# rustup install 1.42.0-x86_64-unknown-linux-gnu