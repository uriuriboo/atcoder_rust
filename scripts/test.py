import os,sys
import subprocess
from urllib.request import urlopen

def get_contest_id(path) -> tuple:
    parsed_path = path.split("/")
    contest_name = parsed_path[3][:3]
    contest_id = parsed_path[3][3:]
    problem_id = parsed_path[6][0]
    return contest_name,contest_id,problem_id

def download_test(contest_name,contest_id,problem_id):
    url = "https://atcoder.jp/contests/{0}/tasks/{0}_{1}".format(contest_id,problem_id)
    # cp = subprocess.run("pwd") /workspaces/atcoder_rust
    # cp = subprocess.run(["./bt.bash",contest_name,contest_id,problem_id])
    cp = subprocess.run(["scripts/change_launch.bash",contest_name,contest_id,problem_id])
    cp = subprocess.run(["scripts/bt.bash",contest_name,contest_id,problem_id])
    if cp != 0:
        print("error test failed.check the file you have open.")
        sys.exit(1)

contest_name,contest_id,problem_id = get_contest_id(sys.argv[1])
download_test(contest_name,contest_id,problem_id)