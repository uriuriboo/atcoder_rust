#[allow(unused_imports)]
use proconio::{marker::*, *};
#[allow(unused_imports)]
use std::{cmp::*, collections::*, *};

fn eratosthenesn(n: usize) -> Vec<usize> {
    let mut primes: Vec<usize> = Vec::new();
    let mut isp = vec![true; n + 1];
    isp[0] = false;
    isp[1] = false;
    for i in 2..=n {
        if isp[i] == false {
            continue;
        }
        primes.push(i);
        let mut j: usize = 2 * i;
        while j <= n {
            isp[j] = false;
            j += i;
        }
    }
    primes
}