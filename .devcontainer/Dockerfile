FROM mcr.microsoft.com/devcontainers/rust:2-1-trixie

# uv は公式の推奨どおり、公式イメージからバイナリをコピーする（バージョンは固定する）
COPY --from=ghcr.io/astral-sh/uv:0.13.1 /uv /uvx /usr/local/bin/

# リポジトリに依存する処理（chmod、Cargo.toml、rust-toolchain.toml）は postCreateCommand.bash で行う
# - python3：scripts/*.py を動かす（ベースイメージの python3-minimal には標準ライブラリの一部しか無い）
# - online-judge-tools（oj）：uv のツールとして入れ、全ユーザーから使えるよう /usr/local/bin に置く。
#   依存する lxml などのビルド済みパッケージがあるよう、Python は Debian の 3.13 を使う。
#   oj は distutils を使うため、setuptools を一緒に入れる（Python 3.12 以降は distutils が無く、oj が起動しない）
RUN apt-get update && \
    apt-get install -y graphviz mold python3 && \
    env UV_TOOL_DIR=/opt/uv/tools UV_TOOL_BIN_DIR=/usr/local/bin uv tool install --python 3.13 --with setuptools online-judge-tools && \
    env UV_PYTHON_INSTALL_DIR=/opt/uv/python UV_PYTHON_BIN_DIR=/usr/local/bin uv python install 3.15 && \
    cargo install cargo-compete && \
    cargo install cargo-member && \
    rustup component add rustfmt && \
    rustup component add clippy
