# 数値計算結果の可視化

数値計算を行う上で、結果を視覚的に確認することは非常に重要です。グラフやアニメーションを通じて、計算が正しく行われているかを検証したり、物理現象の振る舞いを直感的に理解したりできます。

この節では、数値計算の結果を可視化する方法をいくつか紹介します。

## 可視化ツールの選択

本書では、Rustで開発環境を統一するため`plotters`や`kiss3d`といったRust製ライブラリを使用しますが、読者の皆さんは使い慣れたツールを自由に使用して構いません。

可視化は、本書で扱う数値計算のアルゴリズムそのものではなく、あくまで計算結果を理解・分析するための手段です。Python (`matplotlib`)、`gnuplot`、Excel、MATLAB、Mathematicaなど、すでに習熟しているツールがあれば、そちらを使用することを推奨します。

本書のコード例から`plotters`や`kiss3d`に関する部分を省略し、代わりに計算結果をCSVファイルに出力して、お好みのツールで可視化しても全く問題ありません。

## データファイルへの出力

どのような可視化ツールを使う場合でも、まず計算結果をファイルに保存する方法を知っておくと便利です。特に、CSV (Comma-Separated Values) 形式は多くのツールでサポートされており、汎用性が高いため本書でも推奨します。もちろん、大量のデータを効率的に扱いたい場合など、用途によってはHDF5やApache Parquetといった、より高機能なフォーマットを利用することも有効です。

### CSVファイルへの出力

CSVファイルは非常に汎用的なデータ形式で、ほぼすべての可視化ツールや表計算ソフトで読み込めます。

```rust
use std::fs::File;
use std::io::Write;

fn main() -> std::io::Result<()> {
    let mut file = File::create("output.csv")?;

    // ヘッダー行を書き込む
    writeln!(file, "t,x,v")?;

    // 0.0から10.0まで0.1刻みでデータを生成して書き込む
    for i in 0..=100 {
        let t = i as f64 * 0.1;
        let x = t.sin();
        let v = t.cos();
        writeln!(file, "{},{},{}", t, x, v)?;
    }

    println!("output.csv を生成しました");
    Ok(())
}
```

このCSVファイルは、以下のような様々なツールで可視化できます。

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

CSVファイルをExcelで開き、データ範囲を選択して「挿入」タブからグラフを作成するだけで、簡単に可視化できます。

---

## Rust製ライブラリによる可視化

以下では、本書で使用するRust製の可視化ライブラリについて説明します。**これらを使用せず、前述のCSV出力と外部ツールを組み合わせる方法でも学習を進められます。**

### plotters (2Dグラフ描画)

[plotters](https://crates.io/crates/plotters)は、Rustで最も広く使われている2Dプロットライブラリの一つです。

**主な特徴:**

- 折れ線グラフ、散布図、ヒストグラム、ヒートマップなど多彩なグラフ形式をサポート
- PNG, SVG, HTMLなど複数の出力形式に対応
- 純粋なRustで実装されており、外部ライブラリへの依存が最小限
- 高いカスタマイズ性

### kiss3d (3D可視化)

[kiss3d](https://crates.io/crates/kiss3d)は、シンプルで使いやすい3Dグラフィックスライブラリです。

**主な特徴:**

- リアルタイムの3D描画が可能
- シンプルなAPIで手軽に3Dシーンを構築
- 球、立方体、円柱などの基本図形を簡単に描画
- マウスによるカメラ操作や簡易的なアニメーションをサポート

## 可視化ライブラリのセットアップ

これらのライブラリを使用するには、プロジェクトの`Cargo.toml`に依存関係として追加します。

### plottersの追加

```toml
[dependencies]
plotters = "0.3"
```

### kiss3dの追加

```toml
[dependencies]
kiss3d = "0.35"
nalgebra = "0.32"  # kiss3dの3Dベクトル・行列計算に使用
```

## plottersによる2Dグラフ描画

### 基本的な使い方

以下のコードは、正弦波のグラフを描画して`sine_wave.png`というファイル名で保存します。

```rust
use plotters::prelude::*;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    // 描画先のバックエンドとして800x600ピクセルのPNG画像を指定
    let root = BitMapBackend::new("sine_wave.png", (800, 600)).into_drawing_area();
    root.fill(&WHITE)?;

    // グラフの各種設定
    let mut chart = ChartBuilder::on(&root)
        .caption("正弦波", ("sans-serif", 30))
        .margin(20)
        .x_label_area_size(40)
        .y_label_area_size(40)
        .build_cartesian_2d(0.0..10.0, -1.5..1.5)?;

    // 軸とグリッド線の描画
    chart.configure_mesh().draw()?;

    // データ系列の描画
    chart.draw_series(LineSeries::new(
        (0..=1000).map(|i| {
            let x = i as f64 / 100.0;
            (x, x.sin())
        }),
        &RED,
    ))?;

    // 描画内容をファイルに書き出す
    root.present()?;
    println!("sine_wave.png を生成しました");
    Ok(())
}
```

実行すると、カレントディレクトリに`sine_wave.png`が生成されます。

### コードの解説

`plotters`でのグラフ描画は、概ね以下の手順で行います。

1.  **バックエンドの作成**: `BitMapBackend` (PNG出力) や `SVGBackend` (SVG出力) など、描画先を指定します。
2.  **背景の塗りつぶし**: `fill(&WHITE)`などで背景色を設定します。
3.  **チャートの構築**: `ChartBuilder`で軸の範囲、タイトル、マージンなどを設定します。
4.  **メッシュ (軸とグリッド線) の描画**: `configure_mesh().draw()`で描画します。
5.  **データ系列の描画**: `draw_series`に`LineSeries` (折れ線グラフ) などを渡してプロットします。
6.  **ファイルへの保存**: `present()`でここまでの描画内容をファイルに書き出します。

### 複数系列の描画

複数のデータ系列を同じグラフに描画するには、`draw_series`を複数回呼び出します。凡例 (legend) も追加できます。

```rust
use plotters::prelude::*;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let root = BitMapBackend::new("multi_plot.png", (800, 600)).into_drawing_area();
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
        (0..=1000).map(|i| {
            let x = i as f64 / 100.0;
            (x, x.sin())
        }),
        &RED,
    ))?
    .label("sin(x)")
    .legend(|(x, y)| PathElement::new(vec![(x, y), (x + 20, y)], &RED));

    // cos(x)
    chart.draw_series(LineSeries::new(
        (0..=1000).map(|i| {
            let x = i as f64 / 100.0;
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

以下のコードは、回転する立方体を描画するウィンドウを表示します。

```rust
use kiss3d::light::Light;
use kiss3d::window::Window;
use nalgebra::{UnitQuaternion, Vector3};

fn main() {
    // ウィンドウの作成
    let mut window = Window::new("kiss3d: Cube");

    // 立方体の追加
    let mut cube = window.add_cube(1.0, 1.0, 1.0);
    cube.set_color(0.0, 0.5, 1.0); // 青色

    // 光源の設定
    window.set_light(Light::StickToCamera);

    // メインループ
    while window.render() {
        // Y軸を中心に少し回転させる
        let rotation = UnitQuaternion::from_axis_angle(&Vector3::y_axis(), 0.01);
        cube.prepend_to_local_rotation(&rotation);
    }
}
```

実行するとウィンドウが開き、青い立方体がY軸を中心に回転する様子が表示されます。ウィンドウを閉じるとプログラムは終了します。

### カメラ操作

`kiss3d`のウィンドウでは、マウスを使って直感的にカメラを操作できます。

- **左ドラッグ**: 回転
- **右ドラッグ**: 平行移動
- **スクロール**: ズームイン/ズームアウト

## まとめ

この節では、数値計算の結果を可視化する方法について紹介しました。

> [!IMPORTANT]
>
> - **可視化ツールは自由に選択できます**。本書では`plotters`と`kiss3d`を紹介しましたが、Python、`gnuplot`、Excelなど、使い慣れたツールで構いません。
> - **CSVファイルへの出力**は、ツール間のデータ連携に便利なため推奨される方法です。
> - 本書の学習において重要なのは**数値計算のアルゴリズムとRustによる実装**であり、可視化はその結果を確認・分析するための手段です。

次節では、本書全体の構成や学習の進め方について、より詳しく見ていきましょう。
