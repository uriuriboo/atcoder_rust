import os,sys
import subprocess
from urllib.request import urlopen

def get_contest_id(path) -> tuple:
    parsed_path = path.split("/")
    contest_name = parsed_path[3][:3]
    contest_id = parsed_path[3][3:]
    problem_id = parsed_path[6][0]
    return contest_name,contest_id,problem_id


contest_name,contest_id,problem_id = get_contest_id(sys.argv[1])
path = '/workspaces/atcoder_rust/{}{}/src/bin'.format(contest_name,contest_id)
os.chdir(path)
cp = subprocess.run(["/workspaces/atcoder_rust/scripts/change_launch.bash",contest_name,contest_id,problem_id])
cp = subprocess.run(["cargo" ,"build"])
cp = subprocess.run(["cargo" ,"compete" ,"t" ,problem_id ,"--release"])