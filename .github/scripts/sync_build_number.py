#!/usr/bin/env python3
"""Copy the latest TestFlight build number into the Xcode project.

Xcode Cloud sets each build's CFBundleVersion from its own counter and ignores the project's
CURRENT_PROJECT_VERSION, so the project falls behind TestFlight. This reads the highest build
number App Store Connect has for the app and writes it to the app target's
CURRENT_PROJECT_VERSION (Debug and Release). Targets left at 1 (the test targets) aren't touched,
and the number never goes down.

Needs an App Store Connect team API key with the Developer role (read-only access to TestFlight
builds):
  ASC_KEY_ID, ASC_ISSUER_ID, and ASC_PRIVATE_KEY (the .p8 contents) or ASC_PRIVATE_KEY_PATH

Usage:
  python sync_build_number.py --project brainwallet.xcodeproj/project.pbxproj --app-id 6444157498 [--dry-run]

Writes changed/old/new to $GITHUB_OUTPUT when it's set.
"""

import argparse
import json
import os
import re
import sys
import time
import urllib.request

import jwt  # PyJWT with the crypto extra

API = "https://api.appstoreconnect.apple.com"
VERSION_LINE = re.compile(r"(CURRENT_PROJECT_VERSION = )(\d+)(;)")


def token():
    key = os.environ.get("ASC_PRIVATE_KEY")
    if not key:
        with open(os.path.expanduser(os.environ["ASC_PRIVATE_KEY_PATH"])) as f:
            key = f.read()
    now = int(time.time())
    return jwt.encode(
        {"iss": os.environ["ASC_ISSUER_ID"], "iat": now, "exp": now + 600, "aud": "appstoreconnect-v1"},
        key,
        algorithm="ES256",
        headers={"kid": os.environ["ASC_KEY_ID"], "typ": "JWT"},
    )


def latest_build_number(app_id):
    """The highest numeric build number among the app's most recently uploaded builds."""
    url = (f"{API}/v1/builds?filter[app]={app_id}&sort=-uploadedDate&limit=20"
           "&fields[builds]=version,uploadedDate,processingState")
    req = urllib.request.Request(url, headers={"Authorization": f"Bearer {token()}"})
    try:
        with urllib.request.urlopen(req, timeout=30) as resp:
            builds = json.load(resp)["data"]
    except urllib.error.HTTPError as e:
        sys.exit(f"App Store Connect returned {e.code}: {e.read().decode()[:500]}")
    numbers = [int(b["attributes"]["version"]) for b in builds if b["attributes"]["version"].isdigit()]
    if not numbers:
        sys.exit("No numeric build numbers found in App Store Connect")
    return max(numbers)


def set_output(**values):
    path = os.environ.get("GITHUB_OUTPUT")
    if path:
        with open(path, "a") as f:
            for k, v in values.items():
                f.write(f"{k}={v}\n")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--project", required=True)
    ap.add_argument("--app-id", required=True)
    ap.add_argument("--dry-run", action="store_true")
    a = ap.parse_args()

    with open(a.project) as f:
        text = f.read()
    app_values = {int(m.group(2)) for m in VERSION_LINE.finditer(text) if int(m.group(2)) > 1}
    if not app_values:
        sys.exit(f"No app-target CURRENT_PROJECT_VERSION found in {a.project}")
    current = max(app_values)
    latest = latest_build_number(a.app_id)
    print(f"Project: {current} (values found: {sorted(app_values)}) | TestFlight: {latest}")

    if latest <= current and len(app_values) == 1:
        print("Already up to date")
        set_output(changed="false", old=current, new=current)
        return

    new = max(latest, current)
    updated = VERSION_LINE.sub(
        lambda m: m.group(0) if int(m.group(2)) <= 1 else f"{m.group(1)}{new}{m.group(3)}", text)
    lines = sum(1 for m in VERSION_LINE.finditer(text) if int(m.group(2)) > 1)
    print(f"{'Would set' if a.dry_run else 'Setting'} {lines} line(s) to {new}")
    if not a.dry_run:
        with open(a.project, "w") as f:
            f.write(updated)
    set_output(changed="true", old=current, new=new)


if __name__ == "__main__":
    main()
