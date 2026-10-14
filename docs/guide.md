# 使い方ガイド

この環境で何ができるのか、何が便利なのか、コンテストで実際にどう使うのかをまとめたもの。内部の仕組みは [tasks.md](tasks.md)（タスク）と [build_performance.md](build_performance.md)（ビルド高速化）を参照。

[English version](guide_en.md)

## この環境でできること

VS Code で Dev Container として開くだけで、AtCoder の提出環境と同じ Rust の開発環境ができる。問題の取得からテスト・デバッグ・提出まで、エディタから離れずにクリックだけで進められる。

| やりたいこと | 使う機能 |
| --- | --- |
| コンテストの問題とサンプルを取ってくる | タスク「new contest」 |
| 解いている問題をサンプルでテストする | タスク「build & test」 |
| 実行時間を確かめる | タスク「build & test release」 |
| 提出する | タスク「submit」 |
| 自分の入力でステップ実行する | `input.txt` に入力を書いて F5 |
| サンプルは通るのに WA の原因を探す | タスク「stress: init / hack / test」 |
| グラフの入力を図で見る | タスク「visualize graph」 |
| よく書くコードをすぐ書く | スニペット（`tmplt`、`rep` など）と `library/` |

## 何が便利なのか

### 環境構築がいらない

- Rust のバージョン（1.89.0、edition 2024）と、使えるクレート（proconio、ac-library-rs、itertools など約 65 個）のバージョンが、AtCoder の 2025 年 10 月の言語環境と同じに固定されている。手元で通ったのに AtCoder ではコンパイルエラー、ということが起きにくい。
- cargo-compete、clippy、rustfmt、online-judge-tools、Graphviz などの道具は、コンテナを作るときに全部入る。

### 開いているファイルから問題を判定する

- タスクはどれも、エディタで開いているファイルの場所（`abc325/src/bin/a.rs` など）から、コンテストと問題を自動で判定する。コンテスト名や問題名を毎回入力する必要がない。
- ストレステスト用の `gen.py`・`naive.py` を開いているときも、同じ問題として扱われる。

### 解いている問題だけをビルドする

- ビルドするのは開いている問題だけ。B 問題が書きかけでコンパイルできなくても、A 問題のテストができる。
- サンプルは CPU のコア数だけ並列にテストされる。

### すぐにデバッグできる

- 「build」や「build & test」を実行すると、デバッガの設定（`.vscode/launch.json`）が今の問題に書き換わる。
- `input.txt` に入力を貼って F5 を押すだけで、ブレークポイントを置いてステップ実行できる。デバッガの設定を自分で触る必要はない。

### 反例を自動で探せる

- サンプルは通るのに WA になるとき、ランダムな入力で自分の解答と愚直解を比べて、答えが食い違う入力を自動で探せる。
- 見つかった反例は `input.txt` に入るので、そのまま F5 でデバッグできる。

### ビルドが速い

- リンカに mold を使い、ビルド成果物を Docker ボリュームに置いているので、Windows でもビルドが速い。
- エディタのチェック（rust-analyzer + clippy）は、開いているコンテストだけが対象。コンテストを重ねても遅くならない。
- ツールは Docker イメージに入っているので、コンテナの作り直しも速い。

### エディタの補助

- 保存時に自動でフォーマットされ、clippy の警告がエディタに出る。
- ランダムテストで書く Python（`gen.py`・`naive.py`）も、補完（Pylance）が効き、Ruff のチェックと保存時の自動フォーマットがかかる。デバッグの設定で「Debug Python」を選べば、`input.txt` を入力にして F5 でデバッグできる（[stress_test.md](stress_test.md) の「4. デバッグする」）。

## はじめかた

### 必要なもの

- Docker（Windows・Mac は Docker Desktop）
- VS Code と拡張機能「Dev Containers」
- AtCoder のアカウント（提出するときだけ）

### 初回のセットアップ

1. このリポジトリを **`atcoder_rust` というフォルダ名のまま** clone する。スクリプトがコンテナ内のパス `/workspaces/atcoder_rust` を前提にしているため、フォルダ名を変えると動かない。
2. VS Code でフォルダを開き、右下に出る「コンテナーで再度開く」（Reopen in Container）を選ぶ。出ない場合は `Ctrl+Shift+P` →「Dev Containers: Reopen in Container」。
3. 初回はイメージのビルドに数分かかる。終わると、ターミナルで AtCoder のユーザー名とパスワードを聞かれるので入力する。
   - ログインに失敗しても、セットアップはそのまま進む。後でタスク「login」からやり直せる（[ログインできないとき](#ログインできないとき) も参照）。

## タスクの実行のしかた

この環境の操作は、ほぼすべて VS Code のタスクで行う。実行のしかたは 2 通り。

- **クリック**：エクスプローラーの下のほうにある **Task Explorer** パネルで、`atcoder_rust` → `vscode` を開き、タスク名をクリックする。
- **コマンドパレット**：`Ctrl+Shift+P` →「タスク: タスクの実行」（Tasks: Run Task）→ タスクを選ぶ。

Task Explorer には、ほかにも次の機能がある。

- **お気に入り**：タスクにマウスを乗せて星のボタンを押すと、一番上の「Favorites」に入る。「build & test」と「submit」を入れておくと、探さずに押せる。
- **最後のタスクをもう一度実行**：`Alt+R` → `T` で、最後に実行したタスクをもう一度実行する。開いているファイルは実行するたびに読み直すので、別の問題のファイルに切り替えてから押してもよい。最近実行したタスクは「Last Tasks」にも並ぶ。

「new contest」「visualize graph」「login」以外のタスクは、**解いている問題の `.rs` ファイルをエディタで開いてアクティブにした状態**で実行する。

## コンテストの流れ

ABC325 の A 問題を例にする。

### 1. コンテストを始める

タスク「new contest」を実行し、コンテスト ID（`abc325`）を入力する。次のものが作られる。

```text
abc325/
├── Cargo.toml
├── src/bin/
│   ├── a.rs        解答ファイル（テンプレート入り）
│   ├── b.rs
│   └── ...
└── testcases/
    ├── a.yml       サンプルの入出力
    └── ...
```

コンテストが始まる前は問題が公開されていないので、開始してから実行する。

### 2. 解く

`abc325/src/bin/a.rs` を開いて書く。最初から次のテンプレートが入っている。

```rust
#[allow(unused_imports)]
use proconio::{marker::*, *};
#[allow(unused_imports)]
use std::{cmp::*, collections::*, *};

#[fastout]
fn main(){
    todo!();
}
```

入力は proconio の `input!` マクロで読む。スニペット `tmplt` を使うと、`input!` やよく使う `use` まで入ったテンプレートに置き換えられる。

### 3. サンプルでテストする

`a.rs` を開いたまま、タスク「build & test」を実行する。ターミナルに各サンプルの結果（AC / WA など）が出る。

- 実行時間が気になるときは「build & test release」を使う。最適化ありでビルドするので、AtCoder での実行時間に近くなる。
- コンパイルが通るかだけ確かめたいときは「build」。

### 4. デバッグする

1. 「build」か「build & test」を実行する（デバッガの設定が今の問題に切り替わる）。
2. ルートの `input.txt` に、試したい入力を貼る。
3. ブレークポイントを置いて F5 を押す。

「build & test release」は debug ビルドをしないので、デバッグの前には「build」か「build & test」を使う。

### 5. 提出する

`a.rs` を開いたまま、タスク「submit」を実行する。提出の前にサンプルテストが自動で走り、通らなければ提出されない。

結果は AtCoder の提出一覧で確認する。

### 6. WA の原因が分からないとき

サンプルは通るのに WA になるときは、ランダムテストで反例を探す。

1. 「stress: init」で、入力生成の `gen.py` と愚直解の `naive.py` の雛形を作る（`abc325/stress/a/` にできる）。
2. 2 つのファイルを問題に合わせて Python で書く。
3. 「stress: hack」で反例を探す。見つかると `input.txt` に入るので、F5 でデバッグする。
4. 直したら「stress: test」で、これまでに見つけた反例がすべて通るか確かめる。

詳しい書き方とコツは [stress_test.md](stress_test.md) を参照。

## そのほかの機能

### グラフの可視化

木やグラフの問題で、入力を図にして確かめられる。

1. `input.txt` に問題の入力を貼る。
2. タスク「visualize graph」（有向グラフなら「visualize graph (directed)」）を実行する。
3. `graph.png` が作られ、エディタで開く。

入力の形式は自動で判定する。

| 1 行目 | 読み方 |
| --- | --- |
| `N` | 木として、続く N-1 行を辺として読む |
| `N M` | 続く M 行を辺として読む |

- 辺の行が `u v w` のように 3 列あれば、`w` を重みとして辺のラベルに表示する。
- 頂点番号は 1 始まりとして扱う。辺より後ろの行（クエリなど）は無視する。

### スニペット

`.rs` ファイルで次のキーワードを入力し、候補から選ぶと展開される。

| キーワード | 展開される内容 |
| --- | --- |
| `tmplt` | `input!` やよく使う `use` を含むテンプレート全体 |
| `rep` | `for i in 0..n { }` |
| `rrep` | 二重ループ |
| `pbit` | bit 全探索 |
| `bins` | めぐる式二分探索 |
| `oans` | `println!("{}",ans);` |
| `oY` / `oN` | `Yes` / `No` の出力 |

スニペットは `.vscode/rust.code-snippets` で追加・変更できる。

### ライブラリ

`library/src/` に、コピーして使うためのコードがある。どれも `main` を含む完全なプログラムなので、必要な部分を解答ファイルに貼って使う。

| ファイル | 内容 |
| --- | --- |
| `dijkstra.rs` | ダイクストラ法 |
| `bsf.rs` | 幅優先探索（BFS） |
| `dfs_tmp.rs` | 深さ優先探索（DFS） |
| `bipartite_graph.rs`、`binary_graph.rs` | 二部グラフの判定・塗り分け |
| `eratosthenes.rs` | エラトステネスの篩 |
| `is_kaibun.rs` | 回文の判定 |

### コマンドラインから使う

タスクを使わずに、コンテナ内のターミナルから操作することもできる。

```bash
# コンテストを始める
cargo compete new abc325
sed -i 's/^edition = "2021"$/edition = "2024"/' abc325/Cargo.toml  # AtCoder と同じ edition 2024 にする
cargo member include abc325

# ビルドとテスト（コンテストの番号と問題を指定）
./scripts/build_test.bash 325 a

# 提出
./scripts/submit.bash 325 a
```

- `build_test.bash` と `submit.bash` はコンテストの接頭辞が `abc` 固定。ARC・AGC で使うときは書き換える（タスクは ARC・AGC でもそのまま動く）。
- コマンドラインからビルドした場合、`launch.json` は書き換わらない。デバッグするときは、タスク「build」を一度実行するか、`launch.json` の `program` を手で直す。

## 困ったとき

### ログインできないとき

AtCoder のログイン画面に CAPTCHA（Cloudflare Turnstile）が入ったため、「login」タスクや提出が失敗することがある。その場合は、ブラウザのログイン情報（Cookie）を使う。

1. ブラウザで AtCoder にログインする。
2. 開発者ツールで、atcoder.jp の Cookie `REVEL_SESSION` の値をコピーする。
3. コンテナ内の `~/.local/share/cargo-compete/cookies.jsonl` を開き、`REVEL_SESSION` の値を貼り替える。

それでも提出できないときは、ブラウザから提出する。

### タスクが「list index out of range」などで失敗する

- 解いている問題の `.rs` ファイルがアクティブになっているか確かめる。ターミナルや `input.txt` がアクティブなままだと、問題を判定できない。
- コンテナ内のパスが `/workspaces/atcoder_rust/...` になっているか確かめる。リポジトリのフォルダ名を変えていると動かない。

### 問題がビルド対象に見つからない

「new contest」を実行せずに `cargo compete new` だけを実行すると、ワークスペースに登録されない。`cargo member include <contest>` を実行する。

### ディスクの容量を空けたい

ビルド成果物は Docker ボリューム `atcoder-rust-target` に置かれ、コンテナを作り直しても残る。コンテナを止めてから、ホストで `docker volume rm atcoder-rust-target` を実行すると消せる。

## 制限

- コンテスト名は `abc`・`arc`・`agc` のような 3 文字の接頭辞 + 番号を前提にしている。
- 問題名はファイル名の 1 文字目で判定するので、`a.rs`〜`g.rs` のような 1 文字の問題を前提にしている。
- AtCoder の言語環境が更新されたら、`compete.toml` などのバージョンを合わせて更新する必要がある（手順は `CLAUDE.md` の「主な構成」を参照）。
