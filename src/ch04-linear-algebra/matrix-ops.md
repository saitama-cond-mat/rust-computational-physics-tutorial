# 行列演算の基礎

前節までに`ndarray`を用いた多次元配列の作成や、要素ごとの四則演算、行列積（ドット積）について学びました。本節では、より専門的な線形代数演算、例えば行列式、逆行列、ノルムなどの計算方法を扱います。

Rustの`ndarray`クレート自体は、純粋なRustで書かれた軽量な配列ライブラリであり、高度な線形代数アルゴリズム（固有値分解や特異値分解など）は直接提供していません。これらの機能を利用するには、**`ndarray-linalg`** というコンパニオンクレートを使用するのが一般的です。これは、古くから実績のある数値計算ライブラリであるBLAS/LAPACKへのRustバインディングを提供します。

## `ndarray-linalg` の準備

まず、`Cargo.toml`に`ndarray-linalg`を追加します。また、バックエンドとしてOpenBLASなどを使用するように設定する必要があります。

```toml
[dependencies]
ndarray = "0.17"
ndarray-linalg = { version = "0.18", features = ["openblas-system"] } # 環境に合わせて選択
```

コード内では、トレイトをインポートすることでメソッドが拡張されます。

```rust,ignore
use ndarray::prelude::*;
use ndarray_linalg::prelude::*; // 線形代数のトレイトを取り込む
```

## ノルム (Norm)

ベクトルや行列の「大きさ」を測る尺度がノルムです。物理シミュレーションでは、解の収束判定や誤差評価に頻繁に使用されます。

### ベクトルノルム

ベクトル $vb(x)$ の $L^p$ ノルムは以下のように定義されます。

$$ norm(vb(x))_p = ( sum_i abs(x_i)^p )^(1/p) $$

よく使われるのは $L^2$ ノルム（ユークリッドノルム）と $L^infinity$ ノルム（最大値ノルム）です。

```rust,noplayground
use ndarray::arr1;
use ndarray_linalg::Norm;

fn main() {
    let x = arr1(&[3.0, 4.0]);

    // L2ノルム: √(3² + 4²) = 5.0
    println!("L2 norm: {}", x.norm_l2());

    // L1ノルム: |3| + |4| = 7.0
    println!("L1 norm: {}", x.norm_l1());

    // 最大値ノルム: max(|3|, |4|) = 4.0
    println!("Max norm: {}", x.norm_max());
}
```

### 行列ノルム

行列 $A$ の演算子ノルムも同様に計算できます。

```rust,noplayground
use ndarray::arr2;
use ndarray_linalg::OperationNorm;

fn main() {
    let a = arr2(&[[1.0, 2.0],
                   [3.0, 4.0]]);

    let norm_one = a.opnorm_one().unwrap();
    let norm_inf = a.opnorm_inf().unwrap();
    let norm_fro = a.opnorm_fro().unwrap();

    // 行列のL2演算子ノルム
    println!("Operator L2 1-norm: {}", norm_one);
    println!("Operator L2 infinity norm: {}", norm_inf);
    println!("Operator L2 Frobenius norm: {}", norm_fro);

    // Frobeniusノルム（全要素の二乗和の平方根）
    // ndarray-linalg では `norm` は L2ノルムを指すことが多いですが、
    // 行列に対してはフロベニウスノルムが一般的です。
    // (注: バージョンやバックエンドによりAPIが異なる場合があります)
}
```

## トレースと行列式

正方行列 $A$ に対して、トレース（対角和） $tr(A)$ と行列式 $det(A)$ は基本的な不変量です。

### トレース (Trace)

トレースは対角成分の和です。`ndarray`の`diag()`メソッドで対角成分を取り出して和をとることで計算できます。

$$ tr(A) = sum_i A_(i i) $$

```rust,noplayground
use ndarray::arr2;

fn main() {
    let a = arr2(&[[1.0, 2.0],
                   [3.0, 4.0]]);

    let trace = a.diag().sum();
    println!("Trace: {}", trace); // 1.0 + 4.0 = 5.0
}
```

### 行列式 (Determinant)

行列式は `ndarray-linalg` の `det()` メソッドで計算できます。

```rust,noplayground
use ndarray::arr2;
use ndarray_linalg::Determinant;

fn main() {
    let a = arr2(&[[1.0, 2.0],
                   [3.0, 4.0]]);

    // det(A) = 1*4 - 2*3 = -2
    let det = a.det().unwrap();
    println!("Determinant: {}", det);
}
```

> [!NOTE]
> `det()` は `Result` 型を返します。計算過程（内部的なLU分解など）でエラーが発生する可能性があるためです。

## 逆行列 (Inverse Matrix)

正則な行列 $A$ に対して、$A^(-1)$ を計算します。

$$ A A^(-1) = A^(-1) A = I $$

数値計算の観点からは、連立一次方程式 $A vb(x) = vb(b)$ を解くために**逆行列を明示的に求めることは推奨されません**（計算コストが高く、数値的に不安定になりやすいため）。方程式を解く場合は、次節で扱う `solve()` やLU分解を用いるべきです。

しかし、物理学の公式など、逆行列そのものが必要な場合もあります（例：グリーン関数の計算）。

```rust,noplayground
use ndarray::arr2;
use ndarray_linalg::Inverse;

fn main() {
    let a = arr2(&[[1.0, 2.0],
                   [3.0, 4.0]]);

    let a_inv = a.inv().expect("Singular matrix");

    println!("Inverse matrix:\n{}", a_inv);

    // 確認: A * A⁻¹ = I (単位行列)
    println!("Check:\n{}", a.dot(&a_inv));
}
```

## まとめ

- 線形代数の高度な機能には `ndarray-linalg` を使用する。
- ノルム、行列式、逆行列といった基本的な演算は、対応するトレイト（`Norm`, `Determinant`, `Inverse`）をインポートすることで利用可能になる。
- 逆行列の計算はコストが高いため、単に方程式を解くだけなら避けるべきである。
