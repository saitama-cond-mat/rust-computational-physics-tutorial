# メトロポリス法

イジング模型のシミュレーションにおいて最も標準的なアルゴリズムが、**メトロポリス法 (Metropolis Method)** です。
これは、あるスピン配置から別の配置への遷移確率を適切に定めることで、
ボルツマン分布を定常分布にもつマルコフ連鎖を構成する手法です。
詳細釣り合いは、目標分布が定常分布になることを保証する十分条件です。
ただし、任意の初期状態からその分布へ収束するためには、連鎖が状態空間を十分に探索できること、
すなわちエルゴード性も必要です。

## アルゴリズムの手順

1. **初期化**: スピン配列を適当な状態（全て $+1$ やランダムなど）に設定します。
2. **スピンの選択**: ランダムに1つのスピン $s_i$ を選びます。
3. **フリップの試行**: そのスピンを反転させた状態（$s'_i = -s_i$）を考え、その時のエネルギー変化 $Delta E$ を計算します。

   $$ Delta E = E_"new" - E_"old" = 2 s_i ( J sum_(j in "neighbor") s_j + h ) $$

   計算に必要なのは局所的な変化分だけです。
   正方格子の最近接模型では近傍数が固定なので、$Delta E$ は系の大きさによらず $O(1)$ で計算できます。
   全エネルギーを毎回再計算すると $O(N)$ かかるため、局所更新では避けます。

4. **遷移判定**:
   - もし $Delta E <= 0$ ならば（エネルギーが下がるか変わらない）、確率1でフリップを採用します。
   - もし $Delta E > 0$ ならば（エネルギーが上がる）、確率 $e^(- beta Delta E)$ でフリップを採用します。
     （乱数 $r in [0, 1)$ を生成し、$r < e^(- beta Delta E)$ なら採用）

5. **繰り返し**: 上記の2〜4を十分な回数繰り返します。

## Rustによる実装

2次元イジング模型（$h=0$）を実装します。周期境界条件を採用します。

```rust
use ndarray::{Array2, Axis};
use rand::Rng;
use std::f64;

struct IsingModel {
    size: usize,
    spins: Array2<i32>, // +1 or -1
    j_coupl: f64,       // 相互作用定数 J
    inv_temp: f64,      // 逆温度 beta
}

impl IsingModel {
    fn new(size: usize, beta: f64) -> Self {
        // 初期状態はランダム (高温極限)
        let mut rng = rand::thread_rng();
        let spins = Array2::from_shape_fn((size, size), |_| {
            if rng.gen_bool(0.5) { 1 } else { -1 }
        });

        Self {
            size,
            spins,
            j_coupl: 1.0,
            inv_temp: beta,
        }
    }

    /// メトロポリス法による1ステップ（MCS: Monte Carlo Step）
    /// 1 MCS = 全スピン数回分のフリップ試行
    fn step(&mut self) {
        let mut rng = rand::thread_rng();
        let n_flips = self.size * self.size;

        for _ in 0..n_flips {
            // ランダムにサイトを選択
            let x = rng.gen_range(0..self.size);
            let y = rng.gen_range(0..self.size);
            let s = self.spins[[y, x]];

            // 隣接スピンの和 (周期境界条件)
            // ndarrayのインデックス操作は少し冗長になりがちなので、
            // 実際にはラッパー関数を作ると良いでしょう。
            let xp = if x + 1 == self.size { 0 } else { x + 1 };
            let xm = if x == 0 { self.size - 1 } else { x - 1 };
            let yp = if y + 1 == self.size { 0 } else { y + 1 };
            let ym = if y == 0 { self.size - 1 } else { y - 1 };

            let neighbor_sum = self.spins[[y, xp]]
                + self.spins[[y, xm]]
                + self.spins[[yp, x]]
                + self.spins[[ym, x]];

            // エネルギー変化 Delta E = 2 * s_i * J * sum(s_j)
            // (外部磁場 h=0)
            let delta_e = 2.0 * self.j_coupl * s as f64 * neighbor_sum as f64;

            // 遷移判定
            if delta_e <= 0.0 || rng.gen::<f64>() < (-self.inv_temp * delta_e).exp() {
                self.spins[[y, x]] *= -1; // フリップ採用
            }
        }
    }

    /// 総磁化 (Magnetization)
    fn magnetization(&self) -> f64 {
        self.spins.iter().sum::<i32>() as f64
    }

    /// 総エネルギー
    fn energy(&self) -> f64 {
        let mut e = 0.0;
        for y in 0..self.size {
            for x in 0..self.size {
                let s = self.spins[[y, x]];
                let xp = if x + 1 == self.size { 0 } else { x + 1 };
                let yp = if y + 1 == self.size { 0 } else { y + 1 };
                // 重複カウントを防ぐため、右と下のボンドだけ計算する
                e -= self.j_coupl * s as f64 * (self.spins[[y, xp]] + self.spins[[yp, x]]) as f64;
            }
        }
        e
    }
}
```

このコードでは、`step` 関数を呼び出すたびに、平均して各スピンが1回更新される試行（1 Monte Carlo Step, 1 MCS）が行われます。
平衡状態に達するまでの初期過程は、MCMC一般では burn-in と呼ばれることもありますが、
統計物理の文脈では thermalization（熱化）と呼ぶのが一般的です。
物理量は、十分に熱化した後に測定する必要があります。

## 総合演習への接続

[2D Ising実践演習](./ising-exercise.md)では、Metropolis法の実装に入る前に、model、境界条件、測定量、seed、熱化、測定間隔、検証方法をPLANとして書き出します。
通常のユニットテストでは周期境界条件、全エネルギー、局所エネルギー差、accept判定を決定的に確認し、小さい格子の厳密列挙で統計量の収束も確認します。

## 参考リンク

- [Metropolis-Hastings algorithm - Wikipedia](https://en.wikipedia.org/wiki/Metropolis%E2%80%93Hastings_algorithm)
- [Detailed balance - Wikipedia](https://en.wikipedia.org/wiki/Detailed_balance)
- [Markov chain Monte Carlo - Wikipedia](https://en.wikipedia.org/wiki/Markov_chain_Monte_Carlo)
