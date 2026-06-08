# 連続アクセス・stride・データ配置

多次元データも、メモリ上では基本的に1次元に並びます。
そのため、2次元配列をどの順序で1次元メモリに対応させるかが重要になります。

## row-major と column-major

2次元配列 `u[i, j]` の並べ方には、代表的に次の2つがあります。

- **row-major**: 行方向に連続する。C/C++、Rustの多くの表現、NumPyの標準に近い。
- **column-major**: 列方向に連続する。Fortran、MATLAB、LAPACK/BLASでよく使われる。

row-major で `ny` 行 `nx` 列の配列を1次元に置くなら、典型的には次の対応になります。

```text
index(i, j) = i * nx + j
```

このとき、`j` を1つ増やすとメモリ上でも隣の要素へ進みます。
`i` を1つ増やすと `nx` 要素分だけ進みます。

## stride

**stride** は、ある添字を1つ進めたとき、メモリ上で何要素進むかを表します。

row-major の2次元配列では、典型的には次のようになります。

- `j` 方向の stride: 1
- `i` 方向の stride: `nx`

stride が1の方向に読むと、メモリ上で連続したアクセスになります。
stride が大きい方向に読むと、飛び飛びのアクセスになります。

## loop order

row-major のデータでは、内側のloopで `j` を回すと連続アクセスになります。

```rust
for i in 0..ny {
    for j in 0..nx {
        let value = u[i * nx + j];
        // valueを使う
    }
}
```

逆に、内側のloopで `i` を回すと、`nx` 要素ずつ飛ぶアクセスになります。

```rust
for j in 0..nx {
    for i in 0..ny {
        let value = u[i * nx + j];
        // valueを使う
    }
}
```

小さい配列では差が見えないこともあります。
しかし、大きな配列や何度も繰り返す計算では、この違いが実行時間に効きます。

## 第4章への接続

第4章では、実際に `Vec<f64>` や `ndarray` を使って多次元データを扱います。
本節で見た row-major、stride、loop order は、そのときの土台になります。
