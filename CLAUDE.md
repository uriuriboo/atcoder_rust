# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## このリポジトリについて

[cargo-compete](https://github.com/qryxip/cargo-compete) と `cargo-member` を使って AtCoder の問題を Rust で解くための VS Code devcontainer 環境。アプリケーションではなくテンプレート兼作業場所であり、コンテストの解答ディレクトリ（`abc*`、`arc*`、`agc*`）、ルートの `Cargo.toml`、`Cargo.lock`、`target/`、`input.txt` はすべて gitignore 対象でローカルで生成される。

すべて devcontainer 内（リポジトリが `/workspaces/atcoder_rust` にマウントされた状態）で動かす前提。スクリプトはこのパスをハードコードしているため、Windows ホスト側のチェックアウトからはそのままでは動かない。

## セットアップ（devcontainer）

devcontainer は `.devcontainer/Dockerfile` からビルドし、cargo-compete、cargo-member、rustfmt、clippy、graphviz、mold をイメージに入れる。`target/` は名前付きボリュームにマウントする（Windows ホストの bind mount が遅いため）。高速化のための設定とその理由は `docs/build_performance.md` にまとめてあり、環境を変えるときもこの要件を満たすようにする。

`.devcontainer/postCreateCommand.bash` は、ルート `Cargo.toml` が空か無いときに `[workspace]` と `resolver = "3"` だけを書き込み（cargo-member がワークスペースのメンバーを書き込むため。resolver を書かないと edition 2024 でも resolver "1" になり警告が出る）、空の `input.txt` を作成し、ボリュームの `target/` の所有者を変え、ツールが未インストールのとき（CI など Dockerfile を使わない環境）だけ graphviz・mold・`cargo-compete`・`cargo-member` をインストールし、rustfmt と clippy を追加し、`rust-toolchain` = `1.89.0` でツールチェーンを固定して、1.89.0 にも rustfmt と clippy を入れる（最小構成でインストールされる環境では stable にしか付かないため）。cargo-compete は固定したツールチェーンではなく最新の stable でビルドするため、`rust-toolchain` を書き込む**前に** cargo-compete をインストールする。`compete.toml` が無いときだけ `cargo compete init atcoder` を実行する（管理している設定の上書き防止）。CI 以外では `cargo compete login atcoder` も実行するが、失敗してもセットアップは止めず、後からタスク "login" でログインし直せる。

## よく使うコマンド

```bash
# 新しいコンテストを開始：パッケージを生成し、edition を 2024 に直し、ルートのワークスペースに追加
# （cargo-compete は compete.toml の edition に "2024" を書くと読み込みに失敗するため、"2021" で生成して書き換える）
cargo compete new abc325
sed -i 's/^edition = "2021"$/edition = "2024"/' abc325/Cargo.toml
cargo member include abc325

# 1問をビルドしてサンプルでテスト（<contest>/src/bin/ で実行）
cargo build --bin abc325-a
cargo compete test a            # リリースモードでテストするなら --release を付ける

# 提出
cargo compete submit a

# ショートカット（コンテストの接頭辞は "abc" にハードコード。arc/agc の場合は書き換える）
./scripts/build_test.bash 325 a   # ビルド + テスト
./scripts/submit.bash 325 a       # 提出
```

普段の操作は拡張機能 Task Explorer（`spmeesseman.vscode-taskexplorer`）のパネルからタスク（`.vscode/tasks.json`）を実行する前提。`.vscode/settings.json` でクリック時の動作を `Execute` にし（既定の `Open` だと tasks.json が開いてアクティブになり、`${file}` が tasks.json になる）、tasks.json のタスクだけを表示するようにしている。タスクが呼ぶスクリプトは、コマンドライン用のスクリプトも含めてすべて `scripts/` にまとめてある。`scripts/test.bash` は online-judge-tools（`oj`）でテストするための、手動実行用のスクリプト。cargo-compete の流れとは別物。`oj` はセットアップで pipx から `/usr/local/bin` に入れる（Debian では pip で直接入れられないため）。

ランダムテスト：タスク "stress: init"・"stress: hack"・"stress: test" が `scripts/stress.py` を呼ぶ。`<contest>/stress/<problem>/` に入力生成の `gen.py` と愚直解の `naive.py` を置き、`oj generate-input --hack-actual/--hack-expected` で解答と愚直解の出力が食い違う反例を探す。反例は同じディレクトリの `test/hack-XXX.{in,out}` に保存し、`input.txt` にもコピーする。gen.py・naive.py を開いた状態でも問題を判定できるよう、パスの 4 番目の要素が `stress` のときは 5 番目を問題とみなす。

VS Code のタスク（`.vscode/tasks.json` の "build"、"build & test"、"build & test release"、"submit"、"new contest"）は、開いているファイルを引数にして `scripts/build.py`、`scripts/test.py`、`scripts/test_release.py`、`scripts/sub.py` を呼び出す。ビルドは `--bin` で開いている問題だけを対象にする。共通の処理（パスの解析、bin ディレクトリへの移動、`launch.json` の書き換え、`--bin` 指定のビルド）は `scripts/common.py` にまとめてある。これらのスクリプトはファイルパス `/workspaces/atcoder_rust/<abc325>/src/bin/<a>.rs` からコンテストと問題を取り出す（パスの 3 番目の要素がコンテスト、6 番目が問題）。コンテスト名は 3 文字の接頭辞を持つ前提。

## 主な構成

- `compete.toml` は cargo-compete の設定。解答テンプレート（`proconio` と `#[fastout]`）、AtCoder の 2025 年 10 月の言語環境（Rust 1.89.0）に合わせて固定した依存クレート群（edition は cargo-compete の制約で `2021` と書き、生成後に 2024 へ書き換える）、テスト用ツールチェーン `1.89.0`、提出用の `language_id = "6088"` を定義している。AtCoder の環境が更新されたら、[公式の言語一覧](https://img.atcoder.jp/file/language-update/2025-10/language-list.html) に合わせて、これらと `.devcontainer/postCreateCommand.bash`・CI のバージョンをまとめて更新する。
- バイナリの命名：コンテスト `abc325` の問題 `a` は、ファイル `abc325/src/bin/a.rs`、bin ターゲット `abc325-a`、実行ファイル `target/debug/abc325-a` になる。サンプルテストは `abc325/testcases/a.yml` に置かれる。
- `.cargo/config.toml` により、全コンテストでリポジトリ直下の `target/` を共有し、リンカに mold を使う。`target/` は devcontainer.json の `mounts` で名前付きボリュームになっている（Windows の bind mount の I/O が遅いため）。rust-analyzer は `.vscode/settings.json` で別の target ディレクトリを使い、タスクの `cargo build` とロックを取り合わない。
- Python（ランダムテストの gen.py・naive.py）用に、devcontainer.json で拡張機能 `ms-python.python`（Pylance・debugpy を含む）と `charliermarsh.ruff` を入れ、`.vscode/settings.json` で保存時に Ruff でフォーマットする。Python 自体は Dockerfile の pipx の依存で入る。
- devcontainer はイメージのビルドに `.devcontainer/Dockerfile` を使う（graphviz・mold・cargo-compete・cargo-member をイメージにキャッシュ）。`postCreateCommand.bash` はリポジトリに依存する処理を行い、ツールが無い環境（CI）でだけインストールする。
- "build & test release" タスクは debug ビルドをせず、`cargo compete t --release` の release ビルドだけを行う。
- `docs/guide.md`（英語版は `docs/guide_en.md`）に利用者向けの使い方ガイド（できること・便利な点・コンテストの流れ・困ったとき）がある。タスクや機能を変えたら両方を合わせて更新する。
- `docs/tasks.md` に VS Code のタスクの詳細とツールを乗り換えるときのチェックリスト、`docs/build_performance.md` にビルド高速化の要件がある。環境やツールを変えるときはこれらの要件を満たすようにする。
- デバッグ：`scripts/change_launch.bash` が `.vscode/launch.json` を書き換え、LLDB の `program` を現在の問題のバイナリに、標準入力を `input.txt` に向ける。"build & test" タスクではこれが自動で行われる。コマンドラインからビルドした場合は `launch.json` を手動で書き換える。Python 用の設定 "Debug Python" も書き出し、`scripts/debug_python.py` が `input.txt` をファイル記述子 0 に付け替えてから開いている `.py`（`${file}`）を実行する（debugpy には標準入力を切り替える設定が無いため）。`launch.json` に設定を足すときは `change_launch.bash` にも足す（丸ごと上書きされるため）。
- グラフ可視化：`scripts/visualize.py` が `input.txt` を読み、Graphviz で `graph.png` を出力する（タスク "visualize graph" / "visualize graph (directed)"）。1行目が `N` なら木、`N M` なら M 本の辺として自動判定し、3列目は重みとして扱う。標準ライブラリのみで、`dot` コマンドは Dockerfile（CI では `postCreateCommand.bash`）で apt から入れる。
- `library/src/*.rs` は単体のスニペット集（ダイクストラ、BFS/DFS、エラトステネスの篩、二部グラフ判定など）で、それぞれコピペ用に `main` を含む完全なプログラムとして書かれている。`library/src/lib.rs` に組み込まれたモジュールでは**ない**。エディタ用スニペット（`tmplt`、`rep`、`bins` など）は `.vscode/rust.code-snippets` にある。

## CI

`.github/workflows/check_environment.yml` は `postCreateCommand.bash` を実行し、`abc325` を生成して `.github/ciabc325a.rs` を `a.rs` としてコピーし、ビルドとテストを行い（失敗しても続行）、最後に `cargo fmt` を実行する。ドキュメント（`*.md`・`docs/`・`img/`・`LICENCE`）だけを変更した push では動かない（`paths-ignore`）。`actions-rust-lang/setup-rust-toolchain` は `override: false` にしている（デフォルトの `rustup override` は `rust-toolchain` より優先され、CI の cargo が stable のままになるため）。
