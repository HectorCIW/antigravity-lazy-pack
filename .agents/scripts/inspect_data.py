#!/usr/bin/env python3
"""Read-only data/file inspector for CSV, TSV, JSON, JSONL, Excel (if pandas available), and SQLite."""
from __future__ import annotations
import csv, json, os, re, sqlite3, sys
from pathlib import Path
from typing import Any

SENSITIVE_RE = re.compile(r"password|passwd|token|secret|api[_-]?key|authorization|cookie|private[_-]?key|credential", re.I)

def redact_value(key: str, value: Any) -> Any:
    if SENSITIVE_RE.search(str(key)):
        return "REDACTED"
    if isinstance(value, str):
        value = re.sub(r"sk-[A-Za-z0-9_-]{8,}", "sk-...REDACTED", value)
    return value

def print_header(path: Path) -> None:
    st = path.stat()
    print("# Data inspection")
    print(f"- File: {path}")
    print(f"- Size: {st.st_size:,} bytes")
    print(f"- Modified: {__import__('datetime').datetime.fromtimestamp(st.st_mtime).isoformat(timespec='seconds')}")
    print(f"- Extension: {path.suffix.lower() or '(none)'}")

def try_pandas(path: Path) -> bool:
    try:
        import pandas as pd  # type: ignore
    except Exception:
        return False
    ext = path.suffix.lower()
    try:
        if ext in {".csv", ".tsv", ".txt"}:
            sep = "\t" if ext == ".tsv" else None
            df = pd.read_csv(path, sep=sep, engine="python", nrows=10000)
        elif ext in {".xlsx", ".xls"}:
            df = pd.read_excel(path, nrows=1000)
        elif ext in {".json"}:
            df = pd.read_json(path)
        elif ext in {".jsonl", ".ndjson"}:
            df = pd.read_json(path, lines=True, nrows=10000)
        else:
            return False
        print(f"- Shape loaded: {df.shape[0]:,} rows x {df.shape[1]:,} columns")
        print("\n## Columns")
        for col in df.columns:
            print(f"- {col}: {df[col].dtype}")
        print("\n## Missing values")
        miss = df.isna().sum().sort_values(ascending=False)
        for col, n in miss.head(30).items():
            if int(n):
                print(f"- {col}: {int(n):,}")
        if not miss.astype(bool).any():
            print("- No missing values in loaded sample.")
        print("\n## Preview")
        safe = df.head(5).copy()
        for col in safe.columns:
            if SENSITIVE_RE.search(str(col)):
                safe[col] = "REDACTED"
            else:
                safe[col] = safe[col].map(lambda x: redact_value(str(col), x))
        print(safe.to_markdown(index=False))
        return True
    except Exception as e:
        print(f"- Pandas inspection failed: {e}")
        return False

def inspect_csv(path: Path, delimiter: str = ',') -> None:
    with path.open(newline='', encoding='utf-8', errors='replace') as f:
        sample = f.read(4096)
        f.seek(0)
        try:
            dialect = csv.Sniffer().sniff(sample)
        except Exception:
            dialect = csv.excel_tab if delimiter == '\t' else csv.excel
        reader = csv.DictReader(f, dialect=dialect)
        cols = reader.fieldnames or []
        print(f"- Columns: {len(cols)}")
        print("\n## Columns")
        for c in cols:
            print(f"- {c}")
        print("\n## Preview")
        rows = []
        for i, row in enumerate(reader):
            rows.append({k: redact_value(k, v) for k, v in row.items()})
            if i >= 4:
                break
        if rows:
            print(json.dumps(rows, ensure_ascii=False, indent=2))
        else:
            print("- No rows found.")

def inspect_json(path: Path) -> None:
    with path.open(encoding='utf-8', errors='replace') as f:
        data = json.load(f)
    print(f"- JSON root type: {type(data).__name__}")
    preview = data[:5] if isinstance(data, list) else data
    def scrub(obj):
        if isinstance(obj, dict):
            return {k: redact_value(k, scrub(v)) for k, v in obj.items()}
        if isinstance(obj, list):
            return [scrub(x) for x in obj[:5]]
        return obj
    print("\n## Preview")
    print(json.dumps(scrub(preview), ensure_ascii=False, indent=2)[:4000])

def inspect_jsonl(path: Path) -> None:
    rows = []
    with path.open(encoding='utf-8', errors='replace') as f:
        for i, line in enumerate(f):
            if not line.strip():
                continue
            try:
                rows.append(json.loads(line))
            except Exception as e:
                rows.append({"parse_error": str(e), "line": line[:200]})
            if len(rows) >= 5:
                break
    print("- JSONL preview rows: ", len(rows))
    print(json.dumps(rows, ensure_ascii=False, indent=2)[:4000])

def inspect_sqlite(path: Path) -> None:
    conn = sqlite3.connect(f"file:{path}?mode=ro", uri=True)
    try:
        cur = conn.cursor()
        cur.execute("SELECT name, type FROM sqlite_master WHERE type IN ('table','view') ORDER BY name")
        objects = cur.fetchall()
        print("\n## SQLite objects")
        for name, typ in objects:
            print(f"- {typ}: {name}")
        for name, typ in objects[:10]:
            if typ != 'table':
                continue
            print(f"\n### Table: {name}")
            cur.execute(f"PRAGMA table_info({name!r})")
            for col in cur.fetchall():
                print(f"- {col[1]}: {col[2]}")
            try:
                cur.execute(f"SELECT COUNT(*) FROM {name!r}")
                print(f"- Rows: {cur.fetchone()[0]:,}")
            except Exception:
                pass
    finally:
        conn.close()

def inspect_text(path: Path) -> None:
    print("\n## Text preview")
    with path.open(encoding='utf-8', errors='replace') as f:
        for i, line in enumerate(f):
            safe = re.sub(r"sk-[A-Za-z0-9_-]{8,}", "sk-...REDACTED", line.rstrip())
            print(f"{i+1:>4}: {safe[:500]}")
            if i >= 40:
                break

def main() -> int:
    if len(sys.argv) != 2:
        print("Usage: inspect_data.py <path>", file=sys.stderr)
        return 2
    path = Path(sys.argv[1]).expanduser()
    if not path.exists():
        print(f"Not found: {path}", file=sys.stderr)
        return 1
    if path.is_dir():
        print(f"Directory: {path}")
        for p in sorted(path.iterdir())[:100]:
            print(f"- {p.name}/" if p.is_dir() else f"- {p.name} ({p.stat().st_size:,} bytes)")
        return 0
    print_header(path)
    ext = path.suffix.lower()
    if ext in {'.csv', '.tsv', '.xlsx', '.xls', '.json', '.jsonl', '.ndjson'} and try_pandas(path):
        return 0
    if ext == '.csv': inspect_csv(path, ',')
    elif ext == '.tsv': inspect_csv(path, '\t')
    elif ext == '.json': inspect_json(path)
    elif ext in {'.jsonl', '.ndjson'}: inspect_jsonl(path)
    elif ext in {'.sqlite', '.sqlite3', '.db'}: inspect_sqlite(path)
    else: inspect_text(path)
    return 0

if __name__ == '__main__':
    raise SystemExit(main())
