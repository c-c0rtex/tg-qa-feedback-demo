# tg-qa demo #2 — Feedback bot (aiogram · media / stickers / voice)

A worked example of [tg-qa](https://codeberg.org/c-c0rtex/tg-qa) testing a **bot-centric**
Telegram bot — MasterGroosha's [telegram-feedback-bot](https://github.com/MasterGroosha/telegram-feedback-bot)
(aiogram 3.21, Fluent i18n, in-RAM, long polling). Where [demo #1](https://codeberg.org/c-c0rtex/tg-qa-demo)
is a Mini App launcher, this one is all about the **bot dialog**: commands, media handling,
and deterministic replies.

It shows the parts of tg-qa a rich bot needs:

- **Sending every media kind** — the runner sends `voice` (гс), `photo`, `sticker`,
  `video_note` (кружок) and friends, and asserts the bot's reaction.
- **Positive AND negative cases** — voice/photo/video/audio/documents → «Сообщение
  отправлено!»; **stickers and video notes → «этот тип сообщения не поддерживается»**
  (the bot only relays media that can carry a caption).
- **Deterministic snapshots** of the bot's real, translated replies.

## What the run proves

`tg-qa-run --project feedbot` → **6/6 passed** (see [sample-reports/](sample-reports/)):
`/start` & `/help` return the intro/help text; a voice message and a photo are confirmed
with «Сообщение отправлено!»; a sticker and a video note are rejected as unsupported.

## Catching a regression

A QA tool should be judged by the bugs it catches, so the demo ships one. Apply the included
regression — a refactor that drops `VOICE` from the bot's supported-media filter — and watch
tg-qa isolate it:

```bash
git -C "$FEEDBACK_SRC" apply patches/regression-drop-voice.patch   # voice no longer accepted
# restart the bot, then:
tg-qa-run --project feedbot --junit          # 5/6 — only TC-F3 (voice) fails
tg-qa-maintain --project feedbot --dry-run   # verdict: PRODUCT-BUG
```

Result (committed under [sample-reports/with-regression/](sample-reports/with-regression/)):
**only the voice test case fails** — photo, sticker, video-note and the commands stay green —
with the real dialog attached (voice sent → «этот тип сообщения не поддерживается» instead of
«Сообщение отправлено!»). `tg-qa-maintain` does **not** rewrite the spec to match the broken
behaviour: it returns a **PRODUCT-BUG** verdict, naming voice as no longer accepted though
`/help` still promises it.

## What it exercised in tg-qa (and fixed)

This bot dogfooded two real gaps in tg-qa's **aiogram source miner**, both fixed upstream:

- **Command forms** — the miner matched only `Command("x")`, but real aiogram bots write
  `Command(commands=["start", "get"])` and declare the menu via `BotCommand(command="help")`.
  On this bot that was the difference between mining **0 and 8** commands deterministically.
- **i18n reply texts** — the handlers hold only message keys (`l10n.format_value("intro")`);
  the actual strings live in Fluent `.ftl` files. tg-qa now parses `.ftl`/`.po` locale files
  deterministically, recovering the **20 real reply strings** («Привет», «Сообщение
  отправлено!», the unsupported-type error) that a code-only pass can never see.

## Layout

```
setup.sh              clone feedback-bot @ pinned SHA, venv, install (no code patches)
run.sh                write .env (token + admin chat) and run on long polling
.env.example          documents the bot env run.sh writes
.tg-qa/               committed test state: config, scenarios/, 6 specs/, baseline/, bot.map.json, media/
sample-reports/       report.md, junit.xml from a real run
```

## Run it yourself

1. `./setup.sh` — fetches the bot at the pinned commit and installs it.
2. Create your own bot via [@BotFather](https://t.me/botfather); save its token to
   `~/.config/tg-qa/feedback.bot-token`.
3. Create an admin group (the bot relays into it) and save its chat id to
   `~/.config/tg-qa/feedback.admin-chat`. tg-qa's driver can create one and auto-mute it:
   `create_group("tg-qa feedback admin", ["@your_bot"])`.
4. Register the project with tg-qa and create a session; point `bot_source_dir` at the checkout.
5. `./run.sh` (in one shell) then `tg-qa-mine --project feedbot && tg-qa-run --project feedbot --junit`.

## License

MIT — see [LICENSE](LICENSE). The feedback bot is © MasterGroosha (MIT); this repo vendors no
upstream code — `setup.sh` fetches it at a pinned commit.
