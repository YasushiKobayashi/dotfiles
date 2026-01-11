# Neovim Configuration

## 概要
個人的なNeovim設定。LSP、補完、Gitインテグレーション、テストランナーなど、Web開発に最適化された設定。

## 主な特徴
- **CoC.nvim**によるLSP統合（自動補完、定義ジャンプ、診断）
- **vim-test**によるテスト実行（PHPUnit、Jest、Go test対応）
- 保存時の自動フォーマット（Prettier、PHP CS Fixer、goimports）
- GitHub Copilot統合
- Git操作（vim-fugitive、gh.vim、tig-explorer）

## tmux連携（AI出力から既存nvimへジャンプ）
tmux 2ペイン運用（左nvim / 右AI出力）を前提に、AIの出力に含まれる `path` / `path:line` / `path:line:col` を左のnvimへジャンプさせる。

### 前提
- `bin/nvim-left` と `bin/open_in_nvim_left` が `PATH` にあること
- 依存: `nvr`, `rg`, `fzf`, `tmux`（`tmux-thumbs` は任意）

### 使い方
1. 左ペインで `nvim-left` を起動（`/tmp/nvim-left.sock` に listen）
2. 右ペインで AI エージェントの出力を流す
3. ジャンプ方法:
   - `prefix + o`: 画面内テキストから抽出 → fzf 選択 → 左nvimへジャンプ
   - copy-mode で選択 → `Enter`: 選択文字列を左nvimへジャンプ
   - `prefix + Space`（tmux-thumbs）: ヒント選択 → 左nvimへジャンプ

### セットアップ
- `dotfiles_link.sh` で `~/.local/bin` にスクリプトがリンクされる
- tmux 設定再読み込み: `prefix + l`
- tmux-thumbs を使う場合は tpm で導入: `prefix + I`

### iTerm2 Cmd+Click 連携（IDE風）
iTerm2 の Semantic History でクリックしたパスを `open_in_nvim_left` に渡す。

- iTerm2 > Settings > Profiles > Advanced > Semantic History
- Action: `Run command`
- Command 例（1つ目のキャプチャを渡す。PATH問題を避けるため bash -lc 推奨）:

```
/bin/bash -lc "$HOME/.local/bin/open_in_nvim_left \"\1\""
```

- Regex 例（path / path:line / path:line:col）:

```
([A-Za-z0-9_./~+-]+/[A-Za-z0-9_./~+.-]+(?::\d+(?::\d+)?)?)
```

相対パスは `PWD` を基準に解決するので、クリック元のカレントディレクトリが正しく取れていることが前提。

### 補足
- 相対パスは右ペインの `pane_current_path` を基準に解決
- ソケットを変えたい場合は `NVIM_LEFT_LISTEN` を指定

## 対応言語とLSP

### Web開発
- **TypeScript/JavaScript**: TSServer、ESLint、Prettier
- **Vue.js**: Vetur言語サーバー
- **CSS/SCSS**: 組み込み検証、Stylelint、Tailwind CSS
- **HTML**: HTML言語サーバー、Emmet

### バックエンド
- **Go**: golangci-lint、goimports、go test
- **PHP**: Intelephense LSP、PHP CS Fixer（Pint）、PHPUnit
- **Rust**: RLS言語サーバー、rustfmt

### その他
- **Markdown**: EFM言語サーバー（textlint）
- **Docker**: Dockerfile言語サーバー
- **Terraform**: terraform-ls
- **GraphQL**: GraphQL言語サーバー
- **Prisma**: Prisma言語サーバー
- **Shell**: shellcheck、shfmt

## キーマッピング

### リーダーキー: `<Space>`

| キー | 機能 | 説明 |
|------|------|------|
| `<Leader>p` | ファイル検索 | CocListでファイル検索 |
| `<Leader>f` | ファイルパスコピー | 現在のファイルの絶対パスをクリップボードにコピー |
| `<Leader>g` | grep検索 | Unite grepで検索 |
| `<Leader>r` | 検索再開 | 前回の検索結果を表示 |
| `<Leader>b` | バッファ一覧 | Uniteバッファ一覧 |
| `<Leader>q` | Qfreplace | Quickfixの結果を一括置換 |
| `<Leader>t` | テスト実行 | 現在のファイルのテストを実行 |
| `<Leader>y` | Emmet展開 | Emmet略語を展開 |
| `<Leader>c` | Git commit | Fugitiveでコミット画面を開く |

### ウィンドウ操作（`s`プレフィックス）

| キー | 機能 |
|------|------|
| `sh/j/k/l` | ウィンドウ移動（左/下/上/右） |
| `sH/J/K/L` | ウィンドウを端に移動 |
| `ss` | 水平分割 |
| `sv` | 垂直分割 |
| `sq` | ウィンドウを閉じる |
| `sQ` | バッファを削除 |
| `sn/sp` | タブ移動（次/前） |
| `st` | 新規タブ |
| `s=` | ウィンドウサイズを均等に |
| `so` | 現在のウィンドウを最大化 |
| `sO` | ウィンドウサイズをリセット |

### コード操作

| キー | 機能 | 説明 |
|------|------|------|
| `<C-]>` または `<C-j>` | 定義へジャンプ | CoC定義ジャンプ |
| `<C-/>` | 参照検索 | CoC参照検索 |
| `ga` | EasyAlign | テキスト整列 |
| `tt` | CamelCase切り替え | snake_case ⇔ camelCase |
| `tc` | CamelCase変換 | camelCaseに変換 |
| `ts` | snake_case変換 | snake_caseに変換 |
| `,w/b/e` | CamelCase移動 | CamelCase単位で移動 |

### その他

| キー | 機能 |
|------|------|
| `x` | 削除（ヤンクしない） |
| `{<Enter>` | 自動改行付き括弧 |
| `[<Enter>` | 自動改行付き角括弧 |
| `(<Enter>` | 自動改行付き丸括弧 |

## プラグイン一覧

### UI/テーマ
- `molokai` - カラースキーム
- `vim-airline` - ステータスライン
- `lightline.vim` - 軽量ステータスライン
- `indentLine` - インデント表示
- `vim-devicons` - ファイルアイコン

### ファイル管理
- `defx.nvim` - ファイルエクスプローラー
- `unite.vim` - ファジー検索
- `denite.nvim` - 非同期ファジー検索

### Git
- `vim-fugitive` - Git操作
- `gh.vim` - GitHub CLI統合
- `tig-explorer.vim` - Tig統合
- `vim-rhubarb` - GitHub統合

### コード補完/LSP
- `coc.nvim` - LSPクライアント
- `copilot.vim` - GitHub Copilot

### コード編集
- `vim-surround` - 括弧操作
- `vim-multiple-cursors` - マルチカーソル
- `tcomment_vim` - コメントトグル
- `switch.vim` - true/false等の切り替え
- `operator-camelize.vim` - CamelCase変換
- `CamelCaseMotion` - CamelCase移動
- `vim-qfreplace` - Quickfix一括置換
- `emmet-vim` - HTML/CSS略語展開
- `tagalong.vim` - HTMLタグ自動リネーム

### 言語サポート
- `vim-polyglot` - 多言語シンタックス
- `vim-styled-components` - styled-components
- `scss-syntax.vim` - SCSS
- `vim-markdown` - Markdown
- `vim-graphql` - GraphQL
- `vim-prisma` - Prisma
- `vim-goimports` - Go import管理

### 開発ツール
- `vim-test` - テストランナー
- `vim-dispatch` - 非同期実行
- `ale` - 非同期リント
- `editorconfig-vim` - EditorConfig
- `spelunker.vim` - スペルチェック
- `vim-sonictemplate` - コードテンプレート

### その他
- `vimproc.vim` - 非同期実行ライブラリ
- `vim-operator-user` - カスタムオペレーター
- `node-host` - Node.jsホスト
- `vim-coloresque` - カラーコードプレビュー
- `aider.nvim` - AI支援

## 保存時の自動フォーマット対応ファイル

- JSON/JSONC
- CSS/SCSS
- Markdown
- TypeScript/TSX
- JavaScript/JSX
- Vue
- Prisma
- Go
- PHP

## テスト実行

`<Leader>t`でテスト実行。以下のテストランナーを自動検出：

- **PHP**: `./vendor/bin/phpunit`
- **JavaScript/TypeScript**: Jest、Vitest、Mocha
- **Go**: `go test`

## 設定ファイル

- `init.vim` - メイン設定ファイル
- `plugins.toml` - dein.vimプラグイン管理
- `coc-settings.json` - CoC.nvim（LSP）設定
- `sonictemplate/` - コードテンプレート

## 必要な外部ツール

以下のツールがインストールされている場合、自動的に利用されます：

- `ag` (The Silver Searcher) - 高速grep
- `efm-langserver` - Markdown用言語サーバー
- `golangci-lint` - Goリンター
- `shellcheck` - シェルスクリプトリンター
- `shfmt` - シェルスクリプトフォーマッター
- 各言語のLSP（自動インストール）

## トラブルシューティング

### プラグインのインストール
```vim
:call dein#install()
:call dein#update()
```

### CoC拡張のインストール
自動的にインストールされますが、手動で実行する場合：
```vim
:CocInstall coc-tsserver coc-eslint coc-prettier ...
```

### 言語サーバーが動作しない場合
```vim
:CocConfig
```
で設定を確認し、必要な言語サーバーがインストールされているか確認してください。
