import argparse
import concurrent.futures
import time
import urllib.error
import urllib.request
from collections import Counter

parser = argparse.ArgumentParser(description="Generate repeated product availability requests")
parser.add_argument("--url", default="http://127.0.0.1:8081", help="Base URL of the product API")
parser.add_argument("--requests", type=int, default=600)
parser.add_argument("--workers", type=int, default=20)
args = parser.parse_args()

PRODUCT_IDS = [101, 102, 103, 104, 999]

def send_one(i):
    url = f"{args.url.rstrip('/')}/availability/{PRODUCT_IDS[i % len(PRODUCT_IDS)]}"
    started = time.perf_counter()
    try:
        with urllib.request.urlopen(url, timeout=8) as response:
            code = response.status
            response.read()
    except urllib.error.HTTPError as exc:
        code = exc.code
        exc.read()
    except Exception:
        code = 0
    return code, time.perf_counter() - started

start = time.perf_counter()
counts = Counter()
latencies = []
with concurrent.futures.ThreadPoolExecutor(max_workers=args.workers) as pool:
    for code, duration in pool.map(send_one, range(args.requests)):
        counts[code] += 1
        latencies.append(duration)
elapsed = time.perf_counter() - start
latencies.sort()
p95 = latencies[min(len(latencies) - 1, int(len(latencies) * 0.95))] if latencies else 0
print(f"Requests attempted : {args.requests}")
print(f"Concurrency        : {args.workers}")
print(f"Elapsed seconds    : {elapsed:.2f}")
print(f"Throughput         : {args.requests / elapsed:.2f} requests/sec")
print(f"HTTP status counts : {dict(counts)}")
print(f"p95 latency        : {p95 * 1000:.1f} ms")
print("Note: HTTP 404 is expected for test product id 999; status 0 means connection failure.")
