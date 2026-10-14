# VS Code タスクで実現している機能

`.vscode/tasks.json` のタスクが何をしているかをまとめたもの。cargo-compete から別のツールへ乗り換えるときに、同じ機能を再現するためのチェックリストとして使う。

## タスク一覧

| タスク名 | 呼び出すもの | 開いているファイルを使うか | cargo-compete への依存 |
|---|---|---|---|
| build | `scripts/build.py ${file}` | 使う | なし |
| build & test | `scripts/test.py ${file}` | 使う | `cargo compete t` |
| build & test release | `scripts/test_release.py ${file}` | 使う | `cargo compete t --release` |
| submit | `scripts/sub.py ${file}` | 使う | `cargo compete s` |
| visualize graph | `scripts/visualize.py input.txt` | 使わない | なし |
| visualize graph (directed) | `scripts/visualize.py input.txt --directed` | 使わない | なし |
| new contest | `cargo compete new` → `cargo member include` | 使わない（コンテスト ID を入力する） | `cargo compete new` |
| login | `cargo compete login atcoder` | 使わない | `cargo compete login` |

## 共通処理（`scripts/common.py`）

build、test、submit の各スクリプトは、最初に次の処理を行う。

1. **パスの解析**（`get_contest_id`）
   - `/workspaces/atcoder_rust/abc325/src/bin/a.rs` を `/` で分割する。
   - 3 番目の要素 `abc325` の先頭 3 文字を `contest_name`（`abc`）、残りを `contest_id`（`325`）とする。
   - 6 番目の要素 `a.rs` の **1 文字目だけ** を `problem_id`（`a`）とする。
   - そのため、ワークスペースのパスは `/workspaces/atcoder_rust` 固定。コンテスト名は 3 文字の接頭辞、問題名は 1 文字であることが前提。
2. **bin ディレクトリへ移動**（`move_to_bin_dir`）
   - `/workspaces/atcoder_rust/<contest>/src/bin` に移動する。cargo-compete が、カレントディレクトリからパッケージを判定するため。
3. **launch.json の書き換え**（`change_launch` → `scripts/change_launch.bash`）
   - `.vscode/launch.json` を丸ごと上書きする。
   - LLDB の `program` を `target/debug/<contest>-<problem>` に向ける。
   - 標準入力（`stdio`）を `input.txt` に向ける。
   - これで F5 を押すと、`input.txt` を入力として今の問題をデバッグできる。
4. **ビルド**（`build`）
   - `cargo build --bin <contest>-<problem>` で、開いている問題だけを debug ビルドする。
   - 成果物は、`.cargo/config.toml` の設定により、リポジトリ直下の `target/` に置かれる。

## 各タスクの詳細

### build

共通処理の 1〜4 を行う。テストはしない。debug ビルドの成果物と `launch.json` が更新される。

### build & test

共通処理の 1〜4 のあと、`cargo compete t <problem>` を実行する。

- サンプルは `<contest>/testcases/<problem>.yml` から読む。この場所は `compete.toml` の `test-suite` で決まる。
- テストに使うツールチェーンは、`compete.toml` の `[test] toolchain = "1.89.0"` で決まる。

### build & test release

共通処理の 1〜4 のあと、`cargo compete t <problem> --release` を実行する。

- 共通処理のビルドは debug なので、テストの前にもう一度 release ビルドが走る。
- `launch.json` が指すのは debug のバイナリのまま。

### submit

共通処理の 1・2 だけを行い、`cargo compete s <problem>` を実行する。ビルドとテストはしない。

- 提出するのはソースファイルそのもの（`compete.toml` の `[submit] kind = "file"`）。
- 言語 ID は `language_id = "6088"`（Rust 1.89.0）。
- AtCoder の Cloudflare Turnstile が原因で、ログインできず失敗する場合がある。

### visualize graph / visualize graph (directed)

`input.txt` を読み、Graphviz で `graph.png` を出力する。cargo-compete とは関係がないので、乗り換えても影響を受けない。

- 1 行目が `N` なら木（辺は N-1 本）、`N M` なら辺が M 本のグラフとして読む。
- 辺の行の 3 列目は重みとして、ラベルに表示する。
- 頂点番号は 1 始まり（`--zero-indexed` を付けると 0 始まり）。
- `dot` コマンドが必要。`postCreateCommand.bash` で apt から入れている。

### new contest

コンテスト ID（例：`abc325`）を入力すると、次の 2 つを順に実行する。

1. `cargo compete new <contest>`：パッケージ `<contest>/` を生成し、サンプルを `testcases/` にダウンロードする。
   - 解答ファイルは、`compete.toml` の `[template]` から作られる。中身は `proconio` と `#[fastout]` を使った雛形。
   - `Cargo.toml` には、`[template.new]` の edition（2024）と、AtCoder の環境に合わせてバージョンを固定した依存クレートが書き込まれる。
2. `cargo member include <contest>`：ルートの `Cargo.toml` のワークスペースに、生成したパッケージを追加する。

### login

`cargo compete login atcoder` を実行する。Turnstile の導入後は、ほぼ失敗する。その場合は、ブラウザから `REVEL_SESSION` の Cookie をコピーし、`~/.local/share/cargo-compete/cookies.jsonl` の同じ項目を差し替える。

## 乗り換えるときのチェックリスト

新しいツールで、次の機能がそれぞれ満たせるかを確認する。

- [ ] コンテスト ID を指定して、問題ごとの解答ファイルを生成できる
- [ ] サンプルの入出力をダウンロードできる
- [ ] 解答の雛形（`proconio` と `#[fastout]`）を設定できる
- [ ] 依存クレートのバージョンと edition を、AtCoder の環境に合わせて固定できる
- [ ] ルートの Cargo ワークスペースと `target/` を共有できる（ビルドの成果物を全コンテストで使い回せる）
- [ ] bin の名前が `<contest>-<problem>` 形式になる。違う場合は、`change_launch.bash` と `common.py` の `build` を直す
- [ ] 特定の問題のサンプルテストを、debug と release の両方で実行できる
- [ ] テスト用のツールチェーンを固定できる
- [ ] ログインに Cookie を使える（Turnstile 対策）
- [ ] 提出できる。できない場合は、ブラウザで提出する運用にする

ツールに依存しない部分（パスの解析、`launch.json` の書き換え、`cargo build --bin`、グラフの可視化）は、そのまま流用できる。差し替えが必要なのは、次の 4 か所だけ。

- `scripts/test.py`：`cargo compete t`
- `scripts/test_release.py`：`cargo compete t --release`
- `scripts/sub.py`：`cargo compete s`
- `tasks.json` の new contest タスクと login タスク
