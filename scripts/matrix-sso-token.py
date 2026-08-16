#!/usr/bin/env python3
import argparse
import json
import os
import urllib.parse
import urllib.request
import webbrowser
from http.server import BaseHTTPRequestHandler, HTTPServer


DEFAULT_HS = os.environ.get("MATRIX_URL", "https://matrix.example.com")
DEFAULT_PORT = 8765

login_token = None


class Handler(BaseHTTPRequestHandler):
    def do_GET(self):
        global login_token
        qs = urllib.parse.parse_qs(urllib.parse.urlparse(self.path).query)
        login_token = qs.get("loginToken", [None])[0]

        self.send_response(200)
        self.end_headers()
        self.wfile.write(b"Matrix login token received. You can close this tab.\n")

    def log_message(self, *args):
        pass


def update_env_file(path, values):
    existing = []
    seen = set()

    if os.path.exists(path):
        with open(path, "r", encoding="utf-8") as env_file:
            existing = env_file.readlines()

    with open(path, "w", encoding="utf-8") as env_file:
        for line in existing:
            key = line.split("=", 1)[0].strip()
            if key in values:
                env_file.write(f"{key}={values[key]}\n")
                seen.add(key)
            else:
                env_file.write(line)

        for key, value in values.items():
            if key not in seen:
                env_file.write(f"{key}={value}\n")


def main():
    parser = argparse.ArgumentParser(description="Get a Matrix access token via SSO.")
    parser.add_argument("--homeserver", default=DEFAULT_HS)
    parser.add_argument("--port", type=int, default=DEFAULT_PORT)
    parser.add_argument("--env-file")
    args = parser.parse_args()

    homeserver = args.homeserver.rstrip("/")
    redirect = f"http://127.0.0.1:{args.port}/callback"
    url = (
        homeserver
        + "/_matrix/client/v3/login/sso/redirect?"
        + urllib.parse.urlencode({"redirectUrl": redirect, "action": "login"})
    )

    print("Opening browser for Matrix SSO...")
    print(url)
    webbrowser.open(url)

    HTTPServer(("127.0.0.1", args.port), Handler).handle_request()

    if not login_token:
        raise SystemExit("No loginToken received")

    payload = {
        "type": "m.login.token",
        "token": login_token,
        "initial_device_display_name": "CLI/API token",
    }

    req = urllib.request.Request(
        homeserver + "/_matrix/client/v3/login",
        data=json.dumps(payload).encode(),
        headers={"Content-Type": "application/json"},
        method="POST",
    )

    with urllib.request.urlopen(req) as response:
        data = json.load(response)

    values = {
        "MATRIX_URL": homeserver,
        "MATRIX_USER_ID": data["user_id"],
        "MATRIX_DEVICE_ID": data["device_id"],
        "MATRIX_ACCESS_TOKEN": data["access_token"],
    }

    if args.env_file:
        update_env_file(args.env_file, values)
        print(f"Saved Matrix token for {data['user_id']} to {args.env_file}")
    else:
        print("user_id:", data.get("user_id"))
        print("device_id:", data.get("device_id"))
        print("access_token:", data.get("access_token"))


if __name__ == "__main__":
    main()
