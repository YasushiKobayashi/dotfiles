#!/usr/bin/env bash
# Claude Code PreToolUse hook: git push の直前に origin/<default> を必ず取り込む。
#
# - 既に取り込み済み（origin/main が HEAD の祖先）なら何もせず通す
# - 遅れていれば fetch → merge --no-edit して push を通す
# - merge が失敗したら merge --abort して push を deny し、理由を Claude に返す
#
# 上書き用の環境変数:
#   CLAUDE_PUSH_BASE_BRANCH  取り込む基準ブランチ（既定: origin/HEAD → main）
#   CLAUDE_PUSH_SKIP_MERGE=1 このフックを無効化

set -uo pipefail

PATH="$HOME/.local/share/aquaproj-aqua/bin:/opt/homebrew/bin:/usr/local/bin:$PATH"

allow() { exit 0; }

# 文字列を JSON 文字列リテラル（引用符込み）に変換する
json_str() {
  if command -v jq >/dev/null 2>&1; then
    printf '%s' "$1" | jq -Rs .
  else
    printf '%s' "$1" |
      sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' |
      awk 'BEGIN{ORS=""; print "\""} {printf "%s%s", (NR>1 ? "\\n" : ""), $0} END{print "\""}'
  fi
}

deny() {
  # permissionDecision: deny で push をブロックし、理由を Claude に返す
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":%s}}\n' "$(json_str "$1")"
  exit 0
}

note() {
  printf '{"systemMessage":%s,"suppressOutput":true}\n' "$(json_str "$1")"
  exit 0
}

[ "${CLAUDE_PUSH_SKIP_MERGE:-}" = "1" ] && allow

payload=$(cat)

if command -v jq >/dev/null 2>&1; then
  cmd=$(printf '%s' "$payload" | jq -r '.tool_input.command // ""')
  cwd=$(printf '%s' "$payload" | jq -r '.cwd // ""')
else
  cmd=""
  cwd=""
fi
[ -n "$cwd" ] && [ -d "$cwd" ] && cd "$cwd" 2>/dev/null

# 実際に push でないもの / 取り込みが無意味なものは素通し
case "$cmd" in
  *"git push"*) ;;
  "") ;;                       # jq が無い場合は if フィルタを信頼する
  *) allow ;;
esac
case "$cmd" in
  *--dry-run*|*--delete*|*" -d "*|*--tags*|*--mirror*) allow ;;
esac

git rev-parse --is-inside-work-tree >/dev/null 2>&1 || allow

# 基準ブランチの決定
base="${CLAUDE_PUSH_BASE_BRANCH:-}"
if [ -z "$base" ]; then
  base=$(git symbolic-ref --quiet --short refs/remotes/origin/HEAD 2>/dev/null)
  base="${base#origin/}"
  [ -z "$base" ] && base="main"
fi

git rev-parse --verify --quiet HEAD >/dev/null 2>&1 || allow
git symbolic-ref --quiet HEAD >/dev/null 2>&1 || allow   # detached HEAD は対象外

fetch_err=$(git fetch --quiet origin "$base" 2>&1)
if [ $? -ne 0 ]; then
  deny "origin/$base の fetch に失敗したため push をブロックしました。取り込み済みか判定できません。

$fetch_err

ネットワーク/認証を確認して再実行するか、意図的にスキップする場合は CLAUDE_PUSH_SKIP_MERGE=1 を付けてください。"
fi

git rev-parse --verify --quiet "origin/$base" >/dev/null 2>&1 || allow

# 既に取り込み済みなら何もしない
git merge-base --is-ancestor "origin/$base" HEAD && allow

behind=$(git rev-list --count "HEAD..origin/$base" 2>/dev/null || echo "?")
merge_err=$(git merge --no-edit "origin/$base" 2>&1)
if [ $? -ne 0 ]; then
  conflicted=$(git diff --name-only --diff-filter=U 2>/dev/null)
  if [ -n "$conflicted" ]; then
    # コンフリクトは abort せずに残す（Claude にそのまま解決させるため）
    deny "origin/$base ($behind commits) の取り込みでコンフリクトしました。push はブロックしています。

コンフリクト中のファイル:
$conflicted

merge は abort していません。この状態のまま resolve-conflict skill でコンフリクトを解決し、git add + git commit で merge を完了させてから push をやり直してください。
（取り込み自体を中止する場合のみ git merge --abort）"
  fi
  # merge が始まっていない失敗（作業ツリー汚れ / 進行中の merge・rebase など）は後始末して deny
  git merge --abort >/dev/null 2>&1
  deny "origin/$base ($behind commits) の取り込みを開始できなかったため push をブロックしました（作業ツリーは元の状態）。

$merge_err

未コミットの変更があるなら commit または stash し、merge/rebase/cherry-pick が進行中ならそれを完了させてから push をやり直してください。"
fi

note "push 前に origin/$base ($behind commits) を merge しました"
