#!/bin/bash
contest="abc"
num=$1
aplha=$2
cd /workspaces/atcoder_rust/${contest}${num}/src/bin/
cargo build & cargo compete t ${aplha}