# 全体設計メモ

このメモは、GitHub issue
[#1 教材統合案: 目次案と統合方針](https://github.com/saitama-cond-mat/rust-computational-physics-tutorial/issues/1)
の内容を、今後のリファクタリングで参照しやすい形に整理したものである。
疑似的な図ではなく、Markdown の見出しと箇条書きで章構成、横断方針、
各章に入れる観点を読むための設計メモとして置く。

## 目的

- `rust-computational-physics-tutorial` を主教材として維持する。
- `agentic_scientific_coding` 側の検証、再現性、AI agent 利用の観点を
  薄く統合する。
- 主軸はあくまで **Rustで計算物理を学ぶ本** とする。
- AI agent、Git、GitHub、再現性は独立した大テーマではなく、
  Rustで科学計算コードを書くときの作法として必要な箇所に差し込む。
- AI agent はコードを正しくしてくれる存在ではなく、note、plan、実装、
  検証、diff review を補助する道具として扱う。
- 本書では AI coding agent の利用を推奨する。ただし特定のツールを
  必須にはしない。
- AI を使って学ぶ場合は、単発の質問に答える Chat 型ではなく、
  リポジトリを読み、コードを編集し、テストを実行し、差分を説明できる
  エージェント型を標準の利用形態として扱う。

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
- Chat 型は Rust の文法や数値計算法の概念を短く確認する補助として扱い、
  本書の演習では、問題設定、実装、テスト、可視化、検証、diff review を
  行き来できるエージェント型を推奨する。
- 詳細なインストール手順、料金、ツール比較は本文に入れない。
- 「任意で使ってもよい」ではなく、「利用を推奨するが、検証責任は人間に
  残る」と書く。
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
  - Codex / OpenCode / Claude Code などの軽い案内 `[新規]`
  - Chat 型とエージェント型の使い分け `[新規]`
  - 数値計算結果の可視化 `[既存/調整]`
  - 本書の使い方 `[既存/調整]`
  - local Git / diff safety `[新規]`
- GitHub、fork、branch、merge、pull request はここでは詳しく扱わない。
- 序盤では `git status`, `git diff`, `git add`, `git commit` 程度に留める。
- compute と plot の分離、すなわち Rustで計算し、結果を保存し、
  plot は保存済みデータから作る方針を導入する。
- 表形式データは CSV と `gnuplot` を標準にする。
- 多次元配列や大きなデータは HDF5、NumPy形式（`.npy`, `.npz`）などの
  バイナリ形式を候補にする。
- `matplotlib` は複雑なデータ加工や論文用の図の補助として扱う。
- `plotters` や `three-d` は Rust だけで完結させたい場合や3D可視化が
  必要な場合の発展的な選択肢にする。
- 第1章 README は章全体の入口として薄くし、詳細は `why-rust.md`,
  `setup.md`, `plotting.md`, `how-to-use.md` に分ける。

#### 第2章 計算機の基本モデル `[新規]`

- 目的:
  - Rustに入る前に、数値計算コードが実際の計算機上でどう動くかを
    言語非依存の基礎として確認する。
  - CPU、memory、storage、latency、bandwidth、cache line、stride、
    stack、heap を、数値計算で必要な範囲に絞って扱う。
  - cache や memory bandwidth の話を、具体的なPDEやSIMD演習より前に置く。
- 分量:
  - CPU architecture の教科書にはしない。
  - 数値計算で効く直感を優先し、詳細な階層cache、TLB、NUMAなどは
    後続の性能章に回す。
- 小節案:
  - 2.1 CPU、memory、storage
    - 計算する場所
    - 実行中のデータ
    - ファイル保存との違い
  - 2.2 latency と bandwidth
    - 待ち時間
    - データを運ぶ速度
    - compute bound
    - memory bandwidth bound
  - 2.3 cache と cache line
    - cache の役割
    - cache line
    - 連続アクセスが有利な理由
  - 2.4 row-major、column-major、stride
    - 多次元データはメモリ上では1次元
    - loop order
    - 飛び飛びアクセス
  - 2.5 stack と heap
    - stack に置かれる小さい値
    - stack size の上限
    - 巨大な固定長配列は避ける
    - 大きな配列はheapに置く

#### 第3章 Rustで数値計算を書く最小セット `[新規]`

- 目的:
  - Rust Book を置き換えるのではなく、以降の計算物理コードを書くための
    Rust と数値データの最小導入に絞る。
  - `f64`、浮動小数点の最小知識、`Vec<f64>`、slice、所有権、借用を扱い、
    1次元の数値計算関数を書いて
    `cargo test` で確認できる状態を作る。
  - 第2章で見た stack、heap、メモリ上のデータ配置を、
    Rustの所有権、借用、slice の説明へ接続する。
  - 文法説明は抽象例ではなく、数値計算で使う短い関数、配列、
    テストに結びつける。
- 分量:
  - 1章として独立させるが、読了目安は 45--60 分程度に留める。
  - trait、generic、lifetime、macro、async、unsafe、concurrency は深追いしない。
  - 詳しい Rust 文法は Rust Book を必要に応じて参照する。
- 小節案:
  - 3.1 Cargo project と実行方法
    - `Cargo.toml`
    - `src/main.rs`
    - `src/lib.rs`
    - `cargo run`
    - `cargo test`
  - 3.2 数値型と浮動小数点の最小知識
    - `f64`
    - `usize`
    - 複素数と `num-complex`
    - 型推論
    - 整数と浮動小数点数の変換
    - 丸め誤差
    - `NaN` / `inf`
    - 浮動小数点比較と許容誤差
  - 3.3 変数、関数、制御構造
    - `let`
    - `mut`
    - `fn`
    - 戻り値
    - 式としてのブロック
    - `if`
    - `for`
    - range
  - 3.4 所有権、借用、可変借用
    - `Vec<f64>` が持つデータ
    - 所有権
    - 借用
    - 可変借用
  - 3.5 `Vec<f64>` と slice
    - 所有する1次元データとしての `Vec<f64>`
    - 関数境界としての `&[f64]`
    - 更新を伴う関数境界としての `&mut [f64]`
    - data ownership と function boundary
  - 3.6 `struct` と `Result`
    - parameter
    - simulation state
    - 入力不正
    - 収束失敗
    - 配列サイズ不一致
    - `panic!` してよい場合
  - 3.7 小さい単体テスト
    - `#[test]`
    - `assert!`
    - 浮動小数点の許容誤差
    - 小さい手計算可能な入力
  - 3.8 module 分割と agent に渡しやすい単位
    - `src/lib.rs`
    - `src/main.rs`
    - `src/bin/*.rs`
    - function boundary
    - module plan
    - model、algorithm、io、plot、benchmark を混ぜない。
    - diff review

#### 第4章 多次元データと配列 `[既存/調整/移植]`

- 目的:
  - 第3章では1次元データと関数境界までを扱い、第4章では多次元データ、
    memory layout、外部 array library、結果保存へ進む。
  - 第2章で見た cache line、stride、loop order の話を、
    Rustの `Vec<f64>` と `ndarray` の具体的なデータ構造へ接続する。
  - `ndarray` は本書の基本的な多次元配列 crate として扱う。
  - `tenferro-rs` のような発展的な tensor stack は、この章の必須要素には
    しない。必要なら後続の発展トピックで扱う。
  - 高精度演算は入口には重いため、付録Eへ移動する。
- 小節案:
  - 4.1 多次元配列と flattening `[既存/調整/移植]`
    - 2D field
    - linear index
    - shape
    - indexing
  - 4.2 memory layout `[移植]`
    - row-major
    - column-major
    - stride
    - contiguous access
  - 4.3 view、copy、reshape、transpose `[移植]`
    - 参照だけの操作
    - 実データをコピーする操作
    - 意図しない allocation
  - 4.4 `ndarray` 入門 `[既存/調整]`
    - `Array1`
    - `Array2`
    - shape
    - axis
    - view
    - slicing
  - 4.5 結果保存と metadata の入口 `[新規]`
    - parameter
    - input size
    - random seed
    - 実行条件
    - crate version
    - compute と plot の分離
- memory layout、`ndarray`、`tenferro-rs` の話は、第6章の matrix multiplication、
  第17章の profiling、SIMD、並列化へつなげる。

### 第2部: 数値計算手法

- 既存の第3章から第9章を基本的に保存し、章番号を2つ後ろにずらす。
- 各章の末尾に、検証、テスト、AI agent 利用時の確認点を短く足す。

#### 第5章 数値微分と数値積分 `[既存/調整]`

- 小節案:
  - 4.1 数値微分
    - 前進差分
    - 中心差分
    - 刻み幅依存
    - 丸め誤差との競合
  - 4.2 数値積分
    - 台形則
    - Simpson 則
    - `n = 0`
    - Simpson 則の偶数条件
  - 4.3 Gauss 求積法
    - 重みと節点
    - 多項式での確認
  - 4.4 適応型積分
    - 誤差推定
    - 再帰の停止条件
    - 非滑らかな関数
  - 4.5 検証と関数化
    - `trapezoidal_rule(f, a, b, n)`
    - `simpsons_rule(f, a, b, n)`
    - `estimate_error(approx, exact)`
    - `run_convergence_check(...)`

#### 第6章 線形代数 `[既存/調整]`

- 小節案:
  - 5.1 行列演算の基礎
    - vector
    - matrix
    - shape
    - indexing
  - 5.2 matrix multiplication 演習 `[新規]`
    - 素朴な三重ループ
    - 関数化
    - 行列サイズの境界条件
    - 単体テスト
    - row-major memory layout と loop order
    - 簡単な benchmark
  - 5.3 連立一次方程式
    - Gauss 消去法
    - LU 分解
    - residual
    - singular matrix
  - 5.4 固有値問題
    - 既知行列での確認
    - normalization
    - residual
  - 5.5 スパース行列
    - 表現形式
    - memory cost
    - dense との比較
  - 5.6 検証と failure mode
    - サイズ不一致
    - ill-conditioned matrix
    - 条件数
    - 既知解

#### 第7章 非線形方程式と最適化 `[既存/調整]`

- 小節案:
  - 6.1 二分法
    - bracket
    - 停止条件
    - 符号変化がない場合
  - 6.2 Newton 法
    - 導関数
    - 初期値依存
    - 発散する例
  - 6.3 多変数 Newton 法
    - Jacobian
    - linear solve
    - residual
  - 6.4 最適化
    - 最急降下法
    - 共役勾配法
    - step size
  - 6.5 収束失敗と `Result`
    - iteration limit
    - tolerance
    - error message

#### 第8章 フーリエ解析 `[既存/調整]`

- 小節案:
  - 7.1 離散 Fourier 変換
    - DFT
    - normalization
    - 周波数軸
  - 7.2 高速 Fourier 変換
    - FFT
    - 入力サイズ
    - crate 利用
  - 7.3 スペクトル解析
    - sampling interval
    - aliasing
    - window
  - 7.4 既知信号での検証
    - sine wave
    - peak frequency
    - inverse transform
  - 7.5 metadata
    - sample 数
    - sampling interval
    - normalization
    - window

#### 第9章 常微分方程式 `[既存/調整]`

- 小節案:
  - 8.1 Euler 法
    - local error
    - global error
    - stability
  - 8.2 Runge-Kutta 法
    - RK4
    - 刻み幅依存
    - 既知解との比較
  - 8.3 適応刻み幅
    - tolerance
    - step rejection
    - stiff な問題
  - 8.4 境界値問題
    - shooting method
    - 初期推定依存
  - 8.5 保存量と単位
    - energy
    - norm
    - 無次元化

#### 第10章 偏微分方程式 `[既存/調整]`

- 小節案:
  - 9.1 差分法の基礎
    - grid
    - boundary
    - stencil
  - 9.2 拡散方程式
    - explicit scheme
    - stability
    - CFL 条件
  - 9.3 波動方程式
    - time stepping
    - boundary reflection
    - energy
  - 9.4 Laplace / Poisson 方程式
    - residual
    - convergence
    - boundary condition
  - 9.5 2D field のデータ表現
    - flattening
    - indexing
    - stride
    - off-by-one

#### 第11章 モンテカルロ法 `[既存/調整]`

- 小節案:
  - 10.1 乱数生成
    - random seed
    - reproducibility
    - distribution
  - 10.2 Monte Carlo 積分
    - sample 数
    - 誤差推定
    - 既知期待値
  - 10.3 重点サンプリング
    - proposal
    - weight
    - variance reduction
  - 10.4 MCMC
    - Markov chain
    - burn-in
    - autocorrelation
  - 10.5 結果 metadata
    - seed
    - sample 数
    - 独立試行
    - 誤差棒

### 第3部: 物理シミュレーション

- 既存の第10章から第13章を基本的に保存し、章番号を2つ後ろにずらす。
- 単なるコード例ではなく、小さい研究 project として、モデル、数値計算法、
  検証、結果保存を意識させる。

#### 第12章 古典力学シミュレーション `[既存/調整]`

- 小節案:
  - 11.1 質点系の運動
    - force
    - state
    - time step
  - 11.2 シンプレクティック積分法
    - Euler 法との比較
    - energy drift
    - long-time stability
  - 11.3 Kepler 問題
    - `GM = 4π²`
    - energy
    - angular momentum
  - 11.4 分子動力学入門
    - pair potential
    - boundary
    - neighbor
  - 11.5 検証と結果保存
    - 保存量
    - 単位系
    - metadata

#### 第13章 流体力学 `[既存/調整]`

- 小節案:
  - 12.1 Navier-Stokes 方程式の基礎
    - conservation law
    - viscosity
    - pressure
  - 12.2 差分法による流体シミュレーション
    - grid
    - boundary condition
    - CFL 条件
  - 12.3 benchmark problem
    - cavity flow
    - Poiseuille flow
    - grid refinement
  - 12.4 格子 Boltzmann 法
    - lattice
    - distribution function
    - boundary
  - 12.5 field data と可視化
    - field output
    - metadata
    - plot from saved data

#### 第14章 統計力学シミュレーション `[既存/調整/AI演習]`

- 小節案:
  - 13.1 Ising model の基礎
    - spin
    - Hamiltonian
    - Boltzmann 分布
    - なぜ MCMC が必要か
  - 13.2 Metropolis 法
    - proposal
    - acceptance probability
    - detailed balance
    - `ΔE`
  - 13.3 2D Ising project `[AI演習]`
    - 周期境界条件
    - energy
    - magnetization
    - `delta_energy_flip`
    - module 分割
  - 13.4 thermalization（熱化）と measurement
    - 統計物理の文脈では、MCMC一般の burn-in よりも thermalization（熱化）という語を使う。
    - sampling interval
    - autocorrelation
    - random seed
  - 13.5 相転移と finite size effect
    - susceptibility
    - specific heat
    - Binder cumulant
    - `T_c = 2J / ln(1 + sqrt(2)) ≈ 2.269`
  - 13.6 結果保存と検証
    - 小さい格子での手計算
    - 局所 `ΔE` と全エネルギー再計算の比較
    - temperature scan
    - metadata

#### 第15章 量子力学 `[既存/調整]`

- 小節案:
  - 14.1 Schrodinger 方程式の数値解法
    - discretization
    - Hamiltonian
    - boundary
  - 14.2 1次元束縛状態
    - harmonic oscillator
    - well potential
    - eigenvalue
  - 14.3 時間発展
    - split operator
    - norm conservation
    - time step
  - 14.4 散乱問題
    - wave packet
    - potential barrier
    - boundary artifact
  - 14.5 検証と保存データ
    - normalization
    - grid spacing
    - potential
    - initial condition

### 第4部: 高度なトピック

#### 第16章 共同開発フロー `[新規]`

- 小節案:
  - 16.1 local Git の復習
    - `git status`
    - `git diff`
    - `git add`
    - `git commit`
  - 16.2 GitHub の最小導入
    - repository
    - fork
    - branch
    - push
  - 16.3 pull request
    - PR 本文
    - 何を変えたか
    - なぜ変えたか
    - どう確認したか
  - 16.4 review と修正
    - review comment
    - additional commit
    - checks
  - 16.5 共同開発で扱わないこと
    - rebase の詳細
    - 複雑な merge conflict
    - release management

#### 第17章 並列計算と性能測定 `[既存/調整/AI演習]`

- 既存の第14章を第17章へ移動・調整する。
- 現状の `src/ch14-parallel/simd.md` は、SIMD の概念、
  auto-vectorization、SoA/AoS の話としては有用だが、実践章としては
  まだ完結していない。
- SoA のサンプルでは `ParticlesSoA` に `vx` が定義されていないのに
  `update_positions` で `p.vx` を使っているため、コード例として修正が必要。
- 小節案:
  - 17.1 Rayon によるデータ並列化
    - iterator
    - parallel iterator
    - correctness first
  - 17.2 performance measurement
    - `--release`
    - 入力サイズ
    - 実行環境
    - 複数回測定
  - 17.3 profiling
    - bottleneck
    - memory bandwidth
    - compute bound
  - 17.4 SIMD と memory layout
    - auto-vectorization
    - SoA
    - AoS
    - contiguous access
  - 17.5 performance project `[AI演習]`
    - scalar baseline
    - SoA への変更
    - `cargo test` による結果一致
    - benchmark
    - CPU、Rust version、compile option
  - 17.6 並列化後の注意
    - 結果の非決定性
    - 浮動小数点和の順序依存
    - random seed
    - thread 数
  - 17.7 GPU 計算への展望
    - 本文では概念紹介に留める。

### 付録

#### 付録A 参考資料 `[既存/調整]`

- Rust Book、Rust By Example、Cargo Book、Pro Git、crate docs への導線を整理する。

#### 付録B 有用なクレート集 `[既存/調整]`

- 既存内容を保存しつつ、用途別に整理する。
- 多次元配列・tensor library として、`ndarray` と `tenferro-rs` の
  位置づけを比較して載せる。

#### 付録C デバッグとトラブルシューティング `[既存/調整]`

- compiler error、`cargo test`、agent に質問するときに渡す情報を扱う。

#### 付録D 数学的背景 `[既存]`

- 既存内容を基本保存する。

#### 付録E 高精度演算 `[既存/移動]`

- 旧第2章の「高精度演算（double-double型とxprec-rs）」を移動する。
- 小節案:
  - E.1 高精度演算が必要になる場面
    - 桁落ち
    - ill-conditioned problem
    - 長時間積分
  - E.2 double-double 型の考え方
    - 2つの `f64` による表現
    - error-free transformation の直感
  - E.3 `xprec-rs` の利用
    - crate の位置づけ
    - 基本的な使い方
  - E.4 検証と性能
    - 通常の `f64` との比較
    - 精度と実行時間の trade-off

## 各章に共通して入れる観点

各章末に、必要な範囲で短い「検証と実装の観点」を置く。

- どの既知解、保存量、極限ケース、収束性で確認できるか。
- どの計算部品を関数化し、単体テストするか。
- 結果とパラメータをどう保存するか。
- データ形式が適切か。表形式なら CSV、多次元配列や大きなデータなら
  HDF5 や NumPy形式を検討する。
- compute と plot が分離されているか。
- 表形式データの確認用 plot は、まず `gnuplot` で十分か。
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
ここでいう agent は、単発の質問に答える Chat 型ではなく、リポジトリの文脈、
ファイル編集、テスト実行、diff review まで扱えるエージェント型を想定する。
Chat 型は、Rust の文法や数値計算法の概念を短く確認する補助として使えるが、
実装を進める標準ワークフローにはしない。

1. 学生が問題設定を読む。agent に丸投げしない。
2. agent にモデル定義、計算法、検証方法を note としてまとめさせる。
3. 学生が note を読み、曖昧な点を質問して修正させる。
4. agent に implementation plan を作らせる。
5. plan には、データ構造、関数分割、テスト、保存する結果、
   metadata、実行コマンドを含める。
6. 実装する。
7. `cargo test` と小さい検証問題を通す。
8. 計算結果をファイルに保存し、plot は保存済みデータから作る。
   表形式データは CSV と `gnuplot` を基本にし、多次元配列や大きなデータは
   HDF5 や NumPy形式も検討する。
9. agent に diff と結果をレビューさせる。
10. 学生が最終的に、何を信頼できて何がまだ近似・有限サイズ効果に
    依存するかを書く。

## 非目標

- Rust Book を置き換える網羅的な Rust 文法書にはしない。
- Rust 文法導入は、以降の数値計算コードを読むための最小限に絞る。
  trait、generic、lifetime、macro、async、unsafe、concurrency の体系的な
  解説は扱わない。
- Git / GitHub の詳細な入門書にはしない。
- AI agent の操作マニュアルにはしない。
- 既存の学生チュートリアルを大きく作り直さない。
