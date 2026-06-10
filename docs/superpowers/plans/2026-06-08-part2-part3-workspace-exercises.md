# Part 2 and 3 Workspace Exercise Standardization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a standardized external work directory workflow and chapter-level exercise guidance across Parts 2 and 3.

**Architecture:** Add one setup chapter at the beginning of Part 2 that defines the external workspace layout, top-level agent instruction files, and per-theme Cargo project structure. Then update each Part 2 and Part 3 chapter README with a compact table that maps each topic to a work subdirectory, structured code units, a unit-test exercise, and a code-extension exercise.

**Tech Stack:** mdBook Markdown, existing `src/SUMMARY.md`, existing chapter README files, shell commands for verification.

---

### Task 1: Add The Workspace Setup Chapter

**Files:**

- Create: `src/ch05-workspace-setup/README.md`
- Modify: `src/SUMMARY.md`

- [ ] **Step 1: Create setup chapter**

Create `src/ch05-workspace-setup/README.md` with:

````markdown
# 作業用ディレクトリのセットアップ

第2部以降の演習では、教材リポジトリの外に作業用ディレクトリを作ります。
教材リポジトリは読む場所、作業用ディレクトリは実装、テスト、結果保存を行う場所として分けます。

```sh
mkdir -p ~/rust-computational-physics-work
cd ~/rust-computational-physics-work
```
````

## 標準ディレクトリ構成

作業用ディレクトリの下には、章やテーマごとにsub directoryを作ります。
各leaf directoryは、原則として独立したCargo projectにします。

```text
rust-computational-physics-work/
  AGENTS.md
  CLAUDE.md
  README.md
  calculus/
    integration/
      Cargo.toml
      src/
        lib.rs
        main.rs
      tests/
        integration_test.rs
      output/
  ode/
    euler-rk4/
  monte-carlo/
    integration/
```

## トップレベルの指示ファイル

AI coding agentを使う場合は、作業用ディレクトリのtopに`AGENTS.md`を置くことを推奨します。
Claude Codeを使う場合は、必要に応じて`CLAUDE.md`も置き、`AGENTS.md`を参照させます。

```md
# AGENTS.md

このディレクトリは rust-computational-physics-tutorial の演習用作業場所です。

- 教材リポジトリ本体は編集しない。
- 各テーマは独立したCargo projectとしてsub directoryに作る。
- 数値計算の本体は `src/lib.rs` に置く。
- 実行用コード、CSV出力、パラメータ実験は `src/main.rs` に置く。
- 小さい手計算可能なケースを `tests/` に追加する。
- `cargo test` を通してから結果を信用する。
- 生成されたCSVや画像は `output/` に置く。
```

```md
@AGENTS.md
```

## テーマごとのCargo project

各テーマでは、次の形を標準にします。

```sh
mkdir -p ~/rust-computational-physics-work/calculus/integration
cd ~/rust-computational-physics-work/calculus/integration
cargo init --bin
mkdir -p tests output
```

- `src/lib.rs`: 数値計算の本体。小さい関数に分け、テストしやすくする。
- `src/main.rs`: 実行条件の設定、CSV出力、簡単なパラメータ走査を担当する。
- `tests/`: 手計算可能な入力、既知解、保存量、再現性を確認する。
- `output/`: CSV、metadata、図などの生成物を置く。

## 演習の標準形

第2部と第3部の演習では、各テーマに対して次の2種類を基本にします。

1. **ユニットテストの追加**
   解析解、既知解、小さい格子、固定seedなどを使い、`cargo test`で確認します。
2. **コードの拡張**
   収束表のCSV出力、保存量の記録、metadataの保存、別手法との比較などを追加します。

AI coding agentに依頼する場合も、まず関数分割、入力、出力、検証方法を確認させてから実装に進みます。

````
- [ ] **Step 2: Add setup chapter to summary**

Insert this entry at the top of Part 2 in `src/SUMMARY.md`:

```markdown
- [作業用ディレクトリのセットアップ](./ch05-workspace-setup/README.md)
````

- [ ] **Step 3: Verify mdBook can see the new chapter**

Run: `mdbook build`

Expected: command exits with status 0 and includes the new chapter in the rendered book.

### Task 2: Standardize Part 2 Chapter README Guidance

**Files:**

- Modify: `src/ch03-calculus/README.md`
- Modify: `src/ch04-linear-algebra/README.md`
- Modify: `src/ch05-nonlinear/README.md`
- Modify: `src/ch06-fourier/README.md`
- Modify: `src/ch07-ode/README.md`
- Modify: `src/ch08-pde/README.md`
- Modify: `src/ch09-monte-carlo/README.md`

- [ ] **Step 1: Add or refine each chapter's `作業テーマ` table**

For each README, add a compact table with these columns:

```markdown
| テーマ | 作業ディレクトリ | 構造化するコード | ユニットテスト演習 | 拡張演習 |
| ------ | ---------------- | ---------------- | ------------------ | -------- |
```

Use chapter-specific rows. Examples:

```markdown
| 数値積分 | `calculus/integration` | `trapezoidal_rule`, `simpson_rule`, `estimate_error` | 低次多項式を解析解と比較する | 分割数ごとの誤差をCSVに出力する |
| 常微分方程式 | `ode/euler-rk4` | `euler_step`, `rk4_step`, `integrate` | 指数関数や調和振動子で刻み幅依存を確認する | エネルギーやnormをCSVに出力する |
```

- [ ] **Step 2: Keep the existing `検証と実装の観点` sections**

Where a README already has `## 検証と実装の観点`, keep it and adjust wording only if it conflicts with the new setup chapter. Do not duplicate the same explanation in every section page.

- [ ] **Step 3: Verify Part 2 links**

Run: `mdbook build`

Expected: command exits with status 0. Existing unrelated warnings may remain, but there should be no missing file error for the new setup chapter.

### Task 3: Standardize Part 3 Chapter README Guidance

**Files:**

- Modify: `src/ch10-classical-mechanics/README.md`
- Modify: `src/ch11-fluid-dynamics/README.md`
- Modify: `src/ch12-statistical-mechanics/README.md`
- Modify: `src/ch13-quantum-mechanics/README.md`

- [ ] **Step 1: Add `作業テーマ` table to each Part 3 README**

Use the same columns as Part 2:

```markdown
| テーマ | 作業ディレクトリ | 構造化するコード | ユニットテスト演習 | 拡張演習 |
| ------ | ---------------- | ---------------- | ------------------ | -------- |
```

Use physics-project rows. Examples:

```markdown
| Kepler問題 | `classical-mechanics/kepler` | `acceleration`, `energy`, `angular_momentum`, `step_verlet` | 円軌道のエネルギーと角運動量を確認する | 軌道と保存量をCSVに出力する |
| Ising model | `statistical-mechanics/ising` | `energy`, `magnetization`, `delta_energy_flip` | 小さい格子で手計算と比較する | temperature scanとmetadata保存を追加する |
```

- [ ] **Step 2: Add chapter-level verification paragraphs if absent**

For Part 3 README files, add a short `## 検証と実装の観点` section if it is missing. Keep it chapter-level and avoid rewriting individual section pages.

- [ ] **Step 3: Verify Part 3 links**

Run: `mdbook build`

Expected: command exits with status 0. Existing unrelated warnings may remain.

### Task 4: Final Verification And Diff Review

**Files:**

- All files changed in Tasks 1-3.

- [ ] **Step 1: Run Rust snippet test script**

Run: `python3 tools/test_mdbook_run_rust.py`

Expected:

```text
Ran 2 tests
OK
```

- [ ] **Step 2: Run mdBook build**

Run: `mdbook build`

Expected: command exits with status 0. Existing warnings about HTML tags in unrelated files may remain.

- [ ] **Step 3: Inspect diff**

Run: `git diff --stat && git diff -- src/SUMMARY.md src/ch05-workspace-setup/README.md src/ch03-calculus/README.md src/ch04-linear-algebra/README.md src/ch05-nonlinear/README.md src/ch06-fourier/README.md src/ch07-ode/README.md src/ch08-pde/README.md src/ch09-monte-carlo/README.md src/ch10-classical-mechanics/README.md src/ch11-fluid-dynamics/README.md src/ch12-statistical-mechanics/README.md src/ch13-quantum-mechanics/README.md`

Expected: diff only adds the workspace setup chapter, summary entry, and chapter-level workdir/exercise guidance.
