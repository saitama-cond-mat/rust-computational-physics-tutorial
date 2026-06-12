#!/usr/bin/env python3
from __future__ import annotations

import re
import subprocess
import unittest
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]

BUILD_TOOLS = {
    "cargo:mdbook",
    "cargo:mdbook-typst-math",
    "cargo:mdbook-last-changed",
    "cargo:pagefind",
}

CHECK_TOOLS = {
    "cargo:dprint",
    "cargo:lychee",
}

LOCAL_ONLY_TOOLS = {
    "cargo:miniserve",
}


class CiWorkflowTest(unittest.TestCase):
    def test_mise_tool_versions_are_pinned(self) -> None:
        mise_toml = (ROOT / "mise.toml").read_text(encoding="utf-8")

        self.assertNotIn('"latest"', mise_toml)
        self.assertNotIn('version = "latest"', mise_toml)

    def test_check_does_not_run_on_main_push(self) -> None:
        check_workflow = (ROOT / ".github/workflows/check.yml").read_text(encoding="utf-8")

        self.assertNotRegex(check_workflow, r"(?m)^  push:")

    def test_deploy_installs_only_book_build_tools(self) -> None:
        install_args = install_args_for(ROOT / ".github/workflows/deploy.yml")

        self.assertEqual(BUILD_TOOLS, install_args)
        self.assertTrue(LOCAL_ONLY_TOOLS.isdisjoint(install_args))
        self.assertTrue(CHECK_TOOLS.isdisjoint(install_args))

    def test_check_installs_book_build_and_check_tools(self) -> None:
        install_args = install_args_for(ROOT / ".github/workflows/check.yml")

        self.assertEqual(BUILD_TOOLS | CHECK_TOOLS, install_args)
        self.assertTrue(LOCAL_ONLY_TOOLS.isdisjoint(install_args))

    def test_workflows_cache_cargo_install_artifacts_with_rust_cache(self) -> None:
        for workflow in [".github/workflows/check.yml", ".github/workflows/deploy.yml"]:
            with self.subTest(workflow=workflow):
                text = (ROOT / workflow).read_text(encoding="utf-8")

                self.assertIn("CARGO_TARGET_DIR", text)
                self.assertIn("jdx/mise-action@v4", text)
                self.assertIn("Swatinem/rust-cache@v2", text)
                self.assertIn("cache-all-crates: true", text)
                self.assertIn("${{ hashFiles('mise.toml') }}", text)
                self.assertIn("MISE_FETCH_REMOTE_VERSIONS_TIMEOUT", text)

        check_text = (ROOT / ".github/workflows/check.yml").read_text(encoding="utf-8")
        deploy_text = (ROOT / ".github/workflows/deploy.yml").read_text(encoding="utf-8")
        self.assertIn("mise-v1-${{ runner.os }}-check-", check_text)
        self.assertIn("mise-v1-${{ runner.os }}-deploy-", deploy_text)

    def test_root_manifest_allows_rust_cache_metadata(self) -> None:
        cargo_toml = (ROOT / "Cargo.toml").read_text(encoding="utf-8")

        self.assertIn('name = "rust-computational-physics-tutorial-ci"', cargo_toml)
        self.assertIn('path = "tools/ci_tool_cache.rs"', cargo_toml)
        subprocess.run(
            ["cargo", "metadata", "--all-features", "--format-version", "1", "--no-deps"],
            cwd=ROOT,
            check=True,
            capture_output=True,
            text=True,
        )


def install_args_for(path: Path) -> set[str]:
    text = path.read_text(encoding="utf-8")
    match = re.search(r"install_args:\s*>-\n(?P<body>(?:\s{12}\S.*\n?)+)", text)
    if match is None:
        raise AssertionError(f"{path} does not define a folded install_args block")
    return set(match.group("body").split())


if __name__ == "__main__":
    unittest.main()
