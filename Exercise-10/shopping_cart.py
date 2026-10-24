from flask import Flask, jsonify, request

app = Flask(__name__)
cart = []  # Demo only: each replica has independent in-memory state.

@app.get("/cart")
def get_cart():
    return jsonify(cart)

@app.post("/cart")
def add_to_cart():
    item = request.get_json(silent=True)
    if not isinstance(item, dict):
        return jsonify({"error": "Expected JSON object"}), 400
    cart.append(item)
    return jsonify(cart), 201

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
