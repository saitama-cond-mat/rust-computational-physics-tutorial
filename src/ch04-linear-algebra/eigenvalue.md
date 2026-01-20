# 固有値問題

行列 $A$ に対して、以下の関係を満たすスカラー $lambda$ と非ゼロベクトル $vb(x)$ を求める問題を固有値問題と呼びます。

$$
A vb(x) = lambda vb(x)
$$

ここで $lambda$ を**固有値 (Eigenvalue)**、$vb(x)$ を**固有ベクトル (Eigenvector)** と呼びます。
物理学において、固有値問題は極めて重要です。

- 量子力学：シュレーディンガー方程式 $H psi = E psi$ は、ハミルトニアン行列 $H$ の固有値問題そのものです（固有値 $E$ がエネルギー準位に対応）。
- 振動・波動：連成振動の固有振動数やモード解析。
- データ解析：主成分分析 (PCA) による次元削減。

## `ndarray-linalg` による解法

`ndarray-linalg` は、LAPACK のルーチンを用いて効率的に固有値と固有ベクトルを計算します。

### 一般の行列

正方行列の固有値・固有ベクトルを求めるには、`Eig` トレイトを使用します。

```rust,noplayground
use ndarray::arr2;
use ndarray_linalg::Eig;
use num_complex::Complex64; // 固有値は一般に複素数になる

fn main() {
    let a = arr2(&[[0.0, -1.0],
                   [1.0,  0.0]]);

    // 固有値と固有ベクトルを計算
    let (evals, evecs) = a.eig().expect("Eig decomposition failed");

    println!("Eigenvalues: {}", evals);
    println!("Eigenvectors:\n{}", evecs);
    
    // 回転行列 [[0, -1], [1, 0]] の固有値は +/- i
    // 出力は Complex64 型になります
}
```

> [!NOTE]
> 実非対称行列の固有値は一般に複素数になるため、結果は `Complex64` 型の配列として返されることが多いです。`num-complex` クレートの依存関係を追加する必要があるかもしれません。

### エルミート行列（実対称行列）

物理学で現れる行列の多くは、エルミート行列（実数の場合は対称行列）です。エルミート行列の固有値は必ず実数になり、固有ベクトルは直交するという素晴らしい性質があります。
この場合、`Eigh` トレイトを用いることで、計算を高速化し、結果を実数型 (`f64`) で得ることができます。

```rust,noplayground
use ndarray::arr2;
use ndarray_linalg::Eigh;
use ndarray_linalg::UPLO;

fn main() {
    // 対称行列（パウリ行列 sigma_x など）
    let a = arr2(&[[0.0, 1.0],
                   [1.0, 0.0]]);

    // 固有値と固有ベクトルを計算
    // UPLO::Lower は下三角部分のみを参照することを意味します（対称なので）
    let (evals, evecs) = a.eigh(UPLO::Lower).expect("Eigh failed");

    println!("Eigenvalues: {}", evals); // [-1, 1]
    println!("Eigenvectors:\n{}", evecs);
}
```

## アルゴリズムの実装例：べき乗法 (Power Iteration)

ライブラリを使うのが実用的ですが、アルゴリズムの理解のために**べき乗法**を実装してみましょう。これは、絶対値が最大の固有値（およびその固有ベクトル）を求めるシンプルな反復法です。

### 原理

任意の初期ベクトル $vb(x)_0$ に行列 $A$ を繰り返し掛けると、ベクトルは次第に最大固有値に属する固有ベクトルの方向へ収束します。

$$
 vb(x)_(k+1) = A vb(x)_k
$$

$$
 vb(x)_(k+1) arrow vb(x)_(k+1) / norm(vb(x)_(k+1)) quad "正規化"
$$

### Rustによる実装

```rust,noplayground
use ndarray::{arr1, arr2, Array1, Array2};
use ndarray_linalg::Norm;

fn power_iteration(a: &Array2<f64>, max_iter: usize, tol: f64) -> (f64, Array1<f64>) {
    let n = a.nrows();
    // 初期ベクトル（ランダムまたは適当な値）
    let mut x = Array1::from_elem(n, 1.0);
    x = &x / x.norm_l2(); // 正規化

    let mut eigenvalue = 0.0;

    for _ in 0..max_iter {
        let x_next = a.dot(&x);
        let x_next_norm = x_next.norm_l2();
        
        // レイリー商による固有値の推定: λ ≈ xᵀAx / xᵀx
        // ここでは単純にノルムの比に近いが、厳密には内積をとる方が精度が良い
        let next_val = x.dot(&x_next); 

        // 収束判定
        if (next_val - eigenvalue).abs() < tol {
            eigenvalue = next_val;
            x = &x_next / x_next_norm;
            break;
        }

        eigenvalue = next_val;
        x = &x_next / x_next_norm;
    }

    (eigenvalue, x)
}

fn main() {
    let a = arr2(&[[2.0, 1.0],
                   [1.0, 3.0]]);
    
    let (eval, evec) = power_iteration(&a, 1000, 1e-6);
    
    println!("Dominant Eigenvalue: {:.5}", eval);
    println!("Eigenvector: {}", evec);
    
    // 理論値:
    // trace=5, det=5 -> λ² - 5λ + 5 = 0
    // λ = (5 ± √(25 - 20))/2 = (5 ± 2.236)/2 = 3.618, 1.382
    // 最大固有値は約 3.618
}
```

## まとめ

- 一般の行列の固有値問題には `eig` を使用する。結果は複素数になることがある。
- 対称行列（エルミート行列）の場合は `eigh` を使用する。計算が高速で、結果は実数になることが保証される。
- 特定の固有値（最大固有値など）だけが必要な場合は、べき乗法などの反復法が有効な場合があるが、基本的にはLAPACKバインディングを利用するのが最も信頼性が高い。
