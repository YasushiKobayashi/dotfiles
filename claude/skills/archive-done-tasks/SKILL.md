---
name: archive-done-tasks
description: 完了した task.*.md（task-start skill の作業ログ）を、紐付く PR / issue の状態と未チェック項目で判定し、リポジトリの old_task/ へ移動する。worktree 内のファイルもメインのチェックアウトの old_task/ に集める。「完了したタスクファイルを old_task に移動して」「タスクファイル片付けて」「old task に移して」と言われた時、またはブランチ・worktree の掃除（clean-stale-branches）のついでに使用。
argument-hint: '[探索ルート（既定: cwd の親ディレクトリ）]'
allowed-tools: Bash(find:*), Bash(git:*), Bash(gh:*), Bash(bash:*), Bash(grep:*), Bash(column:*), Read, AskUserQuestion
---

# 完了タスクファイルの old_task 退避

## 概要

`task-start` skill は 1 タスク 1 ファイル（`task.<issue番号>.md` / `task.pr_<PR番号>.md` / `task.<slug>.md`）で作業ログを残す。完了後も作業ディレクトリに残り続けると、どれが進行中か分からなくなる。この skill は**完了したものだけ**を `old_task/` へ移す。

- **消さない・移すだけ**。ログは後から参照する価値がある（判断の経緯、再発時の調査メモ）。
- **移動先はメインのチェックアウト直下の `old_task/`**。git worktree 内のファイルも worktree 側ではなくメインに集める（worktree は撤去されることがあり、そこに置くと一緒に消える）。
- 判定は機械的な材料（PR / issue の状態、未チェック数）で行い、**判断が要るものはユーザーに聞く**。

スクリプトは同じディレクトリの `scripts/` にある。**zsh の `cd` フックがターミナルタイトルの制御文字を `$(...)` に混ぜて、パスを壊すことがある**ので、パス解決は必ずスクリプト（`git -C` 使用・bash 実行）に任せ、`cd` を含むワンライナーを即興で書かない。

## 手順

### 1. タスクファイルを集める

```bash
ROOT=${1:-$(dirname "$(git rev-parse --show-toplevel)")}   # 既定: リポジトリ群の親ディレクトリ
find "$ROOT" -maxdepth 3 -name 'task.*.md' -not -path '*/old_task/*' -not -path '*/node_modules/*' | sort
```

### 2. 状態を集計する

```bash
S=<skill のディレクトリ>/scripts
bash $S/task_status.sh <files...> > /tmp/tasks.tsv   # scratchpad があればそちらへ
column -t -s$'\t' /tmp/tasks.tsv
```

列は `path / 最終更新日 / 未チェック数/総数 / 主参照(state) / その他参照(state)`。

- **主参照**: ファイル名の番号（`task.pr_123.md` → PR 123、`task.123.md` → issue または PR 123）。名前に番号が無いファイルは本文の GitHub URL すべて。
- **その他参照**: 本文で言及しているだけの PR / issue。取りまとめ用 issue（「〜の現状整理」等）が OPEN でも、それだけを理由に「進行中」と判定しないため、判定には使わない。
- 番号が別リポジトリの issue を指していて 404 になることがある（例: インフラ用リポジトリにある `task.123.md` が、実はアプリ側リポジトリの issue 123 を指す）。その他参照に同じ番号のクローズ済み issue があれば、そちらを主参照とみなす。

### 3. 分類する

| 区分 | 条件 | 扱い |
| --- | --- | --- |
| **完了** | 主参照がすべて MERGED / CLOSED、かつ未チェック 0 | そのまま移動してよい |
| **ほぼ完了** | 主参照はすべて MERGED / CLOSED だが、未チェックが残る | 未チェック項目を `grep -nE '^\s*[-*] \[ \]'` で読み、下の基準で振り分けてユーザーに確認 |
| **進行中** | 主参照に OPEN がある | 移動しない |
| **参照なし** | 主参照が無い（Sentry 起点で未起票など） | 本文冒頭を読み、PR 未作成なら進行中として残す。終わっていそうならユーザーに確認 |

「ほぼ完了」の振り分け基準:

- **移動を推奨**: 残りが「派生 issue で対応」「別件メモ」「マージ待ち（実際はマージ済み）」「任意の手動確認（他ブラウザ等）」だけ
- **残すことを推奨**: 残りに「ユーザー判断待ち」「ビズ確認待ち」「マージ後の設定反映・実効性確認」「対応する OpenSpec change が未アーカイブ」がある

`AskUserQuestion` では、推奨して移すファイルと残すファイルを**名前付きで**並べ、残すものには理由を 1 行で添える。

### 4. 移動する

```bash
bash $S/move_to_old_task.sh <files...>
```

- 移動先: `<メインのチェックアウト>/old_task/<ファイル名>`。同名があれば `<名前>-<元ディレクトリ名>.md`。それも埋まっていれば `SKIP(衝突)` で移動しない（上書きしない）。
- `old_task/` を `.git/info/exclude` に追加する。`task.*.md` はグローバル gitignore で隠れていても、一緒に退避したレビューメモ（`review-*.md` 等）は隠れないため。`.git/info/exclude` は commit されないローカル設定で、他の開発者には影響しない。

### 5. 確認と報告

```bash
git -C <repo> status --porcelain --untracked-files=all -- old_task   # 0 行であること
```

報告には次を含める:

- 移動したファイル数（リポジトリ別）
- 「ほぼ完了」から移動したものと、残したもの（理由つき）
- 進行中として残したファイル数

## 注意事項

- **ファイルを削除しない**。片付けは移動だけで行う。
- **保護 worktree でも移動はしてよい**。`hoge` / `huga` 等の worktree は撤去しないが、その中の完了タスクファイルは移す（作業場所を軽くするのが目的なので）。
- **worktree を撤去する前に**、その worktree にある未追跡のメモ（`task.*.md` / `review-*.md`）を `move_to_old_task.sh` で退避する。`git worktree remove` は未追跡ファイルがあると失敗し、`--force` すると消える。
- `gh api` を 1 参照 1 回呼ぶので、ファイルが多いと時間がかかる（50 ファイル・150 参照で数十秒〜数分）。
