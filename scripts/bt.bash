#!/bin/bash
contest=$1
num=$2
aplha=$3
cd /workspaces/atcoder_rust/${contest}${num}/src/bin/
cargo build & cargo compete t ${aplha}