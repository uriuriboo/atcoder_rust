FROM mcr.microsoft.com/devcontainers/rust:1-trixie

# リポジトリに依存する処理（chmod、Cargo.toml、rust-toolchain）は postCreateCommand.bash で行う
RUN sudo apt-get update && \
    sudo apt-get install -y graphviz && \
    cargo install cargo-compete && \
    cargo install cargo-member && \
    rustup component add rustfmt && \
    rustup component add clippy
