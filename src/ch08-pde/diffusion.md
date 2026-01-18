# 拡散方程式

熱の伝導や粒子の拡散を記述する**拡散方程式（熱伝導方程式）**を扱います。

$$ pdv(u, t) = D pdv(u, x, 2) $$

ここで $D$ は拡散係数です。

## 陽解法 (Explicit Method: FTCS)

最も単純な手法は、時間について前進差分、空間について中心差分を用いる **FTCS (Forward-Time Central-Space)** 法です。

$$ (u_i^(n+1) - u_i^n) / (Delta t) = D (u_(i+1)^n - 2u_i^n + u_(i-1)^n) / (Delta x^2) $$

これを $u_i^(n+1)$ について解くと：

$$ u_i^(n+1) = u_i^n + (D Delta t / Delta x^2) (u_(i+1)^n - 2u_i^n + u_(i-1)^n) $$

### 安定性条件

FTCS法が安定であるためには、以下の条件を満たす必要があります。

$$ r = D Delta t / Delta x^2 leq 1/2 $$

空間を細かく（$Delta x$ を小さく）すると、時間刻み $Delta t$ はその2乗に比例して極端に小さくしなければならず、計算効率が悪くなるという弱点があります。

## 陰解法 (Implicit Method)

安定性の制約を回避するために、次の時刻 $n+1$ の値を用いて微分を近似する**陰解法**が使われます。特に有名なのが **クランク・ニコルソン法 (Crank-Nicolson method)** です。

$$ (u_i^(n+1) - u_i^n) / (Delta t) = D/2 [ (pdv(u, x, 2))_i^n + (pdv(u, x, 2))_i^(n+1) ] $$

これは常に安定ですが、各ステップで連立一次方程式を解く必要があります。

## Rustによる実装 (陽解法)

```rust
fn main() {
    let nx = 50;        // 空間分割数
    let nt = 500;       // 時間ステップ数
    let dx = 1.0;
    let dt = 0.2;
    let d_coeff = 1.0;  // 拡散係数
    
    let r = d_coeff * dt / (dx * dx);
    println!("r = {}", r);
    if r > 0.5 {
        panic!("安定性条件を満たしていません！");
    }

    // 初期状態: 中央に熱源がある
    let mut u = vec![0.0; nx];
    u[nx/2] = 100.0;

    for _n in 0..nt {
        let mut u_next = vec![0.0; nx];
        // 境界を除く内部点を更新
        for i in 1..nx-1 {
            u_next[i] = u[i] + r * (u[i+1] - 2.0 * u[i] + u[i-1]);
        }
        // 境界条件 (固定境界)
        u_next[0] = 0.0;
        u_next[nx-1] = 0.0;
        
        u = u_next;
    }
}
```

---

[次節](./wave.md)では、波の伝播を扱う波動方程式について学びます。
