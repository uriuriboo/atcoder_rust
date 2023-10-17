fn dfs(
    g: &Vec<Vec<(usize, isize, isize)>>,
    visited: &mut Vec<bool>,
    x: isize,
    y: isize,
    v: usize,
    ans: &mut Vec<(isize, isize)>,
) -> () {
    visited[v] = true;
    ans[v] = (x, y);

    for &(u, dx, dy) in &g[v] {
        if visited[u] {
            continue;
        }
        dfs(g, visited, x + dx, y + dy, u, ans);
    }
}
