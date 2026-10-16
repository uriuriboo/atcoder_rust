# User guide

What this environment can do, why it is convenient, and how to use it during a contest. For the internals, see [tasks.md](tasks.md) (tasks) and [build_performance.md](build_performance.md) (build speed), both in Japanese.

[日本語版](guide.md)

## What you can do

Open the repository as a Dev Container in VS Code and you get a Rust environment that matches AtCoder's judge. From fetching problems to testing, debugging, and submitting, everything is a click away without leaving the editor.

| What you want to do | Feature to use |
| --- | --- |
| Fetch a contest's problems and samples | "new contest" task |
| Test the problem you are solving against the samples | "build & test" task |
| Check the running time | "build & test release" task |
| Submit | "submit" task |
| Step through your code with your own input | Write the input in `input.txt` and press F5 |
| Find out why you get WA even though the samples pass | "stress: init / hack / test" tasks |
| See a graph input as a picture | "visualize graph" task |
| Write common code quickly | Snippets (`tmplt`, `rep`, and so on) and `library/` |

## Why it is convenient

### No setup needed

- The Rust version (1.89.0, edition 2024) and the versions of the available crates (about 65, including proconio, ac-library-rs, and itertools) are pinned to AtCoder's October 2025 language environment. Code that compiles locally is unlikely to fail to compile on AtCoder.
- Tools such as cargo-compete, clippy, rustfmt, online-judge-tools, Graphviz, and Python 3.15 for brute-force solutions are all installed when the container is created.

### The problem is detected from the open file

- Every task detects the contest and problem from the location of the file open in the editor (for example `abc325/src/bin/a.rs`). You do not have to type the contest or problem name each time.
- The stress test files `gen.py` and `naive.py` are treated as the same problem when they are open.

### Only the problem you are solving is built

- Only the open problem is built. You can test problem A even if problem B is half-written and does not compile.
- Samples are tested in parallel, as many at once as you have CPU cores.

### Ready to debug

- Running "build" or "build & test" points the debugger configuration (`.vscode/launch.json`) at the current problem.
- Paste an input into `input.txt` and press F5 to step through your code with breakpoints. You never have to edit the debugger configuration yourself.

### Counterexamples are found automatically

- When you get WA even though the samples pass, random inputs are fed to both your solution and a brute-force solution until their answers differ.
- The counterexample found is copied to `input.txt`, so you can debug it with F5 right away.

### Fast builds

- mold is used as the linker and build output lives on a Docker volume, so builds are fast even on Windows.
- Editor checks (rust-analyzer + clippy) cover only the open contest, so they stay fast as contests pile up.
- Tools are baked into the Docker image, so rebuilding the container is quick too.

### Editor support

- Code is formatted on save, and clippy warnings show up in the editor.
- The Python files you write for random testing (`gen.py` and `naive.py`) get completion (Pylance), Ruff checks, and formatting on save too. Choose "Debug Python" in Run and Debug to debug the open `.py` file with F5, reading `input.txt` as standard input.

## Getting started

### Requirements

- Docker (Docker Desktop on Windows and Mac)
- VS Code with the "Dev Containers" extension
- An AtCoder account (only needed to submit)

### First-time setup

1. Clone this repository **keeping the folder name `atcoder_rust`**. The scripts assume the path `/workspaces/atcoder_rust` inside the container, so they do not work if you rename the folder.
2. Open the folder in VS Code and choose "Reopen in Container" in the notification at the bottom right. If it does not appear, use `Ctrl+Shift+P` → "Dev Containers: Reopen in Container".
3. Building the image takes a few minutes the first time. When it finishes, the terminal asks for your AtCoder username and password.
   - Setup continues even if login fails. You can retry later with the "login" task (see also [If you cannot log in](#if-you-cannot-log-in)).

## Running tasks

Almost everything in this environment is done with VS Code tasks. There are two ways to run them.

- **Click**: click a button in the status bar at the bottom of the window (the Tasks extension). Up to six buttons are shown; choose the rest from "その他" (More). The buttons change with the open file.
  - With a solution `.rs` file (`<contest>/src/bin/`) open: `test` (build & test), `submit`, `release` (build & test release), `build`, `stress hack`, and `new contest`. stress init, stress test, graph, digraph (visualize graph), and login are under "その他".
  - With a random-test `gen.py` or `naive.py` open: the stress tasks, `new contest`, `graph`, and `digraph`. login is under "その他".
  - Otherwise: `new contest`, `graph`, `digraph`, and `login`.
- **Command Palette**: `Ctrl+Shift+P` → "Tasks: Run Task" → choose the task.

Except for "new contest", "visualize graph", and "login", run tasks **with the `.rs` file of the problem you are solving open and active in the editor**.

## Contest workflow

Problem A of ABC325 is used as an example.

### 1. Start a contest

Run the "new contest" task and enter the contest ID (`abc325`). The following is created.

```text
abc325/
├── Cargo.toml
├── src/bin/
│   ├── a.rs        solution file (with the template)
│   ├── b.rs
│   └── ...
└── testcases/
    ├── a.yml       sample inputs and outputs
    └── ...
```

Problems are not public before the contest starts, so run it after the start.

### 2. Solve

Open `abc325/src/bin/a.rs` and write your solution. It starts with the following template.

```rust
#[allow(unused_imports)]
use proconio::{marker::*, *};
#[allow(unused_imports)]
use std::{cmp::*, collections::*, *};

#[fastout]
fn main(){
    todo!();
}
```

Read the input with proconio's `input!` macro. The `tmplt` snippet replaces this with a template that already includes `input!` and commonly used `use` lines.

### 3. Test against the samples

With `a.rs` open, run the "build & test" task. The result of each sample (AC, WA, and so on) is shown in the terminal.

- To check the running time, use "build & test release". It builds with optimizations, so the running time is close to AtCoder's.
- To check only that it compiles, use "build".

### 4. Debug

1. Run "build" or "build & test" (this switches the debugger configuration to the current problem).
2. Paste the input you want to try into `input.txt` at the repository root.
3. Set breakpoints and press F5.

"build & test release" does not make a debug build, so use "build" or "build & test" before debugging.

### 5. Submit

With `a.rs` open, run the "submit" task. The sample tests run automatically before submitting, and nothing is submitted if they fail.

Check the result on AtCoder's submission list.

### 6. When you cannot find the cause of WA

When the samples pass but you get WA, look for a counterexample with random testing.

1. Run "stress: init" to create templates for the input generator `gen.py` and the brute-force solution `naive.py` (in `abc325/stress/a/`).
2. Write both files in Python for the problem.
3. Run "stress: hack" to search for a counterexample. When one is found, it is copied to `input.txt`, so debug it with F5.
4. After fixing, run "stress: test" to check that all counterexamples found so far pass.

For how to write the files and tips, see [stress_test.md](stress_test.md) (Japanese).

## Other features

### Graph visualization

For tree and graph problems, you can draw the input to check it.

1. Paste the problem's input into `input.txt`.
2. Run the "visualize graph" task ("visualize graph (directed)" for directed graphs).
3. `graph.png` is created and opened in the editor.

The input format is detected automatically.

| First line | How it is read |
| --- | --- |
| `N` | As a tree: the next N-1 lines are edges |
| `N M` | The next M lines are edges |

- If an edge line has three columns like `u v w`, `w` is shown as the edge's weight label.
- Vertices are numbered from 1. Lines after the edges (such as queries) are ignored.

### Snippets

Type one of the following keywords in a `.rs` file and pick it from the suggestions to expand it.

| Keyword | Expands to |
| --- | --- |
| `tmplt` | A whole template including `input!` and common `use` lines |
| `rep` | `for i in 0..n { }` |
| `rrep` | A nested loop |
| `pbit` | Bit brute force |
| `bins` | Meguru-style binary search |
| `oans` | `println!("{}",ans);` |
| `oY` / `oN` | Print `Yes` / `No` |

You can add or change snippets in `.vscode/rust.code-snippets`.

### Library

`library/src/` has code meant to be copied. Each file is a complete program with `main`, so paste the part you need into your solution.

| File | Contents |
| --- | --- |
| `dijkstra.rs` | Dijkstra's algorithm |
| `bsf.rs` | Breadth-first search (BFS) |
| `dfs_tmp.rs` | Depth-first search (DFS) |
| `bipartite_graph.rs`, `binary_graph.rs` | Bipartite graph check and two-coloring |
| `eratosthenes.rs` | Sieve of Eratosthenes |
| `is_kaibun.rs` | Palindrome check |

### Using the command line

You can also work from a terminal inside the container without tasks.

```bash
# Start a contest
cargo compete new abc325
sed -i 's/^edition = "2021"$/edition = "2024"/' abc325/Cargo.toml  # use edition 2024, same as AtCoder
cargo member include abc325

# Build and test (give the contest number and the problem)
./scripts/build_test.bash 325 a

# Submit
./scripts/submit.bash 325 a
```

- `build_test.bash` and `submit.bash` have the contest prefix fixed to `abc`. Edit them to use them for ARC or AGC (the tasks work for ARC and AGC as they are).
- Building from the command line does not update `launch.json`. To debug, run the "build" task once, or edit `program` in `launch.json` by hand.

## Troubleshooting

### If you cannot log in

AtCoder added a CAPTCHA (Cloudflare Turnstile) to its login page, so the "login" task or submitting may fail. In that case, use your browser's login cookie.

1. Log in to AtCoder in your browser.
2. In the developer tools, copy the value of the `REVEL_SESSION` cookie for atcoder.jp.
3. Open `~/.local/share/cargo-compete/cookies.jsonl` inside the container and replace the `REVEL_SESSION` value.

If you still cannot submit, submit from the browser.

### A task fails with "list index out of range" or similar

- Check that the `.rs` file of the problem you are solving is active. If the terminal or `input.txt` is active, the problem cannot be detected.
- Check that the path inside the container is `/workspaces/atcoder_rust/...`. It does not work if you renamed the repository folder.

### The problem is not found as a build target

If you ran only `cargo compete new` instead of the "new contest" task, the contest is not added to the workspace. Run `cargo member include <contest>`.

### Freeing up disk space

Build output is stored in the Docker volume `atcoder-rust-target` and survives container rebuilds. Stop the container and run `docker volume rm atcoder-rust-target` on the host to delete it.

## Limitations

- Contest names are assumed to be a 3-letter prefix such as `abc`, `arc`, or `agc` followed by a number.
- The problem is detected from the first character of the file name, so one-letter problems such as `a.rs` to `g.rs` are assumed.
- When AtCoder updates its language environment, the versions in `compete.toml` and elsewhere need to be updated to match (see "主な構成" in `CLAUDE.md` for the steps).
