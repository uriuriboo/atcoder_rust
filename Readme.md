# RustのAtCoder用Docker環境です

[cargo-compete](https://github.com/qryxip/cargo-compete)を使用しています
詳しい利用方法は[こちら](https://qiita.com/rokoooouribo/items/76a0057c75694fd943f5)

[Click here for the English Readme](https://github.com/uriuriboo/atcoder_rust/blob/main/Readme_en.md)

## 使い方

### ビルドとテスト

#### コマンドラインからビルドとテスト

```bash:
./bt.bash コンテストの数字 問題のアルファベット
```

#### クリックでビルドとテスト

テストしたい.rsファイルをvscodeで表示した状態で右下のTASKRUNNERのbuild & testをクリック

![Alt text](./img/img.png)

### 提出

#### コマンドラインから提出

```bash:
./sub.bash コンテストの数字 問題のアルファベット
```

#### クリックで提出

上の写真で同様に提出したい.rsファイルをvscodeで表示した状態で右下のTASKRUNNERのsubmitをクリックしてもできます

### デバッグ

input.txtにデバッグの入力を入れてください

コマンドラインでビルドとテストを行った場合はlaunch.jsonのprogramを解いている問題のコンテストの数字に書き換えてください

build & testをクリックしたときに書き換わるように設定しました

## 注意

コマンドラインから操作をしたい場合はlaunch.jsonとbt.bashとsub.bashはabc、arc、agcごとに書き換えてください
