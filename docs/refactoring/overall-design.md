# 全体設計メモ

このメモは、GitHub issue
[#1 教材統合案: 目次案と統合方針](https://github.com/saitama-cond-mat/rust-computational-physics-tutorial/issues/1)
の内容を、今後のリファクタリングで参照しやすい形に整理したものである。
疑似的な図ではなく、Markdown の見出しと箇条書きで章構成、横断方針、
Phase 分けを読むための設計メモとして置く。

## 目的

- `rust-computational-physics-tutorial` を主教材として維持する。
- `agentic_scientific_coding` 側の検証、再現性、AI agent 利用の観点を
  薄く統合する。
- 主軸はあくまで **Rustで計算物理を学ぶ本** とする。
- AI agent、Git、GitHub、再現性は独立した大テーマではなく、
  Rustで科学計算コードを書くときの作法として必要な箇所に差し込む。
- AI agent はコードを正しくしてくれる存在ではなく、note、plan、実装、
  検証、diff review を補助する道具として扱う。

## 参照元

- 主教材: `rust-computational-physics-tutorial`
- 統合元: `agentic_scientific_coding`
  - 公開版: <https://shinaoka.github.io/agentic_scientific_coding/>
  - GitHub: <https://github.com/shinaoka/agentic_scientific_coding>

## 凡例

- `[既存]`: 現在の学生作成チュートリアル由来。基本的に保存する。
- `[調整]`: 既存内容を大きく壊さず、前提、説明、検証観点を足す。
- `[新規]`: 統合のために新しく追加する。
- `[移植]`: `agentic_scientific_coding` 側の考え方を、本書向けに薄く移す。
- `[AI演習]`: AI agent と一緒に note、plan、実装、検証まで進める演習。

## 統合原則

- 既存の日本語資料の丁寧で説明的な文体を優先する。
- 断定的すぎる agentic coding 用語を避ける。
- 「AI agent が正しくしてくれる」ではなく、
  「Rustや計算物理の基礎を持つ人間が agent の出力を検査する」と書く。
- 詳細なインストール手順、料金、ツール比較は本文に入れない。
- 本文は当面、日本語のまま進める。
- 図のラベルや図中テキストは、基本的に英語にする。
- コード、数式、コマンド、file path、crate 名、関数名、
  図の英語ラベルは翻訳時に壊さない。
- 翻訳版を作る前に、`AI agent`, `cargo test`, `metadata`,
  `validation`, `unit test`, `memory layout` などの用語の揺れを減らす。

## 章構成案

### はじめに `[調整]`

- Rustで計算物理を実装する入門書であることを明確にする。
- 想定読者は B4/M1 程度の理工系学生とする。
- Rustの基本文法を完全に習得済みである必要はないが、簡単な
  プログラミング経験があり、Rust Book などを参照しながら進められる
  読者を想定する。
- 微積分、線形代数、基礎物理を前提とする。
- AI agent 時代でも、Rust、数値計算、物理の基本概念を知らなければ
  生成コードを評価できない、という位置づけを述べる。
- Rust Book、Rust By Example、Cargo Book は最初に全部読む前提にせず、
  必要に応じて参照する補助教材として案内する。

### 第1部: 基礎編

#### 第1章 Rustと計算物理学 `[既存/調整]`

- 既存の第1章を保存しつつ、AI agent 時代の Rust の利点を短く足す。
- Rust は agent が完璧に書けるから良いのではなく、型、所有権、借用、
  明示的な可変性、Cargo、`cargo test` によって、生成コードを人間と
  コンパイラが検査しやすいから有用、という説明にする。
- 含める内容:
  - なぜRustなのか `[既存/調整]`
  - AI agent 時代になぜ Rust か `[新規]`
  - 開発環境のセットアップ `[既存/調整]`
  - Codex / OpenCodex / Claude Code などの軽い案内 `[新規]`
  - `AGENTS.md` を共通指示にし、`CLAUDE.md` は薄い参照にする方針 `[新規]`
  - 数値計算の結果の描画 `[既存/調整]`
  - 本書の使い方 `[既存/調整]`
  - local Git / diff safety `[新規]`
- GitHub、fork、branch、merge、pull request はここでは詳しく扱わない。
- 序盤では `git status`, `git diff`, `git add`, `git commit` 程度に留める。
- compute と plot の分離、すなわち Rustで計算し、結果をファイルに保存し、
  plot は保存済みデータから作る方針を導入する。

#### 第2章 数値計算の基礎 `[既存/調整]`

- 既存の第2章を基本的に保存する。
- 追加する重点は、計算機上で数値データがどう表現・配置されるか、
  そして関数化、モジュール化、ユニットテストである。
- 含める内容:
  - 浮動小数点演算と誤差 `[既存/調整]`
  - 配列・スライス・ベクタの基礎 `[既存/調整]`
  - `Vec<f64>`, `&[f64]`, `&mut [f64]` の使い分け `[調整]`
  - memory, stack/heap, references の最小限の説明 `[移植]`
  - 多次元配列と memory layout `[移植]`
  - row-major / column-major, indexing, stride `[移植]`
  - cache, bandwidth, FLOPS の最小限の cost model `[移植]`
  - reshape / view / copy / transpose の違い `[移植]`
  - 関数化・モジュール化・ユニットテスト `[新規]`
  - Rust の error handling `[新規]`
  - 結果保存と metadata の入口 `[新規]`
  - 外部クレートの活用、`ndarray` 入門 `[既存/調整]`
  - 高精度演算 `[既存]`
- `main` に全部書かず、計算の部品を関数化し、`cargo test` で小さく確認する。
- 大きい課題では `src/lib.rs` に計算ロジック、`src/main.rs` や
  `src/bin/*.rs` に実行用 entry point を置く。
- memory layout と cache の話は、第4章の matrix multiplication、
  第15章の profiling、SIMD、並列化へつなげる。

### 第2部: 数値計算手法

- 既存の第3章から第9章を基本的に保存する。
- 各章の末尾に、検証、テスト、AI agent 利用時の確認点を短く足す。

#### 第3章 数値微分と数値積分 `[既存/調整]`

- 解析解がある関数、刻み幅依存、収束次数、境界点の扱いを確認する。
- 台形則や Simpson 則は、関数化して単体テストできる形にする。
- failure mode:
  - `n = 0`
  - Simpson 則の偶数条件
  - 区間の向き
  - 非滑らかな関数
- 関数例:
  - `trapezoidal_rule(f, a, b, n)`
  - `simpsons_rule(f, a, b, n)`
  - `estimate_error(approx, exact)`
  - `run_convergence_check(...)`

#### 第4章 線形代数 `[既存/調整]`

- 行列演算、連立一次方程式、固有値問題、スパース行列を扱う。
- 残差、条件数、既知解、データ表現を検証観点として足す。
- matrix multiplication 演習を入れる。
  - 素朴な三重ループ
  - 関数化
  - 行列サイズの境界条件
  - 単体テスト
  - row-major memory layout と loop order
  - 簡単な benchmark
- この演習を後半の cache、SIMD、並列化の導入にも使う。
- failure mode:
  - サイズ不一致
  - singular matrix
  - ill-conditioned matrix

#### 第5章 非線形方程式と最適化 `[既存/調整]`

- 二分法、Newton 法、多変数 Newton 法、最急降下法、共役勾配法を扱う。
- 初期値依存、停止条件、収束しない例を検証観点として足す。
- 収束しない場合に `Result` で返す設計を扱う。

#### 第6章 フーリエ解析 `[既存/調整]`

- DFT、FFT、スペクトル解析を扱う。
- normalization、周波数軸、aliasing、既知信号での確認を足す。
- sampling interval、sample数、window、normalization を metadata として保存する。

#### 第7章 常微分方程式 `[既存/調整]`

- Euler 法、Runge-Kutta 法、適応刻み幅、境界値問題を扱う。
- 既知解、保存量、刻み幅依存、安定性を検証する。
- step size、stiff な問題、adaptive step の許容誤差、境界値問題の初期推定依存を扱う。
- 単位と無次元化を明示する。

#### 第8章 偏微分方程式 `[既存/調整]`

- 差分法、拡散方程式、波動方程式、Laplace/Poisson 方程式を扱う。
- 境界条件、格子幅、CFL 条件、残差を検証観点として足す。
- 2D field の flattening、indexing、stride を明示する。
- off-by-one、row/column の取り違えを failure mode として扱う。

#### 第9章 モンテカルロ法 `[既存/調整]`

- 乱数生成、Monte Carlo 積分、重点サンプリング、MCMC を扱う。
- seed、誤差推定、独立試行、結果 metadata の保存を強調する。
- 既知の期待値、複数 seed、誤差が sample 数に対してどう減るかを確認する。
- sampling 不足、相関の強い sample、burn-in / thermalization 不足を扱う。

### 第3部: 物理シミュレーション

- 既存の第10章から第13章を基本的に保存する。
- 単なるコード例ではなく、小さい研究 project として、モデル、数値計算法、
  検証、結果保存を意識させる。

#### 第10章 古典力学シミュレーション `[既存/調整]`

- 質点系、シンプレクティック積分、Kepler 問題、分子動力学を扱う。
- エネルギー、角運動量、長時間安定性、積分法比較を検証観点にする。
- step size、単位系の混在、長時間 drift を failure mode として扱う。
- `GM = 4π²` のような単位系の選び方を明示する。

#### 第11章 流体力学 `[既存/調整]`

- Navier-Stokes 方程式、差分法による流体シミュレーション、
  格子 Boltzmann 法を扱う。
- 境界条件、安定性、保存量、可視化データ保存を確認する。
- benchmark problem、grid refinement、CFL 条件違反、境界条件の不整合を扱う。
- field data と metadata を保存し、plot は保存データから作る。

#### 第12章 統計力学シミュレーション `[既存/調整/AI演習]`

- Ising model、Metropolis 法、相転移と臨界現象を扱う。
- 既存本文が尻切れトンボにならないよう、2D Ising model を
  AI agent と一緒に完成させる project 演習を置く。
- 既存の `src/ch12-statistical-mechanics/ising-basics.md` は、
  モデル定義と Boltzmann 分布、MCMC への導入までは自然だが、
  そこで止まって見えやすい。
- 統合版では次の方針を明示する。
  - 入門節として割り切る場合:
    - Ising model の定義と「なぜ MCMC が必要か」までに限定する。
    - 続きは Metropolis 節へ明示的につなぐ。
  - project にする場合:
    - 2D Ising の Metropolis 実装
    - 周期境界条件
    - エネルギー差 `ΔE`
    - 磁化
    - thermalization
    - sampling interval
    - 乱数 seed
    - 誤差棒
    - finite size effect
- AI演習の流れ:
  - agent にモデル定義と計算法の note を作らせる。
  - Hamiltonian、周期境界条件、Metropolis 条件、`ΔE`、観測量を確認する。
  - agent に実装 plan を作らせる。
  - `lattice`, `model`, `metropolis`, `io` などにモジュール化する。
  - `delta_energy_flip`, energy, magnetization を単体テストする。
  - 温度スキャンを行い、susceptibility や specific heat の peak から
    相転移温度を推定する。
  - 余裕があれば Binder cumulant を使う。
  - 厳密値 `T_c = 2J / ln(1 + sqrt(2)) ≈ 2.269` と比較し、
    finite size effect、thermalization、sampling error を考察する。
- project の検証観点:
  - 小さい格子で全エネルギーと磁化を手計算と比較する。
  - spin flip の `ΔE` を局所計算と全エネルギー再計算で比較する。
  - `T` が低いと磁化が揃いやすく、高いと乱れやすいことを確認する。
  - seed、格子サイズ、温度、thermalization steps、measurement steps を
    result metadata に保存する。
  - plot は保存済みデータから作る。

#### 第13章 量子力学 `[既存/調整]`

- Schrodinger 方程式、1次元束縛状態、時間発展、散乱問題を扱う。
- 規格化、境界条件、固有値、時間発展での保存量を検証する。
- grid spacing 不足、boundary artifact、potential の単位や符号の間違いを扱う。
- grid、potential、initial condition、time step を保存する。

### 第4部: 高度なトピック

#### 第14章 共同開発フロー `[新規]`

- ここで初めて GitHub を扱う。
- local Git から GitHub へ進み、fork、branch、push、pull request を最小限学ぶ。
- 教材またはサンプル repository に小さい改善提案を出す演習を置く。
- PR 本文には、何を変えたか、なぜ変えたか、どう確認したかを書く。
- merge conflict や rebase の詳細には深入りしない。

#### 第15章 並列計算と性能測定 `[既存/調整/AI演習]`

- 既存の第14章を移動・調整する。
- Rayon、profiling、SIMD、GPU 計算への展望を扱う。
- SIMD は本文だけで無理に完結させず、performance project として扱う。
- 現状の `src/ch14-parallel/simd.md` は、SIMD の概念、
  auto-vectorization、SoA/AoS の話としては有用だが、実践章としては
  まだ完結していない。
- SoA のサンプルでは `ParticlesSoA` に `vx` が定義されていないのに
  `update_positions` で `p.vx` を使っているため、コード例として修正が必要。
- 統合版では次の方針を明示する。
  - 展望節として割り切る場合:
    - SIMD の概念
    - memory layout
    - auto-vectorization の条件
    - profiling の必要性
  - performance project にする場合:
    - scalar baseline
    - SoA への変更
    - `cargo test` による結果一致
    - benchmark
    - 環境情報
    - 入力サイズ
    - 速度比較
- AI演習の流れ:
  - agent に最適化対象の kernel と benchmark 方針の note を作らせる。
  - scalar baseline を作る。
  - AoS と SoA の違いを確認する。
  - SoA や auto-vectorization が効きやすい loop に変更する。
  - 最適化前後で結果が一致することを `cargo test` で確認する。
  - CPU、Rust version、compile option、入力サイズ、実行時間を記録する。
  - 速度改善と正しさの両方を報告する。
- benchmark の作法:
  - correctness first
  - `--release`
  - 入力サイズ
  - 実行環境
  - 複数回測定
  - 結果一致の確認
- 並列化後の注意:
  - 結果の非決定性
  - 浮動小数点和の順序依存
  - random seed と thread 数

### 付録

#### 付録A 参考資料 `[既存/調整]`

- Rust Book、Rust By Example、Cargo Book、Pro Git、crate docs への導線を整理する。

#### 付録B 有用なクレート集 `[既存/調整]`

- 既存内容を保存しつつ、用途別に整理する。

#### 付録C デバッグとトラブルシューティング `[既存/調整]`

- compiler error、`cargo test`、agent に質問するときに渡す情報を扱う。

#### 付録D 数学的背景 `[既存]`

- 既存内容を基本保存する。

## 各章に共通して入れる観点

各章末に、必要な範囲で短い「検証と実装の観点」を置く。

- どの既知解、保存量、極限ケース、収束性で確認できるか。
- どの計算部品を関数化し、単体テストするか。
- 結果とパラメータをどう保存するか。
- compute と plot が分離されているか。
- AI agent に変更させた場合、どの diff を確認すべきか。

## 関数化・モジュール化・ユニットテスト方針

- 関数化は「きれいなコード」のためだけではなく、検証可能にするために必要である。
- ユニットテストは、AI agent が生成・変更した小さい計算部品を確認する足場になる。
- モジュール化は、物理モデル、数値アルゴリズム、入出力、可視化、
  benchmark を混ぜないために使う。
- 大きい計算ほど、`main` に全部書かない。
- agent に実装を頼むときも、「まず関数境界と module plan を出して」と指示する。
- 例:
  - 数値積分:
    - `trapezoidal_rule(f, a, b, n)`
    - `simpsons_rule(f, a, b, n)`
    - `estimate_error(approx, exact)`
    - `run_convergence_check(...)`
  - Ising model project:
    - `lattice` module: spin 配置、周期境界、neighbor index
    - `model` module: energy, magnetization, `delta_energy_flip`
    - `metropolis` module: update step, thermalization, measurement
    - `io` module: result と metadata の保存
  - SIMD / performance project:
    - `baseline` module: scalar 実装
    - `soa` module: SoA 実装
    - `validate` module: 実装間の結果一致確認
    - benchmark 用 binary: 測定だけを担当し、正しさの検証は test に置く

## AI agent 演習テンプレート

Ising model や SIMD のように、本文だけで最後まで完成させると重くなる題材は、
「AI agent と一緒に完成させる project 演習」にする。

1. 学生が問題設定を読む。agent に丸投げしない。
2. agent にモデル定義、計算法、検証方法を note としてまとめさせる。
3. 学生が note を読み、曖昧な点を質問して修正させる。
4. agent に implementation plan を作らせる。
5. plan には、データ構造、関数分割、テスト、保存する結果、
   metadata、実行コマンドを含める。
6. 実装する。
7. `cargo test` と小さい検証問題を通す。
8. 計算結果をファイルに保存し、plot は保存済みデータから作る。
9. agent に diff と結果をレビューさせる。
10. 学生が最終的に、何を信頼できて何がまだ近似・有限サイズ効果に
    依存するかを書く。

## Phase 1: 入口部分の最小統合

詳細な実装計画は
[Phase 1 Entrance Integration Implementation Plan](../superpowers/plans/2026-06-07-phase-1-entrance-integration.md)
に置く。

### Phase 1 の目的

- 既存の日本語資料の文体を忠実に優先しながら、入口部分にだけ
  `agentic_scientific_coding` 由来の考え方を薄く統合する。
- 章構成を大きく変えない。
- `src/SUMMARY.md` は原則変更しない。
- 本文の主軸は **Rustで計算物理を学ぶ本** のままにする。

### Phase 1 の対象ファイル

- `src/README.md`
- `src/ch01-introduction/why-rust.md`
- `src/ch01-introduction/setup.md`
- `src/ch01-introduction/how-to-use.md`
- `AGENTS.md` 新規追加
- `CLAUDE.md` 新規追加

### Phase 1 の文体方針

- 既存本文の丁寧で説明的な日本語を優先する。
- 断定的すぎる agentic coding 用語を避ける。
- 「AI agent がコードを正しくしてくれる」ではなく、
  「Rustや計算物理の基礎を持つ人間が agent の出力を検査する」と書く。
- 詳細なインストール手順、料金、ツール比較は本文に入れない。
- 図やコマンド、crate 名、file path、関数名は英語表記のままにする。

### Phase 1 tasks

#### Task 1: `src/README.md` の導入調整

- 想定読者と本書の目的を、Rust初学者にも開く。ただし、完全な
  プログラミング未経験者向けにはしない。
- 「Rustの基本文法を習得されている方」という前提を少し緩めるが、
  Rust Book などを参照しながら進める姿勢は前提にする。
- B4/M1程度の理工系学生を主読者として明記する。
- AI agent 時代でも、Rust、数値計算、物理の基本概念が必要であることを短く追加する。
- Rust Book への導線は残すが、「事前に全部読む」ではなく
  「必要に応じて参照する補助教材」として書き換える。

#### Task 2: `why-rust.md` に AI agent 時代の Rust の意義を追加

- 「AI agent 時代になぜ Rust か」を既存の「なぜRustを用いるのか」の流れに沿って追加する。
- 主張:
  - AI agent はコード生成を速くする。
  - 生成コードの物理的・数値的な正しさは保証しない。
  - Rust の型、所有権、借用、明示的な可変性、Cargo、`cargo test` は、
    生成コードを検査する足場になる。
  - コンパイルが通っても、数式、単位、境界条件、刻み幅、乱数、
    保存量が正しいとは限らない。
  - したがって、Rustと計算物理の基礎を学ぶ必要がある。
- 置き場所候補:
  - 「モダンな開発環境」の後
  - または「Rustの主な利点」の最後

#### Task 3: `setup.md` に AI coding agent の軽い導線を追加

- Rust, Cargo, rust-analyzer の説明は既存のまま維持する。
- optional な小節として AI coding agent を紹介する。
- Codex / OpenCodex / Claude Code などを例示してよい。
- 詳細なインストール手順や価格比較はしない。
- 最新の手順は公式情報を確認すると書く。
- agent はリポジトリのルートで起動し、共通指示ファイルを読ませると説明する。

#### Task 4: `how-to-use.md` に agent 利用時の標準ワークフローを追加

- ツール操作ではなく、Rust計算物理の作業順序として説明する。
- 「いきなり実装して」と頼まないことを明記する。
- 大きめの課題では、まず note を作らせ、次に implementation plan を作らせる。
- agent に関数境界と module plan を出させることを推奨する。
- 実装後は `cargo test`, `git status`, `git diff` を確認する。
- 「正しいですか」ではなく、解析解、保存量、収束性、境界条件、
  metadata など具体的に確認させる。
- 追加する流れ:
  1. 問題設定
  2. 入力・出力
  3. 仮定・境界条件
  4. 数値計算法
  5. データ構造
  6. 関数・モジュール設計
  7. テスト・検証方針
  8. 実装
  9. `cargo test`
  10. 結果保存
  11. diff review
  12. 修正

#### Task 5: `AGENTS.md` と `CLAUDE.md` を追加

- agent に渡す共通指示を一箇所に置く。
- ツール固有ファイルで本文を重複させない。
- `AGENTS.md` に含める方針:
  - このリポジトリは Rustで計算物理を学ぶ教材である。
  - agent は、実装前に問題設定、入力、出力、境界条件、検証方法、
    テスト方針を確認する。
  - 大きいコードを一度に生成せず、関数化・モジュール化して進める。
  - 1次元数値データでは、所有データに `Vec<f64>`、関数境界に
    `&[f64]` / `&mut [f64]` を使うことを基本とする。
  - コード変更後は `cargo test` を実行し、必要なら解析解、保存量、
    収束性、極限ケースで検証する。
  - 結果とパラメータを保存し、描画は保存済みデータから行う。
  - 変更後は diff を確認する。
- `CLAUDE.md` は次だけにする。

```markdown
@AGENTS.md
```

#### Task 6: 検証

- コマンド:
  - `mdbook build`
  - `dprint check` が利用可能であれば実行する。
- 手動確認:
  - `src/README.md` から第1章への流れが自然か。
  - `why-rust.md` の追加小節が既存の文体と合っているか。
  - `setup.md` が agent ツールの詳細説明になっていないか。
  - `how-to-use.md` が長すぎないか。
  - `AGENTS.md` が実装を丸投げしない指示になっているか。
  - `git diff` を読み、既存資料の文体を壊していないか確認する。

### Phase 1 の非目標

- `src/SUMMARY.md` の章構成変更。
- 第2章以降の memory / cache / unit test 追加。
- matrix multiplication 演習の実装。
- Ising model project の実装。
- SIMD / performance project の実装。
- GitHub / PR / 共同開発フローの本文追加。
- 英語版・中国語版の作成。

## Phase 2 以降の主な作業

- 第2章に memory layout、関数化、モジュール化、unit test を追加する。
- 第4章に matrix multiplication の検証・benchmark 演習を追加する。
- 第12章の Ising model を project exercise として完結させる。
- 第14章に共同開発フローを新規追加する。
- 既存の第14章並列計算を第15章へ移動・調整する。
- 第15章で SIMD/performance project を扱う。
- GitHub/PR は後半の共同開発フローとして扱う。

## レビューしたい点

- 0章を作らず、第1章に統合する方針でよいか。
- `why-rust.md` に「AI agent 時代になぜ Rust か」を入れるのは自然か。
- Codex / OpenCodex / Claude Code などの導線を `setup.md` に軽く入れる方針でよいか。
- 関数化・モジュール化・ユニットテストを第2章に置く方針でよいか。
- GitHub / PR を第4部の最初に置く方針でよいか。
- Ising model と SIMD を AI agent project 演習として完成させる方針でよいか。

## 非目標

- Rust Book を置き換える網羅的な Rust 文法書にはしない。
- Git / GitHub の詳細な入門書にはしない。
- AI agent の操作マニュアルにはしない。
- 既存の学生チュートリアルを大きく作り直さない。
