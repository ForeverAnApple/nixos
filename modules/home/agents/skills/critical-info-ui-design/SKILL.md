---
name: critical-info-ui-design
description: >-
  Design a page or view around only the information that earns its place — the
  most decision-relevant data front and center, everything else cut or hidden
  behind interaction, and each surviving item encoded in the visual channel that
  conveys it with the least effort. Use this whenever the work is deciding WHAT
  goes on a screen and HOW MUCH weight it gets, not just how it looks: building
  or redesigning a dashboard, control panel, status view, analytics screen, or
  landing page; ranking information by importance; cutting a cluttered UI to
  essentials; choosing how to encode a metric (number vs badge vs bar vs
  sparkline vs avatar); designing information hierarchy or a summary/detail
  split. Trigger it when the user says a view is "too busy", "cluttered",
  "overwhelming", asks "what matters most here", "what should be front and
  center", "what earns its place", "show only the important stuff", or wants a
  screen to lead with the one thing that drives action. Complements
  impeccable / frontend-design (visual craft) and design-guide (component
  system) — this skill is specifically about triaging and encoding information
  by decision-relevance.
---

# Critical-info UI design

A method for building a view whose information content is deliberate — every item present because it changes what the viewer does, encoded in the cheapest channel that carries it. The enemy is the dashboard that shows everything and therefore says nothing.

The governing measure is **useful bits: information that changes the viewer's behavior.** A number the viewer looks at and does nothing differently about carries zero useful bits, however precise or important-sounding. Rank, cut, and encode by useful bits — not by how weighty the topic feels.

Work moves 1–4 to decide and shape the content, then moves 5–6 to audit what you built. Don't jump to layout or color before the ranking is done; the ranking is the design.

## 1. Name the screen's one job

Before listing data, answer: what is the single question this view exists to answer, or the single decision it exists to drive? Write it in one sentence. "Does any pipeline need my attention or money?" "Is the deploy healthy?" "Which lead do I call next?"

Everything downstream serves that sentence. If you can't write it, you're decorating, not designing.

## 2. Rank every candidate by decision-relevance

List every piece of data that *could* appear. For each, ask three questions in order:

1. **What decision does this drive?** If the honest answer is "none, but it's nice to know" — cut it. Nice-to-know is the enemy; it's the noise that buries the signal.
2. **How often does knowing it change what the viewer does?** Often → high rank. Rarely → low rank or move it behind interaction.
3. **Does it stand alone?** A number the viewer can't *judge* carries no useful bits. "$273 spent" means nothing without a cap, a target, or a prior. If it needs a companion to be judgeable, either pair them or drop both.

Rank the survivors. Beware the two seductions:
- **Topic-importance masquerading as decision-relevance.** "Revenue is important" — sure, but if the revenue figure on *this* screen never changes a decision made *from* this screen, it's noise here. Importance is contextual.
- **Precision masquerading as value.** An exact figure where the viewer only needs a direction is expensive noise.

## 3. Set a hard budget, then split visible vs. revealed

Pick a cap *before* you design — e.g. 6 items always visible, 3 revealed on interaction. A cap forces the ranking to mean something; without it, everything creeps back in.

- **Always visible:** the top of the ranking — what the viewer must see to answer the screen's one job at a glance.
- **Revealed (click / hover / select):** two kinds earn a reveal — (a) the *evidence* that backs a headline number (the per-step breakdown behind a total), and (b) detail that only matters *after* the viewer has decided to act on something. Progressive disclosure isn't hiding; it's refusing to spend glance-attention on second-look data.

If an item is neither top-of-rank nor backing-a-headline nor act-time detail, it doesn't make the screen at all.

**When a reveal exists to drive one action, the action leads.** The button the surface exists for is visible the instant it opens — pinned, never below the fold. Size the surface to its job: a cramped drawer the viewer must scroll to find its own point has hidden the only thing it had to say. And fill it with the evidence someone would check before acting — the step costs, the recent runs, the queue. An act-time surface with placeholder-thin content makes the act feel unsafe.

## 4. Encode each survivor in the cheapest sufficient channel

This is where information theory earns its keep. The eye has two channels. **Pre-attentive** features — position, length, slope, hue, size, motion — are read across the whole screen in parallel, in ~200ms, without fixation. **Serial** features — text, numbers — are read one at a time, expensively. And encodings differ in decoding accuracy (Cleveland–McGill): **position > length > slope/angle > area > color**.

So the rule is: **match the channel to the precision the decision needs, and put the parallel-readable channels to work on the questions that matter most.**

| The data is… | Precision needed | Encode as | Why |
|---|---|---|---|
| A category, few states, one of which triggers action | which state | badge: hue + shape + word | pre-attentive; the eye sorts the whole grid at once |
| A ratio to a bound, or a value compared across rows | relative, not exact | bar / meter (length on a common scale) | length is the highest-accuracy pre-attentive channel |
| The direction or shape of a series over time | slope, not points | sparkline | a whole series in the width of a word; slope reads pre-attentively |
| A value the viewer must act on exactly | exact | number (text), tabular-aligned | text is precise; alignment lets a column be compared by length |
| "Is this good?" | a judgment | number **+ its benchmark** (delta, target, prior) | the benchmark is what turns the digits into a useful bit |
| An identity from a small recurring set | recognition | icon / avatar / logo | recognizing an image beats reading a name |
| An arbitrary name | the string | text | high-entropy symbol; nothing beats text |

### The one-signal rule

Choose **one loud channel — usually a single saturated color — and spend it only on the single state that changes behavior** (needs-attention, over-budget, failing). Everything else stays muted. The payoff is enormous: the screen's most important answer becomes readable *without reading*, because the eye finds the one loud thing in parallel across the whole layout. A loud color spent on decoration is worse than wasted — it drowns the signal it should have been reserved for.

### Attach the noun

The unit is part of the datum. "95 / 120 · investors responded" carries a bit; "89 · 59%" over an unlabeled bar carries almost none, because the reader doesn't know 89 *what*. Normalizing heterogeneous metrics into one uniform encoding — value/goal and a bar for every row — optimizes the decoding of numbers whose meaning the normalization just deleted. Fit the encoding to each metric's native shape instead: a fraction takes value/goal and a bar; a volume reads as "3k / 5k impressions"; an uptime percent wants the number, its target, and a 30-day tick strip — a progress bar is useless at 99%. Consistency across rows is worth less than meaning within one. Uniformity is a default, not a virtue.

### One meter, one relationship

Every quantity a meter encodes is another thing the viewer must worry about. Spent/committed/cap layered on one bar reads as three problems; spent-vs-cap reads as one. An intermediate state (committed, reserved, pending) earns a layer only if the intermediate itself drives a decision made from this screen — otherwise collapse to the two ends the viewer acts on. And length is read literally: if a fill doesn't visually match the printed numbers beside it, the viewer stops trusting the whole screen.

### One datum, one format

Encode each piece of data one way, in one place. The same datum shown again in the same format carries zero new bits — the copy is fully predictable from the original — so it buys nothing while spending space and making the viewer stop to check whether the two are really the same thing. If a datum matters enough to recur, **change the format to fit each place's job**: a color badge where the eye sorts a list, a number where it must be exact, an icon or a flash of motion where it must be noticed, an avatar where it must be recognized. Image, text, icon, animation — each instance earns its place only by serving a different reading task through a different channel.

The one exception lives *inside a single component*: layering channels on the single must-not-miss signal (hue + shape + word at once) buys error-proof, colorblind-safe reading. That's reliability, not new information — reserve it for that one signal; everywhere else, one channel per variable. Audit the finished surface for violations in move 6.

## 5. Verify with the glance test

Build it, then cover every number with your hand. Can someone answer the screen's one job — "does anything need me? is anything wrong?" — in one second, from the pre-attentive channels alone? 

- **Yes** → the right things are encoded loudly. Numbers are there for the deliberate second look, as they should be.
- **No** → you've spent your loud channels on the wrong variables. The most decision-relevant answer should never require reading.

## 6. Second pass: audit for duplicate encoding

Do this once the screen exists — it catches what the design moves miss, because redundancy only becomes visible when the whole surface is in front of you. Walk it and write down every place information appears, one row per (datum, location, format). **The list is the deliverable — you can't judge redundancy you haven't enumerated.**

| Datum | Where | Format | Reading task it serves |
|---|---|---|---|
| Attention state | table row | color badge | scan/sort across rows |
| Attention state | summary card | icon + word + color | commit to "act now" |
| Attention state | distribution strip | count + dot | read the mix at a glance |
| Spend vs cap | row | mini meter | compare across rows |
| Spend vs cap | detail panel | number | the exact, act-time value |

Then apply one law:

**A datum appears at most once in a given format.** Where the same datum shows up twice in the same format, the second instance is noise — keep the one whose location best serves its reading task and cut the rest. Where a datum is important enough to belong in several places, a different format per instance is *necessary but not sufficient* — each instance must still pass the decision test on its own. The attention-state rows above show three formats, and in a four-row table two of them still die: a count strip and a commitment card merely re-count what the eye already counts from the badges in one fixation. Format variety is permission to recur, not a reason to. If two instances share a format and both must stay, re-encode one.

Watch the subtle case: the same number as a big hero figure *and* as a row in the table beneath it. **Different size is not a different format — both are text.** Either the hero must summarize something the table doesn't (a portfolio figure vs. a single row), or one of the two must change channel.

## Failure modes to name out loud

When reviewing or being pushed toward a busier design, call these by name:

- **Nice-to-know creep.** Every stakeholder wants their number on the screen. Each one dims all the others. Push back with the screen's one job.
- **Naked numbers.** A figure with no benchmark — or no noun. "89 · 59%" is unjudgeable twice over: nothing says whether 59% is good, and nothing says 89 *what*. Pair it or cut it.
- **Manufactured prescription.** A summary card issuing commands — "X needs your approval to start pacing." Aggregates state facts; imperatives live on the thing being acted on, where the action is. Narrative urgency written into chrome reads as the interface selling something.
- **Self-narrating chrome.** A subtitle restating the column headers ("Monitor outcomes, spend, owners, and next runs"), a help button that goes nowhere. Structure already says what structure is; prose about it is echo, and a dead affordance is a broken promise. Cut both.
- **The buried act.** A reveal surface whose one button sits below the fold. The viewer opened it to act; make them hunt and the surface has failed at the only thing it was for.
- **Vanity precision.** Four significant figures where an arrow would do.
- **Rainbow decoration.** Color used to make it "pop" instead of to carry the one signal. Now nothing pops.
- **Echo encoding.** The same datum, same format, in two places. The echo is fully predictable, so it carries nothing — it just makes the viewer double-check the two numbers agree. Vary the format or cut one.
- **Elegance as avoidance.** A gorgeous gauge for a metric nobody acts on is procrastination with a design tool.

## Worked example

A "workflows" dashboard for autonomous, money-governed agent pipelines. **One job:** *does any pipeline need me, and is any wasting money?*

Ranked and encoded:

- **Portfolio pacing** — one summary card: "3 of 4 on track" with a per-workflow segmented meter. A portfolio figure no single row carries — never an echo of the focal row's own numbers. No call-to-action copy; the rows carry their own status.
- **Spending** — one number (spent) over one meter to the cap. Committed existed in the data and didn't survive: no decision on this screen turned on it.
- **Outcome, per row in its own terms** — "95 / 120 · investors responded" with a bar; "3k / 5k · impressions"; "15 / 30 · days in top 10"; "99.98% · uptime" with a 30-day tick strip. One column, four encodings — the noun travels with the number.
- **Attention state** — badge, loud color *only* for "needs you". (Few states, action-triggering → pre-attentive hue.)
- **Title** — text. **Owner** — avatar (small recurring set → recognition). **Next run** — relative-time text ("in 2h" > "Mon 9:00": relative is the decision-relevant form).
- *Revealed on select:* a full-height drawer whose primary action ("Review & approve") is pinned visible on open; inside, the evidence for the act — per-step costs with real vendors, recent runs, and for a never-run draft a projected run cost against its envelope. A projection, never a fabricated trend: history charts only for things with history.

Glance test passes: with every number covered, the loud color still tells you which pipeline needs you and whether any is over budget — the screen's whole job, read in parallel.

Redundancy audit: attention-state first appeared three ways — row badge, an "Attention" card, a distribution-strip count. Three different formats, so the one-datum-one-format law was satisfied; the decision test still killed two. With four rows, the badges answer "how many need me?" in one fixation — the card and the strip re-counted the visible. What survived recurrence was cap: once per row meter, once as the portfolio meter's axis — different scope, different format, each with its own decision behind it.

## The feedback loop: this skill updates itself

User feedback during a design review is the highest-grade data this skill will ever get — a real owner saying where the method produced the wrong screen. Don't just apply the fix. Every round of feedback ends with this file updated, or with a stated reason it shouldn't be.

For each piece of feedback:

1. **Recover the principle, not the patch.** "Remove this subtitle" is a patch; "structure narrating itself is echo" is a principle. State the why in one sentence that would generalize to a *different* screen. If you can't, you haven't understood the feedback yet.
2. **If the why is ambiguous, ask.** When feedback names the offender but not the reason ("this doesn't make sense here") and more than one principle could explain it, ask the user which it is before encoding — one clarifying question beats generalizing the wrong rule. Only if asking isn't possible, encode your best reading and mark it as inferred.
3. **Write a spotting rule.** The test: could this have been caught before the user saw it, and in which move (1–6) would the catch live? Encode it there — a named rule in move 4, a reveal/budget constraint in move 3, a failure mode with its smell named out loud.
4. **Edit this file, in this voice, immediately.** If the new rule mostly duplicates an existing one, sharpen the existing one's wording instead of adding a sibling — the file stays tight or it stops being read. The copy you're reading is a read-only nix-store symlink; the editable source is `~/nixos/modules/home/agents/skills/critical-info-ui-design/SKILL.md`. Edit there, `git add`, and rebuild (`nh darwin switch` / `nh os switch`) — an edit that skips the rebuild reaches no one.
5. **Keep the worked example honest.** If the feedback invalidated something the example endorses, rewrite the example. A skill whose example demonstrates its own failure modes teaches them.

Precedents, so the loop's output is visible: "needs your approval to start pacing" → *Manufactured prescription*; "89 · 59%" meaning nothing → *Attach the noun*; the spent/committed/cap meter → *One meter, one relationship*; the CTA below the fold → *The buried act*; this skill's own example once blessing a 3× recurrence the owner then cut → *necessary but not sufficient* in move 6. Each was one round of real feedback, distilled and folded back.

## Relationship to other skills

- **This skill** decides *what information appears and how heavily it's weighted.* Do it first.
- **impeccable / frontend-design** — visual craft, typography, motion, polish on the surviving elements.
- **design-guide** — the component system and tokens you build with.
- **dataviz** — deeper method for the chart-shaped survivors (color scales, chart-type choice, accessibility).

Run this one before the others: no amount of polish rescues a screen that shows the wrong things.
