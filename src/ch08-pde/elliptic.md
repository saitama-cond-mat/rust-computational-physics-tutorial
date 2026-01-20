# 楕円型方程式

静的な電位分布や定常的な温度分布を記述する、時間に依存しない方程式を扱います。

- **ラプラス方程式**: $nabla^2 phi = 0$
- **ポアソン方程式**: $nabla^2 phi = f$

2次元のポアソン方程式は以下の通りです。

$$ pdv(phi, x, 2) + pdv(phi, y, 2) = f(x, y) $$

## 反復法による解法

楕円型方程式は領域全体の境界条件によって解が決まるため、時間発展のように端から順番に計算することはできません。通常は、適当な初期推定値から始めて、値を修正していく**反復法**が用いられます。

離散化すると、点 $(i, j)$ における値は周囲の4点の平均（および源 $f$）に関係付けられます。

$$ phi_(i,j) approx 1/4 (phi_(i+1,j) + phi_(i-1,j) + phi_(i,j+1) + phi_(i,j-1) - Delta x^2 f_(i,j)) $$

### 1. ヤコビ法 (Jacobi Method)

古いステップ $n$ の値をすべて使って、新しいステップ $n+1$ の値を一斉に計算します。
実装は簡単ですが、収束が非常に遅いのが欠点です。

### 2. ガウス＝ザイデル法 (Gauss-Seidel Method)

計算が完了したばかりの最新の $n+1$ の値を、同じステップ内の後半の計算ですぐに利用します。ヤコビ法よりも収束が速く、メモリも節約できます。

### 3. SOR法 (Successive Over-Relaxation)

ガウス＝ザイデル法による修正量をさらに加速パラメータ $omega$ で増幅させる手法です。適切な $omega$ を選ぶことで、劇的に高速に収束させることができます。

## Rustによる実装（ガウス＝ザイデル法）

2次元正方形領域におけるラプラス方程式 $nabla^2 phi = 0$ を解きます。
境界条件として、上辺を $100$、それ以外を $0$ とします（ディリクレ問題）。

```rust
fn main() {
    let n = 50; // グリッドサイズ 50x50
    let max_iter = 10000;
    let tolerance = 1e-4; // 収束判定の閾値

    // 2次元グリッドの初期化 (0.0)
    // phi[y][x] としてアクセス
    let mut phi = vec![vec![0.0; n]; n];

    // 境界条件の設定
    // 上辺 (y=0) を 100.0 に固定
    for x in 0..n {
        phi[0][x] = 100.0;
    }
    // 左辺、右辺、下辺は 0.0 のまま

    for iter in 0..max_iter {
        let mut max_diff = 0.0;

        // グリッド内部の更新
        for y in 1..n-1 {
            for x in 1..n-1 {
                let old_val = phi[y][x];

                // ガウス＝ザイデル法: 最新の値をすぐに使う
                // phi[y][x] = 0.25 * (phi[y][x+1] + phi[y][x-1] + phi[y+1][x] + phi[y-1][x])
                let new_val = 0.25 * (phi[y][x+1] + phi[y][x-1] + phi[y+1][x] + phi[y-1][x]);

                phi[y][x] = new_val;

                let diff = (new_val - old_val).abs();
                if diff > max_diff {
                    max_diff = diff;
                }
            }
        }

        // 収束判定
        if max_diff < tolerance {
            println!("収束しました: 反復回数 {}", iter + 1);
            break;
        }

        if iter == max_iter - 1 {
             println!("最大反復回数に達しました (max_diff = {:.6})", max_diff);
        }
    }

    // 結果の確認（中心付近の値）
    println!("phi[25][25] = {:.2}", phi[n/2][n/2]);
}
```

---

第8章はこれで終わりです。次は[第9章: モンテカルロ法](../ch09-monte-carlo/)に進みましょう。
