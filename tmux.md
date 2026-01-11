# tmux Configuration

## 概要
開発効率を高めるtmux設定。特にNeovimとの連携に特化し、AIエージェント出力からのパスジャンプ機能を実装。

## Prefixキー
デフォルト: `Ctrl-b`

## キーバインド

### 基本操作
| キー | 機能 | 説明 |
|------|------|------|
| `prefix + l` | 設定再読み込み | `.tmux.conf`を再読み込み |
| `prefix + v` | 垂直分割 | ウィンドウを左右に分割 |
| `prefix + w` | 水平分割 | ウィンドウを上下に分割 |

### Neovim連携（左ペインジャンプ）
| キー | 機能 | 説明 |
|------|------|------|
| `prefix + o` | パス選択ジャンプ | 画面内のパスをfzfで選択→左nvimへジャンプ |
| `prefix + t` | tmux-thumbsジャンプ | ヒント表示→選択→左nvimへジャンプ |
| copy-mode + `Enter` | 選択テキストジャンプ | 選択したパスを左nvimで開く |

### 対応パスフォーマット
- `path/to/file.txt` - ファイルパス
- `path/to/file.txt:42` - ファイル:行番号
- `path/to/file.txt:42:10` - ファイル:行:列

## 基本設定

### 表示
- **ターミナル**: 256色対応 (`screen-256color`)
- **ステータスバー**: 現在のディレクトリ名を表示
- **更新間隔**: 1秒ごとに更新

### 操作
- **コピーモード**: viキーバインド
- **マウス**: 有効（スクロール、選択など）
- **ESCキー遅延**: 0ms（Vimとの相性向上）

## プラグイン

### tmux-plugins/tpm
プラグインマネージャー。他のプラグインのインストール/更新を管理。

**インストール方法**:
```bash
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
```

**使い方**:
- `prefix + I`: プラグインインストール
- `prefix + U`: プラグイン更新
- `prefix + alt + u`: プラグインアンインストール

### nhdaly/tmux-better-mouse-mode
マウス操作の改善。スムーズなスクロール、コピー＆ペーストの最適化。

### fcsonline/tmux-thumbs
画面上のパス、URL、ハッシュなどをヒント表示で素早く選択。

**設定内容**:
- トリガーキー: `prefix + t`
- 選択時のコマンド: `open_in_nvim_left`（左ペインのnvimで開く）
- 認識パターン:
  - 相対パス: `./path/to/file`
  - 絶対パス: `/path/to/file`
  - ホームパス: `~/path/to/file`
  - 行番号付き: `file.txt:42`
  - 行列番号付き: `file.txt:42:10`

## 左Neovimジャンプ機能

### 概要
AIエージェントやログ出力を右ペインで表示し、含まれるファイルパスを左ペインのNeovimへ即座にジャンプ。

### セットアップ

1. **必要なツール**:
   - `nvr` (Neovim Remote)
   - `fzf`
   - `rg` (ripgrep)
   - `tmux-thumbs`（オプション）

2. **スクリプト配置**:
   - `bin/nvim-left`: 左ペイン用Neovim起動スクリプト
   - `bin/open_in_nvim_left`: パスを左nvimで開くスクリプト
   - `bin/tmux_pick_path`: fzfでパスを選択するスクリプト

3. **使用方法**:
   ```bash
   # 左ペインでNeovimを起動
   nvim-left

   # 右ペインでAIエージェントやログを表示
   # 出力にパスが含まれている場合...

   # 方法1: prefix + o でパス選択
   # 方法2: prefix + t でヒント表示（tmux-thumbs）
   # 方法3: copy-modeで選択してEnter
   ```

### 動作原理
1. 左ペインのNeovimが`/tmp/nvim-left.sock`でリッスンモード起動
2. 右ペインからパスを検出・選択
3. `nvr`コマンドで左Neovimにファイルを開く指示を送信
4. 相対パスは右ペインのカレントディレクトリを基準に解決

### iTerm2連携
iTerm2のSemantic Historyと連携し、`Cmd+Click`でパスを開く：

**設定方法**:
1. iTerm2 > Settings > Profiles > Advanced > Semantic History
2. Action: `Run command`
3. Command:
   ```bash
   /bin/bash -lc "$HOME/.local/bin/open_in_nvim_left \"\1\""
   ```
4. Regex:
   ```
   ([A-Za-z0-9_./~+-]+/[A-Za-z0-9_./~+.-]+(?::\d+(?::\d+)?)?)
   ```

## トラブルシューティング

### プラグインが動作しない
```bash
# TPMを再インストール
rm -rf ~/.tmux/plugins/tpm
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# tmux設定を再読み込み
tmux source-file ~/.tmux.conf

# プラグインをインストール
# tmux内で: prefix + I
```

### 左nvimジャンプが動かない
```bash
# ソケットファイルの確認
ls -la /tmp/nvim-left.sock

# nvr がインストールされているか確認
which nvr || pip install neovim-remote

# 左ペインでnvim-leftを起動しているか確認
ps aux | grep nvim-left
```

### マウススクロールが効かない
```bash
# tmux-better-mouse-modeが読み込まれているか確認
tmux show-options -g | grep mouse

# 設定を再読み込み
tmux source-file ~/.tmux.conf
```

## Tips

### セッション管理
```bash
# セッション一覧
tmux ls

# セッション作成
tmux new -s myproject

# セッションにアタッチ
tmux a -t myproject

# セッション切り替え
# tmux内で: prefix + s
```

### ウィンドウ/ペイン操作
```bash
# 新規ウィンドウ: prefix + c
# ウィンドウ切り替え: prefix + 数字
# ペインを閉じる: prefix + x
# ペインの最大化: prefix + z
# ペインの移動: prefix + o
```

### コピーモード
```bash
# コピーモード開始: prefix + [
# 選択開始: v
# 選択終了＆コピー: y
# ペースト: prefix + ]
```