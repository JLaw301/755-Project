use std::fs::File;
fn main() {
    let mut files = Vec::new();
    for i in 0..100_000 {
        match File::open("/data/secret.txt") {
            Ok(f) => files.push(f),
            Err(e) => { println!("STOPPED after {} open files: {}", i, e); return; }
        }
    }
    println!("opened 100000 files, no limit hit");
}
