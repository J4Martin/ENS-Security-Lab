#!/usr/bin/env python3
"""Publish a reviewed complete project roadmap to NEXUS, without network or secrets.
Usage: python3 control-central/publish.py --input reviewed-tasks.json
       python3 control-central/publish.py --check
Include status.json in the same reviewed PR as the material work.
Input is an array of real tasks with stable existing IDs. Never invent completion.
"""
import argparse
import datetime
import json
import pathlib
import re
import tempfile
import os
from urllib.parse import urlsplit

PROJECT = "bug-bounty"
OUT = pathlib.Path(__file__).resolve().with_name("status.json")
ALLOWED = {"id", "title", "status", "phase", "block", "note", "evidence"}

def valid_url(value):
    if not isinstance(value, str) or len(value) > 1024:
        return False
    u = urlsplit(value)
    return u.scheme == "https" and bool(u.hostname) and not u.username and not u.password

def validate(items):
    if not isinstance(items, list) or len(items) > 300:
        raise ValueError("Expected at most 300 tasks")
    ids = set()
    for item in items:
        if not isinstance(item, dict) or set(item) - ALLOWED:
            raise ValueError("Unexpected task fields")
        key = item.get("id")
        if not isinstance(key, str) or not re.fullmatch(r"[A-Za-z0-9_.:-]{1,100}", key) or key in ids:
            raise ValueError("Invalid or duplicate task ID")
        ids.add(key)
        if item.get("status") not in {"pending", "in_progress", "blocked", "done"}:
            raise ValueError("Invalid task status")
        for field, limit in (("title", 200), ("phase", 100), ("block", 100), ("note", 300)):
            value = item.get(field, "")
            if not isinstance(value, str) or len(value) > limit or (field == "title" and not value.strip()):
                raise ValueError("Invalid task text: " + field)
        evidence = item.get("evidence")
        if evidence is not None and not valid_url(evidence):
            raise ValueError("Evidence must be HTTPS")
        if item["status"] == "done" and not valid_url(evidence):
            raise ValueError("Reported completion requires evidence")
    return items

def load(path):
    if path.stat().st_size > 140000:
        raise ValueError("Report too large")
    return json.loads(path.read_text(encoding="utf-8"))

def main():
    parser = argparse.ArgumentParser()
    group = parser.add_mutually_exclusive_group(required=True)
    group.add_argument("--input", type=pathlib.Path)
    group.add_argument("--check", action="store_true")
    args = parser.parse_args()
    if args.check:
        obj = load(OUT)
        if obj.get("version") != 2 or obj.get("projectId") != PROJECT:
            raise ValueError("Wrong project or version")
        timestamp = datetime.datetime.fromisoformat(obj["observedAt"].replace("Z", "+00:00"))
        if timestamp.tzinfo is None or timestamp > datetime.datetime.now(datetime.timezone.utc) + datetime.timedelta(minutes=5):
            raise ValueError("Invalid report timestamp")
        validate(obj["items"])
        print("NEXUS report valid:", PROJECT, len(obj["items"]), "reported tasks")
        return
    items = validate(load(args.input))
    obj = {"version": 2, "projectId": PROJECT,
           "observedAt": datetime.datetime.now(datetime.timezone.utc).isoformat().replace("+00:00","Z"),
           "items": items}
    encoded = json.dumps(obj, ensure_ascii=False, indent=2) + "\n"
    if len(encoded.encode("utf-8")) > 140000:
        raise ValueError("Report exceeds size limit")
    fd, name = tempfile.mkstemp(prefix=".nexus-report-", dir=OUT.parent)
    try:
        with os.fdopen(fd, "w", encoding="utf-8") as f:
            f.write(encoded)
        os.replace(name, OUT)
    finally:
        if os.path.exists(name):
            os.unlink(name)
    print("Updated status.json. Review diff and include it in the project PR.")

if __name__ == "__main__":
    main()
