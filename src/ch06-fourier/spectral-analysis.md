# スペクトル解析

> [!NOTE]
> **本節のポイント**
>
> - FFTの出力結果を物理的な「周波数」と「強度」に対応させる方法を学ぶ。
> - スペクトル漏れを防ぐための窓関数の役割と、`ndarray`を用いた適用方法を習得する。
> - `plotters`を用いて、計算結果を可視化する。

FFTを計算しただけでは、物理的な意味を持つ「周波数」は分かりません。FFTの出力結果をどのように解釈し、実際の信号を分析するか（**スペクトル解析**）について学びます。

## 周波数軸との対応

サンプリング周期を$Delta t$（サンプリング周波数$f_s = 1 / (Delta t)$）、データ数を$N$とします。
FFTの出力$X_k$の各インデックス$k$に対応する物理的な周波数$f_k$は以下のようになります。

$$ f_k = k / (N Delta t) = (k f_s) / N quad (k = 0, 1, ..., N-1) $$

ここで、$k < N/2$が正の周波数成分、$k > N/2$が負の周波数成分に対応します。
ナイキスト周波数（再現可能な最高周波数）は$f_c = f_s / 2$です。

## パワースペクトル(Power Spectrum)

各周波数成分の「強さ」を見るために、複素数$X_k$の絶対値の2乗をとったものを**パワースペクトル**と呼びます。

$$ P_k = abs(X_k)^2 $$

物理学では、エネルギーがどの周波数帯域に分布しているか（パワースペクトル密度, PSD）を調べることで、系の振動特性などを明らかにします。

## 窓関数(Window Function)

FFTは、入力信号が「周期$N$で無限に繰り返されている」ことを仮定しています。
実際の有限な信号をそのまま切り取ると、信号の端点で不連続が生じ、**スペクトル漏れ (Spectral Leakage)** というノイズが発生します。

これを防ぐために、信号の両端を滑らかに$0$に落とす**窓関数**を事前に乗算します。`ndarray`を使えば、信号ベクトルと窓関数ベクトルの要素ごとの積として簡潔に記述できます。

代表的な窓関数：

- **ハニング窓(Hanning window)**: $w_n = 0.5 - 0.5 cos((2 pi n) / (N-1))$
  最も一般的に使われる窓関数で、周波数分解能とスペクトル漏れの抑制のバランスが良い。
- **ハミング窓(Hamming window)**: $w_n = 0.54 - 0.46 cos((2 pi n) / (N-1))$
  ハニング窓に似ているが、端点が $0$ になりきらない。周波数分解能を少し優先したい場合に用いられる。
- **ブラックマン窓(Blackman window)**: $w_n = 0.42 - 0.5 cos((2 pi n) / (N-1)) + 0.08 cos((4 pi n) / (N-1))$
  ハニング窓よりもスペクトル漏れを強力に抑えるが、メインローブが広くなり周波数分解能は低下する。

## 実践例：合成信号の解析と可視化

2つの異なる周波数のサイン波を含む信号をFFTし、その周波数を特定してみましょう。第1章で学んだ`plotters`を用いた可視化も行います。

### 依存関係

```toml:Cargo.toml
[dependencies]
rustfft = "6.4"
ndarray = "0.17"
num-complex = "0.4"
plotters = "0.3"
```

### 実装例

```rust,noplayground
use rustfft::FftPlanner;
use ndarray::{Array1, Array};
use num_complex::Complex64;
use std::f64::consts::PI;
use plotters::prelude::*;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let n = 1024;
    let fs = 1000.0; // サンプリング周波数 1000Hz
    let dt = 1.0 / fs;

    // 1. 信号の生成(50Hz + 120Hz)
    let t = Array::range(0.0, n as f64 * dt, dt);
    let mut signal = t.mapv(|ti| {
        let val = 1.0 * (2.0 * PI * 50.0 * ti).sin() + 0.5 * (2.0 * PI * 120.0 * ti).sin();
        Complex64::new(val, 0.0)
    });

    // 2. 窓関数の適用(Hanning窓)
    let window = Array1::from_shape_fn(n, |i| {
        0.5 * (1.0 - (2.0 * PI * i as f64 / (n as f64 - 1.0)).cos())
    });
    // 要素ごとの積
    signal *= &window.mapv(|w| Complex64::new(w, 0.0));

    // 3. FFTの実行
    let mut planner = FftPlanner::new();
    let fft = planner.plan_fft_forward(n);
    fft.process(signal.as_slice_mut().unwrap());

    // 4. 結果の解析(パワースペクトルの計算)
    let freqs: Vec<f64> = (0..n/2).map(|k| k as f64 * fs / n as f64).collect();
    let powers: Vec<f64> = signal.iter().take(n/2).map(|c| c.norm_sqr()).collect();

    // 5. 可視化
    let root = BitMapBackend::new("spectrum.png", (800, 600)).into_drawing_area();
    root.fill(&WHITE)?;

    let mut chart = ChartBuilder::on(&root)
        .caption("Power Spectrum", ("sans-serif", 30))
        .margin(10)
        .x_label_area_size(40)
        .y_label_area_size(50)
        .build_cartesian_2d(0.0..fs/2.0, 0.0..*powers.iter().max_by(|a, b| a.partial_cmp(b).unwrap()).unwrap())?;

    chart.configure_mesh()
        .x_desc("Frequency [Hz]")
        .y_desc("Power")
        .draw()?;

    chart.draw_series(LineSeries::new(
        freqs.into_iter().zip(powers.into_iter()),
        &RED,
    ))?;

    root.present()?;
    println!("spectrum.png を生成しました。");

    Ok(())
}
```

![スペクトル解析の結果](../images/ch06/spectrum.avif)

## まとめ

- FFTのインデックス$k$は周波数$(k f_s)/N$に対応する。
- データの端点による誤差（スペクトル漏れ）を抑えるには**窓関数**が不可欠。
- `ndarray`のベクトル演算を活用することで、信号処理のコードを簡潔かつ効率的に記述できる。
- パワースペクトルを可視化することで、信号に含まれる支配的な周波数成分を一目で特定できる。

---

第6章はこれで終わりです。次は[第7章: 常微分方程式](../ch07-ode/)に進みましょう。
