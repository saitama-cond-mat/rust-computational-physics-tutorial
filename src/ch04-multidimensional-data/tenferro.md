# 発展的なテンソルライブラリ tenferro

> [!NOTE]
> **本節のポイント**
>
> - まずは `Vec<f64>`、`&[f64]`、`ndarray` を基本にする。
> - tenferro は、より高機能なテンソル計算が必要になったときの発展的な選択肢である。
> - tenferro は本書の著者の1人が開発に関わるライブラリである。
> - tenferro は単一のクレートではなく、`tenferro-tensor` や `tenferro-ad` などの
>   複数クレートからなる workspace で、crates.io に公開されている。
> - tenferro の密なテンソルは column-major（列優先）なので、`ndarray` の標準的な
>   row-major（行優先）と混同しない。
> - tenferro はまだ 0.x 版（pre-1.0）なので、使う場合は公式リポジトリとドキュメントで
>   現在のAPIを確認する。

1次元の所有データには、通常 `Vec<f64>` を使います。
関数に渡すときは、`&[f64]` や `&mut [f64]` を使うのが基本です。

2次元以上の配列を軽く扱うだけなら、`ndarray` が自然な選択肢です。
本書の多くの例でも、まず `ndarray` を使います。

tenferro は、それより発展的なテンソル計算のためのライブラリです。
ここでいうテンソルは、ベクトルや行列をさらに多次元にした数値配列だと思えば十分です。
単に2次元配列を持つためだけなら、tenferro は大きすぎる選択になりがちです。

本書で tenferro を紹介する理由の1つは、本書の著者の1人が開発に関わっているためです。
Rustで科学技術計算を発展させるときに、どのような機能が必要になり、
どこに実装上の注意があるかを考える具体例として扱います。

## どのような場合に使うか

tenferro は、次のような機能を同じ枠組みで扱いたい場合に候補になります。

- **自動微分**:
  計算式から、微分や勾配を自動的に計算する機能です。
  最適化問題や逆問題で使うことがあります。
- **GPU実行**:
  CPUではなくGPU上で大きなテンソル演算を実行します。
  ただし、CPUとGPUの間でデータを移す時間も考える必要があります。
- **テンソル縮約**:
  添字を持つ多次元配列について、ある添字に関して和を取る演算です。
  行列積もテンソル縮約の一例です。
  Python/NumPy では `einsum` という名前でよく使われます。
- **線形代数やFFTとの接続**:
  行列分解、連立方程式、フーリエ変換などをテンソル計算の流れの中で扱います。

このような機能が必要でなければ、まず `ndarray` と `ndarray-linalg` で十分かを考えます。

## クレート構成

tenferro は単一の `tenferro` クレートではありません。
`tenferro-tensor`、`tenferro-ad`、`tenferro-einsum`、`tenferro-linalg`、
`tenferro-fft`、`tenferro-cpu`、`tenferro-runtime` などの複数クレートからなる
workspace で、それぞれが crates.io に公開されています。
ルートの facade クレートは意図的に用意されておらず、
必要な層や演算を担うクレートを個別に `use` する設計です。

よく使うユーザ向けクレートは次のあたりです。

- `tenferro-tensor`: 実行時のテンソル値と backend trait。
- `tenferro-cpu`: CPU backend。
- `tenferro-runtime`: concrete/traced tensor helper、graph のコンパイルと実行。
- `tenferro-ad`: eager/traced の自動微分 API。
- `tenferro-einsum`: einsum 縮約。
- `tenferro-linalg`: 行列分解などの線形代数。
- `tenferro-fft`: FFT。

`internal` を名前に含むクレートは実装用で、ユーザ向けのAPI面ではありません。
本書では現在のAPIを暗記することが目的ではないため、
実際に使う場合は公式ドキュメントで公開クレートと import path を確認します。

## メモリレイアウト

tenferro の密なテンソルは column-major（列優先）です。
つまり、左端の添字がメモリ上で最も速く変わります。

例えば、論理的な `2 x 3` の行列を

```text
[[1, 2, 3],
 [4, 5, 6]]
```

と書くと、column-major の1次元バッファは次の順序になります。

```text
[1, 4, 2, 5, 3, 6]
```

これは `ndarray` の標準的な row-major（行優先）とは違います。
`ndarray` やNumPyの標準的な並びからtenferroへデータを渡す場合は、
どちらの順序のバッファなのかを必ず確認します。

tenferro のテンソル生成には `from_vec_col_major` のように
並び順が名前に入った constructor が用意されています。
自分が渡したバッファが column-major であることを確認したうえで使います。

AI agent に実装を任せる場合も、入力データが row-major なのか column-major なのか、
各軸が何を意味するのかを明示します。
この確認を省くと、shape は合っていても、物理的には転置されたデータを計算してしまうことがあります。

## 使う前に確認すること

tenferro は crates.io で公開されていますが、まだ 0.x 版（pre-1.0）です。
version 間で breaking change がありうるので、
本書では現在のAPIを暗記することは目的にしません。
実際に使う場合は、公式リポジトリとドキュメントを確認してから、
小さい検証用プロジェクトで試します。

AI agent に tenferro を使ったコードを書かせる場合は、少なくとも次を確認します。

- 参照した公式ドキュメントまたはリポジトリ。
- `Cargo.toml` に書いたクレート名（`tenferro-tensor` などの個別クレート名）。
- どの名前を `use` したか。
- `Cargo.lock` に記録された version（crates.io 依存の場合）。
  Git 依存を使った場合はその revision。
- CPUで実行するのか、GPUで実行するのか。
- CPUとGPUの間でデータを移す場所。
- 入出力バッファの並び順。
- 各軸の意味。
- 小さい入力で期待値を手計算できるテスト。

`Cargo.lock` には、実際に解決されたクレートの version が記録されます。
0.x 版のクレートは version 間でAPIが変わりうるため、
後から同じコードで再実行できるかどうかは version 固定に依存します。
そのため、演習プロジェクトでも `Cargo.lock` を残します。

## 最小例

本節の例は tenferro 0.2 で動作を確認しています。
API は 0.x の間に変わりうるので、手元で動かす場合は
公式ドキュメントで現在のシグニチャを確認してください。
以下の依存を `Cargo.toml` に書きます。

```toml
[dependencies]
tenferro-tensor = "0.2"
tenferro-cpu = "0.2"
tenferro-runtime = "0.2"
tenferro-einsum = "0.2"
tenferro-ad = "0.2"
tenferro-linalg = "0.2"
```

### einsum

`ij,jk->ik` は行列積と同じ縮約です。
入力は column-major で渡し、結果の shape が `[2, 4]` になることを確認します。

```rust
use tenferro_cpu::CpuBackend;
use tenferro_einsum::TensorEinsumExt;
use tenferro_tensor::Tensor;

let a = Tensor::from_vec_col_major(vec![2, 3], vec![1.0_f64; 6])?;
let b = Tensor::from_vec_col_major(vec![3, 4], vec![1.0_f64; 12])?;
let mut backend = CpuBackend::new();

let out = [&a, &b].einsum("ij,jk->ik", &mut backend)?;
assert_eq!(out.shape(), &[2, 4]);
```

### 自動微分

`AdContext` で勾配を計算します。
ここでは `x * x` の `x` に関する勾配を取り、結果がスカラー（rank 0）になることを確認します。

```rust
use tenferro_ad::AdContext;
use tenferro_runtime::TracedTensor;

let ad = AdContext::builder().build()?;
let x = TracedTensor::from_vec_col_major(vec![], vec![3.0_f64])?;
let loss = (&x * &x)?;
let dx = ad.grad(&loss, &x)?;
assert_eq!(dx.rank, 0);
```

### 線形代数

`tenferro-linalg` は traced な行列分解を提供します。
Cholesky 分解を graph にコンパイルし、CPU backend で実行します。
linalg は CPU で BLAS/LAPACK 系の provider クレートを引き込むことがあるので、
手元で feature と外部 library の要件を確認してください。

```rust
use tenferro_cpu::CpuBackend;
use tenferro_linalg::TracedTensorLinalgExt;
use tenferro_runtime::{GraphCompiler, GraphExecutor, TracedTensor};

let a = TracedTensor::from_vec_col_major(vec![2, 2], vec![4.0_f64, 2.0, 2.0, 3.0])?;
let l = a.cholesky()?;

let mut compiler = GraphCompiler::new();
let program = compiler.compile(&l)?;

let mut executor = GraphExecutor::new(CpuBackend::new());
executor.register_extension(tenferro_linalg::register_runtime)?;
let out = executor.run(&program)?;
assert_eq!(out.shape(), &[2, 2]);
```

## 本章での位置づけ

本章では、まず標準的で軽量な `ndarray` を確認します。
LAPACK系の線形代数が必要なら `ndarray-linalg` を確認します。
そのうえで、自動微分、GPU実行、テンソル縮約のような機能が必要になった場合の
発展的な選択肢として tenferro を紹介します。

参照:

- <https://github.com/tensor4all/tenferro-rs>
- <https://tensor4all.org/tenferro-rs/>
- <https://crates.io/crates/tenferro-tensor> （workspace の各クレート）
