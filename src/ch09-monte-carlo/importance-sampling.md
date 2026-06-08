# 重点サンプリング

> [!NOTE]
> **本節のポイント**
>
> - 分散減少法の一種である重点サンプリングの数学的原理を理解する。
> - 積分対象の関数の形状を反映した確率密度関数$p (x)$を選ぶ重要性を学ぶ。
> - サンプリング分布の選択を誤ると、かえって分散が増大するリスク（テールの問題）を理解する。

単純なモンテカルロ積分では、関数の値がほとんど $0$ であるような広大な領域を律儀にサンプリングし、貴重な計算資源を浪費してしまうことがあります。これを改善するのが**重点サンプリング (Importance Sampling)** です。

## 原理：期待値の書き換え

積分$I = integral_V f (vb(x)) dd(vb(x))$を計算したいとします。ここで、領域$V$で定義され、規格化（$integral_V p (vb(x)) dd(vb(x)) = 1$）された任意の確率密度関数$p (vb(x))$を導入すると、積分は以下のように書き換えられます。

$$ I = integral_V f(vb(x)) / p(vb(x)) p(vb(x)) dd(vb(x)) = E_p [ f(vb(x)) / p(vb(x)) ] $$

これは、**確率分布$p (vb(x))$に従って$M$個の点$vb(x)_i$をサンプリングし、重み付きの値$w (vb(x)_i) = (f (vb(x)_i)) / (p (vb(x)_i))$の平均をとる**ことに相当します。

$$ I_M = 1/M sum_(i=1)^M f(vb(x)_i) / p(vb(x)_i), quad vb(x)_i tilde p(vb(x)) $$

## 分散の最小化

この推定量の分散$V_p [I_M]$は、元の積分の真値$I$を用いて次のように表されました。

$$
V_p [I_M] &= 1/M V_p [ f(vb(x)) / p(vb(x)) ] \
&= 1/M (E_p [ (f(vb(x)) / p(vb(x)))^2 ] - E_p [(f (vb(x))) / (p (vb(x)))]^2) \
&= 1/M ( integral_V f(vb(x))^2 / p(vb(x)) dd(vb(x)) - I^2 ) $$

この分散を最小化するには、第一項の積分$J = integral_V (f (vb(x))^2) / (p (vb(x))) dd(vb(x))$を最小にする$p (vb(x))$を見つければよいことになります。ここで、**コーシー＝シュワルツの不等式** $(integral A^2)(integral B^2) gt.eq (integral A B)^2$を利用します。

$A = abs(f (vb(x))) / sqrt(p (vb(x)))$, $B = sqrt(p (vb(x)))$と置くと：

$$
( integral_V (f (vb(x))^2) / (p (vb(x))) dd(vb(x)) ) ( integral_V p (vb(x)) dd(vb(x)) ) gt.eq ( integral_V abs(f(vb(x))) dd(vb(x)) )^2
$$

ここで$integral p (vb(x)) dd(vb(x)) = 1$であるため、左辺は最小化したい項$J$そのものになります。右辺は$p (vb(x))$によらない定数です。等号が成立するのは$A prop B$、すなわち：

$$ abs(f (vb(x))) / sqrt(p (vb(x))) prop sqrt(p (vb(x))) arrow.long p (vb(x)) prop abs(f(vb(x))) $$

のときです。したがって、**最適なサンプリング分布$p (vb(x))$は被積分関数の絶対値に比例する**ことが示されました。

> [!TIP]
> **理想的なケース**: もし$f (vb(x)) gt.eq 0$かつ$p (vb(x)) = (f (vb(x))) / I$と選べたなら、$(f (vb(x)))/(p (vb(x))) = I$（定数）となります。このとき分散は完全に **0** になり、たった1回のサンプリングで正しい積分値が得られることになります。実用上は$I$が未知のため不可能ですが、この「平坦化」の極限を目指すのが重点サンプリングの本質です。

## 実践例：指数減衰を含む積分の効率化

以下の積分を例に、一様サンプリングと重点サンプリングを比較します。

$$ I = integral_0^infinity e^(-x) / (1 + x^2) dd(x) $$

### Rustによる比較実装

```rust,noplayground
use rand::RngExt;
use rand_distr::{Distribution, Exp};

#[derive(Clone, Copy)]
struct Estimate {
    result: f64,
    std_error: f64,
    variance: f64,
}

fn target_integrand(x: f64) -> f64 {
    (-x).exp() / (1.0 + x * x)
}

fn uniform_estimate<R>(rng: &mut R, n_samples: usize, limit: f64) -> Estimate
where
    R: RngExt + ?Sized,
{
    // 積分区間 [0, ∞) を [0, L] で打ち切る
    // I ≈ L × E[f(X)]  where X ~ Uniform(0, L)
    let mut sum = 0.0;
    let mut sum_sq = 0.0;

    for _ in 0..n_samples {
        let x = rng.random_range(0.0..limit);
        let fx = target_integrand(x);
        sum += fx;
        sum_sq += fx * fx;
    }

    let mean = sum / (n_samples as f64);
    let mean_sq = sum_sq / (n_samples as f64);
    let variance = mean_sq - mean * mean;
    let estimator_variance = limit * limit * variance;

    Estimate {
        result: limit * mean,
        std_error: (estimator_variance / (n_samples as f64)).sqrt(),
        variance: estimator_variance,
    }
}

fn importance_weight(x: f64) -> f64 {
    // 提案分布 p(x) = e^(-x) を用いると f(x)/p(x) = 1/(1+x^2)
    1.0 / (1.0 + x * x)
}

fn importance_estimate<R>(rng: &mut R, n_samples: usize) -> Estimate
where
    R: RngExt + ?Sized,
{
    let exp_dist = Exp::new(1.0).unwrap();
    let mut sum = 0.0;
    let mut sum_sq = 0.0;

    for _ in 0..n_samples {
        let x = exp_dist.sample(rng);
        let weight = importance_weight(x);
        sum += weight;
        sum_sq += weight * weight;
    }

    let mean = sum / (n_samples as f64);
    let mean_sq = sum_sq / (n_samples as f64);
    let variance = mean_sq - mean * mean;

    Estimate {
        result: mean,
        std_error: (variance / (n_samples as f64)).sqrt(),
        variance,
    }
}

fn run_trials(
    n_samples: usize,
    n_trials: usize,
    limit: f64,
) -> (Vec<Estimate>, Vec<Estimate>) {
    let mut uniform_results = Vec::new();
    let mut importance_results = Vec::new();

    for _ in 0..n_trials {
        let mut rng = rand::rngs::ThreadRng::default();
        uniform_results.push(uniform_estimate(&mut rng, n_samples, limit));
        importance_results.push(importance_estimate(&mut rng, n_samples));
    }

    (uniform_results, importance_results)
}

fn average_estimate(results: &[Estimate]) -> Estimate {
    let n = results.len() as f64;

    Estimate {
        result: results.iter().map(|e| e.result).sum::<f64>() / n,
        std_error: results.iter().map(|e| e.std_error).sum::<f64>() / n,
        variance: results.iter().map(|e| e.variance).sum::<f64>() / n,
    }
}

fn main() {
    // 目標: 以下の積分を数値的に計算する
    //   I = ∫₀^∞ f(x) dx = ∫₀^∞ e^(-x) / (1 + x²) dx
    //
    // 厳密解 (近似値): I ≈ 0.62144962
    //
    // この積分は解析的に計算困難だが、モンテカルロ法で近似できる。
    // ただし、x → ∞ での収束が遅いため、通常の一様サンプリングは非効率。
    // 重点サンプリングを用いることで、分散を大幅に削減できる。

    let n_samples = 1_000_000;
    let n_trials = 10; // 安定性を確認するための試行回数
    let exact_value = 0.62144962;
    let limit = 10.0;

    println!("積分: ∫₀^∞ e^(-x) / (1 + x²) dx");
    println!("厳密解 (近似): {:.8}\n", exact_value);
    println!("サンプル数: {}\n", n_samples);

    let (uniform_results, importance_results) = run_trials(n_samples, n_trials, limit);
    let first_uniform = uniform_results[0];
    let first_importance = importance_results[0];

    println!("--- 試行 1 の詳細 ---");
    println!("\n[一様サンプリング (区間 [0, {}])]", limit);
    println!("  推定値:     {:.8}", first_uniform.result);
    println!("  標準誤差:   {:.8}", first_uniform.std_error);
    println!("  推定値の分散: {:.8}", first_uniform.variance);
    println!("  誤差:       {:.8}", (first_uniform.result - exact_value).abs());

    println!("\n[重点サンプリング (p(x) = e^(-x))]");
    println!("  推定値:     {:.8}", first_importance.result);
    println!("  標準誤差:   {:.8}", first_importance.std_error);
    println!("  推定値の分散: {:.8}", first_importance.variance);
    println!(
        "  誤差:       {:.8}",
        (first_importance.result - exact_value).abs()
    );

    println!(
        "\n  分散削減率: {:.2}倍 (一様 {:.4} → 重点 {:.4})",
        first_uniform.variance / first_importance.variance,
        first_uniform.variance,
        first_importance.variance
    );

    // ----------------------------------------
    // 複数試行の統計
    // ----------------------------------------
    println!("\n\n=== {} 回の試行結果 ===", n_trials);

    let avg_uniform = average_estimate(&uniform_results);
    let avg_importance = average_estimate(&importance_results);

    println!("\n一様サンプリング:");
    println!("  平均推定値:     {:.8}", avg_uniform.result);
    println!("  平均推定値分散: {:.8}", avg_uniform.variance);
    println!("  平均誤差:       {:.8}", (avg_uniform.result - exact_value).abs());

    println!("\n重点サンプリング:");
    println!("  平均推定値:     {:.8}", avg_importance.result);
    println!("  平均推定値分散: {:.8}", avg_importance.variance);
    println!(
        "  平均誤差:       {:.8}",
        (avg_importance.result - exact_value).abs()
    );

    println!("\n改善効果:");
    println!(
        "  分散削減率:  {:.2}倍",
        avg_uniform.variance / avg_importance.variance
    );
    println!(
        "  効率向上:    {:.2}倍",
        avg_uniform.variance / avg_importance.variance
    );
}
```

### コードの解説

- **比較の設計**: 一様サンプリング（方法1）と重点サンプリング（方法2）を同じサンプル数で実行し、推定値の精度（標準誤差や分散）を直接比較しています。
- **無限区間の扱い（一様サンプリング）**: 本来の積分範囲は$[0, infinity)$ですが、一様分布ではサンプリングできないため、コードでは$L=10$で打ち切っています。この「テールの無視」による誤差が生じる点も、一様サンプリングの限界として示されています。
- **提案分布$p (x)$の選定**: 被積分関数$f (x) = e^(-x) / (1 + x^2)$の主要な減衰要因である$e^(-x)$に注目し、`Exp::new(1.0)`（指数分布）をサンプリング分布として採用しました。
- **分散の劇的な削減**: 重点サンプリングにおける標本値は$(f (x)) / (p (x)) = 1 / (1 + x^2)$となります。これは元の$f (x)$よりも値の変化が非常に穏やか（平坦に近い）であるため、少ないサンプル数で真の値に収束します。実行結果の`分散削減率`を見ることで、その圧倒的な効率向上を確認できます。

## 重大な注意点：テールの問題

重点サンプリングを使う際、**サンプリング分布$p (x)$の裾（テール）が被積分関数$f (x)$よりも早く減衰してはならない**という鉄則があります。

もし、ある領域で$f (x) > 0$なのに $p(x) approx 0$となると、その地点がたまたま選ばれた際に「重み」$(f (x))/(p (x))$が極端に巨大な値をとります。これが稀に発生することで推定値に巨大なスパイクが生じ、分散が爆発（数学的には無限大に発散）します。

> [!WARNING]
> $p (x)$は$f (x)$が大きな値を持つ領域をカバーするだけでなく、$f (x)$よりも「厚い裾（ヘビーテイル）」を持つ分布を選ぶのが安全です。

## まとめ

- **重点サンプリング** は、期待値を書き換えることで「重要な領域」を集中的に探索する。
- コーシー＝シュワルツの不等式により、最適な分布は **$p (x) prop abs(f (x))$** であることが導かれる。
- 適切に$p (x)$を選ぶことで標本値を平坦化し、分散を劇的に抑えることができる。

## 参考リンク

- [Importance sampling - Wikipedia](https://en.wikipedia.org/wiki/Importance_sampling)
- [Monte Carlo integration - Wikipedia](https://en.wikipedia.org/wiki/Monte_Carlo_integration)

---

[次節](./mcmc.md)では、さらに複雑で高次元な分布（解析的に$p (x)$からサンプリングできない場合）を扱うための手法、マルコフ連鎖モンテカルロ法を学びます。
