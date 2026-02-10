# 高速フーリエ変換(FFT)

> [!NOTE]
> **本節のポイント**
>
> - 高速フーリエ変換(FFT)が計算量を$O (N^2)$から$O (N log N)$へ劇的に削減する原理（分割統治法）を理解する。
> - Rustの標準的なFFTライブラリである`rustfft`の使い方を習得する。
> - `ndarray`と外部ライブラリ（スライスベースのAPI）を連携させる方法を学ぶ。

**高速フーリエ変換 (Fast Fourier Transform, FFT)** は、離散フーリエ変換(DFT)を効率的に計算するアルゴリズムの総称です。1965年にクーリー(J. W. Cooley)とテューキー(J. W. Tukey)によって再発見され、現代のデジタル信号処理の基盤となっています。

## アルゴリズムの原理：分割統治法

最も一般的な「基数2のクーリー・テューキー型アルゴリズム」では、データ長$N$が$2$の累乗（$2, 4, 8, ...$）である場合、問題を再帰的に半分に分割していきます。

DFTの定義式を、データの偶数番目($2m$)と奇数番目($2m+1$)に分けます。

$$
X_k = sum_(m=0)^(N/2 - 1) x_(2m) exp(- i (2 pi k (2m)) / N) + sum_(m=0)^(N/2 - 1) x_(2m+1) exp(- i (2 pi k (2m+1)) / N)
$$

指数部分を整理すると：

$$
X_k = sum_(m=0)^(N/2 - 1) x_(2m) exp(- i (2 pi k m) / (N/2)) + exp(- i (2 pi k) / N) sum_(m=0)^(N/2 - 1) x_(2m+1) exp(- i (2 pi k m) / (N/2))
$$

これは、**長さ$N/2$のDFTが2つ**あることを意味します。この分割を繰り返すことで、計算量は$O (N^2)$から **$O (N log N)$** に削減されます。

| データ数 _N_    | *N*² (DFT) | _N_ log₂ _N_ (FFT) | 比率         |
| :-------------- | :--------- | :----------------- | :----------- |
| 1,024 (2¹⁰)     | 約 10⁶     | 約 10⁴             | 約 100 倍    |
| 1,048,576 (2²⁰) | 約 10¹²    | 約 2 × 10⁷         | 約 50,000 倍 |

## Rustでの利用： `rustfft`

物理計算の実務において、FFTを自前で実装することは教育的な目的以外では稀です。Rustでは、高性能なFFTライブラリである[`rustfft`](https://crates.io/crates/rustfft)を使用するのが標準的です。

### 依存関係

`Cargo.toml`に`rustfft`と`ndarray`を追加します。

```toml:Cargo.toml
[dependencies]
rustfft = "6.4"
ndarray = "0.17"
num-complex = "0.4"
```

### 実装例(ndarray との連携)

多くの数値計算ライブラリは、特定のデータ構造（`ndarray`など）ではなく、汎用的なスライス(`&mut [T]`)を要求します。`ndarray`の`as_slice_mut()`や`raw_view_mut()`を使うことで、効率的にデータを渡すことができます。

```rust,noplayground
use rustfft::FftPlanner;
use ndarray::Array1;
use num_complex::Complex64;

fn main() {
    let n = 8;
    // ndarrayでデータを作成
    let mut data = Array1::<Complex64>::from_iter((0..n).map(|i| {
        Complex64::new(i as f64 + 1.0, 0.0)
    }));

    // FFTのプランを作成
    let mut planner = FftPlanner::new();
    let fft = planner.plan_fft_forward(n);

    // ndarrayの内部バッファをスライスとして取り出し、FFTを実行
    // processメソッドはインプレース（破壊的）に計算を行う
    fft.process(data.as_slice_mut().expect("Array must be contiguous"));

    println!("FFT 結果:");
    for (i, val) in data.iter().enumerate() {
        println!("{}: {:.3} + {:.3}i", i, val.re, val.im);
    }
}
```

```text
FFT 結果:
0: 36.000 + 0.000i
1: -4.000 + 9.657i
2: -4.000 + 4.000i
3: -4.000 + 1.657i
4: -4.000 + 0.000i
5: -4.000 + -1.657i
6: -4.000 + -4.000i
7: -4.000 + -9.657i
```

## 注意点

1. **正規化**: `rustfft`を含む多くのライブラリでは、計算効率のために定義式の$1/N$（または $1/sqrt(N)$）といった正規化係数を省略しています。FFTとその逆変換(IFFT)を続けて行っても元の値には戻らないため、必要に応じて$N$で割るなどの正規化が必要です。
2. **データの並び**: FFTの結果は、周波数 $0$（DC成分）から始まり、前半が正の周波数、後半が負の周波数（または高周波成分）という並びになります。
3. **メモリ連続性**: `as_slice_mut()`はデータがメモリ上で連続している場合にのみ成功します。スライシングなどで非連続になった`Array`に対しては、`to_owned()`や`as_standard_layout()`で連続化する必要があります。

---

[次節](./spectral-analysis.md)では、FFTを使って実際の信号の周波数を解析する方法を学びます。
