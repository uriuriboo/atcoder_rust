import sys
import subprocess
from common import get_contest_id, move_to_bin_dir

contest_name,contest_id,problem_id = get_contest_id(sys.argv[1])
move_to_bin_dir(contest_name,contest_id)
cp = subprocess.run(["cargo" ,"compete" ,"s" ,problem_id])
