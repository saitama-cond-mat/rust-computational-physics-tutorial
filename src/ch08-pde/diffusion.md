# 拡散方程式

> [!NOTE]
> **本節のポイント**
>
> - 拡散方程式（熱伝導方程式）の物理的意味を理解する。
> - 陽解法（FTCS法）による離散化と、その安定性条件（フォン・ノイマンの安定性解析）を学ぶ。
> - `ndarray`を用いた効率的な空間格子の扱い方を習得する。

熱の伝導や粒子の拡散を記述する**拡散方程式（熱伝導方程式）** を扱います。

$$ pdv(u, t) = D pdv(u, x, 2) $$

ここで$D$は拡散係数です。

## 陽解法 (Explicit Method: FTCS)

最も単純な手法は、時間について前進差分、空間について中心差分を用いる **FTCS (Forward-Time Central-Space)** 法です。

拡散方程式$pdv(u, t) = D pdv(u, x, 2)$に、[前節](finite-difference.md)で学んだ差分近似を代入します。

$$ (u_i^(n+1) - u_i^n) / (Delta t) = D (u_(i+1)^n - 2u_i^n + u_(i-1)^n) / (Delta x^2) $$

これを$u_i^(n+1)$について解くと、現在の時刻$n$の値から次の時刻$n+1$の値を直接計算できる更新式が得られます。

$$ u_i^(n+1) = u_i^n + r (u_(i+1)^n - 2u_i^n + u_(i-1)^n) $$

ここで、$r = D (Delta t)/(Delta x^2)$です。

![FTCS Stencil](../images/ch08/ftcs_grid.svg)

### 安定性条件

FTCS法が安定であるためには、拡散数$r$が以下の条件を満たす必要があります。

$$ r = D (Delta t)/(Delta x^2) lt.eq 1/2 $$

この条件は、更新式を$u_i^(n+1) = (1 - 2r) u_i^n + r (u_(i+1)^n + u_(i-1)^n)$と書き直すと直感的に理解できます。これは周囲の点との**加重平均**の形をしていますが、$r > 1/2$になると中央の点$u_i^n$の重み$(1-2r)$が負になってしまいます。物理的には「熱が隣へ移動しすぎて、元の場所が周囲より冷たくなってしまう」という不自然な逆転現象が起き、それが増幅されて計算が爆発（発散）するのです。

## 陰解法(Implicit Method)

安定性の制約を回避するために、次の時刻$n+1$の値を用いて微分を近似する**陰解法**が使われます。特に有名なのが **クランク・ニコルソン法(Crank-Nicolson method)** です。

$$ (u_i^(n+1) - u_i^n) / (Delta t) = D/2 [ (pdv(u, x, 2))_i^n + (pdv(u, x, 2))_i^(n+1) ] $$

線形拡散方程式に対しては、クランク・ニコルソン法は時間刻みに関して無条件安定です。ただし、$Delta t$を大きくしすぎると精度が落ちたり、初期条件や境界条件によっては減衰する数値振動が目立つことがあります。また、各ステップで連立一次方程式を解く必要があります。これについては[連立一次方程式](../ch04-linear-algebra/linear-systems.md)で学んだLU分解などの手法が応用できます。

## Rustによる実装 (陽解法)

`ndarray`を用いて、1次元の拡散方程式を解くプログラムを実装してみましょう。

```rust,noplayground
use ndarray::Array1;

fn diffusion_number(d_coeff: f64, dt: f64, dx: f64) -> f64 {
    d_coeff * dt / (dx * dx)
}

fn point_source_initial(nx: usize, amplitude: f64) -> Array1<f64> {
    let mut u = Array1::<f64>::zeros(nx);
    u[nx / 2] = amplitude;
    u
}

fn ftcs_step(u: &Array1<f64>, r: f64) -> Array1<f64> {
    let nx = u.len();
    let mut u_next = Array1::<f64>::zeros(nx);

    // 境界を除く内部点を更新
    for i in 1..nx - 1 {
        u_next[i] = u[i] + r * (u[i + 1] - 2.0 * u[i] + u[i - 1]);
    }

    // 境界条件 (固定境界: ディリクレ条件)
    u_next[0] = 0.0;
    u_next[nx - 1] = 0.0;

    u_next
}

fn evolve_diffusion(
    mut u: Array1<f64>,
    r: f64,
    nt: usize,
    sample_interval: usize,
) -> (Array1<f64>, Vec<(usize, f64)>) {
    let center = u.len() / 2;
    let mut samples = Vec::new();

    for n in 0..nt {
        u = ftcs_step(&u, r);

        if n % sample_interval == 0 {
            samples.push((n, u[center]));
        }
    }

    (u, samples)
}

fn main() {
    let nx = 50; // 空間分割数
    let nt = 500; // 時間ステップ数
    let dx = 1.0;
    let dt = 0.2;
    let d_coeff = 1.0; // 拡散係数

    let r = diffusion_number(d_coeff, dt, dx);
    println!("拡散数 r = {:.3}", r);

    if r > 0.5 {
        eprintln!("Warning: 安定性条件 (r <= 0.5) を満たしていません！");
    }

    // 初期状態: 中央に熱源がある（デルタ関数的な初期分布）
    let u0 = point_source_initial(nx, 100.0);
    let (_u_final, samples) = evolve_diffusion(u0, r, nt, 100);

    for (step, center_value) in samples {
        println!("Step {}: u[center] = {:.4}", step, center_value);
    }
}
```

```text
拡散数 r = 0.200
Step 0: u[center] = 60.0000
Step 100: u[center] = 6.2727
Step 200: u[center] = 4.4478
Step 300: u[center] = 3.6347
Step 400: u[center] = 3.1458
```

### 結果の解釈

中央の温度（`u[center]`）が、ステップが進むにつれて急速に低下していることが分かります。これは、初期に一点に集中していた熱が周囲へと「拡散」し、分布が平滑化されている物理現象を反映しています。
また、今回は両端の温度を$0$に固定しているため、熱は次第に境界から外部へと逃げていき、十分な時間が経過すれば領域全体の温度は$0$に収束します。計算結果の減衰速度が後半になるほど緩やかになるのは、温度勾配が小さくなるにつれて拡散のドライビングフォースが弱まるためです。

## まとめ

- **拡散方程式** は、時間1階・空間2階の偏微分方程式。
- **FTCS法（陽解法）** は実装が容易だが、安定性条件$r lt.eq 1/2$という厳しい制約がある。
- **クランク・ニコルソン法などの陰的手法** を用いると安定性の制約を大きく緩和できるが、精度のための時間刻み選択と連立一次方程式の求解が必要になる。

## 参考リンク

- [Heat equation - Wikipedia](https://en.wikipedia.org/wiki/Heat_equation)
- [Crank-Nicolson method - Wikipedia](https://en.wikipedia.org/wiki/Crank%E2%80%93Nicolson_method)

---

[次節](./wave.md)では、波の伝播を扱う波動方程式について学びます。
