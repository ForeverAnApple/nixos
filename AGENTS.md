# Agents

This file is the *schema* — how the wiki and the repo are maintained — not the *content*. Read [docs/index.md](docs/index.md) for content and [PHILOSOPHY.md](PHILOSOPHY.md) for the principles that govern decisions.

## Where to look

- **What is this fleet?** → [README.md](README.md) and [docs/hosts.md](docs/hosts.md)
- **How do hosts compose?** → [docs/dendritic.md](docs/dendritic.md)
- **Why are there `workstation` and `service` tiers?** → [docs/tiers.md](docs/tiers.md)
- **Why is the repo shaped the way it is?** → [PHILOSOPHY.md](PHILOSOPHY.md)
- **What changed and when?** → `git log`

## Host cohesion (the central rule)

A host's `imports.nix` should read as a one-sentence description of what the machine is.

If it doesn't — if the import list looks like a parts catalog rather than an identity — refactor:

1. Promote repeated imports to a tier or sub-aggregate.
2. Move host-specific quirks to `modules/hosts/<host>/`.
3. If a host is genuinely two things, split it into two hosts.

The single biggest predictor of long-term repo health.

## Dendritic workflow

- Stage new flake module files with `git add` before running `nix eval` or other flake evaluations. The dendritic loader uses git-tracked status; unstaged new module files are invisible and produce misleading missing-module errors.
- New modules go under the folder whose claim matches what the module does (see [docs/dendritic.md](docs/dendritic.md) for folder claims).
- Prefer named modules (`flake.modules.nixos.<name>`) over direct injection into a parent namespace. Direct injection is reserved for tiny ambient settings (locale, common packages).

## Commit style

- Single-line subject only. No body, no `Co-Authored-By:` trailer. Match the historical pattern in `git log` (e.g. `home-assistant`, `monitors off on idle`, `samba: require SMB3 + signing + encryption`).

## Comment style

- Default to zero comments. Code + good names carry the meaning.
- Only comment a genuine non-obvious: host-specific quirk, workaround for a known upstream bug, invariant the types can't express.
- Never narrate what the next line does, restate option names in prose, or write multi-line module headers. Design rationale belongs in the commit message or in [PHILOSOPHY.md](PHILOSOPHY.md).

## Wiki maintenance

The wiki (`docs/`) is a navigation overlay on the code, not a separate knowledge base. Code is the truth; the wiki points at it and records intent.

- A page is right-sized when it answers one question. If you need a fact, find the page named for the concept.
- Add a page when a concept comes up twice. Fold a page back when it's unused for six months.
- [PHILOSOPHY.md](PHILOSOPHY.md) grows by accretion. Add principles when a decision teaches you something general. Don't perform philosophical depth — Bauhaus the doc too.

## This repo is public

- No PII or activity-revealing prose in code, comments, commit messages, or wiki pages. Don't narrate what services do, who uses them, what's stored where, or which providers are paid for.
- Functional config (mount paths, env vars, container names) stays — there's no way around it. Narrative around it does not.
- Commit messages: factual subject only.
