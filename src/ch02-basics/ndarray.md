# 外部クレートの活用（ndarray入門）

> [!NOTE]
> **本節のポイント**
>
> - Rustの科学技術計算における中核クレート`ndarray`の基本を学ぶ。
> - `ndarray`を用いて、ベクトルや行列といった多次元配列を効率的に作成・操作する方法を習得する。
> - ベクトル・行列の四則演算、内積・行列積、スライシングといった基本的な線形代数演算に習熟する。
>
> 本節は、前節「[配列・スライス・ベクタの基礎](./arrays-vectors.md)」で学んだ内容を土台としています。

前節では、Rustの標準ライブラリが提供する配列、スライス、`Vec<T>`といった基本的なコレクション型を学びました。これらの型はデータ管理の基本として有用ですが、より高度な科学技術計算、特に多次元配列（ベクトル、行列、テンソル）を多用する線形代数演算には力不足です。

例えば、`Vec<Vec<f64>>`で「行列」を表現しようとすると、以下のような課題に直面します。

- **メモリ効率**: 各行が独立したヒープ割り当てとなり、データがメモリ上で連続的に配置されないため、キャッシュ効率が悪化します。
- **演算の煩雑さ**: 行列の積や転置といった基本的な演算も、手動でループを実装する必要があり、コードが冗長かつエラーが発生しやすくなります。
- **パフォーマンス**: 最適化された線形代数ライブラリ（BLASなど）の恩恵を受けにくく、手実装のループでは高いパフォーマンスを得るのが困難です。

このような課題を解決するのが、**`ndarray`** クレートです。`ndarray`は、PythonにおけるNumPyや、C++におけるEigenのように、Rustで多次元配列を効率的かつ直感的に扱うための豊富な機能を提供します。これはRustの科学技術計算エコシステムにおいて、最も基本的かつ重要なクレートの一つです。

本節では、この`ndarray`の基本的な使い方を学び、効率的な数値計算のための土台を築きます。

## `ndarray`のセットアップ

まず、`ndarray`をプロジェクトに追加します。`Cargo.toml`ファイルの`[dependencies]`セクションに以下の行を追記してください。

```toml:Cargo.toml
[dependencies]
ndarray = "0.15"
```

バージョンは執筆時点のものです。最新版は[crates.io](https://crates.io/crates/ndarray)で確認できます。

ソースコードの先頭には、`ndarray`の主要な機能に簡単にアクセスするための`prelude`を導入しておくと便利です。

```rust,ignore
use ndarray::prelude::*;
```

本節のコード例では、個別の型を`use`宣言で明示的にインポートすることで、どの機能が`ndarray`から来ているかを分かりやすくします。

```rust,ignore
use ndarray::{arr1, arr2, Array, Array1, Array2, Axis};
```

## 1次元配列 (`Array1`)：ベクトルの表現

`ndarray`における1次元配列`Array1<T>`は、数学的なベクトルに対応します。

### ベクトルの作成

`ndarray`には、ベクトルを生成するための多様な方法が用意されています。

```rust,noplayground
use ndarray::{arr1, Array, Array1};

fn main() {
    // スライスからベクトルを作成
    let a: Array1<f64> = Array::from(vec![1.0, 2.0, 3.0]);
    println!("a = {}", a);

    // arr1 関数を使った、より簡潔な作成方法
    let b = arr1(&[4.0, 5.0, 6.0]);
    println!("b = {}", b);

    // 0から9までの連番を持つベクトルを作成
    let c: Array1<f64> = Array::range(0.0, 10.0, 1.0);
    println!("c = {}", c);

    // すべての要素が0.0のベクトルを作成（次元を指定）
    let zeros = Array1::<f64>::zeros(5);
    println!("zeros = {}", zeros);
}
```

### ベクトル演算

`ndarray`の最大の利点の一つは、ベクトルや行列に対する数学的な演算が直感的に書ける点です。`+`, `-`, `*`, `/` といった演算子がオーバーロードされており、要素ごとの演算が可能です。

```rust,noplayground
use ndarray::arr1;

fn main() {
    let a = arr1(&[1.0, 2.0, 3.0]);
    let b = arr1(&[4.0, 5.0, 6.0]);

    // ベクトルの加算
    println!("a + b = {}", &a + &b);

    // ベクトルの減算
    println!("a - b = {}", &a - &b);

    // スカラー倍
    println!("a * 2.0 = {}", &a * 2.0);

    // 要素ごとの積
    println!("a * b (element-wise) = {}", &a * &b);

    // 内積 (dot product)
    let dot_product = a.dot(&b);
    println!("a . b = {}", dot_product);
}
```

> [!NOTE]
> **参照と所有権**
> `&a + &b`のように、演算時にベクトルの参照(`&`)を渡している点に注目してください。`ndarray`の多くの二項演算は参照を受け取るように実装されています。これにより、演算後も元のデータ`a`と`b`の所有権が維持され、続けて使用することができます。もし`a + b`と記述すると、`a`の所有権が移動してしまい、以降`a`は使えなくなります。

## 2次元配列 (`Array2`)：行列の表現

`ndarray`における2次元配列`Array2<T>`は、行列に対応します。

### 行列の作成

行列もベクトルと同様、様々な方法で作成できます。

```rust,noplayground
use ndarray::{arr2, Array2};

fn main() {
    // arr2 関数で行列を作成
    // 各内部配列が「行」に対応する
    let m = arr2(&[[1.0, 2.0, 3.0],
                   [4.0, 5.0, 6.0]]);
    println!("m =\n{}", m);

    // from_shape_vecで行列を作成
    // (行数, 列数)のタプルと、データを格納したVecを渡す
    let shape = (3, 2);
    let data = vec![1, 2, 3, 4, 5, 6];
    let m_from_vec = Array2::from_shape_vec(shape, data)
        .expect("Incompatible shape");
    println!("m_from_vec =\n{}", m_from_vec);

    // 3x3のゼロ行列
    let zeros = Array2::<f64>::zeros((3, 3));
    println!("zeros =\n{}", zeros);

    // 2x2の単位行列
    let eye = Array2::<f64>::eye(2);
    println!("eye =\n{}", eye);
}
```

### 行列演算

行列同士の加減算やスカラー倍もベクトルと同様に直感的に記述できます。そして、`dot`メソッドを用いることで、行列積や行列とベクトルの積を計算できます。

```rust,noplayground
use ndarray::{arr1, arr2};

fn main() {
    let m1 = arr2(&[[1.0, 2.0],
                    [3.0, 4.0]]);

    let m2 = arr2(&[[5.0, 6.0],
                    [7.0, 8.0]]);

    // 行列の加算
    println!("m1 + m2 =\n{}", &m1 + &m2);

    // 行列のスカラー倍
    println!("m1 * 3.0 =\n{}", &m1 * 3.0);

    // 行列積
    let matrix_product = m1.dot(&m2);
    println!("m1 * m2 (matrix product) =\n{}", matrix_product);

    // 行列とベクトルの積
    let v = arr1(&[10.0, 20.0]);
    let matrix_vector_product = m1.dot(&v);
    println!("m1 * v =\n{}", matrix_vector_product);
}
```

これらの演算は、内部的に最適化された数値計算ライブラリ（BLAS）と連携することが可能であり（feature flag `blas`で有効化）、手動のループ実装に比べて大幅に高速です。

## スライシング

`ndarray`の特に強力な機能がスライシングです。これにより、配列の一部を効率的に、かつ柔軟に抜き出すことができます。スライシングはNumPyのそれに非常によく似ており、`s![]`マクロを用いて行います。

```rust,noplayground
use ndarray::{arr2, s};

fn main() {
    let m = arr2(&[[ 1,  2,  3,  4],
                   [ 5,  6,  7,  8],
                   [ 9, 10, 11, 12]]);
    println!("m =\n{}", m);

    // 0番目の行を取得
    let row0 = m.slice(s![0, ..]);
    println!("Row 0: {}", row0); // [1, 2, 3, 4]

    // 1番目の列を取得
    let col1 = m.slice(s![.., 1]);
    println!("Column 1: {}", col1); // [2, 6, 10]

    // 部分行列を取得
    // 0-1行目、1-2列目を抜き出す
    let sub_matrix = m.slice(s![0..2, 1..3]);
    println!("Sub-matrix (0..2, 1..3) =\n{}", sub_matrix);
    // [[2, 3],
    //  [6, 7]]

    // スライスは元のデータのビュー（参照）
    // スライスを介して元のデータを変更することも可能
    let mut m_mut = m.clone();
    let mut sub_view = m_mut.slice_mut(s![0..2, 1..3]);
    sub_view.fill(0); // 部分行列を0で埋める
    println!("Modified m_mut =\n{}", m_mut);
}
```

> [!IMPORTANT]
> **スライスはビューである**
>
> `slice()`メソッドが返す`ArrayView`型は、元の配列データの所有権を持たない「ビュー（参照）」です。これにより、巨大な行列の一部を操作する際に、不要なデータコピーを回避し、高いメモリ効率とパフォーマンスを実現します。

## ブロードキャスト

ブロードキャストは、形状（shape）が異なる配列間の演算を可能にする強力な機能です。`ndarray`は、不足している次元を自動的に「引き伸ばし」て、形状を一致させてから演算を実行します。

例えば、行列のすべての要素に同じ値を加算する、あるいは行列の各行に同じベクトルを加算するといった操作が簡単に行えます。

```rust,noplayground
use ndarray::{arr1, arr2, Axis};

fn main() {
    let m = arr2(&[[1.0, 2.0],
                   [3.0, 4.0]]);

    let v = arr1(&[10.0, 20.0]);

    // 行列の各行にベクトルvを加算する
    // vは (2,) -> (1, 2) にブロードキャストされ、
    // それがさらに (2, 2) に引き伸ばされてmと加算される
    let result_row = &m + &v;
    println!("m + v (row-wise broadcast) =\n{}", result_row);

    // 行列の各列にベクトルを加算する場合
    // ベクトルを列ベクトルとして扱うために次元を追加する必要がある
    // v.view().insert_axis(Axis(1)) は vの形状を (2,) から (2, 1) に変える
    // view() を使うことで v の所有権を保持したままビューを操作できる
    let result_col = &m + &v.view().insert_axis(Axis(1));
    println!("m + v (column-wise broadcast) =\n{}", result_col);
}
```

実行結果:

```text
m + v (row-wise broadcast) =
[[11, 22],
 [13, 24]]
m + v (column-wise broadcast) =
[[11, 12],
 [23, 24]]
```

## `ndarray`とRust標準型の連携

`ndarray`は標準ライブラリの型とスムーズに連携できます。

- `Array`から`Vec`へ: `to_vec()`
- `Array`からスライスへ: `as_slice()`
- スライスから`ArrayView`へ: `ArrayView::from()`

これにより、既存のRustコードに`ndarray`を段階的に導入したり、`ndarray`で計算した結果を他のライブラリに渡したりすることが容易になります。

## その他の高度な機能

`ndarray`は本節で紹介した以外にも、以下のような多数の機能を提供します。

- **高階関数**: `map`, `fold`, `zip`など、配列を効率的に操作するメソッド。
- **軸に沿った操作**: `sum`, `mean`, `max`, `min`などを特定の軸（行方向や列方向）に沿って計算。
- **豊富な線形代数機能**: `ndarray-linalg`クレートと組み合わせることで、逆行列、固有値問題、特異値分解（SVD）などの高度な計算が可能になります。

## まとめ

本節では、Rustの科学技術計算における中核的なクレートである`ndarray`の基本的な使い方を学びました。

- `Array1`（ベクトル）と`Array2`（行列）の作成方法と、それらの間の基本的な演算（四則演算、内積、行列積）を習得しました。
- `s![]`マクロを用いた柔軟なスライシング機能により、配列の一部を効率的に参照・操作できることを見ました。
- ブロードキャスト機能により、形状の異なる配列間でも直感的な演算が可能であることを学びました。

`ndarray`は、Rustでパフォーマンスが要求される数値計算コードを記述する上で、事実上の標準ツールとなっています。本書でも以降の章で、微分方程式の求解や物理シミュレーションの実装に`ndarray`を全面的に活用していきます。
