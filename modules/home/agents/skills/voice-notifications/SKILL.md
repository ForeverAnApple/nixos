---
name: voice-notifications
description: Announce catastrophic failures out loud via the `voice` CLI. Use only when something is down, broken, or at risk, the user must act, and no agent can fix it; or when the user explicitly asks for voice. Do NOT use it for finished tasks, routine blockers, questions, or successful deploys; those go in the terminal.
---

# Voice notifications

The user runs `voice`, a TTS client that streams audio from a local model. A voice line interrupts whatever they're doing, so it is reserved for emergencies.

## When to fire one

Two situations only:

1. **Catastrophe that needs the user.** A service, host, or the user's data is down, broken, or at risk; it won't recover on its own; and no agent can fix it. Examples: a server unreachable after a deploy, a backup chain broken, the machine's audio or network stack dead and not restarting. This rule covers monitoring of this machine and of the servers alike.
2. **Voice-initiated conversation.** If the user opened with a voice ask ("voice announce X", "read this out to me", the `/voice` slash command), they're not watching the terminal. Keep voicing every substantive follow-up in that conversation by default — not just the first answer. Drop back to text-only when they signal it: asking you to edit code, paste a URL, run a command they need to see, or explicitly saying stop. A small-looking follow-up question ("tl;dr that one") still gets voiced.

Never fire one for finished tasks (even long ones), successful deploys, routine blockers like a sudo prompt or a pending decision, or questions. Those go in the terminal; the user will read them when they come back.

## How to fire one

Run in the background so it doesn't block. Two forms, pick whichever fits:

```
voice "nix deployment to wallfacer failed, missing kernel module zfs"
echo "research finished, check the terminal for next steps" | voice
```

`voice --help` shows the rest (env vars, REPL mode, log path) if you need it. You almost never do.

## What to say

The readout is the whole message. The user is in another room, hands full, not looking. So:

- **Lead with the subject.** "Nix deployment to wallfacer" — not "the task is done".
- **Say what happened.** Success, failure, blocker, decision needed.
- **Give the cause or next step in one clause.** Not a stack trace. The reason in plain words.
- **Stop.** One sentence. Maybe two.

Good:
- "Swordholder is unreachable after the deploy and didn't roll back. It needs a console."
- "Audio is down on catjailer and keeps getting killed on restart. Check the terminal."
- "Tonight's backup to THICC failed twice. The chain is broken until you look."

Not worth a voice line (terminal only): "Build succeeded, ready to deploy." "Research finished." "Blocked on a sudo password."

Bad (no context):
- "Task complete."
- "Error."
- "Done."

## What to never say out loud

Some things are read with the eyes, not the ears. Speaking them is noise — the user can't act on what they hear and they have to come back to the screen anyway.

Never TTS:
- URLs, especially long ones
- Passwords, tokens, API keys, hashes, UUIDs
- Long numeric strings (commit SHAs, port lists, IPs in bulk)
- File paths with many slashes
- Raw stack traces, raw JSON, raw logs
- Error messages copy-pasted verbatim — paraphrase them

If the content is visual, summarize it and point at the terminal: "check the terminal for the link", "the password is in the output", "see the failing test on screen". Speak like a human telling another human what happened, not a screen reader.
