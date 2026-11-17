#!/data/data/com.termux/files/usr/bin/bash
# One-time setup in Termux:  bash setup.sh
set -e
cd "$(dirname "$0")"
pkg install -y curl jq termux-api coreutils
mkdir -p ~/bin ~/.shortcuts ~/.config/claude5h
cp ../scripts/usage.sh ~/bin/claude5h-usage.sh
cp claude5h-status.sh claude5h-start.sh ~/bin/
cp shortcuts/*.sh ~/.shortcuts/
chmod 700 ~/bin/claude5h-* ~/.shortcuts/*.sh

if [ ! -f ~/.config/claude5h/env ]; then
  read -rsp "Claude token (from 'claude setup-token', sk-ant-oat01-…): " CT; echo
  read -rsp "GitHub fine-grained token (Actions: read & write on this repo): " GT; echo
  read -rp  "GitHub repo [uzuriella/podatos]: " GR
  umask 077
  cat > ~/.config/claude5h/env <<E
CLAUDE_CODE_OAUTH_TOKEN=$CT
GH_TOKEN=$GT
GH_REPO=${GR:-uzuriella/podatos}
GH_REF=main
E
fi

# Refresh the notification every 15 min (Android's minimum), survives reboot.
termux-job-scheduler --job-id 5 --period-ms 900000 --persisted true \
  --script ~/bin/claude5h-status.sh
bash ~/bin/claude5h-status.sh --toast
echo "Done. Add the Termux:Widget widget to your home screen."
