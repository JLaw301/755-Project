# Turns results/reader_times.json into results/reader_times.png and prints medians.
# Run from inside ~/plugin:  python3 plot_reader_times.py
import json
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt

results = json.load(open("results/reader_times.json"))["results"]
names = [r["command"] for r in results]
times = [[t * 1000 for t in r["times"]] for r in results]  # seconds -> ms

plt.figure(figsize=(9, 5))
plt.boxplot(times)
plt.xticks(range(1, len(names) + 1), [n.replace(" (", "\n(") for n in names])
plt.yscale("log")
plt.ylabel("Start-to-exit time (ms, log scale)")
plt.title(f"Cold start: Reader vs WASM Reader vs Docker Reader ({len(times[0])} runs each)")
plt.tight_layout()
plt.savefig("results/reader_times.png", dpi=150)

base = sorted(times[0])[len(times[0]) // 2]
for n, t in zip(names, times):
    med = sorted(t)[len(t) // 2]
    print(f"{n:26s} median {med:8.1f} ms   ({med / base:5.1f}x Reader)")
print("saved results/reader_times.png")
