# tg-qa run report

**5/6 passed**

| spec | TC | role | status |
|---|---|---|---|
| f1-start.yaml | TC-F1 | - | ✅ pass |
| f2-help.yaml | TC-F2 | - | ✅ pass |
| f3-voice.yaml | TC-F3 | - | ❌ fail |
| f4-photo.yaml | TC-F4 | - | ✅ pass |
| f5-sticker.yaml | TC-F5 | - | ✅ pass |
| f6-videonote.yaml | TC-F6 | - | ✅ pass |

## Failures

### f3-voice.yaml — TC-F3
```
step 1: missing text: 'Сообщение отправлено!'
--- got ---
К сожалению, этот тип сообщения не поддерживается. Отправь что-нибудь другое.
```
<details><summary>dialog</summary>

- **you:** [voice] /home/mikita/tg-qa-feedback-demo/.tg-qa/media/voice.ogg
- **bot:** К сожалению, этот тип сообщения не поддерживается. Отправь что-нибудь другое.

</details>

