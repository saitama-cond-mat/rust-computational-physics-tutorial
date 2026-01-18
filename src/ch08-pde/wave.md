# 波動方程式

波の伝播（弦の振動、音波、電磁波など）を記述する**波動方程式**を扱います。

$$ pdv(u, t, 2) = v^2 pdv(u, x, 2) $$

ここで $v$ は波の伝播速度です。拡散方程式とは異なり、時間に2階微分が含まれていることが大きな特徴です。

## 離散化

時間、空間ともに中心差分を用います。

$$ (u_i^(n+1) - 2u_i^n + u_i^(n-1)) / (Delta t^2) = v^2 (u_(i+1)^n - 2u_i^n + u_(i-1)^n) / (Delta x^2) $$

これを $u_i^(n+1)$ について解くと：

$$ u_i^(n+1) = 2u_i^n - u_i^(n-1) + (v Delta t / Delta x)^2 (u_(i+1)^n - 2u_i^n + u_(i-1)^n) $$

この式からわかるように、次の時刻の状態 $n+1$ を決めるには、**現在 ($n$) と 1つ前 ($n-1$) の 2つの時刻の情報**が必要です。

## 初期条件と最初のステップ

2階微分方程式なので、初期状態として位置 $u(x, 0)$ だけでなく、初期速度 $pdv(u, t)(x, 0)$ も必要です。

最初のステップ ($n=1$) を計算する際は、$u_i^(-1)$ という仮想的な過去の値を、初期速度 $V_i$ を用いた中心差分 $(u_i^1 - u_i^(-1)) / (2 Delta t) = V_i$ から推定して代入します。

## 安定性条件 (CFL条件)

$$ C = v Delta t / Delta x leq 1 $$

これが満たされない場合、波が不自然に増幅されて発散します。

## Rustによる実装

両端固定の弦の振動をシミュレーションする例です。初期状態として、中央が盛り上がったガウス波束を与えます。

```rust
use std::f64::consts::PI;

fn main() {
    let nx = 100;
    let nt = 300;
    let dx = 0.1;
    let dt = 0.05;
    let v = 1.0; // 波の速度
    
    // CFL条件のチェック
    let c = v * dt / dx;
    println!("CFL number = {:.3}", c);
    if c > 1.0 {
        panic!("Unstable condition!");
    }
    
    // 3つの時間ステップを保持するバッファ
    // u_prev: u^(n-1), u_curr: u^n, u_next: u^(n+1)
    let mut u_prev = vec![0.0; nx];
    let mut u_curr = vec![0.0; nx];
    let mut u_next = vec![0.0; nx];
    
    // 1. 初期条件の設定 (t=0)
    // ガウス波束を中心に配置
    let center = (nx / 2) as f64 * dx;
    let sigma = 1.0;
    for i in 0..nx {
        let x = i as f64 * dx;
        u_curr[i] = (- (x - center).powi(2) / (2.0 * sigma.powi(2))).exp();
    }
    
    // 2. 最初のステップ (n=1) の計算
    // 初期速度 0 と仮定: u^(-1) = u^1 -> u^1 = u^0 + 0.5 * (v*dt/dx)^2 * (u_{i+1} - 2u_i + u_{i-1})
    let c2 = c * c;
    for i in 1..nx-1 {
        u_next[i] = u_curr[i] + 0.5 * c2 * (u_curr[i+1] - 2.0 * u_curr[i] + u_curr[i-1]);
    }
    // 境界条件 (固定端)
    u_next[0] = 0.0;
    u_next[nx-1] = 0.0;
    
    // バッファの更新
    u_prev = u_curr.clone();
    u_curr = u_next.clone();
    
    // 3. 時間発展ループ (n=2, 3, ...)
    for n in 2..nt {
        for i in 1..nx-1 {
            u_next[i] = 2.0 * u_curr[i] - u_prev[i] 
                        + c2 * (u_curr[i+1] - 2.0 * u_curr[i] + u_curr[i-1]);
        }
        
        // 境界条件
        u_next[0] = 0.0;
        u_next[nx-1] = 0.0;
        
        // 結果の出力（簡易的に中央の値を表示）
        if n % 10 == 0 {
            println!("Step {}: u[center] = {:.4}", n, u_next[nx/2]);
        }
        
        // バッファの更新 (シフト)
        u_prev = u_curr.clone();
        u_curr = u_next.clone();
    }
}
```

---

[次節](./elliptic.md)では、静的な場の分布を求める楕円型方程式について学びます。
