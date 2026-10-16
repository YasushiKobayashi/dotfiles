#!/usr/bin/env bash
# タスクファイル（task.*.md）ごとに、未チェック項目の数と、紐付く PR / issue の状態を TSV で出す。
#
# usage: task_status.sh <task.*.md>...
# 出力列: path, 最終更新日, 未チェック/総数, 主参照(state), その他参照(state)
#
# 主参照 = ファイル名から読める番号（task.pr_<N>.md → PR N / task.<N>.md → issue または PR N）。
# 名前に番号が無いファイルは、本文の GitHub URL がすべて主参照になる。
# 取りまとめ用 issue を本文で言及しているだけのファイルを「OPEN 参照あり」と誤判定しないため、
# 判定は主参照で行い、その他参照は参考情報として並べる。
set -uo pipefail

state_of() { # $1=owner/repo $2=number -> MERGED / OPEN / CLOSED / ?（404 等の取得失敗）
  local s
  # 404 のとき gh はエラー本文の JSON を stdout に出すので、既知の値以外は捨てる
  s=$(gh api "repos/$1/issues/$2" \
    --jq 'if .pull_request then (if .pull_request.merged_at then "MERGED" else (.state|ascii_upcase) end) else (.state|ascii_upcase) end' \
    2>/dev/null)
  case $s in MERGED | OPEN | CLOSED) echo "$s" ;; *) echo "?" ;; esac
}

for f in "$@"; do
  dir=$(dirname "$f")
  repo=$(git -C "$dir" remote get-url origin 2>/dev/null | sed -E 's#.*github\.com[:/]##; s#\.git$##')
  name=$(basename "$f" .md); name=${name#task.}
  unchecked=$(grep -cE '^[[:space:]]*[-*] \[ \]' "$f")
  total=$(grep -cE '^[[:space:]]*[-*] \[[ xX]\]' "$f")

  primary=""
  if [[ -n $repo && $name =~ ^pr_([0-9]+) ]]; then primary="$repo ${BASH_REMATCH[1]}"
  elif [[ -n $repo && $name =~ ^([0-9]+)($|[-_]) ]]; then primary="$repo ${BASH_REMATCH[1]}"
  fi

  body_refs=$(grep -oE 'github\.com/[A-Za-z0-9_.-]+/[A-Za-z0-9_.-]+/(pull|issues)/[0-9]+' "$f" |
    sed -E 's#github\.com/##; s#/(pull|issues)/# #' | sort -u)

  p_out=""; o_out=""
  if [[ -n $primary ]]; then
    read -r r n <<<"$primary"; p_out="${r##*/}#$n:$(state_of "$r" "$n")"
  fi
  while read -r r n; do
    [[ -z ${n:-} || "$r $n" == "$primary" ]] && continue
    s="${r##*/}#$n:$(state_of "$r" "$n")"
    if [[ -z $primary ]]; then p_out+="$s "; else o_out+="$s "; fi
  done <<<"$body_refs"

  mtime=$(stat -f %Sm -t %F "$f" 2>/dev/null || stat -c %y "$f" | cut -c1-10)
  printf '%s\t%s\t%s/%s\t%s\t%s\n' "$f" "$mtime" "$unchecked" "$total" "${p_out:-none}" "$o_out"
done
