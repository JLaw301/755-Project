use std::fs;
fn main() {
    for path in ["/etc/hostname", "/data/secret.txt", "/data/../etc/hostname"] {
        match fs::read_to_string(path) {
            Ok(s)  => println!("READ  {path}: {}", s.trim()),
            Err(e) => println!("BLOCK {path}: {e}"),
        }
    }
}
