#!/usr/bin/env bash
# tg-qa demo #2 — Feedback bot (aiogram, media/stickers/voice) stand setup.
#
# Clones MasterGroosha's telegram-feedback-bot at a pinned commit and installs it in
# a venv. No code patches: the bot runs on long polling natively (empty WEBHOOK_DOMAIN)
# and keeps state in RAM. Bring your OWN bot: create one via @BotFather and save its
# token (see README).
#
# Requirements: git, python >= 3.11.
set -euo pipefail
cd "$(dirname "$0")"

FB_SHA="6506fcc6166c584519688131c4b9e7ccf71a74c5"
SRC="${FEEDBACK_SRC:-$HOME/feedback-bot}"

echo "== 1/2  Fetch telegram-feedback-bot @ ${FB_SHA:0:12}"
if [ ! -d "$SRC/.git" ]; then
  git clone https://github.com/MasterGroosha/telegram-feedback-bot "$SRC"
fi
git -C "$SRC" fetch --depth 1 origin "$FB_SHA" 2>/dev/null || git -C "$SRC" fetch origin
git -C "$SRC" checkout -q "$FB_SHA"

echo "== 2/2  Create venv + install"
python3 -m venv "$SRC/.venv"
"$SRC/.venv/bin/pip" install -q -r "$SRC/requirements.txt"
"$SRC/.venv/bin/python" -c "import aiogram; print('   aiogram', aiogram.__version__)"

echo
echo "OK. Next:"
echo "  1. Create a bot via @BotFather, save its token to ~/.config/tg-qa/feedback.bot-token"
echo "  2. Create an admin group and save its chat id to ~/.config/tg-qa/feedback.admin-chat"
echo "     (tg-qa's driver can create + auto-mute one — see README), then: ./run.sh"
