# ケプラー問題と軌道安定性

シンプレクティック積分の恩恵を最も実感できる例の一つが、重力下での惑星の運動（ケプラー問題）です。
本節では、太陽の周りを回る地球の軌道をシミュレーションし、物理量の保存（エネルギー・角運動量）を確認します。

## 運動方程式

原点に質量$M$の恒星があり、位置$vb(r)$にある質量$m$の惑星が万有引力を受けて運動しているとします。
運動方程式は以下の通りです。

$$ m dv(vb(v), t) = - (G M m) / abs(vb(r))^3 vb(r) $$

この系はハミルトン系であり、全エネルギー$E$、角運動量$vb(L)$、およびルンゲ＝レンツベクトルが保存されます。

## ndarrayによる実装とエネルギー監視

[第2章](../ch02-basics/ndarray.md)で導入した`ndarray`クレートを使用して、速度ベレ法を実装します。

```rust,noplayground
use ndarray::{Array1, arr1};

// 天文単位系 (AU, Year, Solar Mass) では G*M = 4 * pi^2
const GM: f64 = 4.0 * std::f64::consts::PI * std::f64::consts::PI;

struct Planet {
    pos: Array1<f64>,
    vel: Array1<f64>,
}

impl Planet {
    fn new(x: f64, y: f64, vx: f64, vy: f64) -> Self {
        Self {
            pos: arr1(&[x, y]),
            vel: arr1(&[vx, vy]),
        }
    }

    // 全エネルギー E = K + U
    fn total_energy(&self) -> f64 {
        let v_sq = self.vel.dot(&self.vel);
        let r = self.pos.dot(&self.pos).sqrt();
        0.5 * v_sq - GM / r
    }

    // 角運動量 L = r x v (2次元ではスカラー)
    fn angular_momentum(&self) -> f64 {
        self.pos[0] * self.vel[1] - self.pos[1] * self.vel[0]
    }
}

fn compute_acceleration(pos: &Array1<f64>) -> Array1<f64> {
    let r_sq = pos.dot(pos);
    let r_inv_cb = 1.0 / (r_sq * r_sq.sqrt());
    -GM * r_inv_cb * pos
}

fn velocity_verlet_step(planet: &mut Planet, dt: f64) {
    let a_curr = compute_acceleration(&planet.pos);

    // 1. 位置更新
    planet.pos += &(&planet.vel * dt + 0.5 * &a_curr * dt * dt);

    // 2. 新しい加速度
    let a_next = compute_acceleration(&planet.pos);

    // 3. 速度更新
    planet.vel += &(0.5 * (&a_curr + &a_next) * dt);
}

fn main() {
    // 地球の初期条件 (r=1.0 AU, v=2*pi AU/yr)
    let mut earth = Planet::new(1.0, 0.0, 0.0, 2.0 * std::f64::consts::PI);
    let dt = 0.001; // 約8時間の刻み幅

    println!("Time, X, Y, Energy, L");
    for i in 0..2000 {
        if i % 10 == 0 {
            println!(
                "{:.3}, {:.4}, {:.4}, {:.6}, {:.6}",
                i as f64 * dt,
                earth.pos[0],
                earth.pos[1],
                earth.total_energy(),
                earth.angular_momentum()
            );
        }
        velocity_verlet_step(&mut earth, dt);
    }
}
```

## 軌道の安定性と誤差

このコードを実行すると、エネルギーや角運動量が時間とともにわずかに変動するものの、数千ステップ経過してもその平均値が一定に保たれることがわかります。

一方、[第7章](../ch07-ode/euler.md)で学んだオイラー法を用いた場合、エネルギーは指数関数的に増大し、惑星は螺旋を描いて太陽から遠ざかってしまいます。
また、RK4（4次ルンゲ＝クッタ法）を用いれば短期的には非常に高精度ですが、シンプレクティックではないため、非常に長い時間のシミュレーション（数万年規模）では誤差が一方的に蓄積し、軌道が縮小したり拡大したりする「軌道ドリフト」が発生します。

## 保存量の物理的意味

1. **エネルギー保存**: 軌道の大きさが保たれる。
2. **角運動量保存**: ケプラーの第2法則（面積速度一定）に対応。
3. **ルンゲ＝レンツベクトル保存**: 楕円軌道の向き（近日点の位置）が固定される。

シンプレクティック積分は、これらの物理的性質を数値的に「壊さない」ように設計されているため、天体力学のような長期にわたる安定性が求められる系において、標準的な高精度解法よりも優れた結果をもたらします。
