---
name: clean-stale-branches
description: マージ/クローズ済みPRや古いローカルブランチを安全に掃除する。「古いbranch掃除して」「close済みのPRのブランチ消して」「1ヶ月以上更新ないブランチ消したい」と言われた時に使用。upstream gone / PR状態 / worktree / 未マージ作業を確認し、破壊的削除はユーザー確認を取る。
argument-hint: '[--remote] [days]'
allowed-tools: Bash(git branch:*), Bash(git for-each-ref:*), Bash(git worktree:*), Bash(git fetch:*), Bash(git rev-parse:*), Bash(git rev-list:*), Bash(git merge-base:*), Bash(git log:*), Bash(git push:*), Bash(gh pr list:*), AskUserQuestion
---

# 古い・不要ブランチの掃除

## 概要

ローカル（および任意でリモート）の不要ブランチを、**マージ/クローズ済みPR紐付き**・**upstream削除済み (gone)**・**一定期間更新なし**といった軸で特定し、安全に削除する。

削除は不可逆なので、**確実に安全と判定できるものだけ自動削除**し、**未マージ作業を含むもの・リモート削除・worktreeチェックアウト中のもの**は `AskUserQuestion` で確認を取る。

**引数**: $ARGUMENTS
- `--remote`: リモートブランチ (`git push origin --delete`) も削除対象に含める（要確認、デフォルトはローカルのみ）
- 数値: 「古い」とみなす日数の閾値（デフォルト30日）

---

## 現在の状態

- 現在のブランチ: !`git branch --show-current`
- worktree 一覧: !`git worktree list`
- ローカルブランチ（更新日順）: !`git for-each-ref --sort=committerdate --format='%(committerdate:short) %(upstream:track) %(refname:short)' refs/heads/`

---

## タスク

### 0. 前提

- **現在のブランチ・`main` は絶対に削除しない**。
- worktree でチェックアウト中のブランチは普通に `git branch -D` できない。先に worktree を撤去する必要がある（手順は後述）。

### 1. リモート追跡情報を最新化

```bash
git fetch --prune
```

これで削除済みリモートを追跡していたローカルブランチが `: gone` 表示になる。

### 2. 削除候補を3カテゴリで列挙

#### カテゴリA: upstream が gone（マージ/クローズで remote 削除済み）

```bash
git branch -vv | grep ': gone\]'
```

最も安全な候補。ただし gh で PR 状態を裏取りする（後述）。

#### カテゴリB: 一定期間更新がないブランチ

```bash
# 閾値（デフォルト30日）より古い committerdate のブランチ
git for-each-ref --sort=committerdate \
  --format='%(committerdate:short) %(refname:short)' refs/heads/
```

current / main を除外し、閾値日数より前のものを候補にする。

#### カテゴリC: PR に紐付かないローカル専用ブランチ

upstream を持たない（`git branch -vv` で `[origin/...]` が無い）ローカル専用ブランチ。

### 3. 各候補の PR 状態を gh で裏取り

```bash
for b in <候補ブランチ...>; do
  echo "=== $b ==="
  gh pr list --head "$b" --state all --json number,state,title --limit 5
done
```

- `MERGED` / `CLOSED` → 削除して安全。
- `OPEN` → **削除しない**（作業中）。
- PR 無し（`[]`）→ カテゴリC。未マージ作業の有無を次で確認。

### 4. 未マージ作業の有無を確認（PR無し or CLOSED の場合）

PR が無い、または CLOSED（= main にマージされていない可能性）のブランチは、main に取り込まれているか確認する:

```bash
for b in <候補...>; do
  if git merge-base --is-ancestor "$b" origin/main 2>/dev/null; then
    echo "$b: MERGED into origin/main (安全)"
  else
    echo "$b: NOT in main, $(git rev-list --count origin/main..$b) commits ahead (未マージ作業あり)"
  fi
done
```

### 5. 判定と確認

| 条件 | 扱い |
|---|---|
| PR が MERGED、または main に取り込み済み | **自動削除して良い** |
| PR が CLOSED かつ古い（カテゴリB該当）| クローズ済みPR紐付きなので削除候補。未マージ作業がある旨を添えて確認 |
| PR 無し・main 未取込（未マージ作業あり）| **必ず `AskUserQuestion` で確認**（作業が消える）|
| PR が OPEN | 削除しない |
| worktree チェックアウト中 | worktree 撤去の要否を確認 |
| `--remote` 指定時のリモート削除 | **必ず確認**（外向き・不可逆）|

判断が必要なものは `AskUserQuestion` で、ブランチ名 / 最終更新 / PR番号と状態 / 未マージcommit数 を表で提示して選ばせる。

### 6. 削除実行

#### ローカルブランチ

```bash
git branch -D <branch1> <branch2> ...
```

（マージ済みでも未マージでも消せるよう `-D`。安全判定は前段で済ませている）

#### worktree チェックアウト中のブランチ

先に worktree を撤去してからブランチ削除:

```bash
git worktree remove <worktree_path>   # uncommitted changes があると失敗する → その場合はユーザーに確認
git branch -D <branch>
```

#### リモートブランチ（`--remote` 指定かつ承認時のみ）

```bash
git push origin --delete <branch1> <branch2> ...
```

### 7. 結果報告

削除したブランチを **カテゴリ別 + PR番号/状態** の表で報告する。残したブランチ（OPEN / 作業中 / 閾値内）とその理由も簡潔に添える。リモートが残っている場合はその旨と削除コマンドを案内する。

---

## 注意事項

- **current ブランチと `main` は絶対に削除しない**。
- **`git branch -d` より前に必ず PR 状態と main 取り込みを確認**する。`gh pr list --head <branch> --state all` が一次情報。`: gone` は強いシグナルだが、PR が CLOSED（未マージ）で remote 削除されたケースもあるので過信しない。
- **未マージ作業（main 未取込 commit）を持つブランチは勝手に消さない**。必ず `AskUserQuestion`。一度消すと `git reflog` 頼みになる。
- **worktree チェックアウト中のブランチ**は `git branch -D` が失敗する。`git worktree remove` を先に。uncommitted changes があると remove も失敗するので、その場合はユーザー判断を仰ぐ。
- **リモート削除 (`git push origin --delete`) は外向き・不可逆**。`--remote` 指定があっても必ず最終確認を取る。CLAUDE.md/メモリの「PR作成はユーザー指示を待つ」と同じ温度感で、リモートへの破壊的操作は明示承認を必須とする。
- **「PRに紐付かない」≠「不要」**。ローカルで作業中・未push のブランチもこの形になる。必ず未マージ commit を確認し、作業が残っていれば確認する。
- `git fetch --prune` を最初に実行しないと `: gone` 判定が古いままになる。
