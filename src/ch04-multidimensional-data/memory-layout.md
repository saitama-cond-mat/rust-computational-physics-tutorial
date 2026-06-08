# 多次元配列とメモリレイアウト

格子、行列、画像、波動関数、相関関数などを扱うとき、データは多次元の添字を持ちます。
しかし、[計算機の基本モデル](../ch02-computer-model/)で見たように、
コンピュータのメモリ上ではデータは基本的に1次元に並びます。
この対応を理解しておくと、配列の扱い、性能、ファイル保存を考えやすくなります。

## flattening

2次元配列`u[i, j]`を1次元の`Vec<f64>`に保存する場合、例えば行優先（row-major）では次のように対応させます。

```rust
fn idx(i: usize, j: usize, nx: usize) -> usize {
    i * nx + j
}
```

このとき、`i`は行、`j`は列、`nx`は1行あたりの要素数です。

```rust
let ny = 4;
let nx = 5;
let mut u = vec![0.0; ny * nx];

let i = 2;
let j = 3;
u[idx(i, j, nx)] = 1.0;
```

flattening を明示すると、メモリ上の並び、境界条件、ファイル出力の対応を確認しやすくなります。

## row-major と column-major

多次元配列の並べ方には、主に次の2つがあります。

- row-major: 同じ行の要素が連続する。C/C++、`ndarray`、NumPyの標準に近い。
- column-major: 同じ列の要素が連続する。Fortran、MATLAB、Julia、LAPACK/BLAS、Eigen3でよく使われる。

どちらが正しいという話ではありません。重要なのは、配列を作る側、計算する側、保存する側、読む側で同じ約束を使うことです。

![row-major と column-major の違い](../images/ch02/array-layout.svg)

ここでは、`ny` 行 `nx` 列の配列を考えます。
`i` を行index、`j` を列indexとすると、row-major では典型的に次の対応になります。

```text
index(i, j) = i * nx + j
```

このとき、`j` を1つ増やすとメモリ上でも隣の要素へ進みます。
`i` を1つ増やすと `nx` 要素分だけ進みます。

column-major では、同じ形の配列を次のように対応させます。

```text
index(i, j) = j * ny + i
```

このとき、`i` を1つ増やすとメモリ上でも隣の要素へ進みます。
`j` を1つ増やすと `ny` 要素分だけ進みます。

## stride

stride は、ある軸に沿って添字を1つ進めたとき、メモリ上で何要素進むかを表します。
連続した配列ではアクセスが速く、stride が大きいアクセスでは
cache line に載ったデータを十分に使えないことがあります。

`ny` 行 `nx` 列の2次元配列では、典型的には次のようになります。

row-major:

- `j` 方向の stride: 1
- `i` 方向の stride: `nx`

column-major:

- `i` 方向の stride: 1
- `j` 方向の stride: `ny`

例えば row-major の2次元配列では、同じ行の隣接要素を読むループは連続アクセスになります。

```rust
for i in 0..ny {
    for j in 0..nx {
        let value = u[idx(i, j, nx)];
        // valueを使う
    }
}
```

計算量だけでなく、メモリアクセスの順序も性能に影響します。
大きな配列を扱う章では、loop order、cache、memory bandwidth を意識します。

逆に、row-major の配列を列方向に読むと、`nx` 要素ずつ飛ぶアクセスになります。

```rust
for j in 0..nx {
    for i in 0..ny {
        let value = u[idx(i, j, nx)];
        // valueを使う
    }
}
```

小さい配列では差が見えないこともあります。
しかし、大きな配列や何度も繰り返す計算では、この違いが実行時間に効きます。

## N次元の場合

多次元配列でも考え方は同じです。
shape を `(n0, n1, ..., n_{d-1})`、添字を `(i0, i1, ..., i_{d-1})`
と書くと、index は各添字とstrideの積の和になります。

```text
index = i0 * stride0 + i1 * stride1 + ... + i_{d-1} * stride_{d-1}
```

row-major では右端の添字が最も速く変わります。

```text
strides = (n1 * n2 * ... * n_{d-1}, ..., n_{d-1}, 1)
```

column-major では左端の添字が最も速く変わります。

```text
strides = (1, n0, n0 * n1, ..., n0 * n1 * ... * n_{d-2})
```

この規約は、数学的な shape そのものとは別です。
同じ `2 x 3` の行列でも、row-major と column-major では
1次元bufferへの並び方が変わります。
`ndarray` のような配列型では、shape に加えて stride などのmetadataを持つことで、
同じbufferをさまざまな見方で扱えます。

## view、copy、reshape

多次元配列ライブラリでは、部分配列や転置を「view」として扱える場合があります。view は元データへの参照であり、データをコピーしません。一方、連続した新しい配列が必要な場合は、実データのコピーが発生します。

AI agent に配列操作を任せる場合は、次の点を確認してください。

- view で十分な場所で不要な copy をしていないか。
- reshape 後の shape とデータ順序が期待通りか。
- transpose 後に、後続の処理が想定する memory layout と合っているか。
- 保存時に shape、axis、単位が metadata として残っているか。

多次元配列のバグは、コンパイルは通っても、軸の取り違えや境界条件の間違いとして現れます。小さい配列で手計算できるテストを作ることが重要です。
