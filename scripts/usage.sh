#!/usr/bin/env bash
# Prints the state of your Claude 5-hour window as one line of JSON:
#   {"state":"active","used":23,"resets_at":"2026-11-17T14:32:00Z"}
#   {"state":"idle"}            no window running -> safe to start one
#   {"state":"unknown","why":"..."}
# Needs CLAUDE_CODE_OAUTH_TOKEN (from `claude setup-token`), curl and jq.
# Uses the same (undocumented) endpoint Claude Code's /usage screen reads,
# so it may change without notice; callers treat "unknown" as "go ahead".
set -u
tok="${CLAUDE_CODE_OAUTH_TOKEN:-}"
[ -z "$tok" ] && { echo '{"state":"unknown","why":"no token"}'; exit 0; }

body=$(curl -fsS --max-time 15 https://api.anthropic.com/api/oauth/usage \
  -H "Authorization: Bearer $tok" \
  -H "anthropic-beta: oauth-2025-04-20" \
  -H "Content-Type: application/json" 2>&1) \
  || { jq -cn --arg w "$body" '{state:"unknown",why:$w}'; exit 0; }

echo "$body" | jq -c '
  (.five_hour // {}) as $f
  | if ($f.resets_at // null) != null
       and ($f.resets_at | sub("\\.[0-9]+";"") | sub("\\+00:00$";"Z") | fromdateiso8601) > now
    then {state:"active", used:(($f.utilization // 0)|floor), resets_at:$f.resets_at}
    else {state:"idle"} end
' 2>/dev/null || echo '{"state":"unknown","why":"unexpected response"}'
