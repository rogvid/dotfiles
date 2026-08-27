# Orchestrator design notes

Why the agents in `~/.claude/agents/` are shaped the way they are.
Written 2026-08-01.

## The premise, verified

Subagents cannot reach the user.
An agent defined with `tools: [AskUserQuestion, Read, Bash]` comes back holding only `Read` and `Bash` - the harness strips `AskUserQuestion` while honoring the rest of the same list.
`SendMessage` is agent-to-agent.
`SendUserMessage` (behind `--brief`) is a one-way push and is main-thread gated.

So the split falls out of the harness rather than taste:

> The orchestrator owns all human interaction.
> Subagents own all work.

## What is *not* true

Removing `Edit`/`Write` does not stop an agent writing files.
`Bash` is a complete write vector - `printf >`, `tee`, `sed -i`, heredocs, `git apply`.
Tool restriction at the top level works (Edit/Write really are gone), it just doesn't accomplish that.

So the orchestrator's "never writes code" is a **norm enforced by prompt**, not a wall.
Chosen deliberately: the alternative is removing `Bash` too, which costs a hop for every commit and blinds it to diffstats.

The one place the restriction genuinely earns its keep is the **verifier** - there, no-write means it cannot repair what it is grading.

## Why the orchestrator holds no state

Frontier models degrade around 125-150k tokens regardless of remaining window.
An orchestrator is a single long-lived session, which is exactly the shape that fills that budget with routing history.

Mitigation: durable state goes to disk or the tracker, subagents return pointers rather than reports, and the orchestrator re-assesses each turn instead of anchoring on earlier routing.
It should be clearable at any moment without loss.

## Routing

Top-level branch is **answer / diagnose / change**, not a maturity pipeline.
A certainty judgement applies only inside *change*.

Size is deliberately **not** a routing axis - "fits in one session" is discovered, not assessed.
It arrives as a trigger instead: the implementer reports "bigger than briefed" and the orchestrator re-routes.
As models improve and sessions get longer, that trigger silently stops firing and nothing needs rewriting.

Default is the smallest thing that could work.
Escalation requires a named reason.
This guards against the failure where ceremony exceeds task cost on the median request and the whole thing gets abandoned.

## Where the human goes

Kept:

- **Grilling** - the user's reactions are the input; it cannot be delegated or simulated.
- **Prototype reaction** - same reason.
- **Escalation after a failed fix loop** - with the diff.
- **Ship / show / ask.**

Removed:

- Route confirmation.
Replaced with announce-and-proceed, stating the one assumption that would flip the route.
Zero keystrokes to accept, one sentence to redirect.
- Line-by-line diff review, watching tests, per-edit approval.

The governing rule, from Pocock's `grilling` skill:

> If a fact can be found by exploring the environment, look it up rather than asking me.
> The decisions, though, are mine.

He added that as a bug fix - the older blanket wording read as license for an agent to answer its own *decisions* once grilling ran inside another skill's frame.

## The failure this is built to prevent

Verifier reports 3 failing tests.
Orchestrator spawns a *fresh* implementer with no memory of attempt 1.
It weakens an assertion, breaks something else, returns a confident summary.
Three rounds later the suite is green and tests nothing, and the orchestrator - which never reads code - cannot see it.

Countermeasures, all in the prompts:

1. Continue the same implementer via `SendMessage`, never respawn.
2. Two-attempt budget scaled by stakes, then escalate with the diff.
3. Verifier diffs test files and hard-fails on weakened assertions.
4. Orchestrator reads the diffstat itself.

## Deliberate deviations from Pocock

1. **He has no floor for small changes** - "use them every time you want to make a change."
We default to the smallest thing that works.
2. **He refuses to build an orchestration layer** - "how you run it is up to you."
No prior art to copy; this is the gap being filled.
3. **His router `ask-matt` is human-fired.**
Every orchestration skill of his is `disable-model-invocation: true`, so only the human starts a phase.
Ours routes autonomously.
That is the trade: speed, against the risk of being coherent about the wrong thing.

His warning, worth re-reading whenever this grows:

> Approaches like GSD, BMAD, and Spec-Kit try to help by owning the process.
> But while doing so, they take away your control and make bugs in the process hard to resolve.

## Roster

| Agent | Status |
|---|---|
| `Explore` | built-in, used as scout |
| `implementer` | custom - carries AGENTS.md + TDD |
| `verifier` | custom - no write, fresh context, absorbs review |
| `debugger` | custom - diagnosis only, does not fix |
