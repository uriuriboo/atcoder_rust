# RustのAtCoder用Docker環境です

[cargo-compete](https://github.com/qryxip/cargo-compete)を使用しています
詳しい利用方法は[こちら](https://qiita.com/rokoooouribo/items/76a0057c75694fd943f5)


## 使い方

### ビルドとテスト

```bash:
./bt.bash コンテストの数字 問題のアルファベット
```

テストしたい.rsファイルをvscodeで表示した状態で右下のTASKRUNNERのbuild & testをクリックしてもできます。

### 提出

```bash:
./sub.bash コンテストの数字 問題のアルファベット
```

同様に提出したい.rsファイルをvscodeで表示した状態で右下のTASKRUNNERのsubmitをクリックしてもできます。


### デバッグ

input.txtにデバッグの入力を入れてください

launch.jsonのprogramを解いている問題のコンテストの数字に書き換えてください

試験的にbuild & testをクリックしたときに書き換わるように設定しました。

## 注意

bt.bashとsub.bashはabc、arc、agcごとに書き換えてください
launch.jsonはコンテストごとに書き換えてください

rust-analyzerをインストールするとコンテナを立ち上げるごとに使えなくなりました
