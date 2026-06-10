# 線形代数

> [!IMPORTANT]
> **この章を読む前に**
>
> この章を読むには、以下の章を先に読んでおく必要があります。
>
> - [多次元データと配列](../ch04-multidimensional-data/)（特に[ndarray入門](../ch04-multidimensional-data/ndarray.md)）

## 本章の概要

物理シミュレーションにおいて、線形代数は最も重要な道具の一つです。偏微分方程式の離散化、量子力学におけるハミルトニアンの対角化、データ解析における主成分分析など、あらゆる場面で行列やベクトルが現れます。

本章では、Rustを用いて線形代数の問題を数値的に解く方法を学びます。特に、[多次元データと配列](../ch04-multidimensional-data/)で導入した`ndarray`クレートを基礎とし、線形代数演算に特化した`ndarray-linalg`クレートなどを活用して、効率的かつ安全なコードを記述することを目指します。

## 本章で扱うトピック

1. **[行列演算の基礎](./matrix-ops.md)**
   - ノルム、トレース、行列式などの基本量の計算
   - 逆行列と条件数
   - `ndarray-linalg`の導入

2. **[連立一次方程式](./linear-systems.md)**
   - $A vb(x) = vb(b)$ の数値解法
   - ガウスの消去法とLU分解
   - コレスキー分解（対称正定値行列の場合）

3. **[固有値問題](./eigenvalue.md)**
   - 固有値と固有ベクトルの計算
   - べき乗法（Power Iteration）の実装
   - エルミート行列の対角化

4. **[スパース行列](./sparse.md)**
   - 疎行列（スパース行列）とは
   - CSR/CSC形式
   - `sprs`クレートを用いた大規模疎行列の計算

## 準備

本章のサンプルコードを実行するには、`Cargo.toml`に以下の依存関係を追加する必要があります（バージョンは執筆時点の目安です）。

```toml
[dependencies]
ndarray = "0.17" # またはそれ以降
ndarray-linalg = "0.18" # BLASバックエンドが必要
```

> [!WARNING]
> **ndarray-linalgとBLAS**
> `ndarray-linalg`を使用するには、システムにBLAS/LAPACKライブラリ（OpenBLAS, Intel MKLなど）がインストールされている必要があります。macOSではAccelerateフレームワークが標準で利用可能ですが、執筆時点では`ndarray-linalg`が対応していません。
> その為、各OSでOpenBLASなどを別途インストールする必要がある場合があります。

## 作業テーマ

作業ディレクトリは `~/rust-computational-physics-work/` からの相対パスです。
ユニットテストで確認する具体的なケースは、解析解、境界条件、許容誤差の観点からAI coding agentと相談して決めます。

| テーマ         | 作業ディレクトリ                | 構造化するコード                                 | ユニットテスト演習                        | 拡張演習                             |
| -------------- | ------------------------------- | ------------------------------------------------ | ----------------------------------------- | ------------------------------------ |
| 行列演算       | `linear-algebra/matrix-ops`     | `matmul`, `transpose`, `norm`                    | 小さい行列の積とノルムを手計算と比較する  | loop orderを変えて実行時間を比較する |
| 連立一次方程式 | `linear-algebra/linear-systems` | `solve`, `residual_norm`, `is_square`            | 既知解を持つ小さい行列で残差を確認する    | 複数右辺を解く例へ拡張する           |
| 固有値問題     | `linear-algebra/eigenvalue`     | `power_iteration`, `normalize`, `eigen_residual` | 対角行列や2x2行列で固有値を確認する       | 収束履歴をCSVに出力する              |
| スパース行列   | `linear-algebra/sparse`         | `build_laplacian_1d`, `matvec`                   | 小さい1次元ラプラシアンを手計算と比較する | dense表現とのメモリ量を比較する      |

## 検証と実装の観点

線形代数のコードは、計算が完了しても正しいとは限りません。既知の小さい行列で
手計算できる例を用意し、さらに大きい問題では残差や条件数を確認します。

- 行列とベクトルのshapeを最初に確認し、サイズ不一致を曖昧に扱わない。
- 連立一次方程式では、解そのものだけでなく $A vb(x) - vb(b)$ の残差を確認する。
- 固有値問題では、正規化と $A vb(v) - lambda vb(v)$ の残差を確認する。
- `ndarray-linalg`を使う場合は、BLAS/LAPACK backendとcrate versionを記録する。
