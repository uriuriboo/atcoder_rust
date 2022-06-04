#[allow(unused_imports)]
use proconio::{marker::*, *};
#[allow(unused_imports)]
use std::{cmp::*, collections::*, *};
const INF: usize = std::usize::MAX / 2;
#[fastout]
fn main(){
    input!{
        n:usize,
        ab:[(Usize1,Usize1);n]
    }

    let mut g = vec![vec![]; n];
    for (a, b) in ab {
        g[a].push(b);
        g[b].push(a);
    }

    let mut d:Vec<usize> = vec![INF; n];
    let mut q = BinaryHeap::new();

    let s = 0;
    d[s] = 0;
    q.push((Reverse(0), s));
    //距離、頂点
    while let Some((Reverse(dist), u)) = q.pop() {
        if d[u] < dist {
            continue;
        }
        for &v in &g[u] {
            let dist = d[u]+1;
            if d[v] > dist {
                d[v] = dist;
                q.push((Reverse(dist), v));
            }
        }
    }
    let s = d.iter().minelement();
}