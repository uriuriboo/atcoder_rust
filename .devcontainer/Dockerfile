FROM mcr.microsoft.com/devcontainers/rust:1-bullseye

RUN echo give permission to bashfiles && \
    chmod a+x bt.bash sub.bash && \
    sudo chmod a+x scripts/bt.bash scripts/sub.bash scripts/change_launch.bash && \
    echo "1.70" > rust-toolchain && \
    cargo -V && \
    cargo install cargo-compete && \
    cargo install cargo-member && \
    cargo compete i atcoder && \
    echo clone ac-library-rs && \
    git clone https://github.com/rust-lang-ja/ac-library-rs.git && \
    rustup component add rustfmt && \
    rustup component add clippy && \
    echo login to atcoder && \
    cargo compete l atcoder &&\