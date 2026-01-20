# 高速フーリエ変換 (FFT)

**高速フーリエ変換 (Fast Fourier Transform, FFT)** は、離散フーリエ変換 (DFT) を効率的に計算するアルゴリズムの総称です。1965年にクーリー (J. W. Cooley) とテューキー (J. W. Tukey) によって再発見され、現代のデジタル信号処理の基盤となっています。

## アルゴリズムの原理：分割統治法

最も一般的な「基数2のクーリー・テューキー型アルゴリズム」では、データ長 $N$ が $2$ の累乗（$2, 4, 8, ...$）である場合、問題を再帰的に半分に分割していきます。

DFTの定義式を、データの偶数番目 ($2m$) と奇数番目 ($2m+1$) に分けます。

$$
X_k = sum_(m=0)^(N/2 - 1) x_(2m) exp(- i (2 pi k (2m)) / N) + sum_(m=0)^(N/2 - 1) x_(2m+1) exp(- i (2 pi k (2m+1)) / N)
$$

指数部分を整理すると：

$$
X_k = sum_(m=0)^(N/2 - 1) x_(2m) exp(- i (2 pi k m) / (N/2)) + exp(- i (2 pi k) / N) sum_(m=0)^(N/2 - 1) x_(2m+1) exp(- i (2 pi k m) / (N/2))
$$

これは、**長さ $N/2$ のDFTが2つ**あることを意味します。この分割を繰り返すことで、計算量は $O(N^2)$ から **$O(N log N)$** に削減されます。

| データ数 N      | N² (DFT) | N log₂ N (FFT) | 比率         |
| :-------------- | :------- | :------------- | :----------- |
| 1,024 (2¹⁰)     | 約 10⁶   | 約 10⁴         | 約 100 倍    |
| 1,048,576 (2²⁰) | 約 10¹²  | 約 2 × 10⁷     | 約 50,000 倍 |

## Rustでの利用： `rustfft`

物理計算の実務において、FFTを自前で実装することは教育的な目的以外では稀です。Rustでは、高性能なFFTライブラリである [`rustfft`](https://crates.io/crates/rustfft) を使用するのが標準的です。

### 依存関係

`Cargo.toml` に以下を追加します。

```toml
[dependencies]
rustfft = "6.2"
num-complex = "0.4"
```

### 実装例

```rust
use rustfft::FftPlanner;
use num_complex::Complex;

fn main() {
    let mut planner = FftPlanner::new();
    let n = 8;
    let fft = planner.plan_fft_forward(n);

    // 入力データ (例：実数成分のみを持つ信号)
    let mut buffer = vec![
        Complex::new(1.0, 0.0),
        Complex::new(2.0, 0.0),
        Complex::new(3.0, 0.0),
        Complex::new(4.0, 0.0),
        Complex::new(5.0, 0.0),
        Complex::new(6.0, 0.0),
        Complex::new(7.0, 0.0),
        Complex::new(8.0, 0.0),
    ];

    // FFTの実行 (インプレース計算)
    fft.process(&mut buffer);

    println!("FFT 結果:");
    for (i, val) in buffer.iter().enumerate() {
        println!("{}: {:.3} + {:.3}i", i, val.re, val.im);
    }
}
```

## 注意点

1. **正規化**: `rustfft` を含む多くのライブラリでは、FFTとその逆変換 (IFFT) を続けて行っても元の値には戻りません。DFTとIDFTの定義に従い、計算結果を $N$ で割るなどの正規化が必要です。
2. **データの並び**: FFTの結果は、周波数 $0$（DC成分）から始まり、前半が正の周波数、後半が負の周波数（または高周波成分）という並びになります。

---

[次節](./spectral-analysis.md)では、FFTを使って実際の信号の周波数を解析する方法を学びます。
