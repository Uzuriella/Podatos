#!/usr/bin/env bash
# Starts a 5-hour window with the smallest possible request, but only if
# no window is running (set FORCE=true to skip the check).
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)

if [ -z "${CLAUDE_CODE_OAUTH_TOKEN:-}" ]; then
  echo "::warning::CLAUDE_CODE_OAUTH_TOKEN secret not set - skipping."; exit 0
fi

if [ "${FORCE:-false}" != "true" ]; then
  status=$(bash "$here/usage.sh")
  echo "usage: $status"
  if [ "$(echo "$status" | jq -r .state)" = "active" ]; then
    echo "Window already running - nothing to do."; exit 0
  fi
fi

# Haiku, no tools, no MCP, no settings, a 5-word system prompt and a
# 1-character message: a few dozen tokens instead of the usual ~20k.
set +e
out=$(npx -y @anthropic-ai/claude-code@latest -p "." \
  --model haiku \
  --tools "" \
  --strict-mcp-config \
  --setting-sources "" \
  --system-prompt "Reply with one character." 2>&1)
rc=$?
set -e
echo "$out"
if [ $rc -ne 0 ]; then
  # Hitting your usage limit means a window is already running: not an error.
  if echo "$out" | grep -qiE 'limit|429|rate.?limit|resets'; then
    echo "::notice::Usage limit reached - a window is already running."; exit 0
  fi
  echo "::error::Ping failed (exit $rc) - check the CLAUDE_CODE_OAUTH_TOKEN secret."; exit $rc
fi
echo
echo "Window started. Now: $(bash "$here/usage.sh")"
