# 時間発展とスプリット演算子法

波動関数の時間変化 $psi(x, t)$ を追跡することは、化学反応のダイナミクスや電子デバイスの動作解析において重要です。

## クランク・ニコルソン法

時間依存シュレーディンガー方程式 $i pdv(psi, t) = H psi$ を時間積分する際、単純なオイラー法を使うと、波動関数のノルム（全存在確率）が保存されず、発散してしまいます。
量子力学のシミュレーションでは、時間発展演算子が**ユニタリ**である（ノルムを保存する）ことが必須です。

**クランク・ニコルソン法 (Crank-Nicolson Method)** は、陰解法の一種で、ユニタリ性と2次の精度を持ち、無条件安定です。

$$ (1 + i Delta t / 2 H) psi^(n+1) = (1 - i Delta t / 2 H) psi^n $$

あるいは、

$$ psi^(n+1) = 1 / (1 + i Delta t / 2 H) (1 - i Delta t / 2 H) psi^n $$

これを解くには、各ステップで連立一次方程式 $A vb(x) = vb(b)$ を解く必要があります。ここで行列 $A$ は三重対角行列になるため、トーマス法（TDMA）を使って $O(N)$ で高速に解くことができます。

## スプリット演算子法 (Split-Operator Method)

より高速で高精度な手法として、**スプリット演算子法**があります。
ハミルトニアンを運動エネルギー $T$ とポテンシャル $V$ に分け、時間発展演算子 $e^(-i Delta t (T+V))$ を近似的に分解します（トロッター分解）。

$$ e^(-i Delta t (T+V)) approx e^(-i Delta t / 2 V) e^(-i Delta t T) e^(-i Delta t / 2 V) $$

- $e^(-i Delta t / 2 V)$ は座標空間では単なる位相回転（対角行列）です。
- $e^(-i Delta t T)$ は運動量空間では単なる位相回転です。

したがって、以下の手順で計算できます。

1. **座標空間**で $e^(-i Delta t / 2 V)$ を掛ける。
2. **高速フーリエ変換 (FFT)** で運動量空間へ移行。
3. **運動量空間**で $e^(-i Delta t p^2 / 2)$ を掛ける。
4. **逆高速フーリエ変換 (IFFT)** で座標空間へ戻る。
5. **座標空間**で $e^(-i Delta t / 2 V)$ を掛ける。

FFTを利用するため、計算量は $O(N log N)$ となり非常に高速です。

## Rustによる実装方針

スプリット演算子法を実装するには、[第6章](../ch06-fourier/)で紹介した `rustfft` クレートを使用します。

```rust
// 擬似コード
fn step(psi: &mut Vec<Complex64>) {
    // 1. Potential half-step
    apply_potential(psi, 0.5 * dt);

    // 2. FFT
    fft_planner.process(psi);

    // 3. Kinetic step (in k-space)
    apply_kinetic_in_k_space(psi, dt);

    // 4. IFFT
    ifft_planner.process(psi);

    // 5. Potential half-step
    apply_potential(psi, 0.5 * dt);
}
```

この手法は、ガウス波束の運動やトンネル効果のシミュレーションなどに非常に適しています。
次節では、これを用いてトンネル効果を見てみましょう。
