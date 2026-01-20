# スペクトル解析

FFTを計算しただけでは、物理的な意味を持つ「周波数」は分かりません。FFTの出力結果をどのように解釈し、実際の信号を分析するか（**スペクトル解析**）について学びます。

## 周波数軸との対応

サンプリング周期を $Delta t$（サンプリング周波数 $f_s = 1 / Delta t$）、データ数を $N$ とします。
FFTの出力 $X_k$ の各インデックス $k$ に対応する物理的な周波数 $f_k$ は以下のようになります。

$$ f_k = k / (N Delta t) = k dot f_s / N quad (k = 0, 1, ..., N-1) $$

ここで、$k < N/2$ が正の周波数成分、$k > N/2$ が負の周波数成分に対応します。
ナイキスト周波数（再現可能な最高周波数）は $f_c = f_s / 2$ です。

## パワースペクトル (Power Spectrum)

各周波数成分の「強さ」を見るために、複素数 $X_k$ の絶対値の2乗をとったものを**パワースペクトル**と呼びます。

$$ P_k = |X_k|^2 $$

物理学では、エネルギーがどの周波数帯域に分布しているか（パワースペクトル密度, PSD）を調べることで、系の振動特性などを明らかにします。

## 窓関数 (Window Function)

FFTは、入力信号が「周期 $N$ で無限に繰り返されている」ことを仮定しています。
実際の有限な信号をそのまま切り取ると、信号の端点で不連続が生じ、**スペクトル漏れ (Spectral Leakage)** というノイズが発生します。

これを防ぐために、信号の両端を滑らかに $0$ に落とす**窓関数**を事前に乗算します。

代表的な窓関数：

- **ハミング窓 (Hamming window)**
- **ハニング窓 (Hanning window)**
- **ブラックマン窓 (Blackman window)**

## 実践例：合成信号の解析

2つの異なる周波数のサイン波を含む信号をFFTし、その周波数を特定してみましょう。

```rust
use rustfft::FftPlanner;
use num_complex::Complex;
use std::f64::consts::PI;

fn main() {
    let n = 1024;
    let fs = 1000.0; // サンプリング周波数 1000Hz
    let dt = 1.0 / fs;

    // 信号の生成: 50Hz と 120Hz の混合
    let mut buffer: Vec<Complex<f64>> = (0..n)
        .map(|i| {
            let t = (i as f64) * dt;
            let val = 1.0 * (2.0 * PI * 50.0 * t).sin() + 0.5 * (2.0 * PI * 120.0 * t).sin();
            // ハニング窓の適用
            let window = 0.5 * (1.0 - (2.0 * PI * (i as f64) / (n as f64 - 1.0)).cos());
            Complex::new(val * window, 0.0)
        })
        .collect();

    let mut planner = FftPlanner::new();
    let fft = planner.plan_fft_forward(n);
    fft.process(&mut buffer);

    println!("Frequency [Hz], Power");
    for k in 0..(n / 2) {
        let freq = (k as f64) * fs / (n as f64);
        let power = buffer[k].norm_sqr();
        if power > 10.0 { // 有意な成分のみ表示
            println!("{:.1}, {:.2}", freq, power);
        }
    }
}
```

## まとめ

- FFTのインデックス $k$ は周波数 $k f_s / N$ に対応する。
- データの端点による誤差（スペクトル漏れ）を抑えるには**窓関数**が不可欠。
- パワースペクトルを分析することで、複雑な信号の支配的なモードを特定できる。

---

第6章はこれで終わりです。次は[第7章: 常微分方程式](../ch07-ode/)に進みましょう。
