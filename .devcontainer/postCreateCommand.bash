#!/bin/bash

echo give permission to bashfiles
chmod a+x scripts/*.bash


# 先にrust-toolchainをインストールするとcargo-competeがコンパイルできなかった2024/4/19
if [ -f "rust-toolchain" ]; then
    rm rust-toolchain
fi

# cargo-memberで書き込むため
# resolver を書かないと、edition 2024 のメンバーがあっても古い resolver "1" になり警告が出る
echo make Cargo.toml
if [ ! -s Cargo.toml ]; then
    printf '[workspace]\nresolver = "3"\n' > Cargo.toml
fi
sudo chmod a+w Cargo.toml

# デバッグ実行の標準入力（launch.json）とグラフ可視化で使う。gitignore 対象
echo make input.txt
touch input.txt

# target/ は名前付きボリューム（devcontainer.json の mounts）で root 所有で作られるため、所有者を変える
if [ -d target ] && [ "$(stat -c %u target)" != "$(id -u)" ]; then
    echo change owner of target
    sudo chown -R "$(id -u):$(id -g)" target
fi

# グラフ可視化（scripts/visualize.py）用の graphviz と、リンカ（.cargo/config.toml）用の mold
# devcontainer では Dockerfile でインストール済み。mold はビルドより前に必要
if ! command -v dot > /dev/null || ! command -v mold > /dev/null; then
    echo install graphviz and mold
    sudo apt-get update
    sudo apt-get install -y graphviz mold
fi

# ランダムテスト（scripts/stress.py）用の online-judge-tools（oj）
# devcontainer では Dockerfile でインストール済み。Debian では pip で直接入れられない（PEP 668）ため pipx を使い、
# 全ユーザーから使えるよう /usr/local/bin に置く
# GitHub のランナーは /etc/environment で PIPX_BIN_DIR を設定しており、`sudo VAR=...` では上書きされるため env を挟む
if ! command -v oj > /dev/null; then
    echo install online-judge-tools
    command -v pipx > /dev/null || { sudo apt-get update; sudo apt-get install -y pipx; }
    sudo env PIPX_HOME=/opt/pipx PIPX_BIN_DIR=/usr/local/bin pipx install online-judge-tools
fi

# ランダムテストの gen.py・naive.py を動かす新しい Python。システムの python3（Debian の 3.13）とは別に uv で入れ、
# 全ユーザーから使えるよう /usr/local/bin/python3.15 に置く。devcontainer では Dockerfile でインストール済み
if ! command -v python3.15 > /dev/null; then
    echo install python3.15
    command -v uv > /dev/null || sudo env PIPX_HOME=/opt/pipx PIPX_BIN_DIR=/usr/local/bin pipx install uv
    sudo env UV_PYTHON_INSTALL_DIR=/opt/uv/python UV_PYTHON_BIN_DIR=/usr/local/bin "$(command -v uv)" python install 3.15
fi

# install cargo tools
# devcontainer では Dockerfile でインストール済み。CI など未インストールの環境でだけビルドする
echo install cargo tools
command -v cargo-compete > /dev/null || cargo install cargo-compete
command -v cargo-member > /dev/null || cargo install cargo-member

# compete.toml はリポジトリで管理しているため、無いときだけ生成する（上書き防止）
if [ ! -f "compete.toml" ]; then
    echo init cargo-compete
    cargo compete i atcoder
fi

rustup component add rustfmt
rustup component add clippy

# ユーザー名とパスワードの入力が必要なため CI では行わない
# 失敗してもセットアップは続行する（後からタスクランナーの "login" でもログインできる）
if [ -z "$CI" ]; then
    echo login to atcoder
    cargo compete l atcoder || echo "login failed: run the \"login\" task later"
fi

# install rustup tools
echo install rust-toolchain
echo "1.89.0" > rust-toolchain
# 上の rustfmt と clippy は stable にしか入らない。最小構成でインストールされる環境（CI など）では
# 1.89.0 に付かず、cargo fmt や clippy が動かないため、固定したツールチェーンにも明示的に入れる
rustup toolchain install 1.89.0 --component rustfmt --component clippy
cargo -V

# rustup install 1.89.0
# rustup install 1.89.0-x86_64-unknown-linux-gnu

# The installation of fish is your choice.
# echo install fish and fisher
# sudo apt-add-repository ppa:fish-shell/release-3
# sudo apt-get update
# sudo apt-get install fish
# curl -sL https://git.io/fisher | source && fisher install jorgebucaran/fisher