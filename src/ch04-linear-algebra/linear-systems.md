# 連立一次方程式

物理シミュレーションにおいて、最も頻繁に現れる計算タスクの一つが連立一次方程式を解くことです。

$$ A vb(x) = vb(b) $$

ここで、$A$ は係数行列、$vb(b)$ は既知のベクトル、$vb(x)$ が求めたい未知のベクトルです。例えば、偏微分方程式を差分法や有限要素法で離散化すると、最終的にこの形の方程式（あるいはその大規模なもの）に帰着します。

## 直接法による解法

密行列（Dense Matrix）の場合、ガウスの消去法（より具体的にはLU分解）を用いるのが一般的です。`ndarray-linalg` の `solve()` は、一般行列に対して LU 分解を行い、その分解結果を使って連立方程式を解きます。LAPACK のルーチン名で言えば、分解は `*getrf`、分解済み行列による求解は `*getrs` に対応します。

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

同じ行列 $A$ に対して、異なる $vb(b)$ で何度も方程式を解く必要がある場合、
毎回 `solve` を呼ぶのは非効率です。
`solve` は内部で $O(N^3)$ のコストがかかるLU分解（`*getrf` 相当）を行い、その後に前進・後退代入（`*getrs` 相当）で解いているからです。

一度LU分解を行って分解結果を保存しておけば、
次回以降は前進・後退代入だけで解を得ることができます。
この部分の計算量は、右辺ベクトル1本あたり $O(N^2)$ です。
ここで $N$ は $N times N$ 行列のサイズです。

$$ A = L U $$

$$ L (U vb(x)) = vb(b) $$

計算量を分けて考えると、LU分解を作る部分が $O(N^3)$、
分解済みのLUで1つの右辺を解く部分が $O(N^2)$ です。

したがって、同じ係数行列で多数の右辺を解く問題では、
LU分解を一度だけ作り、その分解結果を使い回すことが重要です。

```rust,noplayground
use ndarray::{arr1, arr2, Array1, Array2};
use ndarray_linalg::{Factorize, Solve}; // LU分解のために必要

fn solve_two_rhs_with_factorization(
    a: &Array2<f64>,
    b1: &Array1<f64>,
    b2: &Array1<f64>,
) -> (Array1<f64>, Array1<f64>) {
    let f = a.factorize().expect("Factorization failed");
    let x1 = f.solve(b1).expect("Failed to solve b1");
    let x2 = f.solve(b2).expect("Failed to solve b2");
    (x1, x2)
}

fn main() {
    let a = arr2(&[[3.0, 1.0],
                   [1.0, 2.0]]);

    // 1つ目の b に対して解く
    let b1 = arr1(&[9.0, 8.0]);
    // 3x + y = 4, x + 2y = 3 -> x = 1, y = 1
    let b2 = arr1(&[4.0, 3.0]);
    let (x1, x2) = solve_two_rhs_with_factorization(&a, &b1, &b2);
    println!("x1 = {}", x1);
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

連立方程式を解く際、**条件数 (Condition Number)** が重要になります。条件数は、行列に対する入力の小さな変化や丸め誤差が、解にどれだけ増幅されうるかを表す指標です。

正則行列 $A$ と、同じ種類の行列ノルムを用いて、条件数は次のように定義されます。

$$ kappa(A) = norm(A) dot norm(A^(-1)) $$

条件数が非常に大きい行列は「悪条件（ill-conditioned）」であると言われます。この場合、$A$ や $vb(b)$ のわずかな誤差が、解 $vb(x)$ に大きく現れる可能性があります。逆に条件数が小さい行列は、相対的に安定に解きやすい行列です。

LAPACK などの線形代数ライブラリでは、条件数そのものではなく、その逆数 $1 / kappa(A)$（reciprocal condition number, `rcond`）を推定することも多くあります。`rcond` が $0$ に近いほど、行列が特異に近い、または数値的に扱いにくいことを示します。

物理シミュレーションで奇妙な結果が出た場合、行列が特異に近い（条件数が大きい）状態になっていないか確認することが重要です。

## 反復法について

ここまでに扱った `solve()`、LU分解、コレスキー分解は、行列を明示的に持って分解する**直接法**です。一方、大規模な問題では、CG法やGMRES法などの**反復法**が有効になることがあります。

反復法は、行列 $A$ を完全な密行列として保持できない場合でも、積 $A vb(x)$ を高速に計算できれば使えます。典型例は、$A$ が疎行列で行列ベクトル積を非ゼロ要素だけから計算できる場合や、$A$ が微分演算子・畳み込み・FFTを含む作用素として実装されている場合です。

ただし、反復法の収束は条件数、固有値・特異値の分布、前処理（preconditioning）の有無に強く依存します。単に大規模だから反復法が必ず速いわけではなく、「$A vb(x)$ が安く、十分な収束が得られるか」を確認する必要があります。

## 参考リンク

- [Condition number - Wikipedia](https://en.wikipedia.org/wiki/Condition_number)
- [LU decomposition - Wikipedia](https://en.wikipedia.org/wiki/LU_decomposition)

## まとめ

- 一般の連立一次方程式には `Solve` トレイトの `solve` メソッド（LU分解ベース）を使用する。
- 同じ係数行列で何度も解く場合は、`factorize` でLU分解の結果を保存する。
  分解には $O(N^3)$ かかるが、分解済みなら各右辺は $O(N^2)$ で解ける。
- 行列が対称正定値であることが分かっている場合は、コレスキー分解 (`Cholesky`) を用いると効率的である。
- 大規模問題では、$A vb(x)$ を高速に計算できるなら反復法も候補になる。
