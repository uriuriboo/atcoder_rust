"""競プロのグラフ入力を Graphviz で PNG にする

使い方: python3 visualize.py input.txt [--directed] [--zero-indexed]

入力形式は自動で判定する
- 1行目が "N"   : 木として N-1 行の辺を読む
- 1行目が "N M" : M 行の辺を読む（3つ目以降の値は無視）
- 辺の行が "u v w" なら w を重みとしてラベルに出す
辺の後ろにある行（クエリなど）は無視する
"""
import argparse
import os
import shutil
import subprocess
import sys


def parse(path):
    with open(path) as f:
        lines = [line.split() for line in f if line.strip()]
    if not lines:
        sys.exit("入力が空です")

    header = lines[0]
    n = int(header[0])
    m = n - 1 if len(header) == 1 else int(header[1])

    edges = []
    for row in lines[1:1 + m]:
        u, v = int(row[0]), int(row[1])
        w = row[2] if len(row) >= 3 else None
        edges.append((u, v, w))
    if len(edges) < m:
        print("警告: 辺が {} 本しか読めませんでした（期待値 {}）".format(len(edges), m))
    return n, edges


def to_dot(n, edges, directed, zero_indexed):
    start = 0 if zero_indexed else 1
    kind, arrow = ("digraph", "->") if directed else ("graph", "--")
    out = [kind + " G {", "  node [shape=circle];"]
    for i in range(start, start + n):
        out.append("  {};".format(i))
    for u, v, w in edges:
        label = ' [label="{}"]'.format(w) if w is not None else ""
        out.append("  {} {} {}{};".format(u, arrow, v, label))
    out.append("}")
    return "\n".join(out) + "\n"


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("input")
    parser.add_argument("--directed", action="store_true", help="有向グラフとして描く")
    parser.add_argument("--zero-indexed", action="store_true", help="頂点番号を 0 始まりにする")
    parser.add_argument("--out", default=None, help="出力する PNG のパス（既定: 入力と同じ場所の graph.png）")
    args = parser.parse_args()

    n, edges = parse(args.input)
    out_png = args.out or os.path.join(os.path.dirname(os.path.abspath(args.input)), "graph.png")
    out_dot = os.path.splitext(out_png)[0] + ".dot"

    with open(out_dot, "w") as f:
        f.write(to_dot(n, edges, args.directed, args.zero_indexed))

    if shutil.which("dot") is None:
        sys.exit("dot コマンドがありません。sudo apt-get install -y graphviz を実行してください")
    subprocess.run(["dot", "-Tpng", out_dot, "-o", out_png], check=True)
    print("出力しました: " + out_png)

    if shutil.which("code"):
        subprocess.run(["code", out_png])


if __name__ == "__main__":
    main()
