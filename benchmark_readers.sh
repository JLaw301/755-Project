#!/bin/bash
# Times 50 cold starts of each Reader version.
# Run from inside ~/plugin:  ./benchmark_readers.sh
cd "$(dirname "$0")"; set -e
mkdir -p results /tmp/bench docker

# Input file (~900 KB of text), created once
[ -f /tmp/bench/input.txt ] || yes "the quick brown fox jumps over the lazy dog" | head -n 20000 > /tmp/bench/input.txt

echo "== building Reader, WASM Reader and Docker Reader =="
cargo build --release --target wasm32-wasip1 --bin reader
cargo build --release --target x86_64-unknown-linux-musl --bin reader
WASM_READER=target/wasm32-wasip1/release/reader.wasm
READER=target/x86_64-unknown-linux-musl/release/reader
wasmtime compile "$WASM_READER" -o target/reader.cwasm

cp "$READER" docker/reader
printf 'FROM scratch\nCOPY reader /reader\nENTRYPOINT ["/reader"]\n' > docker/Dockerfile
docker build -q -t docker-reader docker/

echo "== sanity check: all four lines should match =="
"$READER" /tmp/bench/input.txt
wasmtime --dir /tmp/bench::/data "$WASM_READER"
wasmtime run --allow-precompiled --dir /tmp/bench::/data target/reader.cwasm
docker run --rm -v /tmp/bench:/data:ro docker-reader

echo "== timing 50 cold starts of each =="
hyperfine -N --warmup 3 --runs 50 \
  -n "Reader"                    "$READER /tmp/bench/input.txt" \
  -n "WASM Reader"               "wasmtime --dir /tmp/bench::/data $WASM_READER" \
  -n "WASM Reader (precompiled)" "wasmtime run --allow-precompiled --dir /tmp/bench::/data target/reader.cwasm" \
  -n "Docker Reader"             "docker run --rm -v /tmp/bench:/data:ro docker-reader" \
  --export-json results/reader_times.json --export-markdown results/reader_times.md

{ uname -a; nproc; free -h; wasmtime --version; docker --version; } > results/env.txt
echo "== done: results/reader_times.json, results/reader_times.md, results/env.txt =="
