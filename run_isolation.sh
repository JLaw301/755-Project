#!/bin/bash
cd "$(dirname "$0")"
cargo build --release --target wasm32-wasip1 || exit 1
W=target/wasm32-wasip1/release
mkdir -p results /tmp/sandbox
echo "allowed file" > /tmp/sandbox/secret.txt

echo "== 1. filesystem, no dirs ==";  wasmtime $W/fs_escape.wasm 2>&1 | tee results/fs_no_dirs.txt
echo "== 2. filesystem, sandbox ==";  wasmtime --dir /tmp/sandbox::/data $W/fs_escape.wasm 2>&1 | tee results/fs_sandbox_dir.txt
echo "== 3. memory, no cap ==";       wasmtime $W/mem_grow.wasm 2>&1 | tee results/mem_nocap.txt | tail -2
echo "== 4. memory, 64 MB cap ==";    wasmtime -W max-memory-size=67108864 $W/mem_grow.wasm 2>&1 | tee results/mem_cap64.txt | tail -2
echo "== 5. out-of-bounds read ==";   wasmtime $W/oob_read.wasm 2>&1 | tee results/oob_read.txt
echo "== 6. fd loop, default ==";     wasmtime --dir /tmp/sandbox::/data $W/fd_loop.wasm 2>&1 | tee results/fd_default.txt
echo "== 7. fd loop, ulimit 256 =="; (ulimit -n 256; wasmtime --dir /tmp/sandbox::/data $W/fd_loop.wasm 2>&1 | tee results/fd_ulimit256.txt)
echo "host ulimit -n: $(ulimit -n)" | tee results/host_ulimit.txt
