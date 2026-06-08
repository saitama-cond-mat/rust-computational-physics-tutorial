#!/usr/bin/env python3
"""mdBook preprocessor for runnable Rust code blocks.

Only code blocks marked as `rust,run` are executed. The captured standard
output is inserted into the generated book, not written back to source files.
"""

from __future__ import annotations

import json
import os
import re
import subprocess
import sys
import tempfile
from pathlib import Path
from typing import Any


FENCE_RE = re.compile(r"^(?P<indent>[ \t]{0,3})(?P<fence>`{3,}|~{3,})(?P<info>[^\r\n]*)\r?\n?$")


class SnippetError(RuntimeError):
    pass


def main() -> int:
    if len(sys.argv) >= 2 and sys.argv[1] == "supports":
        return 0

    try:
        context, book = json.load(sys.stdin)
        config = context.get("config", {}).get("preprocessor", {}).get("run-rust", {})
        timeout_seconds = int(config.get("timeout-seconds", 20))
        output_label = str(config.get("output-label", "実行結果："))
        process_book(book, timeout_seconds, output_label)
        json.dump(book, sys.stdout, ensure_ascii=False)
        return 0
    except Exception as exc:
        print(f"mdbook-run-rust: {exc}", file=sys.stderr)
        return 1


def process_book(book: dict[str, Any], timeout_seconds: int, output_label: str) -> None:
    sections = book.get("sections", book.get("items", []))
    for section in sections:
        process_book_item(section, timeout_seconds, output_label)


def process_book_item(item: dict[str, Any], timeout_seconds: int, output_label: str) -> None:
    chapter = item.get("Chapter")
    if not chapter:
        return

    chapter_name = chapter.get("name", "<unknown>")
    source_path = chapter.get("source_path") or chapter.get("path") or chapter_name
    chapter["content"] = process_content(
        chapter.get("content", ""),
        str(source_path),
        timeout_seconds,
        output_label,
    )

    for sub_item in chapter.get("sub_items", []):
        process_book_item(sub_item, timeout_seconds, output_label)


def process_content(content: str, source_path: str, timeout_seconds: int, output_label: str) -> str:
    lines = content.splitlines(keepends=True)
    output: list[str] = []
    index = 0

    while index < len(lines):
        match = FENCE_RE.match(lines[index])
        if not match:
            output.append(lines[index])
            index += 1
            continue

        fence = match.group("fence")
        info = match.group("info").strip()
        code_start_line = index + 2
        opening_line = lines[index]
        index += 1

        code_lines: list[str] = []
        closing_line: str | None = None
        while index < len(lines):
            if is_closing_fence(lines[index], fence):
                closing_line = lines[index]
                index += 1
                break
            code_lines.append(lines[index])
            index += 1

        if closing_line is None:
            output.append(opening_line)
            output.extend(code_lines)
            continue

        if not should_run(info):
            output.append(opening_line)
            output.extend(code_lines)
            output.append(closing_line)
            continue

        clean_info = info_without_run(info)
        output.append(f"{match.group('indent')}{fence}{clean_info}\n")
        output.extend(code_lines)
        output.append(closing_line)

        code = "".join(code_lines)
        stdout = run_rust_snippet(code, f"{source_path}:{code_start_line}", timeout_seconds)
        if stdout:
            output.append("\n")
            output.append(f"{output_label}\n\n")
            output.append(make_fenced_block("text", stdout))

    return "".join(output)


def is_closing_fence(line: str, opening_fence: str) -> bool:
    char = re.escape(opening_fence[0])
    min_len = len(opening_fence)
    return bool(re.match(rf"^[ \t]{{0,3}}{char}{{{min_len},}}[ \t]*\r?\n?$", line))


def should_run(info: str) -> bool:
    attrs = split_info(info)
    return ("rust" in attrs or "rs" in attrs) and "run" in attrs


def info_without_run(info: str) -> str:
    attrs = [attr for attr in split_info(info) if attr != "run"]
    return ",".join(attrs) if attrs else "rust"


def split_info(info: str) -> list[str]:
    return [part for part in re.split(r"[\s,]+", info.strip()) if part]


def run_rust_snippet(code: str, label: str, timeout_seconds: int) -> str:
    if "fn main" not in code:
        raise SnippetError(f"{label}: rust,run code block must contain fn main")

    with tempfile.TemporaryDirectory(prefix="mdbook-run-rust-") as tmp_dir:
        root = Path(tmp_dir)
        (root / "src").mkdir()
        (root / "Cargo.toml").write_text(
            "\n".join(
                [
                    "[package]",
                    'name = "mdbook_run_rust_snippet"',
                    'version = "0.0.0"',
                    'edition = "2021"',
                    "",
                ]
            ),
            encoding="utf-8",
        )
        (root / "src" / "main.rs").write_text(code, encoding="utf-8")

        env = os.environ.copy()
        env.setdefault("CARGO_TERM_COLOR", "never")
        try:
            result = subprocess.run(
                ["cargo", "run", "--quiet"],
                cwd=root,
                env=env,
                capture_output=True,
                text=True,
                timeout=timeout_seconds,
                check=False,
            )
        except subprocess.TimeoutExpired as exc:
            raise SnippetError(f"{label}: timed out after {timeout_seconds}s") from exc

    if result.returncode != 0:
        raise SnippetError(
            "\n".join(
                [
                    f"{label}: rust,run code block failed",
                    "--- stdout ---",
                    result.stdout.rstrip(),
                    "--- stderr ---",
                    result.stderr.rstrip(),
                ]
            )
        )

    if result.stderr.strip():
        print(f"mdbook-run-rust warning from {label}:\n{result.stderr.rstrip()}", file=sys.stderr)

    return result.stdout


def make_fenced_block(info: str, body: str) -> str:
    longest_backticks = max((len(match.group(0)) for match in re.finditer(r"`+", body)), default=0)
    fence = "`" * max(3, longest_backticks + 1)
    return f"{fence}{info}\n{body.rstrip()}\n{fence}\n"


if __name__ == "__main__":
    raise SystemExit(main())
