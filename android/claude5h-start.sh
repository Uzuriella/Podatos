#!/data/data/com.termux/files/usr/bin/bash
# Asks GitHub Actions to send the tiny ping right now (force=true).
. "$HOME/.config/claude5h/env"
code=$(curl -sS -o /dev/null -w '%{http_code}' -X POST \
  -H "Authorization: Bearer $GH_TOKEN" -H "Accept: application/vnd.github+json" \
  "https://api.github.com/repos/$GH_REPO/actions/workflows/kick-5h-window.yml/dispatches" \
  -d "{\"ref\":\"${GH_REF:-main}\",\"inputs\":{\"force\":true}}")
if [ "$code" = "204" ]; then
  termux-toast "Starting Claude window… (~1 min)"
  sleep 75; bash "$HOME/bin/claude5h-status.sh" --toast
else
  termux-toast "GitHub said HTTP $code — check GH_TOKEN / repo"
fi
