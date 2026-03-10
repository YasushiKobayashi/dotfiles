#!/bin/bash

# Claude Code notification script
# Triggered by hooks on Stop and Notification events

SOUND_FILE="$HOME/private-dotfile/claude/notify-sound.mp3"

# Test mode: notify.sh --test [stop|notification]
if [ "$1" = "--test" ]; then
  EVENT="${2:-Stop}"
  case "$EVENT" in
    stop|Stop) INPUT='{"hook_event_name":"Stop"}' ;;
    notification|Notification) INPUT='{"hook_event_name":"Notification","message":"テスト通知です"}' ;;
    *) echo "Usage: $0 --test [stop|notification]"; exit 1 ;;
  esac
else
  INPUT=$(cat)
fi

EVENT=$(echo "$INPUT" | jq -r '.hook_event_name // empty')

case "$EVENT" in
  "Notification")
    TITLE="Claude Code"
    MESSAGE=$(echo "$INPUT" | jq -r '.message // "通知があります"')
    ;;
  "Stop")
    TITLE="Claude Code"
    MESSAGE="タスクが完了しました"
    ;;
  *)
    # 未知のイベントは無視する
    exit 0
    ;;
esac

# Send notification and play sound as fully detached processes
nohup terminal-notifier -title "$TITLE" -message "$MESSAGE" -sender com.googlecode.iterm2 >/dev/null 2>&1 &
nohup afplay "$SOUND_FILE" >/dev/null 2>&1 &
