# Function-First Samples Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Refactor tutorial Rust samples in Parts 2 and 3 so the computation is shown as functions first, while `main` remains a thin usage/output example.

**Architecture:** Keep the existing Markdown chapter structure. For section pages with `fn main()`-only examples, move core computations into named functions that could live in `src/lib.rs`; keep `main` as a short driver. Add exercise guidance that asks readers to add unit tests and consult an AI agent about concrete test cases using stated verification viewpoints.

**Tech Stack:** mdBook Markdown, Rust snippets, existing `python3 tools/test_mdbook_run_rust.py`, `mdbook build`.

---

### Task 1: Update Global Exercise Guidance

**Files:**

- Modify: `src/ch05-workspace-setup/README.md`
- Modify: Part 2 and Part 3 chapter README files that already have `作業テーマ`

- [ ] **Step 1: Make the standard explicit**

In `src/ch05-workspace-setup/README.md`, state that the body examples should be read as `src/lib.rs` functions plus a thin `src/main.rs`.

- [ ] **Step 2: Clarify unit-test exercise wording**

For chapter README tables, make `ユニットテスト演習` mean: the function to test is named, while exact cases are chosen after consulting an AI agent about analytic solutions, boundary conditions, and tolerances.

### Task 2: Refactor Part 2 Samples

**Files:**

- Modify section Markdown files under `src/ch03-calculus` through `src/ch09-monte-carlo`.

- [ ] **Step 1: Refactor calculus samples**

Target files:

- `src/ch03-calculus/differentiation.md`
- `src/ch03-calculus/integration.md`
- `src/ch03-calculus/gaussian-quadrature.md`
- `src/ch03-calculus/adaptive-integration.md`

Expected pattern:

```rust
fn central_difference<F>(f: F, x: f64, h: f64) -> f64
where
    F: Fn(f64) -> f64,
{
    (f(x + h) - f(x - h)) / (2.0 * h)
}

fn main() {
    let approx = central_difference(f64::sin, 1.0, 1e-5);
    println!("{approx}");
}
```

- [ ] **Step 2: Refactor linear algebra samples**

Target files:

- `src/ch04-linear-algebra/matrix-ops.md`
- `src/ch04-linear-algebra/linear-systems.md`
- `src/ch04-linear-algebra/eigenvalue.md`
- `src/ch04-linear-algebra/sparse.md`

Keep crate-use examples concise, but move reusable calculations like residuals, matrix construction, norms, and power iteration into named functions.

- [ ] **Step 3: Refactor nonlinear, Fourier, ODE, PDE, and Monte Carlo samples**

Target files are those with `fn main()`-only blocks in:

- `src/ch05-nonlinear`
- `src/ch06-fourier`
- `src/ch07-ode`
- `src/ch08-pde`
- `src/ch09-monte-carlo`

Prioritize computation functions over I/O. Do not over-engineer example crates.

### Task 3: Refactor Remaining Part 3 Samples

**Files:**

- Modify remaining `fn main()`-only samples under `src/ch13-quantum-mechanics`.
- Review already structured examples in `src/ch10-classical-mechanics`, `src/ch11-fluid-dynamics`, and `src/ch12-statistical-mechanics` without large rewrites.

- [ ] **Step 1: Refactor quantum mechanics samples**

Target files:

- `src/ch13-quantum-mechanics/schrodinger.md`
- `src/ch13-quantum-mechanics/scattering.md`

Add named functions for Hamiltonian construction, wave-packet construction, and probability/norm calculations where applicable.

- [ ] **Step 2: Leave already structured physics examples intact**

If a file already has structs, methods, and named functions, only adjust exercise wording; do not rewrite it.

### Task 4: Verification

**Files:**

- All modified Markdown files.

- [ ] **Step 1: Scan for remaining `fn main()`-only samples**

Run a read-only code-fence scan and verify remaining `fn main()` blocks either call named functions or are trivial usage examples.

- [ ] **Step 2: Run snippet preprocessor tests**

Run: `python3 tools/test_mdbook_run_rust.py`

Expected: `Ran 2 tests` and `OK`.

- [ ] **Step 3: Run mdBook build**

Run: `mdbook build`

Expected: exit code 0. Existing unrelated HTML/SVG warnings may remain.

- [ ] **Step 4: Inspect diff**

Run: `git diff --check` and `git diff --stat`.

Expected: no whitespace errors; diff is limited to documentation/sample refactoring and plan files.
