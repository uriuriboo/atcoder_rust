# VS Code タスクで実現している機能

`.vscode/tasks.json` のタスクが何をしているかをまとめたもの。cargo-compete から別のツールへ乗り換えるときに、同じ機能を再現するためのチェックリストとして使う。

## タスク一覧

| タスク名 | 呼び出すもの | 開いているファイルを使うか | cargo-compete への依存 |
|---|---|---|---|
| build | `scripts/build.py ${file}` | 使う | なし |
| build & test | `scripts/test.py ${file}` | 使う | `cargo compete t` |
| build & test release | `scripts/test_release.py ${file}` | 使う | `cargo compete t --release` |
| submit | `scripts/sub.py ${file}` | 使う | `cargo compete s` |
| stress: init / hack / test | `scripts/stress.py <mode> ${file}` | 使う | なし（`oj` を使う） |
| visualize graph | `scripts/visualize.py input.txt` | 使わない | なし |
| visualize graph (directed) | `scripts/visualize.py input.txt --directed` | 使わない | なし |
| new contest | `cargo compete new` → edition を 2024 に書き換え → `cargo member include` | 使わない（コンテスト ID を入力する） | `cargo compete new` |
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
   - Python（gen.py・naive.py）用の設定「Debug Python」も一緒に書き出す。debugpy には標準入力を切り替える設定が無いため、`scripts/debug_python.py` が `input.txt` をファイル記述子 0 に付け替えてから、開いている `.py`（`${file}`）を実行する。
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

共通処理の 1〜3 のあと、`cargo compete t <problem> --release` を実行する。

- 共通処理の debug ビルド（4）は行わない。`cargo compete t --release` の release ビルドだけを行う（[build_performance.md](build_performance.md) の要件 5）。
- `launch.json` は書き換えるが、debug のバイナリは更新されない。

### submit

共通処理の 1・2 だけを行い、`cargo compete s <problem>` を実行する。ビルドとテストはしない。

- 提出するのはソースファイルそのもの（`compete.toml` の `[submit] kind = "file"`）。
- 言語 ID は `language_id = "6088"`（Rust 1.89.0）。
- AtCoder の Cloudflare Turnstile が原因で、ログインできず失敗する場合がある。

### stress: init / stress: hack / stress: test

サンプル以外のテストケースを、ランダムな入力と愚直解から作る。使い方は [stress_test.md](stress_test.md)。online-judge-tools（`oj`）の `generate-input` と `test` を使う。解答の `a.rs` と、下の `gen.py`・`naive.py` のどれを開いていても実行できる。

ファイルは `<contest>/stress/<problem>/` に置く（コンテストのディレクトリごと gitignore 対象）。

```text
abc325/stress/a/
├── gen.py      入力を 1 ケース分、標準出力に書き出す
├── naive.py    愚直解（遅くてよいので、確実に正しく）
└── test/       見つけた反例（hack-000.in / hack-000.out など）
```

1. **stress: init**：`gen.py` と `naive.py` の雛形を作る。既にあれば上書きしない。問題に合わせて書き換える。
2. **stress: hack**：共通処理の 1〜4 のあと、`oj generate-input --hack-actual <解答> --hack-expected "python3.15 naive.py" "python3.15 gen.py"` を実行する。gen.py・naive.py は、システムの python3（Debian の 3.13）ではなく、Dockerfile で uv から入れた Python 3.15 で動かす。
   - `gen.py` で入力を作り、解答と `naive.py` の出力が食い違うか、解答が RE になるまで繰り返す。止めるときは Ctrl+C。
   - 見つけた反例は `test/hack-XXX.in` と、`naive.py` による正解 `test/hack-XXX.out` に保存される。
   - 反例は `input.txt` にもコピーするので、そのまま F5 でデバッグできる。
3. **stress: test**：共通処理の 1〜4 のあと、`oj test` で `test/` のケースをすべて実行する。直したあとに、これまでの反例で回帰テストするのに使う。

`gen.py` の値は小さくしておくと、反例が見つかったときに手で追いやすい。`oj` は `postCreateCommand.bash`（devcontainer では Dockerfile）で、uv のツールとして（`uv tool install`）入れている。`oj` は distutils を使うため、Python 3.12 以降では setuptools を一緒に入れないと起動しない（`--with setuptools`）。

### visualize graph / visualize graph (directed)

`input.txt` を読み、Graphviz で `graph.png` を出力する。cargo-compete とは関係がないので、乗り換えても影響を受けない。

- 1 行目が `N` なら木（辺は N-1 本）、`N M` なら辺が M 本のグラフとして読む。
- 辺の行の 3 列目は重みとして、ラベルに表示する。
- 頂点番号は 1 始まり（`--zero-indexed` を付けると 0 始まり）。
- `dot` コマンドが必要。`postCreateCommand.bash` で apt から入れている。

### new contest

コンテスト ID（例：`abc325`）を入力すると、次の 3 つを順に実行する。

1. `cargo compete new <contest>`：パッケージ `<contest>/` を生成し、サンプルを `testcases/` にダウンロードする。
   - 解答ファイルは、`compete.toml` の `[template]` から作られる。中身は `proconio` と `#[fastout]` を使った雛形。
   - `Cargo.toml` には、`[template.new]` の edition と、AtCoder の環境に合わせてバージョンを固定した依存クレートが書き込まれる。
2. `sed` で `<contest>/Cargo.toml` の edition を `2021` から `2024` に書き換える。cargo-compete は `compete.toml` の edition に `2024` を書くと読み込みに失敗する（2015/2018/2021 にしか対応していない）ため、`compete.toml` には `2021` を書いておき、生成後に AtCoder と同じ 2024 にする。
3. `cargo member include <contest>`：ルートの `Cargo.toml` のワークスペースに、生成したパッケージを追加する。

この 3 つは、それぞれ別のタスク（`rust: ...`）として定義している。単体では実行しないので、`"hide": true` を付けてステータスバーのボタンと「タスクの実行」の一覧に出さないようにしている。

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
- [ ] [build_performance.md](build_performance.md) の高速化の要件を満たせる（ビルド先を `target/` から変えるツールでは、要件 1 のボリュームのマウント先も変える）

ツールに依存しない部分（パスの解析、`launch.json` の書き換え、`cargo build --bin`、グラフの可視化）は、そのまま流用できる。差し替えが必要なのは、次の 4 か所だけ。

- `scripts/test.py`：`cargo compete t`
- `scripts/test_release.py`：`cargo compete t --release`
- `scripts/sub.py`：`cargo compete s`
- `tasks.json` の new contest タスクと login タスク
