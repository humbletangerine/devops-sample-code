import os
import time
from flask import Flask, jsonify, Response
from prometheus_client import Counter, Histogram, Gauge, generate_latest, CONTENT_TYPE_LATEST
import psutil

app = Flask(__name__)

PRODUCTS = {
    101: {"name": "Milk", "available": True, "quantity": 24},
    102: {"name": "Bread", "available": True, "quantity": 11},
    103: {"name": "Eggs", "available": False, "quantity": 0},
    104: {"name": "Rice", "available": True, "quantity": 38},
}

REQUESTS = Counter(
    "product_api_requests_total",
    "Total product availability API requests",
    ["method", "endpoint", "status"],
)
LATENCY = Histogram(
    "product_api_request_duration_seconds",
    "Product API request duration in seconds",
    ["endpoint"],
    buckets=(0.005, 0.01, 0.025, 0.05, 0.1, 0.25, 0.5, 1, 2, 5),
)
PROCESS_CPU = Gauge("app_process_cpu_percent", "Flask worker process CPU utilization percent")
PROCESS_MEMORY = Gauge("app_process_memory_bytes", "Flask worker process resident memory in bytes")
PROCESS = psutil.Process(os.getpid())

@app.before_request
def start_timer():
    from flask import g
    g.request_started_at = time.perf_counter()

@app.after_request
def record_metrics(response):
    from flask import request, g
    endpoint = request.endpoint or "unknown"
    REQUESTS.labels(request.method, endpoint, str(response.status_code)).inc()
    started = getattr(g, "request_started_at", None)
    if started is not None and endpoint != "metrics":
        LATENCY.labels(endpoint).observe(time.perf_counter() - started)
    response.headers["X-Served-By"] = os.getenv("HOSTNAME", "local")
    return response

@app.get("/healthz")
def healthz():
    return jsonify(status="ok", pod=os.getenv("HOSTNAME", "local"))

@app.get("/availability/<int:product_id>")
def availability(product_id: int):
    product = PRODUCTS.get(product_id)
    if product is None:
        return jsonify(error="product_not_found", product_id=product_id), 404
    return jsonify(
        product_id=product_id,
        name=product["name"],
        available=product["available"],
        quantity=product["quantity"],
        served_by=os.getenv("HOSTNAME", "local"),
    )

@app.get("/products")
def products():
    return jsonify([
        {"product_id": product_id, **details}
        for product_id, details in PRODUCTS.items()
    ])

@app.get("/metrics")
def metrics():
    # Process-level metrics complement the cAdvisor container CPU/memory metrics.
    try:
        PROCESS_CPU.set(PROCESS.cpu_percent(interval=None))
        PROCESS_MEMORY.set(PROCESS.memory_info().rss)
    except (psutil.Error, OSError):
        pass
    return Response(generate_latest(), mimetype=CONTENT_TYPE_LATEST)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
