// Reader: reads a text file and prints how many lines and words it has.
// This one source file is built three ways for the benchmark:
//   Reader         - normal Linux program (no sandbox)
//   WASM Reader    - WebAssembly module run by wasmtime
//   Docker Reader  - the Linux program inside an empty Docker image
use std::{env, fs};

fn main() {
    let path = env::args().nth(1).unwrap_or("/data/input.txt".into());
    let text = fs::read_to_string(&path).expect("read input");
    println!(
        "{} lines, {} words",
        text.lines().count(),
        text.split_whitespace().count()
    );
}
