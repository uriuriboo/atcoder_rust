#/bin/bash

if [ -e rust-toolchain ];then
    rm rust-toolchain
fi
chmod a+x bt.bash
chmod a+x sub.bash
cargo install cargo-compete
cargo compete i atcoder
cargo compete l atcoder
# touch rust-toolchain
# echo "1.42" > rust-toolchain
# cargo -V
# rustup install 1.42
# rustup install 1.42.0-x86_64-unknown-linux-gnu