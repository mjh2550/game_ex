import json
import os
import threading
from http import HTTPStatus
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path
from urllib.parse import parse_qs, urlparse


WEB_ROOT = Path(os.environ.get("WEB_ROOT", "/app/web")).resolve()
SCORES_FILE = Path(os.environ.get("SCORES_FILE", "/data/scores.json")).resolve()
MAX_RECORDS = int(os.environ.get("MAX_SCORE_RECORDS", "1000"))
SCORES_LOCK = threading.Lock()


def _sort_key(record):
    return (-int(record.get("score", 0)), record.get("playedAt", ""))


def _load_records():
    if not SCORES_FILE.exists():
        return []

    try:
        data = json.loads(SCORES_FILE.read_text(encoding="utf-8"))
    except (json.JSONDecodeError, OSError):
        return []

    if isinstance(data, dict):
        data = data.get("records", [])
    if not isinstance(data, list):
        return []
    return [item for item in data if isinstance(item, dict)]


def _save_records(records):
    SCORES_FILE.parent.mkdir(parents=True, exist_ok=True)
    tmp_file = SCORES_FILE.with_suffix(".tmp")
    tmp_file.write_text(
        json.dumps(records[:MAX_RECORDS], ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )
    tmp_file.replace(SCORES_FILE)


def _filtered_records(records, query):
    game_id = query.get("gameId", [""])[0]
    if game_id:
        records = [record for record in records if record.get("gameId") == game_id]

    records = sorted(records, key=_sort_key)

    raw_limit = query.get("limit", [""])[0]
    if raw_limit:
        try:
            limit = max(0, int(raw_limit))
            records = records[:limit]
        except ValueError:
            pass

    return records


class MiniGameHubHandler(SimpleHTTPRequestHandler):
    def __init__(self, *args, **kwargs):
        super().__init__(*args, directory=str(WEB_ROOT), **kwargs)

    def end_headers(self):
        self.send_header("Access-Control-Allow-Origin", "*")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, DELETE, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")
        super().end_headers()

    def do_OPTIONS(self):
        self.send_response(HTTPStatus.NO_CONTENT)
        self.end_headers()

    def do_GET(self):
        parsed = urlparse(self.path)
        if parsed.path == "/api/scores":
            self._handle_get_scores(parsed)
            return

        super().do_GET()

    def do_POST(self):
        parsed = urlparse(self.path)
        if parsed.path == "/api/scores":
            self._handle_post_score()
            return

        self.send_error(HTTPStatus.NOT_FOUND, "Not found")

    def do_DELETE(self):
        parsed = urlparse(self.path)
        if parsed.path == "/api/scores":
            self._handle_delete_scores(parsed)
            return

        self.send_error(HTTPStatus.NOT_FOUND, "Not found")

    def send_head(self):
        path = self.translate_path(self.path)
        if os.path.isdir(path):
            return super().send_head()
        if os.path.exists(path):
            return super().send_head()

        index_path = WEB_ROOT / "index.html"
        if index_path.exists():
            self.path = "/index.html"
            return super().send_head()

        return super().send_head()

    def _json_response(self, status, payload):
        body = json.dumps(payload, ensure_ascii=False).encode("utf-8")
        self.send_response(status)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def _handle_get_scores(self, parsed):
        query = parse_qs(parsed.query)
        records = _filtered_records(_load_records(), query)
        self._json_response(HTTPStatus.OK, {"records": records})

    def _handle_post_score(self):
        try:
            length = int(self.headers.get("Content-Length", "0"))
            payload = json.loads(self.rfile.read(length).decode("utf-8"))
        except (ValueError, json.JSONDecodeError):
            self._json_response(HTTPStatus.BAD_REQUEST, {"error": "Invalid JSON"})
            return

        if not isinstance(payload, dict) or not payload.get("gameId"):
            self._json_response(HTTPStatus.BAD_REQUEST, {"error": "Invalid score record"})
            return

        game_id = payload["gameId"]

        with SCORES_LOCK:
            records = _load_records()
            previous_best = max(
                [
                    int(record.get("score", 0))
                    for record in records
                    if record.get("gameId") == game_id
                ],
                default=0,
            )

            records.append(payload)
            records = sorted(records, key=_sort_key)
            _save_records(records)

            game_records = [
                record for record in records if record.get("gameId") == game_id
            ]
            rank = next(
                (
                    index + 1
                    for index, record in enumerate(game_records)
                    if record.get("id") == payload.get("id")
                ),
                0,
            )

        score = int(payload.get("score", 0))
        self._json_response(
            HTTPStatus.CREATED,
            {
                "record": payload,
                "bestScore": max(previous_best, score),
                "isNewBest": score > previous_best,
                "rank": rank,
            },
        )

    def _handle_delete_scores(self, parsed):
        query = parse_qs(parsed.query)
        game_id = query.get("gameId", [""])[0]

        with SCORES_LOCK:
            if game_id:
                records = [
                    record
                    for record in _load_records()
                    if record.get("gameId") != game_id
                ]
                _save_records(records)
            else:
                _save_records([])

        self._json_response(HTTPStatus.OK, {"ok": True})


if __name__ == "__main__":
    port = int(os.environ.get("PORT", "8081"))
    server = ThreadingHTTPServer(("0.0.0.0", port), MiniGameHubHandler)
    print(f"MiniGameHub web server listening on 0.0.0.0:{port}")
    print(f"Serving static files from {WEB_ROOT}")
    print(f"Using score file {SCORES_FILE}")
    server.serve_forever()
