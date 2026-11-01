from html.parser import HTMLParser
from pathlib import Path
import subprocess
import sys
import tempfile

class SiteParser(HTMLParser):
    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.ids = []
        self.labels = []
        self.scripts = []
        self.in_script = False
        self.script_parts = []

    def handle_starttag(self, tag, attrs):
        attrs = dict(attrs)
        if "id" in attrs:
            self.ids.append(attrs["id"])
        if tag == "label" and attrs.get("for"):
            self.labels.append(attrs["for"])
        if tag == "script" and attrs.get("src") is None:
            self.in_script = True
            self.script_parts = []

    def handle_endtag(self, tag):
        if tag == "script" and self.in_script:
            self.scripts.append("".join(self.script_parts))
            self.in_script = False

    def handle_data(self, data):
        if self.in_script:
            self.script_parts.append(data)

def fail(message):
    print(f"FAIL: {message}")
    sys.exit(1)

html_path = Path("index.html")
if not html_path.is_file():
    fail("index.html is missing")

source = html_path.read_text(encoding="utf-8")
parser = SiteParser()
try:
    parser.feed(source)
    parser.close()
except Exception as error:
    fail(f"HTML parsing failed: {error}")

duplicates = sorted({value for value in parser.ids if parser.ids.count(value) > 1})
if duplicates:
    fail("duplicate HTML id values: " + ", ".join(duplicates))

required_ids = {
    "quote", "new-quote", "save-quote", "share-quote",
    "saved-quotes-list", "community-quote-form", "quote-request-form",
    "theme-toggle", "challenge", "mood-response",
}
missing = sorted(required_ids - set(parser.ids))
if missing:
    fail("required site elements are missing: " + ", ".join(missing))

missing_label_targets = sorted(set(parser.labels) - set(parser.ids))
if missing_label_targets:
    fail("labels point to missing elements: " + ", ".join(missing_label_targets))

if not parser.scripts:
    fail("no inline application script was found")

for number, script in enumerate(parser.scripts, start=1):
    with tempfile.NamedTemporaryFile("w", suffix=".js", encoding="utf-8") as temp:
        temp.write(script)
        temp.flush()
        result = subprocess.run(
            ["node", "--check", temp.name],
            capture_output=True,
            text=True,
        )
    if result.returncode:
        fail(f"inline JavaScript block {number} has a syntax error:\n{result.stderr}")

print("AirLeo checks passed: unique IDs, required features, label targets, and JavaScript syntax.")
