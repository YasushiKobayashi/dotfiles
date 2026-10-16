#!/usr/bin/env bash
# ファイルを、そのリポジトリのメインのチェックアウト直下の old_task/ へ移動する。
#
# usage: move_to_old_task.sh <file>...
#
# - git worktree 内のファイルも、worktree ではなくメインのチェックアウトの old_task/ に集める
#   （worktree は撤去されることがあり、そこに置くと一緒に消えるため）
# - git 管理外のディレクトリなら、ファイルと同じディレクトリの old_task/ に置く
# - 同名ファイルがあれば <名前>-<元ディレクトリ名>.md にする。それも埋まっていたら移動しない（上書きしない）
#
# zsh の chpwd フック等が出力を汚すので、cd は使わず git -C で解決する。
set -uo pipefail

for f in "$@"; do
  [[ -f $f ]] || { echo "SKIP(not found) $f" >&2; continue; }
  src_dir=$(dirname "$f")
  src_abs=$(git -C "$src_dir" rev-parse --show-toplevel 2>/dev/null || echo "$src_dir")
  common=$(git -C "$src_dir" rev-parse --path-format=absolute --git-common-dir 2>/dev/null || true)
  if [[ -n $common ]]; then root=$(dirname "$common"); else root=$src_dir; fi

  mkdir -p "$root/old_task"
  # task.*.md 以外（レビューメモ等）も退避するので、old_task/ ごと git から隠す。
  # .git/info/exclude はリポジトリに commit されないローカル設定なので、他の開発者には影響しない。
  if [[ -n $common ]]; then
    exclude="$common/info/exclude"
    grep -qxF 'old_task/' "$exclude" 2>/dev/null || { mkdir -p "$common/info"; echo 'old_task/' >>"$exclude"; }
  fi
  base=$(basename "$f")
  dest="$root/old_task/$base"
  if [[ -e $dest ]]; then dest="$root/old_task/${base%.*}-$(basename "$src_abs").${base##*.}"; fi
  if [[ -e $dest ]]; then echo "SKIP(衝突) $f" >&2; continue; fi

  mv "$f" "$dest" && printf '%s -> %s\n' "$f" "$dest"
done
