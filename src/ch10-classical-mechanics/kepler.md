# ケプラー問題と軌道安定性

シンプレクティック積分の恩恵を最も実感できる例の一つが、重力下での惑星の運動（ケプラー問題）です。

## 運動方程式

原点に質量 $M$ の恒星があり、位置 $vb(r)$ にある質量 $m$ の惑星が万有引力を受けて運動しているとします。
運動方程式は以下の通りです。

$$ m dv(vb(v), t) = - (G M m) / abs(vb(r))^3 vb(r) $$

ここで $G$ は万有引力定数です。
この系は角運動量と全エネルギーが保存されるハミルトン系です。

## ndarrayによる実装

ここではベクトル計算を簡潔にするため、[第2章](../ch02-basics/ndarray.md)で導入した `ndarray` クレートを使用します。
速度ベレ法を用いて、惑星の軌道を計算してみましょう。

```rust
use ndarray::{arr1, Array1};

const GM: f64 = 4.0 * std::f64::consts::PI * std::f64::consts::PI; // 年単位・天文単位系で考えると便利

struct Planet {
    pos: Array1<f64>, // 位置 [x, y]
    vel: Array1<f64>, // 速度 [vx, vy]
}

impl Planet {
    fn new(x: f64, y: f64, vx: f64, vy: f64) -> Self {
        Self {
            pos: arr1(&[x, y]),
            vel: arr1(&[vx, vy]),
        }
    }
}

// 加速度（重力場）の計算
fn compute_acceleration(pos: &Array1<f64>) -> Array1<f64> {
    let r_sq = pos.dot(pos);
    let r = r_sq.sqrt();
    let r_cb = r_sq * r;
    
    // a = -GM/r^3 * r
    -GM / r_cb * pos
}

fn velocity_verlet_step(planet: &mut Planet, dt: f64) {
    // 1. 位置の更新
    let a_curr = compute_acceleration(&planet.pos);
    planet.pos = &planet.pos + &(&planet.vel * dt) + &(&a_curr * (0.5 * dt * dt));
    
    // 2. 新しい位置での加速度
    let a_next = compute_acceleration(&planet.pos);
    
    // 3. 速度の更新
    planet.vel = &planet.vel + &(&(&a_curr + &a_next) * (0.5 * dt));
}

fn main() {
    // 地球のような軌道を想定 (r=1.0, v=2pi)
    let mut earth = Planet::new(1.0, 0.0, 0.0, 2.0 * std::f64::consts::PI);
    let dt = 0.01;
    let steps = 1000;

    for i in 0..steps {
        if i % 10 == 0 {
            println!("{},{},{}", i as f64 * dt, earth.pos[0], earth.pos[1]);
        }
        velocity_verlet_step(&mut earth, dt);
    }
}
```

このコードで計算された `(x, y)` をプロットすると、始点に戻ってくる閉じた楕円（あるいは円）軌道が描かれます。
もし同じ条件でオイラー法を使うと、惑星は外側へ螺旋を描いて飛び去ってしまいます。RK4でも長時間計算すると徐々にエネルギー誤差が蓄積しますが、速度ベレ法ならば非常に長時間にわたって安定した軌道を保ち続けることができます。

## まとめ

- 重力多体問題のような保存系では、数値解法の選択が結果の定性的な振る舞い（軌道が閉じるか、発散するか）に直結します。
- `ndarray` を使うことで、ベクトル方程式 $vb(a) prop vb(r)$ をそのまま数式に近い形でコードに落とし込むことができます。

次節では、この手法を多数の粒子に拡張し、分子動力学シミュレーションを行います。
