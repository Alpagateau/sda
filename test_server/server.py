import base64
from http.server import BaseHTTPRequestHandler, HTTPServer
import json

PORT = 8000

class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        with open("image.png", "rb") as f:
            image_bytes = f.read()

        base64_str = base64.b64encode(image_bytes).decode("utf-8")

        response = json.dumps({
            "name": "Player",
            "date": "03-04-2026",
            "image": base64_str,
            "streak": 5
        }).encode("utf-8")

        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(response)))
        self.end_headers()

        self.wfile.write(response)

    def do_POST(self):
        response = {"text": "Thx"}

        self.send_response(200)
        self.send_header("Content-Type", "application/json")
        self.end_headers()
        self.wfile.write(json.dumps(response).encode())


def start_server(port=PORT):
    server = HTTPServer(("localhost", port), Handler)
    print(f"Server running on http://localhost:{port}")
    server.serve_forever()


if __name__ == "__main__":
    start_server()