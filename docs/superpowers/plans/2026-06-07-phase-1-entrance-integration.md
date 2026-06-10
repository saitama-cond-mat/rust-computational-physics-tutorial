# Phase 1 Entrance Integration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a minimal entrance-layer integration of AI agent era validation practices while preserving the Japanese Rust computational physics tutorial as the main book.

**Architecture:** Keep the existing `src/SUMMARY.md` chapter structure unchanged. Edit only the entrance pages and root agent instruction files, adding short guidance that frames AI agents as planning and checking aids rather than as replacements for Rust, numerical methods, or physics understanding.

**Tech Stack:** mdBook Markdown, D2 preprocessing through `mdbook-d2`, Typst math preprocessing through `mdbook-typst-math`, Rust/Cargo examples, Git.

---

## File Structure

- Modify `src/README.md`: broaden the reader profile for Rust beginners without presenting the book as a complete programming introduction, and adjust the Rust Book guidance.
- Modify `src/ch01-introduction/why-rust.md`: add one subsection on why Rust remains useful in the AI agent era.
- Modify `src/ch01-introduction/setup.md`: add an optional subsection introducing AI coding agents without tool-specific setup instructions.
- Modify `src/ch01-introduction/how-to-use.md`: add a standard AI agent workflow for computational physics tasks.
- Create `AGENTS.md`: shared repository instructions for AI coding agents.
- Create `CLAUDE.md`: thin pointer to `AGENTS.md`.

Do not modify `src/SUMMARY.md` in Phase 1. Do not start Phase 2 topics such as memory layout, matrix multiplication, Ising project completion, SIMD project completion, or GitHub/PR teaching content.

## Global Acceptance Criteria

- The book still reads as a Rust computational physics tutorial, not as an AI tool manual.
- The added agent guidance is short, optional, and tied to validation, tests, result metadata, and diff review.
- `AGENTS.md` gives concrete repository-level instructions that students and agents can understand.
- `CLAUDE.md` contains only `@AGENTS.md`.
- `mdbook build` exits 0.
- `dprint check` is run if `dprint` is installed.
- `git diff --check` exits 0.

### Task 1: Preflight And Baseline

**Files:**

- Read: `docs/refactoring/overall-design.md`
- Read: `docs/superpowers/plans/2026-06-07-phase-1-entrance-integration.md`
- Read: `src/README.md`
- Read: `src/ch01-introduction/why-rust.md`
- Read: `src/ch01-introduction/setup.md`
- Read: `src/ch01-introduction/how-to-use.md`

- [ ] **Step 1: Confirm branch and clean starting point**

Run:

```bash
git status --short --branch
```

Expected: current branch is the Phase 1 work branch chosen by the implementer, and there are no unrelated changes. If unrelated user changes exist, leave them untouched and account for them before editing.

- [ ] **Step 2: Read the design note**

Run:

```bash
sed -n '1,220p' docs/refactoring/overall-design.md
```

Expected: the Phase 1 target files and non-goals are visible.

- [ ] **Step 3: Confirm current entrance text**

Run:

```bash
sed -n '1,140p' src/README.md
sed -n '1,220p' src/ch01-introduction/why-rust.md
sed -n '1,220p' src/ch01-introduction/setup.md
sed -n '1,220p' src/ch01-introduction/how-to-use.md
```

Expected: the files match the existing style: polite Japanese prose, explanatory paragraphs, and practical command examples.

- [ ] **Step 4: Run baseline build**

Run:

```bash
mdbook build
```

Expected: exit 0. Existing warnings about mdBook preprocessor minor versions or pre-existing HTML tag balance may appear; record them but do not fix them in this phase.

- [ ] **Step 5: Commit nothing**

This task is orientation only. Do not create a commit.

### Task 2: Adjust `src/README.md`

**Files:**

- Modify: `src/README.md`

- [ ] **Step 1: Soften the Rust prerequisite paragraph**

In `## 想定読者`, replace the Rust bullet with this text:

```markdown
- **Rustの基本文法を学びながら計算物理を実装したい方**：Rustの基本文法を一通り学んだ方、または簡単なプログラミング経験があり、必要に応じてRust Bookなどを参照しながら学習を進められる方を対象とします。変数、関数、構造体、所有権、借用といった概念は本書を読み進める上で重要ですが、最初からすべてを完全に理解している必要はありません。
```

- [ ] **Step 2: Add the primary reader profile**

After the physics bullet in `## 想定読者`, add this bullet:

```markdown
- **B4/M1程度の理工系学生や研究を始める方**：微積分、線形代数、基礎的な物理学を学び、数値計算やシミュレーションを自分で実装して理解したい方を主な読者として想定します。
```

- [ ] **Step 3: Add a short AI agent era paragraph**

After the sentence ending `最適な内容です。`, add:

```markdown
AI agent を使えばコードの下書きや修正は速くなります。しかし、生成されたコードが物理的・数値的に正しいことは自動的には保証されません。本書では、Rust、数値計算、物理の基本概念を学び、生成コードや自分の実装を検査できる力を養うことも重視します。
```

- [ ] **Step 4: Rewrite the Rust Book note as reference guidance**

In the `Rustを未習得の方へ` note, replace the first paragraph after the heading with:

```markdown
Rustに初めて触れる方は、本書と並行して公式ドキュメントを必要に応じて参照してください。公式ドキュメントは非常に丁寧に記述されており、Rustの基本概念を体系的に学ぶことができます。
```

Replace the last paragraph of the same note with:

```markdown
特に、変数と可変性、所有権、構造体、列挙型、パターンマッチ、トレイトなどの章は、本書を読み進める上で重要な基礎となります。最初にすべてを読み切る必要はありませんが、コンパイルエラーや所有権の説明で立ち止まったときに戻って参照すると理解が深まります。
```

- [ ] **Step 5: Check the edited introduction**

Run:

```bash
sed -n '1,90p' src/README.md
```

Expected: the reader guidance is broader than the original but does not imply the book is for complete programming beginners. AI agent appears once in the opening reader guidance and does not dominate the introduction.

- [ ] **Step 6: Commit**

Run:

```bash
git add src/README.md
git commit -m "docs: broaden tutorial introduction"
```

Expected: commit succeeds.

### Task 3: Add AI Agent Era Rationale To `why-rust.md`

**Files:**

- Modify: `src/ch01-introduction/why-rust.md`

- [ ] **Step 1: Insert subsection after `モダンな開発環境`**

After the paragraph ending `これらの維持を強力に支援します。`, add:

```markdown
### AI agent 時代におけるRustの意義

AI coding agent は、コードの下書き、リファクタリング、テストの追加、エラーメッセージの読み解きといった作業を大きく助けます。しかし、agent が生成したコードであっても、物理モデル、数値解法、単位系、境界条件、刻み幅、乱数の扱い、保存量の確認が正しいとは限りません。

この点で、Rustの型システム、所有権、借用、明示的な可変性、そしてCargoによるビルドと`cargo test`は、生成されたコードを人間とコンパイラが検査するための足場になります。コンパイルが通ることは正しさの十分条件ではありませんが、少なくともメモリ安全性、型の不整合、データ競合の多くを早い段階で検出できます。

したがって、AI agent を利用する場合でも、Rustと計算物理の基礎を学ぶ意義は失われません。むしろ、agent の出力を評価し、必要なテストや検証を指示するために、数値計算と物理の理解がいっそう重要になります。
```

- [ ] **Step 2: Check placement**

Run:

```bash
rg -n "AI agent 時代|モダンな開発環境|他言語との比較" src/ch01-introduction/why-rust.md
```

Expected: `AI agent 時代におけるRustの意義` appears between `モダンな開発環境` and `他言語との比較`.

- [ ] **Step 3: Commit**

Run:

```bash
git add src/ch01-introduction/why-rust.md
git commit -m "docs: explain Rust in the AI agent era"
```

Expected: commit succeeds.

### Task 4: Add Optional AI Coding Agent Setup Guidance

**Files:**

- Modify: `src/ch01-introduction/setup.md`

- [ ] **Step 1: Insert optional subsection before `次のステップ`**

Before `## 次のステップ`, add:

```markdown
## AI coding agent を利用する場合

本書の演習は、Codex、OpenCodex、Claude Code などの AI coding agent と一緒に進めることもできます。ただし、これらは必須の開発環境ではありません。Rust、Cargo、rust-analyzer が使える状態であれば、本書の内容は通常のエディタとターミナルだけで学習できます。

AI coding agent を使う場合は、各ツールの最新の導入手順を公式情報で確認してください。ツールのインストール方法、料金体系、利用できるモデルは変わることがあるため、本書では詳細な手順や比較は扱いません。

AIを使って学ぶ場合、本書では単発の質問に答える Chat 型よりも、
リポジトリを読み、コードを編集し、テストを実行し、差分を説明できる
エージェント型の利用を推奨します。Chat 型はRustの文法や数値計算法の
概念を短く確認する用途には有用ですが、演習を進める標準的な補助としては
エージェント型を想定します。

agent を起動するときは、対象となるRustプロジェクトまたは本書のリポジトリのルートディレクトリで起動します。リポジトリに `AGENTS.md` のような共通指示ファイルがある場合は、その内容を読ませ、実装前に問題設定、入力、出力、境界条件、検証方法、テスト方針を確認させるとよいでしょう。
```

- [ ] **Step 2: Check optional tone**

Run:

```bash
rg -n "AI coding agent|必須の開発環境ではありません|公式情報|Chat 型|エージェント型" src/ch01-introduction/setup.md
```

Expected: the subsection says agents are optional, recommends agent-style tools for exercises, positions chat-style use as concept checking, and avoids tool-specific setup commands.

- [ ] **Step 3: Commit**

Run:

```bash
git add src/ch01-introduction/setup.md
git commit -m "docs: add optional AI coding agent setup guidance"
```

Expected: commit succeeds.

### Task 5: Add Standard Agent Workflow To `how-to-use.md`

**Files:**

- Modify: `src/ch01-introduction/how-to-use.md`

- [ ] **Step 1: Insert subsection after `コードを用いた実験の推奨`**

After the paragraph ending `本書の公式リポジトリをご参照ください。` and its following parenthetical sentence, add:

````markdown
### AI agent と一緒に進める場合

AI agent を使う場合でも、いきなり「実装して」と依頼するのではなく、計算物理の作業順序に沿って進めることが重要です。大きめの課題では、まず問題設定と検証方法を整理した note を作らせ、次に implementation plan を作らせてから実装に進むと、後から確認しやすくなります。

本書の演習では、単発の質問に答える Chat 型ではなく、リポジトリの文脈、
ファイル編集、テスト実行、diff review まで扱えるエージェント型を
推奨します。Chat 型は概念確認には使えますが、実装、検証、差分確認を
含む課題では、コードベース全体を扱えるエージェント型の方が適しています。

基本的な流れは次の通りです。

```text
問題設定
→ 入力・出力
→ 前提・境界条件
→ 数値計算法
→ データ構造
→ 関数・モジュール設計
→ テスト・検証方針
→ 実装
→ cargo test
→ 結果保存
→ diff review
→ 修正
```

agent には、関数境界と module plan を先に出させるとよいでしょう。実装後は `cargo test` を実行し、さらに `git status` と `git diff` で変更内容を確認します。「正しいですか」とだけ聞くのではなく、解析解、保存量、収束性、境界条件、乱数 seed、結果 metadata など、確認したい観点を具体的に指定してください。
````

- [ ] **Step 2: Check Markdown fence balance**

Run:

````bash
python3 - <<'PY'
from pathlib import Path
p = Path("src/ch01-introduction/how-to-use.md")
count = sum(1 for line in p.read_text().splitlines() if line.startswith("```"))
print(count)
raise SystemExit(0 if count % 2 == 0 else 1)
PY
````

Expected: command prints an even number and exits 0.

- [ ] **Step 3: Check workflow terms**

Run:

```bash
rg -n "implementation plan|cargo test|git status|git diff|metadata|Chat 型|エージェント型" src/ch01-introduction/how-to-use.md
```

Expected: all terms appear in the new subsection, with agent-style use recommended for implementation, verification, and diff review.

- [ ] **Step 4: Commit**

Run:

```bash
git add src/ch01-introduction/how-to-use.md
git commit -m "docs: add AI agent workflow guidance"
```

Expected: commit succeeds.

### Task 6: Add Shared Agent Instruction Files

**Files:**

- Create: `AGENTS.md`
- Create: `CLAUDE.md`

- [ ] **Step 1: Create `AGENTS.md`**

Create `AGENTS.md` with exactly this content:

```markdown
# Repository Instructions

This repository is a Japanese mdBook tutorial for learning computational physics with Rust.

When changing the book, preserve the existing polite Japanese explanatory style. Keep the main focus on Rust, numerical methods, and physics. AI agent guidance should be short and tied to validation, testing, result metadata, and diff review.

For code examples and exercises:

- Clarify the problem setting, inputs, outputs, boundary conditions, validation method, and test strategy before implementation.
- Prefer small functions and modules over large blocks of code in `main`.
- For one-dimensional numerical data, use `Vec<f64>` for owned data and `&[f64]` / `&mut [f64]` at function boundaries unless the surrounding text needs another type.
- Separate computation from plotting. Save results and parameters first, then plot from saved data.
- After code changes, run `cargo test` when the edited example is inside a Cargo project.
- Validate numerical results with analytic solutions, conserved quantities, convergence checks, small hand-checkable cases, or limiting cases when possible.
- Record important metadata such as parameters, random seeds, input sizes, and execution conditions.
- Review changes with `git status` and `git diff` before committing.

For book changes:

- Do not change `src/SUMMARY.md` unless the task explicitly changes the chapter structure.
- Run `mdbook build` before reporting completion.
- Run `dprint check` if `dprint` is installed.
```

- [ ] **Step 2: Create `CLAUDE.md`**

Create `CLAUDE.md` with exactly this content:

```markdown
@AGENTS.md
```

- [ ] **Step 3: Check files**

Run:

```bash
sed -n '1,220p' AGENTS.md
cat CLAUDE.md
```

Expected: `AGENTS.md` contains the shared instructions above, and `CLAUDE.md` contains only `@AGENTS.md`.

- [ ] **Step 4: Commit**

Run:

```bash
git add AGENTS.md CLAUDE.md
git commit -m "docs: add shared agent instructions"
```

Expected: commit succeeds.

### Task 7: Final Verification And Review

**Files:**

- Verify: `src/README.md`
- Verify: `src/ch01-introduction/why-rust.md`
- Verify: `src/ch01-introduction/setup.md`
- Verify: `src/ch01-introduction/how-to-use.md`
- Verify: `AGENTS.md`
- Verify: `CLAUDE.md`

- [ ] **Step 1: Run whitespace check**

Run:

```bash
git diff --check HEAD~5..HEAD
```

Expected: exit 0.

- [ ] **Step 2: Run mdBook build**

Run:

```bash
mdbook build
```

Expected: exit 0. Existing warnings unrelated to Phase 1 may appear.

- [ ] **Step 3: Run formatter check if available**

Run:

```bash
if command -v dprint >/dev/null 2>&1; then dprint check; else echo "dprint not installed"; fi
```

Expected: either `dprint check` exits 0 or the command prints `dprint not installed`.

- [ ] **Step 4: Confirm Phase 1 scope**

Run:

```bash
git diff --name-only HEAD~5..HEAD
```

Expected output contains only:

```text
AGENTS.md
CLAUDE.md
src/README.md
src/ch01-introduction/how-to-use.md
src/ch01-introduction/setup.md
src/ch01-introduction/why-rust.md
```

- [ ] **Step 5: Confirm no chapter structure change**

Run:

```bash
git diff --name-only HEAD~5..HEAD | rg '^src/SUMMARY.md$' && exit 1 || exit 0
```

Expected: exit 0.

- [ ] **Step 6: Write final commit if verification caused tracked changes**

Run:

```bash
git status --short
```

Expected: no tracked changes. If a formatter changed files, review them with `git diff`, then commit:

```bash
git add src/README.md src/ch01-introduction/why-rust.md src/ch01-introduction/setup.md src/ch01-introduction/how-to-use.md AGENTS.md CLAUDE.md
git commit -m "docs: format phase 1 entrance integration"
```

- [ ] **Step 7: Report summary**

Report:

```text
Phase 1 changed the entrance pages and shared agent instruction files only.
mdbook build: exit 0
dprint: passed or not installed
No src/SUMMARY.md change
```

Do not claim Phase 2 work was completed.
