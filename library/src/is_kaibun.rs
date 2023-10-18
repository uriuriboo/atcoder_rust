fn is_kaibun(s: &str) -> bool {
    if s == s.chars().rev().collect::<String>() {
        return true;
    }
    return false;
}

#[test]
fn kaibun() {
    assert_eq!(true, is_kaibun("bkb"));
}
