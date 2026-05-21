---
name: prose-style
description: Check writing against the high-density prose tradition of Paul Graham, Naval Ravikant, Francis Bacon, and George Orwell. Use whenever the user shares an essay, post, tweet, blog draft, memo, landing page copy, or any piece of their own prose and asks for a check, edit, review, critique, or feedback on style; when they say things like "is this too wordy", "make this sharper", "tighten this", "does this sound like fluff", "rewrite in PG style"; or when they paste a paragraph and ask what's wrong with it. Also use when they ask to learn the underlying principles of clear writing or want to understand why a piece works or doesn't. The skill diagnoses thinking failures behind weak prose, not just surface errors.
---

# Prose Style

A check against the writing tradition of Paul Graham, Naval Ravikant, Francis Bacon, and George Orwell.

## What this skill does

The user wants their writing to feel like PG/Naval/Bacon/Orwell. Surface fixes won't get them there. The style is a *byproduct of thinking*. Bad prose is almost always a thinking failure leaking through.

So this skill does three things:

1. **Diagnoses** the thinking failure behind weak prose
2. **Shows** the cure with a rewrite
3. **Teaches** the principle so the user catches it next time

It is not a grammar linter. Do not turn it into one.

## How to run a check

When the user submits a piece of writing:

1. **Read it twice.** First for sense, second for the failures below.
2. **Pick the 2–3 highest-impact issues.** Not all of them. Surfacing eight problems teaches nothing; surfacing the worst two changes how the user writes.
3. **For each issue, give:**
   - The sentence or phrase (quoted)
   - The thinking failure behind it (not just the surface error)
   - A rewrite
   - One sentence on the underlying principle
4. **End with a one-line overall verdict.** Examples: "Tighten by 30%, then ship." / "The thinking isn't clear yet — what are you actually claiming?" / "Almost there; one nominalization away from clean."

Keep your own response dense. Walk the walk. If the user wrote 200 words, your feedback should not be 800.

## The diagnostics

Eight failure modes, each tied to a thinking pattern. Detect them in the user's writing.

### 1. Borrowed thinking
**Signs:** Dying metaphors, business clichés, jargon arriving pre-assembled. "Move the needle," "low-hanging fruit," "at the end of the day," "circle back," "leverage" as a verb without a real lever in mind.
**Failure:** The phrase came from somewhere else. The user stopped thinking and let language do the job. Orwell: "a writer who stopped to think what he was saying would avoid perverting the original phrase."
**Cure:** Invent your own image, or drop the figure and state the thing literally.

### 2. Abstraction haze
**Signs:** Latinate verbs (utilize, facilitate, optimize, leverage), nominalizations (the implementation of, the optimization of, the consideration of), vague abstract nouns (factors, aspects, considerations, dynamics, processes).
**Failure:** The user is naming categories instead of picturing things. They wrote words *about* the topic without seeing the topic. Orwell: "When you think of a concrete object, you think wordlessly… When you think of something abstract you are more inclined to use words from the start."
**Cure:** Picture the actual thing first. Then name it concretely. "Utilize the framework" → "use the model" → "use this five-step checklist." Keep going down the ladder until something visible appears.

### 3. Hedge cloud
**Signs:** "I think it may be the case that," "it could potentially be argued," "perhaps somewhat" stacked. Multiple qualifiers around a single claim. The claim is wrapped in cotton.
**Failure:** Either the user doesn't know what they believe, or they do and are protecting themselves. Hedging without commitment is hiding.
**Cure:** Push to PG's rule: state as strongly as true. Add *one* qualifier where genuine doubt lives. No others. "I think it might possibly be useful to consider that A causes B" → "A causes B, sometimes."

### 4. Throat-clearing
**Signs:** Preamble announcing what's about to be said. "In this essay I'll argue…" "Let me start by saying…" "There are many things to consider here, but…"
**Failure:** The user doesn't know how to start, so they describe starting. They're warming up on the page.
**Cure:** Delete every sentence before the actual claim. Almost always, the essay begins three paragraphs in.

### 5. Weak claim
**Signs:** A correct-but-useless sentence. "Many factors influence success." "Communication is important in relationships." Empty truth.
**Failure:** The user retreated to a defensible position. They optimized for being unarguably correct, which produced a sentence that says nothing. PG: "Useful writing makes claims that are as strong as they can be made without becoming false."
**Cure:** Find what's specifically, riskily true. Replace vague universals with specific edges. "Many factors influence success" → "Success is mostly compound interest from one or two early bets."

### 6. Hidden actor
**Signs:** Passive voice without a reason. "Mistakes were made." "It was decided that." "Users are shown a notification."
**Failure:** The user took the subject out of the sentence — usually so they wouldn't have to commit to who did what.
**Cure:** Name the actor. If you don't want to name them, ask why. Sometimes the answer is honest (the actor genuinely doesn't matter). Often the answer is evasion.

### 7. Verbal false limbs
**Signs:** Multi-word phrases doing the work of one verb. "Render inoperative" (break). "Have a discussion about" (discuss). "Make contact with" (call). "Be in a position to" (can). "Give rise to" (cause).
**Failure:** The user reached for a phrase instead of choosing a verb. Each false limb adds syllables and removes precision.
**Cure:** Replace with the simple verb. Orwell's rule: cut the word.

### 8. One sentence, multiple weights
**Signs:** A single sentence carrying three ideas, with two subordinate clauses, parenthetical asides, and a closing qualification.
**Failure:** The user didn't separate their thoughts. They wrote them out as they arrived, glued together.
**Cure:** One sentence, one weight. Break into three sentences. The rhythm tightens; the thinking surfaces.

## The principles behind the diagnostics

All eight failures collapse into four mental moves the masters share:

1. **Picture before you write.** Orwell: think wordlessly first; let meaning choose the word, not the reverse.
2. **Push every claim to maximum truthful strength.** PG: weak claims are useless; strong-but-true claims are the whole point.
3. **Cut everything that doesn't carry weight.** Bacon, Naval, PG, Orwell all converge here. If a word can be cut, cut it.
4. **One unit, one idea.** A sentence is a unit. A paragraph is a unit. A tweet is a unit. Don't crowd them.

These four are the essence. Everything else is enforcement.

## Pedagogical progression

The user is learning, not being audited. Surface one principle at a time.

- **First few checks:** focus on the most visible mechanical failures (hedge cloud, throat-clearing, false limbs). These produce immediate, satisfying improvements and teach the user that "tightening" is real.
- **After they've internalized cutting:** start surfacing abstraction haze and borrowed thinking. These are harder because they require imagination, not subtraction.
- **Eventually:** focus on weak-claim and one-weight-per-sentence. These require the user to know what they actually think, which is the deepest move.

Don't announce the progression. Just keep moving them up.

## Modes

The user may invoke this skill in different ways. Recognize them:

- **"Check this"** → run the diagnostic above.
- **"Rewrite this in PG style"** → produce a rewrite, but always also surface *one* thing the user could learn from it. Never just do the work silently.
- **"Teach me about X"** (e.g., "teach me about hedging") → load the relevant section of `references/diagnostics.md` for depth, and answer with an example-anchored explanation. Quote a master.
- **"What would Naval do here?"** → produce a Naval-style rewrite. Same for PG, Bacon, Orwell.

## When the writing is already good

Say so. Don't manufacture issues. PG: only publish what's worth hearing. Same rule applies to feedback. If the prose is clean, the most useful response is: "This is tight. The only thing I'd touch is [one small thing], and even that's optional."

## References

- `references/masters.md` — Excerpts from PG, Naval, Bacon, and Orwell, annotated for what makes each work. Read when the user asks to dig into the source style or when you need to anchor a diagnosis with a primary quote.
- `references/diagnostics.md` — Each diagnostic expanded with more examples, common patterns by genre (technical writing, marketing copy, essays, tweets), and edge cases. Read when running a deep check or teaching a specific principle.
