---
name: interview-to-spec
description: Interview the user in rounds to turn a fuzzy feature or app idea into a written spec (docs/specs/<slug>.md) that an implementing agent can build from without guessing. Use when the user asks to build, add, or create a new feature, app, service, or sizeable capability and no spec for it exists yet, or says "spec this", "let's spec out", "interview me", "write a spec". Not for bug fixes or small tweaks.
---

# Interview to Spec

The goal is to get what is in the user's head onto the page precisely enough that a different agent, with no access to this conversation, builds the right thing the first time. The spec is the deliverable. Do not plan the implementation and do not write code.

## Step 0: Orient in the codebase

Before asking anything, spend a few minutes reading. Questions shaped by the code are better than generic ones, and the user should never be asked something the repo already answers.

- Read the repo's `AGENTS.md` / `CLAUDE.md`, README, and any existing specs (look in `docs/specs/`, `docs/`, `specs/`). Match the style of existing specs. Note overlap with anything already specified.
- Decide: greenfield project, or feature in an existing repo?
- In an existing repo, locate what the feature would touch: related modules, data models, API or CLI surface, UI patterns, test setup, config. Note candidate "extend X or build new?" decisions.
- Keep it a survey, not an audit. Do not narrate it. Open round 1 with one short paragraph: what you found that is relevant, and what you are assuming because of it.

## Step 1: Interview in rounds

Ask in topic-batched rounds: one numbered list per round, roughly 3–6 questions. Each round is shaped by the answers to the last. Never one question at a time; never a single dump of twenty questions.

Question rules:
- Offer your best-guess default wherever you have one ("I'd assume X, correct?"). People correct faster than they generate.
- Ask only what you cannot infer from the code or the conversation.
- Add a one-line "why this matters" only when the reason is not obvious.
- Use the user's vocabulary, not spec jargon.
- When the user says "your call" or "you decide", pick, and record it as an agent default in the spec so they can see it.
- If the user says "just write it", stop asking, write the spec, and put everything unanswered under Open questions.

Round plan. Skip rounds already answered; merge rounds when there is little to ask.

1. **Problem and outcome.** Who it is for, what pain it removes, what "done" looks like, how success is judged, and what is explicitly out of scope.
2. **Users and flows.** The main path step by step and what the user sees at each step (screen, command, response). Secondary paths. Who else is affected (admins, other systems).
3. **Data and interfaces.** Entities and their fields, where they live, what is exposed (API, CLI, UI), how it connects to existing code. Extend-vs-new decisions surfaced in step 0 go here.
4. **Edge cases and failure.** Bad, empty, huge, duplicate, or concurrent input. Offline, timeouts, partial failure. What the user sees when it fails.
5. **Constraints.** Stack, allowed dependencies, performance numbers, auth and security, compatibility, migrations, where it runs, deadlines.
6. **Acceptance.** Turn everything above into checkable criteria. Read them back to the user and confirm before writing.

Stop when you could write every section of the spec without guessing.

## Step 2: Write the spec

Location: `docs/specs/<kebab-case-slug>.md` at the repo root, unless existing specs live elsewhere, in which case follow them. For a greenfield project with no repo yet, ask where it should go; default to `SPEC.md` at the project root.

Sections, in this order:

```markdown
# <Feature name>

Status: Draft | Reviewed | Approved
Date: YYYY-MM-DD
Summary: one sentence.

## Problem and goals
## Non-goals
## Users and flows
## Data and interfaces
## Edge cases and failure modes
## Constraints
## Acceptance criteria
## Decisions
## Open questions
## Existing code touched
```

Section notes:
- **Acceptance criteria** are numbered and each one must be checkable by an agent without asking anyone. Prefer Given/When/Then, or a concrete command and its expected output. "Should be fast" is not a criterion; "p95 under 200 ms on the seeded dataset" is.
- **Decisions** is a table: decision, choice, why, decided by (user or agent default). This is where "your call" answers land.
- **Open questions** lists anything unresolved and who needs to resolve it. An empty section is fine and is the goal.
- **Existing code touched** is for existing repos only: files or modules, and whether each is extended, replaced, or left alone.

Writing rules:
- Concrete over abstract. Name real files, endpoints, fields, commands.
- Say what, not how. Implementation order and architecture belong to the plan that follows. Include a "how" only when it is a constraint the user set.
- Short sentences. No filler.

## Step 3: Adversarial review

Before showing the user the draft, have it attacked by a reader with no conversation context.

- If the agent can spawn a clean-context subagent (in Claude Code, the `adversary` agent), give it the spec path and the repo, and ask for: statements an implementer would have to guess at, contradictions between sections, conflicts or duplication with existing code, missing edge cases, and acceptance criteria that are not actually checkable.
- Otherwise, do that review yourself in a separate pass, reading the spec as if you had never seen the conversation, against the same checklist.

Triage the findings. Fix what is clearly right. Anything that is a product decision goes back to the user as one final numbered round. Do not silently resolve product questions.

## Step 4: Hand off

- Set status to Reviewed.
- Show the user the spec path, the Decisions table, and any Open questions.
- Commit the spec following the global git rules. It is the first commit of the feature.
- Stop. Do not plan and do not implement. Say that the next step is to plan from the spec (in Claude Code: enter plan mode with the spec as input).
