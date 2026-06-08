# 2D Ising実践演習

この演習では、2次元正方格子イジング模型を題材にして、理論的に分かっている性質、実装計画、検証を一つの流れとして扱います。
いきなりコードを書かず、第1章の「AI agent を使う標準的な流れ」と同じく、まず note、次に PLAN、最後に実装とチェックへ進みます。

扱う模型は、外部磁場なし ($h = 0$) の強磁性イジング模型です。

$$ H = -J sum_((i, j)) s_i s_j $$

ここで $sum_((i, j))$ は最近接ペアに対する和、$s_i$ は $+1$ または $-1$、$J > 0$ は強磁性相互作用です。
格子サイズを $L times L$、スピン数を $N = L^2$、総磁化を $M = sum_i s_i$、単位スピンあたりの磁化を $m = M / N$ とします。

## 1. 厳密解ノート

まず、厳密解の導出を追う必要はありません。
実装と検証に必要な性質を、自分の note にまとめます。

外部磁場なしの2次元正方格子イジング模型では、熱力学極限で臨界温度が厳密に分かっています。

$$ sinh(2 beta_c J) = 1 $$

したがって、

$$ k_B T_c / J = 2 / ln(1 + sqrt(2)) approx 2.269185 $$

です。
また、熱力学極限の自発磁化は、$T < T_c$ で

$$ m_0(T) = [1 - 1 / sinh^4(2 beta J)]^(1/8) $$

となり、$T >= T_c$ ではゼロです。
これは有限格子の単純な平均磁化そのものではなく、熱力学極限で対称性が破れた相を選んだときの量です。

有限サイズの分配関数は有限個の指数関数の和なので、自由エネルギーは温度の滑らかな関数です。
したがって、厳密な意味での相転移の特異点は $L -> infinity$ の極限で現れます。
有限サイズのシミュレーションでは、磁化の変化や比熱のピークは丸まり、ピーク位置も厳密な $T_c$ からずれます。

## 2. 対称性と測定量

$h = 0$ では、すべてのスピンを反転する変換 $s_i -> -s_i$ に対してハミルトニアンは不変です。
そのため、有限サイズの平衡分布では $P(M) = P(-M)$ となり、厳密にサンプリングすれば

$$ chevron.l M chevron.r = 0 $$

です。
一方で、$chevron.l M^2 chevron.r$ はゼロではありません。
低温では分布が $+M_0$ と $-M_0$ の二つの山を持つため、相の大きさは $chevron.l M chevron.r$ ではなく $chevron.l |M| chevron.r$ や $chevron.l M^2 chevron.r$ で見るのが実用的です。

この演習では、以下の量を保存します。

- 磁化の大きさ: $chevron.l |m| chevron.r = chevron.l |M| chevron.r / N$
- 磁化の2乗: $chevron.l m^2 chevron.r = chevron.l M^2 chevron.r / N^2$
- 帯磁率: $chi = beta / N (chevron.l M^2 chevron.r - chevron.l M chevron.r^2)$
- 比熱: $C = beta^2 / N (chevron.l E^2 chevron.r - chevron.l E chevron.r^2)$
- Binder parameter: $U_L$

Binder parameter は次のように定義します。

$$ U_L = 1 - chevron.l M^4 chevron.r / (3 chevron.l M^2 chevron.r^2) $$

Binder parameter は、全磁化 $M$ で計算しても単位スピンあたりの磁化 $m$ で計算しても同じ値になります。
高温側で $U_L$ は0に近づき、低温側で $2/3$ に近づきます。
異なる $L$ の $U_L(T)$ は、有限サイズ補正を除いて $T_c$ 付近で交差します。

## 3. PLAN

実装前に、`notes/ising-plan.md` のような短い計画を書きます。
AI coding agent に依頼する場合も、最初にこの計画を出させ、人間が確認してから実装へ進みます。

最低限、次を決めます。

- 模型: 2次元正方格子、周期境界条件、$h = 0$、$J = 1$、$k_B = 1$
- 更新: 単一スピン反転の Metropolis 法
- 測定: エネルギー、磁化、その揺らぎ、Binder parameter に必要な量
- 走査: 複数の $L$ と $T$、特に $T_c approx 2.269$ の近傍
- 乱数: seed、熱化 sweep 数、測定 sweep 数、測定間隔
- 出力: CSV と metadata。seed、$L$、$T$、sweep 数、測定間隔を必ず保存する
- 検証: 決定的に確認できる性質と、統計的に確認する性質を分ける

関数境界や module 構成は、AI coding agent と相談して決めます。
ただし、物理的な意味がある単位に分け、単に別名を付けるだけの wrapper は避けます。
相談するときは、少なくとも次の責務がどこに入るかを確認します。

- 格子と周期境界条件
- エネルギーと磁化の計算
- 1スピン反転のエネルギー差
- Metropolis 更新
- 熱化、測定、統計量の集計
- 結果保存と metadata
- Binder parameter と有限サイズスケーリング用の後処理

## 4. 決定的なユニットテスト

乱数を含むシミュレーションでも、乱数に依存しない部分は決定的にテストできます。
ここではテスト項目を固定せず、AI coding agent と一緒に「どの小さい配置なら手計算できるか」「どの性質が実装ミスを見つけやすいか」を brainstorm します。

候補になる観点は次の通りです。

- 周期境界条件が正しく実装されているか。
- 小さい格子のエネルギーと磁化が手計算と一致するか。
- 1スピン反転のエネルギー差が、反転前後の全エネルギー差と一致するか。
- Metropolis の採否判定が、エネルギーが下がる場合と上がる場合で正しいか。
- 固定 seed を使ったとき、短い実行の測定列が再現するか。

実際に `cargo test` に入れるのは、この中から選んだ少数の本質的なテストにします。
境界条件、エネルギー差の符号、bond の二重数えはバグが入りやすいので、候補として必ず検討します。

## 5. 統計量の収束チェック

MCMC の結果は乱数を含むため、すべてを通常のユニットテストに押し込むと不安定になります。
決定的なテストと、統計的なチェックを分けます。

小さい格子では全配置を列挙できます。
小さい $L$ を選べば配置数 $2^(L^2)$ がまだ扱えるので、厳密に

$$ Z = sum_({s}) exp(- beta H({s})) $$

を計算できます。
ここから $chevron.l E chevron.r$、$chevron.l E^2 chevron.r$、$chevron.l M^2 chevron.r$、$chevron.l |M| chevron.r$、$chevron.l M^4 chevron.r$、$U_L$ を求め、Metropolis の長時間平均と比較します。

このチェックは、通常の高速な unit test ではなく、`#[ignore]` を付けた統計テストや、演習用の検証スクリプトにするのが現実的です。
どの $L$、温度、seed 数、許容範囲にするかは、実行時間と揺らぎを見ながら AI coding agent と相談して決めます。
複数 seed の平均と標準誤差を保存し、厳密値が誤差棒の範囲に入るかを確認します。
確率的コードの自動テストを厳密に設計したい場合は、仮説検定を使う方法もあります。

## 6. 有限サイズスケーリング

実装後、$L = 8, 16, 32$ など複数のサイズで温度走査を行います。
まず粗い温度刻みで $T_c$ 近傍を探し、次に $T = 2.1$ から $2.4$ 程度を細かく走査します。

保存した測定量から、次をプロットします。

- $chevron.l |m| chevron.r$: 低温で非ゼロ、高温でゼロへ向かう。
- $chi$: $T_c$ 付近にピークを持つ。
- $C$: $T_c$ 付近にピークを持つ。
- $U_L$: 異なる $L$ の曲線が $T_c$ 付近で交差する。

2次元イジング模型では相関長指数が $nu = 1$ なので、臨界領域では概念的に

$$ U_L(T) approx f((T - T_c) L^(1/nu)) $$

と書けます。
この演習では、厳密なスケーリング崩壊まで要求せず、Binder parameter の交差から転移点を見積もり、

$$ T_c = 2 / ln(1 + sqrt(2)) approx 2.269185 $$

と比較します。
有限サイズ補正、熱化不足、測定間隔の不足、臨界点近傍の autocorrelation の増大が、交点のずれとして現れることも確認します。

## 発展的な問い

低温で十分長くないシミュレーションを行うと、$chevron.l M chevron.r$ がゼロにならないことがあります。
これはハミルトニアンの対称性が消えたからではありません。
有限時間の Markov chain が $+M_0$ 側または $-M_0$ 側の谷に長く留まり、符号反転をほとんど観測しないためです。
熱力学極限では、二つの相の間を行き来する時間が非常に長くなり、実効的にエルゴード性が破れたように見えます。

発展課題として、低温やスピンガラスのような緩和しにくい系では、複数温度の replica を同時に走らせて配置を交換する replica exchange Monte Carlo（exchange Monte Carlo, parallel tempering）を調べるとよいでしょう。
Hukushima と Nemoto の exchange Monte Carlo は、この考え方をスピンガラスに適用した代表的な仕事です。

## 参考リンク

- [Ising model - Wikipedia](https://en.wikipedia.org/wiki/Ising_model)
- [Binder parameter - Wikipedia](https://en.wikipedia.org/wiki/Binder_parameter)
- [Lars Onsager, Crystal Statistics. I. A Two-Dimensional Model with an Order-Disorder Transition, Phys. Rev. 65, 117 (1944)](https://doi.org/10.1103/PhysRev.65.117)
- [C. N. Yang, The Spontaneous Magnetization of a Two-Dimensional Ising Model, Phys. Rev. 85, 808 (1952)](https://doi.org/10.1103/PhysRev.85.808)
- [K. Binder, Finite size scaling analysis of Ising model block distribution functions, Z. Phys. B 43, 119 (1981)](https://doi.org/10.1007/BF01293604)
- [Markus Wallerberger and Emanuel Gull, Hypothesis testing of scientific Monte Carlo calculations](https://arxiv.org/abs/1801.01688)
- [Koji Hukushima and Koji Nemoto, Exchange Monte Carlo Method and Application to Spin Glass Simulations](https://doi.org/10.1143/JPSJ.65.1604)
