# ランダムテスト（stress）の使い方

サンプルは通るのに WA になるときに、ランダムな入力で自分の解答と愚直解を比べて、答えが食い違う入力（反例）を探す。

online-judge-tools（`oj`）の `generate-input` を使う。`oj` はコンテナ作成時に入るので、自分でインストールする必要はない。

## 用意するもの

問題ごとに、次の 2 つを Python で書く。Python 3.15 で動くので、新しい文法も使える。エディタでは補完（Pylance）が効き、Ruff のチェックと保存時の自動フォーマットがかかる。

| ファイル | 役割 |
| --- | --- |
| `gen.py` | 入力を 1 ケース分作り、標準出力に書き出す |
| `naive.py` | 愚直解。遅くてよいので、確実に正しい方法で解く |

置き場所は `<contest>/stress/<problem>/`。コンテストのディレクトリごと gitignore 対象なので、コミットされない。

```text
abc325/
├── src/bin/a.rs        解答
└── stress/a/
    ├── gen.py
    ├── naive.py
    └── test/           見つけた反例がたまる
        ├── hack-000.in
        └── hack-000.out
```

## 手順

### タスクの実行のしかた

stress のタスクは、ほかのタスク（build & test など）と同じように実行する。

1. 解きたい問題のファイルをエディタで開き、アクティブにしておく。`a.rs`・`gen.py`・`naive.py` のどれを開いていても、同じ問題として扱われる。
2. `Ctrl+Shift+P` を押し、「タスク: タスクの実行」（Tasks: Run Task）を選ぶ。
3. 一覧から実行したいタスク（stress: init など）を選ぶ。

ステータスバーのボタン（`stress hack` など。ないものは「その他」）からクリックで実行してもよい。

コマンドラインから実行する場合は、devcontainer 内で、モード（`init`・`hack`・`test`）と解答ファイルのパスを渡す。

```bash
python3 scripts/stress.py init /workspaces/atcoder_rust/abc325/src/bin/a.rs
```

### 1. 雛形を作る（stress: init）

`a.rs` を開いて「stress: init」を実行すると、`stress/a/gen.py` と `stress/a/naive.py` の雛形ができる。ターミナルには `created: ...` と表示される。既にあるファイルは上書きせず、`skip (already exists): ...` と表示される。

### 2. gen.py と naive.py を書く

雛形を問題に合わせて書き換える。

例：「N 個の整数 A から異なる 2 つを選んだときの和の最大値」を求める問題。

`gen.py`

```python
import random

N = random.randint(2, 5)
A = [random.randint(-10, 10) for _ in range(N)]
print(N)
print(*A)
```

`naive.py`

```python
N = int(input())
A = list(map(int, input().split()))
print(max(A[i] + A[j] for i in range(N) for j in range(i + 1, N)))
```

### 3. 反例を探す（stress: hack）

「stress: hack」を実行すると、次のことを行う。

1. 解答を debug ビルドする（`launch.json` も書き換わる）。
2. `gen.py` で入力を作り、解答と `naive.py` に与えて出力を比べる。食い違うか、解答が実行時エラーになるまで繰り返す。CPU のコア数だけ並列に回る。
3. 反例を `test/hack-XXX.in` に、`naive.py` の出力を `test/hack-XXX.out` に保存する。
4. 反例を `input.txt` にコピーし、正しい出力をターミナルに表示する。

反例がなかなか見つからないときは、Ctrl+C で止める。

### 4. デバッグする

反例は `input.txt` に入っているので、そのまま F5 でデバッグ実行できる。直したら、もう一度「stress: hack」を実行して、ほかの反例がないか確かめる。

`naive.py` や `gen.py` もデバッグできる。

1. 「実行とデバッグ」（`Ctrl+Shift+D`）の上にある一覧で「Debug Python」を選ぶ。一度選べば次からはそのまま。
2. デバッグしたい `.py` を開いてアクティブにし、ブレークポイントを置いて F5 を押す。
3. 標準入力は `input.txt` から読む（`input()`・`sys.stdin`・`open(0)` のどれでもよい）。

解答（Rust）のデバッグに戻るときは、一覧で「Debug」を選び直す。

### 5. これまでの反例で確認する（stress: test）

「stress: test」は、`test/` にたまった反例をすべて解答に流す。修正で前の反例が再び壊れていないかを確かめるのに使う。

## うまく使うコツ

- **値は小さくする**：N は 1〜10 程度、値も 10 程度にすると、反例を手で追える。小さい範囲でもたいていのバグは見つかる。
- **端のケースを出やすくする**：N の最小値、すべて同じ値、負の数や 0 など、問題文の制約の端が出るように範囲を決める。
- **gen.py が制約を守っているか確かめる**：制約外の入力を作ると、正しい解答でも食い違うことがある。「異なる値」「連結なグラフ」などの条件に注意する。
- **反例をやり直したいとき**：`stress/<problem>/test/` を消す。消さなければ番号が `hack-001`、`hack-002` … と増えていく。

## 使えない場面

- **答えが複数ある問題**：出力をそのまま比べるので、別の正解を出すと食い違いとして扱われる。
- **小数の答え**：誤差を許す比較ができないので、同じ理由で使えない。
- **実行時間（TLE）の確認**：debug ビルドで、時間制限なしで動かしている。大きな入力での速さは「build & test release」などで確かめる。

## 関連

- タスクの内部の動きは [tasks.md](tasks.md) の「stress: init / stress: hack / stress: test」。
- 実装は `scripts/stress.py`。
