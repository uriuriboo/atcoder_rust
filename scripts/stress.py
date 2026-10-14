# ランダムテスト（oj generate-input）で、サンプル以外のテストケースを作る
#
# 使い方: python3 stress.py <init|hack|test> /workspaces/atcoder_rust/<abc325>/src/bin/<a>.rs
#   init: <contest>/stress/<problem>/ に gen.py（入力の生成）と naive.py（愚直解）の雛形を作る
#   hack: gen.py の入力で、解答と naive.py の出力が食い違うケース（反例）を探す
#         見つかったら stress/<problem>/test/hack-XXX.{in,out} に保存し、input.txt にもコピーする
#   test: stress/<problem>/test/ に保存したケースで、解答をテストする
# 解答の a.rs のほか、gen.py・naive.py を開いた状態でも実行できる
import glob
import os
import shutil
import subprocess
import sys
from common import WORKSPACE, get_contest_id, move_to_bin_dir, change_launch, build

GEN_TEMPLATE = '''\
# 入力を 1 ケース分、標準出力に書き出す
# 値を小さくしておくと、反例が見つかったときに手で追いやすい
import random

N = random.randint(1, 10)
A = [random.randint(1, 10) for _ in range(N)]
print(N)
print(*A)
'''

NAIVE_TEMPLATE = '''\
# 愚直解。計算量は気にせず、確実に正しい方法で書く
N = int(input())
A = list(map(int, input().split()))
print(sum(A))
'''

# gen.py・naive.py は、システムの python3 ではなく uv で入れた新しい Python で動かす（Dockerfile）
PYTHON = 'python3.15'
GEN = PYTHON + ' gen.py'
NAIVE = PYTHON + ' naive.py'


def write_if_absent(path, content):
    if os.path.exists(path):
        print('skip (already exists): ' + path)
        return
    with open(path, 'w') as f:
        f.write(content)
    print('created: ' + path)


def init(stress_dir):
    os.makedirs(stress_dir, exist_ok=True)
    write_if_absent(os.path.join(stress_dir, 'gen.py'), GEN_TEMPLATE)
    write_if_absent(os.path.join(stress_dir, 'naive.py'), NAIVE_TEMPLATE)


def prepare(stress_dir, contest_name, contest_id, problem_id):
    if not os.path.exists(os.path.join(stress_dir, 'gen.py')):
        sys.exit('gen.py がありません。先に "stress: init" を実行してください: ' + stress_dir)
    move_to_bin_dir(contest_name, contest_id)
    change_launch(contest_name, contest_id, problem_id)
    if build(contest_name, contest_id, problem_id).returncode != 0:
        sys.exit(1)
    os.chdir(stress_dir)
    return '{}/target/debug/{}{}-{}'.format(WORKSPACE, contest_name, contest_id, problem_id)


def hack(stress_dir, binary):
    if not os.path.exists('naive.py'):
        sys.exit('naive.py がありません: ' + stress_dir)
    # 反例が見つかるまで生成を繰り返す。止めるときは Ctrl+C
    try:
        cp = subprocess.run(['oj', 'generate-input', '-d', 'test', '-j', str(os.cpu_count()),
                             '--hack-actual', binary, '--hack-expected', NAIVE, GEN])
    except KeyboardInterrupt:
        sys.exit('interrupted')
    if cp.returncode != 0:
        sys.exit(cp.returncode)
    # 見つけた反例を input.txt にコピーし、F5 のデバッグ実行でそのまま追えるようにする
    found = max(glob.glob('test/hack-*.in'), key=os.path.getmtime)
    shutil.copyfile(found, WORKSPACE + '/input.txt')
    print('copied {} to input.txt'.format(os.path.join(stress_dir, found)))
    print('expected output:')
    with open(found[:-len('.in')] + '.out') as f:
        print(f.read(), end='')


def test(stress_dir, binary):
    if not glob.glob('test/*.in'):
        sys.exit('テストケースがありません。先に "stress: hack" を実行してください: ' + stress_dir)
    cp = subprocess.run(['oj', 'test', '-c', binary, '-d', 'test', '-j', str(os.cpu_count())])
    sys.exit(cp.returncode)


mode = sys.argv[1]
contest_name, contest_id, problem_id = get_contest_id(sys.argv[2])
# gen.py や naive.py（<contest>/stress/<problem>/*.py）を開いたままでも実行できるようにする
parsed_path = sys.argv[2].split('/')
if parsed_path[4] == 'stress':
    problem_id = parsed_path[5]
stress_dir = '{}/{}{}/stress/{}'.format(WORKSPACE, contest_name, contest_id, problem_id)

if mode == 'init':
    init(stress_dir)
elif mode == 'hack':
    hack(stress_dir, prepare(stress_dir, contest_name, contest_id, problem_id))
elif mode == 'test':
    test(stress_dir, prepare(stress_dir, contest_name, contest_id, problem_id))
else:
    sys.exit('unknown mode: ' + mode)
