FROM mcr.microsoft.com/devcontainers/rust:1-trixie

# リポジトリに依存する処理（chmod、Cargo.toml、rust-toolchain）は postCreateCommand.bash で行う
RUN sudo apt-get update && \
    sudo apt-get install -y graphviz mold pipx && \
    sudo env PIPX_HOME=/opt/pipx PIPX_BIN_DIR=/usr/local/bin pipx install online-judge-tools && \
    sudo env PIPX_HOME=/opt/pipx PIPX_BIN_DIR=/usr/local/bin pipx install uv && \
    sudo env UV_PYTHON_INSTALL_DIR=/opt/uv/python UV_PYTHON_BIN_DIR=/usr/local/bin uv python install 3.15 && \
    cargo install cargo-compete && \
    cargo install cargo-member && \
    rustup component add rustfmt && \
    rustup component add clippy
