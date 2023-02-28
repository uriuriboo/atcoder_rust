# RustのDocker環境です

機能を追加したり、修正したりの途中です
詳しい利用方法は[こちら](https://qiita.com/rokoooouribo/items/76a0057c75694fd943f5)

## 今後のTODO

1. sudo apt-get する(4のため)
2. fish shellをダウンロード
3. fisherインストール
4. taskrunnerでビルド、テスト、デバッグ、グラフ可視化できるようにする
5. ライブラリの追加
6. online-judge-toolsの追加
7. シェルスクリプト(tc.bash)でabc以外にもテストができるようにする(権限を与えて実行可能に chmod a+x tc.bash)
8. cargo-equipを使えるように設定

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
