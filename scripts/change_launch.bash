#!/bin/bash

contest_name=$1
contest_id=$2
problem_id=$3
workspaceFolder=/workspaces/atcoder_rust
workspaceRoot=/workspaces/atcoder_rust
echo change launch.json for debag ${contest_name}${contest_id}-${problem_id}

# pwd

echo -e \
"{\n\
    \"version\": \"0.2.0\",\n\
    \"configurations\": [\n\
        {\n\
            \"type\": \"lldb\",\n\
            \"request\": \"launch\",\n\
            \"name\": \"Debug\",\n\
            \"sourceLanguages\": [\n\
                \"rust\"\n\
            ],\n\
            //\"preLaunchTask\": \"cargo build\",\n\
            \"internalConsoleOptions\": \"openOnSessionStart\",\n\
            \"program\": \"/workspaces/atcoder_rust/target/debug/${contest_name}${contest_id}-${problem_id}\",\n\
            \"args\": [],\n\
            \"stdio\": [\n\
                \"/workspaces/atcoder_rust/input.txt\"\n\
            ],\n\
        },\n\
        // 開いている Python（gen.py・naive.py）を、input.txt を標準入力にしてデバッグする\n\
        {\n\
            \"type\": \"debugpy\",\n\
            \"request\": \"launch\",\n\
            \"name\": \"Debug Python\",\n\
            \"program\": \"/workspaces/atcoder_rust/scripts/debug_python.py\",\n\
            \"args\": [\n\
                \"\${file}\"\n\
            ],\n\
            \"console\": \"integratedTerminal\",\n\
        }\n\
    ]\n\
}"\
> $workspaceRoot/.vscode/launch.json