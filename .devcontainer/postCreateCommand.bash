#!/bin/bash

echo give permission to bashfiles
chmod a+x scripts/*.bash


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

# uv（下の oj と Python 3.15 を入れる）。devcontainer では Dockerfile でインストール済み
# 公式のインストーラーで入れる（バージョンは Dockerfile と合わせる）
if ! command -v uv > /dev/null; then
    echo install uv
    curl -LsSf https://astral.sh/uv/0.13.1/install.sh | sudo env UV_INSTALL_DIR=/usr/local/bin UV_NO_MODIFY_PATH=1 sh
fi

# ランダムテスト（scripts/stress.py）用の online-judge-tools（oj）
# devcontainer では Dockerfile でインストール済み。uv のツールとして入れ、全ユーザーから使えるよう /usr/local/bin に置く
# 依存する lxml などのビルド済みパッケージがあるよう、Python は 3.13 を使う（無ければ uv が入れる）
# oj は distutils を使うため、setuptools を一緒に入れる（Python 3.12 以降は distutils が無く、oj が起動しない）
if ! command -v oj > /dev/null; then
    echo install online-judge-tools
    sudo env UV_TOOL_DIR=/opt/uv/tools UV_TOOL_BIN_DIR=/usr/local/bin UV_PYTHON_INSTALL_DIR=/opt/uv/python "$(command -v uv)" tool install --python 3.13 --with setuptools online-judge-tools
fi

# ランダムテストの gen.py・naive.py を動かす新しい Python。システムの python3（Debian の 3.13）とは別に uv で入れ、
# 全ユーザーから使えるよう /usr/local/bin/python3.15 に置く。devcontainer では Dockerfile でインストール済み
if ! command -v python3.15 > /dev/null; then
    echo install python3.15
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
# 失敗してもセットアップは続行する（後からタスク "login" でもログインできる）
if [ -z "$CI" ]; then
    echo login to atcoder
    cargo compete l atcoder || echo "login failed: run the \"login\" task later"
fi

# install rustup tools
# 拡張子なしの rust-toolchain は古い形式なので、rust-toolchain.toml に書く
echo install rust-toolchain
printf '[toolchain]\nchannel = "1.89.0"\ncomponents = ["rustfmt", "clippy"]\n' > rust-toolchain.toml
# 上の rustfmt と clippy は stable にしか入らない。最小構成でインストールされる環境（CI など）では
# 1.89.0 に付かず、cargo fmt や clippy が動かないため、固定したツールチェーンにも明示的に入れる
rustup toolchain install 1.89.0 --component rustfmt --component clippy
cargo -V