# 数値計算結果の可視化

数値計算を実行する上で、その結果を視覚的に検証するプロセスは非常に重要です。グラフやアニメーションといった可視化手法は、計算の正当性を検証し、物理現象の動的な振る舞いを直感的に理解するための強力な手段となります。

本節では、数値計算結果を可視化するためのいくつかの手法を紹介します。

## 可視化ツールの選択

本書では、開発環境をRustで統一する観点から`plotters`や`kiss3d`といったRust製ライブラリを用いますが、読者の皆様はご自身が使い慣れたツールを自由にご利用いただけます。

可視化は、本書で解説する数値計算アルゴリズム自体とは独立した、計算結果を理解・分析するための補助的な手段です。Python (`matplotlib`)、`gnuplot`、Excel、MATLAB、Mathematicaなど、既に習熟されているツールがあれば、そちらの利用を推奨します。

本書のコード例から`plotters`や`kiss3d`に関する部分を省略し、計算結果をCSVファイルに出力した上で、任意のツールで可視化するというアプローチを採っていただいても全く問題ありません。

## データファイルへの出力

どのような可視化ツールを利用するにせよ、計算結果をファイルに保存する方法を習得しておくことは有益です。特に、CSV (Comma-Separated Values) 形式は多くのツールでサポートされており、汎用性が高いため本書でも推奨します。もちろん、大量のデータを効率的に扱いたい場合など、用途によってはHDF5やApache Parquetといった、より高機能なフォーマットを利用することも有効です。

### CSVファイルへの出力

CSVファイルは非常に汎用的なデータ形式であり、ほぼすべての可視化ツールや表計算ソフトで読み込むことが可能です。

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

### Pythonによる可視化例

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

### gnuplotによる可視化例

```gnuplot
set datafile separator ","
set xlabel "時間 t"
set ylabel "値"
set grid
plot "output.csv" using 1:2 with lines title "位置 x", \
     "output.csv" using 1:3 with lines title "速度 v"
```

### Excelによる可視化

CSVファイルをExcelで開き、データ範囲を選択して「挿入」タブからグラフを作成するだけで、簡単に可視化できます。

---

## Rust製ライブラリによる可視化

以下では、本書で利用するRust製の可視化ライブラリについて解説します。**これらのライブラリを使用せず、前述のCSVファイル出力と外部ツールを組み合わせる方法でも、本書の学習を進めることは可能です。**

### plotters (2Dグラフ描画)

[plotters](https://crates.io/crates/plotters)は、Rustで最も広く利用されている2Dプロットライブラリの一つです。

**主な特徴:**

- 折れ線グラフ、散布図、ヒストグラム、ヒートマップなど多彩なグラフ形式をサポート
- PNG, SVG, HTMLなど複数の出力形式に対応
- 純粋なRustで実装されており、外部ライブラリへの依存が最小限
- 高いカスタマイズ性

### kiss3d (3D可視化)

[kiss3d](https://crates.io/crates/kiss3d)は、シンプルさを特徴とする使いやすい3Dグラフィックスライブラリです。

**主な特徴:**

- リアルタイムの3D描画に対応
- シンプルなAPIで手軽に3Dシーンを構築可能
- 球、立方体、円柱などの基本図形を容易に描画
- マウスによるカメラ操作や簡易的なアニメーションをサポート

## 可視化ライブラリの導入

これらのライブラリを使用するには、プロジェクトの`Cargo.toml`に依存関係として追加します。

### plottersの追加

`plotters`と共に、CSVファイルを読み込むための`csv`クレートも依存関係に追加します。

```toml:Cargo.toml
[dependencies]
plotters = "0.3"
csv = "1.4" # CSVファイルの読み込みに必要
```

### kiss3dの追加

```toml:Cargo.toml
[dependencies]
kiss3d = "0.35"
nalgebra = "0.32" # kiss3dが内部で利用する3Dベクトル・行列計算ライブラリ
```

## plottersによる2Dグラフ描画

ここでは`plotters`を用いて、「データファイルへの出力」の項で作成した`output.csv`ファイルを読み込み、グラフを描画する方法を示します。

> [!NOTE]
> `plotters`で日本語のような非ASCII文字を表示するには、フォントファイルへのパスを正しく指定する必要があり、環境によっては追加のセットアップを要する場合があります。
> 本チュートリアルでは、追加設定なしでどの環境でもコードが動作することを優先するため、グラフ内のテキストには英語を使用します。

> [!NOTE]
> 以降のコードを実行する前に、`output.csv`が生成されていることを確認してください。未生成の場合は、「CSVファイルへの出力」の項に記載のコードを先に実行してください。

### CSVからのデータ読み込みと描画 (単一系列)

以下のコードは、`output.csv`ファイルを読み込み、`t`と`x`のデータを用いてグラフを描画し、`plot-single.png`というファイル名で保存します。

```rust,noplayground
use plotters::prelude::*;
use std::error::Error;

// 設定定数
const INPUT_CSV: &str = "output.csv";
const OUTPUT_IMAGE: &str = "plot-single.png";
const IMAGE_WIDTH: u32 = 800;
const IMAGE_HEIGHT: u32 = 600;

fn main() -> Result<(), Box<dyn Error>> {
    // 1. CSVファイルからデータを読み込む
    let mut reader = csv::Reader::from_path(INPUT_CSV)?;
    let data: Vec<(f64, f64)> = reader
        .records()
        .enumerate()
        .map(|(i, r)| {
            let record = r.map_err(|e| format!("行 {} の読み込みエラー: {e}", i + 1))?;
            let t: f64 = record
                .get(0)
                .ok_or_else(|| format!("行 {}: 時刻データが存在しません", i + 1))?
                .parse()
                .map_err(|e| format!("行 {} の時刻パースエラー: {e}", i + 1))?;
            let x: f64 = record
                .get(1)
                .ok_or_else(|| format!("行 {}: 位置データが存在しません", i + 1))?
                .parse()
                .map_err(|e| format!("行 {} の位置パースエラー: {e}", i + 1))?;
            Ok((t, x))
        })
        .collect::<Result<Vec<_>, String>>()?;

    // データが空の場合のチェック
    if data.is_empty() {
        return Err("CSVファイルにデータが含まれていません".into());
    }

    // 軸の範囲を自動計算
    let (t_min, t_max) = data
        .iter()
        .fold((f64::MAX, f64::MIN), |(min, max), (t, _)| {
            (min.min(*t), max.max(*t))
        });
    let (x_min, x_max) = data
        .iter()
        .fold((f64::MAX, f64::MIN), |(min, max), (_, x)| {
            (min.min(*x), max.max(*x))
        });

    // マージンを追加
    let t_margin = (t_max - t_min) * 0.05;
    let x_margin = (x_max - x_min) * 0.1;
    let t_range = (t_min - t_margin)..(t_max + t_margin);
    let x_range = (x_min - x_margin)..(x_max + x_margin);

    // 2. 描画バックエンドをセットアップする
    let root = BitMapBackend::new(OUTPUT_IMAGE, (IMAGE_WIDTH, IMAGE_HEIGHT)).into_drawing_area();
    root.fill(&WHITE)?;

    // 3. チャートを構築する
    let mut chart = ChartBuilder::on(&root)
        .caption("Position x vs. Time t (from CSV)", ("sans-serif", 30))
        .margin(20)
        .x_label_area_size(40)
        .y_label_area_size(40)
        .build_cartesian_2d(t_range, x_range)?;

    // 4. メッシュ (軸とグリッド線) を描画する
    chart
        .configure_mesh()
        .x_desc("Time t")
        .y_desc("Position x")
        .draw()?;

    // 5. データ系列 (t, x) を描画する
    chart.draw_series(LineSeries::new(data, &RED))?;

    // 6. ファイルに保存する
    root.present()?;
    println!("{OUTPUT_IMAGE} を生成しました");
    Ok(())
}
```

### コードの解説

`plotters`を用いてCSVデータからグラフを描画する手順は、概ね以下の通りです。

1. **データの読み込み**: `csv`クレートを利用して`output.csv`を読み込み、プロット対象のデータ（この場合は`t`と`x`）を`Vec<(f64, f64)>`のような形式に変換します。
2. **バックエンドの作成**: `BitMapBackend`（PNG出力用）など、描画先を指定します。
3. **チャートの構築**: `ChartBuilder`を用いて、描画範囲、タイトル、マージンなどの各種設定を行います。
4. **メッシュの描画**: `configure_mesh().draw()`を呼び出し、軸やグリッド線を描画します。
5. **データ系列の描画**: `draw_series`メソッドに`LineSeries`と描画データを渡し、プロットを実行します。
6. **ファイルへの保存**: `present()`メソッドにより、ここまでの描画内容をファイルに書き出します。

### 複数系列の描画

次に、`output.csv`に含まれる「位置 `x`」と「速度 `v`」の両方を一枚のグラフに描画します。

```rust,noplayground
use plotters::prelude::*;
use std::error::Error;

// 定数定義
const INPUT_CSV: &str = "output.csv";
const OUTPUT_IMAGE: &str = "plot-multi.png";
const IMAGE_WIDTH: u32 = 800;
const IMAGE_HEIGHT: u32 = 600;

// データポイント構造体
struct DataPoint {
    t: f64,
    x: f64,
    v: f64,
}

fn main() -> Result<(), Box<dyn Error>> {
    // CSVからデータを読み込み、構造化データとしてパース
    let mut reader = csv::Reader::from_path(INPUT_CSV)?;
    let data: Vec<DataPoint> = reader
        .records()
        .enumerate()
        .map(|(i, result)| {
            let record = result.map_err(|e| format!("行 {} の読み込みエラー: {e}", i + 2))?;
            Ok(DataPoint {
                t: record[0]
                    .parse()
                    .map_err(|e| format!("行 {} の時刻パースエラー: {e}", i + 2))?,
                x: record[1]
                    .parse()
                    .map_err(|e| format!("行 {} の位置パースエラー: {e}", i + 2))?,
                v: record[2]
                    .parse()
                    .map_err(|e| format!("行 {} の速度パースエラー: {e}", i + 2))?,
            })
        })
        .collect::<Result<Vec<_>, String>>()?;

    // 軸範囲の自動計算
    let (t_min, t_max) = data.iter().fold((f64::MAX, f64::MIN), |(min, max), d| {
        (min.min(d.t), max.max(d.t))
    });
    let (val_min, val_max) = data.iter().fold((f64::MAX, f64::MIN), |(min, max), d| {
        (min.min(d.x).min(d.v), max.max(d.x).max(d.v))
    });

    // マージンを追加
    let t_margin = (t_max - t_min) * 0.05;
    let val_margin = (val_max - val_min) * 0.1;
    let t_range = (t_min - t_margin)..(t_max + t_margin);
    let val_range = (val_min - val_margin)..(val_max + val_margin);

    let root = BitMapBackend::new(OUTPUT_IMAGE, (IMAGE_WIDTH, IMAGE_HEIGHT)).into_drawing_area();
    root.fill(&WHITE)?;

    let mut chart = ChartBuilder::on(&root)
        .caption("Position and Velocity (from CSV)", ("sans-serif", 30))
        .margin(20)
        .x_label_area_size(40)
        .y_label_area_size(40)
        .build_cartesian_2d(t_range, val_range)?;

    chart
        .configure_mesh()
        .x_desc("Time t")
        .y_desc("Value")
        .draw()?;

    // 位置 x のデータ系列
    let pos_series = LineSeries::new(data.iter().map(|d| (d.t, d.x)), &RED);

    // 速度 v のデータ系列
    let vel_series = LineSeries::new(data.iter().map(|d| (d.t, d.v)), &BLUE);

    // 系列を描画し、凡例を設定
    chart
        .draw_series(pos_series)?
        .label("Position x")
        .legend(|(x, y)| PathElement::new(vec![(x, y), (x + 20, y)], RED));

    chart
        .draw_series(vel_series)?
        .label("Velocity v")
        .legend(|(x, y)| PathElement::new(vec![(x, y), (x + 20, y)], BLUE));

    // 凡例の描画
    chart
        .configure_series_labels()
        .position(SeriesLabelPosition::UpperRight)
        .background_style(WHITE.mix(0.8))
        .border_style(BLACK)
        .draw()?;

    root.present()?;
    println!("{OUTPUT_IMAGE} を生成しました");
    Ok(())
}
```

このコードを実行すると、`plot-multi.png`というファイルに以下のようなグラフが描画されます。赤色の線が位置 `x`、青色の線が速度 `v` を表しており、凡例も表示されていることが確認できます。

![複数系列のプロット結果](../images/plot-multi.avif)

## kiss3dによる3D可視化

### 基本的な使い方

以下のコードは、回転する立方体を描画するウィンドウを表示します。

```rust,noplayground
use kiss3d::light::Light;
use kiss3d::window::Window;
use nalgebra::{UnitQuaternion, Vector3};

#[tokio::main]
async fn main() {
    // ウィンドウの作成
    let mut window = Window::new("kiss3d: Cube");

    // 立方体の追加
    let mut cube = window.add_cube(1.0, 1.0, 1.0);
    cube.set_color(0.0, 0.5, 1.0); // 青色

    // 光源の設定
    window.set_light(Light::StickToCamera);

    // メインループ
    // ウィンドウが閉じられるとプログラムが終了します。
    loop {
        // Y軸を中心に少し回転させる
        let rotation = UnitQuaternion::from_axis_angle(&Vector3::y_axis(), 0.01);
        cube.prepend_to_local_rotation(&rotation);

        // フレームを非同期でレンダリング
        window.render().await;
    }
}
```

実行すると、以下のように青い立方体がY軸を中心に回転するウィンドウが表示されます。ウィンドウを閉じるとプログラムは終了します。

<video autoplay loop muted playsinline width="400">
  <source src="../videos/three-d-video.webm" type="video/webm">
  お使いのブラウザは動画タグをサポートしていません。
</video>

### カメラ操作

`kiss3d`のウィンドウでは、マウスによる直感的なカメラ操作が可能です。

- **左ドラッグ**: 回転
- **右ドラッグ**: 平行移動
- **スクロール**: ズームイン／ズームアウト

## まとめ

本節では、数値計算結果を可視化するための手法について紹介しました。

> [!IMPORTANT]
>
> - **可視化ツールは任意に選択可能です**。本書では`plotters`と`kiss3d`を紹介しますが、Python、`gnuplot`、Excelなど、ご自身が習熟されているツールの使用を推奨します。
> - **CSVファイルへの出力**は、ツール間のデータ連携において利便性が高いため、推奨される手法です。
> - 本書の学習における中核は**数値計算アルゴリズムとそのRustによる実装**であり、可視化はあくまで結果を検証・分析するための一手段です。

次節では、本書全体の構成と学習の進め方について、より詳細に解説します。
