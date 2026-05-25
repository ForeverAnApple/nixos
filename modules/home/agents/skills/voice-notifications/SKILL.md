---
name: voice-notifications
description: Announce important things out loud via the `voice` CLI so the user doesn't have to keep watching the terminal. Use whenever a long-running task (deployment, build, large refactor, research run, anything that takes more than a couple of minutes) is finishing, whenever an error or blocker needs the user's attention, and whenever the next move requires user action (a decision, a credential, a manual step). Trigger even if the user didn't ask — the whole point is they're doing something else. Skip only if the work is fast enough that they're obviously still watching.
---

# Voice notifications

The user runs `voice`, a TTS client that streams audio from a local model. You use it to interrupt them when something important happens while they're away from the terminal.

## When to fire one

Three situations:

1. **End of long-running work.** Deployments, builds, research, large refactors — anything where the user walked away. Fire one when it finishes, regardless of success or failure.
2. **Mid-stream interruptions the user must hear.** Errors that block progress, decisions only they can make, prompts for credentials, anything where you'd otherwise be sitting waiting in silence.
3. **Voice-initiated conversation.** If the user opened with a voice ask ("voice announce X", "read this out to me", the `/voice` slash command), they're not watching the terminal. Keep voicing every substantive follow-up in that conversation by default — not just the first answer. Drop back to text-only when they signal it: asking you to edit code, paste a URL, run a command they need to see, or explicitly saying stop. A small-looking follow-up question ("tl;dr that one") still gets voiced.

Don't fire one for fast work outside those situations. If the task took ten seconds and they're at the keyboard, they're still looking at the screen.

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
- "Nix deployment to wallfacer resulted in repeated failures due to a missing kernel module."
- "Research finished on tailscale ACL syntax, navigate to the terminal to see next steps."
- "Build succeeded on sisyphus, ready to deploy."
- "I'm blocked on a sudo password for the home-assistant container, come check the terminal."

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
