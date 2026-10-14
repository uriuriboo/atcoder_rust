# ビルド高速化の要件

ビルドとセットアップを速くするために入れている設定と、その理由をまとめたもの。環境を作り直すときや、ツールを乗り換えるときにも、ここに書いた要件を満たすようにする。

## 要件一覧

| # | 要件 | 実現している場所 |
|---|---|---|
| 1 | ビルドの成果物（`target/`）を Windows ホストの bind mount に置かない | `.devcontainer/devcontainer.json` の `mounts` |
| 2 | リンカに mold を使う | `.cargo/config.toml`、`.devcontainer/Dockerfile` |
| 3 | rust-analyzer のチェックが、ワークスペース全体に広がらない | `.vscode/settings.json` |
| 4 | rust-analyzer とタスクのビルドが、`target/` のロックを取り合わない | `.vscode/settings.json` |
| 5 | release でテストするときに、不要な debug ビルドをしない | `scripts/test_release.py` |
| 6 | コンテナを作るたびに、cargo のツールをソースからビルドし直さない | `.devcontainer/Dockerfile`、`.devcontainer/postCreateCommand.bash` |

## 1. `target/` を名前付きボリュームに置く

**理由**：リポジトリは Windows のファイルシステム上にあり、コンテナから bind mount している。Docker Desktop for Windows では、bind mount のファイル I/O がかなり遅い。Rust のビルドは `target/` に大量の小さなファイルを書くので、特に影響が大きい。

**実現方法**
- `devcontainer.json` の `mounts` で、名前付きボリューム `atcoder-rust-target` を `/workspaces/atcoder_rust/target` にマウントする。
- パスは今までと同じなので、`change_launch.bash` などのスクリプトは変更不要。
- ボリュームは root 所有で作られる。そのため `postCreateCommand.bash` で、所有者が自分でないときだけ `chown` する。

**注意**
- `target/` はホスト側からは見えない（ホスト側には空のディレクトリができるだけ）。
- ボリュームは、コンテナを作り直しても残る。消したいときは `docker volume rm atcoder-rust-target` を実行する。

## 2. リンカに mold を使う

**理由**：Rust 1.89 の Linux では、標準のリンカは GNU ld。依存クレートが約 65 個あるので、問題をビルドするたびにリンクに時間がかかる。

**実現方法**
- `.cargo/config.toml` で、`x86_64-unknown-linux-gnu` 向けに `-C link-arg=-fuse-ld=mold` を指定する。
- mold は Dockerfile で apt からインストールする。CI では `postCreateCommand.bash` がインストールする。

**注意**
- `.cargo/config.toml` はリポジトリ内のすべてのビルドに効くので、mold が無い環境ではリンクに失敗する。mold はビルドより前にインストールしておく。
- 提出するのはソースファイルなので、提出には影響しない。

## 3・4. rust-analyzer の設定

**理由**
- 保存時に clippy でチェックする設定にしているが、そのままだとワークスペース全体がチェック対象になる。コンテストはすべてワークスペースのメンバーなので、コンテストが増えるほど遅くなる。
- rust-analyzer とタスクの `cargo build` が同じ `target/` を使うと、ロックを取り合って待たされる（「Blocking waiting for file lock」）。

**実現方法**（`.vscode/settings.json`）
- `"rust-analyzer.check.workspace": false`：チェック対象を、開いているパッケージだけにする。
- `"rust-analyzer.cargo.targetDir": true`：rust-analyzer 用に別のビルドディレクトリ（`target/rust-analyzer`）を使う。

**注意**：rust-analyzer 用に依存クレートを別にビルドするので、ディスク使用量は約 2 倍になる。

## 5. release テストで debug ビルドをしない

**理由**：以前は、debug でビルドしたあと、`cargo compete t --release` でもう一度 release でビルドしていた。

**実現方法**：`scripts/test_release.py` は `build()` を呼ばず、`cargo compete t --release` の release ビルドだけにする。

**注意**：`launch.json` は書き換えるが、debug のバイナリは更新されない。デバッグするときは、"build" か "build & test" タスクを使う。

## 6. cargo のツールをイメージにキャッシュする

**理由**：`cargo install cargo-compete` と `cargo install cargo-member` は、ソースからビルドするので数分かかる。以前は、コンテナを作るたびに実行していた。

**実現方法**
- `devcontainer.json` は `image` を直接指定せず、`.devcontainer/Dockerfile` からビルドする。
- Dockerfile では、cargo-compete、cargo-member、rustfmt、clippy、graphviz、mold をインストールする。これらはイメージのレイヤーにキャッシュされる。
- `postCreateCommand.bash` では、コマンドが見つからないときだけインストールする。CI は Dockerfile を使わないので、このスクリプトがインストールを行う。

**注意**
- cargo-compete は最新の stable でビルドする必要がある。Dockerfile にはリポジトリの `rust-toolchain` が無いので、stable でビルドされる。
- CI では、`actions-rust-lang/setup-rust-toolchain` のキャッシュ（デフォルトで有効）によって、`~/.cargo` と `target/` がキャッシュされる。
