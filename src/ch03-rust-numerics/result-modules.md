# Resultとmodule境界

数値計算コードでは、計算そのものだけでなく、入力不正、配列サイズ不一致、収束失敗、ファイル出力失敗なども扱う必要があります。小さい例では`panic!`でも動きますが、再利用する関数では`Result`で失敗を返す方が安全です。

## `Result`で失敗を返す

例えば、2つのベクトルの内積では、長さが一致している必要があります。

```rust
fn dot(a: &[f64], b: &[f64]) -> Result<f64, String> {
    if a.len() != b.len() {
        return Err(format!(
            "length mismatch: a has {}, b has {}",
            a.len(),
            b.len()
        ));
    }

    let value = a.iter().zip(b).map(|(x, y)| x * y).sum();
    Ok(value)
}
```

呼び出し側では、失敗した場合に何をするかを明示できます。

```rust
let a = vec![1.0, 2.0, 3.0];
let b = vec![4.0, 5.0, 6.0];
let value = dot(&a, &b)?;
```

## `struct`でパラメータをまとめる

引数が増えてきたら、パラメータや状態を`struct`にまとめます。

```rust
struct EulerConfig {
    dt: f64,
    n_steps: usize,
}

impl EulerConfig {
    fn validate(&self) -> Result<(), String> {
        if self.dt <= 0.0 {
            return Err("dt must be positive".to_string());
        }
        if self.n_steps == 0 {
            return Err("n_steps must be positive".to_string());
        }
        Ok(())
    }
}
```

入力条件を`validate`に分けると、テストしやすくなります。

## module境界

大きい計算では、`main.rs`にすべてを書かないようにします。例えば、次のように分けます。

```text
src/
├── lib.rs
├── model.rs
├── algorithm.rs
├── io.rs
└── main.rs
```

役割は次のように分けます。

- `model`: 物理モデル、パラメータ、状態量
- `algorithm`: 時間発展、反復法、更新規則
- `io`: 結果保存、metadata保存
- `main`: コマンドライン引数、実行順序
- `tests`: 小さい検証問題、解析解との比較

これは、前節で述べた「小さい部品を先に検査する」考え方を、
project全体に広げたものです。
`model`、`algorithm`、`io`を分けておくと、各部品を単体テストしやすくなります。
他の言語へ移植する場合も、moduleごとに移し、同じ小さい検証問題で比較できます。

この分割は、AI agent に実装を任せる場合にも有効です。「`algorithm`だけを修正してください」「`io`にCSV保存を追加してください」「`model`の物理量更新を疑似コード化してください」のように、作業範囲を限定できます。

## `panic!`してよい場合

`panic!`は、プログラムのバグを示す場合や、サンプルコードを短くする場合には使えます。一方、ユーザー入力、ファイル入出力、収束失敗、配列サイズ不一致のように実行時に起こりうる失敗は、`Result`で返す方が適しています。

本書では、説明を短くするために`expect`や`panic!`を使うこともあります。ただし、研究用・演習用のコードを長く育てる場合は、どの失敗を呼び出し側に返すべきかを意識してください。
