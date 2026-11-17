#!/data/data/com.termux/files/usr/bin/bash
# Shows your Claude 5h window as a pinned notification (and a toast with --toast).
. "$HOME/.config/claude5h/env"
export CLAUDE_CODE_OAUTH_TOKEN
s=$(bash "$HOME/bin/claude5h-usage.sh")
state=$(echo "$s" | jq -r .state)
case "$state" in
  active)
    used=$(echo "$s" | jq -r .used)
    at=$(date -d "$(echo "$s" | jq -r .resets_at)" +%H:%M 2>/dev/null)
    title="⏳ Claude window running"; text="$used% used · resets $at" ;;
  idle)
    title="🟢 Claude window UNUSED"; text="Tap Start to begin a 5h window" ;;
  *)
    title="❔ Claude status unknown"; text=$(echo "$s" | jq -r .why | head -c 120) ;;
esac
termux-notification --id claude5h --ongoing --alert-once --priority low \
  --title "$title" --content "$text  (checked $(date +%H:%M))" \
  --button1 "Start" --button1-action "bash $HOME/bin/claude5h-start.sh" \
  --button2 "Refresh" --button2-action "bash $HOME/bin/claude5h-status.sh"
[ "${1:-}" = "--toast" ] && termux-toast "$title — $text"
exit 0
