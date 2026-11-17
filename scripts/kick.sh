#!/usr/bin/env bash
# Starts a 5-hour window with the smallest possible request, but only if
# no window is running (set FORCE=true to skip the check).
set -euo pipefail
here=$(cd "$(dirname "$0")" && pwd)

if [ "${FORCE:-false}" != "true" ]; then
  status=$(bash "$here/usage.sh")
  echo "usage: $status"
  if [ "$(echo "$status" | jq -r .state)" = "active" ]; then
    echo "Window already running - nothing to do."; exit 0
  fi
fi

# Haiku, no tools, no MCP, no settings, a 5-word system prompt and a
# 1-character message: a few dozen tokens instead of the usual ~20k.
npx -y @anthropic-ai/claude-code@latest -p "." \
  --model haiku \
  --tools "" \
  --strict-mcp-config \
  --setting-sources "" \
  --system-prompt "Reply with one character."
echo
echo "Window started. Now: $(bash "$here/usage.sh")"
