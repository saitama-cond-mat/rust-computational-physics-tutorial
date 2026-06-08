#!/usr/bin/env python3
from __future__ import annotations

import json
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path


SCRIPT = Path(__file__).with_name("mdbook_run_rust.py")


class MdbookRunRustTest(unittest.TestCase):
    def test_inserts_stdout_for_run_block(self) -> None:
        content = "\n".join(
            [
                "before",
                "",
                "```rust,run",
                "fn main() {",
                '    println!("hello");',
                "}",
                "```",
                "",
                "after",
                "",
            ]
        )
        output = run_preprocessor(content)

        self.assertIn("```rust\nfn main()", output)
        self.assertIn("実行結果：\n\n```text\nhello\n```", output)
        self.assertIn("\nafter\n", output)

    def test_leaves_plain_rust_block_unchanged(self) -> None:
        content = "\n".join(
            [
                "```rust",
                "fn main() {",
                '    println!("hello");',
                "}",
                "```",
                "",
            ]
        )
        output = run_preprocessor(content)

        self.assertEqual(content, output)


def run_preprocessor(content: str) -> str:
    with tempfile.TemporaryDirectory() as root:
        payload = [
            {
                "root": root,
                "config": {
                    "preprocessor": {
                        "run-rust": {
                            "timeout-seconds": 20,
                            "output-label": "実行結果：",
                        }
                    }
                },
            },
            {
                "items": [
                    {
                        "Chapter": {
                            "name": "Test",
                            "content": content,
                            "source_path": "test.md",
                            "sub_items": [],
                        }
                    }
                ]
            },
        ]
        result = subprocess.run(
            [sys.executable, str(SCRIPT)],
            input=json.dumps(payload),
            capture_output=True,
            text=True,
            check=True,
        )
    book = json.loads(result.stdout)
    return book["items"][0]["Chapter"]["content"]


if __name__ == "__main__":
    unittest.main()
