# dotfiles

個人的なmacOS/Linux開発環境セットアップ用dotfilesリポジトリ。

## 前提条件

**重要**: このリポジトリは `~/dotfiles` にクローンする必要があります。多くの設定ファイルがこのパスを前提としています。

```bash
git clone https://github.com/[username]/dotfiles.git ~/dotfiles
```

## 概要

このリポジトリには、以下の開発環境設定が含まれています：

- **エディタ**: Neovim（LSP、補完、テスト実行環境）
- **ターミナル**: Zsh + Sheldon（プラグイン管理）
- **セッション管理**: tmux（Neovim連携機能付き）
- **ツール管理**: aqua（クロスプラットフォーム対応）
- **その他**: Git、Docker、各種言語環境設定

## クイックスタート

```bash
# 1. リポジトリをクローン（必ず ~/dotfiles に）
git clone https://github.com/[username]/dotfiles.git ~/dotfiles

# 2. シンボリックリンクを作成
cd ~/dotfiles
./dotfiles_link.sh

# 3. 必要なツールをインストール
# aqua
aqua install

# 4. Neovimプラグインをインストール
nvim
# Neovim内で実行
:call dein#install()

# 5. tmuxプラグインをインストール（tmux内で）
# prefix + I
```

## 主要設定

### Neovim (`nvim/`)
- **プラグイン管理**: dein.vim
- **LSP/補完**: CoC.nvim
- **テスト実行**: vim-test（dispatch戦略）
- **コード支援**: GitHub Copilot
- 詳細: [nvim/README.md](nvim/README.md)

### tmux (`.tmux.conf`)
- **Prefix**: `Ctrl-b`（デフォルト）
- **特徴**: 左Neovimジャンプ機能（AIエージェント出力連携）
- **プラグイン**: tpm、tmux-thumbs、better-mouse-mode
- 詳細: [tmux.md](tmux.md)

### Zsh (`.zshrc`)
- **プラグイン管理**: Sheldon
- **PATH設定**: `~/dotfiles/bin`が自動的にPATHに追加
- **補完**: 大文字小文字を区別しない補完
- **履歴**: 100,000件保存、重複除外

### ツール管理 (`aqua.yaml`)
主要ツール（自動インストール）：
- fzf、ripgrep、jq、gh（GitHub CLI）
- docker、terraform、aws-cli、gcloud
- golangci-lint、buf、air
- deno、bun、uv

## ディレクトリ構造

```
~/dotfiles/
├── nvim/               # Neovim設定
│   ├── init.vim        # メイン設定
│   ├── plugins.toml    # プラグイン定義
│   ├── coc-settings.json # LSP設定
│   └── sonictemplate/  # コードテンプレート
├── bin/                # 実行可能スクリプト（PATHに追加）
│   ├── nvim-left       # 左ペイン用Neovim起動
│   ├── open_in_nvim_left # パスを左nvimで開く
│   └── tmux_pick_path  # fzfでパス選択
├── sheldon/            # Zshプラグイン設定
├── tmuxinator/         # tmuxセッションテンプレート
├── efm-langserver/     # Markdown用言語サーバー
├── claude/             # Claude Code設定
├── .zshrc              # Zsh設定
├── .tmux.conf          # tmux設定
├── aqua.yaml           # ツール管理
├── CLAUDE.md           # プロジェクト指示書
└── dotfiles_link.sh    # シンボリックリンク作成スクリプト
```

## 対応言語/フレームワーク

### フロントエンド
- TypeScript/JavaScript（ESLint、Prettier）
- Vue.js（Vetur）
- React（TSX/JSX）
- CSS/SCSS（Stylelint、Tailwind CSS）

### バックエンド
- Go（golangci-lint、goimports）
- PHP（Intelephense、PHP CS Fixer）
- Rust（RLS、rustfmt）
- Python（Ruff、Black）

### インフラ/その他
- Docker/Docker Compose
- Terraform
- Kubernetes
- Shell Script（shellcheck、shfmt）

## 特殊機能

### AIエージェント連携（tmux + Neovim）
右ペインのAI出力から左ペインのNeovimへ即座にジャンプ：
- `prefix + p`: パスをfzfで選択してジャンプ
- `prefix + t`: tmux-thumbsでヒント表示してジャンプ
- `Cmd+Click`（iTerm2）: クリックしたパスをNeovimで開く

### テスト実行
`<Leader>t`で現在のファイルのテストを自動実行：
- PHPUnit、Jest、Vitest、Go test等を自動検出
- vim-testとdispatchによる非同期実行

## カスタマイズ

### 環境別設定
- macOS: `.mac_gitconfig`
- Linux: `.linux_gitconfig`

### プロジェクト固有設定
`CLAUDE.md`ファイルでClaude Codeへの指示をカスタマイズ可能。

## トラブルシューティング

### Neovimプラグインが動作しない
```vim
:call dein#install()
:call dein#update()
:CocInstall
```

### tmuxプラグインが動作しない
```bash
# TPM再インストール
rm -rf ~/.tmux/plugins/tpm
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
# tmux内で: prefix + I
```

### PATHが通らない
```bash
# .zshrcを再読み込み
source ~/.zshrc
# または新しいシェルを起動
exec $SHELL
```

## 更新

### 依存関係の自動更新
Renovateによる自動更新が設定済み：
- aqua.yaml のツールバージョン
- Neovimプラグイン
- Zshプラグイン

### 手動更新
```bash
# aquaツール更新
aqua update

# Neovimプラグイン更新（nvim内で）
:call dein#update()

# tmuxプラグイン更新（tmux内で）
# prefix + U
```

## ライセンス

MIT

## 関連ドキュメント

- [nvim/README.md](nvim/README.md) - Neovim設定詳細
- [tmux.md](tmux.md) - tmux設定詳細
- [CLAUDE.md](CLAUDE.md) - Claude Code用プロジェクト指示書
