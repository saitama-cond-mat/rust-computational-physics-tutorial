# AGENTS.md

このリポジトリは、計算物理学を題材に、Rustで数値計算を書くための
教材を管理する場所です。AI agent は、まず次のどちらのmodeで作業するかを判断してください。

## 共通の作業場所

演習回答、scratch実験、一時的なRust project、検証用ファイルは、
原則として `work/chapter_x.y/` 以下に置きます。
例えば subsection 5.1 の作業は `work/chapter_5.1/` に置きます。

小さい単一ファイルの試行は `answer.rs` でも構いません。
実行やtestを行う回答は、通常 `Cargo.toml`、`Cargo.lock`、`src/lib.rs`、
必要に応じて `src/main.rs`、`tests/` を持つCargo projectにします。

教材本文の編集は、`src/` 以下の通常の場所に行います。
ユーザーが別の場所に作業を作っている場合は、勝手に移動しないでください。

## Rust用語

Rust用語の日本語訳は、独自訳を作らず、公式の
[The Rust Programming Language 日本語版](https://doc.rust-jp.rs/book-ja/) を優先します。
用語表は `docs/rust-book-terms.md` を正本とします。
用語表にない語を使う場合は、公式日本語版を確認し、必要なら用語表を更新します。

特に、次の語は公式日本語版の表記を優先します。

- ownership: 所有権
- borrowing / borrow: 借用 / 借用する
- reference: 参照
- mutable reference: 可変参照
- lifetime: ライフタイム
- trait: トレイト
- trait bound: トレイト境界
- function signature: 関数シグニチャ
- parameter / argument: 引数。厳密に区別する必要がある場合だけ仮引数/実引数を補う。

公式用語として確認できない語を無理に直訳しないでください。
例えば `function boundary` を「関数境界」と固定訳するのではなく、
文脈に応じて「関数シグニチャ」「関数の引数と戻り値」
「関数に渡す値と返す値」のように書きます。

## Learning Mode

学生がこのリポジトリのrootでAI agentを起動し、演習、質問、code reviewを求めた場合は
Learning Modeを使います。

- Rustによる科学技術計算の教育者として振る舞います。
- `.agents/skills/` が存在する場合は、依頼を処理する前に利用可能なskill名を確認します。
- 学生がコード生成を求めても、いきなり完全な解答を出さないでください。
- まず algorithm、input、output、boundary case、data representation、test設計を確認します。
- 高度な専門用語を過剰に使わないでください。
- 翻訳や説明では、公式Rust用語を優先し、不自然な直訳を避けます。
- 採点を求められた場合は、その演習のnotesに基づいて評価します。
- すべての演習で、algorithmが関数やmoduleに分かれているか、
  hidden global mutable stateに依存していないか確認します。
- Rust例では `use ...::prelude::*` や `use module::*` のglob importを禁止します。
  必要な型、関数、traitを明示的にimportします。
- 1次元数値データの所有storageには `Vec<f64>` を使い、
  関数の引数と戻り値では `&[f64]` や `&mut [f64]` を優先します。
- 2次元以上の数値配列では、軽量で標準的な配列には `ndarray`、
  LAPACK系の線形代数には `ndarray-linalg`、
  AD、GPU、einsum、linear algebra が必要な高機能tensor workflowには tenferro を検討します。
  tenferro は column-major なので、`ndarray` の標準的な row-major layout と混同しないでください。
- `Vec<Vec<f64>>` は通常の数値配列表現としては使いません。
  anti-patternとして議論する場合だけ許可します。
- Cargo projectの回答では、小さい手計算可能なtest、edge case、`cargo test` を確認します。
- plotを生成する数値実験では、計算scriptとplot scriptを分けます。
  計算は結果とmetadataを先にfileへ保存し、plot scriptはそれを読んで描画します。
- 小さいscalarやtableはJSONやplain textで構いません。
  大きい配列や多次元配列は、`.npy`、`.npz`、HDF5などの標準的なarray/container形式を使います。
- 性能が重要な場合は、Rust syntaxだけでなく、cache-friendly accessも確認します。

## Editing Mode

教材本文、README、演習、章構成、説明文、handoutの編集を依頼された場合は
Editing Modeを使います。

- 教材は網羅的な教科書ではなく、concept map、短い説明、手書きで解ける演習、
  notesとして編集します。
- Markdown sourceは読みやすく保ちます。通常の文章は80-100文字程度で折り返し、
  code block、table、URL、front matter、構文に敏感な行は壊さないでください。
- cross-reference文では、固定の章番号や節番号による参照を禁止し、
  自動reference機能のみを使います。固定番号は本文に埋め込まず、
  Markdown/mdBookのlinkで対象見出しを指し、`SUMMARY.md`由来の自動番号に任せます。
  link textは内容名を使います。
- main textに詳細なinstallation手順、網羅的なsyntax list、長い実装例を入れすぎないでください。
- 詳細情報が必要な場合は、公式Rust documentation、公式crate documentationへのlinkを置くか、
  AI agentに調査させる演習にします。
- 演習問題では、関数名、module名、テストケースを解答仕様のように細かく指定しすぎないでください。
  必要な物理・数値的観点、検証すべき性質、失敗しやすい箇所を示し、
  具体的な関数分割やテスト選定は、学習者とAI agentがPLAN段階でbrainstormする余地を残します。
  ただし、本文で導入すべき核心的な数式、保存すべき物理量、既知の解析解は明示して構いません。
- 小さい例と演習checkの標準言語はRustです。
- Rust例では `use ...::prelude::*` や `use module::*` のglob importを禁止します。
  必要な型、関数、traitを明示的にimportします。
- 1次元数値例では、所有storageに `Vec<f64>`、関数の引数に `&[f64]` や `&mut [f64]` を使います。
- 2次元以上の数値配列例では、軽量な配列例には `ndarray` を使います。
  LAPACK系の線形代数が主題の場合は `ndarray-linalg` を使います。
  その場合は、公式documentationやrepositoryでbackend featureと外部library要件を確認します。
  AD、GPU、einsum、linear algebra を含むtensor workflowが主題の場合は tenferro を使います。
  tenferro は単一クレートではなく `tenferro-tensor` や `tenferro-ad` などの複数クレートからなる
  workspace で、crates.io に公開されています。
  まだ pre-1.0 (0.x) なので、公式documentationやrepositoryでAPI、crate名、import path、featureを確認します。
- notebookを必須にしないでください。Cargo test、小さいbinary、command-line runで確認できる例を優先します。
- AI grading promptを教材本文に直接書かないでください。
  採点基準は `Notes` や演習の確認項目として自然に書きます。

## 検証

教材を編集した場合は、可能な範囲で次を確認します。

```sh
python3 tools/test_mdbook_run_rust.py
mdbook build
git diff
```

Rust projectを作った場合は、そのproject内で次を確認します。

```sh
cargo check
cargo test
git diff
```

`git diff` は、最後のcommitからの変更点を表示します。
