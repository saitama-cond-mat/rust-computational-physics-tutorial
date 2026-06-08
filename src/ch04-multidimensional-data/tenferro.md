# 高機能tensor library tenferro

> [!NOTE]
> **本節のポイント**
>
> - `ndarray` は、現時点でRustの標準的で軽量なN次元配列crateです。
> - tenferro は、AD、GPU、einsum、linear algebra まで含む高機能なtensor stackです。
> - tenferro のowned dense tensorは column-major です。
> - tenferro はpre-1.0なので、AI agentに任せる場合もrepositoryとdocumentationを確認します。

1次元の所有データには、通常 `Vec<f64>` を使います。
関数に渡すときは、`&[f64]` や `&mut [f64]` を使うのが基本です。

2次元以上の配列を軽く扱うだけなら、`ndarray` が自然な選択肢です。
`ndarray` はRust ecosystemで広く使われており、標準的な軽量配列として扱いやすいcrateです。

一方、PyTorch や JAX のように、tensor演算、automatic differentiation、
GPU execution、einsum、linear algebra を同じ設計の中で扱いたい場合は、
tenferro が候補になります。

## tenferroの位置づけ

tenferro-rs は、Rust-native な dense tensor computation stack です。
READMEでは、typed tensor computation、immediate execution、
traced graph execution、automatic differentiation、linear algebra、einsum、FFT、
CPU/CUDA backend control を対象にしています。

`ndarray` は軽量な配列crateです。
`ndarray-linalg` は、その `ndarray` にLAPACK系の線形代数を接続するcrateです。
tenferro は、それより高機能なtensor library stackです。
単に2次元配列を持つだけでなく、次のような用途を想定します。

- automatic differentiation を使う。
- GPU上でtensor演算を行う。
- einsumやtensor contractionを使う。
- linear algebraをbackend経由で使う。
- PyTorch eager execution や JAX traced execution に近いworkflowをRustで扱う。

tenferro は単一の機能ではなく、複数のlayerを持ちます。

| やりたいこと | 入口 |
| --- | --- |
| scalar type がコンパイル時に決まる通常のtensor計算 | `TypedTensor<T, R>` |
| dtype を実行時に選ぶ、またはbackend dispatchを使う | `Tensor` |
| PyTorch風に即時実行し、必要なら scalar loss に `backward()` を使う | `EagerTensor` と `EagerRuntime` |
| JAX風にgraphを作り、`grad`、`vjp`、`jvp`、graph再利用を使う | `TracedTensor`、`GraphCompiler`、`GraphExecutor<B>` |
| CUDA実行 | 同じtensor APIと明示的なupload/download |

## memory layout

tenferro の dense tensor は column-major です。
つまり、左端のdimensionがメモリ上で最も速く変わります。

例えば、論理的な `[2, 3]` matrixを

```text
[[1, 2, 3],
 [4, 5, 6]]
```

と書くと、column-major のflat bufferは次です。

```text
[1, 4, 2, 5, 3, 6]
```

これは `ndarray` の標準的な row-major layout とは違います。
row-major のdataをtenferroへ渡す境界では、`from_vec_row_major` のような変換用APIを使います。
逆に、tenferro の物理順序に従うbufferを渡す場合は `from_vec_col_major` を使います。

layoutの違いは、バグにも性能差にもつながります。
AI agentに実装を任せる場合も、入力dataが row-major なのか column-major なのかを明示します。

## crate構成

GitHub READMEによると、tenferro-rs はmulti-crate workspaceです。
stack全体を本書では tenferro と呼びますが、実際のprojectでは必要なcrateを選んで依存します。

| crate | 用途 |
| --- | --- |
| `tenferro-tensor` | tensor値、typed tensor、view、dtype/runtime tensor contract、backend trait |
| `tenferro-cpu` | CPU backend execution |
| `tenferro-gpu` | CUDA/ROCm backend support と明示的なdevice transfer |
| `tenferro-runtime` | eager/traced execution、graph compilation、extension runtime |
| `tenferro-ad` | automatic differentiation |
| `tenferro-linalg` | linear algebra operations |
| `tenferro-einsum` | einsum と contraction planning |
| `tenferro-fft` | FFT operations |

## `Cargo.lock`を残す

Git dependency を使う場合、`Cargo.lock` には実際に解決されたGit revisionが記録されます。
tenferro のように開発中のcrateでは、このrevisionが再現性に関わります。

exercise project を提出・保存するときは、`Cargo.lock` も残します。
これにより、後から同じAPIで再実行できる可能性が高くなります。

## AI agentに任せる場合

AI agent に tenferro を使ったコードを書かせる場合も、少なくとも次を確認します。

- 参照したdocumentationまたはrepository。
- `Cargo.toml` に書いたcrate名。
- `use` したimport path。
- `Cargo.lock` に記録されたGit revision。
- CPU/CUDA のどちらで実行するか。
- CPU/GPU間のupload/downloadが明示されているか。
- 入出力bufferが row-major か column-major か。
- 各axisの意味。
- 入力shapeを検査する小さいテスト。

tenferro はpre-1.0です。
Public API、crate boundary、backend contract、feature flag、内部設計は変わる可能性があります。
そのため、AI agentの生成コードをそのまま信頼せず、現在のrepositoryとdocumentationで確認します。

## 第4章での位置づけ

本章では、まず標準的で軽量な `ndarray` を確認します。
LAPACK系の線形代数が必要なら `ndarray-linalg` を確認します。
そのうえで、AD、GPU、einsum、linear algebra が必要な場合の高機能な選択肢として
tenferro を紹介します。

`ndarray` と tenferro は排他的ではありません。
小さい配列操作や既存Rust ecosystemとの接続には `ndarray`、
既存LAPACK workflowには `ndarray-linalg`、
PyTorch/JAX相当のtensor workflowには tenferro、という使い分けを意識します。

参照:

- <https://github.com/tensor4all/tenferro-rs>
- <https://tensor4all.org/tenferro-rs/>
