# Agent orchestration

The parent plans and judges. Subagents execute tasks with explicit scope. [ALL_AGENTS.md](ALL_AGENTS.md#orchestration) defines the roles and preferred models.

Each handoff includes the objective, relevant context, owned files, constraints, and verification required. The parent reviews the result, resolves conflicts, and watches the changed path work before calling it done.

## Runtime and defaults

Use only models exposed by the current runtime. When a preferred model is absent, choose the nearest available capable model and disclose the fallback. Never invent model IDs.

Use Sol for mechanical work when Luna is unavailable. Use Sonnet when Haiku is unavailable. Work that needs judgement moves to the coding tier. Terra 6.1 can handle visual or browser tasks as a specialist; it needs no separate tier.

[Codex configuration](codex/default.nix) seeds the parent model into a writable config. [Claude configuration](claude/default.nix) sets its parent model and shares the same instructions. Delegation choices come from the role policy, subject to runtime availability.

## Sources

Reviewed 2026-11-17.

- [OpenAI model guide](https://learn.chatgpt.com/docs/models): Astra 6.2 for demanding projects, Sol 6.2 for everyday coding, Terra 6.1 for visual computer use, Luna 6 for focused repetitive tasks.
- [Claude Fable and Mythos 5.2](https://www.anthropic.com/claude-fable-and-mythos-5-2): Fable for orchestration, Opus 5.5 for daily coding. Mythos has restricted access to the same underlying model; it does not replace the default.
- [Claude Haiku 5.5](https://www.anthropic.com/claude-haiku-5-5): efficient subagents for narrow tasks.
