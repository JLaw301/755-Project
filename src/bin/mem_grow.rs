fn main() {
    let mb = 1024 * 1024;
    let mut chunks: Vec<Vec<u8>> = Vec::with_capacity(256);
    for i in 1..=256 {
        let mut v: Vec<u8> = Vec::new();
        if let Err(e) = v.try_reserve_exact(mb) {
            println!("STOPPED at {} MB: {}", i - 1, e);
            return;
        }
        v.resize(mb, 1);
        chunks.push(v);
        if i % 16 == 0 { println!("allocated {} MB", i); }
    }
    println!("allocated 256 MB, no limit hit");
}
