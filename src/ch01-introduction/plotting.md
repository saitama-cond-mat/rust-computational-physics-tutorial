# 数値計算の結果の描画

数値計算を行う上で，結果を視覚的に確認することは非常に重要です．グラフやアニメーションを通じて，計算結果の妥当性を検証したり，物理現象の振る舞いを直感的に理解したりすることができます．

本章では，数値計算結果の可視化方法について紹介します．

## 可視化ツールの選択について

本書ではRustで開発環境を統一するためにplottersやkiss3dといったRust製のライブラリを使用しますが，読者の皆さんは使い慣れた任意のツールを使用して構いません．

可視化は数値計算の本質的な部分ではなく，計算結果を確認・分析するための手段です．Python（matplotlib），gnuplot，Excel，MATLAB，Mathematicaなど，すでに習熟しているツールがあれば，そちらを使用することを推奨します，

本書のコード例からplottersやkiss3dの部分を省略し，CSVファイルへの出力のみを行って，お好みのツールで可視化しても全く問題ありません．

## データファイルへの出力

どのような可視化ツールを使う場合でも，まず計算結果をファイルに保存する方法を知っておくと便利です．
特に，CSV（Comma-Separated Values）形式は多くのツールでサポートされており，汎用的に利用できるため，本書では推奨します．

### CSVファイルへの出力

CSVファイルは最も汎用的なデータ形式で，ほぼすべての可視化ツールで読み込めます．

```rust
use std::fs::File;
use std::io::Write;

fn main() -> std::io::Result<()> {
    let mut file = File::create("output.csv")?;

    // ヘッダー行
    writeln!(file, "t,x,v")?;

    // データの書き込み
    for i in 0..100 {
        let t = i as f64 * 0.1;
        let x = t.sin();
        let v = t.cos();
        writeln!(file, "{},{},{}", t, x, v)?;
    }

    println!("output.csv を生成しました");
    Ok(())
}
```

このCSVファイルは，以下のような様々なツールで可視化できます．

### Pythonでの可視化例

```python
import pandas as pd
import matplotlib.pyplot as plt

# CSVファイルの読み込み
df = pd.read_csv("output.csv")

# グラフの描画
plt.figure(figsize=(10, 6))
plt.plot(df["t"], df["x"], label="位置 x")
plt.plot(df["t"], df["v"], label="速度 v")
plt.xlabel("時間 t")
plt.ylabel("値")
plt.legend()
plt.grid(True)
plt.savefig("plot.png")
plt.show()
```

### gnuplotでの可視化例

```gnuplot
set datafile separator ","
set xlabel "時間 t"
set ylabel "値"
set grid
plot "output.csv" using 1:2 with lines title "位置 x", \
     "output.csv" using 1:3 with lines title "速度 v"
```

### Excelでの可視化

CSVファイルをExcelで開き，データ範囲を選択してグラフを挿入するだけで可視化できます．

---

## Rust製可視化ライブラリ

以下では，本書で使用するRust製の可視化ライブラリについて説明します．**これらを使用せず，上記のCSV出力と外部ツールの組み合わせで進めても構いません．**

### plotters（2Dグラフ描画）

[plotters](https://crates.io/crates/plotters)は，Rustで最も広く使われている2Dプロットライブラリです．

**主な特徴：**

- 折れ線グラフ，散布図，ヒストグラム，ヒートマップなど多彩なグラフ形式をサポート
- PNG，SVG，HTMLなど複数の出力形式に対応
- 純粋なRustで実装されており，外部依存が最小限
- 高いカスタマイズ性

### kiss3d（3D可視化）

[kiss3d](https://crates.io/crates/kiss3d)は，シンプルで使いやすい3Dグラフィックスライブラリです．

**主な特徴：**

- リアルタイムの3D描画が可能
- シンプルなAPIで手軽に3Dシーンを構築
- 球体，立方体などの基本図形を簡単に描画
- カメラ操作やアニメーションのサポート

## 可視化ライブラリのセットアップ

可視化ライブラリを使用するには，プロジェクトの`Cargo.toml`に依存関係を追加します．

### plottersの追加

```toml
[dependencies]
plotters = "0.3"
```

### kiss3dの追加

```toml
[dependencies]
kiss3d = "0.35"
nalgebra = "0.32"  # kiss3dの座標計算に使用
```

## plottersによる2Dグラフ描画

### 基本的な使い方

以下のコードは，正弦波のグラフを描画してPNGファイルとして保存します．

```rust
use plotters::prelude::*;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    // 描画領域の作成（800x600ピクセルのPNG画像）
    let root = BitMapBackend::new("sine_wave.png", (800, 600))
        .into_drawing_area();
    root.fill(&WHITE)?;

    // グラフの設定
    let mut chart = ChartBuilder::on(&root)
        .caption("正弦波", ("sans-serif", 30))
        .margin(20)
        .x_label_area_size(40)
        .y_label_area_size(40)
        .build_cartesian_2d(0.0..10.0, -1.5..1.5)?;

    // 軸の描画
    chart.configure_mesh().draw()?;

    // データの描画
    chart.draw_series(LineSeries::new(
        (0..=1000).map(|x| {
            let x = x as f64 / 100.0;
            (x, x.sin())
        }),
        &RED,
    ))?;

    root.present()?;
    println!("sine_wave.png を生成しました");
    Ok(())
}
```

実行すると，カレントディレクトリに`sine_wave.png`というファイルが生成されます．

### コードの解説

plottersでのグラフ描画は，以下の手順で行います．

1. **バックエンドの作成**：`BitMapBackend`（PNG出力）や`SVGBackend`（SVG出力）を選択
2. **背景の塗りつぶし**：`fill(&WHITE)`で背景色を設定
3. **チャートの構築**：`ChartBuilder`で軸の範囲，タイトル，余白などを設定
4. **メッシュの描画**：`configure_mesh().draw()`でグリッド線と軸ラベルを描画
5. **データ系列の描画**：`draw_series`でデータをプロット
6. **ファイル出力**：`present()`で描画内容をファイルに書き出し

### 複数の曲線を重ねて描画

```rust
use plotters::prelude::*;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let root = BitMapBackend::new("multi_plot.png", (800, 600))
        .into_drawing_area();
    root.fill(&WHITE)?;

    let mut chart = ChartBuilder::on(&root)
        .caption("三角関数", ("sans-serif", 30))
        .margin(20)
        .x_label_area_size(40)
        .y_label_area_size(40)
        .build_cartesian_2d(0.0..10.0, -1.5..1.5)?;

    chart.configure_mesh()
        .x_desc("x")
        .y_desc("y")
        .draw()?;

    // sin(x)
    chart.draw_series(LineSeries::new(
        (0..=1000).map(|x| {
            let x = x as f64 / 100.0;
            (x, x.sin())
        }),
        &RED,
    ))?
    .label("sin(x)")
    .legend(|(x, y)| PathElement::new(vec![(x, y), (x + 20, y)], &RED));

    // cos(x)
    chart.draw_series(LineSeries::new(
        (0..=1000).map(|x| {
            let x = x as f64 / 100.0;
            (x, x.cos())
        }),
        &BLUE,
    ))?
    .label("cos(x)")
    .legend(|(x, y)| PathElement::new(vec![(x, y), (x + 20, y)], &BLUE));

    // 凡例の描画
    chart.configure_series_labels()
        .border_style(&BLACK)
        .draw()?;

    root.present()?;
    Ok(())
}
```

## kiss3dによる3D可視化

### 基本的な使い方

以下のコードは，回転する立方体を描画するウィンドウを表示します．

```rust
use kiss3d::light::Light;
use kiss3d::window::Window;

fn main() {
    // ウィンドウの作成
    let mut window = Window::new("kiss3d テスト");

    // 立方体の追加
    let mut cube = window.add_cube(1.0, 1.0, 1.0);
    cube.set_color(0.0, 0.5, 1.0);  // 青色

    // 光源の設定
    window.set_light(Light::StickToCamera);

    // メインループ
    while window.render() {
        cube.prepend_to_local_rotation(&nalgebra::UnitQuaternion::from_axis_angle(
            &nalgebra::Vector3::y_axis(),
            0.02,
        ));
    }
}
```

実行すると，ウィンドウが開き，青い立方体が回転する様子が表示されます．ウィンドウを閉じるとプログラムが終了します．

### カメラ操作

kiss3dでは，マウスでカメラを操作できます．

- **左ドラッグ**：回転
- **右ドラッグ**：平行移動
- **スクロール**：ズーム

## まとめ

本章では，数値計算結果の可視化について紹介しました．

重要なポイントを再度強調します．

> [!IMPORTANT]
>
> - **可視化ツールは自由に選択してください**．本書ではplottersとkiss3dを使用するが，Python，gnuplot，Excel等，使い慣れたツールで構わない
> - **CSVファイルへの出力**はどのツールでも読み込めるため，本書では推奨
> - 本書の学習において重要なのは**数値計算のアルゴリズムと実装**であり，可視化は結果確認の手段

次章では，本書の使い方と各章の概要について説明します．
