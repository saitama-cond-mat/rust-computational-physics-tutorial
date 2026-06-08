# 作業用ディレクトリのセットアップ

第2部以降の演習では、教材リポジトリの外に作業用ディレクトリを作ります。
教材リポジトリは読む場所、作業用ディレクトリは実装、テスト、結果保存を行う場所として分けます。

```sh
mkdir -p ~/rust-computational-physics-work
cd ~/rust-computational-physics-work
```

## 標準ディレクトリ構成

作業用ディレクトリの下には、章やテーマごとにsub directoryを作ります。
各leaf directoryは、原則として独立したCargo projectにします。

```text
rust-computational-physics-work/
  AGENTS.md
  CLAUDE.md
  README.md
  calculus/
    integration/
      Cargo.toml
      src/
        lib.rs
        main.rs
      tests/
        integration_test.rs
      output/
  ode/
    euler-rk4/
  monte-carlo/
    integration/
```

## トップレベルの指示ファイル

AI coding agentを使う場合は、作業用ディレクトリのtopに`AGENTS.md`を置くことを推奨します。
Claude Codeを使う場合は、必要に応じて`CLAUDE.md`も置き、`AGENTS.md`を参照させます。

`AGENTS.md` の例:

```md
# AGENTS.md

このディレクトリは rust-computational-physics-tutorial の演習用作業場所です。

- 教材リポジトリ本体は編集しない。
- 各テーマは独立したCargo projectとしてsub directoryに作る。
- 数値計算の本体は `src/lib.rs` に置く。
- 実行用コード、CSV出力、パラメータ実験は `src/main.rs` に置く。
- 小さい手計算可能なケースを `tests/` に追加する。
- `cargo test` を通してから結果を信用する。
- 生成されたCSVや画像は `output/` に置く。
```

`CLAUDE.md` を置く場合は、次のように `AGENTS.md` を参照するだけで構いません。

```md
@AGENTS.md
```

## テーマごとのCargo project

各テーマでは、次の形を標準にします。

```sh
mkdir -p ~/rust-computational-physics-work/calculus/integration
cd ~/rust-computational-physics-work/calculus/integration
cargo init --bin
mkdir -p tests output
```

- `src/lib.rs`: 数値計算の本体。小さい関数に分け、テストしやすくする。
- `src/main.rs`: 実行条件の設定、CSV出力、簡単なパラメータ走査を担当する。
- `tests/`: 手計算可能な入力、既知解、保存量、再現性を確認する。
- `output/`: CSV、metadata、図などの生成物を置く。

本文のサンプルコードも、この構成を意識して読みます。つまり、計算本体は
`src/lib.rs` に置ける関数として定義し、`fn main()` はその関数を呼び出して
結果を表示したり、CSVへ保存したりする薄い実行例に留めます。

## 演習の標準形

第2部と第3部の演習では、各テーマに対して次の2種類を基本にします。

1. **ユニットテストの追加**
   本文で示した関数に対して、`cargo test`で確認するテストを追加します。
   どのケースをテストすべきかはAI coding agentと相談して構いませんが、
   解析解、既知解、小さい格子、固定seed、境界条件、許容誤差を必ず確認します。
2. **コードの拡張**
   収束表のCSV出力、保存量の記録、metadataの保存、別手法との比較などを追加します。

AI coding agentに依頼する場合も、まず関数分割、入力、出力、検証方法を確認させてから実装に進みます。
