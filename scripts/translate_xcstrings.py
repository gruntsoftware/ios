#!/usr/bin/env python3
"""
translate_xcstrings.py

Finds all Localizable.xcstrings files in the repo, identifies string keys
that are missing translations for any target language, batches them to the
Anthropic API, and writes the results back into the JSON file in-place.

The .xcstrings format is a single JSON file containing ALL languages:
  {
    "sourceLanguage": "en",
    "strings": {
      "Some key": {
        "comment": "optional context",
        "localizations": {
          "de": { "stringUnit": { "state": "translated", "value": "Etwas" } },
          ...
        }
      }
    },
    "version": "1.1"
  }

Environment variables
---------------------
ANTHROPIC_GH_API_KEY  – required
FORCE_RETRANSLATE     – "true" to re-translate strings that already have a value
TARGET_LANGUAGES      – comma-separated codes, e.g. "de,fr,ja"  (blank = all)
"""

import os
import re
import sys
import json
import glob
import textwrap
import anthropic
from pathlib import Path

# ── Configuration ──────────────────────────────────────────────────────────────

MODEL      = "claude-haiku-4-5-20251001"
BATCH_SIZE = 50   # string keys per API call
PR_BODY_PATH = "/tmp/pr_body.md"

# All target language codes used in Brainwallet's xcstrings files,
# mapped to the human name passed to the translation prompt.
ALL_LANGUAGES: dict[str, str] = {
    "ar":      "Arabic",
    "de":      "German",
    "es-419":  "Spanish (Latin American)",
    "fa-IR":   "Farsi (Persian)",
    "fr":      "French",
    "hi":      "Hindi",
    "id":      "Indonesian",
    "it":      "Italian",
    "ja":      "Japanese",
    "ko":      "Korean",
    "nl":      "Dutch",  
    "pa":      "Punjabi",
    "pl":      "Polish",
    "pt-BR":   "Brazilian Portuguese",
    "ru":      "Russian",
    "sv":      "Swedish",
    "th":      "Thai",
    "tr":      "Turkish",
    "uk":      "Ukrainian",
    "zh-Hans": "Simplified Chinese (Mainland China)",
    "zh-Hant": "Traditional Chinese (Taiwan)",
}

# Keys whose value is purely a format placeholder — no translation needed.
# The source text itself is the correct value for all languages.
PASSTHROUGH_PATTERN = re.compile(r"^[\s%\d$@dflsS]+$")


# ── Helpers ────────────────────────────────────────────────────────────────────

def find_xcstrings_files(root: str) -> list[Path]:
    pattern = os.path.join(root, "**", "Localizable.xcstrings")
    return [Path(p) for p in sorted(glob.glob(pattern, recursive=True))]


def load_xcstrings(path: Path) -> dict:
    with open(path, encoding="utf-8") as f:
        return json.load(f)


def save_xcstrings(data: dict, path: Path):
    """Write back with the same formatting Xcode uses.

    Xcode's String Catalog serializer puts a space before every colon
    ("key" : value), which is not json.dump's default ("key": value). Without
    matching that, every single line of the file changes on every run, even
    when the only real change is a couple of new translations.
    """
    with open(path, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2, separators=(",", " : "))


def is_passthrough(key: str, value: str) -> bool:
    """Return True for strings that should not be translated (pure placeholders)."""
    stripped = value.strip()
    if not stripped:
        return True
    if PASSTHROUGH_PATTERN.match(stripped):
        return True
    return False


def collect_missing(
    data: dict,
    lang_code: str,
    force: bool,
) -> dict[str, str]:
    """
    Return {key: english_source_text} for every string that needs a
    translation into lang_code.

    The xcstrings format has no separate "source" field per-string; the key
    itself is the English source text (Xcode default-key convention).
    """
    missing: dict[str, str] = {}
    strings = data.get("strings", {})

    for key, entry in strings.items():
        # Respect shouldTranslate: false
        if not entry.get("shouldTranslate", True):
            continue

        source_text = key  # key == English source in xcstrings

        if is_passthrough(key, source_text):
            continue

        localizations = entry.get("localizations", {})
        existing = localizations.get(lang_code, {})
        existing_value = existing.get("stringUnit", {}).get("value", "").strip()
        already_done = bool(existing_value)

        if already_done and not force:
            continue

        missing[key] = source_text

    return missing


def chunk(d: dict, size: int):
    """Yield successive sub-dicts of at most `size` items."""
    items = list(d.items())
    for i in range(0, len(items), size):
        yield dict(items[i:i + size])


# ── Translation ────────────────────────────────────────────────────────────────

def translate_batch(
    client: anthropic.Anthropic,
    lang_code: str,
    lang_name: str,
    batch: dict[str, str],
    comments: dict[str, str],
) -> dict[str, str]:
    """
    Translate a {key: english_text} batch into lang_name.
    Returns {key: translated_text}. Returns {} on failure.
    """
    # Build the payload with optional comment context
    payload = []
    for key, src in batch.items():
        item: dict = {"key": key, "english": src}
        if comments.get(key):
            item["context"] = comments[key]
        payload.append(item)

    prompt = textwrap.dedent(f"""
        You are a professional mobile-app localisation expert.

        Translate the following iOS string resource values from English into
        **{lang_name}** (locale code: {lang_code}).

        Rules:
        - Preserve ALL format placeholders EXACTLY: %@  %1$@  %2$lld  %d  etc.
        - Preserve ALL HTML/rich-text tags EXACTLY: <b>  </b>  <a href="…">  etc.
        - Preserve ALL URLs exactly — never translate them.
        - Do NOT translate the JSON "key" field — return the same key unchanged.
        - Do NOT add explanations or markdown. Return ONLY a valid JSON array.
        - The app is a Litecoin cryptocurrency wallet called "Brainwallet".
          Keep "Brainwallet", "Litecoin", "LTC", "PIN", "QR" untranslated.
        - Use natural, idiomatic language suited to a mobile finance app UI.
        - For Traditional Chinese (zh-Hant) use Taiwan conventions.
        - For Simplified Chinese (zh-Hans) use Mainland China conventions.
        - For Spanish (es-419) use Latin American conventions.
        - For Portuguese (pt-BR) use Brazilian conventions.
        - The "context" field (when present) describes where the string appears
          in the UI — use it to choose the most natural translation.

        Input JSON array:
        {json.dumps(payload, ensure_ascii=False, indent=2)}

        Return a JSON array with the same objects, replacing the "english" field
        with a "translated" field containing the {lang_name} translation.
        Example output element: {{"key": "Cancel", "translated": "Annuler"}}
    """).strip()

    try:
        message = client.messages.create(
            model=MODEL,
            max_tokens=4096,
            messages=[{"role": "user", "content": prompt}],
        )
        raw = message.content[0].text.strip()
        raw = re.sub(r"^```(?:json)?\s*", "", raw)
        raw = re.sub(r"\s*```$", "", raw)
        parsed = json.loads(raw)
        return {item["key"]: item["translated"] for item in parsed if "translated" in item}
    except Exception as exc:
        print(f"    ⚠️  API/parse error ({lang_name}): {exc}", file=sys.stderr)
        return {}


# ── Core logic ─────────────────────────────────────────────────────────────────

def process_file(
    path: Path,
    client: anthropic.Anthropic,
    target_langs: list[str],
    force: bool,
) -> list[tuple[str, int, int]]:
    """
    Process one .xcstrings file.
    Returns list of (lang_code, missing_count, translated_count) per language.
    """
    data = load_xcstrings(path)
    strings = data.get("strings", {})

    # Pre-build a comment lookup for context
    comments = {key: entry.get("comment", "") for key, entry in strings.items()}

    langs = target_langs if target_langs else list(ALL_LANGUAGES.keys())
    results = []

    for lang_code in langs:
        lang_name = ALL_LANGUAGES.get(lang_code, lang_code)
        missing = collect_missing(data, lang_code, force)

        if not missing:
            print(f"    ✔  {lang_name} ({lang_code}): nothing to translate.")
            results.append((lang_code, 0, 0))
            continue

        print(f"    🔄  {lang_name} ({lang_code}): {len(missing)} string(s) to translate …")
        translated_count = 0

        for batch in chunk(missing, BATCH_SIZE):
            batch_comments = {k: comments.get(k, "") for k in batch}
            result = translate_batch(client, lang_code, lang_name, batch, batch_comments)

            for key, translated_text in result.items():
                if key not in batch:
                    continue
                # Ensure the localizations dict exists
                if "localizations" not in strings[key]:
                    strings[key]["localizations"] = {}
                strings[key]["localizations"][lang_code] = {
                    "stringUnit": {
                        "state": "translated",
                        "value": translated_text,
                    }
                }
                translated_count += 1

        print(f"    ✅  {lang_name}: {translated_count}/{len(missing)} translated.")
        results.append((lang_code, len(missing), translated_count))

    save_xcstrings(data, path)
    return results


# ── Main ───────────────────────────────────────────────────────────────────────

def main():
    api_key = os.environ.get("ANTHROPIC_GH_API_KEY", "")
    if not api_key:
        sys.exit("ERROR: ANTHROPIC_GH_API_KEY environment variable is not set.")

    force = os.environ.get("FORCE_RETRANSLATE", "false").lower() == "true"
    lang_filter_raw = os.environ.get("TARGET_LANGUAGES", "").strip()
    target_langs = [l.strip() for l in lang_filter_raw.split(",") if l.strip()] if lang_filter_raw else []

    client = anthropic.Anthropic(api_key=api_key)

    repo_root = os.environ.get("GITHUB_WORKSPACE", os.getcwd())
    xcstrings_files = find_xcstrings_files(repo_root)

    if not xcstrings_files:
        print("No Localizable.xcstrings files found. Nothing to do.")
        return

    print(f"Found {len(xcstrings_files)} xcstrings file(s).\n")

    # PR summary table
    pr_lines = [
        "## 🌍 Auto-translation summary (iOS)\n",
        "| Language | Code | Strings added | Status |",
        "|----------|------|-------------:|--------|",
    ]

    grand_missing = 0
    grand_translated = 0

    for xcstrings_path in xcstrings_files:
        rel = xcstrings_path.relative_to(repo_root)
        print(f"📄  {rel}")
        file_results = process_file(xcstrings_path, client, target_langs, force)

        for lang_code, missing, translated in file_results:
            lang_name = ALL_LANGUAGES.get(lang_code, lang_code)
            grand_missing    += missing
            grand_translated += translated
            if missing == 0:
                status = "⏭️ Already complete"
            elif translated == missing:
                status = "✅ Complete"
            elif translated > 0:
                status = f"⚠️ Partial ({translated}/{missing})"
            else:
                status = "❌ Failed"
            if missing > 0:
                pr_lines.append(f"| {lang_name} | `{lang_code}` | {translated} | {status} |")

    pr_lines.append(f"\n**Total:** {grand_translated}/{grand_missing} strings translated")
    pr_lines.append(f"\n_Model: `{MODEL}` · Triggered by push to `{os.environ.get('GITHUB_REF_NAME', 'unknown')}`_")
    pr_lines.append("\n---\n*Generated automatically by translate_xcstrings.py*")

    Path(PR_BODY_PATH).write_text("\n".join(pr_lines) + "\n", encoding="utf-8")
    print(f"\n📄  PR body written to {PR_BODY_PATH}")
    print(f"🎉  Done. {grand_translated}/{grand_missing} strings translated.")


if __name__ == "__main__":
    main()
