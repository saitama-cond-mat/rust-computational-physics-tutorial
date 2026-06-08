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
use ndarray::{arr1, arr2};
use ndarray_linalg::{Determinant, Inverse, Norm, OperationNorm};
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

行列 $A$ では、誘導ノルム（1ノルム、無限大ノルム）や Frobenius ノルムなどを使います。Frobenius ノルムは全要素をまとめて測る便利な行列ノルムですが、ベクトルノルムから誘導される演算子ノルムではありません。

特に、誘導2ノルム（スペクトルノルム）は最大特異値で表せます。

$$ norm(A)_2 = max_(vb(x) != 0) (norm(A vb(x))_2) / (norm(vb(x))_2) = sigma_("max")(A) $$

ここで $sigma_("max")(A)$ は $A$ の最大特異値です。実対称行列では固有値の絶対値の最大値と一致しますが、一般の行列では固有値ではなく特異値で評価する点に注意します。

```rust,noplayground
use ndarray::arr2;
use ndarray_linalg::OperationNorm;

fn main() {
    let a = arr2(&[[1.0, 2.0],
                   [3.0, 4.0]]);

    println!("Matrix 1-norm: {}", a.opnorm_one().unwrap());
    println!("Matrix infinity norm: {}", a.opnorm_inf().unwrap());
    println!("Frobenius norm: {}", a.opnorm_fro().unwrap());

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

    println!("Trace: {}", a.diag().sum()); // 1.0 + 4.0 = 5.0
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
    println!("Determinant: {}", a.det().unwrap());
}
```

> [!NOTE]
> `det()` は `Result` 型を返します。計算過程（内部的なLU分解など）でエラーが発生する可能性があるためです。

## 逆行列 (Inverse Matrix)

正則な行列 $A$ に対して、$A^(-1)$ を計算します。

$$ A A^(-1) = A^(-1) A = I $$

数値計算の観点からは、連立一次方程式 $A vb(x) = vb(b)$ を解くために**逆行列を明示的に求めて $vb(x) = A^(-1) vb(b)$ と計算することは推奨されません**。主な理由は数値安定性です。特に係数行列 $A$ の条件数

$$ kappa(A) = norm(A) norm(A^(-1)) $$

が大きい（ill-conditioned、悪条件）場合、入力データや丸め誤差の小さなずれが解に大きく増幅されます。方程式を解く場合は、次節で扱う `solve()` やLU分解のように、逆行列を作らずに連立方程式を直接解く手法を用いるべきです。

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
- 単に方程式を解くだけなら、逆行列を作って $A^(-1) vb(b)$ を計算するのではなく、`solve()` や分解済み行列を使う。特に条件数が大きい行列では、丸め誤差や入力誤差が解に大きく増幅されやすい。
