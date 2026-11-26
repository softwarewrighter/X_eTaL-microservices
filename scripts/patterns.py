# Run with scripts/py (the uv venv .venv), never a system python.
"""The counts at the end of docs/patterns.md, made from its rows.

  scripts/py scripts/patterns.py --check   # fail when the table does not match the rows (the gate)
  scripts/py scripts/patterns.py --write   # rewrite the table from the rows

A row's status is its last column (covered, planned, FBP, later); the
Richardson sections are counted together, every other section alone.
"""
import sys
from pathlib import Path

DOC = Path(__file__).resolve().parent.parent / "docs" / "patterns.md"
STATUSES = ("covered", "planned", "FBP", "later")
HEADER = ("| Pattern", "| Family", "| Concept", "| Group", "| ---")


def count(text):
    groups, section = {}, None
    for line in text.splitlines():
        if line.startswith("## "):
            section = line[3:].strip()
            continue
        if section == "Counts" or not line.startswith("| ") or line.startswith(HEADER):
            continue
        status = line.rstrip().rstrip("|").split("|")[-1].strip()
        if status not in STATUSES:
            sys.exit(f"patterns: unknown status {status!r} in: {line}")
        group = "Richardson (with additions)" if section.startswith("Richardson") else section.split(" (")[0].split(",")[0]
        groups.setdefault(group, dict.fromkeys(STATUSES, 0))[status] += 1
    return groups


def table(groups):
    rows = ["| Group | Rows | Covered | Planned | FBP | Later |", "| ----- | ---- | ------- | ------- | --- | ----- |"]
    for g, c in groups.items():
        rows.append(f"| {g} | {sum(c.values())} | {c['covered']} | {c['planned']} | {c['FBP']} | {c['later']} |")
    return "\n".join(rows) + "\n"


def main():
    text = DOC.read_text()
    head, sep, _ = text.partition("## Counts\n")
    if not sep:
        sys.exit("patterns: docs/patterns.md has no '## Counts' section")
    want = head + sep + "\n" + table(count(text))
    if "--write" in sys.argv:
        DOC.write_text(want)
        print("patterns: counts written")
    elif text != want:
        sys.exit("patterns: docs/patterns.md's counts do not match its rows (scripts/py scripts/patterns.py --write)")
    else:
        print("patterns: ok")


if __name__ == "__main__":
    main()
