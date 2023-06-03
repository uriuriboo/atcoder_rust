#!/bin/bash

contest_name=$1
contest_id=$2
problem_id=$3
workspaceFolder=/workspaces/atcoder_rust
workspaceRoot=/workspaces/atcoder_rust
echo change launch.json for debag ${contest_name}${contest_id}-${problem_id}

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
        }\n\
    ]\n\
}"\
> .vscode/launch.json