impl Solution {
    pub fn possible_bipartition(n: i32, dislikes: Vec<Vec<i32>>) -> bool {
        let mut col:Vec<i32> =vec![0;n as usize];
        let mut g:Vec<Vec<usize>> = vec![vec![];n as usize];

        for i in dislikes.iter(){
            g[(i[0]-1) as usize].push((i[1]-1) as usize);
            g[(i[1]-1) as usize].push((i[0]-1) as usize);
        }

        fn dfs(g:&Vec<Vec<usize>>,col:&mut Vec<i32>,c:i32,v:usize) -> bool{
            col[v] = c;

            for &u in &g[v] {
                if col[u] == c {
                        return false;
                    }
                if col[u] == 0 && !dfs(g,col,-c,u) {
                    return false;
                    }
                }
                return true;
            }

            for i in 0..n as usize{
                if col[i] == 0{
                    if !dfs(&g,&mut col,1,i){
                        return false;
                    }
                }
            }
            return true;
        }
}
