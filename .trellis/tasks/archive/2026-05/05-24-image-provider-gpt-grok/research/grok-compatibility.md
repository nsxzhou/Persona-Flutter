# Grok Image API Compatibility Notes

- Preferred Grok compatibility endpoint after user revision: `POST /v1/chat/completions`.
- Tested model: `grok-imagine-image-lite`.
- `response_format: b64_json` works and returns `data[0].b64_json`.
- URL response may return `assets.grok.com` links that respond 403 to direct HEAD/GET in the current environment.
- `/v1/chat/completions` returns Markdown image links in `choices[0].message.content`; this task now uses that path for Grok providers.
- `/v1/images/edits` with current multipart shape returned 400; Grok edits are out of scope.
- `quality` is not needed for Grok and previously showed instability, so omit it for Grok requests.
