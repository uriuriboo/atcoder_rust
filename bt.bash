#!/bin/bash
contest="abc"
num=$1
aplha=$2
cd /workspaces/atcr/${contest}${num}/src/bin/
cargo build & cargo compete t ${aplha}