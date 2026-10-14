# Python（gen.py・naive.py）のデバッグ実行用。標準入力を input.txt に向けてから、指定したファイルを実行する
# debugpy の launch.json には標準入力を切り替える設定が無いため、このスクリプトを経由する（.vscode/launch.json の "Debug Python"）
#
# 使い方: python3 debug_python.py <実行する .py>
import os
import runpy
import sys
from common import WORKSPACE

target = os.path.abspath(sys.argv[1])
# input()・sys.stdin・open(0) のどれで読んでも input.txt から読めるよう、ファイル記述子 0 を差し替える
fd = os.open(WORKSPACE + '/input.txt', os.O_RDONLY)
os.dup2(fd, 0)
os.close(fd)
# 対象のファイルを直接実行したときと同じ sys.argv・sys.path にする
sys.argv = sys.argv[1:]
sys.path[0] = os.path.dirname(target)
runpy.run_path(target, run_name='__main__')
