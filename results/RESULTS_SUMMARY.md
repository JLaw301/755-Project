# COMP 755 Project 4: WASM Sandbox Isolation Limits (wasmtime)

## Isolation tests (run_isolation.sh)

| # | Test | Result | What it means |
|---|---|---|---|
| 1 | Read host files, no folders granted | All blocked (error 44, "no such file") | Plugin starts with no filesystem; host files don't exist to it |
| 2 | One folder granted as /data | Allowed file read; `../` escape blocked (error 63, "not permitted") | Access is limited to exactly what's granted; escapes are refused |
| 3 | Grab memory, no cap | Got all 256 MB | Without a limit, the plugin can grow |
| 4 | Grab memory, 64 MB cap | Stopped at 62 MB with a normal allocation error | Cap works; ~2 MB is the program's own startup memory |
| 5 | Read past end of its memory | Trapped: memory fault at 0x111000 in linear memory of size 0x110000 | Memory is one bounded block; 32-bit pointers can't name host addresses |
| 6 | Open files until stopped (host ulimit 1024) | Stopped at 1013 | No wasmtime-level fd limit; host per-process limit enforces it (~11 used by wasmtime) |
| 7 | Same, ulimit lowered to 256 | Stopped at 245 | Same ~11 gap, confirming the host OS limit is the enforcer |

Findings for discussion:
- File-handle limits come from the host process, not the sandbox, so one plugin could exhaust handles for others in the same wasmtime process.
- Running out of files shows up to the plugin as a generic "I/O error" (29), not "too many open files".

## Cold-start benchmark (benchmark_readers.sh, 50 runs each, 3 warmup)

Reader counts lines and words in a ~900 KB text file. All four versions printed `20000 lines, 180000 words`.

| Version | Median | Mean ± SD | Range |
|---|---|---|---|
| Reader (native, no sandbox) | 2.2 ms | 2.2 ± 0.3 ms | 1.8 – 3.1 ms |
| WASM Reader (precompiled) | 8.6 ms | 8.6 ± 0.9 ms | 7.2 – 11.3 ms |
| WASM Reader | 10.2 ms | 10.2 ± 0.9 ms | 8.3 – 12.0 ms |
| Docker Reader | 478.6 ms | 578.4 ± 629.6 ms | 453.3 – 4917.2 ms |

- WASM Reader started ~47x faster than Docker Reader by median (~56x precompiled).
- Docker's cost is setup (docker CLI -> dockerd -> containerd -> runc, plus namespaces, cgroups, layered filesystem, network). The Reader itself takes ~2 ms.
- WASM is one process: load module, allocate linear memory, grant preopened dirs, run.
- Precompiling saved only ~1.6 ms because Reader is tiny.
- One Docker run took 4.9 s (outlier), so medians are reported. Docker start times are less predictable.

Limitations: one VM (VirtualBox), one small task, times may differ on bare metal.
Chart: results/reader_times.png. Raw data: results/reader_times.json, results/reader_times.md, results/env.txt.
