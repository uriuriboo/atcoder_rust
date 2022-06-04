#[allow(unused_imports)]
use proconio::{marker::*, *};

fn dfs(g:&Vec<Vec<usize>>,col:&mut Vec<usize>,cur:usize,pos:usize) {
    col[pos] = cur;
    for &u in &g[pos] {
        if col[u] == 10 {
            dfs(g,col,1-cur,u);
        }
    }
}

#[fastout]
fn main() {
    input!{
        n:usize,
        ab:[(Usize1,Usize1);n-1]
    }
    let mut g:Vec<Vec<usize>> = vec![vec![];n];

    for &(a,b) in &ab {
        g[a].push(b);
        g[b].push(a);
    }

    let mut col:Vec<usize> = vec![10;n];

    dfs(&g,&mut col,0,0);

    let mut g1:Vec<usize> = vec![];
    let mut g2:Vec<usize> = vec![];

    for i in 0..n {
        if col[i] == 0 {
            g1.push(i);
        }
        else {
            g2.push(i);
        }
    }
    
    if g1.len() > g2.len() {
        for i in 0..n/2 {
            print!("{} ",g1[i]+1);
        }
    }

    else {
        for i in 0..n/2 {
            print!("{} ",g2[i]+1);
        }
    }
    
}

