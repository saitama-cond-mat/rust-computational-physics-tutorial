# rust-computational-physics-tutorial

rustでの計算物理学のドキュメント

## ビルド方法

### 必要なツール

このプロジェクトは[mise](https://mise.jdx.dev/)を使用してツールを管理しています。

```bash
# miseのインストール（まだの場合）
curl https://mise.run | sh

# 必要なツールのインストール
mise install
```

### ビルド

```bash
# mdBookのビルドとpagefind検索インデックスの生成
mise run build
```

このコマンドは以下を実行します：

1. `mdbook build` - mdBookをビルド
2. `pagefind --site book` - 検索インデックスを生成
3. `lychee book/` - リンクチェック

### ローカルプレビュー

```bash
# ビルド + サーバー起動（ポート3000）
mise run serve
```

ブラウザで `http://localhost:3000` を開いてください。
サーバーを停止するには `Ctrl+C` を押してください。

**注意**: `mdbook serve` は使用しないでください。Pagefindの検索インデックスが含まれないため、検索機能が動作しません。

## 検索機能について

このプロジェクトは[Pagefind](https://pagefind.app/)を使用した検索機能を実装しています。

### 使い方

- 検索アイコン（🔍）をクリックするか、`S`または`/`キーを押すと検索バーが表示されます
- 検索バーに検索キーワードを入力すると、リアルタイムで結果が表示されます
- `Esc`キーで検索バーを閉じることができます

### 技術詳細

- **検索エンジン**: Pagefind（Rust製の静的サイト検索）
- **言語**: 日本語対応（66ページ、1,073語をインデックス化）
- **インデックス**: ビルド時に自動生成
- **UI**: PagefindのデフォルトUIをmdBookのテーマに統合
- **サーバー**: miniserve（Rust製HTTPサーバー）

#### カスタマイズファイル

- `theme/index.hbs` - Pagefind統合のHTMLテンプレート
- `theme/css/pagefind.css` - Pagefind UIのカスタムスタイル
- `mise.toml` - ビルド・サーブタスクの設定

## クリーンビルド

```bash
# ビルド成果物を削除
mise run clean

# 再ビルド
mise run build
```
