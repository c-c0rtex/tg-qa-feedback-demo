#!/usr/bin/env bash
# tg-qa demo #2 — Feedback bot: run on long polling (no tunnel, no public host).
#
# Reads the bot token and admin-chat id from ~/.config/tg-qa/ and writes the bot's
# .env (kept out of git). The bot relays user messages to the admin chat and confirms
# receipt; stickers / video notes are answered with an "unsupported type" message —
# the deterministic positive+negative cases tg-qa asserts.
#
# Prereqs: ./setup.sh done; token + admin chat id files present.
set -euo pipefail
cd "$(dirname "$0")"

SRC="${FEEDBACK_SRC:-$HOME/feedback-bot}"
TOKEN_FILE="$HOME/.config/tg-qa/feedback.bot-token"
ADMIN_FILE="$HOME/.config/tg-qa/feedback.admin-chat"
[ -f "$TOKEN_FILE" ] || { echo "missing $TOKEN_FILE — create a bot via @BotFather first"; exit 1; }
[ -f "$ADMIN_FILE" ] || { echo "missing $ADMIN_FILE — put the admin chat id there (e.g. -5306171913)"; exit 1; }

echo "== Write bot .env (polling, keep sent-confirmation for snapshots)"
umask 077
cat > "$SRC/.env" <<EOF
BOT_TOKEN=$(cat "$TOKEN_FILE")
ADMIN_CHAT_ID=$(cat "$ADMIN_FILE")
REMOVE_SENT_CONFIRMATION=no
WEBHOOK_DOMAIN=
WEBHOOK_PATH=
CUSTOM_BOT_API=
EOF

echo "== Run bot on long polling (Ctrl-C to stop)"
( cd "$SRC" && .venv/bin/python -m bot )
