# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## プロジェクト概要

このリポジトリは、macOS開発環境セットアップ用の個人dotfilesリポジトリです。Neovim、シェル環境、言語サーバー、および開発ユーティリティなど、さまざまな開発ツールの設定ファイルとスクリプトが含まれています。

## 主要ツールとパッケージマネージャー

- **aqua**: `aqua.yaml`を使用した宣言的ツール管理のCLIバージョンマネージャー
- **sheldon**: `sheldon/plugins.toml`で設定されたZshプラグインマネージャー
- **dein.vim**: `nvim/plugins.toml`を使用したNeovimプラグインマネージャー
- **renovate**: `renovate.json`で設定された自動依存関係更新

## よく使用するコマンド

### ツール管理
```bash
# aqua経由でツールのインストール/更新
aqua install

# シェルプラグインの更新
sheldon lock --update
```

### 開発環境
```bash
# Neovim設定
nvim ~/.config/nvim/init.vim
nvim ~/.config/nvim/plugins.toml
nvim ~/.config/nvim/coc-settings.json

# Neovimプラグインのインストール（nvim内で実行）
:call dein#install()
:call dein#update()
```

### プロジェクト開発
```bash
# vim-testを使用したテストファイル実行（nvimで<Leader>tにマップ済み）
# PHPUnit、Jest、Go testなど様々なテストランナーをサポート

# 言語サーバーを使用したリントとフォーマット
# 保存時の自動フォーマットが有効：JSON、CSS、TypeScript、JavaScript、Vue、Go、PHP
```

## アーキテクチャと主要ディレクトリ

### 設定構造
- `nvim/`: Neovim設定
  - `init.vim`: キーバインドとプラグイン設定を含むメイン設定ファイル
  - `plugins.toml`: dein.vimを使用したプラグイン定義
  - `coc-settings.json`: LSPと補完設定
  - `sonictemplate/`: Go、PHP、TypeScriptのコードテンプレート
- `coc/`: VSCodeスタイルの言語サーバー設定
- `sheldon/`: Zshプラグイン管理
- `tmuxinator/`: 様々なプロジェクト用のTmuxセッションテンプレート
- `efm-langserver/`: Markdownリント用の言語サーバー設定

### 言語サポート
**設定済みの主要言語:**
- **Go**: golangci-lint、goimports、テストを含む完全なLSPサポート
- **PHP**: Intelephense LSP、PHP CS Fixer（Pint）、PHPUnitテスト
- **TypeScript/JavaScript**: TSServer、ESLint、Prettier、Jest/Vitestテスト
- **Vue**: Vetur言語サーバーサポート
- **CSS/SCSS**: 組み込み検証とフォーマット
- **Markdown**: textlintを使用したEFM言語サーバー
- **Rust**: RLS言語サーバーサポート
- **Docker**: Dockerfile用言語サーバー
- **Terraform**: 言語サーバーサポート

### aquaで管理される開発ツール
利用可能な主要ツール: `gh`、`fzf`、`jq`、`docker`、`terraform`、`aws-cli`、`gcloud`、`buf`、`air`、`golangci-lint`、`trivy`、`deno`、`bun`

## テストアプローチ

テストはvim-testプラグインをdispatch戦略で実行:
- PHP: `./vendor/bin/phpunit`
- JavaScript/TypeScript: Jest、Vitest、Mochaなどを自動検出
- Go: 標準の`go test`を使用
- その他の言語: プロジェクト構造に基づく自動検出

## リントとフォーマット

CoC LSPを通じて、ほとんどのファイルタイプで保存時の自動フォーマットが有効。主要なリンター:
- **ESLint**: JavaScript/TypeScript
- **golangci-lint**: Go（広範囲なルールセット）
- **PHP CS Fixer/Pint**: PHP
- **Prettier**: Web技術
- **shellcheck**: シェルスクリプト

## IDE統合

Neovim向けに最適化された設定:
- LSP機能（補完、診断、フォーマット）のためのCoC
- GitHub Copilot統合
- 広範囲な言語サーバー設定
- ナビゲーションとテスト用のカスタムキーバインド