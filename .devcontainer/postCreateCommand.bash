#!/bin/bash

echo give permission to bashfiles
chmod a+x scripts/*.bash


# 先にrust-toolchainをインストールするとcargo-competeがコンパイルできなかった2024/4/19
if [ -f "rust-toolchain" ]; then
    rm rust-toolchain
fi

# cargo-memberで書き込むため
echo make Cargo.toml
touch Cargo.toml
sudo chmod a+w Cargo.toml

# デバッグ実行の標準入力（launch.json）とグラフ可視化で使う。gitignore 対象
echo make input.txt
touch input.txt

# install cargo tools
echo install cargo tools
cargo install cargo-compete
cargo install cargo-member

# compete.toml はリポジトリで管理しているため、無いときだけ生成する（上書き防止）
if [ ! -f "compete.toml" ]; then
    echo init cargo-compete
    cargo compete i atcoder
fi

rustup component add rustfmt
rustup component add clippy

# グラフ可視化（scripts/visualize.py）用
echo install graphviz
sudo apt-get update
sudo apt-get install -y graphviz

# ユーザー名とパスワードの入力が必要なため CI では行わない
# 失敗してもセットアップは続行する（後からタスクランナーの "login" でもログインできる）
if [ -z "$CI" ]; then
    echo login to atcoder
    cargo compete l atcoder || echo "login failed: run the \"login\" task later"
fi

# install rustup tools
echo install rust-toolchain
echo "1.89.0" > rust-toolchain
cargo -V

# install online-judge-tools for generater
# pip3 install online-judge-template-generator


# rustup install 1.89.0
# rustup install 1.89.0-x86_64-unknown-linux-gnu

# The installation of fish is your choice.
# echo install fish and fisher
# sudo apt-add-repository ppa:fish-shell/release-3
# sudo apt-get update
# sudo apt-get install fish
# curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher