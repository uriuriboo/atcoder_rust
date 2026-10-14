import sys
import subprocess
from common import get_contest_id, move_to_bin_dir, change_launch

contest_name,contest_id,problem_id = get_contest_id(sys.argv[1])
move_to_bin_dir(contest_name,contest_id)
change_launch(contest_name,contest_id,problem_id)
# debug ビルドは行わない（cargo compete t --release が release ビルドする）
cp = subprocess.run(["cargo", "compete", "t", problem_id , "--release"])
