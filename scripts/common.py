import os
import subprocess

WORKSPACE = '/workspaces/atcoder_rust'

def get_contest_id(path) -> tuple:
    parsed_path = path.split("/")
    contest_name = parsed_path[3][:3]
    contest_id = parsed_path[3][3:]
    problem_id = parsed_path[6][0]
    return contest_name,contest_id,problem_id

def move_to_bin_dir(contest_name,contest_id):
    os.chdir('{}/{}{}/src/bin'.format(WORKSPACE,contest_name,contest_id))

def change_launch(contest_name,contest_id,problem_id):
    subprocess.run([WORKSPACE + "/scripts/change_launch.bash",contest_name,contest_id,problem_id])

def build(contest_name,contest_id,problem_id):
    return subprocess.run(["cargo", "build", "--bin" , contest_name + contest_id + "-" + problem_id])
