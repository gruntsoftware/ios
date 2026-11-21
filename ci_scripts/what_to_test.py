#!/usr/bin/env python3
"""Write TestFlight "What to Test" notes for a daily develop build.

TestFlight Build runs once a day (02:00 Europe/London, set in App Store Connect), so one
build can hold many merged PRs. This lists each PR merged to the branch since the previous
scheduled build: its title, then a one- or two-sentence summary taken from the merge commit.
The notes are capped at MAX_CHARS.

Usage (ci_post_xcodebuild.sh runs it on archive):
  python3 what_to_test.py --repo <path> --out <file> [--ref HEAD] [--build N] [--branch develop]

The window starts at the last scheduled time at or before the built commit, so a scheduled
build lists what was merged since the previous one, and a manual build lists what was merged
since the most recent scheduled build. SCHEDULE_HOUR/SCHEDULE_MINUTE/SCHEDULE_TZ must match the
workflow's schedule in App Store Connect; WHAT_TO_TEST_SINCE (any git date, e.g. "2 days ago")
overrides the window.
"""

import argparse
import datetime as dt
import os
import re
import subprocess
from zoneinfo import ZoneInfo

MAX_CHARS = 3000
SUMMARY_MAX = 240
SCHEDULE_HOUR = int(os.environ.get("WHAT_TO_TEST_SCHEDULE_HOUR", "2"))
SCHEDULE_MINUTE = int(os.environ.get("WHAT_TO_TEST_SCHEDULE_MINUTE", "0"))
SCHEDULE_TZ = os.environ.get("WHAT_TO_TEST_SCHEDULE_TZ", "Europe/London")

TRAILER = re.compile(r"^(Co-authored-by|Signed-off-by|Triggered by):", re.I)
SKIP_SUBJECT = re.compile(r"\[(skip ci|ci skip)\]", re.I)
MERGE_PR = re.compile(r"^Merge pull request #(\d+) from (\S+)")
SENTENCE_END = re.compile(r"(?<=[.!?])\s+(?=[A-Z0-9\"'(])")


def git(repo, *args, check=True):
    out = subprocess.run(["git", "-C", repo, *args], capture_output=True, text=True)
    if check and out.returncode != 0:
        raise RuntimeError(f"git {' '.join(args)} failed: {out.stderr.strip()}")
    return out.stdout


def window_start(repo, ref):
    """The last scheduled build time at or before the built commit, as an ISO string."""
    if os.environ.get("WHAT_TO_TEST_SINCE"):
        return os.environ["WHAT_TO_TEST_SINCE"], os.environ["WHAT_TO_TEST_SINCE"]
    tz = ZoneInfo(SCHEDULE_TZ)
    head_time = dt.datetime.fromtimestamp(int(git(repo, "log", "-1", "--format=%ct", ref).strip()), tz)
    start = head_time.replace(hour=SCHEDULE_HOUR, minute=SCHEDULE_MINUTE, second=0, microsecond=0)
    if start > head_time:
        start -= dt.timedelta(days=1)
    return start.isoformat(), start.strftime("%a %d %b %H:%M %Z")


def deepen(repo, branch, since):
    """Xcode Cloud clones shallowly; fetch enough history to see the window."""
    if git(repo, "rev-parse", "--is-shallow-repository", check=False).strip() != "true":
        return
    since_day = since[:10] if re.match(r"\d{4}-\d{2}-\d{2}", since) else since
    for args in (["--shallow-since", since_day], ["--deepen", "200"]):
        if subprocess.run(["git", "-C", repo, "fetch", "-q", *args, "origin", branch],
                          capture_output=True).returncode == 0:
            break
    # One more step so the window's oldest commit has its parent (for merge-commit summaries).
    subprocess.run(["git", "-C", repo, "fetch", "-q", "--deepen", "20", "origin", branch],
                   capture_output=True)


def clean_lines(body):
    return [l.rstrip() for l in body.splitlines() if not TRAILER.match(l.strip())]


def first_sentences(text, n=2):
    text = re.sub(r"\s+", " ", text).strip()
    return " ".join(SENTENCE_END.split(text)[:n])


def summarize_body(lines, title):
    """One or two sentences from a squash commit body."""
    lines = [l for l in lines if l.strip() != "-" * len(l.strip()) or not l.strip()]
    # Squash of several commits: "* Subject" lines, one per commit. Use their subjects.
    starred = [l[2:].strip() for l in lines if l.startswith("* ")]
    starred = drop_title([s for s in starred if not SKIP_SUBJECT.search(s)], title)
    if starred:
        picked = starred[:2]
        text = ". ".join(s.rstrip(".") for s in picked) + "."
        if len(starred) > 2:
            text += f" (+{len(starred) - 2} more)"
        return text
    # A bullet list ("- ..."): the first two bullets, each joined with its wrapped lines.
    bullets, current = [], None
    for l in lines:
        if l.startswith("- "):
            current = [l[2:].strip()]
            bullets.append(current)
        elif current is not None and l.startswith("  ") and l.strip():
            current.append(l.strip())
        elif not l.strip():
            current = None
    if bullets:
        return " ".join(first_sentences(" ".join(b), 1) for b in bullets[:2])
    # Prose: the first two sentences of the first paragraph.
    paragraph = []
    for l in lines:
        if l.strip():
            paragraph.append(l.strip())
        elif paragraph:
            break
    return first_sentences(" ".join(paragraph))


def norm(text):
    return re.sub(r"[^a-z0-9]+", " ", re.sub(r"\(#\d+\)\s*$", "", text.lower())).strip()


def drop_title(subjects, title):
    """Drop commit subjects that only repeat the PR title."""
    return [s for s in subjects if norm(s) != norm(title)]


def truncate(text, limit):
    text = text.strip()
    if len(text) <= limit:
        return text
    return text[: limit - 1].rsplit(" ", 1)[0].rstrip(",;:") + "…"


def collect(repo, ref, since):
    fmt = "%H%x1f%P%x1f%s%x1f%b%x1e"
    raw = git(repo, "log", "--first-parent", f"--since={since}", f"--format={fmt}", ref)
    entries = []
    for record in filter(None, (r.strip("\n") for r in raw.split("\x1e"))):
        sha, parents, subject, body = (record.split("\x1f") + [""] * 4)[:4]
        if SKIP_SUBJECT.search(subject):
            continue
        lines = clean_lines(body)
        merge = MERGE_PR.match(subject)
        if merge:
            # "Merge pull request #N from branch": the body's first line is the PR title, and the
            # summary comes from the subjects of the commits the PR brought in.
            title_line = next((l.strip() for l in lines if l.strip()), merge.group(2))
            title = f"{title_line} (#{merge.group(1)})"
            p = parents.split()
            subjects = []
            if len(p) == 2:
                subjects = [s for s in git(repo, "log", "--no-merges", "--format=%s",
                                           f"{p[0]}..{p[1]}", check=False).splitlines()
                            if s.strip() and not SKIP_SUBJECT.search(s)]
            subjects = drop_title(subjects[::-1], title)
            summary = ". ".join(s.rstrip(".") for s in subjects[:2]) + "." if subjects else ""
        else:
            title = subject.strip()
            summary = summarize_body(lines, title)
        entries.append((title, truncate(summary, SUMMARY_MAX) if summary else ""))
    return entries


def render(entries, since_label, footer):
    header = f"Changes merged to develop since {since_label}:"
    if not entries:
        return f"No changes were merged to develop since {since_label}.\n\n{footer}\n"
    blocks = []
    for title, summary in entries:
        blocks.append(f"• {truncate(title, 200)}" + (f"\n  {summary}" if summary else ""))
    # Keep whole entries until the next one would push past MAX_CHARS (leaving room for the
    # "and N more" line and the footer).
    kept, used = [], len(header) + len(footer) + 60
    for block in blocks:
        if used + len(block) + 2 > MAX_CHARS:
            break
        kept.append(block)
        used += len(block) + 2
    body = "\n\n".join(kept)
    if len(kept) < len(blocks):
        body += f"\n\n…and {len(blocks) - len(kept)} more (see the develop history)."
    return f"{header}\n\n{body}\n\n{footer}\n"


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--repo", required=True)
    ap.add_argument("--out", required=True)
    ap.add_argument("--ref", default="HEAD")
    ap.add_argument("--build", default="?")
    ap.add_argument("--branch", default="develop")
    a = ap.parse_args()

    since, since_label = window_start(a.repo, a.ref)
    deepen(a.repo, a.branch, since)
    entries = collect(a.repo, a.ref, since)
    short = git(a.repo, "rev-parse", "--short=7", a.ref).strip()
    footer = f"Build {a.build} · {a.branch} @ {short}"
    notes = render(entries, since_label, footer)
    os.makedirs(os.path.dirname(a.out), exist_ok=True)
    with open(a.out, "w", encoding="utf-8") as f:
        f.write(notes)
    print(notes)


if __name__ == "__main__":
    main()
