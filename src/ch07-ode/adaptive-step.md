# 適応型刻み幅制御

これまで時間刻み幅 $h$（ステップサイズ）は固定定数として扱ってきましたが、物理現象は常に一定のペースで変化するわけではありません。

- 変化が激しい時間帯 $arrow.r$ $h$ を小さくして精度を確保したい。
- 変化が緩やかな時間帯 $arrow.r$ $h$ を大きくして計算時間を短縮したい。

これを自動的に行うのが**適応型刻み幅制御 (Adaptive Step Size Control)** です。

## 埋め込み型ルンゲ＝クッタ法 (Embedded Runge-Kutta)

基本的なアイデアは、**2つの異なる次数（例：4次と5次）の解法を同時に計算し、その差を誤差の推定値として使う**ことです。

最も有名なのが**ルンゲ＝クッタ＝フェールベルグ法 (Runge-Kutta-Fehlberg, RKF45)** です。

### アルゴリズムの概要

RKF45では、6回の関数評価を行って、以下の2つの値を計算します。

1. **4次精度の近似解** $x_(n+1)^( (4) )$
2. **5次精度の近似解** $x_(n+1)^( (5) )$

この2つの差 $Delta = |x_(n+1)^( (5) ) - x_(n+1)^( (4) )|$ が、現在のステップにおける打ち切り誤差の目安になります。

### ステップサイズの調整戦略

許容誤差を $epsilon$ とします。

1. **$Delta lt.eq epsilon$ の場合**:
   精度は十分です。このステップを採用（$x_(n+1) = x_(n+1)^( (5) )$）し、次のステップへ進みます。余裕があれば、次のステップ幅 $h_("next")$ を大きくします。

2. **$Delta > epsilon$ の場合**:
   誤差が大きすぎます。このステップを破棄し、$h$ を小さくして（例：半分にして）やり直します。

新しいステップ幅 $h_("new")$ は、一般に以下の式で決定します。

$$ h_("new") = h_("old") times S times ( epsilon / Delta )^(1/5) $$

ここで $S$ は安全率（例：0.9）です。5乗根が出てくるのは、誤差が $O(h^5)$ のオーダーだからです。

## Rustクレートの活用： `ode_solvers`

適応型ステップ制御を自前で実装するのは係数の管理などが大変です。Rustには [`ode_solvers`](https://crates.io/crates/ode_solvers) などのライブラリがあり、これらを使うのが便利です。

（※以下は概念的な使い方の例であり、実際のAPIはバージョンにより異なる場合があります）

```rust
// Cargo.toml
// [dependencies]
// ode_solvers = "0.3"

use ode_solvers::dopri5::*;
use ode_solvers::*;

// 解きたい系を定義する構造体
struct System;

impl System<f64, Vector2<f64>> for System {
    fn system(&self, _t: f64, y: &Vector2<f64>, dy: &mut Vector2<f64>) {
        // 単振動: dx/dt = v, dv/dt = -x
        dy[0] = y[1];
        dy[1] = -y[0];
    }
}

fn main() {
    let system = System;
    let y0 = Vector2::new(1.0, 0.0); // 初期値
    let t_start = 0.0;
    let t_end = 10.0;
    let h_initial = 0.1;

    // Dormand-Prince 5(4) 法（RKF45の改良版）を使用
    let mut stepper = Dopri5::new(system, t_start, t_end, h_initial, y0, 1.0e-6, 1.0e-6);

    let res = stepper.integrate();

    match res {
        Ok(stats) => {
            println!("Integration finished.");
            println!("Steps: {}", stats.steps);

            // 結果の取得
            let path = stepper.x_out();
            let values = stepper.y_out();

            for (t, y) in path.iter().zip(values.iter()) {
                println!("t={:.4}, x={:.6}", t, y[0]);
            }
        },
        Err(e) => println!("Error: {:?}", e),
    }
}
```

## メリットとデメリット

- **メリット**:
  - ユーザーが適切な $h$ を悩む必要がない。
  - 必要な精度を保証してくれる。
  - 楕円軌道の近点（速い）と遠点（遅い）のように、速度が変わる系で劇的に効率が良い。
- **デメリット**:
  - 1ステップあたりの計算量は増える（関数の評価回数が多い）。
  - 厳密な等間隔データが出力されるわけではない（描画などで等間隔データが必要な場合は、補間を行う必要がある）。

---

[次節](./boundary-value.md)では、初期値問題とは異なる「境界値問題」について触れます。
