# パフォーマンス測定とプロファイリング

最適化の第一歩は、プログラムのどこが遅いのかを正確に把握することです。
数値計算プログラムにおいて、勘に頼った最適化は往々にして失敗します。

## ベンチマーク：Criterion

Rustで精密なベンチマークを取るための標準的なライブラリが **Criterion** です。
実行時間の統計的なばらつきを考慮し、微小な変化を正確に測定できます。

`Cargo.toml` に設定を追加し、`benches/my_benchmark.rs` を以下のように記述します。

```rust
use criterion::{black_box, criterion_group, criterion_main, Criterion};

fn heavy_computation(n: u64) -> u64 {
    (0..n).sum()
}

fn criterion_benchmark(c: &mut Criterion) {
    c.bench_function("sum 1000", |b| b.iter(|| {
        heavy_computation(black_box(1000))
    }));
}

criterion_group!(benches, criterion_benchmark);
criterion_main!(benches);
```

`cargo bench` を実行すると、詳細な統計レポートが `target/criterion/` に生成されます。`black_box` を使うことで、コンパイラによる過度な最適化（計算自体を消し去ること）を防ぎ、正しく測定を行うことができます。

## プロファイリング：Flamegraph

プログラムの実行時間のうち、どの関数が何パーセントを占めているかを視覚化するのが **フレームグラフ (Flamegraph)** です。

Rustでは `cargo-flamegraph` を使うことで、簡単に生成できます。

```bash
cargo install cargo-flamegraph
cargo flamegraph -- [プログラムの引数]
```

生成された `flamegraph.svg` をブラウザで開くと、横幅が実行時間に相当するスタックトレースが表示されます。
幅の広い（＝時間がかかっている）関数を特定し、そこを集中的に最適化するのが鉄則です。

## 最適化のステップ

1. **リリースモードで実行**: 常に `cargo run --release` で測定してください。デバッグモードとは速度が数十倍〜数百倍異なります。
2. **ボトルネックの特定**: フレームグラフで最も重い関数を見つける。
3. **アルゴリズムの改善**: オーダー ($O(N^2)$ から $O(N log N)$ へなど）を改善できないか検討する。
4. **並列化・SIMD化**: ボトルネックとなっているループを `Rayon` や `SIMD` で高速化する。
5. **再測定**: 効果を確認する。
