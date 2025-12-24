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
import japanize_matplotlib  # noqa
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

`plotters`と共に、CSVファイルを読み込むための`csv`クレートも依存関係に追加します。

```toml
[dependencies]
plotters = "0.3"
csv = "1.4" # CSVファイルの読み込みに必要
```

### kiss3dの追加

```toml
[dependencies]
kiss3d = "0.35"
nalgebra = "0.32"  # kiss3dの3Dベクトル・行列計算に使用
```

## plottersによる2Dグラフ描画

`plotters`を使って、先に「データファイルへの出力」で作成した`output.csv`を読み込んでグラフを描画してみましょう。

> [!NOTE]
> `plotters`で日本語のような非ASCII文字を表示するには、フォントファイルへのパスを正しく指定する必要があります。これは環境によって異なり、追加のセットアップが必要になる場合があります。
> このチュートリアルでは、追加設定なしでどの環境でもコードが動作することを優先し、グラフ内のテキストには英語を使用します。

> [!NOTE]
> この先のコードを実行する前に、`output.csv`が生成されていることを確認してください。もし生成されていない場合は、「CSVファイルへの出力」のコードを実行してください。

### CSVからのデータ読み込みと描画 (単一系列)

以下のコードは、`output.csv`ファイルを読み込み、`t`と`x`のデータを使ってグラフを描画し、`plot-single.png`というファイル名で保存します。

```rust
use plotters::prelude::*;
use csv;
use std::error::Error;

fn main() -> Result<(), Box<dyn Error>> {
    // 1. CSVファイルからデータを読み込む
    let mut reader = csv::Reader::from_path("output.csv")?;
    let data: Vec<(f64, f64)> = reader
        .records()
        .map(|r| {
            let record = r.unwrap();
            (record[0].parse().unwrap(), record[1].parse().unwrap())
        })
        .collect();

    // 2. 描画バックエンドのセットアップ
    let root = BitMapBackend::new("plot-single.png", (800, 600)).into_drawing_area();
    root.fill(&WHITE)?;

    // 3. チャートの構築
    let mut chart = ChartBuilder::on(&root)
        .caption("Position x vs. Time t (from CSV)", ("sans-serif", 30))
        .margin(20)
        .x_label_area_size(40)
        .y_label_area_size(40)
        .build_cartesian_2d(0.0..10.0, -1.5..1.5)?;

    // 4. メッシュ (軸とグリッド線) の描画
    chart.configure_mesh()
        .x_desc("Time t")
        .y_desc("Position x")
        .draw()?;

    // 5. データ系列 (t, x) の描画
    chart.draw_series(LineSeries::new(data, &RED))?;

    // 6. ファイルへの保存
    root.present()?;
    println!("plot-single.png を生成しました");
    Ok(())
}
```

### コードの解説

`plotters`でCSVデータからグラフを描画する手順は以下の通りです。

1.  **データの読み込み**: `csv`クレートを使って`output.csv`を読み込み、プロットしたいデータ(`t`と`x`)を`Vec<(f64, f64)>`のような形式に変換します。
2.  **バックエンドの作成**: `BitMapBackend` (PNG出力) など、描画先を指定します。
3.  **チャートの構築**: `ChartBuilder`で軸の範囲、タイトル、マージンなどを設定します。
4.  **メッシュ (軸とグリッド線) の描画**: `configure_mesh().draw()`で描画します。
5.  **データ系列の描画**: `draw_series`に`LineSeries`と読み込んだデータを渡してプロットします。
6.  **ファイルへの保存**: `present()`でここまでの描画内容をファイルに書き出します。

### 複数系列の描画

次に、`output.csv`に含まれる「位置 `x`」と「速度 `v`」の両方を一枚のグラフに描画します。

```rust
use plotters::prelude::*;
use csv;
use std::error::Error;

fn main() -> Result<(), Box<dyn Error>> {
    // CSVからデータを読み込む
    let mut reader = csv::Reader::from_path("output.csv")?;
    let records: Vec<_> = reader.records().collect();

    let root = BitMapBackend::new("plot-multi.png", (800, 600)).into_drawing_area();
    root.fill(&WHITE)?;

    let mut chart = ChartBuilder::on(&root)
        .caption("Position and Velocity (from CSV)", ("sans-serif", 30))
        .margin(20)
        .x_label_area_size(40)
        .y_label_area_size(40)
        .build_cartesian_2d(0.0..12.0, -1.5..1.5)?; // X軸の範囲を広げて凡例のスペースを確保

    chart.configure_mesh()
        .x_desc("Time t")
        .y_desc("Value")
        .draw()?;

    // 位置 x のデータ系列
    let pos_series = LineSeries::new(
        records.iter().map(|r| {
            let record = r.as_ref().unwrap();
            (record[0].parse().unwrap(), record[1].parse().unwrap())
        }),
        &RED,
    );

    // 速度 v のデータ系列
    let vel_series = LineSeries::new(
        records.iter().map(|r| {
            let record = r.as_ref().unwrap();
            (record[0].parse().unwrap(), record[2].parse().unwrap())
        }),
        &BLUE,
    );

    // 系列を描画し、凡例を設定
    chart.draw_series(pos_series)?
        .label("Position x")
        .legend(|(x, y)| PathElement::new(vec![(x, y), (x + 20, y)], &RED));

    chart.draw_series(vel_series)?
        .label("Velocity v")
        .legend(|(x, y)| PathElement::new(vec![(x, y), (x + 20, y)], &BLUE));

    // 凡例の描画
    chart.configure_series_labels()
        .border_style(&BLACK)
        .draw()?;

    root.present()?;
    println!("plot-multi.png を生成しました");
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
