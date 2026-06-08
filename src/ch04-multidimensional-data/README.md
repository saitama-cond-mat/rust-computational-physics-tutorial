# 多次元データと配列

> [!IMPORTANT]
> **本章の前提知識**
>
> 本章の内容を理解するためには、以下の章を事前に学習しておく必要があります。
>
> - [Rustと計算物理学](../ch01-introduction/)
> - [計算機の基本モデル](../ch02-computer-model/)
> - [Rustで数値計算を書く最小セット](../ch03-rust-numerics/)

本章では、1次元の数値データから、多次元配列、memory layout、外部クレート、
データ保存へ進みます。以降の線形代数、偏微分方程式、統計力学、量子力学では、
多次元データを正しく扱うことが重要になります。

本章の目的は、`ndarray`を使うことだけではありません。
[計算機の基本モデル](../ch02-computer-model/)で見た
cache line、連続アクセス、stride の考え方を使い、
配列のshape、axis、copy/view、保存形式、metadataを意識して、
計算結果を後から検証できる形で扱うことを目指します。

## 本章の構成

- **[1次元データから多次元データへ](./arrays-vectors.md)**
  Rust標準の配列、スライス、`Vec<T>`を出発点として、ベクトル、行列、格子データへ進む準備をします。

- **[多次元配列とメモリレイアウト](./memory-layout.md)**
  flattening、row-major、column-major、stride、view/copyの違いをRustの配列で確認します。

- **[外部クレートの活用（ndarray入門）](./ndarray.md)**
  Rustの科学技術計算で標準的に使われる軽量な`ndarray`クレートと、
  LAPACK系の線形代数を使う`ndarray-linalg`の位置づけを確認します。

- **[発展的なテンソルライブラリ tenferro](./tenferro.md)**
  `ndarray`を確認した後、自動微分、GPU実行、テンソル縮約を扱う
  発展的な選択肢としてtenferroを確認します。

- **[データ保存とmetadata](./data-storage.md)**
  CSV、HDF5、NumPy形式、metadataの使い分けを整理します。

本章を終えることで、読者は多次元の数値データをRustで扱い、保存し、後続の解析や可視化につなげるための基礎を習得できます。
