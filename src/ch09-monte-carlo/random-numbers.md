# 乱数生成

> [!NOTE]
> **本節のポイント**
>
> - 疑似乱数生成器(PRNG)の特性と、物理計算における再現性の重要性を理解する。
> - `rand`クレートを用いた一様乱数の生成手法を習得する。
> - 逆関数法やボックス＝ミュラー法などの、任意の確率分布への変換原理を数学的に理解する。

モンテカルロ法の精度と信頼性は、使用する**疑似乱数 (Pseudo-random numbers)** の質に直接依存します。物理シミュレーションでは、巨大なサンプル数を扱うため、周期が長く、統計的な偏りが極めて少ない生成器が必要です。

## Rustにおける乱数: `rand`クレート

Rustの数値計算において、乱数は[`rand`](https://crates.io/crates/rand)クレートとそのエコシステムを通じて提供されます。

### 依存関係

```toml
[dependencies]
rand = "0.10"
rand_chacha = "0.10" # 高高品質な疑似乱数生成器
rand_distr = "0.6" # 特定の統計分布
```

物理計算では、標準的な`StdRng`以外にも、**ChaCha** アルゴリズムのような暗号学的にも安全な（＝予測困難で統計的性質に優れた）生成器が好んで使われます。

## 物理計算と再現性

数値シミュレーションでは、バグの特定や結果の検証のために、同じ条件下で全く同じ乱数列を生成する **再現性(Reproducibility)** が極めて重要です。

```rust,noplayground
use rand::{RngExt, SeedableRng};
use rand_chacha::ChaCha8Rng;

fn main() {
    // 32バイトのシード（種）を固定することで、常に同じ乱数列を得る
    let seed = [0u8; 32];
    // シードから生成器を初期化
    let mut rng = ChaCha8Rng::from_seed(seed);

    // [0, 1) の範囲の f64 型の一様乱数を生成
    let x: f64 = rng.random();
    // 1 から 100 までの整数の範囲から一様乱数を生成
    let n: i32 = rng.random_range(1..=100);

    println!("Fixed x: {}, n: {}", x, n);
}
```

```text
Fixed x: 0.8369197568826472, n: 91
```

- **`SeedableRng`**: シード値から生成器を決定論的に初期化するためのトレイトです。
- **`random()`**: 対象となる型の全範囲（実数の場合は$[0, 1)$）から乱数を生成します。
- **`random_range(range)`**: 指定された範囲（半開区間や閉区間）から乱数をサンプリングします。

## 確率分布の生成原理

一様乱数$U in [0, 1)$から、任意の確率密度関数$p(x)$に従う乱数を生成するための数学的背景を解説します。

### 1. 逆関数法 (Inverse Transform Sampling)

累積分布関数$F (x) = integral_(-infinity)^x p (t) dd(t)$の逆関数$F^(-1)$が既知である場合に有効な手法です。

**数学的原理**:
一様乱数$U$に対して$X = F^(-1)(U)$と置くと、その累積分布関数$P (X lt.eq x)$は以下のようになります。
$$
P (X lt.eq x) = P (F^(-1)(U) lt.eq x) = P (U lt.eq F (x))
$$

ここで$U$は一様分布なので$P (U lt.eq u) = u$です。したがって、$P (X lt.eq x) = F (x)$となり、$X$は目的の累積分布関数$F (x)$、すなわち確率密度関数$p (x)$に従うことが示されます。

**具体例：指数分布**
$p (x) = lambda e^(-lambda x) quad (x gt.eq 0)$の場合、累積分布関数は$F (x) = 1 - e^(-lambda x)$です。
$u = 1 - e^(-lambda x)$を$x$について解くと：
$$ x = - 1/lambda ln(1 - u) $$

$1-u$もまた$[0, 1)$の一様乱数であるため、実装上は$x = - 1/lambda ln(u)$と簡略化されます。

### 2. ボックス＝ミュラー法 (Box-Muller transform)

正規分布（ガウス分布）$p(x) = 1/sqrt(2 pi sigma^2) exp(- (x-mu)^2 / (2 sigma^2))$のように、逆関数が初等関数で書けない場合に用いられます。

2つの一様乱数$u_1, u_2 in [0, 1)$を用いて、以下の変換を行うことで、標準正規分布$N(0, 1)$に従う独立な2つの乱数$z_1, z_2$を得られます。
$$
z_1 = sqrt(-2 ln u_1) cos(2 pi u_2) \
z_2 = sqrt(-2 ln u_1) sin(2 pi u_2)
$$

これは、2次元ガウス分布を極座標$(r, theta)$で表したとき、$r^2 = -2 ln u_1$が指数分布に、$theta = 2 pi u_2$が一様分布に従うという幾何学的性質を利用しています。

## `rand_distr`による実践的な利用

実用上は、これらの変換アルゴリズムを自分で実装する代わりに、最適化された`rand_distr`クレートを使用します。

```rust,noplayground
use rand::RngExt;
use rand_distr::{Distribution, Normal, Exp, Gamma};

/// 各種確率分布からのサンプリング
/// 物理現象のモデリングに応じて適切な分布を選択する
fn demonstrate_distributions() {
    println!("--- 各種確率分布からのサンプリング ---");

    let mut rng = rand::rngs::ThreadRng::default();

    // 正規分布（ガウス分布）: N(平均 mu, 標準偏差 sigma)
    // 用途: 測定誤差、熱雑音、ブラウン運動の変位など
    let normal = Normal::new(0.0, 1.0).unwrap();
    let v_n = normal.sample(&mut rng);
    println!("正規分布 N(0, 1): {:.6}", v_n);
    println!("  用途例: 測定誤差、熱雑音、中心極限定理が成り立つ現象");

    // 指数分布: Exp(lambda)
    // 用途: 放射性崩壊の待ち時間、光子の自由行程、ポアソン過程のイベント間隔
    let exp = Exp::new(1.0).unwrap();
    let v_e = exp.sample(&mut rng);
    println!("\n指数分布 Exp(1.0): {:.6}", v_e);
    println!("  用途例: 放射性崩壊の待ち時間、粒子の平均自由行程");

    // ガンマ分布: Gamma(shape, scale)
    let gamma = Gamma::new(2.0, 2.0).unwrap();
    let v_g = gamma.sample(&mut rng);
    println!("\nガンマ分布 Gamma(2.0, 2.0): {:.6}", v_g);
    println!("  用途例: 複数イベントの待ち時間、ベイズ統計");
}

/// 統計的性質の確認
/// 大量のサンプルから分布の特性（平均、分散）を計算
fn demonstrate_statistics() {
    println!("--- 統計的性質の確認（N=10000サンプル）---");

    let mut rng = rand::rngs::ThreadRng::default();
    let n_samples = 10000;

    // 正規分布 N(0, 1) のサンプリング
    let normal = Normal::new(0.0, 1.0).unwrap();
    let samples_normal: Vec<f64> = (0..n_samples).map(|_| normal.sample(&mut rng)).collect();

    let (mean_n, std_n) = compute_statistics(&samples_normal);
    println!("正規分布 N(0, 1):");
    println!("  理論値: 平均 = 0.0, 標準偏差 = 1.0");
    println!("  実測値: 平均 = {:.6}, 標準偏差 = {:.6}", mean_n, std_n);

    // 指数分布 Exp(1.0) のサンプリング
    let exp = Exp::new(1.0).unwrap();
    let samples_exp: Vec<f64> = (0..n_samples).map(|_| exp.sample(&mut rng)).collect();

    let (mean_e, std_e) = compute_statistics(&samples_exp);
    println!("\n指数分布 Exp(1.0):");
    println!("  理論値: 平均 = 1.0, 標準偏差 = 1.0");
    println!("  実測値: 平均 = {:.6}, 標準偏差 = {:.6}", mean_e, std_e);

    // 一様分布 [0, 1) のサンプリング
    let samples_uniform: Vec<f64> = (0..n_samples).map(|_| rng.random::<f64>()).collect();

    let (mean_u, std_u) = compute_statistics(&samples_uniform);
    println!("\n一様分布 U(0, 1):");
    println!(
        "  理論値: 平均 = 0.5, 標準偏差 = {:.6}",
        (1.0 / 12.0_f64).sqrt()
    );
    println!("  実測値: 平均 = {:.6}, 標準偏差 = {:.6}", mean_u, std_u);
}

/// サンプルから平均と標準偏差を計算
fn compute_statistics(samples: &[f64]) -> (f64, f64) {
    let n = samples.len() as f64;
    let mean = samples.iter().sum::<f64>() / n;
    let variance = samples.iter().map(|x| (x - mean).powi(2)).sum::<f64>() / n;
    let std_dev = variance.sqrt();
    (mean, std_dev)
}
```

```text
--- 各種確率分布からのサンプリング ---
正規分布 N(0, 1): -0.750363
  用途例: 測定誤差、熱雑音、中心極限定理が成り立つ現象

指数分布 Exp(1.0): 4.913783
  用途例: 放射性崩壊の待ち時間、粒子の平均自由行程

ガンマ分布 Gamma(2.0, 2.0): 1.258798
  用途例: 複数イベントの待ち時間、ベイズ統計

--- 統計的性質の確認（N=10000サンプル）---
正規分布 N(0, 1):
  理論値: 平均 = 0.0, 標準偏差 = 1.0
  実測値: 平均 = -0.015215, 標準偏差 = 0.999117

指数分布 Exp(1.0):
  理論値: 平均 = 1.0, 標準偏差 = 1.0
  実測値: 平均 = 0.996618, 標準偏差 = 0.998381

一様分布 U(0, 1):
  理論値: 平均 = 0.5, 標準偏差 = 0.288675
  実測値: 平均 = 0.498569, 標準偏差 = 0.288859
```

## 結果の解釈：理論値と統計誤差

上記の実行結果（統計的性質の確認）を見ると、実測値（平均や標準偏差）が理論値に非常に近いものの、完全には一致していないことが分かります。これはモンテカルロ法における**統計誤差**によるものです。

1. **統計的揺らぎ**: サンプル数$N=10,000$の場合、中心極限定理によれば相対誤差は$1/sqrt(N) = 0.01$（1%）程度のオーダーで現れます。実際、結果の「平均」を見ると理論値から小数点第2位程度のズレに収まっており、サンプリングが統計的に正しく行われていることが確認できます。
2. **再現性の確認**: `ChaCha8Rng`を用いてシードを固定した例では、何度実行しても`0.836919...`という全く同じ値が得られます。一方、`ThreadRng`を用いた統計テストでは、内部的な不確定性により実行ごとに結果が僅かに変動します。
3. **物理的妥当性**: 例えば指数分布 $exp(1.0)$ では、得られた個別のサンプル値（`4.913...`）が正の実数であり、理論通りの範囲に収まっていることが分かります。

このように、数値計算の結果を得た際には「理論値とのズレが統計誤差の範囲内か？」を確認する習慣をつけることが、信頼性の高いシミュレーションへの第一歩となります。

---

[次節](./integration.md)では、これらの乱数を用いて積分の近似値を求める「モンテカルロ積分」を学びます。
