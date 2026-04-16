#!/usr/bin/env python3
"""
test_i18n_coverage.py

Informational test: audits translation coverage for every target language
in Localizable.xcstrings and prints a formatted report.

Exit codes
----------
0  All languages meet COVERAGE_WARN_PCT (default 80 %).
1  One or more languages fall below the threshold.

The threshold is intentionally set low so the job is informational and
does not block releases for small gaps, but will catch regressions where
a large batch of new English strings ships without translations.

Environment variables
---------------------
XCSTRINGS_PATH      Explicit path to Localizable.xcstrings.
                    If unset the script searches the working directory.
COVERAGE_WARN_PCT   Minimum acceptable coverage % per language (default 80).
"""

import os
import re
import sys
import json
import glob
from pathlib import Path

# ── Configuration ──────────────────────────────────────────────────────────────

DEFAULT_GLOB    = "**/brainwallet/Localizations/Localizable.xcstrings"
WARN_THRESHOLD  = float(os.environ.get("COVERAGE_WARN_PCT", "80"))

ALL_LANGUAGES: dict[str, str] = {
    "ar":      "Arabic",
    "de":      "German",
    "es-419":  "Spanish (Latin American)",
    "fa-IR":   "Farsi",
    "fr":      "French",
    "hi":      "Hindi",
    "id":      "Indonesian",
    "it":      "Italian",
    "ja":      "Japanese",
    "ko":      "Korean",
    "pa":      "Punjabi",
    "pl":      "Polish",
    "pt-BR":   "Brazilian Portuguese",
    "ru":      "Russian",
    "sv":      "Swedish",
    "tr":      "Turkish",
    "uk":      "Ukrainian",
    "zh-Hans": "Simplified Chinese",
    "zh-Hant": "Traditional Chinese",
}

# Pure format-placeholder keys are correct untranslated — exclude from totals.
PASSTHROUGH_RE = re.compile(r"^[\s%\d$@dflsS]+$")

# ANSI colours (disabled automatically when not a TTY)
USE_COLOUR = sys.stdout.isatty()
GREEN  = "\033[32m" if USE_COLOUR else ""
YELLOW = "\033[33m" if USE_COLOUR else ""
RED    = "\033[31m" if USE_COLOUR else ""
BOLD   = "\033[1m"  if USE_COLOUR else ""
RESET  = "\033[0m"  if USE_COLOUR else ""


# ── Helpers ────────────────────────────────────────────────────────────────────

def find_xcstrings(root: str) -> list[Path]:
    explicit = os.environ.get("XCSTRINGS_PATH", "").strip()
    if explicit:
        p = Path(explicit)
        if not p.exists():
            print(f"{RED}ERROR: XCSTRINGS_PATH '{explicit}' does not exist.{RESET}")
            sys.exit(1)
        return [p]
    matches = sorted(glob.glob(os.path.join(root, DEFAULT_GLOB), recursive=True))
    return [Path(m) for m in matches]


def is_translatable(key: str, entry: dict) -> bool:
    if not entry.get("shouldTranslate", True):
        return False
    stripped = key.strip()
    return bool(stripped) and not PASSTHROUGH_RE.match(stripped)


def audit_file(path: Path) -> tuple[int, list[dict]]:
    """
    Parse one xcstrings file.
    Returns (total_translatable, list of per-language result dicts).
    """
    with open(path, encoding="utf-8") as f:
        data = json.load(f)

    strings = data.get("strings", {})
    translatable_keys = [k for k, v in strings.items() if is_translatable(k, v)]
    total = len(translatable_keys)

    results = []
    for lang_code, lang_name in ALL_LANGUAGES.items():
        translated = sum(
            1 for key in translatable_keys
            if strings[key]
               .get("localizations", {})
               .get(lang_code, {})
               .get("stringUnit", {})
               .get("value", "")
               .strip()
        )
        missing  = total - translated
        pct      = (translated / total * 100) if total else 100.0
        results.append({
            "code":       lang_code,
            "name":       lang_name,
            "translated": translated,
            "missing":    missing,
            "total":      total,
            "pct":        pct,
        })

    return total, results


def colour_for(pct: float) -> str:
    if pct >= 95:
        return GREEN
    if pct >= WARN_THRESHOLD:
        return YELLOW
    return RED


def status_icon(pct: float) -> str:
    if pct >= 95:
        return "✅"
    if pct >= WARN_THRESHOLD:
        return "⚠️ "
    return "❌"


# ── Main ───────────────────────────────────────────────────────────────────────

def main():
    root = os.environ.get("GITHUB_WORKSPACE", os.getcwd())
    files = find_xcstrings(root)

    if not files:
        print(f"{RED}ERROR: No Localizable.xcstrings file found under {root}{RESET}")
        print("Set XCSTRINGS_PATH to the explicit location if the file is outside the working directory.")
        sys.exit(1)

    overall_fail = False

    for xcstrings_path in files:
        rel = xcstrings_path.relative_to(root) if xcstrings_path.is_relative_to(root) else xcstrings_path
        print(f"\n{BOLD}{'─' * 62}{RESET}")
        print(f"{BOLD}📋  i18n Coverage Report — {rel}{RESET}")
        print(f"{BOLD}{'─' * 62}{RESET}")
        print(f"  Threshold: {WARN_THRESHOLD:.0f}%   "
              f"{GREEN}✅ ≥ 95%{RESET}   "
              f"{YELLOW}⚠️  ≥ {WARN_THRESHOLD:.0f}%{RESET}   "
              f"{RED}❌ < {WARN_THRESHOLD:.0f}%{RESET}\n")

        total, results = audit_file(xcstrings_path)
        print(f"  {'Language':<28} {'Code':<10} {'Translated':>12} {'Missing':>8} {'Coverage':>9}")
        print(f"  {'─' * 28} {'─' * 10} {'─' * 12} {'─' * 8} {'─' * 9}")

        failing_langs = []
        for r in sorted(results, key=lambda x: x["pct"]):
            c   = colour_for(r["pct"])
            ico = status_icon(r["pct"])
            print(
                f"  {ico} {r['name']:<26} {r['code']:<10} "
                f"{r['translated']:>12} {r['missing']:>8} "
                f"{c}{r['pct']:>8.1f}%{RESET}"
            )
            if r["pct"] < WARN_THRESHOLD:
                failing_langs.append(r)

        # Summary
        all_translated = sum(r["translated"] for r in results)
        all_total      = total * len(results)
        overall_pct    = (all_translated / all_total * 100) if all_total else 100.0
        c = colour_for(overall_pct)
        print(f"\n  {BOLD}Overall: {c}{overall_pct:.1f}%{RESET}{BOLD} "
              f"({all_translated}/{all_total} string-language pairs){RESET}")
        print(f"  Total translatable keys: {total}")

        if failing_langs:
            overall_fail = True
            print(f"\n{RED}{BOLD}  FAIL — the following languages are below {WARN_THRESHOLD:.0f}%:{RESET}")
            for r in failing_langs:
                print(f"    • {r['name']} ({r['code']}): {r['pct']:.1f}% — {r['missing']} string(s) missing")
            print(f"\n  Run the auto-translate workflow to fix missing strings:")
            print(f"  gh workflow run auto-translate-ios.yml --ref <branch>")
        else:
            print(f"\n{GREEN}  PASS — all languages meet the {WARN_THRESHOLD:.0f}% threshold.{RESET}")

    print(f"\n{'─' * 62}\n")

    # Write a plain-text copy for the CircleCI artifact store
    artifact_path = Path("/tmp/i18n_coverage_report.txt")
    try:
        with open(artifact_path, "w", encoding="utf-8") as f:
            f.write(f"Brainwallet iOS i18n Coverage Report\n")
            f.write(f"Threshold: {WARN_THRESHOLD:.0f}%\n\n")
            for xcstrings_path in files:
                _, results = audit_file(xcstrings_path)
                f.write(f"File: {xcstrings_path}\n")
                f.write(f"{'Language':<28} {'Code':<10} {'Translated':>12} {'Missing':>8} {'Coverage':>9}\n")
                f.write(f"{'─'*28} {'─'*10} {'─'*12} {'─'*8} {'─'*9}\n")
                for r in sorted(results, key=lambda x: x["pct"]):
                    icon = "PASS" if r["pct"] >= WARN_THRESHOLD else "FAIL"
                    f.write(
                        f"[{icon}] {r['name']:<26} {r['code']:<10} "
                        f"{r['translated']:>12} {r['missing']:>8} {r['pct']:>8.1f}%\n"
                    )
    except OSError:
        pass  # Non-fatal — artifact write failure should not affect exit code

    sys.exit(1 if overall_fail else 0)


if __name__ == "__main__":
    main()
