import sys
from common import get_contest_id, move_to_bin_dir, change_launch, build

contest_name,contest_id,problem_id = get_contest_id(sys.argv[1])
move_to_bin_dir(contest_name,contest_id)
change_launch(contest_name,contest_id,problem_id)
build(contest_name,contest_id,problem_id)
