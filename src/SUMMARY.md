# Summary

[はじめに](./README.md)

# 第1部: 基礎編

- [Rustと計算物理学](./ch01-introduction/README.md)
  - [なぜRustなのか](./ch01-introduction/why-rust.md)
  - [開発環境のセットアップ](./ch01-introduction/setup.md)
  - [数値計算結果の可視化](./ch01-introduction/plotting.md)
  - [本書の使い方](./ch01-introduction/how-to-use.md)

- [計算機の基本モデル](./ch02-computer-model/README.md)
  - [CPU・メモリ・ストレージ](./ch02-computer-model/cpu-memory-storage.md)
  - [latency・bandwidth・cache line](./ch02-computer-model/latency-bandwidth-cache.md)
  - [連続アクセスと1次元データ](./ch02-computer-model/data-layout.md)
  - [stackとheap](./ch02-computer-model/stack-heap.md)

- [Rustで数値計算を書く最小セット](./ch03-rust-numerics/README.md)
  - [数値型・関数・小さいテスト](./ch03-rust-numerics/numbers-functions-tests.md)
  - [浮動小数点演算と誤差](./ch03-rust-numerics/floating-point.md)
  - [Vecとスライス](./ch03-rust-numerics/vec-slices-ownership.md)
  - [Resultとmodule境界](./ch03-rust-numerics/result-modules.md)

- [多次元データと配列](./ch04-multidimensional-data/README.md)
  - [1次元データから多次元データへ](./ch04-multidimensional-data/arrays-vectors.md)
  - [多次元配列とメモリレイアウト](./ch04-multidimensional-data/memory-layout.md)
  - [外部クレートの活用（ndarray入門）](./ch04-multidimensional-data/ndarray.md)
  - [発展的なテンソルライブラリ tenferro](./ch04-multidimensional-data/tenferro.md)
  - [データ保存とmetadata](./ch04-multidimensional-data/data-storage.md)

# 第2部: 数値計算手法

- [作業用ディレクトリのセットアップ](./ch05-workspace-setup/README.md)

- [数値微分と数値積分](./ch03-calculus/README.md)
  - [数値微分](./ch03-calculus/differentiation.md)
  - [数値積分（台形則・シンプソン則）](./ch03-calculus/integration.md)
  - [ガウス求積法](./ch03-calculus/gaussian-quadrature.md)
  - [適応型積分](./ch03-calculus/adaptive-integration.md)

- [線形代数](./ch04-linear-algebra/README.md)
  - [行列演算の基礎](./ch04-linear-algebra/matrix-ops.md)
  - [連立一次方程式（ガウスの消去法・LU分解）](./ch04-linear-algebra/linear-systems.md)
  - [固有値問題](./ch04-linear-algebra/eigenvalue.md)
  - [スパース行列](./ch04-linear-algebra/sparse.md)

- [非線形方程式と最適化](./ch05-nonlinear/README.md)
  - [二分法とニュートン法](./ch05-nonlinear/root-finding.md)
  - [多変数のニュートン法](./ch05-nonlinear/multivariable-newton.md)
  - [最急降下法と共役勾配法](./ch05-nonlinear/optimization.md)

- [フーリエ解析](./ch06-fourier/README.md)
  - [離散フーリエ変換の基礎](./ch06-fourier/dft-basics.md)
  - [高速フーリエ変換（FFT）](./ch06-fourier/fft.md)
  - [スペクトル解析と応用](./ch06-fourier/spectral-analysis.md)

- [常微分方程式](./ch07-ode/README.md)
  - [オイラー法](./ch07-ode/euler.md)
  - [ルンゲ＝クッタ法](./ch07-ode/runge-kutta.md)
  - [適応型刻み幅制御](./ch07-ode/adaptive-step.md)
  - [境界値問題（シューティング法）](./ch07-ode/boundary-value.md)

- [偏微分方程式](./ch08-pde/README.md)
  - [差分法の基礎](./ch08-pde/finite-difference.md)
  - [拡散方程式（熱伝導）](./ch08-pde/diffusion.md)
  - [波動方程式](./ch08-pde/wave.md)
  - [ラプラス方程式とポアソン方程式](./ch08-pde/elliptic.md)

- [モンテカルロ法](./ch09-monte-carlo/README.md)
  - [乱数生成](./ch09-monte-carlo/random-numbers.md)
  - [モンテカルロ積分](./ch09-monte-carlo/integration.md)
  - [重点サンプリング](./ch09-monte-carlo/importance-sampling.md)
  - [マルコフ連鎖モンテカルロ法（MCMC）](./ch09-monte-carlo/mcmc.md)

# 第3部: 物理シミュレーション

- [古典力学シミュレーション](./ch10-classical-mechanics/README.md)
  - [質点系の運動](./ch10-classical-mechanics/particle-motion.md)
  - [シンプレクティック積分法](./ch10-classical-mechanics/symplectic.md)
  - [惑星運動（ケプラー問題）](./ch10-classical-mechanics/kepler.md)
  - [分子動力学入門](./ch10-classical-mechanics/molecular-dynamics.md)

- [流体力学](./ch11-fluid-dynamics/README.md)
  - [ナビエ＝ストークス方程式の基礎](./ch11-fluid-dynamics/navier-stokes.md)
  - [差分法による流体シミュレーション](./ch11-fluid-dynamics/finite-difference-cfd.md)
  - [格子ボルツマン法](./ch11-fluid-dynamics/lattice-boltzmann.md)

- [統計力学シミュレーション](./ch12-statistical-mechanics/README.md)
  - [イジング模型の基礎](./ch12-statistical-mechanics/ising-basics.md)
  - [メトロポリス法](./ch12-statistical-mechanics/metropolis.md)
  - [相転移とクリティカル現象](./ch12-statistical-mechanics/phase-transition.md)
  - [2D Ising実践演習](./ch12-statistical-mechanics/ising-exercise.md)
  - [その他の格子模型](./ch12-statistical-mechanics/other-models.md)

- [量子力学](./ch13-quantum-mechanics/README.md)
  - [シュレーディンガー方程式の数値解法](./ch13-quantum-mechanics/schrodinger.md)
  - [1次元束縛状態（調和振動子・井戸型ポテンシャル）](./ch13-quantum-mechanics/bound-states.md)
  - [時間発展とスプリット演算子法](./ch13-quantum-mechanics/time-evolution.md)
  - [散乱問題](./ch13-quantum-mechanics/scattering.md)

# 第4部: 高度なトピック

- [並列計算](./ch14-parallel/README.md)
  - [Rayonによるデータ並列化](./ch14-parallel/rayon.md)
  - [SIMD最適化](./ch14-parallel/simd.md)
  - [パフォーマンス測定とプロファイリング](./ch14-parallel/profiling.md)
  - [GPU計算への展望](./ch14-parallel/gpu-outlook.md)

# 付録

- [付録A: 参考資料](./appendix/a-references.md)
- [付録B: 有用なクレート集](./appendix/b-crates.md)
- [付録C: デバッグとトラブルシューティング](./appendix/c-debugging.md)
- [付録D: 数学的背景](./appendix/d-math-background.md)
- [付録E: 高精度演算](./appendix/e-high-precision.md)
