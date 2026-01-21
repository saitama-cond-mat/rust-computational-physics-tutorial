# 連立一次方程式

物理シミュレーションにおいて、最も頻繁に現れる計算タスクの一つが連立一次方程式を解くことです。

$$ A vb(x) = vb(b) $$

ここで、$A$ は係数行列、$vb(b)$ は既知のベクトル、$vb(x)$ が求めたい未知のベクトルです。例えば、偏微分方程式を差分法や有限要素法で離散化すると、最終的にこの形の方程式（あるいはその大規模なもの）に帰着します。

## 直接法による解法

密行列（Dense Matrix）の場合、ガウスの消去法（より具体的にはLU分解）を用いるのが一般的です。`ndarray-linalg` は、LAPACKのルーチン（`dgesv`など）を呼び出すことで、これを高速に実行します。

### `solve` メソッド

最も簡単な方法は、`Solve` トレイトの `solve` メソッドを使うことです。

```rust,noplayground
use ndarray::{arr1, arr2};
use ndarray_linalg::Solve;

fn main() {
    // 係数行列 A
    let a = arr2(&[[3.0, 1.0],
                   [1.0, 2.0]]);

    // 右辺ベクトル b
    let b = arr1(&[9.0, 8.0]);

    // Ax = b を解く
    let x = a.solve(&b).expect("Failed to solve");

    println!("Solution x = {}", x);
    // 期待される解:
    // 3x + y = 9
    // x + 2y = 8
    // -> x=2, y=3
}
```

### LU分解 (LU Decomposition)

同じ行列 $A$ に対して、異なる $vb(b)$ で何度も方程式を解く必要がある場合、毎回 `solve` を呼ぶのは非効率です。`solve` は内部で $O(N^3)$ のコストがかかるLU分解を行っているからです。

一度LU分解を行って分解結果を保存しておけば、次回以降は前進・後退代入（$O(N^2)$）だけで解を得ることができます。

$$ A = L U $$

$$ L (U vb(x)) = vb(b) $$

```rust,noplayground
use ndarray::{arr1, arr2};
use ndarray_linalg::{Factorize, Solve}; // LU分解のために必要

fn main() {
    let a = arr2(&[[3.0, 1.0],
                   [1.0, 2.0]]);

    // LU分解を実行
    let f = a.factorize().expect("Factorization failed");

    // 1つ目の b に対して解く
    let b1 = arr1(&[9.0, 8.0]);
    let x1 = f.solve(&b1).expect("Failed to solve b1");
    println!("x1 = {}", x1);

    // 2つ目の b に対して解く（LU分解の結果を再利用するため高速）
    // 3x + y = 4, x + 2y = 3 -> x = 1, y = 1
    let b2 = arr1(&[4.0, 3.0]);
    let x2 = f.solve(&b2).expect("Failed to solve b2");
    println!("x2 = {}", x2);
}
```

## 特別な行列の解法

行列 $A$ が特定の性質（対称、正定値など）を持つ場合、より特化したアルゴリズムを用いることで計算を高速化・安定化できます。

### コレスキー分解 (Cholesky Decomposition)

$A$ が**エルミート行列（実対称行列）** かつ**正定値（Positive Definite）** である場合、コレスキー分解が利用できます。

$$ A = L L^T quad ("または " L L^*) $$

コレスキー分解はLU分解に比べて計算量が約半分で済み、数値的にも非常に安定しています。物理の問題（例：バネ系や構造解析の剛性行列、拡散問題の係数行列など）では、行列が対称正定値になることがよくあります。

```rust,noplayground
use ndarray::arr2;
use ndarray_linalg::Cholesky;
use ndarray_linalg::UPLO;

fn main() {
    // 対称正定値行列
    let a = arr2(&[[4.0, 1.0],
                   [1.0, 4.0]]);

    // コレスキー分解 (Lower triangular)
    let l = a.cholesky(UPLO::Lower).expect("Cholesky failed");

    println!("L =\n{}", l);
    println!("L * L^T =\n{}", l.dot(&l.t()));
    // L * L^T = A となるはず

    // 分解結果を使って方程式を解くことも可能
    // (APIの詳細はバージョンによりますが、通常 solve メソッドなどが提供されます)
}
```

## 数値的安定性と条件数

連立方程式を解く際、**条件数 (Condition Number)** が重要になります。条件数が非常に大きい行列は「悪条件（Ill-conditioned）」であると言われ、数値計算の誤差が解に大きな影響を与えます。

$$ kappa(A) = norm(A) dot norm(A^(-1)) $$

物理シミュレーションで奇妙な結果が出た場合、行列が特異に近い（条件数が大きい）状態になっていないか確認することが重要です。

## まとめ

- 一般の連立一次方程式には `Solve` トレイトの `solve` メソッド（LU分解ベース）を使用する。
- 同じ係数行列で何度も解く場合は、`factorize` でLU分解の結果をキャッシュする。
- 行列が対称正定値であることが分かっている場合は、コレスキー分解 (`Cholesky`) を用いると効率的である。
