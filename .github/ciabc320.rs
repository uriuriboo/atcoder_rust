#[allow(unused_imports)]
use proconio::{marker::*, *};
#[allow(unused_imports)]
use std::{cmp::*, collections::*, *};

#[fastout]
fn main(){
    input! {
        a:usize,
        b:usize
    }

    let mut ans = a.pow(b.try_into().unwrap()) + b.pow(a.try_into().unwrap());
    println!("{}",ans);
}
