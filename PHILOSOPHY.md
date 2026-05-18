# Philosophy

This repo applies *form follows function* to NixOS configuration. The file you're reading codifies the principle and the tradeoffs we accept. It grows by accretion: when a decision teaches us something, we add it. Old entries are not edited — they're left as evidence of how the thinking changed.

## Form follows function

The shape of a thing should derive from its purpose. In this repo:

- A module's namespace name (`flake.modules.nixos.tailscale`) declares what it does. The file path is a hint; the name is the contract.
- Tier modules (`workstation`, `service`) are named for the function they serve — *creating* vs *serving* — not for the role of the operator, the form factor of the hardware, or the network topology.
- When a name lies about its function, rename. `worker` was the deploy account, not the function; `service` is the function. `users` was generic; `human-user` and `deploy-user` are honest pairs.
- A host's `imports.nix` should read as a one-sentence description of what the machine is. If it reads like a parts catalog, the host has lost cohesion — refactor: into a tier, into a sub-aggregate, or by reducing scope.

Form drift is cheap to fix early and expensive to fix late. Rename when the name drifts.

## Tradeoffs we accept

Dendritic optimizes for *composition*: every file is a module, the namespace is flat, paths are arbitrary. The cost is *opacity* — the dendritic Discourse critique is correct: you can't always tell what contract a module satisfies just from reading it. We accept this cost because the alternative (typed module contracts, explicit `provides`/`wants` declarations everywhere) is more ceremony than a five-host fleet earns.

Where opacity bites, we compensate with:
- Function-named tiers (`workstation`, `service`) so hosts compose at a coarser grain.
- This file, articulating intent that the code can't express.
- The `docs/` wiki, recording decisions and shape.

## Prior art

We didn't invent these ideas. The synthesis is ours; the components are borrowed.

- **[Dendritic pattern](https://github.com/mightyiam/dendritic)** — the composition substrate. We adopt its flat-namespace claim but reject the literal reading of "paths don't matter" — our folder structure is semantic and we treat it as such.
- **[Dendritic critique (Discourse)](https://discourse.nixos.org/t/the-dendritic-pattern/61271)** — names the opacity cost honestly; we cite this as the reason tiers exist.
- **[Asaduzzaman Pavel — 100+ NixOS modules without going crazy](https://iampavel.dev/blog/nixos-module-organization)** — the *provides / wants* frame. A tier *provides* a function bundle; a host *wants* a tier. Our tiers are the bundle; the host's `imports.nix` is the want list.
- **[Tweag — Taming Unix with Nix](https://www.tweag.io/blog/2022-07-14-taming-unix-with-nix/)** — Unix philosophy applied to whole-system declarative config: small composable pieces over monoliths.

## How to grow this file

When a decision *teaches you something general*, add it. Specifically:

- A new principle (only if it isn't a special case of one we already have): name it, claim it, give an example.
- A new tradeoff: state what we optimize for, what we give up, why.
- A new prior-art reference: link it, one-line takeaway.
- Don't rewrite old entries. Add a dated correction below if the thinking changed.

Aim for blunt, short, no padding. Bauhaus the doc too — if you find yourself performing depth, cut.

## Changelog

- **2026-05-18** — Trimmed. First draft of this file listed three principles: *form follows function*, *one purpose per object*, *honest substrate*. The second and third were derivative — special cases of the first, dressed as parallel rules. Stripped back to one. The examples that lived under those two principles still appear in the body of the surviving one, where they belong.
- **2026-05-18** — Initial draft. Recorded the tier introduction (workstation/service) and the rename chain (worker → service, users → human-user) as the first applications.
