# RustのAtCoder用Docker環境です

cargo-competeを使用しています
詳しい利用方法は[こちら](https://qiita.com/rokoooouribo/items/76a0057c75694fd943f5)


## 使い方

### ビルドとテスト

```bash:
./bt.bash コンテストの数字 問題のアルファベット
```

### 提出

```bash:
./sub.bash コンテストの数字 問題のアルファベット
```

### デバッグ

input.txtにデバッグの入力を入れてください

launch.jsonのprogramを解いている問題のコンテストの数字に書き換えてください

## 注意

bt.bashとsub.bashはabc、arc、agcごとに書き換えてください
launch.jsonはコンテストごとに書き換えてください

rust-analyzerをインストールするとコンテナを立ち上げるごとに使えなくなりました
