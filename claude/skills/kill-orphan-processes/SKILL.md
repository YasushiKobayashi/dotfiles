---
name: kill-orphan-processes
description: PCが重い時に、orphan化した dev tool プロセス（vitest / vite / jest / playwright / esbuild / tsc / storybook 等）を検出して kill する。「PC重い」「vitest残ってる」「不要なプロセス切って」と言われた時に使用。tmux配下のプロセスは保護対象として除外する。
argument-hint: '[pattern]'
allowed-tools: Bash(ps:*), Bash(pgrep:*), Bash(pkill:*), Bash(kill:*), Bash(tmux list-panes:*), Bash(tmux ls:*), AskUserQuestion
---

# Orphan Dev プロセス kill

## 概要

`vitest` などの dev ツールが test runner / IDE のクラッシュ後に orphan (PPID=1) として残り、CPU を食い続けるケースを掃除する。**tmux 配下で動いているプロセス（開発者が意図的に走らせている dev server / watch 等）は kill しない**。

**指定されたパターン**: $ARGUMENTS（未指定の場合は dev tool 既定パターン）

---

## 既定の対象パターン

引数で別パターンが指定されなければ、以下を候補とする:

```
vitest|jest|vite[^a-z]|esbuild|tsc|eslint|playwright|storybook|webpack|rollup|turbo
```

`bun dev` / `next dev` / `nodemon` などの **意図的な dev server** は基本的に親 (tmux pane / VSCode terminal) を持つので候補に含めず、**PPID=1 (orphan) のみ** を kill 対象とする。

---

## タスク

### 1. tmux 配下のプロセス PID 集合を作成（保護対象）

```bash
# tmux サーバが動いていなければ空集合
TMUX_PANE_PIDS=$(tmux list-panes -aF '#{pane_pid}' 2>/dev/null | tr '\n' ' ' || true)
```

各 pane の shell PID を起点に **子孫すべて** を再帰的に展開して保護セットを作る。Python で実装するのが楽:

```bash
PROTECTED_PIDS=$(ROOTS="$TMUX_PANE_PIDS" python3 - <<'PY'
import os, subprocess
roots = set(os.environ.get('ROOTS', '').split())
out = subprocess.check_output(['ps', '-eo', 'pid=,ppid=']).decode().splitlines()
children = {}
for line in out:
    parts = line.split()
    if len(parts) < 2: continue
    pid, ppid = parts[0], parts[1]
    children.setdefault(ppid, []).append(pid)
protected, stack = set(), list(roots)
while stack:
    p = stack.pop()
    if p in protected: continue
    protected.add(p)
    stack.extend(children.get(p, []))
print(' '.join(sorted(protected)))
PY
)
```

### 2. orphan 候補を列挙

```bash
PATTERN='vitest|jest|vite[^a-z]|esbuild|tsc|eslint|playwright|storybook|webpack|rollup|turbo'
# ${ARGUMENTS:-...} で引数があれば差し替え

ps -eo pid=,ppid=,pcpu=,pmem=,etime=,command= \
  | awk -v pat="$PATTERN" '$2=="1" && tolower($0) ~ pat { print }'
```

このうち `PROTECTED_PIDS` に含まれる PID は除外する（念のため。orphan は基本 tmux 配下にならないが、サニティ）。

### 3. ユーザー確認（HITL）

`AskUserQuestion` で候補一覧を提示して承認を取る:

```
## kill 候補（orphan, tmux配下除外済み）

PID    CPU%  MEM%  ETIME    COMMAND
66879  53.9  0.6   09:22    node (vitest 1)
66950  55.7  1.2   09:21    node (vitest 11)
...

合計 12 プロセス、合計 CPU 約 600%
```

選択肢:

- 全部 kill する
- パターンを絞り込む（例: vitest だけ）
- キャンセル

### 4. kill 実行

承認後、PID を明示して `kill <pid1> <pid2> ...` を実行（`pkill -f` はパターン誤爆のリスクがあるので避ける）。2秒待って残存確認:

```bash
kill $PIDS_TO_KILL
sleep 2
ps -p $PIDS_TO_KILL -o pid=,command= 2>/dev/null || echo "all killed"
```

残ったものは `kill -9` で SIGKILL を当てるか、ユーザーに再度確認する。

### 5. 結果報告

何プロセス kill したか、解放された CPU%、残存があれば PID を表示。

---

## 注意事項

- **tmux 配下は絶対に kill しない**: ユーザーが意図して動かしている dev server / watcher を巻き込まないため。tmux pane PID の子孫を必ず保護セットに入れる
- **PPID=1 (orphan) のみ対象**: 親プロセスがいる = 何かに管理されている可能性が高いので触らない
- **`pkill -f` は使わない**: パターン誤爆で関係ない node プロセスを巻き込む事故が起きやすい。必ず PID を明示
- **ユーザー確認は必須**: 候補一覧を見せて承認を取ってから kill
- **kill は sandbox で拒否される可能性**: その場合は `dangerouslyDisableSandbox: true` で再実行（プロセス kill は sandbox の外の操作のため）
