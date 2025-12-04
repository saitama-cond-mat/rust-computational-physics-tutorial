# Summary

[はじめに](./README.md)

# 第1部: 基礎編

- [Rustと計算物理学](./ch01-introduction/README.md)
  - [なぜRustなのか](./ch01-introduction/why-rust.md)
  - [開発環境のセットアップ](./ch01-introduction/setup.md)
  - [数値計算の結果の描画](./ch01-introduction/plotting.md)]
  - [本書の使い方](./ch01-introduction/how-to-use.md)

- [数値計算の基礎](./ch02-basics/README.md)
  - [浮動小数点演算と誤差](./ch02-basics/floating-point.md)
  - [配列とベクトル演算](./ch02-basics/arrays-vectors.md)
  - [外部クレートの活用（ndarray入門）](./ch02-basics/ndarray.md)
  - [高精度演算（xprec-rs）](./ch02-basics/xprec.md)

# 第2部: 数値計算手法

- [数値微分と数値積分](./ch03-calculus/README.md)
  - [数値微分](./ch03-calculus/differentiation.md)
  - [数値積分（台形則・シンプソン則）](./ch03-calculus/integration.md)
  - [モンテカルロ積分](./ch03-calculus/monte-carlo.md)

- [線形代数](./ch04-linear-algebra/README.md)
  - [行列演算の基礎](./ch04-linear-algebra/matrix-ops.md)
  - [連立一次方程式（ガウスの消去法）](./ch04-linear-algebra/linear-systems.md)
  - [固有値問題](./ch04-linear-algebra/eigenvalue.md)

- [常微分方程式](./ch05-ode/README.md)
  - [オイラー法](./ch05-ode/euler.md)
  - [ルンゲ=クッタ法](./ch05-ode/runge-kutta.md)
  - [応用例：単振動と減衰振動](./ch05-ode/oscillation.md)

- [偏微分方程式](./ch06-pde/README.md)
  - [差分法の基礎](./ch06-pde/finite-difference.md)
  - [拡散方程式](./ch06-pde/diffusion.md)
  - [波動方程式](./ch06-pde/wave.md)

# 第3部: 物理シミュレーション

- [古典力学シミュレーション](./ch07-classical-mechanics/README.md)
  - [質点系の運動](./ch07-classical-mechanics/particle-motion.md)
  - [惑星運動（ケプラー問題）](./ch07-classical-mechanics/kepler.md)
  - [剛体の運動](./ch07-classical-mechanics/rigid-body.md)

- [モンテカルロ法](./ch08-monte-carlo/README.md)
  - [乱数生成とランダムウォーク](./ch08-monte-carlo/random-walk.md)
  - [モンテカルロ積分の詳細](./ch08-monte-carlo/integration.md)
  - [重点サンプリング](./ch08-monte-carlo/importance-sampling.md)
  - [マルコフ連鎖モンテカルロ法](./ch08-monte-carlo/mcmc.md)

- [統計力学シミュレーション](./ch09-statistical-mechanics/README.md)
  - [イジング模型の基礎](./ch09-statistical-mechanics/ising-basics.md)
  - [メトロポリス法](./ch09-statistical-mechanics/metropolis.md)
  - [相転移とクリティカル現象](./ch09-statistical-mechanics/phase-transition.md)
  - [その他の格子模型](./ch09-statistical-mechanics/other-models.md)

- [量子力学](./ch10-quantum-mechanics/README.md)
  - [シュレーディンガー方程式の数値解法](./ch10-quantum-mechanics/schrodinger.md)
  - [調和振動子](./ch10-quantum-mechanics/harmonic-oscillator.md)
  - [ポテンシャル井戸問題](./ch10-quantum-mechanics/potential-well.md)

- [流体力学](./ch11-fluid-dynamics/README.md)
  - [格子ボルツマン法入門](./ch11-fluid-dynamics/lattice-boltzmann.md)
  - [ナビエ-ストークス方程式](./ch11-fluid-dynamics/navier-stokes.md)

# 第4部: 高度なトピック

- [並列計算](./ch12-parallel/README.md)
  - [RayonによるCPU並列化](./ch12-parallel/rayon.md)
  - [SIMD最適化](./ch12-parallel/simd.md)
  - [パフォーマンス測定とプロファイリング](./ch12-parallel/profiling.md)

- [FFT（高速フーリエ変換）](./ch13-fft/README.md)
  - [離散フーリエ変換の基礎](./ch13-fft/dft-basics.md)
  - [FFTの実装と応用](./ch13-fft/fft-application.md)
  - [スペクトル解析](./ch13-fft/spectral-analysis.md)

# 付録

- [付録A: 参考資料](./appendix/a-references.md)
- [付録B: 有用なクレート集](./appendix/b-crates.md)
- [付録C: デバッグとトラブルシューティング](./appendix/c-debugging.md)
- [付録D: 数学的背景](./appendix/d-math-background.md)
